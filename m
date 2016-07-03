From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/10] net/ncsi: NCSI response packet handler
Date: Sun,  3 Jul 2016 15:32:26 +1000
Message-ID: <1467523953-18998-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:15314 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751294AbcGCFdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:33:15 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635VZUd019879
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:33:14 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x6hvjut0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:33:13 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:33:10 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 885113578053
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:33:08 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635X81s49283112
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:33:08 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635X7LV010986
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:33:08 +1000
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NCSI response packets are sent to MC (Management Controller)
from the remote end. They are responses of NCSI command packets
for multiple purposes: completion status of NCSI command packets,
return NCSI channel's capability or configuration etc.

This defines struct to represent NCSI response packets and introduces
function ncsi_rcv_rsp() which will be used to receive NCSI response
packets and parse them.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/Makefile   |   2 +-
 net/ncsi/internal.h |   2 +
 net/ncsi/ncsi-pkt.h | 191 ++++++++++
 net/ncsi/ncsi-rsp.c | 987 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1181 insertions(+), 1 deletion(-)
 create mode 100644 net/ncsi/ncsi-rsp.c

diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index abc4046..4751819 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -1,4 +1,4 @@
 #
 # Makefile for NCSI API
 #
-obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-manage.o
+obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-manage.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 842a687..508836a 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -269,5 +269,7 @@ struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
 /* Packet handlers */
 u32 ncsi_calculate_checksum(unsigned char *data, int len);
 int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca);
+int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev);
 
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-pkt.h b/net/ncsi/ncsi-pkt.h
index 7f030b5..95882f3 100644
--- a/net/ncsi/ncsi-pkt.h
+++ b/net/ncsi/ncsi-pkt.h
@@ -25,6 +25,12 @@ struct ncsi_cmd_pkt_hdr {
 	struct ncsi_pkt_hdr common; /* Common NCSI packet header */
 };
 
