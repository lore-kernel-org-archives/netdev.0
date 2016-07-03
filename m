From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/10] net/ncsi: NCSI AEN packet handler
Date: Sun,  3 Jul 2016 15:32:28 +1000
Message-ID: <1467523953-18998-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:28578 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751079AbcGCFcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:32:46 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635TK27135681
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:32:45 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x9sy6yuu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:32:45 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:32:42 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C3DC22BB005A
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:32:39 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635Wdhb9830812
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:39 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635WcK4032678
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:39 +1000
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces NCSI AEN packet handlers that result in (A) the
currently active channel is reconfigured; (B) Currently active
channel is deconfigured and disabled, another channel is chosen
as active one and configured.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/Makefile   |   2 +-
 net/ncsi/internal.h |   1 +
 net/ncsi/ncsi-aen.c | 169 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h |  36 +++++++++++
 net/ncsi/ncsi-rsp.c |   6 +-
 5 files changed, 212 insertions(+), 2 deletions(-)
 create mode 100644 net/ncsi/ncsi-aen.c

diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index 4751819..dd12b56 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -1,4 +1,4 @@
 #
 # Makefile for NCSI API
 #
-obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-manage.o
+obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-aen.o ncsi-manage.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index e322f9e..bebf699 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -305,5 +305,6 @@ u32 ncsi_calculate_checksum(unsigned char *data, int len);
 int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca);
 int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 		 struct packet_type *pt, struct net_device *orig_dev);
+int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb);
 
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
new file mode 100644
index 0000000..b14b6c4
--- /dev/null
+++ b/net/ncsi/ncsi-aen.c
@@ -0,0 +1,169 @@
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
+static int ncsi_validate_aen_pkt(struct ncsi_aen_pkt_hdr *h,
+				 const unsigned short payload)
+{
+	u32 checksum;
+	__be32 *pchecksum;
+
+	if (h->common.revision != NCSI_PKT_REVISION)
+		return -EINVAL;
+	if (ntohs(h->common.length) != payload)
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
+static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
+				struct ncsi_aen_pkt_hdr *h)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_aen_lsc_pkt *lsc;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	/* Find the NCSI channel */
+	ncsi_find_package_and_channel(ndp, h->common.channel, NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* Update the link status */
+	ncm = &nc->modes[NCSI_MODE_LINK];
+	lsc = (struct ncsi_aen_lsc_pkt *)h;
+	ncm->data[2] = ntohl(lsc->status);
+	ncm->data[4] = ntohl(lsc->oem_status);
+	if (!ndp->active_channel || ndp->active_channel != nc)
+		return 0;
+
+	ndp->flags |= NCSI_DEV_FLAG_RESHUFFLE;
+	ncsi_suspend_dev(nd);
+
+	return 0;
+}
+
+static int ncsi_aen_handler_cr(struct ncsi_dev_priv *ndp,
+			       struct ncsi_aen_pkt_hdr *h)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_channel *nc;
+
+	/* Find the NCSI channel */
+	ncsi_find_package_and_channel(ndp, h->common.channel, NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* If the channel is active one, we need reconfigure it */
+	if (!ndp->active_channel || ndp->active_channel != nc)
+		return 0;
+
+	ncsi_config_dev(nd);
+
+	return 0;
+}
+
+static int ncsi_aen_handler_hncdsc(struct ncsi_dev_priv *ndp,
+				   struct ncsi_aen_pkt_hdr *h)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+	struct ncsi_aen_hncdsc_pkt *hncdsc;
+
+	/* Find the NCSI channel */
+	ncsi_find_package_and_channel(ndp, h->common.channel, NULL, &nc);
+	if (!nc)
+		return -ENODEV;
+
+	/* If the channel is active one, we need reconfigure it */
+	ncm = &nc->modes[NCSI_MODE_LINK];
+	hncdsc = (struct ncsi_aen_hncdsc_pkt *)h;
+	ncm->data[3] = ntohl(hncdsc->status);
+	if (ndp->active_channel != nc || ncm->data[3] & 0x1)
+		return 0;
+
+	/* If this channel is the active one and the link doesn't
+	 * work, we have to choose another channel to be active one.
+	 * The logic here is exactly similar to what we do when link
+	 * is down on the active channel.
+	 */
+	ndp->flags |= NCSI_DEV_FLAG_RESHUFFLE;
+	ncsi_suspend_dev(nd);
+	return 0;
+}
+
+static struct ncsi_aen_handler {
+	unsigned char type;
+	int           payload;
+	int           (*handler)(struct ncsi_dev_priv *ndp,
+				 struct ncsi_aen_pkt_hdr *h);
+} ncsi_aen_handlers[] = {
+	{ NCSI_PKT_AEN_LSC,    12, ncsi_aen_handler_lsc    },
+	{ NCSI_PKT_AEN_CR,      4, ncsi_aen_handler_cr     },
+	{ NCSI_PKT_AEN_HNCDSC,  4, ncsi_aen_handler_hncdsc },
+	{ 0,                    0, NULL                    }
+};
+
+int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb)
+{
+	struct ncsi_aen_pkt_hdr *h;
+	struct ncsi_aen_handler *nah;
+	int ret;
+
+	/* Find the handler */
+	h = (struct ncsi_aen_pkt_hdr *)skb_network_header(skb);
+	nah = ncsi_aen_handlers;
+	while (nah->handler) {
+		if (nah->type == h->type)
+			break;
+
+		nah++;
+	}
+
+	if (!nah->handler) {
+		pr_warn("NCSI: Invalid AEN packet (0x%x) received\n",
+			h->type);
+		return -ENOENT;
+	}
+
+	ret = ncsi_validate_aen_pkt(h, nah->payload);
+	if (ret)
+		goto out;
+
+	ret = nah->handler(ndp, h);
+out:
+	consume_skb(skb);
+	return ret;
+}
diff --git a/net/ncsi/ncsi-pkt.h b/net/ncsi/ncsi-pkt.h
index 95882f3..6248835 100644
--- a/net/ncsi/ncsi-pkt.h
+++ b/net/ncsi/ncsi-pkt.h
@@ -31,6 +31,12 @@ struct ncsi_rsp_pkt_hdr {
 	__be16              reason; /* Response reason           */
 };
 
