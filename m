From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4: implement the ETHTOOL_GRXFH command
Date: Sun, 11 Jul 2010 15:01:18 -0700
Message-ID: <1278885679-3738-5-git-send-email-dm@chelsio.com>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
 <1278885679-3738-2-git-send-email-dm@chelsio.com>
 <1278885679-3738-3-git-send-email-dm@chelsio.com>
 <1278885679-3738-4-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25664 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208Ab0GKWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:01:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6BM1KLl021632
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:20 -0700
In-Reply-To: <1278885679-3738-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 +
 drivers/net/cxgb4/cxgb4_main.c |   54 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/cxgb4/t4_hw.c      |   11 ++++++++
 3 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index a614eb5..4769c1c 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -294,6 +294,7 @@ struct port_info {
 	u8     rx_offload;            /* CSO, etc */
 	u8     nqsets;                /* # of qsets */
 	u8     first_qset;            /* index of first qset */
+	u8     rss_mode;
 	struct link_config link_cfg;
 	u16   *rss;
 };
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 61d4313..110843c 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1851,9 +1851,61 @@ static int set_rss_table(struct net_device *dev,
 static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 		     void *rules)
 {
+	const struct port_info *pi = netdev_priv(dev);
+
 	switch (info->cmd) {
+	case ETHTOOL_GRXFH: {
+		unsigned int v = pi->rss_mode;
+
+		info->data = 0;
+		switch (info->flow_type) {
+		case TCP_V4_FLOW:
+			if (v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST |
+					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		case UDP_V4_FLOW:
+			if ((v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN) &&
+			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN))
+				info->data = RXH_IP_SRC | RXH_IP_DST |
+					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		case SCTP_V4_FLOW:
+		case AH_ESP_V4_FLOW:
+		case IPV4_FLOW:
+			if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		case TCP_V6_FLOW:
+			if (v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST |
+					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		case UDP_V6_FLOW:
+			if ((v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN) &&
+			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN))
+				info->data = RXH_IP_SRC | RXH_IP_DST |
+					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		case SCTP_V6_FLOW:
+		case AH_ESP_V6_FLOW:
+		case IPV6_FLOW:
+			if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+				info->data = RXH_IP_SRC | RXH_IP_DST;
+			break;
+		}
+		return 0;
+	}
 	case ETHTOOL_GRXRINGS:
-		info->data = netdev2pinfo(dev)->nqsets;
+		info->data = pi->nqsets;
 		return 0;
 	}
 	return -EOPNOTSUPP;
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 3e63d14..ab46797 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -3133,8 +3133,10 @@ int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 	u8 addr[6];
 	int ret, i, j = 0;
 	struct fw_port_cmd c;
+	struct fw_rss_vi_config_cmd rvc;
 
 	memset(&c, 0, sizeof(c));
+	memset(&rvc, 0, sizeof(rvc));
 
 	for_each_port(adap, i) {
 		unsigned int rss_size;
@@ -3171,6 +3173,15 @@ int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		p->port_type = FW_PORT_CMD_PTYPE_GET(ret);
 		p->mod_type = FW_PORT_MOD_TYPE_NA;
 
+		rvc.op_to_viid = htonl(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
+				       FW_CMD_REQUEST | FW_CMD_READ |
+				       FW_RSS_VI_CONFIG_CMD_VIID(p->viid));
+		rvc.retval_len16 = htonl(FW_LEN16(rvc));
+		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
+		if (ret)
+			return ret;
+		p->rss_mode = ntohl(rvc.u.basicvirtual.defaultq_to_udpen);
+
 		init_link_config(&p->link_cfg, ntohs(c.u.info.pcap));
 		j++;
 	}
-- 
1.5.4

