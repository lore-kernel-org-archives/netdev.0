From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/16] ipv4: Add redirect support to all protocol icmp
 error handlers.
Date: Thu, 12 Jul 2012 01:11:20 -0700 (PDT)
Message-ID: <20120712.011120.1989024463196492967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758746Ab2GLILV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:21 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 22B295824C6
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c         |   11 +++++++++++
 net/ipv4/ah4.c          |   18 +++++++++++++-----
 net/ipv4/esp4.c         |   18 +++++++++++++-----
 net/ipv4/ip_gre.c       |    9 ++++++++-
 net/ipv4/ipcomp.c       |   18 +++++++++++++-----
 net/ipv4/ipip.c         |    9 +++++++++
 net/ipv4/ping.c         |    1 +
 net/ipv4/raw.c          |    2 ++
 net/ipv4/tcp_ipv4.c     |   11 +++++++++++
 net/ipv4/udp.c          |    3 +++
 net/ipv4/xfrm4_policy.c |   10 ++++++++++
 net/sctp/input.c        |   16 ++++++++++++++++
 12 files changed, 110 insertions(+), 16 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3eb76b5..8f41a319 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -195,6 +195,14 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 	} /* else let the usual retransmit timer handle it */
 }
 
+static void dccp_do_redirect(struct sk_buff *skb, struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_check(sk, 0);
+
+	if (dst && dst->ops->redirect)
+		dst->ops->redirect(dst, skb);
+}
+
 /*
  * This routine is called by the ICMP module when it gets some sort of error
  * condition. If err < 0 then the socket should be closed and the error
@@ -259,6 +267,9 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	}
 
 	switch (type) {
+	case ICMP_REDIRECT:
+		dccp_do_redirect(skb, sk);
+		goto out;
 	case ICMP_SOURCE_QUENCH:
 		/* Just silently ignore these. */
 		goto out;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 916d5ec..a0d8392 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -398,17 +398,25 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
-	if (icmp_hdr(skb)->type != ICMP_DEST_UNREACH ||
-	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+	switch (icmp_hdr(skb)->type) {
+	case ICMP_DEST_UNREACH:
+		if (icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+			return;
+	case ICMP_REDIRECT:
+		break;
+	default:
 		return;
+	}
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
-	pr_debug("pmtu discovery on SA AH/%08x/%08x\n",
-		 ntohl(ah->spi), ntohl(iph->daddr));
-	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
+
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
+	else
+		ipv4_redirect(skb, net, 0, 0, IPPROTO_AH, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7b95b49..b61e9de 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -484,17 +484,25 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
-	if (icmp_hdr(skb)->type != ICMP_DEST_UNREACH ||
-	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+	switch (icmp_hdr(skb)->type) {
+	case ICMP_DEST_UNREACH:
+		if (icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+			return;
+	case ICMP_REDIRECT:
+		break;
+	default:
 		return;
+	}
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
-		 ntohl(esph->spi), ntohl(iph->daddr));
-	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
+
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
+	else
+		ipv4_redirect(skb, net, 0, 0, IPPROTO_ESP, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 594cec3..0c31235 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -528,6 +528,9 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		if (code != ICMP_EXC_TTL)
 			return;
 		break;
+
+	case ICMP_REDIRECT:
+		break;
 	}
 
 	rcu_read_lock();
@@ -543,7 +546,11 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 				 t->parms.link, 0, IPPROTO_GRE, 0);
 		goto out;
 	}
-
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
+			      IPPROTO_GRE, 0);
+		goto out;
+	}
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
 		goto out;
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index b913754..d3ab47e 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -31,18 +31,26 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 	struct ip_comp_hdr *ipch = (struct ip_comp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
-	if (icmp_hdr(skb)->type != ICMP_DEST_UNREACH ||
-	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+	switch (icmp_hdr(skb)->type) {
+	case ICMP_DEST_UNREACH:
+		if (icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+			return;
+	case ICMP_REDIRECT:
+		break;
+	default:
 		return;
+	}
 
 	spi = htonl(ntohs(ipch->cpi));
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%pI4\n",
-		 spi, &iph->daddr);
-	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
+
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
+	else
+		ipv4_redirect(skb, net, 0, 0, IPPROTO_COMP, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 715338a..c2d0e6d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -360,6 +360,8 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 		if (code != ICMP_EXC_TTL)
 			return 0;
 		break;
+	case ICMP_REDIRECT:
+		break;
 	}
 
 	err = -ENOENT;
@@ -376,6 +378,13 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 		goto out;
 	}
 
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), t->dev->ifindex, 0,
+			      IPPROTO_IPIP, 0);
+		err = 0;
+		goto out;
+	}
+
 	if (t->parms.iph.daddr == 0)
 		goto out;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 340fcf2..6232d47 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -387,6 +387,7 @@ void ping_err(struct sk_buff *skb, u32 info)
 		break;
 	case ICMP_REDIRECT:
 		/* See ICMP_SOURCE_QUENCH */
+		ipv4_sk_redirect(skb, sk);
 		err = EREMOTEIO;
 		break;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 659ddfb..ff0f071 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -218,6 +218,8 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
 		ipv4_sk_update_pmtu(skb, sk, info);
+	else if (type == ICMP_REDIRECT)
+		ipv4_sk_redirect(skb, sk);
 
 	/* Report error on raw socket, if:
 	   1. User requested ip_recverr.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 01545a3..087a848 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -321,6 +321,14 @@ static void do_pmtu_discovery(struct sock *sk, const struct iphdr *iph, u32 mtu)
 	} /* else let the usual retransmit timer handle it */
 }
 
+static void do_redirect(struct sk_buff *skb, struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_check(sk, 0);
+
+	if (dst && dst->ops->redirect)
+		dst->ops->redirect(dst, skb);
+}
+
 /*
  * This routine is called by the ICMP module when it gets some
  * sort of error condition.  If err < 0 then the socket should
@@ -394,6 +402,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	}
 
 	switch (type) {
+	case ICMP_REDIRECT:
+		do_redirect(icmp_skb, sk);
+		goto out;
 	case ICMP_SOURCE_QUENCH:
 		/* Just silently ignore these. */
 		goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ee37d47..b4c3582 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -630,6 +630,9 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 			err = icmp_err_convert[code].errno;
 		}
 		break;
+	case ICMP_REDIRECT:
+		ipv4_sk_redirect(skb, sk);
+		break;
 	}
 
 	/*
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 87d3fcc..258ebd7 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -202,6 +202,15 @@ static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu)
 	path->ops->update_pmtu(path, mtu);
 }
 
+static void xfrm4_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	struct dst_entry *path = xdst->route;
+
+	if (path->ops->redirect)
+		path->ops->redirect(path, skb);
+}
+
 static void xfrm4_dst_destroy(struct dst_entry *dst)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
@@ -225,6 +234,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
+	.redirect =		xfrm4_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 80564fe..9fb4247 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -423,6 +423,18 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
 }
 
+static void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
+			       struct sk_buff *skb)
+{
+	struct dst_entry *dst;
+
+	if (!t)
+		return;
+	dst = sctp_transport_dst_check(t);
+	if (dst && dst->ops->redirect)
+		dst->ops->redirect(dst, skb);
+}
+
 /*
  * SCTP Implementer's Guide, 2.37 ICMP handling procedures
  *
@@ -628,6 +640,10 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 
 		err = EHOSTUNREACH;
 		break;
+	case ICMP_REDIRECT:
+		sctp_icmp_redirect(sk, transport, skb);
+		err = 0;
+		break;
 	default:
 		goto out_unlock;
 	}
-- 
1.7.10.4