+struct ncsi_aen_pkt_hdr {
+	struct ncsi_pkt_hdr common;       /* Common NCSI packet header */
+	unsigned char       reserved2[3]; /* Reserved                  */
+	unsigned char       type;         /* AEN packet type           */
+};
+
 /* NCSI common command packet */
 struct ncsi_cmd_pkt {
 	struct ncsi_cmd_pkt_hdr cmd;      /* Command header */
@@ -282,6 +288,30 @@ struct ncsi_rsp_gnpts_pkt {
 	__be32                  checksum;       /* Checksum            */
 };
 
+/* AEN: Link State Change */
+struct ncsi_aen_lsc_pkt {
+	struct ncsi_aen_pkt_hdr aen;        /* AEN header      */
+	__be32                  status;     /* Link status     */
+	__be32                  oem_status; /* OEM link status */
+	__be32                  checksum;   /* Checksum        */
+	unsigned char           pad[14];
+};
+
+/* AEN: Configuration Required */
+struct ncsi_aen_cr_pkt {
+	struct ncsi_aen_pkt_hdr aen;      /* AEN header */
+	__be32                  checksum; /* Checksum   */
+	unsigned char           pad[22];
+};
+
+/* AEN: Host Network Controller Driver Status Change */
+struct ncsi_aen_hncdsc_pkt {
+	struct ncsi_aen_pkt_hdr aen;      /* AEN header */
+	__be32                  status;   /* Status     */
+	__be32                  checksum; /* Checksum   */
+	unsigned char           pad[18];
+};
+
 /* NCSI packet revision */
 #define NCSI_PKT_REVISION	0x01
 
@@ -356,4 +386,10 @@ struct ncsi_rsp_gnpts_pkt {
 #define NCSI_PKT_RSP_R_LENGTH		0x0005  /* Invalid payload length   */
 #define NCSI_PKT_RSP_R_UNKNOWN		0x7fff  /* Command type unsupported */
 
+/* NCSI packet type: AEN */
+#define NCSI_PKT_AEN		0xFF /* AEN Packet               */
+#define NCSI_PKT_AEN_LSC	0x00 /* Link status change       */
+#define NCSI_PKT_AEN_CR		0x01 /* Configuration required   */
+#define NCSI_PKT_AEN_HNCDSC	0x02 /* HNC driver status change */
+
 #endif /* __NCSI_PKT_H__ */
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 5b81217..09f79f8 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -946,8 +946,12 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	if (!ndp)
 		return -ENODEV;
 
-	/* Find the handler */
+	/* Check if it is AEN packet */
 	hdr = (struct ncsi_pkt_hdr *)skb_network_header(skb);
+	if (hdr->type == NCSI_PKT_AEN)
+		return ncsi_aen_handler(ndp, skb);
+
+	/* Find the handler */
 	nrh = ncsi_rsp_handlers;
 	while (nrh->handler) {
 		if (nrh->type == hdr->type)
-- 
2.1.0
