From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 4/4] [RESEND] netxen: fix rx dropped stats
Date: Mon, 17 Mar 2008 19:59:51 -0700
Message-ID: <1205809191-20901-5-git-send-email-dhananjay@netxen.com>
References: <1205809191-20901-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:59171 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752076AbYCRDJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 23:09:19 -0400
In-Reply-To: <1205809191-20901-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't count rx dropped packets based on return value of netif_receive_skb(),
which is misleading.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Tested-by: Vernon Mauery <mauery@us.ibm.com>
---
 drivers/net/netxen/netxen_nic.h         |    7 +-----
 drivers/net/netxen/netxen_nic_ethtool.c |    6 -----
 drivers/net/netxen/netxen_nic_init.c    |   33 +------------------------------
 drivers/net/netxen/netxen_nic_isr.c     |    2 +-
 4 files changed, 3 insertions(+), 45 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 070421b..7f20a03 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -818,12 +818,7 @@ struct netxen_adapter_stats {
 	u64  badskblen;
 	u64  nocmddescriptor;
 	u64  polled;
-	u64  uphappy;
-	u64  updropped;
-	u64  uplcong;
-	u64  uphcong;
-	u64  upmcong;
-	u64  updunno;
+	u64  rxdropped;
 	u64  txdropped;
 	u64  csummed;
 	u64  no_rcv;
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index d324ea3..6e98d83 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -64,12 +64,6 @@ static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
 	{"bad_skb_len", NETXEN_NIC_STAT(stats.badskblen)},
 	{"no_cmd_desc", NETXEN_NIC_STAT(stats.nocmddescriptor)},
 	{"polled", NETXEN_NIC_STAT(stats.polled)},
-	{"uphappy", NETXEN_NIC_STAT(stats.uphappy)},
-	{"updropped", NETXEN_NIC_STAT(stats.updropped)},
-	{"uplcong", NETXEN_NIC_STAT(stats.uplcong)},
-	{"uphcong", NETXEN_NIC_STAT(stats.uphcong)},
-	{"upmcong", NETXEN_NIC_STAT(stats.upmcong)},
-	{"updunno", NETXEN_NIC_STAT(stats.updunno)},
 	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
 	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
 	{"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index fe64618..d9713d9 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1089,7 +1089,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	skb = (struct sk_buff *)buffer->skb;
 
 	if (likely(adapter->rx_csum &&
-				netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
+			netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -1106,37 +1106,6 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	ret = netif_receive_skb(skb);
-
-	/*
-	 * RH: Do we need these stats on a regular basis. Can we get it from
-	 * Linux stats.
-	 */
-	switch (ret) {
-	case NET_RX_SUCCESS:
-		adapter->stats.uphappy++;
-		break;
-
-	case NET_RX_CN_LOW:
-		adapter->stats.uplcong++;
-		break;
-
-	case NET_RX_CN_MOD:
-		adapter->stats.upmcong++;
-		break;
-
-	case NET_RX_CN_HIGH:
-		adapter->stats.uphcong++;
-		break;
-
-	case NET_RX_DROP:
-		adapter->stats.updropped++;
-		break;
-
-	default:
-		adapter->stats.updunno++;
-		break;
-	}
-
 	netdev->last_rx = jiffies;
 
 	rcv_desc->rcv_pending--;
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 1a2333a..c81313b 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -59,7 +59,7 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 	/* packet transmit problems */
 	stats->tx_errors = adapter->stats.nocmddescriptor;
 	/* no space in linux buffers    */
-	stats->rx_dropped = adapter->stats.updropped;
+	stats->rx_dropped = adapter->stats.rxdropped;
 	/* no space available in linux  */
 	stats->tx_dropped = adapter->stats.txdropped;
 
-- 
1.5.4

