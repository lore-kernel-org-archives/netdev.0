From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 1/6] ipv6: del the statements for updating route in, (dccp|tcp|sctp)_v6_err
Date: Mon, 16 Sep 2013 19:49:19 +0800
Message-ID: <5236F03F.5020407@cn.fujitsu.com>
References: <5236EFEB.60106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53059 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756615Ab3IPLuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 07:50:18 -0400
In-Reply-To: <5236EFEB.60106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we will do route updating for redirect in nidsc layer. And
when dealing with redirect message, the dccp and sctp should like
tcp return directly.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/dccp/ipv6.c     | 10 +++-------
 net/ipv6/tcp_ipv6.c | 12 ++++--------
 net/sctp/input.c    | 12 ------------
 net/sctp/ipv6.c     |  6 +++---
 4 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c61f9c..300840c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -98,6 +98,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	}
 
+	if (type == NDISC_REDIRECT)
+		return;
+
 	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
@@ -130,13 +133,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..d3ca8a4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -346,6 +346,10 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u32 seq;
 	struct net *net = dev_net(skb->dev);
 
+
+	if (type == NDISC_REDIRECT)
+		return;
+
 	sk = inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
 			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
@@ -382,14 +386,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-		goto out;
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		/* We are not interested in TCP_LISTEN and open_requests
 		 * (SYN-ACKs send out by Linux are always <576bytes so
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5f20686..0d2d4b7 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -413,18 +413,6 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
 }
 
-void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
-			struct sk_buff *skb)
-{
-	struct dst_entry *dst;
-
-	if (!t)
-		return;
-	dst = sctp_transport_dst_check(t);
-	if (dst)
-		dst->ops->redirect(dst, sk, skb);
-}
-
 /*
  * SCTP Implementer's Guide, 2.37 ICMP handling procedures
  *
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index da613ce..ee12d87 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -151,6 +151,9 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	struct net *net = dev_net(skb->dev);
 
+	if (type == NDISC_REDIRECT)
+		return;
+
 	idev = in6_dev_get(skb->dev);
 
 	/* Fix up skb to look at the embedded net header. */
@@ -181,9 +184,6 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out_unlock;
 		}
 		break;
-	case NDISC_REDIRECT:
-		sctp_icmp_redirect(sk, transport, skb);
-		break;
 	default:
 		break;
 	}
-- 
1.8.3.1
