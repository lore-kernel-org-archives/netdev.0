From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Convert printks to pr_<level>
Date: Sun, 11 Mar 2012 21:36:11 -0700
Message-ID: <1331526971.13200.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46308 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751346Ab2CLEgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 00:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more current kernel messaging style.

Convert a printk block to print_hex_dump.
Coalesce formats, align arguments.
Use %s, __func__ instead of embedding function names.

Some messages that were prefixed with <foo>_close are
now prefixed with <foo>_fini.  Some ah4 and esp messages
are now not prefixed with "ip ".

The intent of this patch is to later add something like
  #define pr_fmt(fmt) "IPv4: " fmt.
to standardize the output messages.

Text size is trivially reduced. (x86-32 allyesconfig)

$ size net/ipv4/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 887888	  31558	 249696	1169142	 11d6f6	net/ipv4/built-in.o.new
 887934	  31558	 249800	1169292	 11d78c	net/ipv4/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/af_inet.c       |   25 +++++------
 net/ipv4/ah4.c           |   14 +++---
 net/ipv4/esp4.c          |    8 ++--
 net/ipv4/fib_frontend.c  |    6 +-
 net/ipv4/fib_semantics.c |    2 +-
 net/ipv4/fib_trie.c      |    5 +-
 net/ipv4/icmp.c          |   19 +++-----
 net/ipv4/ip_fragment.c   |    3 +-
 net/ipv4/ip_gre.c        |    6 +-
 net/ipv4/ip_input.c      |    4 +-
 net/ipv4/ip_options.c    |    2 +-
 net/ipv4/ipcomp.c        |    8 ++--
 net/ipv4/ipconfig.c      |  110 +++++++++++++++++++++++-----------------------
 net/ipv4/ipip.c          |    4 +-
 net/ipv4/ipmr.c          |    4 +-
 net/ipv4/ping.c          |   18 ++++----
 net/ipv4/raw.c           |    7 +--
 net/ipv4/route.c         |   43 ++++++++----------
 net/ipv4/tcp.c           |    7 +--
 net/ipv4/tcp_cong.c      |    7 +--
 net/ipv4/tcp_input.c     |    8 ++--
 net/ipv4/tcp_ipv4.c      |    8 ++--
 net/ipv4/tunnel4.c       |    8 ++--
 net/ipv4/udplite.c       |    4 +-
 net/ipv4/xfrm4_tunnel.c  |   14 +++---
 25 files changed, 163 insertions(+), 181 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e588a34..b7a9466 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1085,13 +1085,11 @@ out:
 	return;
 
 out_permanent:
-	printk(KERN_ERR "Attempt to override permanent protocol %d.\n",
-	       protocol);
+	pr_err("Attempt to override permanent protocol %d\n", protocol);
 	goto out;
 
 out_illegal:
-	printk(KERN_ERR
-	       "Ignoring attempt to register invalid socket type %d.\n",
+	pr_err("Ignoring attempt to register invalid socket type %d\n",
 	       p->type);
 	goto out;
 }
