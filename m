From: Bastian Stender <bst@pengutronix.de>
Subject: [PATCH] net ipv4: use preferred log methods
Date: Wed, 30 Sep 2015 17:00:31 +0200
Message-ID: <1443625231-1871-1-git-send-email-bst@pengutronix.de>
References: <20150928.222409.1641594777817922710.davem@davemloft.net>
Cc: netdev@vger.kernel.org, trivial@kernel.org, kernel@pengutronix.de,
	Bastian Stender <bst@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59576 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbI3PBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 11:01:08 -0400
In-Reply-To: <20150928.222409.1641594777817922710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace printk calls with preferred unconditional log method calls to keep
kernel messages clean.

Signed-off-by: Bastian Stender <bst@pengutronix.de>
---
 net/ipv4/ipconfig.c                            |  77 +++++-------
 net/ipv4/netfilter/arp_tables.c                | 165 +++++++++++--------------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |  31 +++--
 4 files changed, 122 insertions(+), 153 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed4ef09..50ec7c6 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -65,15 +65,6 @@
 #include <net/checksum.h>
 #include <asm/processor.h>
 
-/* Define this to allow debugging output */
-#undef IPCONFIG_DEBUG
-
-#ifdef IPCONFIG_DEBUG
-#define DBG(x) printk x
-#else
-#define DBG(x) do { } while(0)
-#endif
-
 #if defined(CONFIG_IP_PNP_DHCP)
 #define IPCONFIG_DHCP
 #endif
@@ -223,7 +214,7 @@ static int __init ic_open_devs(void)
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
 			else
-				pr_warn("DHCP/BOOTP: Ignoring device %s, MTU %d too small",
+				pr_warn("DHCP/BOOTP: Ignoring device %s, MTU %d too small\n",
 					dev->name, dev->mtu);
 			if (!(dev->flags & IFF_NOARP))
 				able |= IC_RARP;
@@ -250,8 +241,8 @@ static int __init ic_open_devs(void)
 			else
 				d->xid = 0;
 			ic_proto_have_if |= able;
-			DBG(("IP-Config: %s UP (able=%d, xid=%08x)\n",
-				dev->name, able, d->xid));
+			pr_debug("IP-Config: %s UP (able=%d, xid=%08x)\n",
+				 dev->name, able, d->xid);
 		}
 	}
 
@@ -307,7 +298,7 @@ static void __init ic_close_devs(void)
 		next = d->next;
 		dev = d->dev;
 		if (dev != ic_dev && !netdev_uses_dsa(dev)) {
-			DBG(("IP-Config: Downing %s\n", dev->name));
+			pr_debug("IP-Config: Downing %s\n", dev->name);
 			dev_change_flags(dev, d->flags);
 		}
 		kfree(d);
@@ -460,7 +451,8 @@ static int __init ic_defaults(void)
 			       &ic_myaddr);
 			return -1;
 		}
-		printk("IP-Config: Guessing netmask %pI4\n", &ic_netmask);
+		pr_notice("IP-Config: Guessing netmask %pI4\n",
+			  &ic_netmask);
 	}
 
 	return 0;
@@ -671,9 +663,7 @@ ic_dhcp_init_options(u8 *options)
 	u8 *e = options;
 	int len;
 
-#ifdef IPCONFIG_DEBUG
-	printk("DHCP: Sending message type %d\n", mt);
-#endif
+	pr_debug("DHCP: Sending message type %d\n", mt);
 
 	memcpy(e, ic_bootp_cookie, 4);	/* RFC1048 Magic Cookie */
 	e += 4;
@@ -833,7 +823,8 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	else if (dev->type == ARPHRD_FDDI)
 		b->htype = ARPHRD_ETHER;
 	else {
-		printk("Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
+		pr_warn("Unknown ARP type 0x%04x for device %s\n", dev->type,
+			dev->name);
 		b->htype = dev->type; /* can cause undefined behavior */
 	}
 
@@ -857,12 +848,12 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
 			    dev->broadcast, dev->dev_addr, skb->len) < 0) {
 		kfree_skb(skb);
-		printk("E");
+		pr_alert("E\n");
 		return;
 	}
 
 	if (dev_queue_xmit(skb) < 0)
