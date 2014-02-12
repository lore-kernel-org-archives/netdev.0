From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix more Smatch warnings and errors
Date: Wed, 12 Feb 2014 16:14:35 -0600
Message-ID: <1392243275-23697-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

After updating Smatch, the following new errors and warnings are reported:

drivers/staging/rtl8188eu/core/rtw_recv.c:368 recvframe_chkmic() warn: variable dereferenced before check 'psecuritypriv' (see line 364)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:2642 rtw_wps_start() warn: variable dereferenced before check 'pdata' (see line 2636)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:4461 rtw_dbg_port() error: we previously assumed 'pregpriv' could be null (see line 4453)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:4473 rtw_dbg_port() error: we previously assumed 'pregpriv' could be null (see line 4469)

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c      |  7 +++----
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c | 18 +++++++++---------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 35397bd..bc5baf2 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -361,16 +361,15 @@ static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvfra
 		/* calculate mic code */
 		if (stainfo != NULL) {
 			if (IS_MCAST(prxattrib->ra)) {
-				mickey = &psecuritypriv->dot118021XGrprxmickey[prxattrib->key_index].skey[0];
-
-				RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("\n recvframe_chkmic: bcmc key\n"));
-
 				if (!psecuritypriv) {
 					res = _FAIL;
 					RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n recvframe_chkmic:didn't install group key!!!!!!!!!!\n"));
 					DBG_88E("\n recvframe_chkmic:didn't install group key!!!!!!!!!!\n");
 					goto exit;
 				}
+				mickey = &psecuritypriv->dot118021XGrprxmickey[prxattrib->key_index].skey[0];
+
+				RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("\n recvframe_chkmic: bcmc key\n"));
 			} else {
 				mickey = &stainfo->dot11tkiprxmickey.skey[0];
 				RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n recvframe_chkmic: unicast key\n"));
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 7de8139..3691007 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -2633,13 +2633,13 @@ static int rtw_wps_start(struct net_device *dev,
 	struct iw_point *pdata = &wrqu->data;
 	u32   u32wps_start = 0;
 
-	ret = copy_from_user((void *)&u32wps_start, pdata->pointer, 4);
-	if (ret) {
+	if ((padapter->bDriverStopped) || (pdata == NULL)) {
 		ret = -EINVAL;
 		goto exit;
 	}
 
-	if ((padapter->bDriverStopped) || (pdata == NULL)) {
+	ret = copy_from_user((void *)&u32wps_start, pdata->pointer, 4);
+	if (ret) {
 		ret = -EINVAL;
 		goto exit;
 	}
@@ -4450,11 +4450,9 @@ static int rtw_dbg_port(struct net_device *dev,
 			struct registry_priv	*pregpriv = &padapter->registrypriv;
 			/*  0: disable, bit(0):enable 2.4g, bit(1):enable 5g, 0x3: enable both 2.4g and 5g */
 			/* default is set to enable 2.4GHZ for IOT issue with bufflao's AP at 5GHZ */
-			if (pregpriv &&
-			    (extra_arg == 0 ||
-			     extra_arg == 1 ||
-			     extra_arg == 2 ||
-			     extra_arg == 3)) {
+			if (!pregpriv)
+				break;
+			if (extra_arg >= 0 && extra_arg <= 3) {
 				pregpriv->rx_stbc = extra_arg;
 				DBG_88E("set rx_stbc =%d\n", pregpriv->rx_stbc);
 			} else {
@@ -4466,7 +4464,9 @@ static int rtw_dbg_port(struct net_device *dev,
 		{
 			struct registry_priv	*pregpriv = &padapter->registrypriv;
 			/*  0: disable, 0x1:enable (but wifi_spec should be 0), 0x2: force enable (don't care wifi_spec) */
-			if (pregpriv && extra_arg >= 0 && extra_arg < 3) {
+			if (!pregpriv)
+				break;
+			if (extra_arg >= 0 && extra_arg < 3) {
 				pregpriv->ampdu_enable = extra_arg;
 				DBG_88E("set ampdu_enable =%d\n", pregpriv->ampdu_enable);
 			} else {
-- 
1.8.4.5