@@ -1100,8 +1098,7 @@ EXPORT_SYMBOL(inet_register_protosw);
 void inet_unregister_protosw(struct inet_protosw *p)
 {
 	if (INET_PROTOSW_PERMANENT & p->flags) {
-		printk(KERN_ERR
-		       "Attempt to unregister permanent protocol %d.\n",
+		pr_err("Attempt to unregister permanent protocol %d\n",
 		       p->protocol);
 	} else {
 		spin_lock_bh(&inetsw_lock);
@@ -1150,8 +1147,8 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		return 0;
 
 	if (sysctl_ip_dynaddr > 1) {
-		printk(KERN_INFO "%s(): shifting inet->saddr from %pI4 to %pI4\n",
-		       __func__, &old_saddr, &new_saddr);
+		pr_info("%s(): shifting inet->saddr from %pI4 to %pI4\n",
+			__func__, &old_saddr, &new_saddr);
 	}
 
 	inet->inet_saddr = inet->inet_rcv_saddr = new_saddr;
@@ -1680,14 +1677,14 @@ static int __init inet_init(void)
 	 */
 
 	if (inet_add_protocol(&icmp_protocol, IPPROTO_ICMP) < 0)
-		printk(KERN_CRIT "inet_init: Cannot add ICMP protocol\n");
+		pr_crit("%s: Cannot add ICMP protocol\n", __func__);
 	if (inet_add_protocol(&udp_protocol, IPPROTO_UDP) < 0)
-		printk(KERN_CRIT "inet_init: Cannot add UDP protocol\n");
+		pr_crit("%s: Cannot add UDP protocol\n", __func__);
 	if (inet_add_protocol(&tcp_protocol, IPPROTO_TCP) < 0)
-		printk(KERN_CRIT "inet_init: Cannot add TCP protocol\n");
+		pr_crit("%s: Cannot add TCP protocol\n", __func__);
 #ifdef CONFIG_IP_MULTICAST
 	if (inet_add_protocol(&igmp_protocol, IPPROTO_IGMP) < 0)
-		printk(KERN_CRIT "inet_init: Cannot add IGMP protocol\n");
+		pr_crit("%s: Cannot add IGMP protocol\n", __func__);
 #endif
 
 	/* Register the socket-side information for inet_create. */
@@ -1734,14 +1731,14 @@ static int __init inet_init(void)
 	 */
 #if defined(CONFIG_IP_MROUTE)
 	if (ip_mr_init())
-		printk(KERN_CRIT "inet_init: Cannot init ipv4 mroute\n");
+		pr_crit("%s: Cannot init ipv4 mroute\n", __func__);
 #endif
 	/*
 	 *	Initialise per-cpu ipv4 mibs
 	 */
 
 	if (init_ipv4_mibs())
-		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n");
+		pr_crit("%s: Cannot init ipv4 mibs\n", __func__);
 
 	ipv4_proc_init();
 
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 36d1440..b552466 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -445,9 +445,9 @@ static int ah_init_state(struct xfrm_state *x)
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
 	    crypto_ahash_digestsize(ahash)) {
-		printk(KERN_INFO "AH: %s digestsize %u != %hu\n",
-		       x->aalg->alg_name, crypto_ahash_digestsize(ahash),
-		       aalg_desc->uinfo.auth.icv_fullbits/8);
+		pr_info("AH: %s digestsize %u != %hu\n",
+			x->aalg->alg_name, crypto_ahash_digestsize(ahash),
+			aalg_desc->uinfo.auth.icv_fullbits/8);
 		goto error;
 	}
 
@@ -510,11 +510,11 @@ static const struct net_protocol ah4_protocol = {
 static int __init ah4_init(void)
 {
 	if (xfrm_register_type(&ah_type, AF_INET) < 0) {
-		printk(KERN_INFO "ip ah init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet_add_protocol(&ah4_protocol, IPPROTO_AH) < 0) {
-		printk(KERN_INFO "ip ah init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ah_type, AF_INET);
 		return -EAGAIN;
 	}
@@ -524,9 +524,9 @@ static int __init ah4_init(void)
 static void __exit ah4_fini(void)
 {
 	if (inet_del_protocol(&ah4_protocol, IPPROTO_AH) < 0)
-		printk(KERN_INFO "ip ah close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ah_type, AF_INET) < 0)
-		printk(KERN_INFO "ip ah close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(ah4_init);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index a5b4134..0a86dbe 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -706,11 +706,11 @@ static const struct net_protocol esp4_protocol = {
 static int __init esp4_init(void)
 {
 	if (xfrm_register_type(&esp_type, AF_INET) < 0) {
-		printk(KERN_INFO "ip esp init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet_add_protocol(&esp4_protocol, IPPROTO_ESP) < 0) {
-		printk(KERN_INFO "ip esp init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&esp_type, AF_INET);
 		return -EAGAIN;
 	}
@@ -720,9 +720,9 @@ static int __init esp4_init(void)
 static void __exit esp4_fini(void)
 {
 	if (inet_del_protocol(&esp4_protocol, IPPROTO_ESP) < 0)
-		printk(KERN_INFO "ip esp close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&esp_type, AF_INET) < 0)
-		printk(KERN_INFO "ip esp close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(esp4_init);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 92fc5f6..76e72ba 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -695,7 +695,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, prefix, mask);
 		if (prim == NULL) {
-			printk(KERN_WARNING "fib_add_ifaddr: bug: prim == NULL\n");
+			pr_warn("%s: bug: prim == NULL\n", __func__);
 			return;
 		}
 	}
@@ -749,11 +749,11 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
 		if (prim == NULL) {
-			printk(KERN_WARNING "fib_del_ifaddr: bug: prim == NULL\n");
+			pr_warn("%s: bug: prim == NULL\n", __func__);
 			return;
 		}
 		if (iprim && iprim != prim) {
-			printk(KERN_WARNING "fib_del_ifaddr: bug: iprim != prim\n");
+			pr_warn("%s: bug: iprim != prim\n", __func__);
 			return;
 		}
 	} else if (!ipv4_is_zeronet(any) &&
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 80106d8..a8c5c1d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -154,7 +154,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
-		pr_warning("Freeing alive fib_info %p\n", fi);
+		pr_warn("Freeing alive fib_info %p\n", fi);
 		return;
 	}
 	change_nexthops(fi) {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2b555a5..da9b9cb 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1170,9 +1170,8 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 	}
 
 	if (tp && tp->pos + tp->bits > 32)
-		pr_warning("fib_trie"
-			   " tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
-			   tp, tp->pos, tp->bits, key, plen);
+		pr_warn("fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
+			tp, tp->pos, tp->bits, key, plen);
 
 	/* Rebalance the trie */
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ab188ae..5c7323b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -670,7 +670,7 @@ static void icmp_unreach(struct sk_buff *skb)
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: fragmentation needed and DF set.\n",
+				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: fragmentation needed and DF set\n",
 					       &iph->daddr);
 			} else {
 				info = ip_rt_frag_needed(net, iph,
@@ -681,7 +681,7 @@ static void icmp_unreach(struct sk_buff *skb)
 			}
 			break;
 		case ICMP_SR_FAILED:
-			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: Source Route Failed.\n",
+			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: Source Route Failed\n",
 				       &iph->daddr);
 			break;
 		default:
@@ -713,13 +713,10 @@ static void icmp_unreach(struct sk_buff *skb)
 	if (!net->ipv4.sysctl_icmp_ignore_bogus_error_responses &&
 	    inet_addr_type(net, iph->daddr) == RTN_BROADCAST) {
 		if (net_ratelimit())
-			printk(KERN_WARNING "%pI4 sent an invalid ICMP "
-					    "type %u, code %u "
-					    "error to a broadcast: %pI4 on %s\n",
-			       &ip_hdr(skb)->saddr,
-			       icmph->type, icmph->code,
-			       &iph->daddr,
-			       skb->dev->name);
+			pr_warn("%pI4 sent an invalid ICMP type %u, code %u error to a broadcast: %pI4 on %s\n",
+				&ip_hdr(skb)->saddr,
+				icmph->type, icmph->code,
+				&iph->daddr, skb->dev->name);
 		goto out;
 	}
 
@@ -946,8 +943,8 @@ static void icmp_address_reply(struct sk_buff *skb)
 				break;
 		}
 		if (!ifa && net_ratelimit()) {
-			printk(KERN_INFO "Wrong address mask %pI4 from %s/%pI4\n",
-			       mp, dev->name, &ip_hdr(skb)->saddr);
+			pr_info("Wrong address mask %pI4 from %s/%pI4\n",
+				mp, dev->name, &ip_hdr(skb)->saddr);
 		}
 	}
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1f23a57..b2fd333 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -643,8 +643,7 @@ out_nomem:
 	goto out_fail;
 out_oversize:
 	if (net_ratelimit())
-		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
-			&qp->saddr);
+		pr_info("Oversized IP packet from %pI4\n", &qp->saddr);
 out_fail:
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	return err;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6ef66af..185e0a7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1716,7 +1716,7 @@ static int __init ipgre_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
+	pr_info("GRE over IPv4 tunneling driver\n");
 
 	err = register_pernet_device(&ipgre_net_ops);
 	if (err < 0)
@@ -1724,7 +1724,7 @@ static int __init ipgre_init(void)
 
 	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	if (err < 0) {
-		printk(KERN_INFO "ipgre init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		goto add_proto_failed;
 	}
 
@@ -1753,7 +1753,7 @@ static void __exit ipgre_fini(void)
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
-		printk(KERN_INFO "ipgre close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	unregister_pernet_device(&ipgre_net_ops);
 }
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index bdaa2c5..de8e9be 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -299,8 +299,8 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 			if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
 				if (IN_DEV_LOG_MARTIANS(in_dev) &&
 				    net_ratelimit())
-					printk(KERN_INFO "source route option %pI4 -> %pI4\n",
-					       &iph->saddr, &iph->daddr);
+					pr_info("source route option %pI4 -> %pI4\n",
+						&iph->saddr, &iph->daddr);
 				goto drop;
 			}
 		}
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 42dd1a9..e25ee7c 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -577,7 +577,7 @@ void ip_forward_options(struct sk_buff *skb)
 			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
-			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
+			pr_crit("%s(): Argh! Destination lost!\n", __func__);
 		if (opt->ts_needaddr) {
 			optptr = raw + opt->ts;
 			ip_rt_get_source(&optptr[optptr[2]-9], skb, rt);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index c857f6f..63b64c4 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -156,11 +156,11 @@ static const struct net_protocol ipcomp4_protocol = {
 static int __init ipcomp4_init(void)
 {
 	if (xfrm_register_type(&ipcomp_type, AF_INET) < 0) {
-		printk(KERN_INFO "ipcomp init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet_add_protocol(&ipcomp4_protocol, IPPROTO_COMP) < 0) {
-		printk(KERN_INFO "ipcomp init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ipcomp_type, AF_INET);
 		return -EAGAIN;
 	}
@@ -170,9 +170,9 @@ static int __init ipcomp4_init(void)
 static void __exit ipcomp4_fini(void)
 {
 	if (inet_del_protocol(&ipcomp4_protocol, IPPROTO_COMP) < 0)
-		printk(KERN_INFO "ip ipcomp close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ipcomp_type, AF_INET) < 0)
-		printk(KERN_INFO "ip ipcomp close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(ipcomp4_init);
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 6e412a6..92ac7e7 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -214,7 +214,7 @@ static int __init ic_open_devs(void)
 		if (!(dev->flags & IFF_LOOPBACK))
 			continue;
 		if (dev_change_flags(dev, dev->flags | IFF_UP) < 0)
-			printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+			pr_err("IP-Config: Failed to open %s\n", dev->name);
 	}
 
 	for_each_netdev(&init_net, dev) {
@@ -223,7 +223,8 @@ static int __init ic_open_devs(void)
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
 			else
-				printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
+				pr_warn("DHCP/BOOTP: Ignoring device %s, MTU %d too small",
+					dev->name, dev->mtu);
 			if (!(dev->flags & IFF_NOARP))
 				able |= IC_RARP;
 			able &= ic_proto_enabled;
@@ -231,7 +232,8 @@ static int __init ic_open_devs(void)
 				continue;
 			oflags = dev->flags;
 			if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
-				printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+				pr_err("IP-Config: Failed to open %s\n",
+				       dev->name);
 				continue;
 			}
 			if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
@@ -273,9 +275,10 @@ have_carrier:
 
 	if (!ic_first_dev) {
 		if (user_dev_name[0])
-			printk(KERN_ERR "IP-Config: Device `%s' not found.\n", user_dev_name);
+			pr_err("IP-Config: Device `%s' not found\n",
+			       user_dev_name);
 		else
-			printk(KERN_ERR "IP-Config: No network devices available.\n");
+			pr_err("IP-Config: No network devices available\n");
 		return -ENODEV;
 	}
 	return 0;
@@ -359,17 +362,20 @@ static int __init ic_setup_if(void)
 	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name);
 	set_sockaddr(sin, ic_myaddr, 0);
 	if ((err = ic_devinet_ioctl(SIOCSIFADDR, &ir)) < 0) {
-		printk(KERN_ERR "IP-Config: Unable to set interface address (%d).\n", err);
+		pr_err("IP-Config: Unable to set interface address (%d)\n",
+		       err);
 		return -1;
 	}
 	set_sockaddr(sin, ic_netmask, 0);
 	if ((err = ic_devinet_ioctl(SIOCSIFNETMASK, &ir)) < 0) {
-		printk(KERN_ERR "IP-Config: Unable to set interface netmask (%d).\n", err);
+		pr_err("IP-Config: Unable to set interface netmask (%d)\n",
+		       err);
 		return -1;
 	}
 	set_sockaddr(sin, ic_myaddr | ~ic_netmask, 0);
 	if ((err = ic_devinet_ioctl(SIOCSIFBRDADDR, &ir)) < 0) {
-		printk(KERN_ERR "IP-Config: Unable to set interface broadcast address (%d).\n", err);
+		pr_err("IP-Config: Unable to set interface broadcast address (%d)\n",
+		       err);
 		return -1;
 	}
 	/* Handle the case where we need non-standard MTU on the boot link (a network
@@ -380,8 +386,8 @@ static int __init ic_setup_if(void)
 		strcpy(ir.ifr_name, ic_dev->name);
 		ir.ifr_mtu = ic_dev_mtu;
 		if ((err = ic_dev_ioctl(SIOCSIFMTU, &ir)) < 0)
-			printk(KERN_ERR "IP-Config: Unable to set interface mtu to %d (%d).\n",
-			                 ic_dev_mtu, err);
+			pr_err("IP-Config: Unable to set interface mtu to %d (%d)\n",
+			       ic_dev_mtu, err);
 	}
 	return 0;
 }
@@ -396,7 +402,7 @@ static int __init ic_setup_routes(void)
 
 		memset(&rm, 0, sizeof(rm));
 		if ((ic_gateway ^ ic_myaddr) & ic_netmask) {
-			printk(KERN_ERR "IP-Config: Gateway not on directly connected network.\n");
+			pr_err("IP-Config: Gateway not on directly connected network\n");
 			return -1;
 		}
 		set_sockaddr((struct sockaddr_in *) &rm.rt_dst, 0, 0);
@@ -404,7 +410,8 @@ static int __init ic_setup_routes(void)
 		set_sockaddr((struct sockaddr_in *) &rm.rt_gateway, ic_gateway, 0);
 		rm.rt_flags = RTF_UP | RTF_GATEWAY;
 		if ((err = ic_route_ioctl(SIOCADDRT, &rm)) < 0) {
-			printk(KERN_ERR "IP-Config: Cannot add default route (%d).\n", err);
+			pr_err("IP-Config: Cannot add default route (%d)\n",
+			       err);
 			return -1;
 		}
 	}
@@ -437,8 +444,8 @@ static int __init ic_defaults(void)
 		else if (IN_CLASSC(ntohl(ic_myaddr)))
 			ic_netmask = htonl(IN_CLASSC_NET);
 		else {
-			printk(KERN_ERR "IP-Config: Unable to guess netmask for address %pI4\n",
-				&ic_myaddr);
+			pr_err("IP-Config: Unable to guess netmask for address %pI4\n",
+			       &ic_myaddr);
 			return -1;
 		}
 		printk("IP-Config: Guessing netmask %pI4\n", &ic_netmask);
@@ -688,8 +695,8 @@ ic_dhcp_init_options(u8 *options)
 			e += len;
 		}
 		if (*vendor_class_identifier) {
-			printk(KERN_INFO "DHCP: sending class identifier \"%s\"\n",
-			       vendor_class_identifier);
+			pr_info("DHCP: sending class identifier \"%s\"\n",
+				vendor_class_identifier);
 			*e++ = 60;	/* Class-identifier */
 			len = strlen(vendor_class_identifier);
 			*e++ = len;
@@ -949,8 +956,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	/* Fragments are not supported */
 	if (ip_is_fragment(h)) {
 		if (net_ratelimit())
-			printk(KERN_ERR "DHCP/BOOTP: Ignoring fragmented "
-			       "reply.\n");
+			pr_err("DHCP/BOOTP: Ignoring fragmented reply\n");
 		goto drop;
 	}
 
@@ -999,8 +1005,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	if (b->op != BOOTP_REPLY ||
 	    b->xid != d->xid) {
 		if (net_ratelimit())
-			printk(KERN_ERR "DHCP/BOOTP: Reply not for us, "
-			       "op[%x] xid[%x]\n",
+			pr_err("DHCP/BOOTP: Reply not for us, op[%x] xid[%x]\n",
 			       b->op, b->xid);
 		goto drop_unlock;
 	}
@@ -1008,7 +1013,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	/* Is it a reply for the device we are configuring? */
 	if (b->xid != ic_dev_xid) {
 		if (net_ratelimit())
-			printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet\n");
+			pr_err("DHCP/BOOTP: Ignoring delayed packet\n");
 		goto drop_unlock;
 	}
 
@@ -1146,17 +1151,17 @@ static int __init ic_dynamic(void)
 	 * are missing, and without DHCP/BOOTP/RARP we are unable to get it.
 	 */
 	if (!ic_proto_enabled) {
-		printk(KERN_ERR "IP-Config: Incomplete network configuration information.\n");
+		pr_err("IP-Config: Incomplete network configuration information\n");
 		return -1;
 	}
 
 #ifdef IPCONFIG_BOOTP
 	if ((ic_proto_enabled ^ ic_proto_have_if) & IC_BOOTP)
-		printk(KERN_ERR "DHCP/BOOTP: No suitable device found.\n");
+		pr_err("DHCP/BOOTP: No suitable device found\n");
 #endif
 #ifdef IPCONFIG_RARP
 	if ((ic_proto_enabled ^ ic_proto_have_if) & IC_RARP)
-		printk(KERN_ERR "RARP: No suitable device found.\n");
+		pr_err("RARP: No suitable device found\n");
 #endif
 
 	if (!ic_proto_have_if)
@@ -1183,11 +1188,11 @@ static int __init ic_dynamic(void)
 	 * [Actually we could now, but the nothing else running note still
 	 *  applies.. - AC]
 	 */
-	printk(KERN_NOTICE "Sending %s%s%s requests .",
-	       do_bootp
-		? ((ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP") : "",
-	       (do_bootp && do_rarp) ? " and " : "",
-	       do_rarp ? "RARP" : "");
+	pr_notice("Sending %s%s%s requests .",
+		  do_bootp
+		  ? ((ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP") : "",
+		  (do_bootp && do_rarp) ? " and " : "",
+		  do_rarp ? "RARP" : "");
 
 	start_jiffies = jiffies;
 	d = ic_first_dev;
@@ -1216,13 +1221,13 @@ static int __init ic_dynamic(void)
 		    (ic_proto_enabled & IC_USE_DHCP) &&
 		    ic_dhcp_msgtype != DHCPACK) {
 			ic_got_reply = 0;
-			printk(KERN_CONT ",");
+			pr_cont(",");
 			continue;
 		}
 #endif /* IPCONFIG_DHCP */
 
 		if (ic_got_reply) {
-			printk(KERN_CONT " OK\n");
+			pr_cont(" OK\n");
 			break;
 		}
 
@@ -1230,7 +1235,7 @@ static int __init ic_dynamic(void)
 			continue;
 
 		if (! --retries) {
-			printk(KERN_CONT " timed out!\n");
+			pr_cont(" timed out!\n");
 			break;
 		}
 
@@ -1240,7 +1245,7 @@ static int __init ic_dynamic(void)
 		if (timeout > CONF_TIMEOUT_MAX)
 			timeout = CONF_TIMEOUT_MAX;
 
-		printk(KERN_CONT ".");
+		pr_cont(".");
 	}
 
 #ifdef IPCONFIG_BOOTP
@@ -1260,8 +1265,8 @@ static int __init ic_dynamic(void)
 	printk("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
 		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-		&ic_servaddr);
-	printk(KERN_CONT "my address is %pI4\n", &ic_myaddr);
+	       &ic_servaddr);
+	pr_cont("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
 }
@@ -1437,24 +1442,22 @@ static int __init ip_auto_config(void)
 			 */
 #ifdef CONFIG_ROOT_NFS
 			if (ROOT_DEV ==  Root_NFS) {
-				printk(KERN_ERR
-					"IP-Config: Retrying forever (NFS root)...\n");
+				pr_err("IP-Config: Retrying forever (NFS root)...\n");
 				goto try_try_again;
 			}
 #endif
 
 			if (--retries) {
-				printk(KERN_ERR
-				       "IP-Config: Reopening network devices...\n");
+				pr_err("IP-Config: Reopening network devices...\n");
 				goto try_try_again;
 			}
 
 			/* Oh, well.  At least we tried. */
-			printk(KERN_ERR "IP-Config: Auto-configuration of network failed.\n");
+			pr_err("IP-Config: Auto-configuration of network failed\n");
 			return -1;
 		}
 #else /* !DYNAMIC */
-		printk(KERN_ERR "IP-Config: Incomplete network configuration information.\n");
+		pr_err("IP-Config: Incomplete network configuration information\n");
 		ic_close_devs();
 		return -1;
 #endif /* IPCONFIG_DYNAMIC */
@@ -1492,19 +1495,16 @@ static int __init ip_auto_config(void)
 	/*
 	 * Clue in the operator.
 	 */
-	printk("IP-Config: Complete:\n");
-	printk("     device=%s", ic_dev->name);
-	printk(KERN_CONT ", addr=%pI4", &ic_myaddr);
-	printk(KERN_CONT ", mask=%pI4", &ic_netmask);
-	printk(KERN_CONT ", gw=%pI4", &ic_gateway);
-	printk(KERN_CONT ",\n     host=%s, domain=%s, nis-domain=%s",
-	       utsname()->nodename, ic_domain, utsname()->domainname);
-	printk(KERN_CONT ",\n     bootserver=%pI4", &ic_servaddr);
-	printk(KERN_CONT ", rootserver=%pI4", &root_server_addr);
-	printk(KERN_CONT ", rootpath=%s", root_server_path);
+	pr_info("IP-Config: Complete:\n");
+	pr_info("     device=%s, addr=%pI4, mask=%pI4, gw=%pI4\n",
+		ic_dev->name, &ic_myaddr, &ic_netmask, &ic_gateway);
+	pr_info("     host=%s, domain=%s, nis-domain=%s\n",
+		utsname()->nodename, ic_domain, utsname()->domainname);
+	pr_info("     bootserver=%pI4, rootserver=%pI4, rootpath=%s",
+		&ic_servaddr, &root_server_addr, root_server_path);
 	if (ic_dev_mtu)
-		printk(KERN_CONT ", mtu=%d", ic_dev_mtu);
-	printk(KERN_CONT "\n");
+		pr_cont(", mtu=%d", ic_dev_mtu);
+	pr_cont("\n");
 #endif /* !SILENT */
 
 	return 0;
@@ -1637,8 +1637,8 @@ static int __init vendor_class_identifier_setup(char *addrs)
 	if (strlcpy(vendor_class_identifier, addrs,
 		    sizeof(vendor_class_identifier))
 	    >= sizeof(vendor_class_identifier))
-		printk(KERN_WARNING "DHCP: vendorclass too long, truncated to \"%s\"",
-		       vendor_class_identifier);
+		pr_warn("DHCP: vendorclass too long, truncated to \"%s\"",
+			vendor_class_identifier);
 	return 1;
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index f84ebff..ae1413e 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -892,7 +892,7 @@ static int __init ipip_init(void)
 	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
 	if (err < 0) {
 		unregister_pernet_device(&ipip_net_ops);
-		printk(KERN_INFO "ipip init: can't register tunnel\n");
+		pr_info("%s: can't register tunnel\n", __func__);
 	}
 	return err;
 }
@@ -900,7 +900,7 @@ static int __init ipip_init(void)
 static void __exit ipip_fini(void)
 {
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
-		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
+		pr_info("%s: can't deregister tunnel\n", __func__);
 
 	unregister_pernet_device(&ipip_net_ops);
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7bc2db6..0518a4f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -951,7 +951,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	rcu_read_unlock();
 	if (ret < 0) {
 		if (net_ratelimit())
-			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
+			pr_warn("mroute: pending queue full, dropping entries\n");
 		kfree_skb(skb);
 	}
 
@@ -2538,7 +2538,7 @@ int __init ip_mr_init(void)
 		goto reg_notif_fail;
 #ifdef CONFIG_IP_PIMSM_V2
 	if (inet_add_protocol(&pim_protocol, IPPROTO_PIM) < 0) {
-		printk(KERN_ERR "ip_mr_init: can't add PIM protocol\n");
+		pr_err("%s: can't add PIM protocol\n", __func__);
 		err = -EAGAIN;
 		goto add_proto_fail;
 	}
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 4398a45..ab6b36e 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -156,7 +156,7 @@ static struct sock *ping_v4_lookup(struct net *net, __be32 saddr, __be32 daddr,
 	struct hlist_nulls_node *hnode;
 
 	pr_debug("try to find: num = %d, daddr = %pI4, dif = %d\n",
-			 (int)ident, &daddr, dif);
+		 (int)ident, &daddr, dif);
 	read_lock_bh(&ping_table.lock);
 
 	ping_portaddr_for_each_entry(sk, hnode, hslot) {
@@ -229,7 +229,7 @@ static int ping_init_sock(struct sock *sk)
 static void ping_close(struct sock *sk, long timeout)
 {
 	pr_debug("ping_close(sk=%p,sk->num=%u)\n",
-		inet_sk(sk), inet_sk(sk)->inet_num);
+		 inet_sk(sk), inet_sk(sk)->inet_num);
 	pr_debug("isk->refcnt = %d\n", sk->sk_refcnt.counter);
 
 	sk_common_release(sk);
@@ -252,7 +252,7 @@ static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	pr_debug("ping_v4_bind(sk=%p,sa_addr=%08x,sa_port=%d)\n",
-		sk, addr->sin_addr.s_addr, ntohs(addr->sin_port));
+		 sk, addr->sin_addr.s_addr, ntohs(addr->sin_port));
 
 	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
 	if (addr->sin_addr.s_addr == htonl(INADDR_ANY))
@@ -280,9 +280,9 @@ static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	pr_debug("after bind(): num = %d, daddr = %pI4, dif = %d\n",
-		(int)isk->inet_num,
-		&isk->inet_rcv_saddr,
-		(int)sk->sk_bound_dev_if);
+		 (int)isk->inet_num,
+		 &isk->inet_rcv_saddr,
+		 (int)sk->sk_bound_dev_if);
 
 	err = 0;
 	if (isk->inet_rcv_saddr)
@@ -335,7 +335,7 @@ void ping_err(struct sk_buff *skb, u32 info)
 		return;
 
 	pr_debug("ping_err(type=%04x,code=%04x,id=%04x,seq=%04x)\n", type,
-		code, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+		 code, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
 
 	sk = ping_v4_lookup(net, iph->daddr, iph->saddr,
 			    ntohs(icmph->un.echo.id), skb->dev->ifindex);
@@ -679,7 +679,7 @@ out:
 static int ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	pr_debug("ping_queue_rcv_skb(sk=%p,sk->num=%d,skb=%p)\n",
-		inet_sk(sk), inet_sk(sk)->inet_num, skb);
+		 inet_sk(sk), inet_sk(sk)->inet_num, skb);
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		pr_debug("ping_queue_rcv_skb -> failed\n");
@@ -705,7 +705,7 @@ void ping_rcv(struct sk_buff *skb)
 	/* We assume the packet has already been checked by icmp_rcv */
 
 	pr_debug("ping_rcv(skb=%p,id=%04x,seq=%04x)\n",
-		skb, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+		 skb, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
 
 	/* Push ICMP header back */
 	skb_push(skb, skb->data - (u8 *)icmph);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ab46630..bbd604c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -491,11 +491,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if (msg->msg_namelen < sizeof(*usin))
 			goto out;
 		if (usin->sin_family != AF_INET) {
-			static int complained;
-			if (!complained++)
-				printk(KERN_INFO "%s forgot to set AF_INET in "
-						 "raw sendmsg. Fix it!\n",
-						 current->comm);
+			pr_info_once("%s: %s forgot to set AF_INET. Fix it!\n",
+				     __func__, current->comm);
 			err = -EAFNOSUPPORT;
 			if (usin->sin_family)
 				goto out;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 815989b..cbda6de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -959,7 +959,7 @@ void rt_cache_flush_batch(struct net *net)
 static void rt_emergency_hash_rebuild(struct net *net)
 {
 	if (net_ratelimit())
-		printk(KERN_WARNING "Route hash chain too long!\n");
+		pr_warn("Route hash chain too long!\n");
 	rt_cache_invalidate(net);
 }
 
@@ -1083,7 +1083,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 	if (dst_entries_get_slow(&ipv4_dst_ops) < ip_rt_max_size)
 		goto out;
 	if (net_ratelimit())
-		printk(KERN_WARNING "dst cache overflow\n");
+		pr_warn("dst cache overflow\n");
 	RT_CACHE_STAT_INC(gc_dst_overflow);
 	return 1;
 
@@ -1181,8 +1181,7 @@ restart:
 			int err = rt_bind_neighbour(rt);
 			if (err) {
 				if (net_ratelimit())
-					printk(KERN_WARNING
-					    "Neighbour table failure & not caching routes.\n");
+					pr_warn("Neighbour table failure & not caching routes\n");
 				ip_rt_put(rt);
 				return ERR_PTR(err);
 			}
@@ -1258,7 +1257,7 @@ restart:
 			struct net *net = dev_net(rt->dst.dev);
 			int num = ++net->ipv4.current_rt_cache_rebuild_count;
 			if (!rt_caching(net)) {
-				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching disabled\n",
+				pr_warn("%s: %d rebuilds is over limit, route caching disabled\n",
 					rt->dst.dev->name, num);
 			}
 			rt_emergency_hash_rebuild(net);
@@ -1299,7 +1298,7 @@ restart:
 			}
 
 			if (net_ratelimit())
-				printk(KERN_WARNING "ipv4: Neighbour table overflow.\n");
+				pr_warn("ipv4: Neighbour table overflow\n");
 			rt_drop(rt);
 			return ERR_PTR(-ENOBUFS);
 		}
@@ -1503,10 +1502,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 reject_redirect:
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		printk(KERN_INFO "Redirect from %pI4 on %s about %pI4 ignored.\n"
+		pr_info("Redirect from %pI4 on %s about %pI4 ignored\n"
 			"  Advised path = %pI4 -> %pI4\n",
-		       &old_gw, dev->name, &new_gw,
-		       &saddr, &daddr);
+			&old_gw, dev->name, &new_gw,
+			&saddr, &daddr);
 #endif
 	;
 }
@@ -1618,8 +1617,8 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		if (log_martians &&
 		    peer->rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
-			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
-			       &ip_hdr(skb)->saddr, rt->rt_iif,
+			pr_warn("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
+				&ip_hdr(skb)->saddr, rt->rt_iif,
 				&rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
@@ -2105,18 +2104,13 @@ static void ip_handle_martian_source(struct net_device *dev,
 		 *	RFC1812 recommendation, if source is martian,
 		 *	the only hint is MAC header.
 		 */
-		printk(KERN_WARNING "martian source %pI4 from %pI4, on dev %s\n",
+		pr_warn("martian source %pI4 from %pI4, on dev %s\n",
 			&daddr, &saddr, dev->name);
 		if (dev->hard_header_len && skb_mac_header_was_set(skb)) {
-			int i;
-			const unsigned char *p = skb_mac_header(skb);
-			printk(KERN_WARNING "ll header: ");
-			for (i = 0; i < dev->hard_header_len; i++, p++) {
-				printk("%02x", *p);
-				if (i < (dev->hard_header_len - 1))
-					printk(":");
-			}
-			printk("\n");
+			print_hex_dump(KERN_WARNING, "ll header: ",
+				       DUMP_PREFIX_OFFSET, 16, 1,
+				       skb_mac_header(skb),
+				       dev->hard_header_len, true);
 		}
 	}
 #endif
@@ -2140,8 +2134,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
 	if (out_dev == NULL) {
 		if (net_ratelimit())
-			printk(KERN_CRIT "Bug in ip_route_input" \
-			       "_slow(). Please, report\n");
+			pr_crit("Bug in ip_route_input_slow(). Please report.\n");
 		return -EINVAL;
 	}
 
@@ -2413,7 +2406,7 @@ martian_destination:
 	RT_CACHE_STAT_INC(in_martian_dst);
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		printk(KERN_WARNING "martian destination %pI4 from %pI4, dev %s\n",
+		pr_warn("martian destination %pI4 from %pI4, dev %s\n",
 			&daddr, &saddr, dev->name);
 #endif
 
@@ -3490,7 +3483,7 @@ int __init ip_rt_init(void)
 		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
 
 	if (ip_rt_proc_init())
-		printk(KERN_ERR "Unable to create route proc files\n");
+		pr_err("Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
 	xfrm4_init(ip_rt_max_size);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..2baba1b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1675,7 +1675,7 @@ do_prequeue:
 
 				if (tp->ucopy.dma_cookie < 0) {
 
-					printk(KERN_ALERT "dma_cookie < 0\n");
+					pr_alert("dma_cookie < 0\n");
 
 					/* Exception. Bailout! */
 					if (!copied)
@@ -3311,9 +3311,8 @@ void __init tcp_init(void)
 	sysctl_tcp_rmem[1] = 87380;
 	sysctl_tcp_rmem[2] = max(87380, max_share);
 
-	printk(KERN_INFO "TCP: Hash tables configured "
-	       "(established %u bind %u)\n",
-	       tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
+	pr_info("TCP: Hash tables configured (established %u bind %u)\n",
+		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index fc6d475..67bab75 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -41,18 +41,17 @@ int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
 
 	/* all algorithms must implement ssthresh and cong_avoid ops */
 	if (!ca->ssthresh || !ca->cong_avoid) {
-		printk(KERN_ERR "TCP %s does not implement required ops\n",
-		       ca->name);
+		pr_err("TCP %s does not implement required ops\n", ca->name);
 		return -EINVAL;
 	}
 
 	spin_lock(&tcp_cong_list_lock);
 	if (tcp_ca_find(ca->name)) {
-		printk(KERN_NOTICE "TCP %s already registered\n", ca->name);
+		pr_notice("TCP %s already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
 		list_add_tail_rcu(&ca->list, &tcp_cong_list);
-		printk(KERN_INFO "TCP %s registered\n", ca->name);
+		pr_info("TCP %s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b5e315f..23ca366 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3867,9 +3867,9 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 					opt_rx->wscale_ok = 1;
 					if (snd_wscale > 14) {
 						if (net_ratelimit())
-							printk(KERN_INFO "tcp_parse_options: Illegal window "
-							       "scaling value %d >14 received.\n",
-							       snd_wscale);
+							pr_info("%s: Illegal window scaling value %d >14 received\n",
+								__func__,
+								snd_wscale);
 						snd_wscale = 14;
 					}
 					opt_rx->snd_wscale = snd_wscale;
@@ -4191,7 +4191,7 @@ static void tcp_fin(struct sock *sk)
 		/* Only TCP_LISTEN and TCP_CLOSE are left, in these
 		 * cases we should never reach this piece of code.
 		 */
-		printk(KERN_ERR "%s: Impossible, sk->sk_state=%d\n",
+		pr_err("%s: Impossible, sk->sk_state=%d\n",
 		       __func__, sk->sk_state);
 		break;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 507924b..257dba6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1227,10 +1227,10 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
-			       &iph->saddr, ntohs(th->source),
-			       &iph->daddr, ntohs(th->dest),
-			       genhash ? " tcp_v4_calc_md5_hash failed" : "");
+			pr_info("MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
+				&iph->saddr, ntohs(th->source),
+				&iph->daddr, ntohs(th->dest),
+				genhash ? " tcp_v4_calc_md5_hash failed" : "");
 		}
 		return 1;
 	}
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 0177598..0d01718 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -164,12 +164,12 @@ static const struct net_protocol tunnel64_protocol = {
 static int __init tunnel4_init(void)
 {
 	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP)) {
-		printk(KERN_ERR "tunnel4 init: can't add protocol\n");
+		pr_err("%s: can't add protocol\n", __func__);
 		return -EAGAIN;
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
-		printk(KERN_ERR "tunnel64 init: can't add protocol\n");
+		pr_err("tunnel64 init: can't add protocol\n");
 		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
 		return -EAGAIN;
 	}
@@ -181,10 +181,10 @@ static void __exit tunnel4_fini(void)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
-		printk(KERN_ERR "tunnel64 close: can't remove protocol\n");
+		pr_err("tunnel64 close: can't remove protocol\n");
 #endif
 	if (inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP))
-		printk(KERN_ERR "tunnel4 close: can't remove protocol\n");
+		pr_err("tunnel4 close: can't remove protocol\n");
 }
 
 module_init(tunnel4_init);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 12e9499..280bfb1 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -129,11 +129,11 @@ void __init udplite4_register(void)
 	inet_register_protosw(&udplite4_protosw);
 
 	if (udplite4_proc_init())
-		printk(KERN_ERR "%s: Cannot register /proc!\n", __func__);
+		pr_err("%s: Cannot register /proc!\n", __func__);
 	return;
 
 out_unregister_proto:
 	proto_unregister(&udplite_prot);
 out_register_err:
-	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __func__);
+	pr_crit("%s: Cannot add UDP-Lite protocol\n", __func__);
 }
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 9247d9d..5b48f49 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -75,18 +75,18 @@ static struct xfrm_tunnel xfrm64_tunnel_handler __read_mostly = {
 static int __init ipip_init(void)
 {
 	if (xfrm_register_type(&ipip_type, AF_INET) < 0) {
-		printk(KERN_INFO "ipip init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 
 	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET)) {
-		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET\n");
+		pr_info("%s: can't add xfrm handler for AF_INET\n", __func__);
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	if (xfrm4_tunnel_register(&xfrm64_tunnel_handler, AF_INET6)) {
-		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
+		pr_info("%s: can't add xfrm handler for AF_INET6\n", __func__);
 		xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET);
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
@@ -99,12 +99,14 @@ static void __exit ipip_fini(void)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (xfrm4_tunnel_deregister(&xfrm64_tunnel_handler, AF_INET6))
-		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET6\n");
+		pr_info("%s: can't remove xfrm handler for AF_INET6\n",
+			__func__);
 #endif
 	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET))
-		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET\n");
+		pr_info("%s: can't remove xfrm handler for AF_INET\n",
+			__func__);
 	if (xfrm_unregister_type(&ipip_type, AF_INET) < 0)
-		printk(KERN_INFO "ipip close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(ipip_init);
-- 
1.7.8.111.gad25c.dirty
