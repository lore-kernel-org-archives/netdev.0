From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Thu, 27 Jul 2006 20:23:59 -0400
Message-ID: <20060728002358.GB11621@tuxdriver.com>
References: <20060728002206.GA11621@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:37897 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750783AbWG1AY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 20:24:27 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060728002206.GA11621@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 416512cb75f51f3d12e5e1aa57b6a36760fd12c9:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Dan Williams:
      prism54: update to WE-19 for WPA support

Daniel Drake:
      zd1211rw: Implement SIOCGIWNICKN
      Add zd1211rw MAINTAINERS entry
      ieee80211: small ERP handling additions
      softmac: ERP handling and driver-level notifications
      softmac: export highest_supported_rate function
      ieee80211: Make ieee80211_rx_any usable
      softmac: Add MAINTAINERS entry

Pavel Machek:
      cleanup // comments from ipw2200

Robert Schulze:
      airo: collapse debugging-messages in issuecommand to one line

 MAINTAINERS                                     |   21 +
 drivers/net/wireless/airo.c                     |   12 
 drivers/net/wireless/ipw2200.c                  |   29 -
 drivers/net/wireless/prism54/isl_ioctl.c        |  573 ++++++++++++++++++++++-
 drivers/net/wireless/prism54/isl_ioctl.h        |    6 
 drivers/net/wireless/prism54/islpci_dev.c       |    4 
 drivers/net/wireless/prism54/islpci_dev.h       |    2 
 drivers/net/wireless/zd1211rw/zd_netdev.c       |   17 +
 include/net/ieee80211.h                         |    9 
 include/net/ieee80211softmac.h                  |   60 ++
 net/ieee80211/ieee80211_rx.c                    |   39 +-
 net/ieee80211/softmac/ieee80211softmac_assoc.c  |   21 +
 net/ieee80211/softmac/ieee80211softmac_io.c     |   14 +
 net/ieee80211/softmac/ieee80211softmac_module.c |   90 ++--
 net/ieee80211/softmac/ieee80211softmac_priv.h   |    8 
 15 files changed, 777 insertions(+), 128 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b2afc7a..4e14ee7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2588,6 +2588,18 @@ P:	Nicolas Pitre
 M:	nico@cam.org
 S:	Maintained
 
+SOFTMAC LAYER (IEEE 802.11)
+P:	Johannes Berg
+M:	johannes@sipsolutions.net
+P:	Joe Jezak
+M:	josejx@gentoo.org
+P:	Daniel Drake
+M:	dsd@gentoo.org
+W:	http://softmac.sipsolutions.net/
+L:	softmac-dev@sipsolutions.net
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 SOFTWARE RAID (Multiple Disks) SUPPORT
 P:	Ingo Molnar
 M:	mingo@redhat.com
@@ -3296,6 +3308,15 @@ W:	http://www.qsl.net/dl1bke/
 L:	linux-hams@vger.kernel.org
 S:	Maintained
 
