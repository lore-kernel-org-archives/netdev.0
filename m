From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 2/6] IPv6: Do mandatory IPv6 tunnel endpoint checks in realtime
Date: Thu, 02 Nov 2006 13:31:34 +0200
Message-ID: <4549D716.7090600@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050803060401060703020803"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:46985 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1752536AbWKBLbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:31:43 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050803060401060703020803
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------050803060401060703020803
Content-Type: text/plain;
 name*0="0002-IPv6-Do-mandatory-ip6_tunnel-endpoint-checks-in-realtime.tx";
 name*1="t"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-IPv6-Do-mandatory-ip6_tunnel-endpoint-checks-in-realtim";
 filename*1="e.txt"

>From e60ed41fb11793d16ffcbfd56b889e0bbf04ea88 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 12:43:50 +0200
Subject: [PATCH 2/6] IPv6: Do mandatory IPv6 tunnel endpoint checks in realtime

Doing the mandatory tunnel endpoint checks when the tunnel is set up
isn't enough as interfaces can go up or down and addresses can be
added or deleted after this. The checks need to be done realtime when
the tunnel is processing a packet.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |   96 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 62 insertions(+), 34 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e61458c..2467b04 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -494,6 +494,27 @@ static inline void ip6ip6_ecn_decapsulat
 	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
 		IP6_ECN_set_ce(inner_iph);
 }
+static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
+{
+	struct ip6_tnl_parm *p = &t->parms;
+	int ret = 0;
+
+	if (p->flags & IP6_TNL_F_CAP_RCV) {
+    		struct net_device *ldev = NULL;
+
+		if (p->link)
+			ldev = dev_get_by_index(p->link);
+
+		if ((ipv6_addr_is_multicast(&p->laddr) ||
+		     likely(ipv6_chk_addr(&p->laddr, ldev, 0))) &&
+		    likely(!ipv6_chk_addr(&p->raddr, NULL, 0)))
+			ret = 1;
+
+		if (ldev)
+			dev_put(ldev);
+	}
+	return ret;
+}
 
 /**
  * ip6ip6_rcv - decapsulate IPv6 packet and retransmit it locally
@@ -518,7 +539,7 @@ ip6ip6_rcv(struct sk_buff *skb)
 			goto discard;
 		}
 
-		if (!(t->parms.flags & IP6_TNL_F_CAP_RCV)) {
+		if (!ip6_tnl_rcv_ctl(t)) {
 			t->stat.rx_dropped++;
 			read_unlock(&ip6ip6_lock);
 			goto discard;
@@ -596,6 +617,34 @@ ip6ip6_tnl_addr_conflict(struct ip6_tnl
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
 
+static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
+{
+	struct ip6_tnl_parm *p = &t->parms;
+	int ret = 0;
+
+ 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
+		struct net_device *ldev = NULL;
+
+		if (p->link)
+			ldev = dev_get_by_index(p->link);
+
+		if (unlikely(!ipv6_chk_addr(&p->laddr, ldev, 0)))
+			printk(KERN_WARNING
+			       "%s xmit: Local address not yet configured!\n",
+			       p->name);
+		else if (!ipv6_addr_is_multicast(&p->raddr) &&
+			 unlikely(ipv6_chk_addr(&p->raddr, NULL, 0)))
+			printk(KERN_WARNING
+			       "%s xmit: Routing loop! "
+			       "Remote address found on this node!\n",
+			       p->name);
+		else
+			ret = 1;
+		if (ldev)
+			dev_put(ldev);
+	}
+	return ret;
+}
 /**
  * ip6ip6_tnl_xmit - encapsulate packet and send 
  *   @skb: the outgoing socket buffer
@@ -633,10 +682,9 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 		goto tx_err;
 	}
 	if (skb->protocol != htons(ETH_P_IPV6) ||
-	    !(t->parms.flags & IP6_TNL_F_CAP_XMIT) ||
-	    ip6ip6_tnl_addr_conflict(t, ipv6h)) {
+	    !ip6_tnl_xmit_ctl(t) || ip6ip6_tnl_addr_conflict(t, ipv6h))
 		goto tx_err;
-	}
+
 	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->nh.raw[offset];
@@ -767,39 +815,19 @@ tx_err:
 static void ip6_tnl_set_cap(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
-	struct in6_addr *laddr = &p->laddr;
-	struct in6_addr *raddr = &p->raddr;
-	int ltype = ipv6_addr_type(laddr);
-	int rtype = ipv6_addr_type(raddr);
+	int ltype = ipv6_addr_type(&p->laddr);
+	int rtype = ipv6_addr_type(&p->raddr);
 
 	p->flags &= ~(IP6_TNL_F_CAP_XMIT|IP6_TNL_F_CAP_RCV);
 
-	if (ltype != IPV6_ADDR_ANY && rtype != IPV6_ADDR_ANY &&
-	    ((ltype|rtype) &
-	     (IPV6_ADDR_UNICAST|
-	      IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL|
-	      IPV6_ADDR_MAPPED|IPV6_ADDR_RESERVED)) == IPV6_ADDR_UNICAST) {
-		struct net_device *ldev = NULL;
-		int l_ok = 1;
-		int r_ok = 1;
-
-		if (p->link)
-			ldev = dev_get_by_index(p->link);
-		
-		if (ltype&IPV6_ADDR_UNICAST && !ipv6_chk_addr(laddr, ldev, 0))
-			l_ok = 0;
-		
-		if (rtype&IPV6_ADDR_UNICAST && ipv6_chk_addr(raddr, NULL, 0))
-			r_ok = 0;
-		
-		if (l_ok && r_ok) {
-			if (ltype&IPV6_ADDR_UNICAST)
-				p->flags |= IP6_TNL_F_CAP_XMIT;
-			if (rtype&IPV6_ADDR_UNICAST)
-				p->flags |= IP6_TNL_F_CAP_RCV;
-		}
-		if (ldev)
-			dev_put(ldev);
+	if (ltype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
+	    rtype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
+	    !((ltype|rtype) & IPV6_ADDR_LOOPBACK) &&
+	    !((ltype|rtype) & IPV6_ADDR_LINKLOCAL)) {
+		if (ltype&IPV6_ADDR_UNICAST)
+			p->flags |= IP6_TNL_F_CAP_XMIT;
+		if (rtype&IPV6_ADDR_UNICAST)
+			p->flags |= IP6_TNL_F_CAP_RCV;
 	}
 }
 
-- 
1.4.3.2


--------------050803060401060703020803--
