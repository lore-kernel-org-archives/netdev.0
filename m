From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] net: arp: code cleanup
Date: Thu,  2 Sep 2010 21:56:51 +0800
Message-ID: <1283435811-8875-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:54104 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0IBN5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 09:57:08 -0400
Received: by pvg2 with SMTP id 2so110241pvg.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 06:57:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean the code up according to Documentation/CodingStyle.

Don't initialize the variable dont_send in arp_process().

Remove the temporary varialbe flags in arp_state_to_flags().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v3: don't replace printk(KERN_DEBUG...) with pr_debug(...).
v2: remove the comment changes.
 net/ipv4/arp.c |  226 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 123 insertions(+), 103 deletions(-)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96c1955..dcfe7e9 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -55,7 +55,7 @@
  *		Stuart Cheshire	:	Metricom and grat arp fixes
  *					*** FOR 2.1 clean this up ***
  *		Lawrence V. Stefani: (08/12/96) Added FDDI support.
- *		Alan Cox 	:	Took the AP1000 nasty FDDI hack and
+ *		Alan Cox	:	Took the AP1000 nasty FDDI hack and
  *					folded into the mainstream FDDI code.
  *					Ack spit, Linus how did you allow that
  *					one in...
@@ -120,7 +120,7 @@ EXPORT_SYMBOL(clip_tbl_hook);
 #endif
 
 #include <asm/system.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include <linux/netfilter_arp.h>
 
@@ -173,32 +173,32 @@ const struct neigh_ops arp_broken_ops = {
 EXPORT_SYMBOL(arp_broken_ops);
 
 struct neigh_table arp_tbl = {
-	.family =	AF_INET,
-	.entry_size =	sizeof(struct neighbour) + 4,
-	.key_len =	4,
-	.hash =		arp_hash,
-	.constructor =	arp_constructor,
-	.proxy_redo =	parp_redo,
-	.id =		"arp_cache",
-	.parms = {
-		.tbl =			&arp_tbl,
-		.base_reachable_time =	30 * HZ,
-		.retrans_time =	1 * HZ,
-		.gc_staletime =	60 * HZ,
-		.reachable_time =		30 * HZ,
-		.delay_probe_time =	5 * HZ,
-		.queue_len =		3,
-		.ucast_probes =	3,
-		.mcast_probes =	3,
-		.anycast_delay =	1 * HZ,
-		.proxy_delay =		(8 * HZ) / 10,
-		.proxy_qlen =		64,
-		.locktime =		1 * HZ,
+	.family		= AF_INET,
+	.entry_size	= sizeof(struct neighbour) + 4,
+	.key_len	= 4,
+	.hash		= arp_hash,
+	.constructor	= arp_constructor,
+	.proxy_redo	= parp_redo,
+	.id		= "arp_cache",
+	.parms		= {
+		.tbl			= &arp_tbl,
+		.base_reachable_time	= 30 * HZ,
+		.retrans_time		= 1 * HZ,
+		.gc_staletime		= 60 * HZ,
+		.reachable_time		= 30 * HZ,
+		.delay_probe_time	= 5 * HZ,
+		.queue_len		= 3,
+		.ucast_probes		= 3,
+		.mcast_probes		= 3,
+		.anycast_delay		= 1 * HZ,
+		.proxy_delay		= (8 * HZ) / 10,
+		.proxy_qlen		= 64,
+		.locktime		= 1 * HZ,
 	},
-	.gc_interval =	30 * HZ,
-	.gc_thresh1 =	128,
-	.gc_thresh2 =	512,
-	.gc_thresh3 =	1024,
+	.gc_interval	= 30 * HZ,
+	.gc_thresh1	= 128,
+	.gc_thresh2	= 512,
+	.gc_thresh3	= 1024,
 };
 EXPORT_SYMBOL(arp_tbl);
 
@@ -233,7 +233,7 @@ static u32 arp_hash(const void *pkey, const struct net_device *dev)
 
 static int arp_constructor(struct neighbour *neigh)
 {
-	__be32 addr = *(__be32*)neigh->primary_key;
+	__be32 addr = *(__be32 *)neigh->primary_key;
 	struct net_device *dev = neigh->dev;
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
@@ -296,16 +296,19 @@ static int arp_constructor(struct neighbour *neigh)
 			neigh->ops = &arp_broken_ops;
 			neigh->output = neigh->ops->output;
 			return 0;
+#else
+			break;
 #endif
-		;}
+		}
 #endif
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+		} else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
-		} else if (neigh->type == RTN_BROADCAST || dev->flags&IFF_POINTOPOINT) {
+		} else if (neigh->type == RTN_BROADCAST ||
+			   (dev->flags & IFF_POINTOPOINT)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
@@ -315,7 +318,7 @@ static int arp_constructor(struct neighbour *neigh)
 		else
 			neigh->ops = &arp_generic_ops;
 
-		if (neigh->nud_state&NUD_VALID)
+		if (neigh->nud_state & NUD_VALID)
 			neigh->output = neigh->ops->connected_output;
 		else
 			neigh->output = neigh->ops->output;
@@ -334,7 +337,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	__be32 saddr = 0;
 	u8  *dst_ha = NULL;
 	struct net_device *dev = neigh->dev;
-	__be32 target = *(__be32*)neigh->primary_key;
+	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 	struct in_device *in_dev;
 
@@ -347,7 +350,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
 	case 0:		/* By default announce any local IP */
-		if (skb && inet_addr_type(dev_net(dev), ip_hdr(skb)->saddr) == RTN_LOCAL)
+		if (skb && inet_addr_type(dev_net(dev),
+					  ip_hdr(skb)->saddr) == RTN_LOCAL)
 			saddr = ip_hdr(skb)->saddr;
 		break;
 	case 1:		/* Restrict announcements of saddr in same subnet */
@@ -369,16 +373,21 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	if (!saddr)
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
-	if ((probes -= neigh->parms->ucast_probes) < 0) {
-		if (!(neigh->nud_state&NUD_VALID))
-			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
+	probes -= neigh->parms->ucast_probes;
+	if (probes < 0) {
+		if (!(neigh->nud_state & NUD_VALID))
+			printk(KERN_DEBUG
+			       "trying to ucast probe in NUD_INVALID\n");
 		dst_ha = neigh->ha;
 		read_lock_bh(&neigh->lock);
-	} else if ((probes -= neigh->parms->app_probes) < 0) {
+	} else {
+		probes -= neigh->parms->app_probes;
+		if (probes < 0) {
 #ifdef CONFIG_ARPD
-		neigh_app_ns(neigh);
+			neigh_app_ns(neigh);
 #endif
-		return;
+			return;
+		}
 	}
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
@@ -451,7 +460,8 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
  *	is allowed to use this function, it is scheduled to be removed. --ANK
  */
 
-static int arp_set_predefined(int addr_hint, unsigned char * haddr, __be32 paddr, struct net_device * dev)
+static int arp_set_predefined(int addr_hint, unsigned char *haddr,
+			      __be32 paddr, struct net_device *dev)
 {
 	switch (addr_hint) {
 	case RTN_LOCAL:
@@ -483,7 +493,8 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 
 	paddr = skb_rtable(skb)->rt_gateway;
 
-	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr, paddr, dev))
+	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr,
+			       paddr, dev))
 		return 0;
 
 	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
