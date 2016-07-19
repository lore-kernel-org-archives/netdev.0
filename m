From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 02/10] net/ncsi: NCSI command packet handler
Date: Tue, 19 Jul 2016 11:54:17 +1000
Message-ID: <1468893265-10635-3-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:5062 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752310AbcGSByh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:37 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sNS9083741
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:35 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2496eb6p87-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:34 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:31 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DB40E3578056
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sSWH23003200
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sRat005407
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NCSI command packets are sent from MC (Management Controller)
to remote end. They are used for multiple purposes: probe existing
NCSI package/channel, retrieve NCSI channel's capability, configure
NCSI channel etc.

This defines struct to represent NCSI command packets and introduces
function ncsi_xmit_cmd(), which will be used to transmit NCSI command
packet according to the request. The request is represented by struct
ncsi_cmd_arg.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 include/uapi/linux/if_ether.h |   1 +
 net/ncsi/Makefile             |   2 +-
 net/ncsi/internal.h           |  19 +++
 net/ncsi/ncsi-cmd.c           | 367 ++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h           | 171 ++++++++++++++++++++
 5 files changed, 559 insertions(+), 1 deletion(-)
 create mode 100644 net/ncsi/ncsi-cmd.c
 create mode 100644 net/ncsi/ncsi-pkt.h

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index cec849a..117d02e 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -87,6 +87,7 @@
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
 #define ETH_P_MVRP	0x88F5          /* 802.1Q MVRP                  */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
+#define ETH_P_NCSI	0x88F8		/* NCSI protocol		*/
 #define ETH_P_PRP	0x88FB		/* IEC 62439-3 PRP/HSRv0	*/
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index 07b5625..abc4046 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -1,4 +1,4 @@
 #
 # Makefile for NCSI API
 #
-obj-$(CONFIG_NET_NCSI) += ncsi-manage.o
+obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-manage.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 89028e1..3d81697 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -220,6 +220,21 @@ struct ncsi_dev_priv {
 	struct list_head    node;            /* Form NCSI device list      */
 };
 
+struct ncsi_cmd_arg {
+	struct ncsi_dev_priv *ndp;        /* Associated NCSI device        */
+	unsigned char        type;        /* Command in the NCSI packet    */
+	unsigned char        id;          /* Request ID (sequence number)  */
+	unsigned char        package;     /* Destination package ID        */
+	unsigned char        channel;     /* Detination channel ID or 0x1f */
+	unsigned short       payload;     /* Command packet payload length */
+	bool                 driven;      /* Drive the state machine?      */
+	union {
+		unsigned char  bytes[16]; /* Command packet specific data  */
+		unsigned short words[8];
+		unsigned int   dwords[4];
+	};
+};
+
 extern struct list_head ncsi_dev_list;
 extern spinlock_t ncsi_dev_lock;
 
@@ -253,4 +268,8 @@ struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven);
 void ncsi_free_request(struct ncsi_request *nr);
 struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
 
