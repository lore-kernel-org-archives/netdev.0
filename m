From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Fri,  9 Jan 2015 12:31:55 -0500
Message-ID: <1420824719-28848-2-git-send-email-willemb@google.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:34722 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbbAIRcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:06 -0500
Received: by mail-yh0-f44.google.com with SMTP id c41so4711068yho.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:05 -0800 (PST)
In-Reply-To: <1420824719-28848-1-git-send-email-willemb@google.com>
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
---
 include/uapi/linux/net_tstamp.h |  3 ++-
 net/core/skbuff.c               | 19 ++++++++++++++-----
 net/ipv4/ip_sockglue.c          |  9 +++++----
 net/ipv6/datagram.c             |  4 ++--
 net/rxrpc/ar-error.c            |  5 +++++
 5 files changed, 28 insertions(+), 12 deletions(-)

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
index 5a2a2e8..ece2bb8 100644
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
index a317797..d81ef70 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -440,7 +440,7 @@ static bool ipv4_pktinfo_prepare_errqueue(const struct sock *sk,
 
 	if ((ee_origin != SO_EE_ORIGIN_TIMESTAMPING) ||
 	    (!(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_CMSG)) ||
-	    (!skb->dev))
+	    (!skb->dev) || (!skb->len))
 		return false;
 
 	info->ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
@@ -483,7 +483,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
 						   serr->addr_offset);
@@ -496,8 +496,9 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	sin = &errhdr.offender;
 	sin->sin_family = AF_UNSPEC;
 
-	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
-	    ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin)) {
+	if (skb->len &&
+	    (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
+	     ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin))) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		sin->sin_family = AF_INET;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 100c589..91a31ea 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -369,7 +369,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		const unsigned char *nh = skb_network_header(skb);
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
@@ -394,7 +394,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
 	sin->sin6_family = AF_UNSPEC;
-	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
+	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL && skb->len) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = 0;
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
