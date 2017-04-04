From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/14] nfp: report port type in ethtool
Date: Tue,  4 Apr 2017 16:12:29 -0700
Message-ID: <20170404231235.32027-9-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32936 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755291AbdDDXNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:00 -0400
Received: by mail-pf0-f176.google.com with SMTP id s16so25016360pfs.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:00 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Service process firmware provides us with information about media
and interface (SFP module) plugged in, translate that to Linux's
PORT_* defines and report via ethtool.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  1 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 21 +++++++++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   | 24 ++++++++++++++++++++++
 3 files changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 563ced3c99e1..3b2a09821a59 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -215,6 +215,7 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 		nfp_net_refresh_port_config(nn);
 	/* Separate if - on FW error the port could've disappeared from table */
 	if (nn->eth_port) {
+		cmd->base.port = nn->eth_port->port_type;
 		cmd->base.speed = nn->eth_port->speed;
 		cmd->base.duplex = DUPLEX_FULL;
 		return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index dcb1bc81e554..07b4ded01514 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -62,6 +62,8 @@
 #define NSP_ETH_STATE_TX_ENABLED	BIT_ULL(2)
 #define NSP_ETH_STATE_RX_ENABLED	BIT_ULL(3)
 #define NSP_ETH_STATE_RATE		GENMASK_ULL(11, 8)
+#define NSP_ETH_STATE_INTERFACE		GENMASK_ULL(19, 12)
+#define NSP_ETH_STATE_MEDIA		GENMASK_ULL(21, 20)
 #define NSP_ETH_STATE_OVRD_CHNG		BIT_ULL(22)
 #define NSP_ETH_STATE_ANEG		GENMASK_ULL(25, 23)
 
@@ -134,6 +136,9 @@ nfp_eth_port_translate(struct nfp_nsp *nsp, const struct eth_table_entry *src,
 	rate = nfp_eth_rate(FIELD_GET(NSP_ETH_STATE_RATE, state));
 	dst->speed = dst->lanes * rate;
 
+	dst->interface = FIELD_GET(NSP_ETH_STATE_INTERFACE, state);
+	dst->media = FIELD_GET(NSP_ETH_STATE_MEDIA, state);
+
 	nfp_eth_copy_mac_reverse(dst->mac_addr, src->mac_addr);
 
 	dst->label_port = FIELD_GET(NSP_ETH_PORT_PHYLABEL, port);
@@ -170,6 +175,20 @@ nfp_eth_mark_split_ports(struct nfp_cpp *cpp, struct nfp_eth_table *table)
 		}
 }
 
+static void
+nfp_eth_calc_port_type(struct nfp_cpp *cpp, struct nfp_eth_table_port *entry)
+{
+	if (entry->interface == NFP_INTERFACE_NONE) {
+		entry->port_type = PORT_NONE;
+		return;
+	}
+
+	if (entry->media == NFP_MEDIA_FIBRE)
+		entry->port_type = PORT_FIBRE;
+	else
+		entry->port_type = PORT_DA;
+}
+
 /**
  * nfp_eth_read_ports() - retrieve port information
  * @cpp:	NFP CPP handle
@@ -237,6 +256,8 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 					       &table->ports[j++]);
 
 	nfp_eth_mark_split_ports(cpp, table);
+	for (i = 0; i < table->count; i++)
+		nfp_eth_calc_port_type(cpp, &table->ports[i]);
 
 	kfree(entries);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
index 6b3e954e70b3..57eb3cfa6a0a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
@@ -37,6 +37,22 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+enum nfp_eth_interface {
+	NFP_INTERFACE_NONE	= 0,
+	NFP_INTERFACE_SFP	= 1,
+	NFP_INTERFACE_SFPP	= 10,
+	NFP_INTERFACE_SFP28	= 28,
+	NFP_INTERFACE_QSFP	= 40,
+	NFP_INTERFACE_CXP	= 100,
+	NFP_INTERFACE_QSFP28	= 112,
+};
+
+enum nfp_eth_media {
+	NFP_MEDIA_DAC_PASSIVE = 0,
+	NFP_MEDIA_DAC_ACTIVE,
+	NFP_MEDIA_FIBRE,
+};
+
 enum nfp_eth_aneg {
 	NFP_ANEG_AUTO = 0,
 	NFP_ANEG_SEARCH,
@@ -56,6 +72,8 @@ enum nfp_eth_aneg {
  * @base:	first channel index (within NBI)
  * @lanes:	number of channels
  * @speed:	interface speed (in Mbps)
+ * @interface:	interface (module) plugged in
+ * @media:	media type of the @interface
  * @aneg:	auto negotiation mode
  * @mac_addr:	interface MAC address
  * @label_port:	port id
@@ -65,6 +83,7 @@ enum nfp_eth_aneg {
  * @rx_enabled:	is RX enabled?
  * @override_changed: is media reconfig pending?
  *
+ * @port_type:	one of %PORT_* defines for ethtool
  * @is_split:	is interface part of a split port
  */
 struct nfp_eth_table {
@@ -77,6 +96,9 @@ struct nfp_eth_table {
 		unsigned int lanes;
 		unsigned int speed;
 
+		unsigned int interface;
+		enum nfp_eth_media media;
+
 		enum nfp_eth_aneg aneg;
 
 		u8 mac_addr[ETH_ALEN];
@@ -91,6 +113,8 @@ struct nfp_eth_table {
 		bool override_changed;
 
 		/* Computed fields */
+		u8 port_type;
+
 		bool is_split;
 	} ports[0];
 };
-- 
2.11.0
