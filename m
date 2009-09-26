From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH] Revert "sit: stateless autoconf for isatap"
Date: Sat, 26 Sep 2009 17:03:13 +0200
Message-ID: <1253977393-7757-1-git-send-email-contact@saschahlusiak.de>
Cc: fred.l.templin@boeing.org,
	Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:64098 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbZIZPEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 11:04:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 645069299a1c7358cf7330afe293f07552f11a5d.

While the code does not actually break anything, it does not completely follow
RFC5214 yet. After talking back with Fred L. Templin, I agree that completing the
ISATAP specific RS/RA code, would pollute the kernel a lot with code that is better
implemented in userspace.

The kernel should not send RS packages for ISATAP at all.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
Acked-by: Fred L. Templin <Fred.L.Templin@boeing.com>
---
 include/linux/if_tunnel.h |    2 +-
 include/net/ipip.h        |    7 -----
 net/ipv6/ndisc.c          |    1 -
 net/ipv6/sit.c            |   58 ---------------------------------------------
 4 files changed, 1 insertions(+), 67 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5eb9b0f..5a9aae4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -44,7 +44,7 @@ struct ip_tunnel_prl {
 	__u16			flags;
 	__u16			__reserved;
 	__u32			datalen;
-	__u32			rs_delay;
+	__u32			__reserved2;
 	/* data follows */
 };
 
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 76e3ea6..87acf8f 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -27,18 +27,11 @@ struct ip_tunnel
 	unsigned int			prl_count;	/* # of entries in PRL */
 };
 
-/* ISATAP: default interval between RS in secondy */
-#define IPTUNNEL_RS_DEFAULT_DELAY	(900)
-
 struct ip_tunnel_prl_entry
 {
 	struct ip_tunnel_prl_entry	*next;
 	__be32				addr;
 	u16				flags;
-	unsigned long			rs_delay;
-	struct timer_list		rs_timer;
-	struct ip_tunnel		*tunnel;
-	spinlock_t			lock;
 };
 
 #define IPTUNNEL_XMIT() do {						\
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 498b9b0..f74e4e2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -658,7 +658,6 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		     &icmp6h, NULL,
 		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
-EXPORT_SYMBOL(ndisc_send_rs);
 
 
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index fcb5396..d65e0c4 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -15,7 +15,6 @@
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
  * Fred Templin <fred.l.templin@boeing.com>:	isatap support
- * Sascha Hlusiak <mail@saschahlusiak.de>:	stateless autoconf for isatap
  */
 
 #include <linux/module.h>
@@ -223,44 +222,6 @@ failed:
 	return NULL;
 }
 
-static void ipip6_tunnel_rs_timer(unsigned long data)
-{
-	struct ip_tunnel_prl_entry *p = (struct ip_tunnel_prl_entry *) data;
-	struct inet6_dev *ifp;
-	struct inet6_ifaddr *addr;
-
-	spin_lock(&p->lock);
-	ifp = __in6_dev_get(p->tunnel->dev);
-
-	read_lock_bh(&ifp->lock);
-	for (addr = ifp->addr_list; addr; addr = addr->if_next) {
-		struct in6_addr rtr;
-
-		if (!(ipv6_addr_type(&addr->addr) & IPV6_ADDR_LINKLOCAL))
-			continue;
-
-		/* Send RS to guessed linklocal address of router
-		 *
-		 * Better: send to ff02::2 encapsuled in unicast directly
-		 * to router-v4 instead of guessing the v6 address.
-		 *
-		 * Cisco/Windows seem to not set the u/l bit correctly,
-		 * so we won't guess right.
-		 */
-		ipv6_addr_set(&rtr,  htonl(0xFE800000), 0, 0, 0);
-		if (!__ipv6_isatap_ifid(rtr.s6_addr + 8,
-					p->addr)) {
-			ndisc_send_rs(p->tunnel->dev, &addr->addr, &rtr);
-		}
-	}
-	read_unlock_bh(&ifp->lock);
-
-	mod_timer(&p->rs_timer, jiffies + HZ * p->rs_delay);
-	spin_unlock(&p->lock);
-
-	return;
-}
-
 static struct ip_tunnel_prl_entry *
 __ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 {
@@ -319,7 +280,6 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 			continue;
 		kp[c].addr = prl->addr;
 		kp[c].flags = prl->flags;
-		kp[c].rs_delay = prl->rs_delay;
 		c++;
 		if (kprl.addr != htonl(INADDR_ANY))
 			break;
@@ -369,23 +329,11 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 	}
 
 	p->next = t->prl;
-	p->tunnel = t;
 	t->prl = p;
 	t->prl_count++;
-
-	spin_lock_init(&p->lock);
-	setup_timer(&p->rs_timer, ipip6_tunnel_rs_timer, (unsigned long) p);
 update:
 	p->addr = a->addr;
 	p->flags = a->flags;
-	p->rs_delay = a->rs_delay;
-	if (p->rs_delay == 0)
-		p->rs_delay = IPTUNNEL_RS_DEFAULT_DELAY;
-	spin_lock(&p->lock);
-	del_timer(&p->rs_timer);
-	if (p->flags & PRL_DEFAULT)
-		mod_timer(&p->rs_timer, jiffies + 1);
-	spin_unlock(&p->lock);
 out:
 	write_unlock(&ipip6_lock);
 	return err;
@@ -404,9 +352,6 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 			if ((*p)->addr == a->addr) {
 				x = *p;
 				*p = x->next;
-				spin_lock(&x->lock);
-				del_timer(&x->rs_timer);
-				spin_unlock(&x->lock);
 				kfree(x);
 				t->prl_count--;
 				goto out;
@@ -417,9 +362,6 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 		while (t->prl) {
 			x = t->prl;
 			t->prl = t->prl->next;
-			spin_lock(&x->lock);
-			del_timer(&x->rs_timer);
-			spin_unlock(&x->lock);
 			kfree(x);
 			t->prl_count--;
 		}
-- 
1.6.5.rc1