+/* Packet handlers */
+u32 ncsi_calculate_checksum(unsigned char *data, int len);
+int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca);
+
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
new file mode 100644
index 0000000..21057a8
--- /dev/null
+++ b/net/ncsi/ncsi-cmd.c
@@ -0,0 +1,367 @@
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
+#include <linux/etherdevice.h>
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
+u32 ncsi_calculate_checksum(unsigned char *data, int len)
+{
+	u32 checksum = 0;
+	int i;
+
+	for (i = 0; i < len; i += 2)
+		checksum += (((u32)data[i] << 8) | data[i + 1]);
+
+	checksum = (~checksum + 1);
+	return checksum;
+}
+
+/* This function should be called after the data area has been
+ * populated completely.
+ */
+static void ncsi_cmd_build_header(struct ncsi_pkt_hdr *h,
+				  struct ncsi_cmd_arg *nca)
+{
+	u32 checksum;
+	__be32 *pchecksum;
+
+	h->mc_id        = 0;
+	h->revision     = NCSI_PKT_REVISION;
+	h->reserved     = 0;
+	h->id           = nca->id;
+	h->type         = nca->type;
+	h->channel      = NCSI_TO_CHANNEL(nca->package,
+					  nca->channel);
+	h->length       = htons(nca->payload);
+	h->reserved1[0] = 0;
+	h->reserved1[1] = 0;
+
+	/* Fill with calculated checksum */
+	checksum = ncsi_calculate_checksum((unsigned char *)h,
+					   sizeof(*h) + nca->payload);
+	pchecksum = (__be32 *)((void *)h + sizeof(struct ncsi_pkt_hdr) +
+		    nca->payload);
+	*pchecksum = htonl(checksum);
+}
+
+static int ncsi_cmd_handler_default(struct sk_buff *skb,
+				    struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_sp(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_sp_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_sp_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->hw_arbitration = nca->bytes[0];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_dc(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_dc_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_dc_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->ald = nca->bytes[0];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_rc(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_rc_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_rc_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_ae(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_ae_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_ae_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mc_id = nca->bytes[0];
+	cmd->mode = htonl(nca->dwords[1]);
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_sl(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_sl_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_sl_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mode = htonl(nca->dwords[0]);
+	cmd->oem_mode = htonl(nca->dwords[1]);
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_svf(struct sk_buff *skb,
+				struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_svf_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_svf_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->vlan = htons(nca->words[0]);
+	cmd->index = nca->bytes[2];
+	cmd->enable = nca->bytes[3];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_ev(struct sk_buff *skb,
+			       struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_ev_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_ev_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mode = nca->bytes[0];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_sma(struct sk_buff *skb,
+				struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_sma_pkt *cmd;
+	int i;
+
+	cmd = (struct ncsi_cmd_sma_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	for (i = 0; i < 6; i++)
+		cmd->mac[i] = nca->bytes[i];
+	cmd->index = nca->bytes[6];
+	cmd->at_e = nca->bytes[7];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_ebf(struct sk_buff *skb,
+				struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_ebf_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_ebf_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mode = htonl(nca->dwords[0]);
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_egmf(struct sk_buff *skb,
+				 struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_egmf_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_egmf_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mode = htonl(nca->dwords[0]);
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static int ncsi_cmd_handler_snfc(struct sk_buff *skb,
+				 struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_cmd_snfc_pkt *cmd;
+
+	cmd = (struct ncsi_cmd_snfc_pkt *)skb_put(skb, sizeof(*cmd));
+	memset(cmd, 0, sizeof(*cmd));
+	cmd->mode = nca->bytes[0];
+	ncsi_cmd_build_header(&cmd->cmd.common, nca);
+
+	return 0;
+}
+
+static struct ncsi_cmd_handler {
+	unsigned char type;
+	int           payload;
+	int           (*handler)(struct sk_buff *skb,
+				 struct ncsi_cmd_arg *nca);
+} ncsi_cmd_handlers[] = {
+	{ NCSI_PKT_CMD_CIS,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_SP,     4, ncsi_cmd_handler_sp      },
+	{ NCSI_PKT_CMD_DP,     0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_EC,     0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_DC,     4, ncsi_cmd_handler_dc      },
+	{ NCSI_PKT_CMD_RC,     4, ncsi_cmd_handler_rc      },
+	{ NCSI_PKT_CMD_ECNT,   0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_DCNT,   0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_AE,     8, ncsi_cmd_handler_ae      },
+	{ NCSI_PKT_CMD_SL,     8, ncsi_cmd_handler_sl      },
+	{ NCSI_PKT_CMD_GLS,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_SVF,    4, ncsi_cmd_handler_svf     },
+	{ NCSI_PKT_CMD_EV,     4, ncsi_cmd_handler_ev      },
+	{ NCSI_PKT_CMD_DV,     0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_SMA,    8, ncsi_cmd_handler_sma     },
+	{ NCSI_PKT_CMD_EBF,    4, ncsi_cmd_handler_ebf     },
+	{ NCSI_PKT_CMD_DBF,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_EGMF,   4, ncsi_cmd_handler_egmf    },
+	{ NCSI_PKT_CMD_DGMF,   0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_SNFC,   4, ncsi_cmd_handler_snfc    },
+	{ NCSI_PKT_CMD_GVI,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GC,     0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GP,     0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GCPS,   0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GNS,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GNPTS,  0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_GPS,    0, ncsi_cmd_handler_default },
+	{ NCSI_PKT_CMD_OEM,    0, NULL                     },
+	{ NCSI_PKT_CMD_PLDM,   0, NULL                     },
+	{ NCSI_PKT_CMD_GPUUID, 0, ncsi_cmd_handler_default }
+};
+
+static struct ncsi_request *ncsi_alloc_command(struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_dev_priv *ndp = nca->ndp;
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct net_device *dev = nd->dev;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
+	int len = hlen + tlen;
+	struct sk_buff *skb;
+	struct ncsi_request *nr;
+
+	nr = ncsi_alloc_request(ndp, nca->driven);
+	if (!nr)
+		return NULL;
+
+	/* NCSI command packet has 16-bytes header, payload, 4 bytes checksum.
+	 * The packet needs padding if its payload is less than 26 bytes to
+	 * meet 64 bytes minimal ethernet frame length.
+	 */
+	len += sizeof(struct ncsi_cmd_pkt_hdr) + 4;
+	if (nca->payload < 26)
+		len += 26;
+	else
+		len += nca->payload;
+
+	/* Allocate skb */
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		ncsi_free_request(nr);
+		return NULL;
+	}
+
+	nr->cmd = skb;
+	skb_reserve(skb, hlen);
+	skb_reset_network_header(skb);
+
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_NCSI);
+
+	return nr;
+}
+
+int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
+{
+	struct ncsi_request *nr;
+	struct ethhdr *eh;
+	struct ncsi_cmd_handler *nch = NULL;
+	int i, ret;
+
+	/* Search for the handler */
+	for (i = 0; i < ARRAY_SIZE(ncsi_cmd_handlers); i++) {
+		if (ncsi_cmd_handlers[i].type == nca->type) {
+			if (ncsi_cmd_handlers[i].handler)
+				nch = &ncsi_cmd_handlers[i];
+			else
+				nch = NULL;
+
+			break;
+		}
+	}
+
+	if (!nch) {
+		netdev_err(nca->ndp->ndev.dev,
+			   "Cannot send packet with type 0x%02x\n", nca->type);
+		return -ENOENT;
+	}
+
+	/* Get packet payload length and allocate the request */
+	nca->payload = nch->payload;
+	nr = ncsi_alloc_command(nca);
+	if (!nr)
+		return -ENOMEM;
+
+	/* Prepare the packet */
+	nca->id = nr->id;
+	ret = nch->handler(nr->cmd, nca);
+	if (ret) {
+		ncsi_free_request(nr);
+		return ret;
+	}
+
+	/* Fill the ethernet header */
+	eh = (struct ethhdr *)skb_push(nr->cmd, sizeof(*eh));
+	eh->h_proto = htons(ETH_P_NCSI);
+	eth_broadcast_addr(eh->h_dest);
+	eth_broadcast_addr(eh->h_source);
+
+	/* Start the timer for the request that might not have
+	 * corresponding response. Given NCSI is an internal
+	 * connection a 1 second delay should be sufficient.
+	 */
+	nr->enabled = true;
+	mod_timer(&nr->timer, jiffies + 1 * HZ);
+
+	/* Send NCSI packet */
+	skb_get(nr->cmd);
+	ret = dev_queue_xmit(nr->cmd);
+	if (ret < 0) {
+		ncsi_free_request(nr);
+		return ret;
+	}
+
+	return 0;
+}
diff --git a/net/ncsi/ncsi-pkt.h b/net/ncsi/ncsi-pkt.h
new file mode 100644
index 0000000..5481458
--- /dev/null
+++ b/net/ncsi/ncsi-pkt.h
@@ -0,0 +1,171 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2016.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __NCSI_PKT_H__
+#define __NCSI_PKT_H__
+
+struct ncsi_pkt_hdr {
+	unsigned char mc_id;        /* Management controller ID */
+	unsigned char revision;     /* NCSI version - 0x01      */
+	unsigned char reserved;     /* Reserved                 */
+	unsigned char id;           /* Packet sequence number   */
+	unsigned char type;         /* Packet type              */
+	unsigned char channel;      /* Network controller ID    */
+	__be16        length;       /* Payload length           */
+	__be32        reserved1[2]; /* Reserved                 */
+};
+
+struct ncsi_cmd_pkt_hdr {
+	struct ncsi_pkt_hdr common; /* Common NCSI packet header */
+};
+
+/* NCSI common command packet */
+struct ncsi_cmd_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
+	__be32                  checksum; /* Checksum       */
+	unsigned char           pad[26];
+};
+
+/* Select Package */
+struct ncsi_cmd_sp_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;            /* Command header */
+	unsigned char           reserved[3];    /* Reserved       */
+	unsigned char           hw_arbitration; /* HW arbitration */
+	__be32                  checksum;       /* Checksum       */
+	unsigned char           pad[22];
+};
+
+/* Disable Channel */
+struct ncsi_cmd_dc_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;         /* Command header  */
+	unsigned char           reserved[3]; /* Reserved        */
+	unsigned char           ald;         /* Allow link down */
+	__be32                  checksum;    /* Checksum        */
+	unsigned char           pad[22];
+};
+
+/* Reset Channel */
+struct ncsi_cmd_rc_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
+	__be32                  reserved; /* Reserved       */
+	__be32                  checksum; /* Checksum       */
+	unsigned char           pad[22];
+};
+
+/* AEN Enable */
+struct ncsi_cmd_ae_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;         /* Command header   */
+	unsigned char           reserved[3]; /* Reserved         */
+	unsigned char           mc_id;       /* MC ID            */
+	__be32                  mode;        /* AEN working mode */
+	__be32                  checksum;    /* Checksum         */
+	unsigned char           pad[18];
+};
+
+/* Set Link */
+struct ncsi_cmd_sl_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header    */
+	__be32                  mode;     /* Link working mode */
+	__be32                  oem_mode; /* OEM link mode     */
+	__be32                  checksum; /* Checksum          */
+	unsigned char           pad[18];
+};
+
+/* Set VLAN Filter */
+struct ncsi_cmd_svf_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;       /* Command header    */
+	__be16                  reserved;  /* Reserved          */
+	__be16                  vlan;      /* VLAN ID           */
+	__be16                  reserved1; /* Reserved          */
+	unsigned char           index;     /* VLAN table index  */
+	unsigned char           enable;    /* Enable or disable */
+	__be32                  checksum;  /* Checksum          */
+	unsigned char           pad[14];
+};
+
+/* Enable VLAN */
+struct ncsi_cmd_ev_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;         /* Command header   */
+	unsigned char           reserved[3]; /* Reserved         */
+	unsigned char           mode;        /* VLAN filter mode */
+	__be32                  checksum;    /* Checksum         */
+	unsigned char           pad[22];
+};
+
+/* Set MAC Address */
+struct ncsi_cmd_sma_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header          */
+	unsigned char           mac[6];   /* MAC address             */
+	unsigned char           index;    /* MAC table index         */
+	unsigned char           at_e;     /* Addr type and operation */
+	__be32                  checksum; /* Checksum                */
+	unsigned char           pad[18];
+};
+
+/* Enable Broadcast Filter */
+struct ncsi_cmd_ebf_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
+	__be32                  mode;     /* Filter mode    */
+	__be32                  checksum; /* Checksum       */
+	unsigned char           pad[22];
+};
+
+/* Enable Global Multicast Filter */
+struct ncsi_cmd_egmf_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
+	__be32                  mode;     /* Global MC mode */
+	__be32                  checksum; /* Checksum       */
+	unsigned char           pad[22];
+};
+
+/* Set NCSI Flow Control */
+struct ncsi_cmd_snfc_pkt {
+	struct ncsi_cmd_pkt_hdr cmd;         /* Command header    */
+	unsigned char           reserved[3]; /* Reserved          */
+	unsigned char           mode;        /* Flow control mode */
+	__be32                  checksum;    /* Checksum          */
+	unsigned char           pad[22];
+};
+
+/* NCSI packet revision */
+#define NCSI_PKT_REVISION	0x01
+
+/* NCSI packet commands */
+#define NCSI_PKT_CMD_CIS	0x00 /* Clear Initial State              */
+#define NCSI_PKT_CMD_SP		0x01 /* Select Package                   */
+#define NCSI_PKT_CMD_DP		0x02 /* Deselect Package                 */
+#define NCSI_PKT_CMD_EC		0x03 /* Enable Channel                   */
+#define NCSI_PKT_CMD_DC		0x04 /* Disable Channel                  */
+#define NCSI_PKT_CMD_RC		0x05 /* Reset Channel                    */
+#define NCSI_PKT_CMD_ECNT	0x06 /* Enable Channel Network Tx        */
+#define NCSI_PKT_CMD_DCNT	0x07 /* Disable Channel Network Tx       */
+#define NCSI_PKT_CMD_AE		0x08 /* AEN Enable                       */
+#define NCSI_PKT_CMD_SL		0x09 /* Set Link                         */
+#define NCSI_PKT_CMD_GLS	0x0a /* Get Link                         */
+#define NCSI_PKT_CMD_SVF	0x0b /* Set VLAN Filter                  */
+#define NCSI_PKT_CMD_EV		0x0c /* Enable VLAN                      */
+#define NCSI_PKT_CMD_DV		0x0d /* Disable VLAN                     */
+#define NCSI_PKT_CMD_SMA	0x0e /* Set MAC address                  */
+#define NCSI_PKT_CMD_EBF	0x10 /* Enable Broadcast Filter          */
+#define NCSI_PKT_CMD_DBF	0x11 /* Disable Broadcast Filter         */
+#define NCSI_PKT_CMD_EGMF	0x12 /* Enable Global Multicast Filter   */
+#define NCSI_PKT_CMD_DGMF	0x13 /* Disable Global Multicast Filter  */
+#define NCSI_PKT_CMD_SNFC	0x14 /* Set NCSI Flow Control            */
+#define NCSI_PKT_CMD_GVI	0x15 /* Get Version ID                   */
+#define NCSI_PKT_CMD_GC		0x16 /* Get Capabilities                 */
+#define NCSI_PKT_CMD_GP		0x17 /* Get Parameters                   */
+#define NCSI_PKT_CMD_GCPS	0x18 /* Get Controller Packet Statistics */
+#define NCSI_PKT_CMD_GNS	0x19 /* Get NCSI Statistics              */
+#define NCSI_PKT_CMD_GNPTS	0x1a /* Get NCSI Pass-throu Statistics   */
+#define NCSI_PKT_CMD_GPS	0x1b /* Get package status               */
+#define NCSI_PKT_CMD_OEM	0x50 /* OEM                              */
+#define NCSI_PKT_CMD_PLDM	0x51 /* PLDM request over NCSI over RBT  */
+#define NCSI_PKT_CMD_GPUUID	0x52 /* Get package UUID                 */
+
+#endif /* __NCSI_PKT_H__ */
-- 
2.1.0