+ZD1211RW WIRELESS DRIVER
+P:	Daniel Drake
+M:	dsd@gentoo.org
+P:	Ulrich Kunitz
+M:	kune@deine-taler.de
+W:	http://zd1211.ath.cx/wiki/DriverRewrite
+L:	zd1211-devs@lists.sourceforge.net (subscribers-only)
+S:	Maintained
+
 ZF MACHZ WATCHDOG
 P:	Fernando Fuganti
 M:	fuganti@netbank.com.br
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a4dd139..16befbc 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3950,13 +3950,11 @@ static u16 issuecommand(struct airo_info
 	pRsp->rsp0 = IN4500(ai, RESP0);
 	pRsp->rsp1 = IN4500(ai, RESP1);
 	pRsp->rsp2 = IN4500(ai, RESP2);
-	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
-		airo_print_err(ai->dev->name, "cmd= %x\n", pCmd->cmd);
-		airo_print_err(ai->dev->name, "status= %x\n", pRsp->status);
-		airo_print_err(ai->dev->name, "Rsp0= %x\n", pRsp->rsp0);
-		airo_print_err(ai->dev->name, "Rsp1= %x\n", pRsp->rsp1);
-		airo_print_err(ai->dev->name, "Rsp2= %x\n", pRsp->rsp2);
-	}
+	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET)
+		airo_print_err(ai->dev->name,
+			"cmd:%x status:%x rsp0:%x rsp1:%x rsp2:%x",
+			pCmd->cmd, pRsp->status, pRsp->rsp0, pRsp->rsp1,
+			pRsp->rsp2);
 
 	// clear stuck command busy if necessary
 	if (IN4500(ai, COMMAND) & COMMAND_BUSY) {
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index b3300ff..758459e 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -2667,7 +2667,7 @@ static void ipw_fw_dma_abort(struct ipw_
 
 	IPW_DEBUG_FW(">> :\n");
 
-	//set the Stop and Abort bit
+	/* set the Stop and Abort bit */
 	control = DMA_CONTROL_SMALL_CB_CONST_VALUE | DMA_CB_STOP_AND_ABORT;
 	ipw_write_reg32(priv, IPW_DMA_I_DMA_CONTROL, control);
 	priv->sram_desc.last_cb_index = 0;
@@ -3002,8 +3002,6 @@ static int ipw_load_ucode(struct ipw_pri
 	if (rc < 0)
 		return rc;
 
-//      spin_lock_irqsave(&priv->lock, flags);
-
 	for (addr = IPW_SHARED_LOWER_BOUND;
 	     addr < IPW_REGISTER_DOMAIN1_END; addr += 4) {
 		ipw_write32(priv, addr, 0);
@@ -3097,8 +3095,6 @@ static int ipw_load_ucode(struct ipw_pri
 	   firmware have problem getting alive resp. */
 	ipw_write_reg8(priv, IPW_BASEBAND_CONTROL_STATUS, 0);
 
-//      spin_unlock_irqrestore(&priv->lock, flags);
-
 	return rc;
 }
 
@@ -6387,13 +6383,6 @@ static int ipw_wx_set_genie(struct net_d
 	    (wrqu->data.length && extra == NULL))
 		return -EINVAL;
 
-	//mutex_lock(&priv->mutex);
-
-	//if (!ieee->wpa_enabled) {
-	//      err = -EOPNOTSUPP;
-	//      goto out;
-	//}
-
 	if (wrqu->data.length) {
 		buf = kmalloc(wrqu->data.length, GFP_KERNEL);
 		if (buf == NULL) {
@@ -6413,7 +6402,6 @@ static int ipw_wx_set_genie(struct net_d
 
 	ipw_wpa_assoc_frame(priv, ieee->wpa_ie, ieee->wpa_ie_len);
       out:
-	//mutex_unlock(&priv->mutex);
 	return err;
 }
 
@@ -6426,13 +6414,6 @@ static int ipw_wx_get_genie(struct net_d
 	struct ieee80211_device *ieee = priv->ieee;
 	int err = 0;
 
-	//mutex_lock(&priv->mutex);
-
-	//if (!ieee->wpa_enabled) {
-	//      err = -EOPNOTSUPP;
-	//      goto out;
-	//}
-
 	if (ieee->wpa_ie_len == 0 || ieee->wpa_ie == NULL) {
 		wrqu->data.length = 0;
 		goto out;
@@ -6447,7 +6428,6 @@ static int ipw_wx_get_genie(struct net_d
 	memcpy(extra, ieee->wpa_ie, ieee->wpa_ie_len);
 
       out:
-	//mutex_unlock(&priv->mutex);
 	return err;
 }
 
@@ -6558,7 +6538,6 @@ static int ipw_wx_set_auth(struct net_de
 		ieee->ieee802_1x = param->value;
 		break;
 
-		//case IW_AUTH_ROAMING_CONTROL:
 	case IW_AUTH_PRIVACY_INVOKED:
 		ieee->privacy_invoked = param->value;
 		break;
@@ -6680,7 +6659,7 @@ static int ipw_wx_set_mlme(struct net_de
 
 	switch (mlme->cmd) {
 	case IW_MLME_DEAUTH:
-		// silently ignore
+		/* silently ignore */
 		break;
 
 	case IW_MLME_DISASSOC:
@@ -9766,7 +9745,7 @@ #endif
 	return 0;
 }
 
-#endif				// CONFIG_IPW2200_MONITOR
+#endif				/* CONFIG_IPW2200_MONITOR */
 
 static int ipw_wx_reset(struct net_device *dev,
 			struct iw_request_info *info,
@@ -10009,7 +9988,7 @@ static  void init_sys_config(struct ipw_
 	sys_config->dot11g_auto_detection = 0;
 	sys_config->enable_cts_to_self = 0;
 	sys_config->bt_coexist_collision_thr = 0;
-	sys_config->pass_noise_stats_to_host = 1;	//1 -- fix for 256
+	sys_config->pass_noise_stats_to_host = 1;	/* 1 -- fix for 256 */
 	sys_config->silence_threshold = 0x1e;
 }
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 989599a..0c30fe7 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -35,10 +35,14 @@ #include "oid_mgt.h"
 
 #include <net/iw_handler.h>	/* New driver API */
 
+#define KEY_SIZE_WEP104 13	/* 104/128-bit WEP keys */
+#define KEY_SIZE_WEP40  5	/* 40/64-bit WEP keys */
+/* KEY_SIZE_TKIP should match isl_oid.h, struct obj_key.key[] size */
+#define KEY_SIZE_TKIP   32	/* TKIP keys */
 
-static void prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
+static void prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 				u8 *wpa_ie, size_t wpa_ie_len);
-static size_t prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie);
+static size_t prism54_wpa_bss_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie);
 static int prism54_set_wpa(struct net_device *, struct iw_request_info *,
 				__u32 *, char *);
 
@@ -468,6 +472,9 @@ prism54_get_range(struct net_device *nde
 	range->event_capa[1] = IW_EVENT_CAPA_K_1;
 	range->event_capa[4] = IW_EVENT_CAPA_MASK(IWEVCUSTOM);
 
+	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
+		IW_ENC_CAPA_CIPHER_TKIP;
+
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
 
@@ -567,6 +574,8 @@ prism54_translate_bss(struct net_device 
 	struct iw_event iwe;	/* Temporary buffer */
 	short cap;
 	islpci_private *priv = netdev_priv(ndev);
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
 
 	/* The first entry must be the MAC address */
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
@@ -627,27 +636,13 @@ #define CAP_CRYPT 0x10
 	current_ev =
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
 
-	if (priv->wpa) {
-		u8 wpa_ie[MAX_WPA_IE_LEN];
-		char *buf, *p;
-		size_t wpa_ie_len;
-		int i;
-
-		wpa_ie_len = prism54_wpa_ie_get(priv, bss->address, wpa_ie);
-		if (wpa_ie_len > 0 &&
-		    (buf = kmalloc(wpa_ie_len * 2 + 10, GFP_ATOMIC))) {
-			p = buf;
-			p += sprintf(p, "wpa_ie=");
-			for (i = 0; i < wpa_ie_len; i++) {
-				p += sprintf(p, "%02x", wpa_ie[i]);
-			}
-			memset(&iwe, 0, sizeof (iwe));
-			iwe.cmd = IWEVCUSTOM;
-			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
-			kfree(buf);
-		}
+	/* Add WPA/RSN Information Element, if any */
+	wpa_ie_len = prism54_wpa_bss_ie_get(priv, bss->address, wpa_ie);
+	if (wpa_ie_len > 0) {
+		iwe.cmd = IWEVGENIE;
+		iwe.u.data.length = min(wpa_ie_len, (size_t)MAX_WPA_IE_LEN);
+		current_ev = iwe_stream_add_point(current_ev, end_buf,
+				&iwe, wpa_ie);
 	}
 	return current_ev;
 }
@@ -1051,12 +1046,24 @@ prism54_set_encode(struct net_device *nd
 		current_index = r.u;
 		/* Verify that the key is not marked as invalid */
 		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
-			key.length = dwrq->length > sizeof (key.key) ?
-			    sizeof (key.key) : dwrq->length;
-			memcpy(key.key, extra, key.length);
-			if (key.length == 32)
-				/* we want WPA-PSK */
+			if (dwrq->length > KEY_SIZE_TKIP) {
+				/* User-provided key data too big */
+				return -EINVAL;
+			}
+			if (dwrq->length > KEY_SIZE_WEP104) {
+				/* WPA-PSK TKIP */
 				key.type = DOT11_PRIV_TKIP;
+				key.length = KEY_SIZE_TKIP;
+			} else if (dwrq->length > KEY_SIZE_WEP40) {
+				/* WEP 104/128 */
+				key.length = KEY_SIZE_WEP104;
+			} else {
+				/* WEP 40/64 */
+				key.length = KEY_SIZE_WEP40;
+			}
+			memset(key.key, 0, sizeof (key.key));
+			memcpy(key.key, extra, dwrq->length);
+
 			if ((index < 0) || (index > 3))
 				/* no index provided use the current one */
 				index = current_index;
@@ -1210,6 +1217,489 @@ prism54_set_txpower(struct net_device *n
 	}
 }
 
+static int prism54_set_genie(struct net_device *ndev,
+			     struct iw_request_info *info,
+			     struct iw_point *data, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	int alen, ret = 0;
+	struct obj_attachment *attach;
+
+	if (data->length > MAX_WPA_IE_LEN ||
+	    (data->length && extra == NULL))
+		return -EINVAL;
+
+	memcpy(priv->wpa_ie, extra, data->length);
+	priv->wpa_ie_len = data->length;
+
+	alen = sizeof(*attach) + priv->wpa_ie_len;
+	attach = kzalloc(alen, GFP_KERNEL);
+	if (attach == NULL)
+		return -ENOMEM;
+
+#define WLAN_FC_TYPE_MGMT 0
+#define WLAN_FC_STYPE_ASSOC_REQ 0
+#define WLAN_FC_STYPE_REASSOC_REQ 2
+
+	/* Note: endianness is covered by mgt_set_varlen */
+	attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+               (WLAN_FC_STYPE_ASSOC_REQ << 4);
+	attach->id = -1;
+	attach->size = priv->wpa_ie_len;
+	memcpy(attach->data, extra, priv->wpa_ie_len);
+
+	ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
+		priv->wpa_ie_len);
+	if (ret == 0) {
+		attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+			(WLAN_FC_STYPE_REASSOC_REQ << 4);
+
+		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
+			priv->wpa_ie_len);
+		if (ret == 0)
+			printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
+				ndev->name);
+	}
+
+	kfree(attach);
+	return ret;
+}
+
+
+static int prism54_get_genie(struct net_device *ndev,
+			     struct iw_request_info *info,
+			     struct iw_point *data, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	int len = priv->wpa_ie_len;
+
+	if (len <= 0) {
+		data->length = 0;
+		return 0;
+	}
+
+	if (data->length < len)
+		return -E2BIG;
+
+	data->length = len;
+	memcpy(extra, priv->wpa_ie, len);
+
+	return 0;
+}
+
+static int prism54_set_auth(struct net_device *ndev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_param *param = &wrqu->param;
+	u32 mlmelevel = 0, authen = 0, dot1x = 0;
+	u32 exunencrypt = 0, privinvoked = 0, wpa = 0;
+	u32 old_wpa;
+	int ret = 0;
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	down_write(&priv->mib_sem);
+	wpa = old_wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	privinvoked = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
+	dot1x = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, NULL, &r);
+	mlmelevel = r.u;
+
+	if (ret < 0)
+		goto out;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		/* Do the same thing as IW_AUTH_WPA_VERSION */
+		if (param->value) {
+			wpa = 1;
+			privinvoked = 1; /* For privacy invoked */
+			exunencrypt = 1; /* Filter out all unencrypted frames */
+			dot1x = 0x01; /* To enable eap filter */
+			mlmelevel = DOT11_MLME_EXTENDED;
+			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+		} else {
+			wpa = 0;
+			privinvoked = 0;
+			exunencrypt = 0; /* Do not filter un-encrypted data */
+			dot1x = 0;
+			mlmelevel = DOT11_MLME_AUTO;
+		}
+		break;
+
+	case IW_AUTH_WPA_VERSION:
+		if (param->value & IW_AUTH_WPA_VERSION_DISABLED) {
+			wpa = 0;
+			privinvoked = 0;
+			exunencrypt = 0; /* Do not filter un-encrypted data */
+			dot1x = 0;
+			mlmelevel = DOT11_MLME_AUTO;
+		} else {
+			if (param->value & IW_AUTH_WPA_VERSION_WPA)
+				wpa = 1;
+			else if (param->value & IW_AUTH_WPA_VERSION_WPA2)
+				wpa = 2;
+			privinvoked = 1; /* For privacy invoked */
+			exunencrypt = 1; /* Filter out all unencrypted frames */
+			dot1x = 0x01; /* To enable eap filter */
+			mlmelevel = DOT11_MLME_EXTENDED;
+			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+		}
+		break;
+
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		dot1x = param->value ? 1 : 0;
+		break;
+
+	case IW_AUTH_PRIVACY_INVOKED:
+		privinvoked = param->value ? 1 : 0;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		exunencrypt = param->value ? 1 : 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+			/* Only WEP uses _SK and _BOTH */
+			if (wpa > 0) {
+				ret = -EINVAL;
+				goto out;
+			}
+			authen = DOT11_AUTH_SK;
+		} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+			authen = DOT11_AUTH_OS;
+		} else {
+			ret = -EINVAL;
+			goto out;
+		}
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	/* Set all the values */
+	down_write(&priv->mib_sem);
+	priv->wpa = wpa;
+	up_write(&priv->mib_sem);
+	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &privinvoked);
+	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &exunencrypt);
+	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
+	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlmelevel);
+
+out:
+	return ret;
+}
+
+static int prism54_get_auth(struct net_device *ndev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_param *param = &wrqu->param;
+	u32 wpa = 0;
+	int ret = 0;
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	down_write(&priv->mib_sem);
+	wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		/*
+		 * wpa_supplicant will control these internally
+		 */
+		ret = -EOPNOTSUPP;
+		break;
+
+	case IW_AUTH_WPA_VERSION:
+		switch (wpa) {
+		case 1:
+			param->value = IW_AUTH_WPA_VERSION_WPA;
+			break;
+		case 2:
+			param->value = IW_AUTH_WPA_VERSION_WPA2;
+			break;
+		case 0:
+		default:
+			param->value = IW_AUTH_WPA_VERSION_DISABLED;
+			break;
+		}
+		break;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+		if (ret >= 0) {
+			switch (r.u) {
+			case DOT11_AUTH_OS:
+				param->value = IW_AUTH_ALG_OPEN_SYSTEM;
+				break;
+			case DOT11_AUTH_BOTH:
+			case DOT11_AUTH_SK:
+				param->value = IW_AUTH_ALG_SHARED_KEY;
+			case DOT11_AUTH_NONE:
+			default:
+				param->value = 0;
+				break;
+			}
+		}
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		param->value = wpa > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_PRIVACY_INVOKED:
+		ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+	return ret;
+}
+
+static int prism54_set_encodeext(struct net_device *ndev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu,
+				 char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, alg = ext->alg, set_key = 1;
+	union oid_res_t r;
+	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
+	int ret = 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* Determine and validate the key index */
+	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
+	if (idx) {
+		if (idx < 0 || idx > 3)
+			return -EINVAL;
+	} else {
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret < 0)
+			goto out;
+		idx = r.u;
+	}
+
+	if (encoding->flags & IW_ENCODE_DISABLED)
+		alg = IW_ENCODE_ALG_NONE;
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+		/* Only set transmit key index here, actual
+		 * key is set below if needed.
+		 */
+		ret = mgt_set_request(priv, DOT11_OID_DEFKEYID, 0, &idx);
+		set_key = ext->key_len > 0 ? 1 : 0;
+	}
+
+	if (set_key) {
+		struct obj_key key = { DOT11_PRIV_WEP, 0, "" };
+		switch (alg) {
+		case IW_ENCODE_ALG_NONE:
+			break;
+		case IW_ENCODE_ALG_WEP:
+			if (ext->key_len > KEY_SIZE_WEP104) {
+				ret = -EINVAL;
+				goto out;
+			}
+			if (ext->key_len > KEY_SIZE_WEP40)
+				key.length = KEY_SIZE_WEP104;
+			else
+				key.length = KEY_SIZE_WEP40;
+			break;
+		case IW_ENCODE_ALG_TKIP:
+			if (ext->key_len > KEY_SIZE_TKIP) {
+				ret = -EINVAL;
+				goto out;
+			}
+			key.type = DOT11_PRIV_TKIP;
+			key.length = KEY_SIZE_TKIP;
+		default:
+			return -EINVAL;
+		}
+
+		if (key.length) {
+			memset(key.key, 0, sizeof(key.key));
+			memcpy(key.key, ext->key, ext->key_len);
+			ret = mgt_set_request(priv, DOT11_OID_DEFKEYX, idx,
+					    &key);
+			if (ret < 0)
+				goto out;
+		}
+	}
+
+	/* Read the flags */
+	if (encoding->flags & IW_ENCODE_DISABLED) {
+		/* Encoding disabled,
+		 * authen = DOT11_AUTH_OS;
+		 * invoke = 0;
+		 * exunencrypt = 0; */
+	}
+	if (encoding->flags & IW_ENCODE_OPEN) {
+		/* Encode but accept non-encoded packets. No auth */
+		invoke = 1;
+	}
+	if (encoding->flags & IW_ENCODE_RESTRICTED) {
+		/* Refuse non-encoded packets. Auth */
+		authen = DOT11_AUTH_BOTH;
+		invoke = 1;
+		exunencrypt = 1;
+	}
+
+	/* do the change if requested  */
+	if (encoding->flags & IW_ENCODE_MODE) {
+		ret = mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0,
+				      &authen);
+		ret = mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0,
+				      &invoke);
+		ret = mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
+				      &exunencrypt);
+	}
+
+out:
+	return ret;
+}
+
+
+static int prism54_get_encodeext(struct net_device *ndev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu,
+				 char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, max_key_len;
+	union oid_res_t r;
+	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0, wpa = 0;
+	int ret = 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	invoke = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt = r.u;
+	if (ret < 0)
+		goto out;
+
+	max_key_len = encoding->length - sizeof(*ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+
+	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
+	if (idx) {
+		if (idx < 0 || idx > 3)
+			return -EINVAL;
+	} else {
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret < 0)
+			goto out;
+		idx = r.u;
+	}
+
+	encoding->flags = idx + 1;
+	memset(ext, 0, sizeof(*ext));
+
+	switch (authen) {
+	case DOT11_AUTH_BOTH:
+	case DOT11_AUTH_SK:
+		wrqu->encoding.flags |= IW_ENCODE_RESTRICTED;
+	case DOT11_AUTH_OS:
+	default:
+		wrqu->encoding.flags |= IW_ENCODE_OPEN;
+		break;
+	}
+
+	down_write(&priv->mib_sem);
+	wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+
+	if (authen == DOT11_AUTH_OS && !exunencrypt && !invoke && !wpa) {
+		/* No encryption */
+		ext->alg = IW_ENCODE_ALG_NONE;
+		ext->key_len = 0;
+		wrqu->encoding.flags |= IW_ENCODE_DISABLED;
+	} else {
+		struct obj_key *key;
+
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYX, idx, NULL, &r);
+		if (ret < 0)
+			goto out;
+		key = r.ptr;
+		if (max_key_len < key->length) {
+			ret = -E2BIG;
+			goto out;
+		}
+		memcpy(ext->key, key->key, key->length);
+		ext->key_len = key->length;
+
+		switch (key->type) {
+		case DOT11_PRIV_TKIP:
+			ext->alg = IW_ENCODE_ALG_TKIP;
+			break;
+		default:
+		case DOT11_PRIV_WEP:
+			ext->alg = IW_ENCODE_ALG_WEP;
+			break;
+		}
+		wrqu->encoding.flags |= IW_ENCODE_ENABLED;
+	}
+
+out:
+	return ret;
+}
+
+
 static int
 prism54_reset(struct net_device *ndev, struct iw_request_info *info,
 	      __u32 * uwrq, char *extra)
