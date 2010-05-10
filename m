From: kaber@trash.net
Subject: [PATCH 32/84] netfilter: xt extensions: use pr_<level> (2)
Date: Mon, 10 May 2010 22:18:03 +0200
Message-ID: <1273522735-24672-33-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746Ab0EJUTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:06 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Supplement to 1159683ef48469de71dc26f0ee1a9c30d131cf89.

Downgrade the log level to INFO for most checkentry messages as they
are, IMO, just an extra information to the -EINVAL code that is
returned as part of a parameter "constraint violation". Leave errors
to real errors, such as being unable to create a LED trigger.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/netfilter/ebt_among.c    |   15 +++++-------
 net/bridge/netfilter/ebt_limit.c    |    3 +-
 net/bridge/netfilter/ebt_ulog.c     |   23 +++++++-----------
 net/bridge/netfilter/ebt_vlan.c     |   36 ++++++++++-------------------
 net/bridge/netfilter/ebtables.c     |    5 +--
 net/ipv4/netfilter/ip_tables.c      |   18 ++++++--------
 net/ipv4/netfilter/ipt_CLUSTERIP.c  |   42 +++++++++++++++++-----------------
 net/ipv4/netfilter/ipt_ECN.c        |   11 +++-----
 net/ipv4/netfilter/ipt_LOG.c        |    7 ++---
 net/ipv4/netfilter/ipt_MASQUERADE.c |    8 +++---
 net/ipv4/netfilter/ipt_NETMAP.c     |    6 ++--
 net/ipv4/netfilter/ipt_REDIRECT.c   |    6 ++--
 net/ipv4/netfilter/ipt_REJECT.c     |    6 ++--
 net/ipv4/netfilter/ipt_ULOG.c       |   37 ++++++++++++------------------
 net/ipv4/netfilter/ipt_addrtype.c   |   14 +++++-----
 net/ipv4/netfilter/ipt_ecn.c        |    5 +--
 net/ipv4/netfilter/nf_nat_rule.c    |    5 ++-
 net/ipv6/netfilter/ip6_tables.c     |    9 +++----
 net/ipv6/netfilter/ip6t_LOG.c       |    7 ++---
 net/ipv6/netfilter/ip6t_REJECT.c    |   20 ++++++++--------
 net/ipv6/netfilter/ip6t_ah.c        |    6 ++--
 net/ipv6/netfilter/ip6t_frag.c      |    6 ++--
 net/ipv6/netfilter/ip6t_hbh.c       |    6 ++--
 net/ipv6/netfilter/ip6t_rt.c        |    6 ++--
 net/netfilter/xt_TCPMSS.c           |    7 ++---
 net/netfilter/xt_TPROXY.c           |    4 +-
 net/netfilter/xt_esp.c              |    2 +-
 net/netfilter/xt_iprange.c          |    1 +
 net/netfilter/xt_recent.c           |    6 ++--
 net/netfilter/xt_socket.c           |    5 +--
 net/netfilter/xt_time.c             |    4 +-
 31 files changed, 151 insertions(+), 185 deletions(-)

diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index b595f09..60ad630 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -7,6 +7,7 @@
  *  August, 2003
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/ip.h>
 #include <linux/if_arp.h>
 #include <linux/module.h>
