From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 22 May 2007 11:17:51 -0400
Message-ID: <20070522151751.GA5993__41073.4380515807$1179853375$gmane$org@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4428 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027AbXEVRCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 13:02:47 -0400
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.14.0/8.13.7) with ESMTP id l4MH2b0k004441
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 13:02:42 -0400
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.14.0/8.14.0/Submit) with UUCP id l4MH05l9004339
	for netdev@vger.kernel.org; Tue, 22 May 2007 13:00:05 -0400
Received: from linville-t43.mobile (linville-t43.mobile [127.0.0.1])
	by linville-t43.mobile (8.13.8/8.13.8) with ESMTP id l4MGkPEu019005
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 12:46:25 -0400
Received: (from linville@localhost)
	by linville-t43.mobile (8.13.8/8.13.8/Submit) id l4MGkPxW019004
	for netdev@vger.kernel.org; Tue, 22 May 2007 12:46:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 55b637c6a003a8c4850b41a2c2fd6942d8a7f530:
  Linus Torvalds (1):
        Linux v2.6.22-rc2

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Eugene Teo (2):
      drivers/net/wireless/libertas/fw.c: fix use-before-check
      drivers/net/wireless/libertas/rx.c: fix use-after-free

Florin Malita (1):
      libertas: skb dereferenced after netif_rx

 drivers/net/wireless/libertas/decl.h |    2 +-
 drivers/net/wireless/libertas/fw.c   |   14 +++++++++-----
 drivers/net/wireless/libertas/rx.c   |   24 +++++-------------------
 3 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
index 606bdd0..dfe2764 100644
--- a/drivers/net/wireless/libertas/decl.h
+++ b/drivers/net/wireless/libertas/decl.h
@@ -46,7 +46,7 @@ u32 libertas_index_to_data_rate(u8 index);
 u8 libertas_data_rate_to_index(u32 rate);
 void libertas_get_fwversion(wlan_adapter * adapter, char *fwversion, int maxlen);
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
 
 /** The proc fs interface */
 int libertas_process_rx_command(wlan_private * priv);
diff --git a/drivers/net/wireless/libertas/fw.c b/drivers/net/wireless/libertas/fw.c
index 441123c..5c63c9b 100644
--- a/drivers/net/wireless/libertas/fw.c
+++ b/drivers/net/wireless/libertas/fw.c
@@ -333,18 +333,22 @@ static void command_timer_fn(unsigned long data)
 	unsigned long flags;
 
 	ptempnode = adapter->cur_cmd;
+	if (ptempnode == NULL) {
+		lbs_pr_debug(1, "PTempnode Empty\n");
+		return;
+	}
+
 	cmd = (struct cmd_ds_command *)ptempnode->bufvirtualaddr;
+	if (!cmd) {
+		lbs_pr_debug(1, "cmd is NULL\n");
+		return;
+	}
 
 	lbs_pr_info("command_timer_fn fired (%x)\n", cmd->command);
 
 	if (!adapter->fw_ready)
 		return;
 
-	if (ptempnode == NULL) {
-		lbs_pr_debug(1, "PTempnode Empty\n");
-		return;
-	}
-
 	spin_lock_irqsave(&adapter->driver_lock, flags);
 	adapter->cur_cmd = NULL;
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index d17924f..96619a3 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -136,7 +136,7 @@ static void wlan_compute_rssi(wlan_private * priv, struct rxpd *p_rx_pd)
 	LEAVE();
 }
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 {
 	lbs_pr_debug(1, "skb->data=%p\n", skb->data);
 
@@ -148,8 +148,6 @@ int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx(skb);
-
-	return 0;
 }
 
 /**
@@ -269,15 +267,11 @@ int libertas_process_rxed_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, p_rx_pd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet"
-		       " returns failure\n");
-		ret = -1;
-		goto done;
-	}
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();
@@ -438,22 +432,14 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, prxpd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet "
-			"returns failure\n");
-		ret = -1;
-		goto done;
-	}
-
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();
 
-	skb->protocol = __constant_htons(0x0019);	/* ETH_P_80211_RAW */
-
 	return (ret);
 }
-- 
John W. Linville
linville@tuxdriver.com