@@ -1591,8 +2081,8 @@ #define MAC2STR(a) (a)[0], (a)[1], (a)[2
 #define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
 
 static void
-prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
-		   u8 *wpa_ie, size_t wpa_ie_len)
+prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
+		       u8 *wpa_ie, size_t wpa_ie_len)
 {
 	struct list_head *ptr;
 	struct islpci_bss_wpa_ie *bss = NULL;
@@ -1658,7 +2148,7 @@ prism54_wpa_ie_add(islpci_private *priv,
 }
 
 static size_t
-prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
+prism54_wpa_bss_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
 {
 	struct list_head *ptr;
 	struct islpci_bss_wpa_ie *bss = NULL;
@@ -1683,14 +2173,14 @@ prism54_wpa_ie_get(islpci_private *priv,
 }
 
 void
-prism54_wpa_ie_init(islpci_private *priv)
+prism54_wpa_bss_ie_init(islpci_private *priv)
 {
 	INIT_LIST_HEAD(&priv->bss_wpa_list);
 	sema_init(&priv->wpa_sem, 1);
 }
 
 void
-prism54_wpa_ie_clean(islpci_private *priv)
+prism54_wpa_bss_ie_clean(islpci_private *priv)
 {
 	struct list_head *ptr, *n;
 
@@ -1722,7 +2212,7 @@ prism54_process_bss_data(islpci_private 
 		}
 		if (pos[0] == WLAN_EID_GENERIC && pos[1] >= 4 &&
 		    memcmp(pos + 2, wpa_oid, 4) == 0) {
-			prism54_wpa_ie_add(priv, addr, pos, pos[1] + 2);
+			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
 			return;
 		}
 		pos += 2 + pos[1];
@@ -1879,7 +2369,7 @@ prism54_process_trap_helper(islpci_priva
 		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
 
 		if (priv->iw_mode != IW_MODE_MASTER 
-				&& mlmeex->state != DOT11_STATE_AUTHING)
+				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
 		
 		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
@@ -1893,7 +2383,7 @@ prism54_process_trap_helper(islpci_priva
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
 
-		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
@@ -1937,7 +2427,7 @@ prism54_process_trap_helper(islpci_priva
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
 
-		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
@@ -2553,6 +3043,15 @@ static const iw_handler prism54_handler[
 	(iw_handler) prism54_get_encode,	/* SIOCGIWENCODE */
 	(iw_handler) NULL,	/* SIOCSIWPOWER */
 	(iw_handler) NULL,	/* SIOCGIWPOWER */
+	NULL,			/* -- hole -- */
+	NULL,			/* -- hole -- */
+	(iw_handler) prism54_set_genie,	/* SIOCSIWGENIE */
+	(iw_handler) prism54_get_genie,	/* SIOCGIWGENIE */
+	(iw_handler) prism54_set_auth,	/* SIOCSIWAUTH */
+	(iw_handler) prism54_get_auth,	/* SIOCGIWAUTH */
+	(iw_handler) prism54_set_encodeext, /* SIOCSIWENCODEEXT */
+	(iw_handler) prism54_get_encodeext, /* SIOCGIWENCODEEXT */
+	NULL,			/* SIOCSIWPMKSA */
 };
 
 /* The low order bit identify a SET (0) or a GET (1) ioctl.  */
diff --git a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireless/prism54/isl_ioctl.h
index 46d5cde..65f33ac 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.h
+++ b/drivers/net/wireless/prism54/isl_ioctl.h
@@ -27,7 +27,7 @@ #include "islpci_dev.h"
 
 #include <net/iw_handler.h>	/* New driver API */
 
-#define SUPPORTED_WIRELESS_EXT                  16
+#define SUPPORTED_WIRELESS_EXT                  19
 
 void prism54_mib_init(islpci_private *);
 
@@ -39,8 +39,8 @@ void prism54_acl_clean(struct islpci_acl
 
 void prism54_process_trap(void *);
 
-void prism54_wpa_ie_init(islpci_private *priv);
-void prism54_wpa_ie_clean(islpci_private *priv);
+void prism54_wpa_bss_ie_init(islpci_private *priv);
+void prism54_wpa_bss_ie_clean(islpci_private *priv);
 
 int prism54_set_mac_address(struct net_device *, void *);
 
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 5ddf295..ab3c5a2 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -715,7 +715,7 @@ #endif
 	}
 
 	prism54_acl_init(&priv->acl);
-	prism54_wpa_ie_init(priv);
+	prism54_wpa_bss_ie_init(priv);
 	if (mgt_init(priv)) 
 		goto out_free;
 
@@ -774,7 +774,7 @@ islpci_free_memory(islpci_private *priv)
 
 	/* Free the acces control list and the WPA list */
 	prism54_acl_clean(&priv->acl);
-	prism54_wpa_ie_clean(priv);
+	prism54_wpa_bss_ie_clean(priv);
 	mgt_clean(priv);
 
 	return 0;
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wireless/prism54/islpci_dev.h
index 0705316..5049f37 100644
--- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -179,6 +179,8 @@ typedef struct {
 	struct list_head bss_wpa_list;
 	int num_bss_wpa;
 	struct semaphore wpa_sem;
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
 
 	struct work_struct reset_task;
 	int reset_task_pending;
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 9df232c..440ef24 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -72,10 +72,18 @@ static int iw_get_name(struct net_device
 	               struct iw_request_info *info,
 		       union iwreq_data *req, char *extra)
 {
-	/* FIXME: check whether 802.11a will also supported, add also
-	 *        zd1211B, if we support it.
-	 */
-	strlcpy(req->name, "802.11g zd1211", IFNAMSIZ);
+	/* FIXME: check whether 802.11a will also supported */
+	strlcpy(req->name, "IEEE 802.11b/g", IFNAMSIZ);
+	return 0;
+}
+
+static int iw_get_nick(struct net_device *netdev,
+	               struct iw_request_info *info,
+		       union iwreq_data *req, char *extra)
+{
+	strcpy(extra, "zd1211");
+	req->data.length = strlen(extra) + 1;
+	req->data.flags = 1;
 	return 0;
 }
 
@@ -181,6 +189,7 @@ #define WX(x) [(x)-SIOCIWFIRST]
 
 static const iw_handler zd_standard_iw_handlers[] = {
 	WX(SIOCGIWNAME)		= iw_get_name,
+	WX(SIOCGIWNICKN)	= iw_get_nick,
 	WX(SIOCSIWFREQ)		= iw_set_freq,
 	WX(SIOCGIWFREQ)		= iw_get_freq,
 	WX(SIOCSIWMODE)		= iw_set_mode,
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index ecc4286..b174ebb 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -240,6 +240,11 @@ #define WLAN_CAPABILITY_QOS (1<<9)
 #define WLAN_CAPABILITY_SHORT_SLOT_TIME (1<<10)
 #define WLAN_CAPABILITY_DSSS_OFDM (1<<13)
 
+/* 802.11g ERP information element */
+#define WLAN_ERP_NON_ERP_PRESENT (1<<0)
+#define WLAN_ERP_USE_PROTECTION (1<<1)
+#define WLAN_ERP_BARKER_PREAMBLE (1<<2)
+
 /* Status codes */
 enum ieee80211_statuscode {
 	WLAN_STATUS_SUCCESS = 0,
@@ -747,6 +752,8 @@ #define NETWORK_HAS_QUIET               
 #define NETWORK_HAS_IBSS_DFS            (1<<8)
 #define NETWORK_HAS_TPC_REPORT          (1<<9)
 
+#define NETWORK_HAS_ERP_VALUE           (1<<10)
+
 #define QOS_QUEUE_NUM                   4
 #define QOS_OUI_LEN                     3
 #define QOS_OUI_TYPE                    2
@@ -1252,6 +1259,8 @@ extern int ieee80211_tx_frame(struct iee
 			      int total_len, int encrypt_mpdu);
 
 /* ieee80211_rx.c */
+extern void ieee80211_rx_any(struct ieee80211_device *ieee,
+		     struct sk_buff *skb, struct ieee80211_rx_stats *stats);
 extern int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 			struct ieee80211_rx_stats *rx_stats);
 /* make sure to set stats->len */
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 00ad810..425b3a5 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -86,9 +86,6 @@ struct ieee80211softmac_assoc_info {
 	
 	/* BSSID we're trying to associate to */
 	char bssid[ETH_ALEN];
-
-	/* Rates supported by the network */
-	struct ieee80211softmac_ratesinfo supported_rates;
 	
 	/* some flags.
 	 * static_essid is valid if the essid is constant,
@@ -103,6 +100,7 @@ struct ieee80211softmac_assoc_info {
 	 * bssfixed is used for SIOCSIWAP.
 	 */
 	u8 static_essid:1,
+	   short_preamble_available:1,
 	   associating:1,
 	   assoc_wait:1,
 	   bssvalid:1,
@@ -115,6 +113,19 @@ struct ieee80211softmac_assoc_info {
 	struct work_struct timeout;
 };
 
+struct ieee80211softmac_bss_info {
+	/* Rates supported by the network */
+	struct ieee80211softmac_ratesinfo supported_rates;
+
+	/* This indicates whether frames can currently be transmitted with
+	 * short preamble (only use this variable during TX at CCK rates) */
+	u8 short_preamble:1;
+
+	/* This indicates whether protection (e.g. self-CTS) should be used
+	 * when transmitting with OFDM modulation */
+	u8 use_protection:1;
+};
+
 enum {
 	IEEE80211SOFTMAC_AUTH_OPEN_REQUEST	= 1,
 	IEEE80211SOFTMAC_AUTH_OPEN_RESPONSE	= 2,
@@ -157,6 +168,10 @@ #define IEEE80211SOFTMAC_TXRATECHG_DEFAU
 #define IEEE80211SOFTMAC_TXRATECHG_MCAST		(1 << 2) /* mcast_rate */
 #define IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST		(1 << 3) /* mgt_mcast_rate */
 
+#define IEEE80211SOFTMAC_BSSINFOCHG_RATES		(1 << 0) /* supported_rates */
+#define IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE	(1 << 1) /* short_preamble */
+#define IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION		(1 << 2) /* use_protection */
+
 struct ieee80211softmac_device {
 	/* 802.11 structure for data stuff */
 	struct ieee80211_device *ieee;
@@ -200,10 +215,16 @@ struct ieee80211softmac_device {
 	 * The driver just needs to read them.
 	 */
 	struct ieee80211softmac_txrates txrates;
-	/* If the driver needs to do stuff on TX rate changes, assign this callback. */
+
+	/* If the driver needs to do stuff on TX rate changes, assign this
+	 * callback. See IEEE80211SOFTMAC_TXRATECHG for change flags. */
 	void (*txrates_change)(struct net_device *dev,
-			       u32 changes, /* see IEEE80211SOFTMAC_TXRATECHG flags */
-			       const struct ieee80211softmac_txrates *rates_before_change);
+			       u32 changes);
+
+	/* If the driver needs to do stuff when BSS properties change, assign
+	 * this callback. see IEEE80211SOFTMAC_BSSINFOCHG for change flags. */
+	void (*bssinfo_change)(struct net_device *dev,
+			       u32 changes);
 
 	/* private stuff follows */
 	/* this lock protects this structure */
@@ -216,6 +237,7 @@ struct ieee80211softmac_device {
 	
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
+	struct ieee80211softmac_bss_info bssinfo;
 
 	struct list_head auth_queue;
 	struct list_head events;
@@ -257,6 +279,14 @@ extern void ieee80211softmac_fragment_lo
  * Note that the rates need to be sorted. */
 extern void ieee80211softmac_set_rates(struct net_device *dev, u8 count, u8 *rates);
 
+/* Finds the highest rate which is:
+ *  1. Present in ri (optionally a basic rate)
+ *  2. Supported by the device
+ *  3. Less than or equal to the user-defined rate
+ */
+extern u8 ieee80211softmac_highest_supported_rate(struct ieee80211softmac_device *mac,
+	struct ieee80211softmac_ratesinfo *ri, int basic_only);
+
 /* Helper function which advises you the rate at which a frame should be
  * transmitted at. */
 static inline u8 ieee80211softmac_suggest_txrate(struct ieee80211softmac_device *mac,
@@ -279,6 +309,24 @@ static inline u8 ieee80211softmac_sugges
 		return txrates->mcast_rate;
 }
 
+/* Helper function which advises you when it is safe to transmit with short
+ * preamble.
+ * You should only call this function when transmitting at CCK rates. */
+static inline int ieee80211softmac_short_preamble_ok(struct ieee80211softmac_device *mac,
+						    int is_multicast,
+						    int is_mgt)
+{
+	return (is_multicast && is_mgt) ? 0 : mac->bssinfo.short_preamble;
+}
+
+/* Helper function which advises you whether protection (e.g. self-CTS) is
+ * needed. 1 = protection needed, 0 = no protection needed
+ * Only use this function when transmitting with OFDM modulation. */
+static inline int ieee80211softmac_protection_needed(struct ieee80211softmac_device *mac)
+{
+	return mac->bssinfo.use_protection;
+}
+
 /* Start the SoftMAC. Call this after you initialized the device
  * and it is ready to run.
  */
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 72d4d4e..d60358d 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -779,33 +779,44 @@ #endif
 	return 0;
 }
 
-/* Filter out unrelated packets, call ieee80211_rx[_mgt] */
-int ieee80211_rx_any(struct ieee80211_device *ieee,
+/* Filter out unrelated packets, call ieee80211_rx[_mgt]
+ * This function takes over the skb, it should not be used again after calling
+ * this function. */
+void ieee80211_rx_any(struct ieee80211_device *ieee,
 		     struct sk_buff *skb, struct ieee80211_rx_stats *stats)
 {
 	struct ieee80211_hdr_4addr *hdr;
 	int is_packet_for_us;
 	u16 fc;
 
-	if (ieee->iw_mode == IW_MODE_MONITOR)
-		return ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL;
+	if (ieee->iw_mode == IW_MODE_MONITOR) {
+		if (!ieee80211_rx(ieee, skb, stats))
+			dev_kfree_skb_irq(skb);
+		return;
+	}
+
+	if (skb->len < sizeof(struct ieee80211_hdr))
+		goto drop_free;
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
 	fc = le16_to_cpu(hdr->frame_ctl);
 
 	if ((fc & IEEE80211_FCTL_VERS) != 0)
-		return -EINVAL;
+		goto drop_free;
 		
 	switch (fc & IEEE80211_FCTL_FTYPE) {
 	case IEEE80211_FTYPE_MGMT:
+		if (skb->len < sizeof(struct ieee80211_hdr_3addr))
+			goto drop_free;
 		ieee80211_rx_mgt(ieee, hdr, stats);
-		return 0;
+		dev_kfree_skb_irq(skb);
+		return;
 	case IEEE80211_FTYPE_DATA:
 		break;
 	case IEEE80211_FTYPE_CTL:
-		return 0;
+		return;
 	default:
-		return -EINVAL;
+		return;
 	}
 
 	is_packet_for_us = 0;
@@ -849,8 +860,14 @@ int ieee80211_rx_any(struct ieee80211_de
 	}
 
 	if (is_packet_for_us)
-		return (ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL);
-	return 0;
+		if (!ieee80211_rx(ieee, skb, stats))
+			dev_kfree_skb_irq(skb);
+	return;
+
+drop_free:
+	dev_kfree_skb_irq(skb);
+	ieee->stats.rx_dropped++;
+	return;
 }
 
 #define MGMT_FRAME_FIXED_PART_LENGTH		0x24
@@ -1166,6 +1183,7 @@ #endif
 
 		case MFIE_TYPE_ERP_INFO:
 			network->erp_value = info_element->data[0];
+			network->flags |= NETWORK_HAS_ERP_VALUE;
 			IEEE80211_DEBUG_MGMT("MFIE_TYPE_ERP_SET: %d\n",
 					     network->erp_value);
 			break;
@@ -1729,5 +1747,6 @@ void ieee80211_rx_mgt(struct ieee80211_d
 	}
 }
 
+EXPORT_SYMBOL_GPL(ieee80211_rx_any);
 EXPORT_SYMBOL(ieee80211_rx_mgt);
 EXPORT_SYMBOL(ieee80211_rx);
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index 44215ce..589f6d2 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -96,7 +96,7 @@ ieee80211softmac_disassoc(struct ieee802
 	mac->associated = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associnfo.associating = 0;
-	ieee80211softmac_init_txrates(mac);
+	ieee80211softmac_init_bss(mac);
 	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
@@ -334,11 +334,19 @@ ieee80211softmac_associated(struct ieee8
 	struct ieee80211_assoc_response * resp,
 	struct ieee80211softmac_network *net)
 {
+	u16 cap = le16_to_cpu(resp->capability);
+	u8 erp_value = net->erp_value;
+
 	mac->associnfo.associating = 0;
-	mac->associnfo.supported_rates = net->supported_rates;
+	mac->bssinfo.supported_rates = net->supported_rates;
 	ieee80211softmac_recalc_txrates(mac);
 
 	mac->associated = 1;
+
+	mac->associnfo.short_preamble_available =
+		(cap & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0;
+	ieee80211softmac_process_erp(mac, erp_value);
+
 	if (mac->set_bssid_filter)
 		mac->set_bssid_filter(mac->dev, net->bssid);
 	memcpy(mac->ieee->bssid, net->bssid, ETH_ALEN);
@@ -351,9 +359,9 @@ ieee80211softmac_associated(struct ieee8
 int
 ieee80211softmac_handle_assoc_response(struct net_device * dev,
 				       struct ieee80211_assoc_response * resp,
-				       struct ieee80211_network * _ieee80211_network_do_not_use)
+				       struct ieee80211_network * _ieee80211_network)
 {
-	/* NOTE: the network parameter has to be ignored by
+	/* NOTE: the network parameter has to be mostly ignored by
 	 *       this code because it is the ieee80211's pointer
 	 *       to the struct, not ours (we made a copy)
 	 */
@@ -385,6 +393,11 @@ ieee80211softmac_handle_assoc_response(s
 	/* now that we know it was for us, we can cancel the timeout */
 	cancel_delayed_work(&mac->associnfo.timeout);
 
+	/* if the association response included an ERP IE, update our saved
+	 * copy */
+	if (_ieee80211_network->flags & NETWORK_HAS_ERP_VALUE)
+		network->erp_value = _ieee80211_network->erp_value;
+
 	switch (status) {
 		case 0:
 			dprintk(KERN_INFO PFX "associated!\n");
diff --git a/net/ieee80211/softmac/ieee80211softmac_io.c b/net/ieee80211/softmac/ieee80211softmac_io.c
index 6ae5a1d..82bfddb 100644
--- a/net/ieee80211/softmac/ieee80211softmac_io.c
+++ b/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -467,3 +467,17 @@ ieee80211softmac_send_mgt_frame(struct i
 	kfree(pkt);
 	return 0;
 }
+
+/* Beacon handling */
+int ieee80211softmac_handle_beacon(struct net_device *dev,
+	struct ieee80211_beacon *beacon,
+	struct ieee80211_network *network)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+
+	if (mac->associated && memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
+		ieee80211softmac_process_erp(mac, network->erp_value);
+
+	return 0;
+}
+
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index 4b2e57d..addea1c 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -44,6 +44,7 @@ struct net_device *alloc_ieee80211softma
 	softmac->ieee->handle_assoc_response = ieee80211softmac_handle_assoc_response;
 	softmac->ieee->handle_reassoc_request = ieee80211softmac_handle_reassoc_req;
 	softmac->ieee->handle_disassoc = ieee80211softmac_handle_disassoc;
+ 	softmac->ieee->handle_beacon = ieee80211softmac_handle_beacon;
 	softmac->scaninfo = NULL;
 
 	softmac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
@@ -178,21 +179,14 @@ int ieee80211softmac_ratesinfo_rate_supp
 	return 0;
 }
 
-/* Finds the highest rate which is:
- *  1. Present in ri (optionally a basic rate)
- *  2. Supported by the device
- *  3. Less than or equal to the user-defined rate
- */
-static u8 highest_supported_rate(struct ieee80211softmac_device *mac,
+u8 ieee80211softmac_highest_supported_rate(struct ieee80211softmac_device *mac,
 	struct ieee80211softmac_ratesinfo *ri, int basic_only)
 {
 	u8 user_rate = mac->txrates.user_rate;
 	int i;
 
-	if (ri->count == 0) {
-		dprintk(KERN_ERR PFX "empty ratesinfo?\n");
+	if (ri->count == 0)
 		return IEEE80211_CCK_RATE_1MB;
-	}
 
 	for (i = ri->count - 1; i >= 0; i--) {
 		u8 rate = ri->rates[i];
@@ -208,36 +202,61 @@ static u8 highest_supported_rate(struct 
 	/* If we haven't found a suitable rate by now, just trust the user */
 	return user_rate;
 }
+EXPORT_SYMBOL_GPL(ieee80211softmac_highest_supported_rate);
+
+void ieee80211softmac_process_erp(struct ieee80211softmac_device *mac,
+	u8 erp_value)
+{
+ 	int use_protection;
+	int short_preamble;
+ 	u32 changes = 0;
+
+	/* Barker preamble mode */
+	short_preamble = ((erp_value & WLAN_ERP_BARKER_PREAMBLE) == 0
+			  && mac->associnfo.short_preamble_available) ? 1 : 0;
+
+	/* Protection needed? */
+	use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
+
+	if (mac->bssinfo.short_preamble != short_preamble) {
+		changes |= IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE;
+		mac->bssinfo.short_preamble = short_preamble;
+	}
+
+	if (mac->bssinfo.use_protection != use_protection) {
+		changes |= IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION;
+		mac->bssinfo.use_protection = use_protection;
+	}
+
+	if (mac->bssinfo_change && changes)
+		mac->bssinfo_change(mac->dev, changes);
+}
 
 void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac)
 {
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
-	struct ieee80211softmac_txrates oldrates;
 	u32 change = 0;
 
-	if (mac->txrates_change)
-		oldrates = mac->txrates;
-
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-	txrates->default_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 0);
+	txrates->default_rate = ieee80211softmac_highest_supported_rate(mac, &mac->bssinfo.supported_rates, 0);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
 	txrates->default_fallback = lower_rate(mac, txrates->default_rate);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
-	txrates->mcast_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 1);
+	txrates->mcast_rate = ieee80211softmac_highest_supported_rate(mac, &mac->bssinfo.supported_rates, 1);
 
 	if (mac->txrates_change)
-		mac->txrates_change(mac->dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change);
 
 }
 
-void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac)
+void ieee80211softmac_init_bss(struct ieee80211softmac_device *mac)
 {
 	struct ieee80211_device *ieee = mac->ieee;
 	u32 change = 0;
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
-	struct ieee80211softmac_txrates oldrates;
+	struct ieee80211softmac_bss_info *bssinfo = &mac->bssinfo;
 
 	/* TODO: We need some kind of state machine to lower the default rates
 	 *       if we loose too many packets.
@@ -245,8 +264,6 @@ void ieee80211softmac_init_txrates(struc
 	/* Change the default txrate to the highest possible value.
 	 * The txrate machine will lower it, if it is too high.
 	 */
-	if (mac->txrates_change)
-		oldrates = mac->txrates;
 	/* FIXME: We don't correctly handle backing down to lower
 	   rates, so 801.11g devices start off at 11M for now. People
 	   can manually change it if they really need to, but 11M is
@@ -272,7 +289,23 @@ void ieee80211softmac_init_txrates(struc
 	change |= IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST;
 
 	if (mac->txrates_change)
-		mac->txrates_change(mac->dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change);
+
+	change = 0;
+
+	bssinfo->supported_rates.count = 0;
+	memset(bssinfo->supported_rates.rates, 0,
+		sizeof(bssinfo->supported_rates.rates));
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_RATES;
+
+	bssinfo->short_preamble = 0;
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE;
+
+	bssinfo->use_protection = 0;
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION;
+
+	if (mac->bssinfo_change)
+		mac->bssinfo_change(mac->dev, change);
 
 	mac->running = 1;
 }
@@ -282,7 +315,7 @@ void ieee80211softmac_start(struct net_d
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 
 	ieee80211softmac_start_check_rates(mac);
-	ieee80211softmac_init_txrates(mac);
+	ieee80211softmac_init_bss(mac);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
@@ -335,7 +368,6 @@ u8 ieee80211softmac_lower_rate_delta(str
 static void ieee80211softmac_add_txrates_badness(struct ieee80211softmac_device *mac,
 						 int amount)
 {
-	struct ieee80211softmac_txrates oldrates;
 	u8 default_rate = mac->txrates.default_rate;
 	u8 default_fallback = mac->txrates.default_fallback;
 	u32 changes = 0;
@@ -348,8 +380,6 @@ printk("badness %d\n", mac->txrate_badne
 	mac->txrate_badness += amount;
 	if (mac->txrate_badness <= -1000) {
 		/* Very small badness. Try a faster bitrate. */
-		if (mac->txrates_change)
-			memcpy(&oldrates, &mac->txrates, sizeof(oldrates));
 		default_rate = raise_rate(mac, default_rate);
 		changes |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
 		default_fallback = get_fallback_rate(mac, default_rate);
@@ -358,8 +388,6 @@ printk("badness %d\n", mac->txrate_badne
 printk("Bitrate raised to %u\n", default_rate);
 	} else if (mac->txrate_badness >= 10000) {
 		/* Very high badness. Try a slower bitrate. */
-		if (mac->txrates_change)
-			memcpy(&oldrates, &mac->txrates, sizeof(oldrates));
 		default_rate = lower_rate(mac, default_rate);
 		changes |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
 		default_fallback = get_fallback_rate(mac, default_rate);
@@ -372,7 +400,7 @@ printk("Bitrate lowered to %u\n", defaul
 	mac->txrates.default_fallback = default_fallback;
 
 	if (changes && mac->txrates_change)
-		mac->txrates_change(mac->dev, changes, &oldrates);
+		mac->txrates_change(mac->dev, changes);
 }
 
 void ieee80211softmac_fragment_lost(struct net_device *dev,
@@ -416,7 +444,11 @@ ieee80211softmac_create_network(struct i
 	memcpy(&softnet->supported_rates.rates[softnet->supported_rates.count], net->rates_ex, net->rates_ex_len);
 	softnet->supported_rates.count += net->rates_ex_len;
 	sort(softnet->supported_rates.rates, softnet->supported_rates.count, sizeof(softnet->supported_rates.rates[0]), rate_cmp, NULL);
-	
+
+	/* we save the ERP value because it is needed at association time, and
+	 * many AP's do not include an ERP IE in the association response. */
+	softnet->erp_value = net->erp_value;
+
 	softnet->capabilities = net->capability;
 	return softnet;
 }
diff --git a/net/ieee80211/softmac/ieee80211softmac_priv.h b/net/ieee80211/softmac/ieee80211softmac_priv.h
index fa1f8e3..0642e09 100644
--- a/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ b/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -116,9 +116,11 @@ ieee80211softmac_get_network_by_essid(st
 	struct ieee80211softmac_essid *essid);
 
 /* Rates related */
+void ieee80211softmac_process_erp(struct ieee80211softmac_device *mac,
+	u8 erp_value);
 int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate);
 u8 ieee80211softmac_lower_rate_delta(struct ieee80211softmac_device *mac, u8 rate, int delta);
-void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac);
+void ieee80211softmac_init_bss(struct ieee80211softmac_device *mac);
 void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac);
 static inline u8 lower_rate(struct ieee80211softmac_device *mac, u8 rate) {
 	return ieee80211softmac_lower_rate_delta(mac, rate, 1);
@@ -133,6 +135,9 @@ static inline u8 get_fallback_rate(struc
 /*** prototypes from _io.c */
 int ieee80211softmac_send_mgt_frame(struct ieee80211softmac_device *mac,
 	void* ptrarg, u32 type, u32 arg);
+int ieee80211softmac_handle_beacon(struct net_device *dev,
+	struct ieee80211_beacon *beacon,
+	struct ieee80211_network *network);
 
 /*** prototypes from _auth.c */
 /* do these have to go into the public header? */
@@ -189,6 +194,7 @@ struct ieee80211softmac_network {
 	    authenticated:1,
 	    auth_desynced_once:1;
 
+	u8 erp_value;				/* Saved ERP value */
 	u16 capabilities;			/* Capabilities bitfield */
 	u8 challenge_len;			/* Auth Challenge length */
 	char *challenge;			/* Challenge Text */
-- 
John W. Linville
linville@tuxdriver.com
