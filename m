From: Dawid =?utf-8?q?Ci=C4=99=C5=BCarkiewicz?= <dpc@asn.pl>
Subject: [PATCH][ebtables][vlan] ebt_vlan_t target
Date: Wed, 5 Jul 2006 21:49:15 +0200
Message-ID: <200607052149.16473.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:28333 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S965011AbWGETtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 15:49:21 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
 my name is Dawid Ciezarkiewicz. As a part of my daily job I was to write 
kernel module for ebtables to let linux bridges change vlan ids in fly using 
logic provided by ebtables matches. After hours of tries and kernel learning, 
reading and googlin' I've finally come to the place where I've got working 
module that does what I want. I'm looking for comments of more advanced linux 
developers. Please note that this is my first linux patch I've ever made. 

Best regards,
Dawid





-------------------------------------------------- KERNEL PART:

diff -Nur linux-2.6.17.orig/include/linux/netfilter_bridge/ebt_vlan_t.h 
linux-2.6.17/include/linux/netfilter_bridge/ebt_vlan_t.h
--- linux-2.6.17.orig/include/linux/netfilter_bridge/ebt_vlan_t.h	1970-01-01 
01:00:00.000000000 +0100
+++ linux-2.6.17/include/linux/netfilter_bridge/ebt_vlan_t.h	2006-07-03 
21:29:50.000000000 +0200
@@ -0,0 +1,12 @@
+#ifndef __LINUX_BRIDGE_EBT_VLAN_T_H
+#define __LINUX_BRIDGE_EBT_VLAN_T_H
+
+struct ebt_vlan_t_info
+{
+	unsigned short id;
+	/* EBT_ACCEPT, EBT_DROP, EBT_CONTINUE or EBT_RETURN */
+	int target;
+};
+#define EBT_VLAN_TARGET "vlan_t"
+
+#endif
diff -Nur linux-2.6.17.orig/net/bridge/netfilter/Kconfig 
linux-2.6.17/net/bridge/netfilter/Kconfig
--- linux-2.6.17.orig/net/bridge/netfilter/Kconfig	2006-06-18 
03:49:35.000000000 +0200
+++ linux-2.6.17/net/bridge/netfilter/Kconfig	2006-06-28 20:48:27.000000000 
+0200
@@ -165,6 +165,15 @@

 	  To compile it as a module, choose M here.  If unsure, say N.

+config BRIDGE_EBT_VLAN_T
+	tristate "ebt: vlan target support"
+	depends on BRIDGE_NF_EBTABLES
+	help
+	  This option adds the vlan target.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+
 config BRIDGE_EBT_REDIRECT
 	tristate "ebt: redirect target support"
 	depends on BRIDGE_NF_EBTABLES
diff -Nur linux-2.6.17.orig/net/bridge/netfilter/Makefile 
linux-2.6.17/net/bridge/netfilter/Makefile
--- linux-2.6.17.orig/net/bridge/netfilter/Makefile	2006-06-18 
03:49:35.000000000 +0200
+++ linux-2.6.17/net/bridge/netfilter/Makefile	2006-06-28 22:05:52.000000000 
+0200
@@ -23,6 +23,7 @@
 # targets
 obj-$(CONFIG_BRIDGE_EBT_ARPREPLY) += ebt_arpreply.o
 obj-$(CONFIG_BRIDGE_EBT_MARK_T) += ebt_mark.o
+obj-$(CONFIG_BRIDGE_EBT_VLAN_T) += ebt_vlan_t.o
 obj-$(CONFIG_BRIDGE_EBT_DNAT) += ebt_dnat.o
 obj-$(CONFIG_BRIDGE_EBT_REDIRECT) += ebt_redirect.o
 obj-$(CONFIG_BRIDGE_EBT_SNAT) += ebt_snat.o