-		printk("E");
+		pr_alert("E\n");
 }
 
 
@@ -890,14 +881,12 @@ static void __init ic_do_bootp_ext(u8 *ext)
 	int i;
 	__be16 mtu;
 
-#ifdef IPCONFIG_DEBUG
 	u8 *c;
 
-	printk("DHCP/BOOTP: Got extension %d:",*ext);
+	pr_debug("DHCP/BOOTP: Got extension %d:", *ext);
 	for (c=ext+2; c<ext+2+ext[1]; c++)
-		printk(" %02x", *c);
-	printk("\n");
-#endif
+		pr_debug(" %02x", *c);
+	pr_debug("\n");
 
 	switch (*ext++) {
 	case 1:		/* Subnet mask */
@@ -1066,9 +1055,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				}
 			}
 
-#ifdef IPCONFIG_DEBUG
-			printk("DHCP: Got message type %d\n", mt);
-#endif
+			pr_debug("DHCP: Got message type %d\n", mt);
 
 			switch (mt) {
 			case DHCPOFFER:
@@ -1081,10 +1068,8 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				/* Let's accept that offer. */
 				ic_myaddr = b->your_ip;
 				ic_servaddr = server_id;
-#ifdef IPCONFIG_DEBUG
-				printk("DHCP: Offered address %pI4 by server %pI4\n",
-				       &ic_myaddr, &b->iph.saddr);
-#endif
+				pr_debug("DHCP: Offered address %pI4 by server %pI4\n",
+					 &ic_myaddr, &b->iph.saddr);
 				/* The DHCP indicated server address takes
 				 * precedence over the bootp header one if
 				 * they are different.
@@ -1240,13 +1225,13 @@ static int __init ic_dynamic(void)
 		    (ic_proto_enabled & IC_USE_DHCP) &&
 		    ic_dhcp_msgtype != DHCPACK) {
 			ic_got_reply = 0;
-			pr_cont(",");
+			pr_notice(",");
 			continue;
 		}
 #endif /* IPCONFIG_DHCP */
 
 		if (ic_got_reply) {
-			pr_cont(" OK\n");
+			pr_notice(" OK\n");
 			break;
 		}
 
@@ -1254,7 +1239,7 @@ static int __init ic_dynamic(void)
 			continue;
 
 		if (! --retries) {
-			pr_cont(" timed out!\n");
+			pr_notice(" timed out!\n");
 			break;
 		}
 
@@ -1264,7 +1249,7 @@ static int __init ic_dynamic(void)
 		if (timeout > CONF_TIMEOUT_MAX)
 			timeout = CONF_TIMEOUT_MAX;
 
-		pr_cont(".");
+		pr_notice(".\n");
 	}
 
 #ifdef IPCONFIG_BOOTP
@@ -1281,11 +1266,11 @@ static int __init ic_dynamic(void)
 		return -1;
 	}
 
