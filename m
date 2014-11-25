From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc 2/4] net-errqueue: add IP(V6)_PKTINFO support
Date: Tue, 25 Nov 2014 12:58:04 -0500
Message-ID: <1416938286-14147-3-git-send-email-willemb@google.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:59541 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaKYR6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:58:13 -0500
Received: by mail-yk0-f179.google.com with SMTP id 19so499492ykq.24
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:58:12 -0800 (PST)
In-Reply-To: <1416938286-14147-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

On INET and INET6 sockets with the IP_PKTINFO or IPV6_RECVPKTINFO
socket option set, return a matching cmsg also for packets queued
to the error queue.

These packets are transmitted packets looped back. The fields of
struct in[6]_pktinfo are changed to reflect that:

  ifindex:   index of the outgoing device, if configured
  addr:      destination address
  spec_dst:  source address  (absent in v6)

On IPv6, the mechanism currently returns two IPV6_PKTINFO when
the option is enabled, because the existing code already supports
the feature. The legacy data does not produce a correct ifindex,
however. Perhaps I can revise the patch to only send the legacy
patch, but use the correct ifindex source in case of ERRQUEUE.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_sockglue.c | 15 +++++++++++++++
 net/ipv6/datagram.c    | 22 ++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b782657..615f783 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -399,6 +399,20 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
 		kfree_skb(skb);
 }
 
+static void ip_recv_error_pktinfo(struct msghdr *msg, struct sock *sk,
+				  struct sk_buff *skb)
+{
+	if (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO && skb->dev) {
+		struct in_pktinfo info = {0};
+
+		info.ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
+		info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
+		info.ipi_ifindex = skb->dev->ifindex;
+
+		put_cmsg(msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
+	}
+}
+
 /*
  *	Handle MSG_ERRQUEUE
  */
@@ -429,6 +443,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		goto out_free_skb;
 
 	sock_recv_timestamp(msg, sk, skb);
+	ip_recv_error_pktinfo(msg, sk, skb);
 
 	serr = SKB_EXT_ERR(skb);
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index cc11396..7d2ef7c 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -325,6 +325,27 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 	kfree_skb(skb);
 }
 
+static void ipv6_recv_error_pktinfo(struct msghdr *msg, struct sock *sk,
+				    struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	if (np->rxopt.bits.rxinfo && skb->dev) {
+		struct in6_pktinfo info;
+
+		memset(&info, 0, sizeof(info));
+		if (skb->protocol == htons(ETH_P_IPV6))
+			info.ipi6_addr = ipv6_hdr(skb)->daddr;
+		else
+			ipv6_addr_set_v4mapped(ip_hdr(skb)->daddr,
+					       &info.ipi6_addr);
+
+		info.ipi6_ifindex = skb->dev->ifindex;
+		net_info_ratelimited("yes: ifindex=%d\n", info.ipi6_ifindex);
+		put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(info), &info);
+	}
+}
+
 /*
  *	Handle MSG_ERRQUEUE
  */
@@ -356,6 +377,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		goto out_free_skb;
 
 	sock_recv_timestamp(msg, sk, skb);
+	ipv6_recv_error_pktinfo(msg, sk, skb);
 
 	serr = SKB_EXT_ERR(skb);
 
-- 
2.1.0.rc2.206.gedb03e5
