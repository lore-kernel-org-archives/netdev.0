From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [net-next (TAKE 2) 4/4] ipv6: IPv6 over Firewire (RFC3146) support.
Date: Sun, 10 Feb 2013 18:02:34 +0900
Message-ID: <5117622A.8090402@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54456 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754497Ab3BJJCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 04:02:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/Kconfig |    6 ++--
 drivers/firewire/net.c   |   85 +++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/addrconf.c      |   20 ++++++++++-
 3 files changed, 98 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/Kconfig b/drivers/firewire/Kconfig
index 7224533..ad8d16c 100644
--- a/drivers/firewire/Kconfig
+++ b/drivers/firewire/Kconfig
@@ -47,9 +47,9 @@ config FIREWIRE_NET
 	tristate "IP networking over 1394"
 	depends on FIREWIRE && INET
 	help
-	  This enables IPv4 over IEEE 1394, providing IP connectivity with
-	  other implementations of RFC 2734 as found on several operating
-	  systems.  Multicast support is currently limited.
+	  This enables IPv4/IPv6 over IEEE 1394, providing IP connectivity
+	  with other implementations of RFC 2734/RFC3146 as found on
+	  several operating systems.  Multicast support is currently limited.
 
 	  To compile this driver as a module, say M here:  The module will be
 	  called firewire-net.
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 281ef1b..7f87882 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1,5 +1,6 @@
 /*
  * IPv4 over IEEE 1394, per RFC 2734
+ * IPv6 over IEEE 1394, per RFC 3146
  *
  * Copyright (C) 2009 Jay Fenlason <fenlason@redhat.com>
  *
@@ -46,6 +47,7 @@
 
 #define IANA_SPECIFIER_ID		0x00005eU
 #define RFC2734_SW_VERSION		0x000001U
+#define RFC3146_SW_VERSION		0x000002U
 
 #define IEEE1394_GASP_HDR_SIZE	8
 
@@ -516,6 +518,9 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	switch (ether_type) {
 	case ETH_P_ARP:
 	case ETH_P_IP:
+#if IS_ENABLED(CONFIG_IPV6)
+	case ETH_P_IPV6:
+#endif
 		break;
 	default:
 		goto err;
@@ -781,11 +786,18 @@ static void fwnet_receive_broadcast(struct fw_iso_context *context,
 	ver = be32_to_cpu(buf_ptr[1]) & 0xffffff;
 	source_node_id = be32_to_cpu(buf_ptr[0]) >> 16;
 
-	if (specifier_id == IANA_SPECIFIER_ID && ver == RFC2734_SW_VERSION) {
-		buf_ptr += 2;
-		length -= IEEE1394_GASP_HDR_SIZE;
-		fwnet_incoming_packet(dev, buf_ptr, length, source_node_id,
-				      context->card->generation, true);
+	if (specifier_id == IANA_SPECIFIER_ID) {
+		switch (ver) {
+		case RFC2734_SW_VERSION:
+#if IS_ENABLED(CONFIG_IPV6)
+		case RFC3146_SW_VERSION:
+#endif
+			buf_ptr += 2;
+			length -= IEEE1394_GASP_HDR_SIZE;
+			fwnet_incoming_packet(dev, buf_ptr, length,
+					      source_node_id,
+					      context->card->generation, true);
+		}
 	}
 
 	packet.payload_length = dev->rcv_buffer_size;
@@ -992,8 +1004,18 @@ static int fwnet_send_packet(struct fwnet_packet_task *ptask)
 
 		p = skb_push(ptask->skb, IEEE1394_GASP_HDR_SIZE);
 		put_unaligned_be32(node_id << 16 | IANA_SPECIFIER_ID >> 8, p);
-		put_unaligned_be32((IANA_SPECIFIER_ID & 0xff) << 24
-						| RFC2734_SW_VERSION, &p[4]);
+
+		switch (ptask->skb->protocol) {
+		default:
+			put_unaligned_be32((IANA_SPECIFIER_ID & 0xff) << 24
+							| RFC2734_SW_VERSION, &p[4]);
+			break;
+#if IS_ENABLED(CONFIG_IPV6)
+		case htons(ETH_P_IPV6):
+			put_unaligned_be32((IANA_SPECIFIER_ID & 0xff) << 24
+							| RFC3146_SW_VERSION, &p[4]);
+#endif
+		}
 
 		/* We should not transmit if broadcast_channel.valid == 0. */
 		fw_send_request(dev->card, &ptask->transaction,
@@ -1215,6 +1237,9 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	switch (proto) {
 	case htons(ETH_P_ARP):
 	case htons(ETH_P_IP):
+#if IS_ENABLED(CONFIG_IPV6)
+	case htons(ETH_P_IPV6):
+#endif
 		break;
 	default:
 		goto fail;
@@ -1554,6 +1579,14 @@ static const struct ieee1394_device_id fwnet_id_table[] = {
 		.specifier_id = IANA_SPECIFIER_ID,
 		.version      = RFC2734_SW_VERSION,
 	},
+#if IS_ENABLED(CONFIG_IPV6)
+	{
+		.match_flags  = IEEE1394_MATCH_SPECIFIER_ID |
+				IEEE1394_MATCH_VERSION,
+		.specifier_id = IANA_SPECIFIER_ID,
+		.version      = RFC3146_SW_VERSION,
+	},
+#endif
 	{ }
 };
 
@@ -1591,6 +1624,30 @@ static struct fw_descriptor rfc2374_unit_directory = {
 	.data   = rfc2374_unit_directory_data
 };
 
+#if IS_ENABLED(CONFIG_IPV6)
+static const u32 rfc3146_unit_directory_data[] = {
+	0x00040000,	/* directory_length		*/
+	0x1200005e,	/* unit_specifier_id: IANA	*/
+	0x81000003,	/* textual descriptor offset	*/
+	0x13000002,	/* unit_sw_version: RFC 3146	*/
+	0x81000005,	/* textual descriptor offset	*/
+	0x00030000,	/* descriptor_length		*/
+	0x00000000,	/* text				*/
+	0x00000000,	/* minimal ASCII, en		*/
+	0x49414e41,	/* I A N A			*/
+	0x00030000,	/* descriptor_length		*/
+	0x00000000,	/* text				*/
+	0x00000000,	/* minimal ASCII, en		*/
+	0x49507636,	/* I P v 6			*/
+};
+
+static struct fw_descriptor rfc3146_unit_directory = {
+	.length = ARRAY_SIZE(rfc3146_unit_directory_data),
+	.key    = (CSR_DIRECTORY | CSR_UNIT) << 24,
+	.data   = rfc3146_unit_directory_data
+};
+#endif
+
 static int __init fwnet_init(void)
 {
 	int err;
@@ -1599,11 +1656,17 @@ static int __init fwnet_init(void)
 	if (err)
 		return err;
 
+#if IS_ENABLED(CONFIG_IPV6)
+	err = fw_core_add_descriptor(&rfc3146_unit_directory);
+	if (err)
+		goto out;
+#endif
+
 	fwnet_packet_task_cache = kmem_cache_create("packet_task",
 			sizeof(struct fwnet_packet_task), 0, 0, NULL);
 	if (!fwnet_packet_task_cache) {
 		err = -ENOMEM;
-		goto out;
+		goto out2;
 	}
 
 	err = driver_register(&fwnet_driver.driver);
@@ -1611,7 +1674,11 @@ static int __init fwnet_init(void)
 		return 0;
 
 	kmem_cache_destroy(fwnet_packet_task_cache);
+out2:
+#if IS_ENABLED(CONFIG_IPV6)
+	fw_core_remove_descriptor(&rfc3146_unit_directory);
 out:
+#endif
 	fw_core_remove_descriptor(&rfc2374_unit_directory);
 
 	return err;
@@ -1627,6 +1694,6 @@ static void __exit fwnet_cleanup(void)
 module_exit(fwnet_cleanup);
 
 MODULE_AUTHOR("Jay Fenlason <fenlason@redhat.com>");
-MODULE_DESCRIPTION("IPv4 over IEEE1394 as per RFC 2734");
+MODULE_DESCRIPTION("IP over IEEE1394 as per RFC 2734/3146");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(ieee1394, fwnet_id_table);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index bd9f936..060a08a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -70,6 +70,7 @@
 #include <net/snmp.h>
 
 #include <net/af_ieee802154.h>
+#include <net/firewire.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
 #include <net/ndisc.h>
@@ -1660,6 +1661,20 @@ static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 	return 0;
 }
 
+static int addrconf_ifid_ieee1394(u8 *eui, struct net_device *dev)
+{
+	union fwnet_hwaddr *ha;
+
+	if (dev->addr_len != FWNET_ALEN)
+		return -1;
+
+	ha = (union fwnet_hwaddr *)dev->dev_addr;
+
+	memcpy(eui, &ha->uc.uniq_id, sizeof(ha->uc.uniq_id));
+	eui[0] ^= 2;
+	return 0;
+}
+
 static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 {
 	/* XXX: inherit EUI-64 from other interface -- yoshfuji */
@@ -1724,6 +1739,8 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_gre(eui, dev);
 	case ARPHRD_IEEE802154:
 		return addrconf_ifid_eui64(eui, dev);
+	case ARPHRD_IEEE1394:
+		return addrconf_ifid_ieee1394(eui, dev);
 	}
 	return -1;
 }
@@ -2565,7 +2582,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_ARCNET) &&
 	    (dev->type != ARPHRD_INFINIBAND) &&
-	    (dev->type != ARPHRD_IEEE802154)) {
+	    (dev->type != ARPHRD_IEEE802154) &&
+	    (dev->type != ARPHRD_IEEE1394)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
-- 
1.7.9.5
