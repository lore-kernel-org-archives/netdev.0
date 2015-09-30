From: Bastian Stender <bst@pengutronix.de>
Subject: [PATCH] net ipv4: use preferred log methods
Date: Wed, 30 Sep 2015 11:20:43 +0200
Message-ID: <1443604843-22166-1-git-send-email-bst@pengutronix.de>
References: <20150928.222409.1641594777817922710.davem@davemloft.net>
Cc: netdev@vger.kernel.org, trivial@kernel.org, kernel@pengutronix.de,
	Bastian Stender <bst@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:49928 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbI3JVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 05:21:14 -0400
In-Reply-To: <20150928.222409.1641594777817922710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace printk calls with preferred unconditional log method calls to keep
kernel messages clean.

Signed-off-by: Bastian Stender <bst@pengutronix.de>
---
 net/ipv4/ipconfig.c                            | 53 +++++++++-----------------
 net/ipv4/netfilter/arp_tables.c                | 17 +--------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c         | 31 ++++++++-------
 4 files changed, 36 insertions(+), 67 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed4ef09..b389d8b 100644
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
+		pr_cont(" %02x", *c);
+	pr_cont("\n");
 
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
@@ -1264,7 +1249,7 @@ static int __init ic_dynamic(void)
 		if (timeout > CONF_TIMEOUT_MAX)
 			timeout = CONF_TIMEOUT_MAX;
 
-		pr_cont(".");
+		pr_cont(".\n");
 	}
 
 #ifdef IPCONFIG_BOOTP
@@ -1281,10 +1266,10 @@ static int __init ic_dynamic(void)
 		return -1;
 	}
 
-	printk("IP-Config: Got %s answer from %pI4, ",
+	pr_info("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
-		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-	       &ic_addrservaddr);
+		: (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
+		&ic_addrservaddr);
 	pr_cont("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
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
index 8f87fc3..d8357bd 100644
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