-	printk("IP-Config: Got %s answer from %pI4, ",
+	pr_info("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
-		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-	       &ic_addrservaddr);
-	pr_cont("my address is %pI4\n", &ic_myaddr);
+		: (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
+		&ic_addrservaddr);
+	pr_info("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
 }
@@ -1412,7 +1397,7 @@ static int __init ip_auto_config(void)
 	if (!ic_enable)
 		return 0;
 
-	DBG(("IP-Config: Entered.\n"));
+	pr_debug("IP-Config: Entered.\n");
 #ifdef IPCONFIG_DYNAMIC
  try_try_again:
 #endif
@@ -1525,7 +1510,7 @@ static int __init ip_auto_config(void)
 	pr_info("     bootserver=%pI4, rootserver=%pI4, rootpath=%s",
 		&ic_servaddr, &root_server_addr, root_server_path);
 	if (ic_dev_mtu)
-		pr_cont(", mtu=%d", ic_dev_mtu);
+		pr_info(", mtu=%d", ic_dev_mtu);
 	for (i = 0; i < CONF_NAMESERVERS_MAX; i++)
 		if (ic_nameservers[i] != NONE) {
 			pr_info("     nameserver%u=%pI4",
@@ -1534,8 +1519,8 @@ static int __init ip_auto_config(void)
 		}
 	for (i++; i < CONF_NAMESERVERS_MAX; i++)
 		if (ic_nameservers[i] != NONE)
-			pr_cont(", nameserver%u=%pI4", i, &ic_nameservers[i]);
-	pr_cont("\n");
+			pr_info(", nameserver%u=%pI4", i, &ic_nameservers[i]);
+	pr_info("\n");
 #endif /* !SILENT */
 
 	return 0;
@@ -1614,7 +1599,7 @@ static int __init ip_auto_config_setup(char *addrs)
 		if ((cp = strchr(ip, ':')))
 			*cp++ = '\0';
 		if (strlen(ip) > 0) {
-			DBG(("IP-Config: Parameter #%d: `%s'\n", num, ip));
+			pr_debug("IP-Config: Parameter #%d: `%s'\n", num, ip);
 			switch (num) {
 			case 0:
 				if ((ic_myaddr = in_aton(ip)) == ANY)
@@ -1686,7 +1671,7 @@ static int __init vendor_class_identifier_setup(char *addrs)
 	if (strlcpy(vendor_class_identifier, addrs,
 		    sizeof(vendor_class_identifier))
 	    >= sizeof(vendor_class_identifier))
-		pr_warn("DHCP: vendorclass too long, truncated to \"%s\"",
+		pr_warn("DHCP: vendorclass too long, truncated to \"%s\"\n",
 			vendor_class_identifier);
 	return 1;
 }
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8f87fc3..c54c996 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -34,21 +34,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("David S. Miller <davem@redhat.com>");
 MODULE_DESCRIPTION("arptables core");
 
-/*#define DEBUG_ARP_TABLES*/
-/*#define DEBUG_ARP_TABLES_USER*/
-
-#ifdef DEBUG_ARP_TABLES
-#define dprintf(format, args...)  printk(format , ## args)
-#else
-#define dprintf(format, args...)
-#endif
-
-#ifdef DEBUG_ARP_TABLES_USER
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 #ifdef CONFIG_NETFILTER_DEBUG
 #define ARP_NF_ASSERT(x)	WARN_ON(!(x))
 #else
@@ -114,33 +99,33 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 
 	if (FWINV((arphdr->ar_op & arpinfo->arpop_mask) != arpinfo->arpop,
 		  ARPT_INV_ARPOP)) {
-		dprintf("ARP operation field mismatch.\n");
-		dprintf("ar_op: %04x info->arpop: %04x info->arpop_mask: %04x\n",
-			arphdr->ar_op, arpinfo->arpop, arpinfo->arpop_mask);
+		pr_debug("ARP operation field mismatch.\n");
+		pr_debug("ar_op: %04x info->arpop: %04x info->arpop_mask: %04x\n",
+			 arphdr->ar_op, arpinfo->arpop, arpinfo->arpop_mask);
 		return 0;
 	}
 
 	if (FWINV((arphdr->ar_hrd & arpinfo->arhrd_mask) != arpinfo->arhrd,
 		  ARPT_INV_ARPHRD)) {
-		dprintf("ARP hardware address format mismatch.\n");
-		dprintf("ar_hrd: %04x info->arhrd: %04x info->arhrd_mask: %04x\n",
-			arphdr->ar_hrd, arpinfo->arhrd, arpinfo->arhrd_mask);
+		pr_debug("ARP hardware address format mismatch.\n");
+		pr_debug("ar_hrd: %04x info->arhrd: %04x info->arhrd_mask: %04x\n",
+			 arphdr->ar_hrd, arpinfo->arhrd, arpinfo->arhrd_mask);
 		return 0;
 	}
 
 	if (FWINV((arphdr->ar_pro & arpinfo->arpro_mask) != arpinfo->arpro,
 		  ARPT_INV_ARPPRO)) {
-		dprintf("ARP protocol address format mismatch.\n");
-		dprintf("ar_pro: %04x info->arpro: %04x info->arpro_mask: %04x\n",
-			arphdr->ar_pro, arpinfo->arpro, arpinfo->arpro_mask);
+		pr_debug("ARP protocol address format mismatch.\n");
+		pr_debug("ar_pro: %04x info->arpro: %04x info->arpro_mask: %04x\n",
+			 arphdr->ar_pro, arpinfo->arpro, arpinfo->arpro_mask);
 		return 0;
 	}
 
 	if (FWINV((arphdr->ar_hln & arpinfo->arhln_mask) != arpinfo->arhln,
 		  ARPT_INV_ARPHLN)) {
-		dprintf("ARP hardware address length mismatch.\n");
-		dprintf("ar_hln: %02x info->arhln: %02x info->arhln_mask: %02x\n",
-			arphdr->ar_hln, arpinfo->arhln, arpinfo->arhln_mask);
+		pr_debug("ARP hardware address length mismatch.\n");
+		pr_debug("ar_hln: %02x info->arhln: %02x info->arhln_mask: %02x\n",
+			 arphdr->ar_hln, arpinfo->arhln, arpinfo->arhln_mask);
 		return 0;
 	}
 
@@ -156,7 +141,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 		  ARPT_INV_SRCDEVADDR) ||
 	    FWINV(arp_devaddr_compare(&arpinfo->tgt_devaddr, tgt_devaddr, dev->addr_len),
 		  ARPT_INV_TGTDEVADDR)) {
-		dprintf("Source or target device address mismatch.\n");
+		pr_debug("Source or target device address mismatch.\n");
 
 		return 0;
 	}
@@ -165,18 +150,18 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 		  ARPT_INV_SRCIP) ||
 	    FWINV(((tgt_ipaddr & arpinfo->tmsk.s_addr) != arpinfo->tgt.s_addr),
 		  ARPT_INV_TGTIP)) {
-		dprintf("Source or target IP address mismatch.\n");
-
-		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
-			&src_ipaddr,
-			&arpinfo->smsk.s_addr,
-			&arpinfo->src.s_addr,
-			arpinfo->invflags & ARPT_INV_SRCIP ? " (INV)" : "");
-		dprintf("TGT: %pI4 Mask: %pI4 Target: %pI4.%s\n",
-			&tgt_ipaddr,
-			&arpinfo->tmsk.s_addr,
-			&arpinfo->tgt.s_addr,
-			arpinfo->invflags & ARPT_INV_TGTIP ? " (INV)" : "");
+		pr_debug("Source or target IP address mismatch.\n");
+
+		pr_debug("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
+			 &src_ipaddr,
+			 &arpinfo->smsk.s_addr,
+			 &arpinfo->src.s_addr,
+			 arpinfo->invflags & ARPT_INV_SRCIP ? " (INV)" : "");
+		pr_debug("TGT: %pI4 Mask: %pI4 Target: %pI4.%s\n",
+			 &tgt_ipaddr,
+			 &arpinfo->tmsk.s_addr,
+			 &arpinfo->tgt.s_addr,
+			 arpinfo->invflags & ARPT_INV_TGTIP ? " (INV)" : "");
 		return 0;
 	}
 
