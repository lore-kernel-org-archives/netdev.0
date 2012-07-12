From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/16] ipv6: Add redirect support to all protocol icmp
 error handlers.
Date: Thu, 12 Jul 2012 01:12:12 -0700 (PDT)
Message-ID: <20120712.011212.345092134877777384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932904Ab2GLIMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:12:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 9A2215824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:12:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sctp/sctp.h |    2 ++
 net/dccp/ipv6.c         |    7 +++++++
 net/ipv6/ah6.c          |   10 ++++++----
 net/ipv6/esp6.c         |   11 +++++++----
 net/ipv6/ip6_tunnel.c   |    7 +++++++
 net/ipv6/ipcomp6.c      |   11 +++++++----
 net/ipv6/raw.c          |    2 ++
 net/ipv6/sit.c          |    8 ++++++++
 net/ipv6/tcp_ipv6.c     |    7 +++++++
 net/ipv6/udp.c          |    2 ++
 net/ipv6/xfrm6_policy.c |    9 +++++++++
 net/sctp/input.c        |    4 ++--
 net/sctp/ipv6.c         |    3 +++
 13 files changed, 69 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index a2ef814..1f2735d 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -162,6 +162,8 @@ struct sock *sctp_err_lookup(int family, struct sk_buff *,
 void sctp_err_finish(struct sock *, struct sctp_association *);
 void sctp_icmp_frag_needed(struct sock *, struct sctp_association *,
 			   struct sctp_transport *t, __u32 pmtu);
+void sctp_icmp_redirect(struct sock *, struct sctp_transport *,
+			struct sk_buff *);
 void sctp_icmp_proto_unreachable(struct sock *sk,
 				 struct sctp_association *asoc,
 				 struct sctp_transport *t);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 02162cf..b4d7d28 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -130,6 +130,13 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
+	if (type == NDISC_REDIRECT) {
+		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
+
+		if (dst && dst->ops->redirect)
+			dst->ops->redirect(dst, skb);
+	}
+
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 49d4d26..7e61395 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -613,16 +613,18 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG)
+	    type != ICMPV6_PKT_TOOBIG &&
+	    type != NDISC_REDIRECT)
 		return;
 
 	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
 	if (!x)
 		return;
 
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/%pI6\n",
-		 ntohl(ah->spi), &iph->daddr);
-	ip6_update_pmtu(skb, net, info, 0, 0);
+	if (type == NDISC_REDIRECT)
+		ip6_redirect(skb, net, 0, 0);
+	else
+		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89a615b..6dc7fd3 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -434,16 +434,19 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG)
+	    type != ICMPV6_PKT_TOOBIG &&
+	    type != NDISC_REDIRECT)
 		return;
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
-	pr_debug("pmtu discovery on SA ESP/%08x/%pI6\n",
-		 ntohl(esph->spi), &iph->daddr);
-	ip6_update_pmtu(skb, net, info, 0, 0);
+
+	if (type == NDISC_REDIRECT)
+		ip6_redirect(skb, net, 0, 0);
+	else
+		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6af3fcf..0b5b60e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -550,6 +550,9 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_type = ICMP_DEST_UNREACH;
 		rel_code = ICMP_FRAG_NEEDED;
 		break;
+	case NDISC_REDIRECT:
+		rel_type = ICMP_REDIRECT;
+		rel_code = ICMP_REDIR_HOST;
 	default:
 		return 0;
 	}
@@ -608,6 +611,10 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), rel_info);
 	}
+	if (rel_type == ICMP_REDIRECT) {
+		if (skb_dst(skb2)->ops->redirect)
+			skb_dst(skb2)->ops->redirect(skb_dst(skb2), skb2);
+	}
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 9283238..7af5aee 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -64,7 +64,9 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		(struct ip_comp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH && type != ICMPV6_PKT_TOOBIG)
+	if (type != ICMPV6_DEST_UNREACH &&
+	    type != ICMPV6_PKT_TOOBIG &&
+	    type != NDISC_REDIRECT)
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
@@ -73,9 +75,10 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	pr_debug("pmtu discovery on SA IPCOMP/%08x/%pI6\n",
-		 spi, &iph->daddr);
-	ip6_update_pmtu(skb, net, info, 0, 0);
+	if (type == NDISC_REDIRECT)
+		ip6_redirect(skb, net, 0, 0);
+	else
+		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index b5c1dcb..ef0579d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -332,6 +332,8 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		ip6_sk_update_pmtu(skb, sk, info);
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
 	}
+	if (type == NDISC_REDIRECT)
+		ip6_sk_redirect(skb, sk);
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 49aea94..fbf1622 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -539,6 +539,8 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		if (code != ICMP_EXC_TTL)
 			return 0;
 		break;
+	case ICMP_REDIRECT:
+		break;
 	}
 
 	err = -ENOENT;
@@ -557,6 +559,12 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		err = 0;
 		goto out;
 	}
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), t->dev->ifindex, 0,
+			      IPPROTO_IPV6, 0);
+		err = 0;
+		goto out;
+	}
 
 	if (t->parms.iph.daddr == 0)
 		goto out;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 70458a9..7249e4b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -363,6 +363,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
+	if (type == NDISC_REDIRECT) {
+		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
+
+		if (dst && dst->ops->redirect)
+			dst->ops->redirect(dst,skb);
+	}
+
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1ecd102..99d0077 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -483,6 +483,8 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_sk_update_pmtu(skb, sk, info);
+	if (type == NDISC_REDIRECT)
+		ip6_sk_redirect(skb, sk);
 
 	np = inet6_sk(sk);
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index bb02038..f5a9cb8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -215,6 +215,14 @@ static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
 	path->ops->update_pmtu(path, mtu);
 }
 
+static void xfrm6_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	struct dst_entry *path = xdst->route;
+
+	path->ops->redirect(path, skb);
+}
+
 static void xfrm6_dst_destroy(struct dst_entry *dst)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
@@ -261,6 +269,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
+	.redirect =		xfrm6_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 9fb4247..5943b7d 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -423,8 +423,8 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
 }
 
-static void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
-			       struct sk_buff *skb)
+void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
+			struct sk_buff *skb)
 {
 	struct dst_entry *dst;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 91f4791..ed7139e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -185,6 +185,9 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out_unlock;
 		}
 		break;
+	case NDISC_REDIRECT:
+		sctp_icmp_redirect(sk, transport, skb);
+		break;
 	default:
 		break;
 	}
-- 
1.7.10.4
