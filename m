From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/2] IPV6: use ipv6_addr_is_multicast()
Date: Wed, 28 Jan 2004 16:30:47 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128.163047.87255505.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use simple ipv6_addr_is_multicast()
where ipv6_addr_type() is called to check for multicast only.

Thanks.

===== net/ipv6/exthdrs.c 1.14 vs edited =====
--- 1.14/net/ipv6/exthdrs.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/exthdrs.c	Wed Jan 28 16:08:02 2004
@@ -218,7 +218,6 @@
 	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
 	struct in6_addr *addr;
 	struct in6_addr daddr;
-	int addr_type;
 	int n, i;
 
 	struct ipv6_rt_hdr *hdr;
@@ -233,7 +232,7 @@
 
 	hdr = (struct ipv6_rt_hdr *) skb->h.raw;
 
-	if ((ipv6_addr_type(&skb->nh.ipv6h->daddr)&IPV6_ADDR_MULTICAST) ||
+	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
 		kfree_skb(skb);
 		return -1;
@@ -293,9 +292,7 @@
 	addr = rthdr->addr;
 	addr += i - 1;
 
-	addr_type = ipv6_addr_type(addr);
-
-	if (addr_type&IPV6_ADDR_MULTICAST) {
+	if (ipv6_addr_is_multicast(addr)) {
 		kfree_skb(skb);
 		return -1;
 	}
===== net/ipv6/anycast.c 1.10 vs edited =====
--- 1.10/net/ipv6/anycast.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/anycast.c	Wed Jan 28 16:08:02 2004
@@ -111,7 +111,7 @@
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
-	if (ipv6_addr_type(addr) & IPV6_ADDR_MULTICAST)
+	if (ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 	if (ipv6_chk_addr(addr, NULL, 0))
 		return -EINVAL;
===== net/ipv6/raw.c 1.47 vs edited =====
--- 1.47/net/ipv6/raw.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/raw.c	Wed Jan 28 16:08:02 2004
@@ -81,7 +81,7 @@
 			     struct in6_addr *loc_addr, struct in6_addr *rmt_addr)
 {
 	struct hlist_node *node;
-	int addr_type = ipv6_addr_type(loc_addr);
+	int is_multicast = ipv6_addr_is_multicast(loc_addr);
 
 	sk_for_each_from(sk, node)
 		if (inet_sk(sk)->num == num) {
@@ -94,7 +94,7 @@
 			if (!ipv6_addr_any(&np->rcv_saddr)) {
 				if (!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
 					goto found;
-				if ((addr_type & IPV6_ADDR_MULTICAST) &&
+				if (is_multicast &&
 				    inet6_mc_check(sk, loc_addr, rmt_addr))
 					goto found;
 				continue;
===== net/ipv6/mcast.c 1.49 vs edited =====
--- 1.49/net/ipv6/mcast.c	Sun Jan 25 02:54:51 2004
+++ edited/net/ipv6/mcast.c	Wed Jan 28 16:08:02 2004
@@ -175,7 +175,7 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int err;
 
-	if (!(ipv6_addr_type(addr) & IPV6_ADDR_MULTICAST))
+	if (!ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 
 	mc_lst = sock_kmalloc(sk, sizeof(struct ipv6_mc_socklist), GFP_KERNEL);
@@ -348,7 +348,7 @@
 	source = &((struct sockaddr_in6 *)&pgsr->gsr_source)->sin6_addr;
 	group = &((struct sockaddr_in6 *)&pgsr->gsr_group)->sin6_addr;
 
-	if (!(ipv6_addr_type(group) & IPV6_ADDR_MULTICAST))
+	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
 	idev = ip6_mc_find_dev(group, pgsr->gsr_interface);
@@ -457,7 +457,7 @@
 
 	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
 
-	if (!(ipv6_addr_type(group) & IPV6_ADDR_MULTICAST))
+	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 	if (gsf->gf_fmode != MCAST_INCLUDE &&
 	    gsf->gf_fmode != MCAST_EXCLUDE)
@@ -529,7 +529,7 @@
 
 	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
 
-	if (!(ipv6_addr_type(group) & IPV6_ADDR_MULTICAST))
+	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
 	idev = ip6_mc_find_dev(group, gsf->gf_interface);
===== net/ipv6/udp.c 1.57 vs edited =====
--- 1.57/net/ipv6/udp.c	Fri Jan  9 18:50:23 2004
+++ edited/net/ipv6/udp.c	Wed Jan 28 16:08:02 2004
@@ -658,7 +658,7 @@
 	/* 
 	 *	Multicast receive code 
 	 */
-	if (ipv6_addr_type(daddr) & IPV6_ADDR_MULTICAST) {
+	if (ipv6_addr_is_multicast(daddr)) {
 		udpv6_mcast_deliver(uh, saddr, daddr, skb);
 		return 0;
 	}
===== net/ipv6/ndisc.c 1.64 vs edited =====
--- 1.64/net/ipv6/ndisc.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/ndisc.c	Wed Jan 28 16:08:56 2004
@@ -277,25 +277,21 @@
 	struct in6_addr *addr = (struct in6_addr*)&neigh->primary_key;
 	struct net_device *dev = neigh->dev;
 	struct inet6_dev *in6_dev = in6_dev_get(dev);
-	int addr_type;
+	int is_multicast = ipv6_addr_is_multicast(addr);
 
 	if (in6_dev == NULL)
 		return -EINVAL;
 
-	addr_type = ipv6_addr_type(addr);
 	if (in6_dev->nd_parms)
 		neigh->parms = in6_dev->nd_parms;
 
-	if (addr_type&IPV6_ADDR_MULTICAST)
-		neigh->type = RTN_MULTICAST;
-	else
-		neigh->type = RTN_UNICAST;
+	neigh->type = is_multicast ? RTN_MULTICAST : RTN_UNICAST;
 	if (dev->hard_header == NULL) {
 		neigh->nud_state = NUD_NOARP;
 		neigh->ops = &ndisc_direct_ops;
 		neigh->output = neigh->ops->queue_xmit;
 	} else {
-		if (addr_type&IPV6_ADDR_MULTICAST) {
+		if (is_multicast) {
 			neigh->nud_state = NUD_NOARP;
 			ndisc_mc_map(addr, neigh->ha, dev, 1);
 		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
@@ -355,7 +351,7 @@
 	unsigned char *h_dest = NULL;
 
 	if (dev->hard_header) {
-		if (ipv6_addr_type(daddr) & IPV6_ADDR_MULTICAST) {
+		if (ipv6_addr_is_multicast(daddr)) {
 			ndisc_mc_map(daddr, ha, dev, 1);
 			h_dest = ha;
 		} else if (neigh) {
@@ -711,7 +707,7 @@
 	struct neighbour *neigh;
 	int addr_type = ipv6_addr_type(saddr);
 
-	if (ipv6_addr_type(&msg->target)&IPV6_ADDR_MULTICAST) {
+	if (ipv6_addr_is_multicast(&msg->target)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "ICMP NS: target address is multicast\n");
 		return;
@@ -797,9 +793,7 @@
 		}
 
 		if (addr_type & IPV6_ADDR_UNICAST) {
-			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
-
-			if (inc)
+			if (ipv6_addr_is_multicast(daddr))
 				nd_tbl.stats.rcv_probes_mcast++;
 			else
 				nd_tbl.stats.rcv_probes_ucast++;
@@ -841,7 +835,7 @@
 		}
 
 		if (addr_type & IPV6_ADDR_UNICAST) {
-			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
+			int inc = ipv6_addr_is_multicast(daddr);
 			if (inc)  
 				nd_tbl.stats.rcv_probes_mcast++;
 			else
@@ -870,7 +864,7 @@
 		    (addr_type & IPV6_ADDR_UNICAST ||
 		     addr_type == IPV6_ADDR_ANY) &&
 		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
-			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
+			int inc = ipv6_addr_is_multicast(daddr);
 
 			if (skb->stamp.tv_sec == 0 ||
 			    skb->pkt_type == PACKET_HOST ||
@@ -929,13 +923,13 @@
 		return;
 	}
 
-	if (ipv6_addr_type(&msg->target)&IPV6_ADDR_MULTICAST) {
+	if (ipv6_addr_is_multicast(&msg->target)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "NDISC NA: target address is multicast\n");
 		return;
 	}
 
-	if ((ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST) &&
+	if (ipv6_addr_is_multicast(daddr) &&
 	    msg->icmph.icmp6_solicited) {
 		ND_PRINTK0("NDISC: solicited NA is multicasted\n");
 		return;
@@ -1229,7 +1223,7 @@
 	target = (struct in6_addr *) (icmph + 1);
 	dest = target + 1;
 
-	if (ipv6_addr_type(dest) & IPV6_ADDR_MULTICAST) {
+	if (ipv6_addr_is_multicast(dest)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "ICMP redirect for multicast addr\n");
 		return;


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