@@ -515,13 +526,14 @@ int arp_bind_neighbour(struct dst_entry *dst)
 		return -EINVAL;
 	if (n == NULL) {
 		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
-		if (dev->flags&(IFF_LOOPBACK|IFF_POINTOPOINT))
+		if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
 			nexthop = 0;
 		n = __neigh_lookup_errno(
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-		    dev->type == ARPHRD_ATM ? clip_tbl_hook :
+					 dev->type == ARPHRD_ATM ?
+					 clip_tbl_hook :
 #endif
-		    &arp_tbl, &nexthop, dev);
+					 &arp_tbl, &nexthop, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 		dst->neighbour = n;
@@ -543,8 +555,8 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 
 	if (!IN_DEV_PROXY_ARP(in_dev))
 		return 0;
-
-	if ((imi = IN_DEV_MEDIUM_ID(in_dev)) == 0)
+	imi = IN_DEV_MEDIUM_ID(in_dev);
+	if (imi == 0)
 		return 1;
 	if (imi == -1)
 		return 0;
@@ -685,7 +697,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp->ar_pln = 4;
 	arp->ar_op = htons(type);
 
-	arp_ptr=(unsigned char *)(arp+1);
+	arp_ptr = (unsigned char *)(arp + 1);
 
 	memcpy(arp_ptr, src_hw, dev->addr_len);
 	arp_ptr += dev->addr_len;
@@ -735,9 +747,8 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 
 	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
 			 dest_hw, src_hw, target_hw);
