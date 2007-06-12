From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'libertas-fixes' branch of wireless-2.6
Date: Tue, 12 Jun 2007 17:06:58 -0400
Message-ID: <20070612210658.GG310@tuxdriver.com>
References: <20070529183347.GD3496@tuxdriver.com> <20070612210544.GF310@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3110 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbXFLVYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:24:44 -0400
Content-Disposition: inline
In-Reply-To: <20070612210544.GF310@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes identified by the libertas team as important for 2.6.22...

---

The following changes since commit 717c9339202a42ae7bec7d3c4b84deecdcae9f81:
  Dan Williams (1):
        libertas: reduce SSID and BSSID mixed-case abuse

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas-fixes

Dan Williams (1):
      libertas: actually send mesh frames to mesh netdev

Luis Carlos (1):
      libertas: convert libertas_mpp into anycast_mask

Luis Carlos Cobo Rus (2):
      libertas: pull current channel from firmware on mesh autostart
      libertas: deauthenticate from AP in channel switch

 drivers/net/wireless/libertas/assoc.c   |   13 +++++++++++++
 drivers/net/wireless/libertas/assoc.h   |    2 ++
 drivers/net/wireless/libertas/cmdresp.c |    1 +
 drivers/net/wireless/libertas/dev.h     |    1 +
 drivers/net/wireless/libertas/host.h    |    4 ++--
 drivers/net/wireless/libertas/main.c    |   27 ++++++++++++++-------------
 drivers/net/wireless/libertas/rx.c      |    5 ++---
 7 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index ee82413..f67efa0 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -200,6 +200,14 @@ static int update_channel(wlan_private * priv)
 				    cmd_option_waitforrsp, 0, NULL);
 }
 
