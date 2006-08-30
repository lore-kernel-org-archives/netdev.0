From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for tiacx
Date: Tue, 29 Aug 2006 18:09:39 -0700
Message-ID: <20060830010939.GM8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:13506 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932198AbWH3BKt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:10:49 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for TI ACX driver...
	Patch for wireless-2.6 git.

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

--- linux/drivers/net/wireless/tiacx/ioctl.20.c	2006-08-29 15:38:59.000000000 -0700
+++ linux/drivers/net/wireless/tiacx/ioctl.c	2006-08-29 15:54:05.000000000 -0700
@@ -686,15 +686,15 @@ acx_ioctl_set_essid(
 		adev->essid_active = 0;
 
 	} else {
-		if (dwrq->length > IW_ESSID_MAX_SIZE+1)	{
+		if (dwrq->length > IW_ESSID_MAX_SIZE)	{
 			result = -E2BIG;
 			goto end_unlock;
 		}
 
-		if (len > sizeof(adev->essid))
-			len = sizeof(adev->essid);
-		memcpy(adev->essid, extra, len-1);
-		adev->essid[len-1] = '\0';
+		if (len >= sizeof(adev->essid))
+			len = sizeof(adev->essid) - 1;
+		memcpy(adev->essid, extra, len);
+		adev->essid[len] = '\0';
 		/* Paranoia: just in case there is a '\0'... */
 		adev->essid_len = strlen(adev->essid);
 		adev->essid_active = 1;
@@ -730,7 +730,7 @@ acx_ioctl_get_essid(
 	if (adev->essid_active)	{
 		memcpy(extra, adev->essid, adev->essid_len);
 		extra[adev->essid_len] = '\0';
-		dwrq->length = adev->essid_len + 1;
+		dwrq->length = adev->essid_len;
 		dwrq->flags = 1;
 	}
 	return OK;
@@ -1097,7 +1097,7 @@ acx_ioctl_set_power(
 				"due to %dus\n", ps_timeout, vwrq->value);
 		adev->ps_hangover_period = ps_timeout;
 	} else if ((vwrq->flags & IW_POWER_TYPE) == IW_POWER_PERIOD) {
-		u16 ps_periods = vwrq->value / 1000000;
+		u16 ps_periods = vwrq->value;
 
 		if (ps_periods > 255)
 			ps_periods = 255;
@@ -1160,7 +1160,7 @@ acx_ioctl_get_power(
 		vwrq->value = adev->ps_hangover_period * 1000 / 1024;
 		vwrq->flags = IW_POWER_TIMEOUT;
 	} else {
-		vwrq->value = adev->ps_listen_interval * 1000000;
+		vwrq->value = adev->ps_listen_interval;
 		vwrq->flags = IW_POWER_PERIOD|IW_POWER_RELATIVE;
 	}
 	if (adev->ps_options & PS_OPT_STILL_RCV_BCASTS)
@@ -1381,7 +1381,7 @@ acx_ioctl_get_nick(
 	acx_device_t *adev = ndev2adev(ndev);
 
 	strcpy(extra, adev->nick);
-	dwrq->length = strlen(extra) + 1;
+	dwrq->length = strlen(extra);
 
 	return OK;
 }
@@ -1405,13 +1405,14 @@ acx_ioctl_set_nick(
 
 	acx_sem_lock(adev);
 
-	if (dwrq->length > IW_ESSID_MAX_SIZE + 1) {
+	if (dwrq->length > IW_ESSID_MAX_SIZE) {
 		result = -E2BIG;
 		goto end_unlock;
 	}
 
-	/* extra includes trailing \0, so it's ok */
+	/* extra does not include trailing \0 in WE 21 and later */
 	strcpy(adev->nick, extra);
+	adev->nick[dwrq->length] = '\0';
 	result = OK;
 
 end_unlock:
@@ -1446,13 +1447,13 @@ acx_ioctl_get_retry(
 	if (type == IW_RETRY_LIFETIME) {
 		vwrq->flags = IW_RETRY_LIFETIME;
 		vwrq->value = adev->msdu_lifetime;
-	} else if (modifier == IW_RETRY_MAX) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	} else if (modifier == IW_RETRY_LONG) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = adev->long_retry;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		if (adev->long_retry != adev->short_retry)
-			SET_BIT(vwrq->flags, IW_RETRY_MIN);
+			SET_BIT(vwrq->flags, IW_RETRY_SHORT);
 		vwrq->value = adev->short_retry;
 	}
 
@@ -1498,9 +1499,9 @@ acx_ioctl_set_retry(
 	if (IW_RETRY_LIMIT == (vwrq->flags & IW_RETRY_TYPE)) {
 		printk("old retry limits: short %d long %d\n",
 				adev->short_retry, adev->long_retry);
-		if (vwrq->flags & IW_RETRY_MAX) {
+		if (vwrq->flags & IW_RETRY_LONG) {
 			adev->long_retry = vwrq->value;
-		} else if (vwrq->flags & IW_RETRY_MIN) {
+		} else if (vwrq->flags & IW_RETRY_SHORT) {
 			adev->short_retry = vwrq->value;
 		} else {
 			/* no modifier: set both */
