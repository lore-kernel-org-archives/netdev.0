From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 5/6 linux-2.6.9-rc1/2.4.28-pre2] prism54
	initial WPA support
Date: Sun, 5 Sep 2004 12:32:29 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200409051232.29014.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_9suOBTiZpSr4nE3"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_9suOBTiZpSr4nE3
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-09-05 Margit Schubert-While <margitsw@t-online.de>

2004-08-18 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

* Work based on initial patches from Jouni Malinen <jkmaline@cc.hut.fi>
* Initial wpa_supplicant support work:
* isl_ioctl.c (prism54_process_trap_helper): Start to use mlmeex,
* start doing what's right for
* DOT11_OID_AUTHENTICATEEX,
* DOT11_OID_ASSOCIATEEX,
* DOT11_OID_ASSOCIATEEX, and
* DOT11_OID_REASSOCIATEEX

* isl_ioctl.c: add temporary structure for wpa_supplicant requests,

* isl_ioctl.c: add prism2_ioctl_set_encryption which can probably be removed 
later

* isl_ioctl.c: add prism2_ioctl_set_generic_element (well tested)

* isl_ioctl.c: add prism2_ioctl_mlme which should be unnecessary since
* WE scan should be used by wpa_supplicant

* isl_ioctl.c: add prism54_hostapd - this parses wpa_supplicant
* requests and does the right job for each

* isl_ioctl.c (prism54_set_wpa): changed to not use mgt_set/mgt_commit
* as commit is unecessary. Added proper OID sets to enable/disable WPA.
* This is called by wpa_supplicant at startup. This should eventually
* be part of WE18.

* isl_ioctl.c (prism54_ioctl): Links wpa_supplicant to prism54

* isl_ioctl.h: defined prism54_set_wpa to allow prism54_hostapd to use

* isl_oid.h: add struct obj_attachment for OID OID_TYPE_ATTACH

* oid_mgt.c: map OID DOT11_OID_ATTACHMENT to struct obj_attachment

* oid_mgt.c (mgt_le_to_cpu, mgt_cpu_to_le): handle endianness for
* obj_attachment

* oid_mgt.c: add mgt_set_varlen, needed for mlmeex as it has a
* variable size field.

* oid_mgt.c: add mgt_unlatch_all, this can be used to force a commit
* on OIDs:
* MEDIUMLIMIT, BEACONPERIOD, DTIMPERIOD, ATIMWINDOW,
* LISTENINTERVAL, FREQUENCY, EXTENDEDRATES
* These OIDs are "latched". TODO: config mode handling.
* oid_mgt.c (mgt_response_to_str): learn to parse OID_TYPE_ATTACH
* oid_mgt.h: add mgt_set_varlen, and mgt_unlatch_all


Margit















--Boundary-00=_9suOBTiZpSr4nE3
Content-Type: text/x-diff;
  charset="us-ascii";
  name="05_start_wpa.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="05_start_wpa.patch"

diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:48:32.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:49:05.000000000 +0200
@@ -1735,11 +1735,13 @@
 			    char *data)
 {
 	struct obj_mlme *mlme = (struct obj_mlme *) data;
-	size_t len;
-	u8 *payload, *pos = (u8 *) (mlme + 1);
-
-	len = pos[0] | (pos[1] << 8);	/* little endian data length */
-	payload = pos + 2;
+	struct obj_mlmeex *mlmeex = (struct obj_mlmeex *) data;
+	struct obj_mlmeex *confirm;
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	int wpa_ie_len;
+	size_t len = 0; /* u16, better? */
+	u8 *payload = 0, *pos = 0;
+	int ret;
 
 	/* I think all trapable objects are listed here.
 	 * Some oids have a EX version. The difference is that they are emitted
@@ -1749,9 +1751,14 @@
 	 * suited. We use the more flexible custom event facility.
 	 */
 
+	if (oid >= DOT11_OID_BEACON) {
+		len = mlmeex->size;
+		payload = pos = mlmeex->data;
+	}
+
 	/* I fear prism54_process_bss_data won't work with big endian data */
 	if ((oid == DOT11_OID_BEACON) || (oid == DOT11_OID_PROBE))
-		prism54_process_bss_data(priv, oid, mlme->address,
+		prism54_process_bss_data(priv, oid, mlmeex->address,
 					 payload, len);
 
 	mgt_le_to_cpu(isl_oid[oid].flags & OID_FLAG_TYPE, (void *) mlme);
@@ -1811,21 +1818,134 @@
 
 	case DOT11_OID_AUTHENTICATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Authenticate request", mlme, 1);
+		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
+
+		if (priv->iw_mode != IW_MODE_MASTER 
+				&& mlmeex->state != DOT11_STATE_AUTHING)
+			break;
+
+		confirm = kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
+
+		if (!confirm) 
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+		confirm->id = -1; /* or mlmeex->id ? */
+		confirm->state = 0; /* not used */
+		confirm->code = 0;
+		confirm->size = 6;
+		confirm->data[0] = 0x00;
+		confirm->data[1] = 0x00;
+		confirm->data[2] = 0x02;
+		confirm->data[3] = 0x00;
+		confirm->data[4] = 0x00;
+		confirm->data[5] = 0x00;
+
+		ret = mgt_set_varlen(priv, DOT11_OID_ASSOCIATEEX, confirm, 6);
+
+		kfree(confirm);
+		if (ret)
+			return ret;
 		break;
 
 	case DOT11_OID_DISASSOCIATEEX:
-		send_formatted_event(priv, "Disassociate request", mlme, 0);
+		send_formatted_event(priv, "Disassociate request (ex)", mlme, 0);
 		break;
 
 	case DOT11_OID_ASSOCIATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Associate request", mlme, 1);
+		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
+
+		if (priv->iw_mode != IW_MODE_MASTER 
+				&& mlmeex->state != DOT11_STATE_AUTHING)
+			break;
+		
+		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
+
+		if (!confirm)
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+
+		confirm->id = ((struct obj_mlmeex *)mlme)->id;
+		confirm->state = 0; /* not used */
+		confirm->code = 0;
+
+		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+
+		if (!wpa_ie_len) {
+			printk(KERN_DEBUG "No WPA IE found from "
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+			kfree(confirm);
+			break;
+		}
+
+		confirm->size = wpa_ie_len;
+		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
+
+		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
+
+		kfree(confirm);
+		
 		break;
 
 	case DOT11_OID_REASSOCIATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Reassociate request", mlme, 1);
+		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
+
+		if (priv->iw_mode != IW_MODE_MASTER 
+				&& mlmeex->state != DOT11_STATE_ASSOCING)
+			break;
+
+		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
+
+		if (!confirm)
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+
+		confirm->id = mlmeex->id;
+		confirm->state = 0; /* not used */
+		confirm->code = 0;
+
+		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+
+		if (!wpa_ie_len) {
+			printk(KERN_DEBUG "No WPA IE found from "
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+			kfree(confirm);
+			break;
+		}
+
+		confirm->size = wpa_ie_len; 
+		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
+
+		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
+
+		kfree(confirm);
+		
 		break;
 
 	default:
@@ -1868,23 +1988,367 @@
 	return ret;
 }
 
+/* Note: currently, use hostapd ioctl from the Host AP driver for WPA
+ * support. This is to be replaced with Linux wireless extensions once they
+ * get WPA support. */
+
+/* Note II: please leave all this together as it will be easier to remove later,
+ * once wireless extensions add WPA support -mcgrof */
+
+/* PRISM54_HOSTAPD ioctl() cmd: */
+enum {
+	PRISM2_SET_ENCRYPTION = 6,
+	PRISM2_HOSTAPD_SET_GENERIC_ELEMENT = 12,
+	PRISM2_HOSTAPD_MLME = 13,
+	PRISM2_HOSTAPD_SCAN_REQ = 14,
+};
+
+#define PRISM54_SET_WPA			SIOCIWFIRSTPRIV+12
+#define PRISM54_HOSTAPD			SIOCIWFIRSTPRIV+25
+#define PRISM54_DROP_UNENCRYPTED	SIOCIWFIRSTPRIV+26
+
+#define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
+#define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
+((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
+
+/* Maximum length for algorithm names (-1 for nul termination) 
+ * used in ioctl() */
+#define HOSTAP_CRYPT_ALG_NAME_LEN 16
+	
+struct prism2_hostapd_param {
+	u32 cmd;
+	u8 sta_addr[ETH_ALEN];
+	union {
+	       struct {
+		       u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
+		       u32 flags;
+		       u32 err;
+		       u8 idx;
+		       u8 seq[8]; /* sequence counter (set: RX, get: TX) */
+		       u16 key_len;
+		       u8 key[0];
+		       } crypt;
+               struct {
+                       u8 len;
+                       u8 data[0];
+               } generic_elem;
+               struct {
+#define MLME_STA_DEAUTH 0
+#define MLME_STA_DISASSOC 1
+                       u16 cmd;
+                       u16 reason_code;
+               } mlme;
+               struct {
+                       u8 ssid_len;
+                       u8 ssid[32];
+               } scan_req;
+       } u;
+};
+
+
+static int
+prism2_ioctl_set_encryption(struct net_device *dev,
+	struct prism2_hostapd_param *param,
+	int param_len)
+{
+	islpci_private *priv = netdev_priv(dev);
+	int rvalue = 0, force = 0;
+	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
+	union oid_res_t r;
+
+	/* with the new API, it's impossible to get a NULL pointer.
+	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
+	 * when no key is given, but older versions don't. */
+
+	if (param->u.crypt.key_len > 0) {
+		/* we have a key to set */
+		int index = param->u.crypt.idx;
+		int current_index;
+		struct obj_key key = { DOT11_PRIV_TKIP, 0, "" };
+
+		/* get the current key index */
+		rvalue = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		current_index = r.u;
+		/* Verify that the key is not marked as invalid */
+		if (!(param->u.crypt.flags & IW_ENCODE_NOKEY)) {
+			key.length = param->u.crypt.key_len > sizeof (param->u.crypt.key) ?
+			    sizeof (param->u.crypt.key) : param->u.crypt.key_len;
+			memcpy(key.key, param->u.crypt.key, key.length);
+			if (key.length == 32)
+				/* we want WPA-PSK */
+				key.type = DOT11_PRIV_TKIP;
+			if ((index < 0) || (index > 3))
+				/* no index provided use the current one */
+				index = current_index;
+
+			/* now send the key to the card  */
+			rvalue |=
+			    mgt_set_request(priv, DOT11_OID_DEFKEYX, index,
+					    &key);
+		}
+		/*
+		 * If a valid key is set, encryption should be enabled 
+		 * (user may turn it off later).
+		 * This is also how "iwconfig ethX key on" works
+		 */
+		if ((index == current_index) && (key.length > 0))
+			force = 1;
+	} else {
+		int index = (param->u.crypt.flags & IW_ENCODE_INDEX) - 1;
+		if ((index >= 0) && (index <= 3)) {
+			/* we want to set the key index */
+			rvalue |=
+			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
+					    &index);
+		} else {
+			if (!param->u.crypt.flags & IW_ENCODE_MODE) {
+				/* we cannot do anything. Complain. */
+				return -EINVAL;
+			}
+		}
+	}
+	/* now read the flags */
+	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
+		/* Encoding disabled, 
+		 * authen = DOT11_AUTH_OS;
+		 * invoke = 0;
+		 * exunencrypt = 0; */
+	}
+	if (param->u.crypt.flags & IW_ENCODE_OPEN)
+		/* Encode but accept non-encoded packets. No auth */
+		invoke = 1;
+	if ((param->u.crypt.flags & IW_ENCODE_RESTRICTED) || force) {
+		/* Refuse non-encoded packets. Auth */
+		authen = DOT11_AUTH_BOTH;
+		invoke = 1;
+		exunencrypt = 1;
+	}
+	/* do the change if requested  */
+	if ((param->u.crypt.flags & IW_ENCODE_MODE) || force) {
+		rvalue |=
+		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+		rvalue |=
+		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
+		rvalue |=
+		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
+				    &exunencrypt);
+	}
+	return rvalue;
+}
+
+static int
+prism2_ioctl_set_generic_element(struct net_device *ndev,
+	struct prism2_hostapd_param *param,
+	int param_len)
+{
+       islpci_private *priv = netdev_priv(ndev);
+       int max_len, len, alen, ret=0;
+       struct obj_attachment *attach;
+
+       len = param->u.generic_elem.len;
+       max_len = param_len - PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
+       if (max_len < 0 || max_len < len)
+               return -EINVAL;
+
+       alen = sizeof(*attach) + len;
+       attach = kmalloc(alen, GFP_KERNEL);
+       if (attach == NULL)
+               return -ENOMEM;
+
+       memset(attach, 0, alen);
+#define WLAN_FC_TYPE_MGMT 0
+#define WLAN_FC_STYPE_ASSOC_REQ 0
+#define WLAN_FC_STYPE_REASSOC_REQ 2
+
+       /* Note: endianness is covered by mgt_set_varlen */
+
+       attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+               (WLAN_FC_STYPE_ASSOC_REQ << 4);
+       attach->id = -1;
+       attach->size = len;
+       memcpy(attach->data, param->u.generic_elem.data, len);
+
+       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
+
+       if (ret == 0) {
+               attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+                       (WLAN_FC_STYPE_REASSOC_REQ << 4);
+
+	       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
+
+	       if (ret == 0) 
+		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
+				       ndev->name);
+       }
+
+       kfree(attach);
+       return ret;
+
+}
+
+static int
+prism2_ioctl_mlme(struct net_device *dev, struct prism2_hostapd_param *param)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+prism2_ioctl_scan_req(struct net_device *ndev,
+                     struct prism2_hostapd_param *param)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	int i, rvalue;
+	struct obj_bsslist *bsslist;
+	u32 noise = 0;
+	char *extra = "";
+	char *current_ev = "foo";
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		/* device is not ready, fail gently */
+		return 0;
+	}
+
+	/* first get the noise value. We will use it to report the link quality */
+	rvalue = mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
+	noise = r.u;
+
+	/* Ask the device for a list of known bss. We can report at most
+	 * IW_MAX_AP=64 to the range struct. But the device won't repport anything
+	 * if you change the value of IWMAX_BSS=24.
+	 */
+	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
+	bsslist = r.ptr;
+
+	/* ok now, scan the list and translate its info */
+	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+		current_ev = prism54_translate_bss(ndev, current_ev,
+						   extra + IW_SCAN_MAX_DATA,
+						   &(bsslist->bsslist[i]),
+						   noise);
+	kfree(bsslist);
+
+	return rvalue;
+}
+
+static int
+prism54_hostapd(struct net_device *ndev, struct iw_point *p)
+{
+       struct prism2_hostapd_param *param;
+       int ret = 0;
+       u32 uwrq;
+
+       printk(KERN_DEBUG "prism54_hostapd - len=%d\n", p->length);
+       if (p->length < sizeof(struct prism2_hostapd_param) ||
+           p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
+               return -EINVAL;
+
+       param = (struct prism2_hostapd_param *) kmalloc(p->length, GFP_KERNEL);
+       if (param == NULL)
+               return -ENOMEM;
+
+       if (copy_from_user(param, p->pointer, p->length)) {
+               kfree(param);
+               return -EFAULT;
+       }
+
+       switch (param->cmd) {
+       case PRISM2_SET_ENCRYPTION:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant set encryption request\n",
+			       ndev->name);
+               ret = prism2_ioctl_set_encryption(ndev, param, p->length);
+               break;
+       case PRISM2_HOSTAPD_SET_GENERIC_ELEMENT:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant set WPA IE request\n",
+			       ndev->name);
+               ret = prism2_ioctl_set_generic_element(ndev, param,
+                                                      p->length);
+               break;
+       case PRISM2_HOSTAPD_MLME:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant MLME request\n",
+			       ndev->name);
+               ret = prism2_ioctl_mlme(ndev, param);
+               break;
+       case PRISM2_HOSTAPD_SCAN_REQ:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant scan request\n",
+			       ndev->name);
+               ret = prism2_ioctl_scan_req(ndev, param);
+               break;
+	case PRISM54_SET_WPA:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant wpa init request\n",
+			       ndev->name);
+	       uwrq = 1;
+	       ret = prism54_set_wpa(ndev, NULL, &uwrq, NULL);
+	       break;
+	case PRISM54_DROP_UNENCRYPTED:
+	       printk(KERN_DEBUG "%s: Caught WPA drop unencrypted request\n",
+			       ndev->name);
+#if 0
+	       uwrq = 0x01;
+	       mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &uwrq);
+	       down_write(&priv->mib_sem);
+	       mgt_commit(priv);
+	       up_write(&priv->mib_sem);
+#endif
+	       /* Not necessary, as set_wpa does it, should we just do it here though? */
+	       ret = 0;
+	       break;
+       default:
+	       printk(KERN_DEBUG "%s: Caught a WPA supplicant request that is not supported\n",
+			       ndev->name);
+               ret = -EOPNOTSUPP;
+               break;
+       }
+
+       if (ret == 0 && copy_to_user(p->pointer, param, p->length))
+               ret = -EFAULT;
+
+       kfree(param);
+
+       return ret;
+}
+
 int
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
+	u32 mlme, authen, dot1x, filter, wep;
 
