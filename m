From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 1/3] net-timestamp: no-payload option
Date: Fri, 30 Jan 2015 13:29:31 -0500
Message-ID: <1422642573-6126-2-git-send-email-willemb@google.com>
References: <1422642573-6126-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:33809 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762881AbbA3S3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 13:29:52 -0500
Received: by mail-yh0-f45.google.com with SMTP id f73so11652064yha.4
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 10:29:51 -0800 (PST)
In-Reply-To: <1422642573-6126-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add timestamping option SOF_TIMESTAMPING_OPT_TSONLY. For transmit
timestamps, this loops timestamps on top of empty packets.

Doing so reduces the pressure on SO_RCVBUF. Payload inspection and
cmsg reception (aside from timestamps) are no longer possible. This
works together with a follow on patch that allows administrators to
only allow tx timestamping if it does not loop payload or metadata.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

Changes (rfc -> v1)
  - add documentation
  - remove unnecessary skb->len test (thanks to Richard Cochran)
---
 Documentation/networking/timestamping.txt | 21 +++++++++++++++++++++
 include/uapi/linux/net_tstamp.h           |  3 ++-
 net/core/skbuff.c                         | 19 ++++++++++++++-----
 net/ipv4/ip_sockglue.c                    |  7 ++++---
 net/ipv6/datagram.c                       |  5 ++---
 net/rxrpc/ar-error.c                      |  5 +++++
 6 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index a5c784c..5f09226 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -162,6 +162,27 @@ SOF_TIMESTAMPING_OPT_CMSG:
   option IP_PKTINFO simultaneously.
 
 
+SOF_TIMESTAMPING_OPT_TSONLY:
+
+  Applies to transmit timestamps only. Makes the kernel return the
+  timestamp as a cmsg alongside an empty packet, as opposed to
+  alongside the original packet. This reduces the amount of memory
+  charged to the socket's receive budget (SO_RCVBUF) and delivers
+  the timestamp even if sysctl net.core.tstamp_allow_data is 0.
+  This option disables SOF_TIMESTAMPING_OPT_CMSG.
+
+
+New applications are encouraged to pass SOF_TIMESTAMPING_OPT_ID to
+disambiguate timestamps and SOF_TIMESTAMPING_OPT_TSONLY to operate
+regardless of the setting of sysctl net.core.tstamp_allow_data.
+
+An exception is when a process needs additional cmsg data, for
+instance SOL_IP/IP_PKTINFO to detect the egress network interface.
+Then pass option SOF_TIMESTAMPING_OPT_CMSG. This option depends on
+having access to the contents of the original packet, so cannot be
+combined with SOF_TIMESTAMPING_OPT_TSONLY.
+
+
 1.4 Bytestream Timestamps
 
 The SO_TIMESTAMPING interface supports timestamping of bytes in a
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index edbc888..6d1abea 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -24,8 +24,9 @@ enum {
 	SOF_TIMESTAMPING_TX_SCHED = (1<<8),
 	SOF_TIMESTAMPING_TX_ACK = (1<<9),
 	SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
+	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_CMSG,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TSONLY,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 56db472..65a3798 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3710,19 +3710,28 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct sock *sk, int tstype)
 {
 	struct sk_buff *skb;
+	bool tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
 
 	if (!sk)
 		return;
 
-	if (hwtstamps)
-		*skb_hwtstamps(orig_skb) = *hwtstamps;
+	if (tsonly)
+		skb = alloc_skb(0, GFP_ATOMIC);
 	else
-		orig_skb->tstamp = ktime_get_real();
-
-	skb = skb_clone(orig_skb, GFP_ATOMIC);
+		skb = skb_clone(orig_skb, GFP_ATOMIC);
 	if (!skb)
 		return;
 
+	if (tsonly) {
+		skb_shinfo(skb)->tx_flags = skb_shinfo(orig_skb)->tx_flags;
+		skb_shinfo(skb)->tskey = skb_shinfo(orig_skb)->tskey;
+	}
+
+	if (hwtstamps)
+		*skb_hwtstamps(skb) = *hwtstamps;
+	else
+		skb->tstamp = ktime_get_real();
+
 	__skb_complete_tx_timestamp(skb, sk, tstype);
 }
 EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index db5e0f8..31d8c71 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -483,7 +483,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
 						   serr->addr_offset);
@@ -496,8 +496,9 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	sin = &errhdr.offender;
 	memset(sin, 0, sizeof(*sin));
 
-	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
-	    ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin)) {
+	if (skb->len &&
+	    (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
+	     ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin))) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
 		if (inet_sk(sk)->cmsg_flags)
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 49f5e73..c215be7 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -369,7 +369,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		const unsigned char *nh = skb_network_header(skb);
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
@@ -394,8 +394,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
 	memset(sin, 0, sizeof(*sin));
-
-	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
+	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL && skb->len) {
 		sin->sin6_family = AF_INET6;
 		if (np->rxopt.all) {
 			if (serr->ee.ee_origin != SO_EE_ORIGIN_ICMP &&
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 74c0fcd..5394b6b 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -42,6 +42,11 @@ void rxrpc_UDP_error_report(struct sock *sk)
 		_leave("UDP socket errqueue empty");
 		return;
 	}
+	if (!skb->len) {
+		_leave("UDP empty message");
+		kfree_skb(skb);
+		return;
+	}
 
 	rxrpc_new_skb(skb);
 
-- 
2.2.0.rc0.207.ga3a616c