-	if (skb == NULL) {
+	if (skb == NULL)
 		return;
-	}
 
 	arp_xmit(skb);
 }
@@ -815,7 +826,7 @@ static int arp_process(struct sk_buff *skb)
 /*
  *	Extract fields
  */
-	arp_ptr= (unsigned char *)(arp+1);
+	arp_ptr = (unsigned char *)(arp + 1);
 	sha	= arp_ptr;
 	arp_ptr += dev->addr_len;
 	memcpy(&sip, arp_ptr, 4);
@@ -869,16 +880,17 @@ static int arp_process(struct sk_buff *skb)
 		addr_type = rt->rt_type;
 
 		if (addr_type == RTN_LOCAL) {
-			int dont_send = 0;
+			int dont_send;
 
-			if (!dont_send)
-				dont_send |= arp_ignore(in_dev,sip,tip);
+			dont_send = arp_ignore(in_dev, sip, tip);
 			if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-				dont_send |= arp_filter(sip,tip,dev);
+				dont_send |= arp_filter(sip, tip, dev);
 			if (!dont_send) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
+						 dev, tip, sha, dev->dev_addr,
+						 sha);
 					neigh_release(n);
 				}
 			}
@@ -887,8 +899,7 @@ static int arp_process(struct sk_buff *skb)
 			if (addr_type == RTN_UNICAST  &&
 			    (arp_fwd_proxy(in_dev, dev, rt) ||
 			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
-			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))
-			{
+			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0))) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
@@ -896,9 +907,12 @@ static int arp_process(struct sk_buff *skb)
 				if (NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED ||
 				    skb->pkt_type == PACKET_HOST ||
 				    in_dev->arp_parms->proxy_delay == 0) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
+						 dev, tip, sha, dev->dev_addr,
+						 sha);
 				} else {
-					pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
+					pneigh_enqueue(&arp_tbl,
+						       in_dev->arp_parms, skb);
 					return 0;
 				}
 				goto out;
@@ -939,7 +953,8 @@ static int arp_process(struct sk_buff *skb)
 		if (arp->ar_op != htons(ARPOP_REPLY) ||
 		    skb->pkt_type != PACKET_HOST)
 			state = NUD_STALE;
-		neigh_update(n, sha, state, override ? NEIGH_UPDATE_F_OVERRIDE : 0);
+		neigh_update(n, sha, state,
+			     override ? NEIGH_UPDATE_F_OVERRIDE : 0);
 		neigh_release(n);
 	}
 
@@ -975,7 +990,8 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 	    arp->ar_pln != 4)
 		goto freeskb;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (skb == NULL)
 		goto out_of_mem;
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
@@ -1019,7 +1035,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 		return -EINVAL;
 	if (!dev && (r->arp_flags & ATF_COM)) {
 		dev = dev_getbyhwaddr(net, r->arp_ha.sa_family,
-				r->arp_ha.sa_data);
+				      r->arp_ha.sa_data);
 		if (!dev)
 			return -ENODEV;
 	}
@@ -1033,7 +1049,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 }
 
 static int arp_req_set(struct net *net, struct arpreq *r,
-		struct net_device * dev)
+		       struct net_device *dev)
 {
 	__be32 ip;
 	struct neighbour *neigh;
@@ -1046,10 +1062,11 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
-		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
-							 .tos = RTO_ONLINK } } };
-		struct rtable * rt;
-		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
+		struct flowi fl = { .nl_u.ip4_u = { .daddr = ip,
+						    .tos = RTO_ONLINK } };
+		struct rtable *rt;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err != 0)
 			return err;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
@@ -1083,9 +1100,9 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 		unsigned state = NUD_STALE;
 		if (r->arp_flags & ATF_PERM)
 			state = NUD_PERMANENT;