-	down_write(&priv->mib_sem);
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
 
+	wep = 1; /* For privacy invoked */
+	filter = 1; /* Filter out all unencrypted frames */
+	dot1x = 0x01; /* To enable eap filter */
+	mlme = DOT11_MLME_EXTENDED;
+	authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+
+	down_write(&priv->mib_sem);
 	priv->wpa = *uwrq;
-	if (priv->wpa) {
-		u32 l = DOT11_MLME_EXTENDED;
-		mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &l);
+
+	switch (priv->wpa) {
+		default:
+		case 0: /* Clears/disables WPA and friends */
+			wep = 0;
+			filter = 0; /* Do not filter un-encrypted data */
+			dot1x = 0;
+			mlme = DOT11_MLME_AUTO;
+			printk("%s: Disabling WPA\n", ndev->name);
+			break;
+		case 2: 
+		case 1: /* WPA */
+			printk("%s: Enabling WPA\n", ndev->name);
+			break;
 	}
-	/* restart the card with new level. Needed ? */
-	mgt_commit(priv);
 	up_write(&priv->mib_sem);
 
+	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &wep);
+	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &filter);
+	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
+	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlme);
+
 	return 0;
 }
 
@@ -2250,11 +2714,19 @@
 #endif /* WIRELESS_EXT == 16 */
 };
 