diff -Nur linux-2.6.17.orig/net/bridge/netfilter/ebt_vlan_t.c 
linux-2.6.17/net/bridge/netfilter/ebt_vlan_t.c
--- linux-2.6.17.orig/net/bridge/netfilter/ebt_vlan_t.c	1970-01-01 
01:00:00.000000000 +0100
+++ linux-2.6.17/net/bridge/netfilter/ebt_vlan_t.c	2006-07-05 
21:09:32.000000000 +0200
@@ -0,0 +1,154 @@
+/*
+ *  ebt_vlan target
+ *
+ *	Authors:
+ *	Dawid Ciezarkiewicz <dpc@asn.pl>
+ *
+ *  June, 2006
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_vlan_t.h>
+#include <linux/module.h>
+#include <linux/if_vlan.h>
+#include <linux/if_ether.h>
+#include <net/sock.h>
+
+static int ebt_target_vlan(struct sk_buff **pskb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_vlan_t_info *info = (struct ebt_vlan_t_info *)data;
+	struct vlan_hdr* vh, frame;
+	unsigned short vlan_TCI;
+	struct sk_buff *nskb;
+	int pskb_data_mod;
+	struct vlan_ethhdr * veth;
+
+	if ((*pskb)->protocol == __constant_htons(ETH_P_8021Q)) {
+		vh = skb_header_pointer(*pskb, 0, sizeof(frame), &frame);
+		vlan_TCI = ntohs (vh->h_vlan_TCI) & ~VLAN_VID_MASK;
+		vh->h_vlan_TCI = htons(vlan_TCI | info->id);
+	} else {
+		printk("vlan_t: no vlan pskb - creating...\n");
+
+		/*
+		 * If we are here we got (*pskb)->data pointing to
+		 * IMO strange place - right after protocol ID. If this
+		 * is layer2 filter shouldn't data point before mac
+		 * addresses?
+		 * I don't really know if messing with things before this
+		 * pointer (adding 2 bytes for vlan and moving everything)
+		 * is a hack.
+		 *
+		 * Anyway I see no other way. --dpc
+		 */
+
+		/* get our own packet */
+		if (skb_shared(*pskb) || skb_cloned(*pskb)) {
+			printk("skb_shared(*pskb) || skb_cloned(*pskb)\n");
+
+			nskb = skb_copy(*pskb, GFP_ATOMIC);
+			if (!nskb)
+				return EBT_DROP;
+			if ((*pskb)->sk)
+				skb_set_owner_w(nskb, (*pskb)->sk);
+			kfree_skb(*pskb);
+			*pskb = nskb;
+		}
+
+		/*
+		 * skb_headroom() uses skb->data pointer, we need to fix it
+		 * for a moment to check if we got 2 bytes in headspace left
+		 *
+		 * NOTE:
+		 * using pskb_data_mod is kind of assert - this should be optimized
+		 * in the future
+		 */
+		pskb_data_mod = (*pskb)->data - (*pskb)->mac.raw;
+		if (pskb_data_mod != 14) {
+			printk("vlan_t: no magic 14!\n");
+			return EBT_DROP;
+		}
+		(*pskb)->data = (*pskb)->mac.raw;
+		(*pskb)->len += pskb_data_mod;
+
+
+		if (skb_headroom(*pskb) < VLAN_HLEN) {
+			nskb = *pskb;
+			*pskb = skb_realloc_headroom(nskb, VLAN_HLEN);
+			if (*pskb == NULL) {
+				*pskb = nskb;
+				printk(KERN_ERR "vlan_t: failed to realloc headroom\n");
+				return EBT_DROP;
+			}
+			kfree_skb(nskb);
+		}
+
+		/* restore previous data pointer */
+		(*pskb)->data += pskb_data_mod;
+		(*pskb)->len  -= pskb_data_mod;
+
+		/* add space and shift data pointer to point right after 0x8100 */
+		skb_push(*pskb, VLAN_HLEN);
+
+		/* move mac pointer as well */
+		(*pskb)->mac.raw -= VLAN_HLEN;
+
+		veth = (struct vlan_ethhdr*)((*pskb)->mac.raw);
+
+		/* Move the mac addresses to the beginning of the new header. */
+		memmove(veth, veth + VLAN_HLEN, 2 * VLAN_ETH_ALEN);
+
+		/* first, the ethernet type */
+		veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
+
+		/* now, the tag */
+		veth->h_vlan_TCI = htons(info->id);
+
+		/* XXX: ke?! taken from __put_vlan_tag()
+		 * this header haven't moved anywhere ... */
+		/* skb->nh.raw -= VLAN_HLEN; */
+	}
+	return info->target;
+}
+
+static int ebt_target_vlan_check(const char *tablename, unsigned int 
hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_vlan_t_info *info = (struct ebt_vlan_t_info *)data;
+
+	if (datalen != EBT_ALIGN(sizeof(struct ebt_vlan_t_info)))
+		return -EINVAL;
+	if (info->id > 4095)
+		return -EINVAL;
+	if (BASE_CHAIN && info->target == EBT_RETURN)
+		return -EINVAL;
+	CLEAR_BASE_CHAIN_BIT;
+	if (INVALID_TARGET)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_target vlan_target =
+{
+	.name		= EBT_VLAN_TARGET,
+	.target		= ebt_target_vlan,
+	.check		= ebt_target_vlan_check,
+	.me		= THIS_MODULE,
+};
+
+static int __init ebt_vlan_init(void)
+{
+	return ebt_register_target(&vlan_target);
+}
+
+static void __exit ebt_vlan_fini(void)
+{
+	ebt_unregister_target(&vlan_target);
+}
+
+module_init(ebt_vlan_init);
+module_exit(ebt_vlan_fini);
+MODULE_LICENSE("GPL");







-------------------------------------------------- EBTABLES PART:

diff -Nur ebtables-v2.0.8-rc2.orig/extensions/Makefile 
ebtables-v2.0.8-rc2/extensions/Makefile
--- ebtables-v2.0.8-rc2.orig/extensions/Makefile	2006-03-30 19:24:57.000000000 
+0200
+++ ebtables-v2.0.8-rc2/extensions/Makefile	2006-06-29 17:18:52.000000000 
+0200
@@ -1,7 +1,7 @@
 #! /usr/bin/make

 EXT_FUNC+=802_3 nat arp arpreply ip standard log redirect vlan mark_m mark \
-          pkttype stp among limit ulog
+          pkttype stp among limit ulog vlan_t
 EXT_TABLES+=filter nat broute
 EXT_OBJS+=$(foreach T,$(EXT_FUNC), extensions/ebt_$(T).o)
 EXT_OBJS+=$(foreach T,$(EXT_TABLES), extensions/ebtable_$(T).o)
diff -Nur ebtables-v2.0.8-rc2.orig/extensions/ebt_vlan_t.c 
ebtables-v2.0.8-rc2/extensions/ebt_vlan_t.c
--- ebtables-v2.0.8-rc2.orig/extensions/ebt_vlan_t.c	1970-01-01 
01:00:00.000000000 +0100
+++ ebtables-v2.0.8-rc2/extensions/ebt_vlan_t.c	2006-07-03 21:24:05.000000000 
+0200
@@ -0,0 +1,127 @@
+/* ebt_vlan_t
+ *
+ * Authors:
+ * Dawid Ciezarkiewicz
+ *
+ * June, 2006
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <getopt.h>
+#include "../include/ebtables_u.h"
+#include <linux/netfilter_bridge/ebt_vlan_t.h>
+
+static int id_supplied;
+
+#define VLAN_TARGET  '1'
+#define VLAN_SETID '2'
+static struct option opts[] =
+{
+	{ "vlan-target" , required_argument, 0, VLAN_TARGET },
+	{ "vlan-set"    , required_argument, 0, VLAN_SETID},
+	{ 0 }
+};
+
+static void print_help()
+{
+	printf(
+	"vlan target options:\n"
+	" --vlan-set value     : Set vlan id\n"
+	" --vlan-target target : ACCEPT, DROP, RETURN or CONTINUE\n");
+}
+
+static void init(struct ebt_entry_target *target)
+{
+	struct ebt_vlan_t_info *vlaninfo =
+	   (struct ebt_vlan_t_info *)target->data;
+
+	vlaninfo->target = EBT_ACCEPT;
+	vlaninfo->id = 0;
+	id_supplied = 0;
+}
+
+#define OPT_VLAN_SETID  0x01
+#define OPT_VLAN_TARGET  0x02
+static int parse(int c, char **argv, int argc,
+   const struct ebt_u_entry *entry, unsigned int *flags,
+   struct ebt_entry_target **target)
+{
+	struct ebt_vlan_t_info *vlaninfo =
+	   (struct ebt_vlan_t_info *)(*target)->data;
+	char *end;
+
+	switch (c) {
+	case VLAN_TARGET:
+		ebt_check_option2(flags, OPT_VLAN_TARGET);
+		if (FILL_TARGET(optarg, vlaninfo->target))
+			ebt_print_error2("Illegal --vlan-target target");
+		break;
+	case VLAN_SETID:
+		ebt_check_option2(flags, OPT_VLAN_SETID);
+		vlaninfo->id = strtoul(optarg, &end, 0);
+		if (*end != '\0' || end == optarg || vlaninfo->id > 4095)
+			ebt_print_error2("Bad VLAN id value '%s'", optarg);
+		id_supplied = 1;
+                break;
+	 default:
+		return 0;
+	}
+	return 1;
+}
+
+static void final_check(const struct ebt_u_entry *entry,
+   const struct ebt_entry_target *target, const char *name,
+   unsigned int hookmask, unsigned int time)
+{
+	struct ebt_vlan_t_info *vlaninfo =
+	   (struct ebt_vlan_t_info *)target->data;
+
+	if (time == 0 && id_supplied == 0) {
+		ebt_print_error("No vlan id value supplied");
+	} else if (BASE_CHAIN && vlaninfo->target == EBT_RETURN)
+		ebt_print_error("--vlan-target RETURN not allowed on base chain");
+}
+
+static void print(const struct ebt_u_entry *entry,
+   const struct ebt_entry_target *target)
+{
+	struct ebt_vlan_t_info *vlaninfo =
+	   (struct ebt_vlan_t_info *)target->data;
+
+	printf("--vlan-set 0x%lx", vlaninfo->id);
+	if (vlaninfo->target == EBT_ACCEPT)
+		return;
+	printf(" --vlan-target %s", TARGET_NAME(vlaninfo->target));
+}
+
+static int compare(const struct ebt_entry_target *t1,
+   const struct ebt_entry_target *t2)
+{
+	struct ebt_vlan_t_info *vlaninfo1 =
+	   (struct ebt_vlan_t_info *)t1->data;
+	struct ebt_vlan_t_info *vlaninfo2 =
+	   (struct ebt_vlan_t_info *)t2->data;
+
+	return vlaninfo1->target == vlaninfo2->target &&
+	   vlaninfo1->id == vlaninfo2->id;
+}
+
+static struct ebt_u_target vlan_target =
+{
+	.name		= EBT_VLAN_TARGET,
+	.size		= sizeof(struct ebt_vlan_t_info),
+	.help		= print_help,
+	.init		= init,
+	.parse		= parse,
+	.final_check	= final_check,
+	.print		= print,
+	.compare	= compare,
+	.extra_ops	= opts,
+};
+
+void _init(void)
+{
+	ebt_register_target(&vlan_target);
+}