-		err = neigh_update(neigh, (r->arp_flags&ATF_COM) ?
+		err = neigh_update(neigh, (r->arp_flags & ATF_COM) ?
 				   r->arp_ha.sa_data : NULL, state,
-				   NEIGH_UPDATE_F_OVERRIDE|
+				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
 	}
@@ -1094,12 +1111,12 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 
 static unsigned arp_state_to_flags(struct neighbour *neigh)
 {
-	unsigned flags = 0;
 	if (neigh->nud_state&NUD_PERMANENT)
-		flags = ATF_PERM|ATF_COM;
+		return ATF_PERM | ATF_COM;
 	else if (neigh->nud_state&NUD_VALID)
-		flags = ATF_COM;
-	return flags;
+		return ATF_COM;
+	else
+		return 0;
 }
 
 /*
@@ -1142,7 +1159,7 @@ static int arp_req_delete_public(struct net *net, struct arpreq *r,
 }
 
 static int arp_req_delete(struct net *net, struct arpreq *r,
-		struct net_device * dev)
+			  struct net_device *dev)
 {
 	int err;
 	__be32 ip;
@@ -1153,10 +1170,11 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (dev == NULL) {
-		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
-							 .tos = RTO_ONLINK } } };
-		struct rtable * rt;
-		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
+		struct flowi fl = { .nl_u.ip4_u = { .daddr = ip,
+						    .tos = RTO_ONLINK } };
+		struct rtable *rt;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err != 0)
 			return err;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
@@ -1166,7 +1184,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 	err = -ENXIO;
 	neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	if (neigh) {
-		if (neigh->nud_state&~NUD_NOARP)
+		if (neigh->nud_state & ~NUD_NOARP)
 			err = neigh_update(neigh, NULL, NUD_FAILED,
 					   NEIGH_UPDATE_F_OVERRIDE|
 					   NEIGH_UPDATE_F_ADMIN);
@@ -1186,24 +1204,24 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	struct net_device *dev = NULL;
 
 	switch (cmd) {
-		case SIOCDARP:
-		case SIOCSARP:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-		case SIOCGARP:
-			err = copy_from_user(&r, arg, sizeof(struct arpreq));
-			if (err)
-				return -EFAULT;
-			break;
-		default:
-			return -EINVAL;
+	case SIOCDARP:
+	case SIOCSARP:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	case SIOCGARP:
+		err = copy_from_user(&r, arg, sizeof(struct arpreq));
+		if (err)
+			return -EFAULT;
+		break;
+	default:
+		return -EINVAL;
 	}
 
 	if (r.arp_pa.sa_family != AF_INET)
 		return -EPFNOSUPPORT;
 
 	if (!(r.arp_flags & ATF_PUBL) &&
-	    (r.arp_flags & (ATF_NETMASK|ATF_DONTPUB)))
+	    (r.arp_flags & (ATF_NETMASK | ATF_DONTPUB)))
 		return -EINVAL;
 	if (!(r.arp_flags & ATF_NETMASK))
 		((struct sockaddr_in *)&r.arp_netmask)->sin_addr.s_addr =
@@ -1211,7 +1229,8 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	rtnl_lock();
 	if (r.arp_dev[0]) {
 		err = -ENODEV;
-		if ((dev = __dev_get_by_name(net, r.arp_dev)) == NULL)
+		dev = __dev_get_by_name(net, r.arp_dev);
+		if (dev == NULL)
 			goto out;
 
 		/* Mmmm... It is wrong... ARPHRD_NETROM==0 */
@@ -1243,7 +1262,8 @@ out:
 	return err;
 }
 
-static int arp_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+static int arp_netdev_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
 {
 	struct net_device *dev = ptr;
 
@@ -1311,12 +1331,13 @@ static char *ax2asc2(ax25_address *a, char *buf)
 	for (n = 0, s = buf; n < 6; n++) {
 		c = (a->ax25_call[n] >> 1) & 0x7F;
 
-		if (c != ' ') *s++ = c;
+		if (c != ' ')
+			*s++ = c;
 	}
 
 	*s++ = '-';
-
-	if ((n = ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
+	n = (a->ax25_call[6] >> 1) & 0x0F;
+	if (n > 9) {
 		*s++ = '1';
 		n -= 10;
 	}
@@ -1325,10 +1346,9 @@ static char *ax2asc2(ax25_address *a, char *buf)
 	*s++ = '\0';
 
 	if (*buf == '\0' || *buf == '-')
-	   return "*";
+		return "*";
 
 	return buf;
-
 }
 #endif /* CONFIG_AX25 */
 
@@ -1408,10 +1428,10 @@ static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
 /* ------------------------------------------------------------------------ */
 
 static const struct seq_operations arp_seq_ops = {
-	.start  = arp_seq_start,
-	.next   = neigh_seq_next,
-	.stop   = neigh_seq_stop,
-	.show   = arp_seq_show,
+	.start	= arp_seq_start,
+	.next	= neigh_seq_next,
+	.stop	= neigh_seq_stop,
+	.show	= arp_seq_show,
 };
 
 static int arp_seq_open(struct inode *inode, struct file *file)