-/* For ioctls that don't work with the new API */
+/* For wpa_supplicant */
 
 int
 prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-
+	struct iwreq *wrq = (struct iwreq *) rq;
+	int ret = -1;
+	switch (cmd) {
+		case PRISM54_HOSTAPD:
+		if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+		ret = prism54_hostapd(ndev, &wrq->u.data);
+		return ret;
+	}
 	return -EOPNOTSUPP;
 }
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.h linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.h
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.h	2004-08-14 07:36:58.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.h	2004-09-05 10:49:05.000000000 +0200
@@ -48,6 +48,8 @@
 int prism54_set_mac_address(struct net_device *, void *);
 
 int prism54_ioctl(struct net_device *, struct ifreq *, int);
+int prism54_set_wpa(struct net_device *, struct iw_request_info *, 
+			__u32 *, char *);
 
 extern const struct iw_handler_def prism54_handler_def;
 
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_oid.h linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_oid.h
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_oid.h	2004-08-14 07:37:15.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_oid.h	2004-09-05 10:49:05.000000000 +0200
@@ -91,6 +91,14 @@
 	u16 mhz[0];
 } __attribute__ ((packed));
 
+struct obj_attachment {
+	char type;
+	char reserved;
+	short id;
+	short size;
+	char data[0];
+} __attribute__((packed));
+
 /* 
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
@@ -472,6 +480,7 @@
 #define OID_TYPE_MLMEEX		0x09
 #define OID_TYPE_ADDR		0x0A
 #define OID_TYPE_RAW		0x0B
+#define OID_TYPE_ATTACH		0x0C
 
 /* OID_TYPE_MLMEEX is special because of a variable size field when sending.
  * Not yet implemented (not used in driver anyway).
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/oid_mgt.c	2004-09-05 10:44:54.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/oid_mgt.c	2004-09-05 10:49:05.000000000 +0200
@@ -201,7 +201,8 @@
 	OID_U32(DOT11_OID_STATIMEOUT, 0x19000000),
 	OID_U32_C(DOT11_OID_MLMEAUTOLEVEL, 0x19000001),
 	OID_U32(DOT11_OID_BSSTIMEOUT, 0x19000002),
-	OID_UNKNOWN(DOT11_OID_ATTACHMENT, 0x19000003),
+	[DOT11_OID_ATTACHMENT] = {0x19000003, 0,
+		sizeof(struct obj_attachment), OID_TYPE_ATTACH},
 	OID_STRUCT_C(DOT11_OID_PSMBUFFER, 0x19000004, struct obj_buffer,
 		     OID_TYPE_BUFFER),
 
@@ -329,6 +330,12 @@
 			mlme->size = le16_to_cpu(mlme->size);
 			break;
 		}
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach = data;
+			attach->id = le16_to_cpu(attach->id);
+			attach->size = le16_to_cpu(attach->size);; 
+			break;
+	}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
@@ -392,6 +399,12 @@
 			mlme->size = cpu_to_le16(mlme->size);
 			break;
 		}
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach = data;
+			attach->id = cpu_to_le16(attach->id);
+			attach->size = cpu_to_le16(attach->size);; 
+			break;
+	}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
@@ -465,6 +478,42 @@
 	return ret;
 }
 
+/* None of these are cached */
+int
+mgt_set_varlen(islpci_private *priv, enum oid_num_t n, void *data, int extra_len)
+{
+	int ret = 0;
+	struct islpci_mgmtframe *response;
+	int response_op = PIMFOR_OP_ERROR;
+	int dlen;
+	u32 oid;
+
+	BUG_ON(OID_NUM_LAST <= n);
+
+	dlen = isl_oid[n].size;
+	oid = isl_oid[n].oid;
+
+	mgt_cpu_to_le(isl_oid[n].flags & OID_FLAG_TYPE, data);
+
+	if (islpci_get_state(priv) >= PRV_STATE_READY) {
+		ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET, oid,
+					     data, dlen + extra_len, &response);
+		if (!ret) {
+			response_op = response->header->operation;
+			islpci_mgt_release(response);
+		}
+		if (ret || response_op == PIMFOR_OP_ERROR)
+			ret = -EIO;
+	} else 
+		ret = -EIO;
+
+	/* re-set given data to what it was */
+	if (data)
+		mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE, data);
+
+	return ret;
+}
+
 int
 mgt_get_request(islpci_private *priv, enum oid_num_t n, int extra, void *data,
 		union oid_res_t *res)
