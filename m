From: Jiri Benc <jbenc@suse.cz>
Subject: hostapd patch for d80211
Date: Fri, 23 Jun 2006 20:19:33 +0200
Message-ID: <20060623201933.59578ecc@griffin.suse.cz>
References: <200606191107.34602.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"Alexander Tsvyashchenko" <lists@ndl.kiev.ua>,
	"Francois Barre" <francois.barre@gmail.com>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37805 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751875AbWFWSTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 14:19:35 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606191107.34602.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006 11:07:34 +0200, Michael Buesch wrote:
> Important notes from Alexander Tsvyashchenko's initial mail follow:
> [...]
> Although my previous patch to hostapd to make it interoperable with
> bcm43xx & dscape has been merged already in their CVS version, due to
> the subsequent changes in dscape stack current hostapd is again
> incompartible :-(

This patch allows devicescape driver in hostapd to work with recent d80211.
No manipulation with network interfaces is needed anymore - hostapd even
switches the interface to AP mode automatically now. Just modprobe
bcm43xx-d80211, run hostapd and enjoy :-)

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 driver_devicescape.c |   77 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 64 insertions(+), 13 deletions(-)

--- hostapd-0.5-2006-06-19.orig/driver_devicescape.c
+++ hostapd-0.5-2006-06-19/driver_devicescape.c
@@ -73,6 +73,7 @@ struct i802_driver_data {
 
 	char iface[IFNAMSIZ + 1];
 	char mgmt_iface[IFNAMSIZ + 1];
+	int mgmt_ifindex;
 	int sock; /* raw packet socket for driver access */
 	int ioctl_sock; /* socket for ioctl() use */
 	int wext_sock; /* socket for wireless events */
@@ -88,6 +89,21 @@ static const struct driver_ops devicesca
 static int i802_sta_set_flags(void *priv, const u8 *addr,
 			      int flags_or, int flags_and);
 
+static int i802_set_ap_mode(struct i802_driver_data *drv)
+{
+	struct iwreq iwr;
+
+	memset(&iwr, 0, sizeof(iwr));
+	strncpy(iwr.ifr_name, drv->iface, IFNAMSIZ);
+	iwr.u.mode = IW_MODE_MASTER;
+
+	if (ioctl(drv->ioctl_sock, SIOCSIWMODE, &iwr) < 0) {
+		perror("ioctl[SIOCSIWMODE]");
+		return -1;
+	}
+
+	return 0;
+}
 
 static int hostapd_set_iface_flags(struct i802_driver_data *drv, int dev_up)
 {
@@ -96,13 +112,16 @@ static int hostapd_set_iface_flags(struc
 	if (drv->ioctl_sock < 0)
 		return -1;
 
+	if (dev_up)
+		i802_set_ap_mode(drv);
+
 	memset(&ifr, 0, sizeof(ifr));
-	snprintf(ifr.ifr_name, IFNAMSIZ, "%s", drv->mgmt_iface);
+	snprintf(ifr.ifr_name, IFNAMSIZ, "%s", drv->iface);
 
 	if (ioctl(drv->ioctl_sock, SIOCGIFFLAGS, &ifr) != 0) {
 		perror("ioctl[SIOCGIFFLAGS]");
 		wpa_printf(MSG_DEBUG, "Could not read interface flags (%s)",
-			   drv->mgmt_iface);
+			   drv->iface);
 		return -1;
 	}
 
@@ -303,7 +322,35 @@ static int hostap_ioctl_prism2param(stru
 	return hostap_ioctl_prism2param_iface(drv->iface, drv, param, value);
 }
 
- 
+static int hostap_ioctl_get_prism2param_iface(const char *iface,
+					      struct i802_driver_data *drv,
+					      int param)
+{
+	struct iwreq iwr;
+	int *i;
+
+	memset(&iwr, 0, sizeof(iwr));
+	strncpy(iwr.ifr_name, iface, IFNAMSIZ);
+	i = (int *) iwr.u.name;
+	*i = param;
+
+	if (ioctl(drv->ioctl_sock, PRISM2_IOCTL_GET_PRISM2_PARAM, &iwr) < 0) {
+		char buf[128];
+		snprintf(buf, sizeof(buf),
+			 "%s: ioctl[PRISM2_IOCTL_GET_PRISM2_PARAM]", iface);
+		perror(buf);
+		return -1;
+	}
+
+	return *i;
+}
+
+static int hostap_ioctl_get_prism2param(struct i802_driver_data *drv,
+					int param)
+{
+	return hostap_ioctl_get_prism2param_iface(drv->iface, drv, param);
+}
+
 static int i802_set_ssid(void *priv, const u8 *buf, int len)
 {
 	struct i802_driver_data *drv = priv;
@@ -1338,12 +1385,20 @@ static int i802_init_sockets(struct i802
 		return -1;
 	}
 
+	/* Enable management interface */
+	if (hostap_ioctl_prism2param(drv, PRISM2_PARAM_MGMT_IF, 1) < 0)
+		return -1;
+	drv->mgmt_ifindex =
+		hostap_ioctl_get_prism2param(drv, PRISM2_PARAM_MGMT_IF);
+	if (drv->mgmt_ifindex < 0)
+		return -1;
         memset(&ifr, 0, sizeof(ifr));
-        snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "%s", drv->mgmt_iface);
-        if (ioctl(drv->ioctl_sock, SIOCGIFINDEX, &ifr) != 0) {
-		perror("ioctl(SIOCGIFINDEX)");
+	ifr.ifr_ifindex = drv->mgmt_ifindex;
+	if (ioctl(drv->ioctl_sock, SIOCGIFNAME, &ifr) != 0) {
+		perror("ioctl(SIOCGIFNAME)");
 		return -1;
         }
+	snprintf(drv->mgmt_iface, sizeof(drv->mgmt_iface), "%s", ifr.ifr_name);
 
 	if (hostapd_set_iface_flags(drv, 1))
 		return -1;
@@ -1716,13 +1771,6 @@ static int i802_init(struct hostapd_data
 	drv->ops = devicescape_driver_ops;
 	drv->hapd = hapd;
 	memcpy(drv->iface, hapd->conf->iface, sizeof(drv->iface));
-	if (strncmp(hapd->conf->iface, "wlan", 4) == 0) {
-		snprintf(drv->mgmt_iface, sizeof(drv->mgmt_iface),
-			 "wmaster%sap", hapd->conf->iface + 4);
-	} else {
-		snprintf(drv->mgmt_iface, sizeof(drv->mgmt_iface),
-			 "%sap", hapd->conf->iface);
-	}
 
 	if (i802_init_sockets(drv))
 		goto failed;
@@ -1751,6 +1799,9 @@ static void i802_deinit(void *priv)
 
 	(void) hostapd_set_iface_flags(drv, 0);
 
+	/* Disable management interface */
+	hostap_ioctl_prism2param(drv, PRISM2_PARAM_MGMT_IF, 0);
+
 	if (drv->sock >= 0)
 		close(drv->sock);
 	if (drv->ioctl_sock >= 0)


-- 
Jiri Benc
SUSE Labs
