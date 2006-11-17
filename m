From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH 2.6.19] IPv6 Fixes
Date: Fri, 17 Nov 2006 15:32:54 +0900 (JST)
Message-ID: <20061117.153254.11726398.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:25472 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1162413AbWKQGdB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 01:33:01 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Please consider pulling from the "2.6.19-rc6-20061117-to-davem-20061117" 
branch at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev/>,
which contains the following changesets:

HEADLINES
---------

    [IPV6] ROUTE: Try to use router which is not known unreachable.
    [IPV6] ROUTE: Prefer reachable nexthop only if the caller requests.
    [IPV6] ROUTE: Do not enable router reachability probing in router mode.
    [IPV6] IP6TUNNEL: Delete all tunnel device when unloading module.
    [IPV6] IP6TUNNEL: Add missing nf_reset() on input path.

DIFFSTAT
--------

 net/ipv6/ip6_tunnel.c |   19 ++++++++++++++++++-
 net/ipv6/route.c      |   15 ++++++++-------
 2 files changed, 26 insertions(+), 8 deletions(-)

CHANGESETS
----------

commit 20081a591eade6e21692b181af8eaf03adce828d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Nov 6 09:45:44 2006 -0800

    [IPV6] ROUTE: Try to use router which is not known unreachable.
    
    Only routers in "FAILED" state should be considered unreachable.
    Otherwise, we do not try to use speicific routes unless all least specific
    routers are considered unreachable.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c953466..5132821 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -330,6 +330,8 @@ static int inline rt6_check_neigh(struct
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
 			m = 2;
+		else if (!(neigh->nud_state & NUD_FAILED))
+			m = 1;
 		read_unlock_bh(&neigh->lock);
 	}
 	return m;

---
commit fb15463574afe3180061752da672fe311b9b6033
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Nov 6 09:45:45 2006 -0800

    [IPV6] ROUTE: Prefer reachable nexthop only if the caller requests.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5132821..a972a66 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -349,9 +349,7 @@ static int rt6_score_route(struct rt6_in
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
 #endif
 	n = rt6_check_neigh(rt);
-	if (n > 1)
-		m |= 16;
-	else if (!n && strict & RT6_LOOKUP_F_REACHABLE)
+	if (!n && (strict & RT6_LOOKUP_F_REACHABLE))
 		return -1;
 	return m;
 }

---
commit d48ebf246f402bf335f34474e00d77b9492d021a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Nov 6 09:45:45 2006 -0800

    [IPV6] ROUTE: Do not enable router reachability probing in router mode.
    
    RFC4191 explicitly states that the procedures are applicable to
    hosts only.  We should not have changed behavior of routers.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a972a66..b39ae99 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -380,10 +380,11 @@ static struct rt6_info *rt6_select(struc
 			continue;
 
 		if (m > mpri) {
-			rt6_probe(match);
+			if (strict & RT6_LOOKUP_F_REACHABLE)
+				rt6_probe(match);
 			match = rt;
 			mpri = m;
-		} else {
+		} else if (strict & RT6_LOOKUP_F_REACHABLE) {
 			rt6_probe(rt);
 		}
 	}
@@ -636,7 +637,7 @@ static struct rt6_info *ip6_pol_route_in
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = RT6_LOOKUP_F_REACHABLE;
+	int reachable = ipv6_devconf.forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 
@@ -733,7 +734,7 @@ static struct rt6_info *ip6_pol_route_ou
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = RT6_LOOKUP_F_REACHABLE;
+	int reachable = ipv6_devconf.forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 

---
commit 6d43de372a2865a723dcb2b6136b28041dc19314
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Mon Nov 6 10:06:22 2006 -0800

    [IPV6] IP6TUNNEL: Delete all tunnel device when unloading module.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 84d7ebd..c8d4160 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1149,6 +1149,20 @@ fail:
 	return err;
 }
 
+static void __exit ip6ip6_destroy_tunnels(void)
+{
+	int h;
+	struct ip6_tnl *t;
+
+	for (h = 0; h < HASH_SIZE; h++) {
+		while ((t = tnls_r_l[h]) != NULL)
+			unregister_netdevice(t->dev);
+	}
+
+	t = tnls_wc[0];
+	unregister_netdevice(t->dev);
+}
+
 /**
  * ip6_tunnel_cleanup - free resources and unregister protocol
  **/
@@ -1158,7 +1172,9 @@ static void __exit ip6_tunnel_cleanup(vo
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler))
 		printk(KERN_INFO "ip6ip6 close: can't deregister tunnel\n");
 
-	unregister_netdev(ip6ip6_fb_tnl_dev);
+	rtnl_lock();
+	ip6ip6_destroy_tunnels();
+	rtnl_unlock();
 }
 
 module_init(ip6_tunnel_init);

---
commit 64575e617ce5d87858f08aa019703d66ebe403b8
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Mon Nov 6 10:06:23 2006 -0800

    [IPV6] IP6TUNNEL: Add missing nf_reset() on input path.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c8d4160..b9f4029 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -542,6 +542,7 @@ ip6ip6_rcv(struct sk_buff *skb)
 		skb->dev = t->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
+		nf_reset(skb);
 		if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
 			ipv6_copy_dscp(ipv6h, skb->nh.ipv6h);
 		ip6ip6_ecn_decapsulate(ipv6h, skb);

---

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