@@ -673,6 +722,40 @@
 	}
 }
 
+/* The following OIDs need to be "unlatched":
+ *
+ * MEDIUMLIMIT,BEACONPERIOD,DTIMPERIOD,ATIMWINDOW,LISTENINTERVAL
+ * FREQUENCY,EXTENDEDRATES.
+ *
+ * The way to do this is to set ESSID. Note though that they may get 
+ * unlatch before though by setting another OID. */
+void
+mgt_unlatch_all(islpci_private *priv)
+{
+	u32 u;
+	int rvalue = 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return;
+
+	u = DOT11_OID_SSID;
+	rvalue = mgt_commit_list(priv, &u, 1);
+	/* Necessary if in MANUAL RUN mode? */
+#if 0
+	u = OID_INL_MODE;
+	rvalue |= mgt_commit_list(priv, &u, 1);
+
+	u = DOT11_OID_MLMEAUTOLEVEL;
+	rvalue |= mgt_commit_list(priv, &u, 1);
+
+	u = OID_INL_MODE;
+	rvalue |= mgt_commit_list(priv, &u, 1);
+#endif
+
+	if (rvalue)
+		printk(KERN_DEBUG "%s: Unlatching OIDs failed\n", priv->ndev->name);
+}
+
 /* This will tell you if you are allowed to answer a mlme(ex) request .*/
 
 int