+struct ncsi_rsp_pkt_hdr {
+	struct ncsi_pkt_hdr common; /* Common NCSI packet header */
+	__be16              code;   /* Response code             */
+	__be16              reason; /* Response reason           */
+};
+
 /* NCSI common command packet */
 struct ncsi_cmd_pkt {
 	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
@@ -32,6 +38,12 @@ struct ncsi_cmd_pkt {
 	unsigned char           pad[26];
 };
 
+struct ncsi_rsp_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;      /* Response header */
+	__be32                  checksum; /* Checksum        */
+	unsigned char           pad[22];
+};
+
 /* Select Package */
 struct ncsi_cmd_sp_pkt {
 	struct ncsi_cmd_pkt_hdr cmd;            /* Command header */
@@ -133,6 +145,143 @@ struct ncsi_cmd_snfc_pkt {
 	unsigned char           pad[22];
 };
 
+/* Get Link Status */
+struct ncsi_rsp_gls_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;        /* Response header   */
+	__be32                  status;     /* Link status       */
+	__be32                  other;      /* Other indications */
+	__be32                  oem_status; /* OEM link status   */
+	__be32                  checksum;
+	unsigned char           pad[10];
+};
+
+/* Get Version ID */
+struct ncsi_rsp_gvi_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;          /* Response header */
+	__be32                  ncsi_version; /* NCSI version    */
+	unsigned char           reserved[3];  /* Reserved        */
+	unsigned char           alpha2;       /* NCSI version    */
+	unsigned char           fw_name[12];  /* f/w name string */
+	__be32                  fw_version;   /* f/w version     */
+	__be16                  pci_ids[4];   /* PCI IDs         */
+	__be32                  mf_id;        /* Manufacture ID  */
+	__be32                  checksum;
+};
+
+/* Get Capabilities */
+struct ncsi_rsp_gc_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;         /* Response header   */
+	__be32                  cap;         /* Capabilities      */
+	__be32                  bc_cap;      /* Broadcast cap     */
+	__be32                  mc_cap;      /* Multicast cap     */
+	__be32                  buf_cap;     /* Buffering cap     */
+	__be32                  aen_cap;     /* AEN cap           */
+	unsigned char           vlan_cnt;    /* VLAN filter count */
+	unsigned char           mixed_cnt;   /* Mix filter count  */
+	unsigned char           mc_cnt;      /* MC filter count   */
+	unsigned char           uc_cnt;      /* UC filter count   */
+	unsigned char           reserved[2]; /* Reserved          */
+	unsigned char           vlan_mode;   /* VLAN mode         */
+	unsigned char           channel_cnt; /* Channel count     */
+	__be32                  checksum;    /* Checksum          */
+};
+
+/* Get Parameters */
+struct ncsi_rsp_gp_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;          /* Response header       */
+	unsigned char           mac_cnt;      /* Number of MAC addr    */
+	unsigned char           reserved[2];  /* Reserved              */
+	unsigned char           mac_enable;   /* MAC addr enable flags */
+	unsigned char           vlan_cnt;     /* VLAN tag count        */
+	unsigned char           reserved1;    /* Reserved              */
+	__be16                  vlan_enable;  /* VLAN tag enable flags */
+	__be32                  link_mode;    /* Link setting          */
+	__be32                  bc_mode;      /* BC filter mode        */
+	__be32                  valid_modes;  /* Valid mode parameters */
+	unsigned char           vlan_mode;    /* VLAN mode             */
+	unsigned char           fc_mode;      /* Flow control mode     */
+	unsigned char           reserved2[2]; /* Reserved              */
+	__be32                  aen_mode;     /* AEN mode              */
+	unsigned char           mac[6];       /* Supported MAC addr    */
+	__be16                  vlan;         /* Supported VLAN tags   */
+	__be32                  checksum;     /* Checksum              */
+};
+
+/* Get Controller Packet Statistics */
+struct ncsi_rsp_gcps_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;            /* Response header            */
+	__be32                  cnt_hi;         /* Counter cleared            */
+	__be32                  cnt_lo;         /* Counter cleared            */
+	__be32                  rx_bytes;       /* Rx bytes                   */
+	__be32                  tx_bytes;       /* Tx bytes                   */
+	__be32                  rx_uc_pkts;     /* Rx UC packets              */
+	__be32                  rx_mc_pkts;     /* Rx MC packets              */
+	__be32                  rx_bc_pkts;     /* Rx BC packets              */
+	__be32                  tx_uc_pkts;     /* Tx UC packets              */
+	__be32                  tx_mc_pkts;     /* Tx MC packets              */
+	__be32                  tx_bc_pkts;     /* Tx BC packets              */
+	__be32                  fcs_err;        /* FCS errors                 */
+	__be32                  align_err;      /* Alignment errors           */
+	__be32                  false_carrier;  /* False carrier detection    */
+	__be32                  runt_pkts;      /* Rx runt packets            */
+	__be32                  jabber_pkts;    /* Rx jabber packets          */
+	__be32                  rx_pause_xon;   /* Rx pause XON frames        */
+	__be32                  rx_pause_xoff;  /* Rx XOFF frames             */
+	__be32                  tx_pause_xon;   /* Tx XON frames              */
+	__be32                  tx_pause_xoff;  /* Tx XOFF frames             */
+	__be32                  tx_s_collision; /* Single collision frames    */
+	__be32                  tx_m_collision; /* Multiple collision frames  */
+	__be32                  l_collision;    /* Late collision frames      */
+	__be32                  e_collision;    /* Excessive collision frames */
+	__be32                  rx_ctl_frames;  /* Rx control frames          */
+	__be32                  rx_64_frames;   /* Rx 64-bytes frames         */
+	__be32                  rx_127_frames;  /* Rx 65-127 bytes frames     */
+	__be32                  rx_255_frames;  /* Rx 128-255 bytes frames    */
+	__be32                  rx_511_frames;  /* Rx 256-511 bytes frames    */
+	__be32                  rx_1023_frames; /* Rx 512-1023 bytes frames   */
+	__be32                  rx_1522_frames; /* Rx 1024-1522 bytes frames  */
+	__be32                  rx_9022_frames; /* Rx 1523-9022 bytes frames  */
+	__be32                  tx_64_frames;   /* Tx 64-bytes frames         */
+	__be32                  tx_127_frames;  /* Tx 65-127 bytes frames     */
+	__be32                  tx_255_frames;  /* Tx 128-255 bytes frames    */
+	__be32                  tx_511_frames;  /* Tx 256-511 bytes frames    */
+	__be32                  tx_1023_frames; /* Tx 512-1023 bytes frames   */
+	__be32                  tx_1522_frames; /* Tx 1024-1522 bytes frames  */
+	__be32                  tx_9022_frames; /* Tx 1523-9022 bytes frames  */
+	__be32                  rx_valid_bytes; /* Rx valid bytes             */
+	__be32                  rx_runt_pkts;   /* Rx error runt packets      */
+	__be32                  rx_jabber_pkts; /* Rx error jabber packets    */
+	__be32                  checksum;       /* Checksum                   */
+};
+
+/* Get NCSI Statistics */
+struct ncsi_rsp_gns_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;           /* Response header         */
+	__be32                  rx_cmds;       /* Rx NCSI commands        */
+	__be32                  dropped_cmds;  /* Dropped commands        */
+	__be32                  cmd_type_errs; /* Command type errors     */
+	__be32                  cmd_csum_errs; /* Command checksum errors */
+	__be32                  rx_pkts;       /* Rx NCSI packets         */
+	__be32                  tx_pkts;       /* Tx NCSI packets         */
+	__be32                  tx_aen_pkts;   /* Tx AEN packets          */
+	__be32                  checksum;      /* Checksum                */
+};
+
+/* Get NCSI Pass-through Statistics */
+struct ncsi_rsp_gnpts_pkt {
+	struct ncsi_rsp_pkt_hdr rsp;            /* Response header     */
+	__be32                  tx_pkts;        /* Tx packets          */
+	__be32                  tx_dropped;     /* Tx dropped packets  */
+	__be32                  tx_channel_err; /* Tx channel errors   */
+	__be32                  tx_us_err;      /* Tx undersize errors */
+	__be32                  rx_pkts;        /* Rx packets          */
+	__be32                  rx_dropped;     /* Rx dropped packets  */
+	__be32                  rx_channel_err; /* Rx channel errors   */
+	__be32                  rx_us_err;      /* Rx undersize errors */
+	__be32                  rx_os_err;      /* Rx oversize errors  */
+	__be32                  checksum;       /* Checksum            */
+};
+
 /* NCSI packet revision */
 #define NCSI_PKT_REVISION	0x01
 