+void libertas_sync_channel(struct work_struct *work)
+{
+	wlan_private *priv = container_of(work, wlan_private, sync_channel);
+
+	if (update_channel(priv) != 0)
+		lbs_pr_info("Channel synchronization failed.");
+}
+
 static int assoc_helper_channel(wlan_private *priv,
                                 struct assoc_request * assoc_req)
 {
@@ -403,6 +411,11 @@ static int should_deauth_infrastructure(wlan_adapter *adapter,
 		return 1;
 	}
 
+	if (test_bit(ASSOC_FLAG_CHANNEL, &assoc_req->flags)) {
+		lbs_deb_assoc("Deauthenticating due to channel switch.\n");
+		return 1;
+	}
+
 	/* FIXME: deal with 'auto' mode somehow */
 	if (test_bit(ASSOC_FLAG_MODE, &assoc_req->flags)) {
 		if (assoc_req->mode != IW_MODE_INFRA)
diff --git a/drivers/net/wireless/libertas/assoc.h b/drivers/net/wireless/libertas/assoc.h
index b5eddf8..5e9c31f 100644
--- a/drivers/net/wireless/libertas/assoc.h
+++ b/drivers/net/wireless/libertas/assoc.h
@@ -9,6 +9,8 @@ void libertas_association_worker(struct work_struct *work);
 
 struct assoc_request * wlan_get_association_request(wlan_adapter *adapter);
 
+void libertas_sync_channel(struct work_struct *work);
+
 #define ASSOC_DELAY (HZ / 2)
 static inline void wlan_postpone_association_work(wlan_private *priv)
 {
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
index ebedd63..0c3b9a5 100644
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -987,6 +987,7 @@ int libertas_process_event(wlan_private * priv)
 			netif_carrier_on(priv->mesh_dev) ;
 		}
 		adapter->mode = IW_MODE_ADHOC ;
+		schedule_work(&priv->sync_channel);
 		break;
 
 	default:
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index d6c340a..785192b 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -150,6 +150,7 @@ struct _wlan_private {
 
 	struct delayed_work assoc_work;
 	struct workqueue_struct *assoc_thread;
+	struct work_struct sync_channel;
 
 	/** Hardware access */
 	int (*hw_register_dev) (wlan_private * priv);
diff --git a/drivers/net/wireless/libertas/host.h b/drivers/net/wireless/libertas/host.h
index cedf1db..7509cc1 100644
--- a/drivers/net/wireless/libertas/host.h
+++ b/drivers/net/wireless/libertas/host.h
@@ -310,8 +310,8 @@ enum cmd_mesh_access_opts {
 	cmd_act_mesh_get_ttl = 1,
 	cmd_act_mesh_set_ttl,
 	cmd_act_mesh_get_stats,
-	cmd_act_mesh_get_mpp,
-	cmd_act_mesh_set_mpp,
+	cmd_act_mesh_get_anycast,
+	cmd_act_mesh_set_anycast,
 };
 
 /** Card Event definition */
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index ec9be0c..623ab4b 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -178,45 +178,45 @@ u16 libertas_region_code_to_index[MRVDRV_MAX_REGION_CODE] =
  */
 
 /**
- * @brief Get function for sysfs attribute libertas_mpp
+ * @brief Get function for sysfs attribute anycast_mask
  */
-static ssize_t libertas_mpp_get(struct device * dev,
+static ssize_t libertas_anycast_get(struct device * dev,
 		struct device_attribute *attr, char * buf) {
 	struct cmd_ds_mesh_access mesh_access;
 
 	memset(&mesh_access, 0, sizeof(mesh_access));
 	libertas_prepare_and_send_command(to_net_dev(dev)->priv,
 			cmd_mesh_access,
-			cmd_act_mesh_get_mpp,
+			cmd_act_mesh_get_anycast,
 			cmd_option_waitforrsp, 0, (void *)&mesh_access);
 
-	return snprintf(buf, 3, "%d\n", le32_to_cpu(mesh_access.data[0]));
+	return snprintf(buf, 12, "0x%X\n", le32_to_cpu(mesh_access.data[0]));
 }
 
 /**
- * @brief Set function for sysfs attribute libertas_mpp
+ * @brief Set function for sysfs attribute anycast_mask
  */
-static ssize_t libertas_mpp_set(struct device * dev,
+static ssize_t libertas_anycast_set(struct device * dev,
 		struct device_attribute *attr, const char * buf, size_t count) {
 	struct cmd_ds_mesh_access mesh_access;
 	uint32_t datum;
 
 	memset(&mesh_access, 0, sizeof(mesh_access));
-	sscanf(buf, "%d", &datum);
+	sscanf(buf, "%x", &datum);
 	mesh_access.data[0] = cpu_to_le32(datum);
 
 	libertas_prepare_and_send_command((to_net_dev(dev))->priv,
 			cmd_mesh_access,
-			cmd_act_mesh_set_mpp,
+			cmd_act_mesh_set_anycast,
 			cmd_option_waitforrsp, 0, (void *)&mesh_access);
 	return strlen(buf);
 }
 
 /**
- * libertas_mpp attribute to be exported per mshX interface
- * through sysfs (/sys/class/net/mshX/libertas-mpp)
+ * anycast_mask attribute to be exported per mshX interface
+ * through sysfs (/sys/class/net/mshX/anycast_mask)
  */
-static DEVICE_ATTR(libertas_mpp, 0644, libertas_mpp_get, libertas_mpp_set );
+static DEVICE_ATTR(anycast_mask, 0644, libertas_anycast_get, libertas_anycast_set);
 
 /**
  *  @brief Check if the device can be open and wait if necessary.
@@ -847,6 +847,7 @@ int libertas_activate_card(wlan_private *priv, char *fw_name)
 	priv->assoc_thread =
 		create_singlethread_workqueue("libertas_assoc");
 	INIT_DELAYED_WORK(&priv->assoc_work, libertas_association_worker);
+	INIT_WORK(&priv->sync_channel, libertas_sync_channel);
 
 	/*
 	 * Register the device. Fillup the private data structure with
@@ -938,7 +939,7 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 		goto err_free;
 	}
 
-	ret = device_create_file(&(mesh_dev->dev), &dev_attr_libertas_mpp);
+	ret = device_create_file(&(mesh_dev->dev), &dev_attr_anycast_mask);
 	if (ret)
 		goto err_unregister;
 
@@ -1048,7 +1049,7 @@ void libertas_remove_mesh(wlan_private *priv)
 	netif_stop_queue(mesh_dev);
 	netif_carrier_off(priv->mesh_dev);
 
-	device_remove_file(&(mesh_dev->dev), &dev_attr_libertas_mpp);
+	device_remove_file(&(mesh_dev->dev), &dev_attr_anycast_mask);
 	unregister_netdev(mesh_dev);
 
 	priv->mesh_dev = NULL ;
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 5d70a76..88d9d2d 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -141,10 +141,9 @@ void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 	lbs_deb_rx("skb->data %p\n", skb->data);
 
 	if (priv->mesh_dev && IS_MESH_FRAME(skb))
-		skb->dev = priv->mesh_dev;
+		skb->protocol = eth_type_trans(skb, priv->mesh_dev);
 	else
-		skb->dev = priv->dev;
-	skb->protocol = eth_type_trans(skb, priv->dev);
+		skb->protocol = eth_type_trans(skb, priv->dev);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx(skb);
-- 
John W. Linville
linville@tuxdriver.com