@@ -773,6 +856,14 @@
 					mlme->state, mlme->code, mlme->size);
 		}
 		break;
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach = r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=%d\nsize=%d\n",
+					attach->id,
+					attach->size);
+		}
+		break;
 	case OID_TYPE_SSID:{
 			struct obj_ssid *ssid = r->ptr;
 			return snprintf(str, PRIV_STR_SIZE,
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/oid_mgt.h linux-2.6.9-rc1msw/drivers/net/wireless/prism54/oid_mgt.h
--- linux-2.6.9rc1/drivers/net/wireless/prism54/oid_mgt.h	2004-08-14 07:38:07.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/oid_mgt.h	2004-09-05 10:49:05.000000000 +0200
@@ -36,6 +36,8 @@
 void mgt_le_to_cpu(int, void *);
 
 int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
+int mgt_set_varlen(islpci_private *, enum oid_num_t, void *, int);
+
 
 int mgt_get_request(islpci_private *, enum oid_num_t, int, void *,
 		    union oid_res_t *);
@@ -47,6 +49,7 @@
 void mgt_get(islpci_private *, enum oid_num_t, void *);
 
 void mgt_commit(islpci_private *);
+void mgt_unlatch_all(islpci_private *);
 
 int mgt_mlme_answer(islpci_private *);
 

--Boundary-00=_9suOBTiZpSr4nE3
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_9suOBTiZpSr4nE3--