@@ -165,4 +314,46 @@ struct ncsi_cmd_snfc_pkt {
 #define NCSI_PKT_CMD_GNPTS	0x1a	/* Get NCSI Pass-throu Statistics   */
 #define NCSI_PKT_CMD_OEM	0x50	/* OEM                              */
 
+/* NCSI packet responses */
+#define NCSI_PKT_RSP_CIS	(NCSI_PKT_CMD_CIS   + 0x80)
+#define NCSI_PKT_RSP_SP		(NCSI_PKT_CMD_SP    + 0x80)
+#define NCSI_PKT_RSP_DP		(NCSI_PKT_CMD_DP    + 0x80)
+#define NCSI_PKT_RSP_EC		(NCSI_PKT_CMD_EC    + 0x80)
+#define NCSI_PKT_RSP_DC		(NCSI_PKT_CMD_DC    + 0x80)
+#define NCSI_PKT_RSP_RC		(NCSI_PKT_CMD_RC    + 0x80)
+#define NCSI_PKT_RSP_ECNT	(NCSI_PKT_CMD_ECNT  + 0x80)
+#define NCSI_PKT_RSP_DCNT	(NCSI_PKT_CMD_DCNT  + 0x80)
+#define NCSI_PKT_RSP_AE		(NCSI_PKT_CMD_AE    + 0x80)
+#define NCSI_PKT_RSP_SL		(NCSI_PKT_CMD_SL    + 0x80)
+#define NCSI_PKT_RSP_GLS	(NCSI_PKT_CMD_GLS   + 0x80)
+#define NCSI_PKT_RSP_SVF	(NCSI_PKT_CMD_SVF   + 0x80)
+#define NCSI_PKT_RSP_EV		(NCSI_PKT_CMD_EV    + 0x80)
+#define NCSI_PKT_RSP_DV		(NCSI_PKT_CMD_DV    + 0x80)
+#define NCSI_PKT_RSP_SMA	(NCSI_PKT_CMD_SMA   + 0x80)
+#define NCSI_PKT_RSP_EBF	(NCSI_PKT_CMD_EBF   + 0x80)
+#define NCSI_PKT_RSP_DBF	(NCSI_PKT_CMD_DBF   + 0x80)
+#define NCSI_PKT_RSP_EGMF	(NCSI_PKT_CMD_EGMF  + 0x80)
+#define NCSI_PKT_RSP_DGMF	(NCSI_PKT_CMD_DGMF  + 0x80)
+#define NCSI_PKT_RSP_SNFC	(NCSI_PKT_CMD_SNFC  + 0x80)
+#define NCSI_PKT_RSP_GVI	(NCSI_PKT_CMD_GVI   + 0x80)
+#define NCSI_PKT_RSP_GC		(NCSI_PKT_CMD_GC    + 0x80)
+#define NCSI_PKT_RSP_GP		(NCSI_PKT_CMD_GP    + 0x80)
+#define NCSI_PKT_RSP_GCPS	(NCSI_PKT_CMD_GCPS  + 0x80)
+#define NCSI_PKT_RSP_GNS	(NCSI_PKT_CMD_GNS   + 0x80)
+#define NCSI_PKT_RSP_GNPTS	(NCSI_PKT_CMD_GNPTS + 0x80)
+#define NCSI_PKT_RSP_OEM	(NCSI_PKT_CMD_OEM   + 0x80)
+
+/* NCSI response code/reason */
+#define NCSI_PKT_RSP_C_COMPLETED	0x0000  /* Command Completed        */
+#define NCSI_PKT_RSP_C_FAILED		0x0001  /* Command Failed           */
+#define NCSI_PKT_RSP_C_UNAVAILABLE	0x0002  /* Command Unavailable      */
+#define NCSI_PKT_RSP_C_UNSUPPORTED	0x0003  /* Command Unsupported      */
+#define NCSI_PKT_RSP_R_NO_ERROR		0x0000  /* No Error                 */
+#define NCSI_PKT_RSP_R_INTERFACE	0x0001  /* Interface not ready      */
+#define NCSI_PKT_RSP_R_PARAM		0x0002  /* Invalid Parameter        */
+#define NCSI_PKT_RSP_R_CHANNEL		0x0003  /* Channel not Ready        */
+#define NCSI_PKT_RSP_R_PACKAGE		0x0004  /* Package not Ready        */
+#define NCSI_PKT_RSP_R_LENGTH		0x0005  /* Invalid payload length   */
+#define NCSI_PKT_RSP_R_UNKNOWN		0x7fff  /* Command type unsupported */
+
 #endif /* __NCSI_PKT_H__ */
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
new file mode 100644
index 0000000..20a45dc
--- /dev/null
+++ b/net/ncsi/ncsi-rsp.c
@@ -0,0 +1,987 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2016.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+#include <net/ncsi.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "internal.h"
+#include "ncsi-pkt.h"
+
+static int ncsi_validate_rsp_pkt(struct ncsi_req *nr,
+				 unsigned short payload)
+{
+	struct ncsi_rsp_pkt_hdr *h;
+	u32 checksum;
+	__be32 *pchecksum;
+
+	/* Check NCSI packet header. We don't need validate
+	 * the packet type, which should have been checked
+	 * before calling this function.
+	 */
+	h = (struct ncsi_rsp_pkt_hdr *)skb_network_header(nr->rsp);
+	if (h->common.revision != NCSI_PKT_REVISION)
+		return -EINVAL;
+	if (ntohs(h->common.length) != payload)
+		return -EINVAL;
+
+	/* Check on code and reason */
+	if (ntohs(h->code) != NCSI_PKT_RSP_C_COMPLETED ||
+	    ntohs(h->reason) != NCSI_PKT_RSP_R_NO_ERROR)
+		return -EINVAL;
+
+	/* Validate checksum, which might be zeroes if the
+	 * sender doesn't support checksum according to NCSI
+	 * specification.
+	 */
+	pchecksum = (__be32 *)((void *)(h + 1) + payload - 4);
+	if (ntohl(*pchecksum) == 0)
+		return 0;
+
+	checksum = ncsi_calculate_checksum((unsigned char *)h,
+					   sizeof(*h) + payload - 4);
+	if (*pchecksum != htonl(checksum))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_cis(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	unsigned char id;
+
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel, &np, &nc);
+	if (!nc) {
+		id = NCSI_CHANNEL_INDEX(rsp->rsp.common.channel);
+		nc = ncsi_add_channel(np, id);
+	} else if (nc->state == ncsi_channel_state_deselected_initial) {
+		nc->state = ncsi_channel_state_deselected_ready;
+	} else if (nc->state == ncsi_channel_state_selected_initial) {
+		nc->state = ncsi_channel_state_selected_ready;
+	}
+
+	return nc ? 0 : -ENODEV;
+}
+
+static int ncsi_rsp_handler_sp(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	unsigned char id;
+
+	/* Add the package if it's not existing. Otherwise,
+	 * to change the state of its child channels.
+	 */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      &np, NULL);
+	if (!np) {
+		id = NCSI_PACKAGE_INDEX(rsp->rsp.common.channel);
+		np = ncsi_add_package(ndp, id);
+		if (!np)
+			return -ENODEV;
+	}
+
+	NCSI_FOR_EACH_CHANNEL(np, nc) {
+		if (nc->state == ncsi_channel_state_deselected_initial)
+			nc->state = ncsi_channel_state_selected_initial;
+		else if (nc->state == ncsi_channel_state_deselected_ready)
+			nc->state = ncsi_channel_state_selected_ready;
+	}
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_dp(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+
+	/* Find the package */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      &np, NULL);
+	if (!np)
+		return -ENODEV;
+
+	/* Change state of all channels attached to the package */
+	NCSI_FOR_EACH_CHANNEL(np, nc) {
+		if (nc->state == ncsi_channel_state_selected_initial)
+			nc->state = ncsi_channel_state_deselected_initial;
+		else if (nc->state == ncsi_channel_state_selected_ready)
+			nc->state = ncsi_channel_state_deselected_ready;
+	}
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_ec(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	ncm = &nc->modes[NCSI_MODE_ENABLE];
+	if (ncm->enable)
+		return -EBUSY;
+
+	ncm->enable = 1;
+	return 0;
+}
+
+static int ncsi_rsp_handler_dc(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+	int ret;
+
+	ret = ncsi_validate_rsp_pkt(nr, 4);
+	if (ret)
+		return ret;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	ncm = &nc->modes[NCSI_MODE_ENABLE];
+	if (!ncm->enable)
+		return -EBUSY;
+
+	ncm->enable = 0;
+	return 0;
+}
+
+static int ncsi_rsp_handler_rc(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update state for the specified channel */
+	if (nc->state == ncsi_channel_state_deselected_ready)
+		nc->state = ncsi_channel_state_deselected_initial;
+	else if (nc->state == ncsi_channel_state_selected_ready)
+		nc->state = ncsi_channel_state_selected_initial;
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_ecnt(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	ncm = &nc->modes[NCSI_MODE_TX_ENABLE];
+	if (ncm->enable)
+		return -EBUSY;
+
+	ncm->enable = 1;
+	return 0;
+}
+
+static int ncsi_rsp_handler_dcnt(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	ncm = &nc->modes[NCSI_MODE_TX_ENABLE];
+	if (!ncm->enable)
+		return -EBUSY;
+
+	ncm->enable = 1;
+	return 0;
+}
+
+static int ncsi_rsp_handler_ae(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_ae_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if the AEN has been enabled */
+	ncm = &nc->modes[NCSI_MODE_AEN];
+	if (ncm->enable)
+		return -EBUSY;
+
+	/* Update to AEN configuration */
+	cmd = (struct ncsi_cmd_ae_pkt *)skb_network_header(nr->cmd);
+	ncm->enable = 1;
+	ncm->data[0] = cmd->mc_id;
+	ncm->data[1] = ntohl(cmd->mode);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_sl(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_sl_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	cmd = (struct ncsi_cmd_sl_pkt *)skb_network_header(nr->cmd);
+	ncm = &nc->modes[NCSI_MODE_LINK];
+	ncm->data[0] = ntohl(cmd->mode);
+	ncm->data[1] = ntohl(cmd->oem_mode);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gls(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gls_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_gls_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	ncm = &nc->modes[NCSI_MODE_LINK];
+	ncm->data[2] = ntohl(rsp->status);
+	ncm->data[3] = ntohl(rsp->other);
+	ncm->data[4] = ntohl(rsp->oem_status);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_svf(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_svf_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_filter *ncf;
+	unsigned short vlan;
+	int ret;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	cmd = (struct ncsi_cmd_svf_pkt *)skb_network_header(nr->cmd);
+	ncf = nc->filters[NCSI_FILTER_VLAN];
+	if (!ncf)
+		return -ENOENT;
+	if (cmd->index >= ncf->total)
+		return -ERANGE;
+
+	/* Add or remove the VLAN filter */
+	if (!(cmd->enable & 0x1)) {
+		ret = ncsi_remove_filter(nc, NCSI_FILTER_VLAN, cmd->index);
+	} else {
+		vlan = ntohs(cmd->vlan);
+		ret = ncsi_add_filter(nc, NCSI_FILTER_VLAN, &vlan);
+	}
+
+	return ret;
+}
+
+static int ncsi_rsp_handler_ev(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_ev_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if VLAN mode has been enabled */
+	ncm = &nc->modes[NCSI_MODE_VLAN];
+	if (ncm->enable)
+		return -EBUSY;
+
+	/* Update to VLAN mode */
+	cmd = (struct ncsi_cmd_ev_pkt *)skb_network_header(nr->cmd);
+	ncm->enable = 1;
+	ncm->data[0] = ntohl(cmd->mode);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_dv(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if VLAN mode has been enabled */
+	ncm = &nc->modes[NCSI_MODE_VLAN];
+	if (!ncm->enable)
+		return -EBUSY;
+
+	/* Update to VLAN mode */
+	ncm->enable = 0;
+	return 0;
+}
+
+static int ncsi_rsp_handler_sma(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_sma_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_filter *ncf;
+	void *bitmap;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* According to NCSI spec 1.01, the mixed filter table
+	 * isn't supported yet.
+	 */
+	cmd = (struct ncsi_cmd_sma_pkt *)skb_network_header(nr->cmd);
+	switch (cmd->at_e >> 5) {
+	case 0x0:	/* UC address */
+		ncf = nc->filters[NCSI_FILTER_UC];
+		break;
+	case 0x1:	/* MC address */
+		ncf = nc->filters[NCSI_FILTER_MC];
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Sanity check on the filter */
+	if (!ncf)
+		return -ENOENT;
+	else if (cmd->index >= ncf->total)
+		return -ERANGE;
+
+	bitmap = &ncf->bitmap;
+	if (cmd->at_e & 0x1) {
+		if (test_and_set_bit(cmd->index, bitmap))
+			return -EBUSY;
+		memcpy(ncf->data + 6 * cmd->index, cmd->mac, 6);
+	} else {
+		if (!test_and_clear_bit(cmd->index, bitmap))
+			return -EBUSY;
+
+		memset(ncf->data + 6 * cmd->index, 0, 6);
+	}
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_ebf(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_ebf_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the package and channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel, NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if broadcast filter has been enabled */
+	ncm = &nc->modes[NCSI_MODE_BC];
+	if (ncm->enable)
+		return -EBUSY;
+
+	/* Update to broadcast filter mode */
+	cmd = (struct ncsi_cmd_ebf_pkt *)skb_network_header(nr->cmd);
+	ncm->enable = 1;
+	ncm->data[0] = ntohl(cmd->mode);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_dbf(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if broadcast filter isn't enabled */
+	ncm = &nc->modes[NCSI_MODE_BC];
+	if (!ncm->enable)
+		return -EBUSY;
+
+	/* Update to broadcast filter mode */
+	ncm->enable = 0;
+	ncm->data[0] = 0;
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_egmf(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_egmf_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if multicast filter has been enabled */
+	ncm = &nc->modes[NCSI_MODE_MC];
+	if (ncm->enable)
+		return -EBUSY;
+
+	/* Update to multicast filter mode */
+	cmd = (struct ncsi_cmd_egmf_pkt *)skb_network_header(nr->cmd);
+	ncm->enable = 1;
+	ncm->data[0] = ntohl(cmd->mode);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_dgmf(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if multicast filter has been enabled */
+	ncm = &nc->modes[NCSI_MODE_MC];
+	if (!ncm->enable)
+		return -EBUSY;
+
+	/* Update to multicast filter mode */
+	ncm->enable = 0;
+	ncm->data[0] = 0;
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_snfc(struct ncsi_req *nr)
+{
+	struct ncsi_cmd_snfc_pkt *cmd;
+	struct ncsi_rsp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Check if flow control has been enabled */
+	ncm = &nc->modes[NCSI_MODE_FC];
+	if (ncm->enable)
+		return -EBUSY;
+
+	/* Update to flow control mode */
+	cmd = (struct ncsi_cmd_snfc_pkt *)skb_network_header(nr->cmd);
+	ncm->enable = 1;
+	ncm->data[0] = cmd->mode;
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gvi(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gvi_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_version *ncv;
+	int i;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gvi_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update to channel's version info */
+	ncv = &nc->version;
+	ncv->version = ntohl(rsp->ncsi_version);
+	ncv->alpha2 = rsp->alpha2;
+	memcpy(ncv->fw_name, rsp->fw_name, 12);
+	ncv->fw_version = ntohl(rsp->fw_version);
+	for (i = 0; i < ARRAY_SIZE(ncv->pci_ids); i++)
+		ncv->pci_ids[i] = ntohs(rsp->pci_ids[i]);
+	ncv->mf_id = ntohl(rsp->mf_id);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gc(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gc_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_filter *ncf;
+	size_t size, entry_size;
+	int cnt, i;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gc_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update channel's capabilities */
+	nc->caps[NCSI_CAP_GENERIC].cap = ntohl(rsp->cap) &
+					 NCSI_CAP_GENERIC_MASK;
+	nc->caps[NCSI_CAP_BC].cap = ntohl(rsp->bc_cap) &
+				    NCSI_CAP_BC_MASK;
+	nc->caps[NCSI_CAP_MC].cap = ntohl(rsp->mc_cap) &
+				    NCSI_CAP_MC_MASK;
+	nc->caps[NCSI_CAP_BUFFER].cap = ntohl(rsp->buf_cap);
+	nc->caps[NCSI_CAP_AEN].cap = ntohl(rsp->aen_cap) &
+				     NCSI_CAP_AEN_MASK;
+	nc->caps[NCSI_CAP_VLAN].cap = rsp->vlan_mode &
+				      NCSI_CAP_VLAN_MASK;
+
+	/* Build filters */
+	for (i = 0; i < NCSI_FILTER_MAX; i++) {
+		switch (i) {
+		case NCSI_FILTER_VLAN:
+			cnt = rsp->vlan_cnt;
+			entry_size = 2;
+			break;
+		case NCSI_FILTER_MIXED:
+			cnt = rsp->mixed_cnt;
+			entry_size = 6;
+			break;
+		case NCSI_FILTER_MC:
+			cnt = rsp->mc_cnt;
+			entry_size = 6;
+			break;
+		case NCSI_FILTER_UC:
+			cnt = rsp->uc_cnt;
+			entry_size = 6;
+			break;
+		default:
+			continue;
+		}
+
+		if (!cnt || nc->filters[i])
+			continue;
+
+		size = sizeof(*ncf) + cnt * entry_size;
+		ncf = kzalloc(size, GFP_ATOMIC);
+		if (!ncf) {
+			pr_warn("%s: Cannot alloc filter table (%d)\n",
+				__func__, i);
+			return -ENOMEM;
+		}
+
+		ncf->index = i;
+		ncf->total = cnt;
+		ncf->bitmap = 0x0ul;
+		nc->filters[i] = ncf;
+	}
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gp(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gp_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	unsigned short enable, vlan;
+	unsigned char *pdata;
+	int table, i;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gp_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Modes with explicit enabled indications */
+	if (ntohl(rsp->valid_modes) & 0x1) {	/* BC filter mode */
+		nc->modes[NCSI_MODE_BC].enable = 1;
+		nc->modes[NCSI_MODE_BC].data[0] = ntohl(rsp->bc_mode);
+	}
+	if (ntohl(rsp->valid_modes) & 0x2)	/* Channel enabled */
+		nc->modes[NCSI_MODE_ENABLE].enable = 1;
+	if (ntohl(rsp->valid_modes) & 0x4)	/* Channel Tx enabled */
+		nc->modes[NCSI_MODE_TX_ENABLE].enable = 1;
+	if (ntohl(rsp->valid_modes) & 0x8)	/* MC filter mode */
+		nc->modes[NCSI_MODE_MC].enable = 1;
+
+	/* Modes without explicit enabled indications */
+	nc->modes[NCSI_MODE_LINK].enable = 1;
+	nc->modes[NCSI_MODE_LINK].data[0] = ntohl(rsp->link_mode);
+	nc->modes[NCSI_MODE_VLAN].enable = 1;
+	nc->modes[NCSI_MODE_VLAN].data[0] = rsp->vlan_mode;
+	nc->modes[NCSI_MODE_FC].enable = 1;
+	nc->modes[NCSI_MODE_FC].data[0] = rsp->fc_mode;
+	nc->modes[NCSI_MODE_AEN].enable = 1;
+	nc->modes[NCSI_MODE_AEN].data[0] = ntohl(rsp->aen_mode);
+
+	/* MAC addresses filter table */
+	pdata = (unsigned char *)rsp + 48;
+	enable = rsp->mac_enable;
+	for (i = 0; i < rsp->mac_cnt; i++, pdata += 6) {
+		if (i >= (nc->filters[NCSI_FILTER_UC]->total +
+			  nc->filters[NCSI_FILTER_MC]->total))
+			table = NCSI_FILTER_MIXED;
+		else if (i >= nc->filters[NCSI_FILTER_UC]->total)
+			table = NCSI_FILTER_MC;
+		else
+			table = NCSI_FILTER_UC;
+
+		if (!(enable & (0x1 << i)))
+			continue;
+
+		if (ncsi_find_filter(nc, table, pdata) >= 0)
+			continue;
+
+		ncsi_add_filter(nc, table, pdata);
+	}
+
+	/* VLAN filter table */
+	enable = ntohs(rsp->vlan_enable);
+	for (i = 0; i < rsp->vlan_cnt; i++, pdata += 2) {
+		if (!(enable & (0x1 << i)))
+			continue;
+
+		vlan = ntohs(*(__be16 *)pdata);
+		if (ncsi_find_filter(nc, NCSI_FILTER_VLAN, &vlan) >= 0)
+			continue;
+
+		ncsi_add_filter(nc, NCSI_FILTER_VLAN, &vlan);
+	}
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gcps(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gcps_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_stats *ncs;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gcps_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update HNC's statistics */
+	ncs = &nc->stats;
+	ncs->hnc_cnt_hi         = ntohl(rsp->cnt_hi);
+	ncs->hnc_cnt_lo         = ntohl(rsp->cnt_lo);
+	ncs->hnc_rx_bytes       = ntohl(rsp->rx_bytes);
+	ncs->hnc_tx_bytes       = ntohl(rsp->tx_bytes);
+	ncs->hnc_rx_uc_pkts     = ntohl(rsp->rx_uc_pkts);
+	ncs->hnc_rx_mc_pkts     = ntohl(rsp->rx_mc_pkts);
+	ncs->hnc_rx_bc_pkts     = ntohl(rsp->rx_bc_pkts);
+	ncs->hnc_tx_uc_pkts     = ntohl(rsp->tx_uc_pkts);
+	ncs->hnc_tx_mc_pkts     = ntohl(rsp->tx_mc_pkts);
+	ncs->hnc_tx_bc_pkts     = ntohl(rsp->tx_bc_pkts);
+	ncs->hnc_fcs_err        = ntohl(rsp->fcs_err);
+	ncs->hnc_align_err      = ntohl(rsp->align_err);
+	ncs->hnc_false_carrier  = ntohl(rsp->false_carrier);
+	ncs->hnc_runt_pkts      = ntohl(rsp->runt_pkts);
+	ncs->hnc_jabber_pkts    = ntohl(rsp->jabber_pkts);
+	ncs->hnc_rx_pause_xon   = ntohl(rsp->rx_pause_xon);
+	ncs->hnc_rx_pause_xoff  = ntohl(rsp->rx_pause_xoff);
+	ncs->hnc_tx_pause_xon   = ntohl(rsp->tx_pause_xon);
+	ncs->hnc_tx_pause_xoff  = ntohl(rsp->tx_pause_xoff);
+	ncs->hnc_tx_s_collision = ntohl(rsp->tx_s_collision);
+	ncs->hnc_tx_m_collision = ntohl(rsp->tx_m_collision);
+	ncs->hnc_l_collision    = ntohl(rsp->l_collision);
+	ncs->hnc_e_collision    = ntohl(rsp->e_collision);
+	ncs->hnc_rx_ctl_frames  = ntohl(rsp->rx_ctl_frames);
+	ncs->hnc_rx_64_frames   = ntohl(rsp->rx_64_frames);
+	ncs->hnc_rx_127_frames  = ntohl(rsp->rx_127_frames);
+	ncs->hnc_rx_255_frames  = ntohl(rsp->rx_255_frames);
+	ncs->hnc_rx_511_frames  = ntohl(rsp->rx_511_frames);
+	ncs->hnc_rx_1023_frames = ntohl(rsp->rx_1023_frames);
+	ncs->hnc_rx_1522_frames = ntohl(rsp->rx_1522_frames);
+	ncs->hnc_rx_9022_frames = ntohl(rsp->rx_9022_frames);
+	ncs->hnc_tx_64_frames   = ntohl(rsp->tx_64_frames);
+	ncs->hnc_tx_127_frames  = ntohl(rsp->tx_127_frames);
+	ncs->hnc_tx_255_frames  = ntohl(rsp->tx_255_frames);
+	ncs->hnc_tx_511_frames  = ntohl(rsp->tx_511_frames);
+	ncs->hnc_tx_1023_frames = ntohl(rsp->tx_1023_frames);
+	ncs->hnc_tx_1522_frames = ntohl(rsp->tx_1522_frames);
+	ncs->hnc_tx_9022_frames = ntohl(rsp->tx_9022_frames);
+	ncs->hnc_rx_valid_bytes = ntohl(rsp->rx_valid_bytes);
+	ncs->hnc_rx_runt_pkts   = ntohl(rsp->rx_runt_pkts);
+	ncs->hnc_rx_jabber_pkts = ntohl(rsp->rx_jabber_pkts);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gns(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gns_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_stats *ncs;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gns_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update HNC's statistics */
+	ncs = &nc->stats;
+	ncs->ncsi_rx_cmds       = ntohl(rsp->rx_cmds);
+	ncs->ncsi_dropped_cmds  = ntohl(rsp->dropped_cmds);
+	ncs->ncsi_cmd_type_errs = ntohl(rsp->cmd_type_errs);
+	ncs->ncsi_cmd_csum_errs = ntohl(rsp->cmd_csum_errs);
+	ncs->ncsi_rx_pkts       = ntohl(rsp->rx_pkts);
+	ncs->ncsi_tx_pkts       = ntohl(rsp->tx_pkts);
+	ncs->ncsi_tx_aen_pkts   = ntohl(rsp->tx_aen_pkts);
+
+	return 0;
+}
+
+static int ncsi_rsp_handler_gnpts(struct ncsi_req *nr)
+{
+	struct ncsi_rsp_gnpts_pkt *rsp;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_stats *ncs;
+
+	/* Find the channel */
+	rsp = (struct ncsi_rsp_gnpts_pkt *)skb_network_header(nr->rsp);
+	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
+				      NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update HNC's statistics */
+	ncs = &nc->stats;
+	ncs->pt_tx_pkts        = ntohl(rsp->tx_pkts);
+	ncs->pt_tx_dropped     = ntohl(rsp->tx_dropped);
+	ncs->pt_tx_channel_err = ntohl(rsp->tx_channel_err);
+	ncs->pt_tx_us_err      = ntohl(rsp->tx_us_err);
+	ncs->pt_rx_pkts        = ntohl(rsp->rx_pkts);
+	ncs->pt_rx_dropped     = ntohl(rsp->rx_dropped);
+	ncs->pt_rx_channel_err = ntohl(rsp->rx_channel_err);
+	ncs->pt_rx_us_err      = ntohl(rsp->rx_us_err);
+	ncs->pt_rx_os_err      = ntohl(rsp->rx_os_err);
+
+	return 0;
+}
+
+static struct ncsi_rsp_handler {
+	unsigned char	type;
+	int             payload;
+	int		(*handler)(struct ncsi_req *nr);
+} ncsi_rsp_handlers[] = {
+	{ NCSI_PKT_RSP_CIS,     4, ncsi_rsp_handler_cis     },
+	{ NCSI_PKT_RSP_SP,      4, ncsi_rsp_handler_sp      },
+	{ NCSI_PKT_RSP_DP,      4, ncsi_rsp_handler_dp      },
+	{ NCSI_PKT_RSP_EC,      4, ncsi_rsp_handler_ec      },
+	{ NCSI_PKT_RSP_DC,      4, ncsi_rsp_handler_dc      },
+	{ NCSI_PKT_RSP_RC,      4, ncsi_rsp_handler_rc      },
+	{ NCSI_PKT_RSP_ECNT,    4, ncsi_rsp_handler_ecnt    },
+	{ NCSI_PKT_RSP_DCNT,    4, ncsi_rsp_handler_dcnt    },
+	{ NCSI_PKT_RSP_AE,      4, ncsi_rsp_handler_ae      },
+	{ NCSI_PKT_RSP_SL,      4, ncsi_rsp_handler_sl      },
+	{ NCSI_PKT_RSP_GLS,    16, ncsi_rsp_handler_gls     },
+	{ NCSI_PKT_RSP_SVF,     4, ncsi_rsp_handler_svf     },
+	{ NCSI_PKT_RSP_EV,      4, ncsi_rsp_handler_ev      },
+	{ NCSI_PKT_RSP_DV,      4, ncsi_rsp_handler_dv      },
+	{ NCSI_PKT_RSP_SMA,     4, ncsi_rsp_handler_sma     },
+	{ NCSI_PKT_RSP_EBF,     4, ncsi_rsp_handler_ebf     },
+	{ NCSI_PKT_RSP_DBF,     4, ncsi_rsp_handler_dbf     },
+	{ NCSI_PKT_RSP_EGMF,    4, ncsi_rsp_handler_egmf    },
+	{ NCSI_PKT_RSP_DGMF,    4, ncsi_rsp_handler_dgmf    },
+	{ NCSI_PKT_RSP_SNFC,    4, ncsi_rsp_handler_snfc    },
+	{ NCSI_PKT_RSP_GVI,    36, ncsi_rsp_handler_gvi     },
+	{ NCSI_PKT_RSP_GC,     32, ncsi_rsp_handler_gc      },
+	{ NCSI_PKT_RSP_GP,     -1, ncsi_rsp_handler_gp      },
+	{ NCSI_PKT_RSP_GCPS,  172, ncsi_rsp_handler_gcps    },
+	{ NCSI_PKT_RSP_GNS,   172, ncsi_rsp_handler_gns     },
+	{ NCSI_PKT_RSP_GNPTS, 172, ncsi_rsp_handler_gnpts   },
+	{ NCSI_PKT_RSP_OEM,     0, NULL                     },
+};
+
+int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct ncsi_rsp_handler *nrh = NULL;
+	struct ncsi_dev *nd;
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_req *nr;
+	struct ncsi_pkt_hdr *hdr;
+	unsigned long flags;
+	int payload, ret;
+
+	/* Find the NCSI device */
+	nd = ncsi_find_dev(dev);
+	ndp = nd ? TO_NCSI_DEV_PRIV(nd) : NULL;
+	if (!ndp)
+		return -ENODEV;
+
+	/* Find the handler */
+	hdr = (struct ncsi_pkt_hdr *)skb_network_header(skb);
+	nrh = ncsi_rsp_handlers;
+	while (nrh->handler) {
+		if (nrh->type == hdr->type)
+			break;
+
+		nrh++;
+	}
+
+	if (!nrh->handler) {
+		pr_warn("NCSI: Received unrecognized packet (0x%x)\n",
+			hdr->type);
+		return -ENOENT;
+	}
+
+	/* Associate with the request */
+	nr = &ndp->reqs[hdr->id];
+	spin_lock_irqsave(&ndp->req_lock, flags);
+	if (!nr->used) {
+		spin_unlock_irqrestore(&ndp->req_lock, flags);
+		return -ENODEV;
+	}
+
+	nr->rsp = skb;
+	if (!nr->timer_enabled) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	/* Validate the packet */
+	payload = nrh->payload;
+	if (payload < 0)
+		payload = ntohs(hdr->length);
+	ret = ncsi_validate_rsp_pkt(nr, payload);
+	if (ret)
+		goto out;
+
+	/* Process the packet */
+	ret = nrh->handler(nr);
+out:
+	spin_unlock_irqrestore(&ndp->req_lock, flags);
+	ncsi_free_req(nr, true, false);
+	return ret;
+}
-- 
2.1.0