@@ -186,21 +187,17 @@ static bool ebt_among_mt_check(const struct xt_mtchk_param *par)
 	expected_length += ebt_mac_wormhash_size(wh_src);
 
 	if (em->match_size != EBT_ALIGN(expected_length)) {
-		printk(KERN_WARNING
-		       "ebtables: among: wrong size: %d "
-		       "against expected %d, rounded to %Zd\n",
-		       em->match_size, expected_length,
-		       EBT_ALIGN(expected_length));
+		pr_info("wrong size: %d against expected %d, rounded to %Zd\n",
+			em->match_size, expected_length,
+			EBT_ALIGN(expected_length));
 		return false;
 	}
 	if (wh_dst && (err = ebt_mac_wormhash_check_integrity(wh_dst))) {
-		printk(KERN_WARNING
-		       "ebtables: among: dst integrity fail: %x\n", -err);
+		pr_info("dst integrity fail: %x\n", -err);
 		return false;
 	}
 	if (wh_src && (err = ebt_mac_wormhash_check_integrity(wh_src))) {
-		printk(KERN_WARNING
-		       "ebtables: among: src integrity fail: %x\n", -err);
+		pr_info("src integrity fail: %x\n", -err);
 		return false;
 	}
 	return true;
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index 7a81827..5b7330b 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -10,6 +10,7 @@
  *  September, 2003
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
@@ -71,7 +72,7 @@ static bool ebt_limit_mt_check(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (info->burst == 0 ||
 	    user2credits(info->avg * info->burst) < user2credits(info->avg)) {
-		printk("Overflow in ebt_limit, try lower: %u/%u\n",
+		pr_info("overflow, try lower: %u/%u\n",
 			info->avg, info->burst);
 		return false;
 	}
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 84340ab..789ea36 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -27,7 +27,7 @@
  *   flushed even if it is not full yet.
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/socket.h>
@@ -43,9 +43,6 @@
 #include <net/sock.h>
 #include "../br_private.h"
 
-#define PRINTR(format, args...) do { if (net_ratelimit()) \
-				printk(format , ## args); } while (0)
-
 static unsigned int nlbufsiz = NLMSG_GOODSIZE;
 module_param(nlbufsiz, uint, 0600);
 MODULE_PARM_DESC(nlbufsiz, "netlink buffer size (number of bytes) "
@@ -106,15 +103,14 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	n = max(size, nlbufsiz);
 	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
-		PRINTR(KERN_ERR "ebt_ulog: can't alloc whole buffer "
-		       "of size %ub!\n", n);
+		pr_debug("cannot alloc whole buffer of size %ub!\n", n);
 		if (n > size) {
 			/* try to allocate only as much as we need for
 			 * current packet */
 			skb = alloc_skb(size, GFP_ATOMIC);
 			if (!skb)
-				PRINTR(KERN_ERR "ebt_ulog: can't even allocate "
-				       "buffer of size %ub\n", size);
+				pr_debug("cannot even allocate "
+					 "buffer of size %ub\n", size);
 		}
 	}
 
@@ -141,8 +137,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 
 	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
 	if (size > nlbufsiz) {
-		PRINTR("ebt_ulog: Size %Zd needed, but nlbufsiz=%d\n",
-		       size, nlbufsiz);
+		pr_debug("Size %Zd needed, but nlbufsiz=%d\n", size, nlbufsiz);
 		return;
 	}
 
@@ -216,8 +211,8 @@ unlock:
 	return;
 
 nlmsg_failure:
-	printk(KERN_CRIT "ebt_ulog: error during NLMSG_PUT. This should "
-	       "not happen, please report to author.\n");
+	pr_debug("error during NLMSG_PUT. This should "
+		 "not happen, please report to author.\n");
 	goto unlock;
 alloc_failure:
 	goto unlock;
@@ -291,8 +286,8 @@ static int __init ebt_ulog_init(void)
 	int i;
 
 	if (nlbufsiz >= 128*1024) {
-		printk(KERN_NOTICE "ebt_ulog: Netlink buffer has to be <= 128kB,"
-		       " please try a smaller nlbufsiz parameter.\n");
+		pr_warning("Netlink buffer has to be <= 128kB,"
+			   " please try a smaller nlbufsiz parameter.\n");
 		return -EINVAL;
 	}
 
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index be1dd2e..5c44f51 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -26,17 +26,12 @@
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_vlan.h>
 
-static int debug;
 #define MODULE_VERS "0.6"
 
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "debug=1 is turn on debug messages");
 MODULE_AUTHOR("Nick Fedchik <nick@fedchik.org.ua>");
 MODULE_DESCRIPTION("Ebtables: 802.1Q VLAN tag match");
 MODULE_LICENSE("GPL");
 
-
-#define DEBUG_MSG(args...) if (debug) printk (KERN_DEBUG "ebt_vlan: " args)
 #define GET_BITMASK(_BIT_MASK_) info->bitmask & _BIT_MASK_
 #define EXIT_ON_MISMATCH(_MATCH_,_MASK_) {if (!((info->_MATCH_ == _MATCH_)^!!(info->invflags & _MASK_))) return false; }
 
@@ -91,24 +86,23 @@ static bool ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 
 	/* Is it 802.1Q frame checked? */
 	if (e->ethproto != htons(ETH_P_8021Q)) {
-		DEBUG_MSG
-		    ("passed entry proto %2.4X is not 802.1Q (8100)\n",
-		     (unsigned short) ntohs(e->ethproto));
+		pr_debug("passed entry proto %2.4X is not 802.1Q (8100)\n",
+			 ntohs(e->ethproto));
 		return false;
 	}
 
 	/* Check for bitmask range
 	 * True if even one bit is out of mask */
 	if (info->bitmask & ~EBT_VLAN_MASK) {
-		DEBUG_MSG("bitmask %2X is out of mask (%2X)\n",
-			  info->bitmask, EBT_VLAN_MASK);
+		pr_debug("bitmask %2X is out of mask (%2X)\n",
+			 info->bitmask, EBT_VLAN_MASK);
 		return false;
 	}
 
 	/* Check for inversion flags range */
 	if (info->invflags & ~EBT_VLAN_MASK) {
-		DEBUG_MSG("inversion flags %2X is out of mask (%2X)\n",
-			  info->invflags, EBT_VLAN_MASK);
+		pr_debug("inversion flags %2X is out of mask (%2X)\n",
+			 info->invflags, EBT_VLAN_MASK);
 		return false;
 	}
 
@@ -121,9 +115,8 @@ static bool ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	if (GET_BITMASK(EBT_VLAN_ID)) {
 		if (!!info->id) { /* if id!=0 => check vid range */
 			if (info->id > VLAN_GROUP_ARRAY_LEN) {
-				DEBUG_MSG
-				    ("id %d is out of range (1-4096)\n",
-				     info->id);
+				pr_debug("id %d is out of range (1-4096)\n",
+					 info->id);
 				return false;
 			}
 			/* Note: This is valid VLAN-tagged frame point.
@@ -137,8 +130,8 @@ static bool ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 
 	if (GET_BITMASK(EBT_VLAN_PRIO)) {
 		if ((unsigned char) info->prio > 7) {
-			DEBUG_MSG("prio %d is out of range (0-7)\n",
-			     info->prio);
+			pr_debug("prio %d is out of range (0-7)\n",
+				 info->prio);
 			return false;
 		}
 	}
@@ -147,9 +140,8 @@ static bool ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	 * if_ether.h:  ETH_ZLEN        60   -  Min. octets in frame sans FCS */
 	if (GET_BITMASK(EBT_VLAN_ENCAP)) {
 		if ((unsigned short) ntohs(info->encap) < ETH_ZLEN) {
-			DEBUG_MSG
-			    ("encap frame length %d is less than minimal\n",
-			     ntohs(info->encap));
+			pr_debug("encap frame length %d is less than "
+				 "minimal\n", ntohs(info->encap));
 			return false;
 		}
 	}
@@ -169,9 +161,7 @@ static struct xt_match ebt_vlan_mt_reg __read_mostly = {
 
 static int __init ebt_vlan_init(void)
 {
-	DEBUG_MSG("ebtables 802.1Q extension module v"
-		  MODULE_VERS "\n");
-	DEBUG_MSG("module debug=%d\n", !!debug);
+	pr_debug("ebtables 802.1Q extension module v" MODULE_VERS "\n");
 	return xt_register_match(&ebt_vlan_mt_reg);
 }
 
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index dfb5805..989d72c 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -14,8 +14,7 @@
  *  as published by the Free Software Foundation; either version
  *  2 of the License, or (at your option) any later version.
  */
-
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kmod.h>
 #include <linux/module.h>
 #include <linux/vmalloc.h>
@@ -2127,7 +2126,7 @@ static int size_entry_mwt(struct ebt_entry *entry, const unsigned char *base,
 			return ret;
 		new_offset += ret;
 		if (offsets_update && new_offset) {
-			pr_debug("ebtables: change offset %d to %d\n",
+			pr_debug("change offset %d to %d\n",
 				offsets_update[i], offsets[j] + new_offset);
 			offsets_update[i] = offsets[j] + new_offset;
 		}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b29c66d..73fdf20 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -39,13 +39,13 @@ MODULE_DESCRIPTION("IPv4 packet filter");
 /*#define DEBUG_IP_FIREWALL_USER*/
 
 #ifdef DEBUG_IP_FIREWALL
-#define dprintf(format, args...)  printk(format , ## args)
+#define dprintf(format, args...) pr_info(format , ## args)
 #else
 #define dprintf(format, args...)
 #endif
 
 #ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) printk(format , ## args)
+#define duprintf(format, args...) pr_info(format , ## args)
 #else
 #define duprintf(format, args...)
 #endif
@@ -168,8 +168,7 @@ static unsigned int
 ipt_error(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	if (net_ratelimit())
-		printk("ip_tables: error: `%s'\n",
-		       (const char *)par->targinfo);
+		pr_info("error: `%s'\n", (const char *)par->targinfo);
 
 	return NF_DROP;
 }
@@ -591,7 +590,7 @@ check_entry(const struct ipt_entry *e, const char *name)
 	const struct ipt_entry_target *t;
 
 	if (!ip_checkentry(&e->ip)) {
-		duprintf("ip_tables: ip check failed %p %s.\n", e, name);
+		duprintf("ip check failed %p %s.\n", e, name);
 		return -EINVAL;
 	}
 
@@ -618,8 +617,7 @@ check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 	ret = xt_check_match(par, m->u.match_size - sizeof(*m),
 	      ip->proto, ip->invflags & IPT_INV_PROTO);
 	if (ret < 0) {
-		duprintf("ip_tables: check failed for `%s'.\n",
-			 par.match->name);
+		duprintf("check failed for `%s'.\n", par.match->name);
 		return ret;
 	}
 	return 0;
@@ -667,7 +665,7 @@ static int check_target(struct ipt_entry *e, struct net *net, const char *name)
 	ret = xt_check_target(&par, t->u.target_size - sizeof(*t),
 	      e->ip.proto, e->ip.invflags & IPT_INV_PROTO);
 	if (ret < 0) {
-		duprintf("ip_tables: check failed for `%s'.\n",
+		duprintf("check failed for `%s'.\n",
 			 t->u.kernel.target->name);
 		return ret;
 	}
@@ -1311,7 +1309,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("ip_tables: Translated table\n");
+	duprintf("Translated table\n");
 
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, tmp.counters);
@@ -2276,7 +2274,7 @@ static int __init ip_tables_init(void)
 	if (ret < 0)
 		goto err5;
 
-	printk(KERN_INFO "ip_tables: (C) 2000-2006 Netfilter Core Team\n");
+	pr_info("(C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 
 err5:
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index a20bee7..fcaa0dc 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -9,6 +9,7 @@
  * published by the Free Software Foundation.
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/proc_fs.h>
 #include <linux/jhash.h>
@@ -238,8 +239,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 		break;
 	default:
 		if (net_ratelimit())
-			printk(KERN_NOTICE "CLUSTERIP: unknown protocol `%u'\n",
-				iph->protocol);
+			pr_info("unknown protocol %u\n", iph->protocol);
 		sport = dport = 0;
 	}
 
@@ -261,7 +261,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 		hashval = 0;
 		/* This cannot happen, unless the check function wasn't called
 		 * at rule load time */
-		printk("CLUSTERIP: unknown mode `%u'\n", config->hash_mode);
+		pr_info("unknown mode %u\n", config->hash_mode);
 		BUG();
 		break;
 	}
@@ -294,7 +294,7 @@ clusterip_tg(struct sk_buff *skb, const struct xt_target_param *par)
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct == NULL) {
-		printk(KERN_ERR "CLUSTERIP: no conntrack!\n");
+		pr_info("no conntrack!\n");
 			/* FIXME: need to drop invalid ones, since replies
 			 * to outgoing connections of other nodes will be
 			 * marked as INVALID */
@@ -357,14 +357,13 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 	if (cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT_DPT) {
-		printk(KERN_WARNING "CLUSTERIP: unknown mode `%u'\n",
-			cipinfo->hash_mode);
+		pr_info("unknown mode %u\n", cipinfo->hash_mode);
 		return false;
 
 	}
 	if (e->ip.dmsk.s_addr != htonl(0xffffffff) ||
 	    e->ip.dst.s_addr == 0) {
-		printk(KERN_ERR "CLUSTERIP: Please specify destination IP\n");
+		pr_info("Please specify destination IP\n");
 		return false;
 	}
 
@@ -373,26 +372,28 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 	config = clusterip_config_find_get(e->ip.dst.s_addr, 1);
 	if (!config) {
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
-			printk(KERN_WARNING "CLUSTERIP: no config found for %pI4, need 'new'\n", &e->ip.dst.s_addr);
+			pr_info("no config found for %pI4, need 'new'\n",
+				&e->ip.dst.s_addr);
 			return false;
 		} else {
 			struct net_device *dev;
 
 			if (e->ip.iniface[0] == '\0') {
-				printk(KERN_WARNING "CLUSTERIP: Please specify an interface name\n");
+				pr_info("Please specify an interface name\n");
 				return false;
 			}
 
 			dev = dev_get_by_name(&init_net, e->ip.iniface);
 			if (!dev) {
-				printk(KERN_WARNING "CLUSTERIP: no such interface %s\n", e->ip.iniface);
+				pr_info("no such interface %s\n",
+					e->ip.iniface);
 				return false;
 			}
 
 			config = clusterip_config_init(cipinfo,
 							e->ip.dst.s_addr, dev);
 			if (!config) {
-				printk(KERN_WARNING "CLUSTERIP: cannot allocate config\n");
+				pr_info("cannot allocate config\n");
 				dev_put(dev);
 				return false;
 			}
@@ -402,8 +403,8 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 	cipinfo->config = config;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 
@@ -478,8 +479,8 @@ static void arp_print(struct arp_payload *payload)
 	}
 	hbuffer[--k]='\0';
 
-	printk("src %pI4@%s, dst %pI4\n",
-		&payload->src_ip, hbuffer, &payload->dst_ip);
+	pr_debug("src %pI4@%s, dst %pI4\n",
+		 &payload->src_ip, hbuffer, &payload->dst_ip);
 }
 #endif
 
@@ -518,7 +519,7 @@ arp_mangle(unsigned int hook,
 	 * this wouldn't work, since we didn't subscribe the mcast group on
 	 * other interfaces */
 	if (c->dev != out) {
-		pr_debug("CLUSTERIP: not mangling arp reply on different "
+		pr_debug("not mangling arp reply on different "
 			 "interface: cip'%s'-skb'%s'\n",
 			 c->dev->name, out->name);
 		clusterip_config_put(c);
@@ -529,7 +530,7 @@ arp_mangle(unsigned int hook,
 	memcpy(payload->src_hw, c->clustermac, arp->ar_hln);
 
 #ifdef DEBUG
-	pr_debug(KERN_DEBUG "CLUSTERIP mangled arp reply: ");
+	pr_debug("mangled arp reply: ");
 	arp_print(payload);
 #endif
 
@@ -705,13 +706,13 @@ static int __init clusterip_tg_init(void)
 #ifdef CONFIG_PROC_FS
 	clusterip_procdir = proc_mkdir("ipt_CLUSTERIP", init_net.proc_net);
 	if (!clusterip_procdir) {
-		printk(KERN_ERR "CLUSTERIP: Unable to proc dir entry\n");
+		pr_err("Unable to proc dir entry\n");
 		ret = -ENOMEM;
 		goto cleanup_hook;
 	}
 #endif /* CONFIG_PROC_FS */
 
-	printk(KERN_NOTICE "ClusterIP Version %s loaded successfully\n",
+	pr_info("ClusterIP Version %s loaded successfully\n",
 		CLUSTERIP_VERSION);
 	return 0;
 
@@ -726,8 +727,7 @@ cleanup_target:
 
 static void __exit clusterip_tg_exit(void)
 {
-	printk(KERN_NOTICE "ClusterIP Version %s unloading\n",
-		CLUSTERIP_VERSION);
+	pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry(clusterip_procdir->name, clusterip_procdir->parent);
 #endif
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index ea5cea2..0198875 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
 */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -99,19 +99,16 @@ static bool ecn_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_entry *e = par->entryinfo;
 
 	if (einfo->operation & IPT_ECN_OP_MASK) {
-		printk(KERN_WARNING "ECN: unsupported ECN operation %x\n",
-			einfo->operation);
+		pr_info("unsupported ECN operation %x\n", einfo->operation);
 		return false;
 	}
 	if (einfo->ip_ect & ~IPT_ECN_IP_MASK) {
-		printk(KERN_WARNING "ECN: new ECT codepoint %x out of mask\n",
-			einfo->ip_ect);
+		pr_info("new ECT codepoint %x out of mask\n", einfo->ip_ect);
 		return false;
 	}
 	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR)) &&
 	    (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
-		printk(KERN_WARNING "ECN: cannot use TCP operations on a "
-		       "non-tcp rule\n");
+		pr_info("cannot use TCP operations on a non-tcp rule\n");
 		return false;
 	}
 	return true;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index ee128ef..b3bf623 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -444,12 +444,11 @@ static bool log_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_log_info *loginfo = par->targinfo;
 
 	if (loginfo->level >= 8) {
-		pr_debug("LOG: level %u >= 8\n", loginfo->level);
+		pr_debug("level %u >= 8\n", loginfo->level);
 		return false;
 	}
 	if (loginfo->prefix[sizeof(loginfo->prefix)-1] != '\0') {
-		pr_debug("LOG: prefix term %i\n",
-			 loginfo->prefix[sizeof(loginfo->prefix)-1]);
+		pr_debug("prefix is not null-terminated\n");
 		return false;
 	}
 	return true;
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 650b540..5063dda 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -8,7 +8,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/inetdevice.h>
 #include <linux/ip.h>
@@ -33,11 +33,11 @@ static bool masquerade_tg_check(const struct xt_tgchk_param *par)
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
 	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
-		pr_debug("masquerade_check: bad MAP_IPS.\n");
+		pr_debug("bad MAP_IPS.\n");
 		return false;
 	}
 	if (mr->rangesize != 1) {
-		pr_debug("masquerade_check: bad rangesize %u\n", mr->rangesize);
+		pr_debug("bad rangesize %u\n", mr->rangesize);
 		return false;
 	}
 	return true;
@@ -72,7 +72,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	rt = skb_rtable(skb);
 	newsrc = inet_select_addr(par->out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
-		printk("MASQUERADE: %s ate my IP address\n", par->out->name);
+		pr_info("%s ate my IP address\n", par->out->name);
 		return NF_DROP;
 	}
 
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index 7c29582..51ab01a 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -27,11 +27,11 @@ static bool netmap_tg_check(const struct xt_tgchk_param *par)
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
 	if (!(mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)) {
-		pr_debug("NETMAP:check: bad MAP_IPS.\n");
+		pr_debug("bad MAP_IPS.\n");
 		return false;
 	}
 	if (mr->rangesize != 1) {
-		pr_debug("NETMAP:check: bad rangesize %u.\n", mr->rangesize);
+		pr_debug("bad rangesize %u.\n", mr->rangesize);
 		return false;
 	}
 	return true;
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 698e5e7..74f1f55 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/ip.h>
 #include <linux/timer.h>
@@ -31,11 +31,11 @@ static bool redirect_tg_check(const struct xt_tgchk_param *par)
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
 	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
-		pr_debug("redirect_check: bad MAP_IPS.\n");
+		pr_debug("bad MAP_IPS.\n");
 		return false;
 	}
 	if (mr->rangesize != 1) {
-		pr_debug("redirect_check: bad rangesize %u.\n", mr->rangesize);
+		pr_debug("bad rangesize %u.\n", mr->rangesize);
 		return false;
 	}
 	return true;
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 5113b8f..ff32252 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -180,13 +180,13 @@ static bool reject_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_entry *e = par->entryinfo;
 
 	if (rejinfo->with == IPT_ICMP_ECHOREPLY) {
-		printk("ipt_REJECT: ECHOREPLY no longer supported.\n");
+		pr_info("ECHOREPLY no longer supported.\n");
 		return false;
 	} else if (rejinfo->with == IPT_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
 		if (e->ip.proto != IPPROTO_TCP ||
 		    (e->ip.invflags & XT_INV_PROTO)) {
-			printk("ipt_REJECT: TCP_RESET invalid for non-tcp\n");
+			pr_info("TCP_RESET invalid for non-tcp\n");
 			return false;
 		}
 	}
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 09a5d3f..d926201 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -29,7 +29,7 @@
  *   Specify, after how many hundredths of a second the queue should be
  *   flushed even if it is not full yet.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/socket.h>
@@ -56,8 +56,6 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NFLOG);
 #define ULOG_NL_EVENT		111		/* Harald's favorite number */
 #define ULOG_MAXNLGROUPS	32		/* numer of nlgroups */
 
-#define PRINTR(format, args...) do { if (net_ratelimit()) printk(format , ## args); } while (0)
-
 static unsigned int nlbufsiz = NLMSG_GOODSIZE;
 module_param(nlbufsiz, uint, 0400);
 MODULE_PARM_DESC(nlbufsiz, "netlink buffer size");
@@ -90,12 +88,12 @@ static void ulog_send(unsigned int nlgroupnum)
 	ulog_buff_t *ub = &ulog_buffers[nlgroupnum];
 
 	if (timer_pending(&ub->timer)) {
-		pr_debug("ipt_ULOG: ulog_send: timer was pending, deleting\n");
+		pr_debug("ulog_send: timer was pending, deleting\n");
 		del_timer(&ub->timer);
 	}
 
 	if (!ub->skb) {
-		pr_debug("ipt_ULOG: ulog_send: nothing to send\n");
+		pr_debug("ulog_send: nothing to send\n");
 		return;
 	}
 
@@ -104,7 +102,7 @@ static void ulog_send(unsigned int nlgroupnum)
 		ub->lastnlh->nlmsg_type = NLMSG_DONE;
 
 	NETLINK_CB(ub->skb).dst_group = nlgroupnum + 1;
-	pr_debug("ipt_ULOG: throwing %d packets to netlink group %u\n",
+	pr_debug("throwing %d packets to netlink group %u\n",
 		 ub->qlen, nlgroupnum + 1);
 	netlink_broadcast(nflognl, ub->skb, 0, nlgroupnum + 1, GFP_ATOMIC);
 
@@ -117,7 +115,7 @@ static void ulog_send(unsigned int nlgroupnum)
 /* timer function to flush queue in flushtimeout time */
 static void ulog_timer(unsigned long data)
 {
-	pr_debug("ipt_ULOG: timer function called, calling ulog_send\n");
+	pr_debug("timer function called, calling ulog_send\n");
 
 	/* lock to protect against somebody modifying our structure
 	 * from ipt_ulog_target at the same time */
@@ -138,7 +136,7 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	n = max(size, nlbufsiz);
 	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
-		PRINTR("ipt_ULOG: can't alloc whole buffer %ub!\n", n);
+		pr_debug("cannot alloc whole buffer %ub!\n", n);
 
 		if (n > size) {
 			/* try to allocate only as much as we need for
@@ -146,8 +144,7 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 
 			skb = alloc_skb(size, GFP_ATOMIC);
 			if (!skb)
-				PRINTR("ipt_ULOG: can't even allocate %ub\n",
-				       size);
+				pr_debug("cannot even allocate %ub\n", size);
 		}
 	}
 
@@ -198,8 +195,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 			goto alloc_failure;
 	}
 
-	pr_debug("ipt_ULOG: qlen %d, qthreshold %Zu\n", ub->qlen,
-		 loginfo->qthreshold);
+	pr_debug("qlen %d, qthreshold %Zu\n", ub->qlen, loginfo->qthreshold);
 
 	/* NLMSG_PUT contains a hidden goto nlmsg_failure !!! */
 	nlh = NLMSG_PUT(ub->skb, 0, ub->qlen, ULOG_NL_EVENT,
@@ -272,11 +268,9 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	return;
 
 nlmsg_failure:
-	PRINTR("ipt_ULOG: error during NLMSG_PUT\n");
-
+	pr_debug("error during NLMSG_PUT\n");
 alloc_failure:
-	PRINTR("ipt_ULOG: Error building netlink message\n");
-
+	pr_debug("Error building netlink message\n");
 	spin_unlock_bh(&ulog_lock);
 }
 
@@ -318,12 +312,11 @@ static bool ulog_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_ulog_info *loginfo = par->targinfo;
 
 	if (loginfo->prefix[sizeof(loginfo->prefix) - 1] != '\0') {
-		pr_debug("ipt_ULOG: prefix term %i\n",
-			 loginfo->prefix[sizeof(loginfo->prefix) - 1]);
+		pr_debug("prefix not null-terminated\n");
 		return false;
 	}
 	if (loginfo->qthreshold > ULOG_MAX_QLEN) {
-		pr_debug("ipt_ULOG: queue threshold %Zu > MAX_QLEN\n",
+		pr_debug("queue threshold %Zu > MAX_QLEN\n",
 			 loginfo->qthreshold);
 		return false;
 	}
@@ -389,10 +382,10 @@ static int __init ulog_tg_init(void)
 {
 	int ret, i;
 
-	pr_debug("ipt_ULOG: init module\n");
+	pr_debug("init module\n");
 
 	if (nlbufsiz > 128*1024) {
-		printk("Netlink buffer has to be <= 128kB\n");
+		pr_warning("Netlink buffer has to be <= 128kB\n");
 		return -EINVAL;
 	}
 
@@ -422,7 +415,7 @@ static void __exit ulog_tg_exit(void)
 	ulog_buff_t *ub;
 	int i;
 
-	pr_debug("ipt_ULOG: cleanup_module\n");
+	pr_debug("cleanup_module\n");
 
 	if (nflog)
 		nf_log_unregister(&ipt_ulog_logger);
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index 3b216be..ea4f58a 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -8,7 +8,7 @@
  *  it under the terms of the GNU General Public License version 2 as
  *  published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -76,24 +76,24 @@ static bool addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 
 	if (info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN &&
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
-		printk(KERN_ERR "ipt_addrtype: both incoming and outgoing "
-				"interface limitation cannot be selected\n");
+		pr_info("both incoming and outgoing "
+			"interface limitation cannot be selected\n");
 		return false;
 	}
 
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
 	    (1 << NF_INET_LOCAL_IN)) &&
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
-		printk(KERN_ERR "ipt_addrtype: output interface limitation "
-				"not valid in PRE_ROUTING and INPUT\n");
+		pr_info("output interface limitation "
+			"not valid in PREROUTING and INPUT\n");
 		return false;
 	}
 
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
 	    (1 << NF_INET_LOCAL_OUT)) &&
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN) {
-		printk(KERN_ERR "ipt_addrtype: input interface limitation "
-				"not valid in POST_ROUTING and OUTPUT\n");
+		pr_info("input interface limitation "
+			"not valid in POSTROUTING and OUTPUT\n");
 		return false;
 	}
 
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index 2a1e56b..e661108 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <net/ip.h>
@@ -98,8 +98,7 @@ static bool ecn_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR) &&
 	    ip->proto != IPPROTO_TCP) {
-		printk(KERN_WARNING "ipt_ecn: can't match TCP bits in rule for"
-		       " non-tcp packets\n");
+		pr_info("cannot match TCP bits in rule for non-tcp packets\n");
 		return false;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index ab74cc0..7d6345e 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -7,6 +7,7 @@
  */
 
 /* Everything about the rules for NAT. */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/ip.h>
 #include <linux/netfilter.h>
@@ -79,7 +80,7 @@ static bool ipt_snat_checkentry(const struct xt_tgchk_param *par)
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
-		printk("SNAT: multiple ranges no longer supported\n");
+		pr_info("SNAT: multiple ranges no longer supported\n");
 		return false;
 	}
 	return true;
@@ -91,7 +92,7 @@ static bool ipt_dnat_checkentry(const struct xt_tgchk_param *par)
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
-		printk("DNAT: multiple ranges no longer supported\n");
+		pr_info("DNAT: multiple ranges no longer supported\n");
 		return false;
 	}
 	return true;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 9210e31..1b2414e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -40,13 +40,13 @@ MODULE_DESCRIPTION("IPv6 packet filter");
 /*#define DEBUG_IP_FIREWALL_USER*/
 
 #ifdef DEBUG_IP_FIREWALL
-#define dprintf(format, args...)  printk(format , ## args)
+#define dprintf(format, args...) pr_info(format , ## args)
 #else
 #define dprintf(format, args...)
 #endif
 
 #ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) printk(format , ## args)
+#define duprintf(format, args...) pr_info(format , ## args)
 #else
 #define duprintf(format, args...)
 #endif
@@ -200,8 +200,7 @@ static unsigned int
 ip6t_error(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	if (net_ratelimit())
-		printk("ip6_tables: error: `%s'\n",
-		       (const char *)par->targinfo);
+		pr_info("error: `%s'\n", (const char *)par->targinfo);
 
 	return NF_DROP;
 }
@@ -2308,7 +2307,7 @@ static int __init ip6_tables_init(void)
 	if (ret < 0)
 		goto err5;
 
-	printk(KERN_INFO "ip6_tables: (C) 2000-2006 Netfilter Core Team\n");
+	pr_info("(C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 
 err5:
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index e16c0c7..5a79883 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
@@ -456,12 +456,11 @@ static bool log_tg6_check(const struct xt_tgchk_param *par)
 	const struct ip6t_log_info *loginfo = par->targinfo;
 
 	if (loginfo->level >= 8) {
-		pr_debug("LOG: level %u >= 8\n", loginfo->level);
+		pr_debug("level %u >= 8\n", loginfo->level);
 		return false;
 	}
 	if (loginfo->prefix[sizeof(loginfo->prefix)-1] != '\0') {
-		pr_debug("LOG: prefix term %i\n",
-			 loginfo->prefix[sizeof(loginfo->prefix)-1]);
+		pr_debug("prefix not null-terminated\n");
 		return false;
 	}
 	return true;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index dd8afba..45efb9f 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -14,7 +14,7 @@
  * as published by the Free Software Foundation; either version
  * 2 of the License, or (at your option) any later version.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/icmpv6.h>
@@ -49,7 +49,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 
 	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
 	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
-		pr_debug("ip6t_REJECT: addr is not unicast.\n");
+		pr_debug("addr is not unicast.\n");
 		return;
 	}
 
@@ -57,7 +57,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data), &proto);
 
 	if ((tcphoff < 0) || (tcphoff > oldskb->len)) {
-		pr_debug("ip6t_REJECT: Can't get TCP header.\n");
+		pr_debug("Cannot get TCP header.\n");
 		return;
 	}
 
@@ -65,7 +65,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 
 	/* IP header checks: fragment, too short. */
 	if (proto != IPPROTO_TCP || otcplen < sizeof(struct tcphdr)) {
-		pr_debug("ip6t_REJECT: proto(%d) != IPPROTO_TCP, "
+		pr_debug("proto(%d) != IPPROTO_TCP, "
 			 "or too short. otcplen = %d\n",
 			 proto, otcplen);
 		return;
@@ -76,14 +76,14 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 
 	/* No RST for RST. */
 	if (otcph.rst) {
-		pr_debug("ip6t_REJECT: RST is set\n");
+		pr_debug("RST is set\n");
 		return;
 	}
 
 	/* Check checksum. */
 	if (csum_ipv6_magic(&oip6h->saddr, &oip6h->daddr, otcplen, IPPROTO_TCP,
 			    skb_checksum(oldskb, tcphoff, otcplen, 0))) {
-		pr_debug("ip6t_REJECT: TCP checksum is invalid\n");
+		pr_debug("TCP checksum is invalid\n");
 		return;
 	}
 
@@ -107,7 +107,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 
 	if (!nskb) {
 		if (net_ratelimit())
-			printk("ip6t_REJECT: Can't alloc skb\n");
+			pr_debug("cannot alloc skb\n");
 		dst_release(dst);
 		return;
 	}
@@ -206,7 +206,7 @@ reject_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 		break;
 	default:
 		if (net_ratelimit())
-			printk(KERN_WARNING "ip6t_REJECT: case %u not handled yet\n", reject->with);
+			pr_info("case %u not handled yet\n", reject->with);
 		break;
 	}
 
@@ -219,13 +219,13 @@ static bool reject_tg6_check(const struct xt_tgchk_param *par)
 	const struct ip6t_entry *e = par->entryinfo;
 
 	if (rejinfo->with == IP6T_ICMP6_ECHOREPLY) {
-		printk("ip6t_REJECT: ECHOREPLY is not supported.\n");
+		pr_info("ECHOREPLY is not supported.\n");
 		return false;
 	} else if (rejinfo->with == IP6T_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
 		if (e->ipv6.proto != IPPROTO_TCP ||
 		    (e->ipv6.invflags & XT_INV_PROTO)) {
-			printk("ip6t_REJECT: TCP_RESET illegal for non-tcp\n");
+			pr_info("TCP_RESET illegal for non-tcp\n");
 			return false;
 		}
 	}
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index ac0b7c6..4429bfd 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -29,7 +29,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 {
 	bool r;
 
-	pr_debug("ah spi_match:%c 0x%x <= 0x%x <= 0x%x",
+	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
 		 invert ? '!' : ' ', min, spi, max);
 	r = (spi >= min && spi <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
@@ -92,7 +92,7 @@ static bool ah_mt6_check(const struct xt_mtchk_param *par)
 	const struct ip6t_ah *ahinfo = par->matchinfo;
 
 	if (ahinfo->invflags & ~IP6T_AH_INV_MASK) {
-		pr_debug("ip6t_ah: unknown flags %X\n", ahinfo->invflags);
+		pr_debug("unknown flags %X\n", ahinfo->invflags);
 		return false;
 	}
 	return true;
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 7b91c25..5c0da91 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
@@ -27,7 +27,7 @@ static inline bool
 id_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 {
 	bool r;
-	pr_debug("frag id_match:%c 0x%x <= 0x%x <= 0x%x", invert ? '!' : ' ',
+	pr_debug("id_match:%c 0x%x <= 0x%x <= 0x%x\n", invert ? '!' : ' ',
 		 min, id, max);
 	r = (id >= min && id <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
@@ -107,7 +107,7 @@ static bool frag_mt6_check(const struct xt_mtchk_param *par)
 	const struct ip6t_frag *fraginfo = par->matchinfo;
 
 	if (fraginfo->invflags & ~IP6T_FRAG_INV_MASK) {
-		pr_debug("ip6t_frag: unknown flags %X\n", fraginfo->invflags);
+		pr_debug("unknown flags %X\n", fraginfo->invflags);
 		return false;
 	}
 	return true;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index 82593c8..f4b7388 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
@@ -169,12 +169,12 @@ static bool hbh_mt6_check(const struct xt_mtchk_param *par)
 	const struct ip6t_opts *optsinfo = par->matchinfo;
 
 	if (optsinfo->invflags & ~IP6T_OPTS_INV_MASK) {
-		pr_debug("ip6t_opts: unknown flags %X\n", optsinfo->invflags);
+		pr_debug("unknown flags %X\n", optsinfo->invflags);
 		return false;
 	}
 
 	if (optsinfo->flags & IP6T_OPTS_NSTRICT) {
-		pr_debug("ip6t_opts: Not strict - not implemented");
+		pr_debug("Not strict - not implemented");
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index b77307f..c58d653 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
@@ -29,7 +29,7 @@ static inline bool
 segsleft_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 {
 	bool r;
-	pr_debug("rt segsleft_match:%c 0x%x <= 0x%x <= 0x%x",
+	pr_debug("segsleft_match:%c 0x%x <= 0x%x <= 0x%x\n",
 		 invert ? '!' : ' ', min, id, max);
 	r = (id >= min && id <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
@@ -188,7 +188,7 @@ static bool rt_mt6_check(const struct xt_mtchk_param *par)
 	const struct ip6t_rt *rtinfo = par->matchinfo;
 
 	if (rtinfo->invflags & ~IP6T_RT_INV_MASK) {
-		pr_debug("ip6t_rt: unknown flags %X\n", rtinfo->invflags);
+		pr_debug("unknown flags %X\n", rtinfo->invflags);
 		return false;
 	}
 	if ((rtinfo->flags & (IP6T_RT_RES | IP6T_RT_FST_MASK)) &&
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 2077da3..45161d9 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -67,15 +67,14 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			if (net_ratelimit())
-				pr_err("xt_TCPMSS: "
-				       "unknown or invalid path-MTU (%u)\n",
+				pr_err("unknown or invalid path-MTU (%u)\n",
 				       dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
 			if (net_ratelimit())
-				pr_err("xt_TCPMSS: unknown or "
-				       "invalid path-MTU (%u)\n", in_mtu);
+				pr_err("unknown or invalid path-MTU (%u)\n",
+				       in_mtu);
 			return -1;
 		}
 		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 1340c2f..e9244fd 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -9,7 +9,7 @@
  * published by the Free Software Foundation.
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -67,7 +67,7 @@ static bool tproxy_tg_check(const struct xt_tgchk_param *par)
 	    && !(i->invflags & IPT_INV_PROTO))
 		return true;
 
-	pr_info("xt_TPROXY: Can be used only in combination with "
+	pr_info("Can be used only in combination with "
 		"either -p tcp or -p udp\n");
 	return false;
 }
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index f9deecb..1a446d6 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -29,7 +29,7 @@ static inline bool
 spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 {
 	bool r;
-	pr_debug("esp spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
+	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
 		 invert ? '!' : ' ', min, spi, max);
 	r = (spi >= min && spi <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index ffc9638..8471d97 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -8,6 +8,7 @@
  *	it under the terms of the GNU General Public License version 2 as
  *	published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index aa9817e..72cbced 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -321,8 +321,8 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 		hash_rnd_inited = true;
 	}
 	if (info->check_set & ~XT_RECENT_VALID_FLAGS) {
-		pr_info(KBUILD_MODNAME ": Unsupported user space flags "
-			"(%08x)\n", info->check_set);
+		pr_info("Unsupported user space flags (%08x)\n",
+			info->check_set);
 		return false;
 	}
 	if (hweight8(info->check_set &
@@ -336,7 +336,7 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	if ((info->check_set & XT_RECENT_REAP) && !info->seconds)
 		return false;
 	if (info->hit_count > ip_pkt_list_tot) {
-		pr_info(KBUILD_MODNAME ": hitcount (%u) is larger than "
+		pr_info("hitcount (%u) is larger than "
 			"packets to be remembered (%u)\n",
 			info->hit_count, ip_pkt_list_tot);
 		return false;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 6a90256..a9b1686 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -9,7 +9,7 @@
  * published by the Free Software Foundation.
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -165,8 +165,7 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 			sk = NULL;
 	}
 
-	pr_debug("socket match: proto %u %08x:%u -> %08x:%u "
-		 "(orig %08x:%u) sock %p\n",
+	pr_debug("proto %u %08x:%u -> %08x:%u (orig %08x:%u) sock %p\n",
 		 protocol, ntohl(saddr), ntohs(sport),
 		 ntohl(daddr), ntohs(dport),
 		 ntohl(iph->daddr), hp ? ntohs(hp->dest) : 0, sk);
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 9a9c9a3..45ed05b 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -223,8 +223,8 @@ static bool time_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->daytime_start > XT_TIME_MAX_DAYTIME ||
 	    info->daytime_stop > XT_TIME_MAX_DAYTIME) {
-		printk(KERN_WARNING "xt_time: invalid argument - start or "
-		       "stop time greater than 23:59:59\n");
+		pr_info("invalid argument - start or "
+			"stop time greater than 23:59:59\n");
 		return false;
 	}
 
-- 
1.7.0.4

