From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] net: ipv6: Standardize prefixes for message logging
Date: Tue, 15 May 2012 17:11:53 -0700
Message-ID: <1e9920c86f1dc655466eaf6fb42688a3d326d8ae.1337126963.git.joe@perches.com>
References: <cover.1337126962.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337126962.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) as appropriate.

Add "IPv6: " to appropriate files.

Convert printk(KERN_<LEVEL> to pr_<level> (but not KERN_DEBUG).
Standardize on "%s: " not "%s(): " when emitting __func__.
Use "%s: ", __func__ instead of embedding function name.
Coalesce formats, align arguments.

ADDRCONF output is now prefixed with "IPv6: "

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/addrconf.c   |   53 +++++++++++++++++++++---------------------------
 net/ipv6/addrlabel.c  |    2 +-
 net/ipv6/af_inet6.c   |   14 ++++--------
 net/ipv6/ah6.c        |   16 ++++++++------
 net/ipv6/esp6.c       |   10 +++++---
 net/ipv6/icmp.c       |    8 +++---
 net/ipv6/ip6_fib.c    |   20 +++++++++---------
 net/ipv6/ip6_tunnel.c |   21 +++++++++----------
 net/ipv6/ip6mr.c      |    2 +-
 net/ipv6/ipcomp6.c    |   11 ++++++---
 net/ipv6/mcast.c      |    3 +-
 net/ipv6/mip6.c       |   30 +++++++++++++-------------
 net/ipv6/ndisc.c      |   22 ++++++++------------
 net/ipv6/route.c      |    8 ++++--
 net/ipv6/sit.c        |    6 +++-
 net/ipv6/tunnel6.c    |   10 +++++---
 16 files changed, 116 insertions(+), 120 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4d1d51a..7079890 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -38,6 +38,8 @@
  *						status etc.
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -327,11 +329,11 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 	WARN_ON(idev->mc_list != NULL);
 
 #ifdef NET_REFCNT_DEBUG
-	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name : "NIL");
+	printk(KERN_DEBUG "%s: %s\n", __func__, dev ? dev->name : "NIL");
 #endif
 	dev_put(dev);
 	if (!idev->dead) {
-		pr_warning("Freeing alive inet6 device %p\n", idev);
+		pr_warn("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
 	snmp6_free_dev(idev);
@@ -372,7 +374,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 	if (snmp6_alloc_dev(ndev) < 0) {
 		ADBG((KERN_WARNING
-			"%s(): cannot allocate memory for statistics; dev=%s.\n",
+			"%s: cannot allocate memory for statistics; dev=%s.\n",
 			__func__, dev->name));
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		dev_put(dev);
@@ -382,7 +384,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 	if (snmp6_register_dev(ndev) < 0) {
 		ADBG((KERN_WARNING
-			"%s(): cannot create /proc/net/dev_snmp6/%s\n",
+			"%s: cannot create /proc/net/dev_snmp6/%s\n",
 			__func__, dev->name));
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
@@ -400,9 +402,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
-		printk(KERN_INFO
-		       "%s: Disabled Multicast RS\n",
-		       dev->name);
+		pr_info("%s: Disabled Multicast RS\n", dev->name);
 		ndev->cnf.rtr_solicits = 0;
 	}
 #endif
@@ -551,7 +551,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 		pr_notice("Timer is still running, when freeing ifa=%p\n", ifp);
 
 	if (ifp->state != INET6_IFADDR_STATE_DEAD) {
-		pr_warning("Freeing alive inet6 address %p\n", ifp);
+		pr_warn("Freeing alive inet6 address %p\n", ifp);
 		return;
 	}
 	dst_release(&ifp->rt->dst);
@@ -841,8 +841,7 @@ retry:
 	in6_dev_hold(idev);
 	if (idev->cnf.use_tempaddr <= 0) {
 		write_unlock(&idev->lock);
-		printk(KERN_INFO
-			"ipv6_create_tempaddr(): use_tempaddr is disabled.\n");
+		pr_info("%s: use_tempaddr is disabled\n", __func__);
 		in6_dev_put(idev);
 		ret = -1;
 		goto out;
@@ -852,8 +851,8 @@ retry:
 		idev->cnf.use_tempaddr = -1;	/*XXX*/
 		spin_unlock_bh(&ifp->lock);
 		write_unlock(&idev->lock);
-		printk(KERN_WARNING
-			"ipv6_create_tempaddr(): regeneration time exceeded. disabled temporary address support.\n");
+		pr_warn("%s: regeneration time exceeded - disabled temporary address support\n",
+			__func__);
 		in6_dev_put(idev);
 		ret = -1;
 		goto out;
@@ -863,8 +862,8 @@ retry:
 	if (__ipv6_try_regen_rndid(idev, tmpaddr) < 0) {
 		spin_unlock_bh(&ifp->lock);
 		write_unlock(&idev->lock);
-		printk(KERN_WARNING
-			"ipv6_create_tempaddr(): regeneration of randomized interface id failed.\n");
+		pr_warn("%s: regeneration of randomized interface id failed\n",
+			__func__);
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
 		ret = -1;
@@ -914,8 +913,7 @@ retry:
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
-		printk(KERN_INFO
-			"ipv6_create_tempaddr(): retry temporary address regeneration.\n");
+		pr_info("%s: retry temporary address regeneration\n", __func__);
 		tmpaddr = &addr;
 		write_lock(&idev->lock);
 		goto retry;
@@ -1429,7 +1427,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 			/* DAD failed for link-local based on MAC address */
 			idev->cnf.disable_ipv6 = 1;
 
-			printk(KERN_INFO "%s: IPv6 being disabled!\n",
+			pr_info("%s: IPv6 being disabled!\n",
 				ifp->idev->dev->name);
 		}
 	}
@@ -1660,9 +1658,8 @@ static void ipv6_regen_rndid(unsigned long data)
 		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time -
 		idev->cnf.max_desync_factor * HZ;
 	if (time_before(expires, jiffies)) {
-		printk(KERN_WARNING
-			"ipv6_regen_rndid(): too short regeneration interval; timer disabled for %s.\n",
-			idev->dev->name);
+		pr_warn("%s: too short regeneration interval; timer disabled for %s\n",
+			__func__, idev->dev->name);
 		goto out;
 	}
 
@@ -2507,7 +2504,7 @@ static void addrconf_gre_config(struct net_device *dev)
 	struct inet6_dev *idev;
 	struct in6_addr addr;
 
-	pr_info("ipv6: addrconf_gre_config(%s)\n", dev->name);
+	pr_info("%s(%s)\n", __func__, dev->name);
 
 	ASSERT_RTNL();
 
@@ -2599,9 +2596,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		if (event == NETDEV_UP) {
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is not ready yet. */
-				printk(KERN_INFO
-					"ADDRCONF(NETDEV_UP): %s: "
-					"link is not ready\n",
+				pr_info("ADDRCONF(NETDEV_UP): %s: link is not ready\n",
 					dev->name);
 				break;
 			}
@@ -2626,10 +2621,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				idev->if_flags |= IF_READY;
 			}
 
-			printk(KERN_INFO
-					"ADDRCONF(NETDEV_CHANGE): %s: "
-					"link becomes ready\n",
-					dev->name);
+			pr_info("ADDRCONF(NETDEV_CHANGE): %s: link becomes ready\n",
+				dev->name);
 
 			run_pending = 1;
 		}
@@ -4757,8 +4750,8 @@ int __init addrconf_init(void)
 
 	err = ipv6_addr_label_init();
 	if (err < 0) {
-		printk(KERN_CRIT "IPv6 Addrconf:"
-		       " cannot initialize default policy table: %d.\n", err);
+		pr_crit("%s: cannot initialize default policy table: %d\n",
+			__func__, err);
 		goto out;
 	}
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 2d8ddba..95aea16 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -350,7 +350,7 @@ static int __net_init ip6addrlbl_net_init(struct net *net)
 	int err = 0;
 	int i;
 
-	ADDRLABEL(KERN_DEBUG "%s()\n", __func__);
+	ADDRLABEL(KERN_DEBUG "%s\n", __func__);
 
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
 		int ret = ip6addrlbl_add(net,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bf8e146..138d498 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -18,6 +18,7 @@
  *      2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
 
 #include <linux/module.h>
 #include <linux/capability.h>
@@ -612,13 +613,11 @@ out:
 	return ret;
 
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
@@ -628,8 +627,7 @@ void
 inet6_unregister_protosw(struct inet_protosw *p)
 {
 	if (INET_PROTOSW_PERMANENT & p->flags) {
-		printk(KERN_ERR
-		       "Attempt to unregister permanent protocol %d.\n",
+		pr_err("Attempt to unregister permanent protocol %d\n",
 		       p->protocol);
 	} else {
 		spin_lock_bh(&inetsw6_lock);
@@ -1067,9 +1065,7 @@ static int __init inet6_init(void)
 		INIT_LIST_HEAD(r);
 
 	if (disable_ipv6_mod) {
-		printk(KERN_INFO
-		       "IPv6: Loaded, but administratively disabled, "
-		       "reboot required to enable\n");
+		pr_info("Loaded, but administratively disabled, reboot required to enable\n");
 		goto out;
 	}
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index a9f4156..9aa3d01 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -24,6 +24,8 @@
  * 	This file is derived from net/ipv4/ah.c.
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <crypto/hash.h>
 #include <linux/module.h>
 #include <linux/slab.h>
@@ -659,9 +661,9 @@ static int ah6_init_state(struct xfrm_state *x)
 
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
 
@@ -727,12 +729,12 @@ static const struct inet6_protocol ah6_protocol = {
 static int __init ah6_init(void)
 {
 	if (xfrm_register_type(&ah6_type, AF_INET6) < 0) {
-		printk(KERN_INFO "ipv6 ah init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 
 	if (inet6_add_protocol(&ah6_protocol, IPPROTO_AH) < 0) {
-		printk(KERN_INFO "ipv6 ah init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ah6_type, AF_INET6);
 		return -EAGAIN;
 	}
@@ -743,10 +745,10 @@ static int __init ah6_init(void)
 static void __exit ah6_fini(void)
 {
 	if (inet6_del_protocol(&ah6_protocol, IPPROTO_AH) < 0)
-		printk(KERN_INFO "ipv6 ah close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 
 	if (xfrm_unregister_type(&ah6_type, AF_INET6) < 0)
-		printk(KERN_INFO "ipv6 ah close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1ac7938..6697eb0 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -24,6 +24,8 @@
  * 	This file is derived from net/ipv4/esp.c
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <crypto/aead.h>
 #include <crypto/authenc.h>
 #include <linux/err.h>
@@ -651,11 +653,11 @@ static const struct inet6_protocol esp6_protocol = {
 static int __init esp6_init(void)
 {
 	if (xfrm_register_type(&esp6_type, AF_INET6) < 0) {
-		printk(KERN_INFO "ipv6 esp init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet6_add_protocol(&esp6_protocol, IPPROTO_ESP) < 0) {
-		printk(KERN_INFO "ipv6 esp init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&esp6_type, AF_INET6);
 		return -EAGAIN;
 	}
@@ -666,9 +668,9 @@ static int __init esp6_init(void)
 static void __exit esp6_fini(void)
 {
 	if (inet6_del_protocol(&esp6_protocol, IPPROTO_ESP) < 0)
-		printk(KERN_INFO "ipv6 esp close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&esp6_type, AF_INET6) < 0)
-		printk(KERN_INFO "ipv6 esp close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(esp6_init);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index cc079d8..23c56ce 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -29,6 +29,8 @@
  *	Kazunori MIYAZAWA @USAGI:       change output process to use ip6_append_data
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -820,9 +822,7 @@ static int __net_init icmpv6_sk_init(struct net *net)
 		err = inet_ctl_sock_create(&sk, PF_INET6,
 					   SOCK_RAW, IPPROTO_ICMPV6, net);
 		if (err < 0) {
-			printk(KERN_ERR
-			       "Failed to initialize the ICMP6 control socket "
-			       "(err %d).\n",
+			pr_err("Failed to initialize the ICMP6 control socket (err %d)\n",
 			       err);
 			goto fail;
 		}
@@ -881,7 +881,7 @@ int __init icmpv6_init(void)
 	return 0;
 
 fail:
-	printk(KERN_ERR "Failed to register ICMP6 protocol\n");
+	pr_err("Failed to register ICMP6 protocol\n");
 	unregister_pernet_subsys(&icmpv6_sk_ops);
 	return err;
 }
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 9371743..e9846da 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -18,6 +18,9 @@
  * 				routing table.
  * 	Ville Nuorvala:		Fixed routing subtrees.
  */
+
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/net.h>
@@ -451,12 +454,10 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
 			if (!allow_create) {
 				if (replace_required) {
-					pr_warn("IPv6: Can't replace route, "
-						"no match found\n");
+					pr_warn("Can't replace route, no match found\n");
 					return ERR_PTR(-ENOENT);
 				}
-				pr_warn("IPv6: NLM_F_CREATE should be set "
-					"when creating new route\n");
+				pr_warn("NLM_F_CREATE should be set when creating new route\n");
 			}
 			goto insert_above;
 		}
@@ -499,11 +500,10 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		 * That would keep IPv6 consistent with IPv4
 		 */
 		if (replace_required) {
-			pr_warn("IPv6: Can't replace route, no match found\n");
+			pr_warn("Can't replace route, no match found\n");
 			return ERR_PTR(-ENOENT);
 		}
-		pr_warn("IPv6: NLM_F_CREATE should be set "
-			"when creating new route\n");
+		pr_warn("NLM_F_CREATE should be set when creating new route\n");
 	}
 	/*
 	 *	We walked to the bottom of tree.
@@ -696,7 +696,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	 */
 	if (!replace) {
 		if (!add)
-			pr_warn("IPv6: NLM_F_CREATE should be set when creating new route\n");
+			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
 		rt->dst.rt6_next = iter;
@@ -715,7 +715,7 @@ add:
 		if (!found) {
 			if (add)
 				goto add;
-			pr_warn("IPv6: NLM_F_REPLACE set, but no existing node found!\n");
+			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
 		*ins = rt;
@@ -768,7 +768,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 			replace_required = 1;
 	}
 	if (!allow_create && !replace_required)
-		pr_warn("IPv6: RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
+		pr_warn("RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
 			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 27fec27..7962b3d 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -18,6 +18,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/errno.h>
@@ -836,15 +838,12 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 			ldev = dev_get_by_index_rcu(net, p->link);
 
 		if (unlikely(!ipv6_chk_addr(net, &p->laddr, ldev, 0)))
-			printk(KERN_WARNING
-			       "%s xmit: Local address not yet configured!\n",
-			       p->name);
+			pr_warn("%s xmit: Local address not yet configured!\n",
+				p->name);
 		else if (!ipv6_addr_is_multicast(&p->raddr) &&
 			 unlikely(ipv6_chk_addr(net, &p->raddr, NULL, 0)))
-			printk(KERN_WARNING
-			       "%s xmit: Routing loop! "
-			       "Remote address found on this node!\n",
-			       p->name);
+			pr_warn("%s xmit: Routing loop! Remote address found on this node!\n",
+				p->name);
 		else
 			ret = 1;
 		rcu_read_unlock();
@@ -1542,13 +1541,13 @@ static int __init ip6_tunnel_init(void)
 
 	err = xfrm6_tunnel_register(&ip4ip6_handler, AF_INET);
 	if (err < 0) {
-		printk(KERN_ERR "ip6_tunnel init: can't register ip4ip6\n");
+		pr_err("%s: can't register ip4ip6\n", __func__);
 		goto out_ip4ip6;
 	}
 
 	err = xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6);
 	if (err < 0) {
-		printk(KERN_ERR "ip6_tunnel init: can't register ip6ip6\n");
+		pr_err("%s: can't register ip6ip6\n", __func__);
 		goto out_ip6ip6;
 	}
 
@@ -1569,10 +1568,10 @@ out_pernet:
 static void __exit ip6_tunnel_cleanup(void)
 {
 	if (xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET))
-		printk(KERN_INFO "ip6_tunnel close: can't deregister ip4ip6\n");
+		pr_info("%s: can't deregister ip4ip6\n", __func__);
 
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
-		printk(KERN_INFO "ip6_tunnel close: can't deregister ip6ip6\n");
+		pr_info("%s: can't deregister ip6ip6\n", __func__);
 
 	unregister_pernet_device(&ip6_tnl_net_ops);
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index ba936e1..b15dc08 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1350,7 +1350,7 @@ int __init ip6_mr_init(void)
 		goto reg_notif_fail;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	if (inet6_add_protocol(&pim6_protocol, IPPROTO_PIM) < 0) {
-		printk(KERN_ERR "ip6_mr_init: can't add PIM protocol\n");
+		pr_err("%s: can't add PIM protocol\n", __func__);
 		err = -EAGAIN;
 		goto add_proto_fail;
 	}
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index bba658d..1addba5 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -30,6 +30,9 @@
  *  The decompression of IP datagram MUST be done after the reassembly,
  *  AH/ESP processing.
  */
+
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/module.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -190,11 +193,11 @@ static const struct inet6_protocol ipcomp6_protocol =
 static int __init ipcomp6_init(void)
 {
 	if (xfrm_register_type(&ipcomp6_type, AF_INET6) < 0) {
-		printk(KERN_INFO "ipcomp6 init: can't add xfrm type\n");
+		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet6_add_protocol(&ipcomp6_protocol, IPPROTO_COMP) < 0) {
-		printk(KERN_INFO "ipcomp6 init: can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ipcomp6_type, AF_INET6);
 		return -EAGAIN;
 	}
@@ -204,9 +207,9 @@ static int __init ipcomp6_init(void)
 static void __exit ipcomp6_fini(void)
 {
 	if (inet6_del_protocol(&ipcomp6_protocol, IPPROTO_COMP) < 0)
-		printk(KERN_INFO "ipv6 ipcomp close: can't remove protocol\n");
+		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ipcomp6_type, AF_INET6) < 0)
-		printk(KERN_INFO "ipv6 ipcomp close: can't remove xfrm type\n");
+		pr_info("%s: can't remove xfrm type\n", __func__);
 }
 
 module_init(ipcomp6_init);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7dfb89f..2a3a22c 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2627,8 +2627,7 @@ static int __net_init igmp6_net_init(struct net *net)
 	err = inet_ctl_sock_create(&net->ipv6.igmp_sk, PF_INET6,
 				   SOCK_RAW, IPPROTO_ICMPV6, net);
 	if (err < 0) {
-		printk(KERN_ERR
-		       "Failed to initialize the IGMP6 control socket (err %d).\n",
+		pr_err("Failed to initialize the IGMP6 control socket (err %d)\n",
 		       err);
 		goto out;
 	}
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7e1e0fb..2e02f7c 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -22,6 +22,8 @@
  *	Masahide NAKAMURA @USAGI
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/time.h>
@@ -307,13 +309,12 @@ static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
 static int mip6_destopt_init_state(struct xfrm_state *x)
 {
 	if (x->id.spi) {
-		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,
-		       x->id.spi);
+		pr_info("%s: spi is not 0: %u\n", __func__, x->id.spi);
 		return -EINVAL;
 	}
 	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
-		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
-		       __func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		pr_info("%s: state's mode is not %u: %u\n",
+			__func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
 		return -EINVAL;
 	}
 
@@ -443,13 +444,12 @@ static int mip6_rthdr_offset(struct xfrm_state *x, struct sk_buff *skb,
 static int mip6_rthdr_init_state(struct xfrm_state *x)
 {
 	if (x->id.spi) {
-		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,
-		       x->id.spi);
+		pr_info("%s: spi is not 0: %u\n", __func__, x->id.spi);
 		return -EINVAL;
 	}
 	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
-		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
-		       __func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		pr_info("%s: state's mode is not %u: %u\n",
+			__func__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
 		return -EINVAL;
 	}
 
@@ -481,18 +481,18 @@ static const struct xfrm_type mip6_rthdr_type =
 
 static int __init mip6_init(void)
 {
-	printk(KERN_INFO "Mobile IPv6\n");
+	pr_info("Mobile IPv6\n");
 
 	if (xfrm_register_type(&mip6_destopt_type, AF_INET6) < 0) {
-		printk(KERN_INFO "%s: can't add xfrm type(destopt)\n", __func__);
+		pr_info("%s: can't add xfrm type(destopt)\n", __func__);
 		goto mip6_destopt_xfrm_fail;
 	}
 	if (xfrm_register_type(&mip6_rthdr_type, AF_INET6) < 0) {
-		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __func__);
+		pr_info("%s: can't add xfrm type(rthdr)\n", __func__);
 		goto mip6_rthdr_xfrm_fail;
 	}
 	if (rawv6_mh_filter_register(mip6_mh_filter) < 0) {
-		printk(KERN_INFO "%s: can't add rawv6 mh filter\n", __func__);
+		pr_info("%s: can't add rawv6 mh filter\n", __func__);
 		goto mip6_rawv6_mh_fail;
 	}
 
@@ -510,11 +510,11 @@ static int __init mip6_init(void)
 static void __exit mip6_fini(void)
 {
 	if (rawv6_mh_filter_unregister(mip6_mh_filter) < 0)
-		printk(KERN_INFO "%s: can't remove rawv6 mh filter\n", __func__);
+		pr_info("%s: can't remove rawv6 mh filter\n", __func__);
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
-		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __func__);
+		pr_info("%s: can't remove xfrm type(rthdr)\n", __func__);
 	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
-		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __func__);
+		pr_info("%s: can't remove xfrm type(destopt)\n", __func__);
 }
 
 module_init(mip6_init);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 35615c6..511e5b4 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -266,7 +266,7 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 		case ND_OPT_REDIRECT_HDR:
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
 				ND_PRINTK2(KERN_WARNING
-					   "%s(): duplicated ND6 option found: type=%d\n",
+					   "%s: duplicated ND6 option found: type=%d\n",
 					   __func__,
 					   nd_opt->nd_opt_type);
 			} else {
@@ -297,7 +297,7 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 				 * protocol.
 				 */
 				ND_PRINTK2(KERN_NOTICE
-					   "%s(): ignored unsupported option; type=%d, len=%d\n",
+					   "%s: ignored unsupported option; type=%d, len=%d\n",
 					   __func__,
 					   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
 			}
@@ -459,7 +459,7 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 ND: %s() failed to allocate an skb, err=%d.\n",
+			   "ICMPv6 ND: %s failed to allocate an skb, err=%d.\n",
 			   __func__, err);
 		return NULL;
 	}
@@ -696,7 +696,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
-			ND_PRINTK1(KERN_DEBUG "%s(): trying to ucast probe in NUD_INVALID: %pI6\n",
+			ND_PRINTK1(KERN_DEBUG "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				   __func__, target);
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
@@ -1230,7 +1230,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
 		if (!neigh) {
 			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s() got default router without neighbour.\n",
+				   "ICMPv6 RA: %s got default router without neighbour.\n",
 				   __func__);
 			dst_release(&rt->dst);
 			return;
@@ -1248,7 +1248,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		rt = rt6_add_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev, pref);
 		if (rt == NULL) {
 			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s() failed to add default route.\n",
+				   "ICMPv6 RA: %s failed to add default route.\n",
 				   __func__);
 			return;
 		}
@@ -1256,7 +1256,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s() got default router without neighbour.\n",
+				   "ICMPv6 RA: %s got default router without neighbour.\n",
 				   __func__);
 			dst_release(&rt->dst);
 			return;
@@ -1605,7 +1605,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 Redirect: %s() failed to allocate an skb, err=%d.\n",
+			   "ICMPv6 Redirect: %s failed to allocate an skb, err=%d.\n",
 			   __func__, err);
 		goto release;
 	}
@@ -1767,11 +1767,7 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 	static int warned;
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm, current->comm);
-		printk(KERN_WARNING
-			"process `%s' is using deprecated sysctl (%s) "
-			"net.ipv6.neigh.%s.%s; "
-			"Use net.ipv6.neigh.%s.%s_ms "
-			"instead.\n",
+		pr_warn("process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead\n",
 			warncomm, func,
 			dev_name, ctl->procname,
 			dev_name, ctl->procname);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e20e320..90119a3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -24,6 +24,8 @@
  *		Fixed routing subtrees.
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/capability.h>
 #include <linux/errno.h>
 #include <linux/export.h>
@@ -794,7 +796,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 				goto retry;
 			}
 
-			net_warn_ratelimited("ipv6: Neighbour table overflow\n");
+			net_warn_ratelimited("Neighbour table overflow\n");
 			dst_free(&rt->dst);
 			return NULL;
 		}
@@ -1280,7 +1282,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	    !(cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_CREATE)) {
 		table = fib6_get_table(net, cfg->fc_table);
 		if (!table) {
-			printk(KERN_WARNING "IPv6: NLM_F_CREATE should be specified when creating new route\n");
+			pr_warn("NLM_F_CREATE should be specified when creating new route\n");
 			table = fib6_new_table(net, cfg->fc_table);
 		}
 	} else {
@@ -2102,7 +2104,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	int err;
 
 	if (!rt) {
-		net_warn_ratelimited("IPv6:  Maximum number of routes reached, consider increasing route/max_size\n");
+		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a36a097..6041571 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -17,6 +17,8 @@
  * Fred Templin <fred.l.templin@boeing.com>:	isatap support
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/errno.h>
@@ -1301,7 +1303,7 @@ static int __init sit_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "IPv6 over IPv4 tunneling driver\n");
+	pr_info("IPv6 over IPv4 tunneling driver\n");
 
 	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
@@ -1309,7 +1311,7 @@ static int __init sit_init(void)
 	err = xfrm4_tunnel_register(&sit_handler, AF_INET6);
 	if (err < 0) {
 		unregister_pernet_device(&sit_net_ops);
-		printk(KERN_INFO "sit init: Can't add protocol\n");
+		pr_info("%s: can't add protocol\n", __func__);
 	}
 	return err;
 }
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 4f3cec1..4b0f50d 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -19,6 +19,8 @@
  * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  */
 
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/icmpv6.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -160,11 +162,11 @@ static const struct inet6_protocol tunnel46_protocol = {
 static int __init tunnel6_init(void)
 {
 	if (inet6_add_protocol(&tunnel6_protocol, IPPROTO_IPV6)) {
-		printk(KERN_ERR "tunnel6 init(): can't add protocol\n");
+		pr_err("%s: can't add protocol\n", __func__);
 		return -EAGAIN;
 	}
 	if (inet6_add_protocol(&tunnel46_protocol, IPPROTO_IPIP)) {
-		printk(KERN_ERR "tunnel6 init(): can't add protocol\n");
+		pr_err("%s: can't add protocol\n", __func__);
 		inet6_del_protocol(&tunnel6_protocol, IPPROTO_IPV6);
 		return -EAGAIN;
 	}
@@ -174,9 +176,9 @@ static int __init tunnel6_init(void)
 static void __exit tunnel6_fini(void)
 {
 	if (inet6_del_protocol(&tunnel46_protocol, IPPROTO_IPIP))
-		printk(KERN_ERR "tunnel6 close: can't remove protocol\n");
+		pr_err("%s: can't remove protocol\n", __func__);
 	if (inet6_del_protocol(&tunnel6_protocol, IPPROTO_IPV6))
-		printk(KERN_ERR "tunnel6 close: can't remove protocol\n");
+		pr_err("%s: can't remove protocol\n", __func__);
 }
 
 module_init(tunnel6_init);
-- 
1.7.8.111.gad25c.dirty