@@ -184,18 +169,18 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	ret = ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
-		dprintf("VIA in mismatch (%s vs %s).%s\n",
-			indev, arpinfo->iniface,
-			arpinfo->invflags&ARPT_INV_VIA_IN ?" (INV)":"");
+		pr_debug("VIA in mismatch (%s vs %s).%s\n",
+			 indev, arpinfo->iniface,
+			 arpinfo->invflags & ARPT_INV_VIA_IN ? " (INV)" : "");
 		return 0;
 	}
 
 	ret = ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
-		dprintf("VIA out mismatch (%s vs %s).%s\n",
-			outdev, arpinfo->outiface,
-			arpinfo->invflags&ARPT_INV_VIA_OUT ?" (INV)":"");
+		pr_debug("VIA out mismatch (%s vs %s).%s\n",
+			 outdev, arpinfo->outiface,
+			 arpinfo->invflags & ARPT_INV_VIA_OUT ? " (INV)" : "");
 		return 0;
 	}
 
@@ -206,12 +191,12 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 static inline int arp_checkentry(const struct arpt_arp *arp)
 {
 	if (arp->flags & ~ARPT_F_MASK) {
-		duprintf("Unknown flag bits set: %08X\n",
+		pr_debug("Unknown flag bits set: %08X\n",
 			 arp->flags & ~ARPT_F_MASK);
 		return 0;
 	}
 	if (arp->invflags & ~ARPT_INV_MASK) {
-		duprintf("Unknown invflag bits set: %08X\n",
+		pr_debug("Unknown invflag bits set: %08X\n",
 			 arp->invflags & ~ARPT_INV_MASK);
 		return 0;
 	}
@@ -411,7 +396,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				if ((strcmp(t->target.u.user.name,
 					    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
-					duprintf("mark_source_chains: bad "
+					pr_debug("mark_source_chains: bad "
 						"negative verdict (%i)\n",
 								t->verdict);
 					return 0;
@@ -448,14 +433,14 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct arpt_entry)) {
-						duprintf("mark_source_chains: "
+						pr_debug("mark_source_chains: "
 							"bad verdict (%i)\n",
 								newpos);
 						return 0;
 					}
 
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u\n",
+					pr_debug("Jump rule %u -> %u\n",
 						 pos, newpos);
 				} else {
 					/* ... this is a fallthru */
@@ -468,7 +453,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 			}
 		}
 		next:
-		duprintf("Finished chain %u\n", hook);
+		pr_debug("Finished chain %u\n", hook);
 	}
 	return 1;
 }
@@ -478,7 +463,7 @@ static inline int check_entry(const struct arpt_entry *e, const char *name)
 	const struct xt_entry_target *t;
 
 	if (!arp_checkentry(&e->arp)) {
-		duprintf("arp_tables: arp check failed %p %s.\n", e, name);
+		pr_debug("arp_tables: arp check failed %p %s.\n", e, name);
 		return -EINVAL;
 	}
 
@@ -507,7 +492,7 @@ static inline int check_target(struct arpt_entry *e, const char *name)
 
 	ret = xt_check_target(&par, t->u.target_size - sizeof(*t), 0, false);
 	if (ret < 0) {
-		duprintf("arp_tables: check failed for `%s'.\n",
+		pr_debug("arp_tables: check failed for `%s'.\n",
 			 t->u.kernel.target->name);
 		return ret;
 	}
@@ -533,7 +518,7 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("find_check_entry: `%s' not found\n", t->u.user.name);
+		pr_debug("find_check_entry: `%s' not found\n", t->u.user.name);
 		ret = PTR_ERR(target);
 		goto out;
 	}
@@ -578,13 +563,13 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 
 	if ((unsigned long)e % __alignof__(struct arpt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct arpt_entry) >= limit) {
-		duprintf("Bad offset %p\n", e);
+		pr_debug("Bad offset %p\n", e);
 		return -EINVAL;
 	}
 
 	if (e->next_offset
 	    < sizeof(struct arpt_entry) + sizeof(struct xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
+		pr_debug("checking: element %p size %u\n",
 			 e, e->next_offset);
 		return -EINVAL;
 	}
@@ -646,7 +631,7 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
-	duprintf("translate_table: size %u\n", newinfo->size);
+	pr_debug("translate_table: size %u\n", newinfo->size);
 	i = 0;
 
 	/* Walk through entries, checking offsets. */
@@ -663,12 +648,12 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
-	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
+	pr_debug("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
 		return ret;
 
 	if (i != repl->num_entries) {
-		duprintf("translate_table: %u not %u entries\n",
+		pr_debug("translate_table: %u not %u entries\n",
 			 i, repl->num_entries);
 		return -EINVAL;
 	}
@@ -679,19 +664,19 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
 		if (newinfo->hook_entry[i] == 0xFFFFFFFF) {
-			duprintf("Invalid hook entry %u %u\n",
+			pr_debug("Invalid hook entry %u %u\n",
 				 i, repl->hook_entry[i]);
 			return -EINVAL;
 		}
 		if (newinfo->underflow[i] == 0xFFFFFFFF) {
-			duprintf("Invalid underflow %u %u\n",
+			pr_debug("Invalid underflow %u %u\n",
 				 i, repl->underflow[i]);
 			return -EINVAL;
 		}
 	}
 
 	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0)) {
-		duprintf("Looping hook\n");
+		pr_debug("Looping hook\n");
 		return -ELOOP;
 	}
 
@@ -898,7 +883,7 @@ static int get_info(struct net *net, void __user *user,
 	int ret;
 
 	if (*len != sizeof(struct arpt_getinfo)) {
-		duprintf("length %u != %Zu\n", *len,
+		pr_debug("length %u != %Zu\n", *len,
 			 sizeof(struct arpt_getinfo));
 		return -EINVAL;
 	}
@@ -958,13 +943,13 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 	struct xt_table *t;
 
 	if (*len < sizeof(get)) {
-		duprintf("get_entries: %u < %Zu\n", *len, sizeof(get));
+		pr_debug("get_entries: %u < %Zu\n", *len, sizeof(get));
 		return -EINVAL;
 	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
 	if (*len != sizeof(struct arpt_get_entries) + get.size) {
-		duprintf("get_entries: %u != %Zu\n", *len,
+		pr_debug("get_entries: %u != %Zu\n", *len,
 			 sizeof(struct arpt_get_entries) + get.size);
 		return -EINVAL;
 	}
@@ -973,13 +958,13 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 
-		duprintf("t->private->number = %u\n",
+		pr_debug("t->private->number = %u\n",
 			 private->number);
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
 		else {
-			duprintf("get_entries: I've got %u not %u!\n",
+			pr_debug("get_entries: I've got %u not %u!\n",
 				 private->size, get.size);
 			ret = -EAGAIN;
 		}
@@ -1020,7 +1005,7 @@ static int __do_replace(struct net *net, const char *name,
 
 	/* You lied! */
 	if (valid_hooks != t->valid_hooks) {
-		duprintf("Valid hook crap: %08X vs %08X\n",
+		pr_debug("Valid hook crap: %08X vs %08X\n",
 			 valid_hooks, t->valid_hooks);
 		ret = -EINVAL;
 		goto put_module;
@@ -1031,8 +1016,8 @@ static int __do_replace(struct net *net, const char *name,
 		goto put_module;
 
 	/* Update module usage count based on number of rules */
-	duprintf("do_replace: oldnum=%u, initnum=%u, newnum=%u\n",
-		oldinfo->number, oldinfo->initial_entries, newinfo->number);
+	pr_debug("do_replace: oldnum=%u, initnum=%u, newnum=%u\n",
+		 oldinfo->number, oldinfo->initial_entries, newinfo->number);
 	if ((oldinfo->number > oldinfo->initial_entries) ||
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
@@ -1102,7 +1087,7 @@ static int do_replace(struct net *net, const void __user *user,
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("arp_tables: Translated table\n");
+	pr_debug("arp_tables: Translated table\n");
 
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, tmp.counters);
@@ -1230,16 +1215,16 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	unsigned int entry_offset;
 	int ret, off, h;
 
-	duprintf("check_compat_entry_size_and_hooks %p\n", e);
+	pr_debug("check_compat_entry_size_and_hooks %p\n", e);
 	if ((unsigned long)e % __alignof__(struct compat_arpt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct compat_arpt_entry) >= limit) {
-		duprintf("Bad offset %p, limit = %p\n", e, limit);
+		pr_debug("Bad offset %p, limit = %p\n", e, limit);
 		return -EINVAL;
 	}
 
 	if (e->next_offset < sizeof(struct compat_arpt_entry) +
 			     sizeof(struct compat_xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
+		pr_debug("checking: element %p size %u\n",
 			 e, e->next_offset);
 		return -EINVAL;
 	}
@@ -1256,7 +1241,7 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("check_compat_entry_size_and_hooks: `%s' not found\n",
+		pr_debug("check_compat_entry_size_and_hooks: `%s' not found\n",
 			 t->u.user.name);
 		ret = PTR_ERR(target);
 		goto out;
@@ -1351,7 +1336,7 @@ static int translate_compat_table(const char *name,
 		info->underflow[i] = 0xFFFFFFFF;
 	}
 
-	duprintf("translate_compat_table: size %u\n", info->size);
+	pr_debug("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(NFPROTO_ARP);
 	xt_compat_init_offsets(NFPROTO_ARP, number);
@@ -1370,7 +1355,7 @@ static int translate_compat_table(const char *name,
 
 	ret = -EINVAL;
 	if (j != number) {
-		duprintf("translate_compat_table: %u not %u entries\n",
+		pr_debug("translate_compat_table: %u not %u entries\n",
 			 j, number);
 		goto out_unlock;
 	}
@@ -1381,12 +1366,12 @@ static int translate_compat_table(const char *name,
 		if (!(valid_hooks & (1 << i)))
 			continue;
 		if (info->hook_entry[i] == 0xFFFFFFFF) {
-			duprintf("Invalid hook entry %u %u\n",
+			pr_debug("Invalid hook entry %u %u\n",
 				 i, hook_entries[i]);
 			goto out_unlock;
 		}
 		if (info->underflow[i] == 0xFFFFFFFF) {
-			duprintf("Invalid underflow %u %u\n",
+			pr_debug("Invalid underflow %u %u\n",
 				 i, underflows[i]);
 			goto out_unlock;
 		}
@@ -1533,7 +1518,7 @@ static int compat_do_replace(struct net *net, void __user *user,
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("compat_do_replace: Translated table\n");
+	pr_debug("compat_do_replace: Translated table\n");
 
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, compat_ptr(tmp.counters));
@@ -1567,7 +1552,7 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 		break;
 
 	default:
-		duprintf("do_arpt_set_ctl:  unknown request %i\n", cmd);
+		pr_debug("do_arpt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1651,13 +1636,13 @@ static int compat_get_entries(struct net *net,
 	struct xt_table *t;
 
 	if (*len < sizeof(get)) {
-		duprintf("compat_get_entries: %u < %zu\n", *len, sizeof(get));
+		pr_debug("compat_get_entries: %u < %zu\n", *len, sizeof(get));
 		return -EINVAL;
 	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
 	if (*len != sizeof(struct compat_arpt_get_entries) + get.size) {
-		duprintf("compat_get_entries: %u != %zu\n",
+		pr_debug("compat_get_entries: %u != %zu\n",
 			 *len, sizeof(get) + get.size);
 		return -EINVAL;
 	}
@@ -1668,13 +1653,13 @@ static int compat_get_entries(struct net *net,
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 
-		duprintf("t->private->number = %u\n", private->number);
+		pr_debug("t->private->number = %u\n", private->number);
 		ret = compat_table_info(private, &info);
 		if (!ret && get.size == info.size) {
 			ret = compat_copy_entries_to_user(private->size,
 							  t, uptr->entrytable);
 		} else if (!ret) {
-			duprintf("compat_get_entries: I've got %u not %u!\n",
+			pr_debug("compat_get_entries: I've got %u not %u!\n",
 				 private->size, get.size);
 			ret = -EAGAIN;
 		}
@@ -1729,7 +1714,7 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 		break;
 
 	default:
-		duprintf("do_arpt_set_ctl:  unknown request %i\n", cmd);
+		pr_debug("do_arpt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1772,7 +1757,7 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 	}
 
 	default:
-		duprintf("do_arpt_get_ctl: unknown request %i\n", cmd);
+		pr_debug("do_arpt_get_ctl: unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1799,7 +1784,7 @@ struct xt_table *arpt_register_table(struct net *net,
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(newinfo, loc_cpu_entry, repl);
-	duprintf("arpt_register_table: translate table gives %d\n", ret);
+	pr_debug("arpt_register_table: translate table gives %d\n", ret);
 	if (ret != 0)
 		goto out_free;
 
@@ -1904,7 +1889,7 @@ static int __init arp_tables_init(void)
 	if (ret < 0)
 		goto err4;
 
-	printk(KERN_INFO "arp_tables: (C) 2002 David S. Miller\n");
+	pr_info("arp_tables: (C) 2002 David S. Miller\n");
 	return 0;
 
 err4:
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8a2caaf..c8d7384 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -457,7 +457,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 
 	ret = nf_register_sockopt(&so_getorigdst);
 	if (ret < 0) {
-		printk(KERN_ERR "Unable to register netfilter socket option\n");
+		pr_err("Unable to register netfilter socket option\n");
 		return ret;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 7c67667..78f63f5 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -915,8 +915,7 @@ static inline void mangle_address(unsigned char *begin,
 		}
 
 		if (debug)
-			printk(KERN_DEBUG "bsalg: mapped %pI4 to %pI4\n",
-			       &old, addr);
+			pr_debug("bsalg: mapped %pI4 to %pI4\n", &old, addr);
 	}
 }
 
@@ -1004,10 +1003,10 @@ static void hex_dump(const unsigned char *buf, size_t len)
 
 	for (i = 0; i < len; i++) {
 		if (i && !(i % 16))
-			printk("\n");
-		printk("%02x ", *(buf + i));
+			pr_debug("\n");
+		pr_debug("%02x ", *(buf + i));
 	}
-	printk("\n");
+	pr_debug("\n");
 }
 
 /*
@@ -1048,7 +1047,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 	if (!asn1_uint_decode (&ctx, end, &vers))
 		return 0;
 	if (debug > 1)
-		printk(KERN_DEBUG "bsalg: snmp version: %u\n", vers + 1);
+		pr_debug("bsalg: snmp version: %u\n", vers + 1);
 	if (vers > 1)
 		return 1;
 
@@ -1064,10 +1063,10 @@ static int snmp_parse_mangle(unsigned char *msg,
 	if (debug > 1) {
 		unsigned int i;
 
-		printk(KERN_DEBUG "bsalg: community: ");
+		pr_debug("bsalg: community: ");
 		for (i = 0; i < comm.len; i++)
-			printk("%c", comm.data[i]);
-		printk("\n");
+			pr_cont("%c", comm.data[i]);
+		pr_cont("\n");
 	}
 	kfree(comm.data);
 
@@ -1091,9 +1090,9 @@ static int snmp_parse_mangle(unsigned char *msg,
 		};
 
 		if (pdutype > SNMP_PDU_TRAP2)
-			printk(KERN_DEBUG "bsalg: bad pdu type %u\n", pdutype);
+			pr_debug("bsalg: bad pdu type %u\n", pdutype);
 		else
-			printk(KERN_DEBUG "bsalg: pdu: %s\n", pdus[pdutype]);
+			pr_debug("bsalg: pdu: %s\n", pdus[pdutype]);
 	}
 	if (pdutype != SNMP_PDU_RESPONSE &&
 	    pdutype != SNMP_PDU_TRAP1 && pdutype != SNMP_PDU_TRAP2)
@@ -1119,7 +1118,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 			return 0;
 
 		if (debug > 1)
-			printk(KERN_DEBUG "bsalg: request: id=0x%lx error_status=%u "
+			pr_debug("bsalg: request: id=0x%lx error_status=%u "
 			"error_index=%u\n", req.id, req.error_status,
 			req.error_index);
 	}
@@ -1145,13 +1144,13 @@ static int snmp_parse_mangle(unsigned char *msg,
 		}
 
 		if (debug > 1) {
-			printk(KERN_DEBUG "bsalg: object: ");
+			pr_debug("bsalg: object: ");
 			for (i = 0; i < obj->id_len; i++) {
 				if (i > 0)
-					printk(".");
-				printk("%lu", obj->id[i]);
+					pr_cont(".");
+				pr_cont("%lu", obj->id[i]);
 			}
-			printk(": type=%u\n", obj->type);
+			pr_cont(": type=%u\n", obj->type);
 
 		}
 
-- 
2.5.3
