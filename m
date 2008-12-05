From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] staging-p80211: Kill directly reference of netdev->priv
Date: Fri, 05 Dec 2008 23:14:53 +0800
Message-ID: <4939456D.8010003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64724 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754258AbYLEPPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 10:15:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this driver, netdev's private data is wlandevice_t.
And the wlandev(type of wlandevice_t) is exist before netdev be allocated.
So use netdev->ml_priv to point to the private data.

I am not sure whether I should consider the kernel version older than 2.3.38.
Because in those kernels, netdevice_t is "structure dev" instead of 
"structure net_device" and of course "dev->ml_priv" will cause compile error.
But before my patch, in function wlan_setup(), there is a ether_setup(net_device)
which already broke kernels which older than 2.3.38.

Compile test only.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/staging/wlan-ng/p80211netdev.c |   20 +++++-----
 drivers/staging/wlan-ng/p80211wext.c   |   58 ++++++++++++++++----------------
 2 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 11f84a8..2b705ea 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -244,7 +244,7 @@ static int p80211knetdev_init( netdevice_t *netdev)
 static struct net_device_stats*
 p80211knetdev_get_stats(netdevice_t *netdev)
 {
-	wlandevice_t	*wlandev = (wlandevice_t*)netdev->priv;
+	wlandevice_t	*wlandev = netdev->ml_priv;
 	DBFENTER;
 
 	/* TODO: review the MIB stats for items that correspond to
@@ -272,7 +272,7 @@ p80211knetdev_get_stats(netdevice_t *netdev)
 static int p80211knetdev_open( netdevice_t *netdev )
 {
 	int 		result = 0; /* success */
-	wlandevice_t	*wlandev = (wlandevice_t*)(netdev->priv);
+	wlandevice_t	*wlandev = netdev->ml_priv;
 
 	DBFENTER;
 
@@ -315,7 +315,7 @@ static int p80211knetdev_open( netdevice_t *netdev )
 static int p80211knetdev_stop( netdevice_t *netdev )
 {
 	int		result = 0;
-	wlandevice_t	*wlandev = (wlandevice_t*)(netdev->priv);
+	wlandevice_t	*wlandev = netdev->ml_priv;
 
 	DBFENTER;
 
@@ -460,7 +460,7 @@ static int p80211knetdev_hard_start_xmit( struct sk_buff *skb, netdevice_t *netd
 {
 	int		result = 0;
 	int		txresult = -1;
-	wlandevice_t	*wlandev = (wlandevice_t*)netdev->priv;
+	wlandevice_t	*wlandev = netdev->ml_priv;
 	p80211_hdr_t    p80211_hdr;
 	p80211_metawep_t p80211_wep;
 
@@ -603,7 +603,7 @@ static int p80211knetdev_hard_start_xmit( struct sk_buff *skb, netdevice_t *netd
 ----------------------------------------------------------------*/
 static void p80211knetdev_set_multicast_list(netdevice_t *dev)
 {
-	wlandevice_t	*wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t	*wlandev = dev->ml_priv;
 
 	DBFENTER;
 
@@ -696,7 +696,7 @@ static int p80211knetdev_do_ioctl(netdevice_t *dev, struct ifreq *ifr, int cmd)
 {
 	int			result = 0;
 	p80211ioctl_req_t	*req = (p80211ioctl_req_t*)ifr;
-	wlandevice_t		*wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t		*wlandev = dev->ml_priv;
 	UINT8			*msgbuf;
 	DBFENTER;
 
@@ -812,7 +812,7 @@ static int p80211knetdev_set_mac_address(netdevice_t *dev, void *addr)
 	dot11req.msgcode = DIDmsg_dot11req_mibset;
 	dot11req.msglen = sizeof(p80211msg_dot11req_mibset_t);
 	memcpy(dot11req.devname,
-		((wlandevice_t*)(dev->priv))->name,
+		((wlandevice_t *)dev->ml_priv)->name,
 		WLAN_DEVNAMELEN_MAX - 1);
 
 	/* Set up the mibattribute argument */
@@ -833,7 +833,7 @@ static int p80211knetdev_set_mac_address(netdevice_t *dev, void *addr)
 	resultcode->data = 0;
 
 	/* now fire the request */
-	result = p80211req_dorequest(dev->priv, (UINT8*)&dot11req);
+	result = p80211req_dorequest(dev->ml_priv, (UINT8 *)&dot11req);
 
 	/* If the request wasn't successful, report an error and don't
 	 * change the netdev address
@@ -917,7 +917,7 @@ int wlan_setup(wlandevice_t *wlandev)
 		memset( dev, 0, sizeof(netdevice_t));
 		ether_setup(dev);
 		wlandev->netdev = dev;
-		dev->priv = wlandev;
+		dev->ml_priv = wlandev;
 		dev->hard_start_xmit =	p80211knetdev_hard_start_xmit;
 		dev->get_stats =	p80211knetdev_get_stats;
 #ifdef HAVE_PRIVATE_IOCTL
@@ -1487,7 +1487,7 @@ void    p80211_resume(wlandevice_t *wlandev)
 
 static void p80211knetdev_tx_timeout( netdevice_t *netdev)
 {
-	wlandevice_t	*wlandev = (wlandevice_t*)netdev->priv;
+	wlandevice_t	*wlandev = netdev->ml_priv;
 	DBFENTER;
 
 	if (wlandev->tx_timeout) {
diff --git a/drivers/staging/wlan-ng/p80211wext.c b/drivers/staging/wlan-ng/p80211wext.c
index 906ba43..b2c9ea2 100644
--- a/drivers/staging/wlan-ng/p80211wext.c
+++ b/drivers/staging/wlan-ng/p80211wext.c
@@ -218,7 +218,7 @@ exit:
 struct iw_statistics* p80211wext_get_wireless_stats (netdevice_t *dev)
 {
 	p80211msg_lnxreq_commsquality_t  quality;
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	struct iw_statistics* wstats = &wlandev->wstats;
 	int retval;
 
@@ -301,7 +301,7 @@ static int p80211wext_giwfreq(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      struct iw_freq *freq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -339,7 +339,7 @@ static int p80211wext_siwfreq(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      struct iw_freq *freq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -380,7 +380,7 @@ static int p80211wext_giwmode(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      __u32 *mode, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 
 	DBFENTER;
 
@@ -407,7 +407,7 @@ static int p80211wext_siwmode(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      __u32 *mode, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int 	result;
@@ -550,7 +550,7 @@ static int p80211wext_giwap(netdevice_t *dev,
 			    struct sockaddr *ap_addr, char *extra)
 {
 
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 
 	DBFENTER;
 
@@ -566,7 +566,7 @@ static int p80211wext_giwencode(netdevice_t *dev,
 				struct iw_request_info *info,
 				struct iw_point *erq, char *key)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	int err = 0;
 	int i;
 
@@ -607,7 +607,7 @@ static int p80211wext_siwencode(netdevice_t *dev,
 				struct iw_request_info *info,
 				struct iw_point *erq, char *key)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211msg_dot11req_mibset_t	msg;
 	p80211item_pstr32_t		pstr;
 
@@ -736,7 +736,7 @@ static int p80211wext_giwessid(netdevice_t *dev,
 			       struct iw_request_info *info,
 			       struct iw_point *data, char *essid)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 
 	DBFENTER;
 
@@ -762,7 +762,7 @@ static int p80211wext_siwessid(netdevice_t *dev,
 			       struct iw_request_info *info,
 			       struct iw_point *data, char *essid)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211msg_lnxreq_autojoin_t     msg;
 
 	int result;
@@ -816,7 +816,7 @@ static int p80211wext_siwcommit(netdevice_t *dev,
 				struct iw_request_info *info,
 				struct iw_point *data, char *essid)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	int err = 0;
 
 	DBFENTER;
@@ -839,7 +839,7 @@ static int p80211wext_giwrate(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      struct iw_param *rrq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -893,7 +893,7 @@ static int p80211wext_giwrts(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_param *rts, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -927,7 +927,7 @@ static int p80211wext_siwrts(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_param *rts, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -964,7 +964,7 @@ static int p80211wext_giwfrag(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      struct iw_param *frag, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -997,7 +997,7 @@ static int p80211wext_siwfrag(netdevice_t *dev,
 			      struct iw_request_info *info,
 			      struct iw_param *frag, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -1047,7 +1047,7 @@ static int p80211wext_giwretry(netdevice_t *dev,
 			       struct iw_request_info *info,
 			       struct iw_param *rrq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -1126,7 +1126,7 @@ static int p80211wext_siwretry(netdevice_t *dev,
 			       struct iw_request_info *info,
 			       struct iw_param *rrq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -1198,7 +1198,7 @@ static int p80211wext_siwtxpow(netdevice_t *dev,
                                struct iw_request_info *info,
                                struct iw_param *rrq, char *extra)
 {
-        wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
         p80211item_uint32_t             mibitem;
         p80211msg_dot11req_mibset_t     msg;
         int result;
@@ -1243,7 +1243,7 @@ static int p80211wext_giwtxpow(netdevice_t *dev,
 			       struct iw_request_info *info,
 			       struct iw_param *rrq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211item_uint32_t             mibitem;
 	p80211msg_dot11req_mibset_t     msg;
 	int result;
@@ -1281,7 +1281,7 @@ static int p80211wext_siwspy(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_point *srq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
         struct sockaddr address[IW_MAX_SPY];
         int number = srq->length;
         int i;
@@ -1317,7 +1317,7 @@ static int p80211wext_giwspy(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_point *srq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 
         struct sockaddr address[IW_MAX_SPY];
         struct iw_quality spy_stat[IW_MAX_SPY];
@@ -1378,7 +1378,7 @@ static int p80211wext_siwscan(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_point *srq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211msg_dot11req_scan_t	msg;
 	int result;
 	int err = 0;
@@ -1501,7 +1501,7 @@ static int p80211wext_giwscan(netdevice_t *dev,
 			     struct iw_request_info *info,
 			     struct iw_point *srq, char *extra)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	p80211msg_dot11req_scan_results_t	msg;
 	int result = 0;
 	int err = 0;
@@ -1551,7 +1551,7 @@ static int p80211wext_set_encodeext(struct net_device *dev,
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-  wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+  wlandevice_t *wlandev = dev->ml_priv;
   struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	p80211msg_dot11req_mibset_t	msg;
 	p80211item_pstr32_t		*pstr;
@@ -1627,7 +1627,7 @@ static int p80211wext_get_encodeext(struct net_device *dev,
 				union iwreq_data *wrqu, char *extra)
 
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 
 	struct iw_point *encoding = &wrqu->encoding;
@@ -1682,7 +1682,7 @@ static int p80211_wext_set_iwauth (struct net_device *dev,
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-  wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+  wlandevice_t *wlandev = dev->ml_priv;
   struct iw_param *param = &wrqu->param;
   int result =0;
 
@@ -1734,7 +1734,7 @@ static int p80211_wext_get_iwauth (struct net_device *dev,
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-  wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+  wlandevice_t *wlandev = dev->ml_priv;
   struct iw_param *param = &wrqu->param;
   int result =0;
 
@@ -1868,7 +1868,7 @@ struct iw_handler_def p80211wext_handler_def = {
 /* wireless extensions' ioctls */
 int p80211wext_support_ioctl(netdevice_t *dev, struct ifreq *ifr, int cmd)
 {
-	wlandevice_t *wlandev = (wlandevice_t*)dev->priv;
+	wlandevice_t *wlandev = dev->ml_priv;
 
 #if WIRELESS_EXT < 13
 	struct iwreq *iwr = (struct iwreq*)ifr;
-- 
1.5.3.4






