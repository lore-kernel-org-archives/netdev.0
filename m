From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 3/6] net-timestamp: add key to disambiguate concurrent datagrams
Date: Mon,  4 Aug 2014 22:11:47 -0400
Message-ID: <1407204710-21778-4-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:39527 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so83891pab.0
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:53 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Datagrams timestamped on transmission can coexist in the kernel stack
and be reordered in packet scheduling. When reading looped datagrams
from the socket error queue it is not always possible to unique
correlate looped data with original send() call (for application
level retransmits). Even if possible, it may be expensive and complex,
requiring packet inspection.

Introduce a data-independent ID mechanism to associate timestamps with
send calls. Pass an ID alongside the timestamp in field ee_data of
sock_extended_err.

The ID is a simple 32 bit unsigned int that is associated with the
socket and incremented on each send() call for which software tx
timestamp generation is enabled.

The feature is enabled only if SOF_TIMESTAMPING_OPT_ID is set, to
avoid changing ee_data for existing applications that expect it 0.
The counter is reset each time the flag is reenabled. Reenabling
does not change the ID of already submitted data. It is possible
to receive out of order IDs if the timestamp stream is not quiesced
first.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h          | 1 +
 include/net/sock.h              | 2 ++
 include/uapi/linux/net_tstamp.h | 8 +++++---
 net/core/skbuff.c               | 2 ++
 net/core/sock.c                 | 3 +++
 net/ipv4/ip_output.c            | 6 ++++++
 net/ipv6/ip6_output.c           | 9 ++++++++-
 7 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 477f0f6..0e35b3a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -278,6 +278,7 @@ struct skb_shared_info {
 	unsigned short  gso_type;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+	u32		tskey;
 	__be32          ip6_frag_id;
 
 	/*
diff --git a/include/net/sock.h b/include/net/sock.h
index a211297..52fe0bc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -280,6 +280,7 @@ struct cg_proto;
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
   *	@sk_tsflags: SO_TIMESTAMPING socket options
+  *	@sk_tskey: counter to disambiguate concurrent tstamp requests
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
   *	@sk_frag: cached page frag
@@ -414,6 +415,7 @@ struct sock {
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	u16			sk_tsflags;
+	u32			sk_tskey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct page_frag	sk_frag;
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index f53879c..1e861d2 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -20,9 +20,11 @@ enum {
 	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
-	SOF_TIMESTAMPING_MASK =
-	(SOF_TIMESTAMPING_RAW_HARDWARE - 1) |
-	SOF_TIMESTAMPING_RAW_HARDWARE
+	SOF_TIMESTAMPING_OPT_ID = (1<<7),
+
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_ID,
+	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
+				 SOF_TIMESTAMPING_LAST
 };
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c9f6880..0df4f1d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3522,6 +3522,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	serr->ee.ee_info = SCM_TSTAMP_SND;
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
+		serr->ee.ee_data = skb_shinfo(skb)->tskey;
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 47c9377..1e0f1c6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -848,6 +848,9 @@ set_rcvbuf:
 			ret = -EINVAL;
 			break;
 		}
+		if (val & SOF_TIMESTAMPING_OPT_ID &&
+		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID))
+			sk->sk_tskey = 0;
 		sk->sk_tsflags = val;
 		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
 			sock_enable_timestamp(sk,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b165568..215af2b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -855,11 +855,15 @@ static int __ip_append_data(struct sock *sk,
 	unsigned int maxfraglen, fragheaderlen, maxnonfragsize;
 	int csummode = CHECKSUM_NONE;
 	struct rtable *rt = (struct rtable *)cork->dst;
+	u32 tskey = 0;
 
 	skb = skb_peek_tail(queue);
 
 	exthdrlen = !skb ? rt->dst.header_len : 0;
 	mtu = cork->fragsize;
+	if (cork->tx_flags & SKBTX_ANY_SW_TSTAMP &&
+	    sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
+		tskey = sk->sk_tskey++;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 
@@ -976,6 +980,8 @@ alloc_new_skb:
 			/* only the initial fragment is time stamped */
 			skb_shinfo(skb)->tx_flags = cork->tx_flags;
 			cork->tx_flags = 0;
+			skb_shinfo(skb)->tskey = tskey;
+			tskey = 0;
 
 			/*
 			 *	Find where to start putting bytes.
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f5dafe6..315a55d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1157,6 +1157,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int err;
 	int offset = 0;
 	__u8 tx_flags = 0;
+	u32 tskey = 0;
 
 	if (flags&MSG_PROBE)
 		return 0;
@@ -1272,8 +1273,12 @@ emsgsize:
 		}
 	}
 
-	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW)
+	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW) {
 		sock_tx_timestamp(sk, &tx_flags);
+		if (tx_flags & SKBTX_ANY_SW_TSTAMP &&
+		    sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
+			tskey = sk->sk_tskey++;
+	}
 
 	/*
 	 * Let's try using as much space as possible.
@@ -1397,6 +1402,8 @@ alloc_new_skb:
 			/* Only the initial fragment is time stamped */
 			skb_shinfo(skb)->tx_flags = tx_flags;
 			tx_flags = 0;
+			skb_shinfo(skb)->tskey = tskey;
+			tskey = 0;
 
 			/*
 			 *	Find where to start putting bytes
-- 
2.0.0.526.g5318336
