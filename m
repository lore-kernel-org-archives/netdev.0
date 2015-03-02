From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 13/15] arp: Kill arp_find
Date: Mon, 02 Mar 2015 00:12:05 -0600
Message-ID: <87385o6i8a.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37834 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbCBGPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 01:15:37 -0500
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are no more callers so kill this function.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/arp.h |  1 -
 net/ipv4/arp.c    | 65 -------------------------------------------------------
 2 files changed, 66 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 73c49864076b..21ee1860abbc 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -47,7 +47,6 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32
 }
 
 void arp_init(void);
-int arp_find(unsigned char *haddr, struct sk_buff *skb);
 int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
 void arp_send(int type, int ptype, __be32 dest_ip,
 	      struct net_device *dev, __be32 src_ip,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 2557cf9a4648..bca5b9d9b442 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -396,71 +396,6 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	return flag;
 }
 
-/* OBSOLETE FUNCTIONS */
-
-/*
- *	Find an arp mapping in the cache. If not found, post a request.
- *
- *	It is very UGLY routine: it DOES NOT use skb->dst->neighbour,
- *	even if it exists. It is supposed that skb->dev was mangled
- *	by a virtual device (eql, shaper). Nobody but broken devices
- *	is allowed to use this function, it is scheduled to be removed. --ANK
- */
-
-static int arp_set_predefined(int addr_hint, unsigned char *haddr,
-			      __be32 paddr, struct net_device *dev)
-{
-	switch (addr_hint) {
-	case RTN_LOCAL:
-		pr_debug("arp called for own IP address\n");
-		memcpy(haddr, dev->dev_addr, dev->addr_len);
-		return 1;
-	case RTN_MULTICAST:
-		arp_mc_map(paddr, haddr, dev, 1);
-		return 1;
-	case RTN_BROADCAST:
-		memcpy(haddr, dev->broadcast, dev->addr_len);
-		return 1;
-	}
-	return 0;
-}
-
-
-int arp_find(unsigned char *haddr, struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	__be32 paddr;
-	struct neighbour *n;
-
-	if (!skb_dst(skb)) {
-		pr_debug("arp_find is called with dst==NULL\n");
-		kfree_skb(skb);
-		return 1;
-	}
-
-	paddr = rt_nexthop(skb_rtable(skb), ip_hdr(skb)->daddr);
-	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr,
-			       paddr, dev))
-		return 0;
-
-	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
-
-	if (n) {
-		n->used = jiffies;
-		if (n->nud_state & NUD_VALID || neigh_event_send(n, skb) == 0) {
-			neigh_ha_snapshot(haddr, n, dev);
-			neigh_release(n);
-			return 0;
-		}
-		neigh_release(n);
-	} else
-		kfree_skb(skb);
-	return 1;
-}
-EXPORT_SYMBOL(arp_find);
-
-/* END OF OBSOLETE FUNCTIONS */
-
 /*
  * Check if we can use proxy ARP for this path
  */
-- 
2.2.1
