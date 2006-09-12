From: "John W. Linville" <linville@tuxdriver.com>
Subject: WE-21 patches/branch for final review
Date: Tue, 12 Sep 2006 14:09:30 -0400
Message-ID: <20060912180925.GD7703@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:53003 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030308AbWILSQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 14:16:24 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have the WE-21 patches on the 'we21' branch of wireless-2.6.
Please give them a final look before I push them for 2.6.19.

Wireless driver maintainers, please make sure that your device
is covered.

Thanks,

John

P.S.  The individual patches are also available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/we21

---

The following changes since commit 884d3a2bad7293e56fe99d9322a1090bfdfd7c4e:
  Christian Steineck:
        hostap_cs: added support for Proxim Harmony PCI W-Lan card

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git we21

Daniel Drake:
      WE-21 for zd1211rw

Jean Tourrilhes:
      WE-21 for airo
      WE-21 for atmel
      WE-21 for hostap
      WE-21 for ipw2100
      WE-21 for orinoco
      WE-21 for Prism54
      WE-21 for ray_cs
      WE-21 for wl3501
      WE-21 for zd1201
      WE-21 for ipw2200

John W. Linville:
      WE-21 support (core API)

Larry Finger:
      bcm43xx: WE-21 support

 drivers/net/wireless/airo.c                 |   19 ++++----
 drivers/net/wireless/atmel.c                |   18 ++++---
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |    2 -
 drivers/net/wireless/hostap/hostap_ioctl.c  |   10 ++--
 drivers/net/wireless/ipw2100.c              |   14 +++---
 drivers/net/wireless/ipw2200.c              |   16 +++---
 drivers/net/wireless/orinoco.c              |   10 ++--
 drivers/net/wireless/prism54/isl_ioctl.c    |   16 +++---
 drivers/net/wireless/ray_cs.c               |    2 -
 drivers/net/wireless/wl3501_cs.c            |    6 +-
 drivers/net/wireless/zd1201.c               |    2 -
 drivers/net/wireless/zd1211rw/zd_netdev.c   |    2 -
 include/linux/netdevice.h                   |    1 
 include/linux/wireless.h                    |   24 ++++++++--
 net/core/net-sysfs.c                        |    5 --
 net/core/wireless.c                         |   67 +++++++++++++++++----------
 net/ieee80211/softmac/ieee80211softmac_wx.c |    8 ++-
 17 files changed, 124 insertions(+), 98 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index e088cee..b7a343f 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5866,7 +5866,7 @@ static int airo_set_essid(struct net_dev
 		int	index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE+1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG ;
 		}
 		/* Check if index is valid */
@@ -5878,7 +5878,7 @@ static int airo_set_essid(struct net_dev
 		memset(SSID_rid.ssids[index].ssid, 0,
 		       sizeof(SSID_rid.ssids[index].ssid));
 		memcpy(SSID_rid.ssids[index].ssid, extra, dwrq->length);
-		SSID_rid.ssids[index].len = dwrq->length - 1;
+		SSID_rid.ssids[index].len = dwrq->length;
 	}
 	SSID_rid.len = sizeof(SSID_rid);
 	/* Write it to the card */
@@ -5988,7 +5988,7 @@ static int airo_set_nick(struct net_devi
 	struct airo_info *local = dev->priv;
 
 	/* Check the size of the string */
-	if(dwrq->length > 16 + 1) {
+	if(dwrq->length > 16) {
 		return -E2BIG;
 	}
 	readConfigRid(local, 1);
@@ -6013,7 +6013,7 @@ static int airo_get_nick(struct net_devi
 	readConfigRid(local, 1);
 	strncpy(extra, local->config.nodeName, 16);
 	extra[16] = '\0';
-	dwrq->length = strlen(extra) + 1;
+	dwrq->length = strlen(extra);
 
 	return 0;
 }
@@ -6765,9 +6765,9 @@ static int airo_set_retry(struct net_dev
 	}
 	readConfigRid(local, 1);
 	if(vwrq->flags & IW_RETRY_LIMIT) {
-		if(vwrq->flags & IW_RETRY_MAX)
+		if(vwrq->flags & IW_RETRY_LONG)
 			local->config.longRetryLimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			local->config.shortRetryLimit = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -6803,14 +6803,14 @@ static int airo_get_retry(struct net_dev
 	if((vwrq->flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME) {
 		vwrq->flags = IW_RETRY_LIFETIME;
 		vwrq->value = (int)local->config.txLifetime * 1024;
-	} else if((vwrq->flags & IW_RETRY_MAX)) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	} else if((vwrq->flags & IW_RETRY_LONG)) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = (int)local->config.longRetryLimit;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = (int)local->config.shortRetryLimit;
 		if((int)local->config.shortRetryLimit != (int)local->config.longRetryLimit)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
@@ -6988,6 +6988,7 @@ static int airo_set_power(struct net_dev
 			local->config.rmode |= RXMODE_BC_MC_ADDR;
 			set_bit (FLAG_COMMIT, &local->flags);
 		case IW_POWER_ON:
+			/* This is broken, fixme ;-) */
 			break;
 		default:
 			return -EINVAL;
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 995c7be..0fc267d 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1656,13 +1656,13 @@ static int atmel_set_essid(struct net_de
 		priv->connect_to_any_BSS = 0;
 
 		/* Check the size of the string */
-		if (dwrq->length > MAX_SSID_LENGTH + 1)
+		if (dwrq->length > MAX_SSID_LENGTH)
 			 return -E2BIG;
 		if (index != 0)
 			return -EINVAL;
 
-		memcpy(priv->new_SSID, extra, dwrq->length - 1);
-		priv->new_SSID_size = dwrq->length - 1;
+		memcpy(priv->new_SSID, extra, dwrq->length);
+		priv->new_SSID_size = dwrq->length;
 	}
 
 	return -EINPROGRESS;
@@ -2120,9 +2120,9 @@ static int atmel_set_retry(struct net_de
 	struct atmel_private *priv = netdev_priv(dev);
 
 	if (!vwrq->disabled && (vwrq->flags & IW_RETRY_LIMIT)) {
-		if (vwrq->flags & IW_RETRY_MAX)
+		if (vwrq->flags & IW_RETRY_LONG)
 			priv->long_retry = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			priv->short_retry = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -2144,15 +2144,15 @@ static int atmel_get_retry(struct net_de
 
 	vwrq->disabled = 0;      /* Can't be disabled */
 
-	/* Note : by default, display the min retry number */
-	if (vwrq->flags & IW_RETRY_MAX) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	/* Note : by default, display the short retry number */
+	if (vwrq->flags & IW_RETRY_LONG) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = priv->long_retry;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = priv->short_retry;
 		if (priv->long_retry != priv->short_retry)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 888077f..9b7b15c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -334,7 +334,7 @@ static int bcm43xx_wx_get_nick(struct ne
 	size_t len;
 
 	mutex_lock(&bcm->mutex);
-	len = strlen(bcm->nick) + 1;
+	len = strlen(bcm->nick);
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8399de5..6f1756e 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1412,9 +1412,9 @@ #if 0
 	/* what could be done, if firmware would support this.. */
 
 	if (rrq->flags & IW_RETRY_LIMIT) {
-		if (rrq->flags & IW_RETRY_MAX)
+		if (rrq->flags & IW_RETRY_LONG)
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
-		else if (rrq->flags & IW_RETRY_MIN)
+		else if (rrq->flags & IW_RETRY_SHORT)
 			HFA384X_RID_SHORTRETRYLIMIT = rrq->value;
 		else {
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
@@ -1468,14 +1468,14 @@ static int prism2_ioctl_giwretry(struct 
 				rrq->value = le16_to_cpu(altretry);
 			else
 				rrq->value = local->manual_retry_count;
-		} else if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		} else if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = longretry;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = shortretry;
 			if (shortretry != longretry)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 	return 0;
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 5d5dab6..3642cf8 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6958,7 +6958,7 @@ static int ipw2100_wx_set_essid(struct n
 	}
 
 	if (wrqu->essid.flags && wrqu->essid.length) {
-		length = wrqu->essid.length - 1;
+		length = wrqu->essid.length;
 		essid = extra;
 	}
 
@@ -7051,7 +7051,7 @@ static int ipw2100_wx_get_nick(struct ne
 
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 
@@ -7343,14 +7343,14 @@ static int ipw2100_wx_set_retry(struct n
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MIN) {
+	if (wrqu->retry.flags & IW_RETRY_SHORT) {
 		err = ipw2100_set_short_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Short Retry Limit -> %d \n",
 			     wrqu->retry.value);
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
 		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Long Retry Limit -> %d \n",
 			     wrqu->retry.value);
@@ -7383,14 +7383,14 @@ static int ipw2100_wx_get_retry(struct n
 	if ((wrqu->retry.flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME)
 		return -EINVAL;
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
 	} else {
 		wrqu->retry.flags =
 		    (priv->short_retry_limit !=
 		     priv->long_retry_limit) ?
-		    IW_RETRY_LIMIT | IW_RETRY_MIN : IW_RETRY_LIMIT;
+		    IW_RETRY_LIMIT | IW_RETRY_SHORT : IW_RETRY_LIMIT;
 
 		wrqu->retry.value = priv->short_retry_limit;
 	}
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index fa245f1..bf14ec7 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8875,8 +8875,6 @@ static int ipw_wx_set_essid(struct net_d
         }
 
 	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
-	if (!extra[length - 1])
-		length--;
 
 	priv->config |= CFG_STATIC_ESSID;
 
@@ -8953,7 +8951,7 @@ static int ipw_wx_get_nick(struct net_de
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	IPW_DEBUG_WX("Getting nick\n");
 	mutex_lock(&priv->mutex);
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 	mutex_unlock(&priv->mutex);
@@ -9276,9 +9274,9 @@ static int ipw_wx_set_retry(struct net_d
 		return -EINVAL;
 
 	mutex_lock(&priv->mutex);
-	if (wrqu->retry.flags & IW_RETRY_MIN)
+	if (wrqu->retry.flags & IW_RETRY_SHORT)
 		priv->short_retry_limit = (u8) wrqu->retry.value;
-	else if (wrqu->retry.flags & IW_RETRY_MAX)
+	else if (wrqu->retry.flags & IW_RETRY_LONG)
 		priv->long_retry_limit = (u8) wrqu->retry.value;
 	else {
 		priv->short_retry_limit = (u8) wrqu->retry.value;
@@ -9307,11 +9305,11 @@ static int ipw_wx_get_retry(struct net_d
 		return -EINVAL;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
-	} else if (wrqu->retry.flags & IW_RETRY_MIN) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	} else if (wrqu->retry.flags & IW_RETRY_SHORT) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 		wrqu->retry.value = priv->short_retry_limit;
 	} else {
 		wrqu->retry.flags = IW_RETRY_LIMIT;
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 1174ff5..b5afb56 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -3037,7 +3037,7 @@ static int orinoco_ioctl_getessid(struct
 	}
 
 	erq->flags = 1;
-	erq->length = strlen(essidbuf) + 1;
+	erq->length = strlen(essidbuf);
 
 	return 0;
 }
@@ -3078,7 +3078,7 @@ static int orinoco_ioctl_getnick(struct 
 	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
 	orinoco_unlock(priv, &flags);
 
-	nrq->length = strlen(nickbuf)+1;
+	nrq->length = strlen(nickbuf);
 
 	return 0;
 }
@@ -3575,14 +3575,14 @@ static int orinoco_ioctl_getretry(struct
 		rrq->value = lifetime * 1000;	/* ??? */
 	} else {
 		/* By default, display the min number */
-		if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = long_limit;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = short_limit;
 			if(short_limit != long_limit)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index c09fbf7..286325c 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -742,9 +742,9 @@ prism54_set_essid(struct net_device *nde
 
 	/* Check if we were asked for `any' */
 	if (dwrq->flags && dwrq->length) {
-		if (dwrq->length > min(33, IW_ESSID_MAX_SIZE + 1))
+		if (dwrq->length > 32)
 			return -E2BIG;
-		essid.length = dwrq->length - 1;
+		essid.length = dwrq->length;
 		memcpy(essid.octets, extra, dwrq->length);
 	} else
 		essid.length = 0;
@@ -814,7 +814,7 @@ prism54_get_nick(struct net_device *ndev
 	dwrq->length = 0;
 
 	down_read(&priv->mib_sem);
-	dwrq->length = strlen(priv->nickname) + 1;
+	dwrq->length = strlen(priv->nickname);
 	memcpy(extra, priv->nickname, dwrq->length);
 	up_read(&priv->mib_sem);
 
@@ -992,9 +992,9 @@ prism54_set_retry(struct net_device *nde
 		return -EINVAL;
 
 	if (vwrq->flags & IW_RETRY_LIMIT) {
-		if (vwrq->flags & IW_RETRY_MIN)
+		if (vwrq->flags & IW_RETRY_SHORT)
 			slimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MAX)
+		else if (vwrq->flags & IW_RETRY_LONG)
 			llimit = vwrq->value;
 		else {
 			/* we are asked to set both */
@@ -1035,18 +1035,18 @@ prism54_get_retry(struct net_device *nde
 		    mgt_get_request(priv, DOT11_OID_MAXTXLIFETIME, 0, NULL, &r);
 		vwrq->value = r.u * 1024;
 		vwrq->flags = IW_RETRY_LIFETIME;
-	} else if ((vwrq->flags & IW_RETRY_MAX)) {
+	} else if ((vwrq->flags & IW_RETRY_LONG)) {
 		/* we are asked for the long retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_LONGRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 	} else {
 		/* default. get the  short retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_SHORTRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 	}
 
 	return rvalue;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 8e112d1..b8480c9 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1173,7 +1173,7 @@ static int ray_set_essid(struct net_devi
 		return -EOPNOTSUPP;
 	} else {
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE + 1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG;
 		}
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index c03e400..2d516d6 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1802,15 +1802,15 @@ static int wl3501_get_retry(struct net_d
 				      &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		goto set_value;
 	}
 	rc = wl3501_get_mib_value(this, WL3501_MIB_ATTR_SHORT_RETRY_LIMIT,
 				  &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 set_value:
 	wrqu->retry.value = retry;
 	wrqu->retry.disabled = 0;
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index c52e9bc..a44dda9 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1218,7 +1218,7 @@ static int zd1201_set_essid(struct net_d
 		return -EINVAL;
 	if (data->length < 1)
 		data->length = 1;
-	zd->essidlen = data->length-1;
+	zd->essidlen = data->length;
 	memset(zd->essid, 0, IW_ESSID_MAX_SIZE+1);
 	memcpy(zd->essid, essid, data->length);
 	return zd1201_join(zd, zd->essid, zd->essidlen);
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 440ef24..af3a7b3 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -82,7 +82,7 @@ static int iw_get_nick(struct net_device
 		       union iwreq_data *req, char *extra)
 {
 	strcpy(extra, "zd1211");
-	req->data.length = strlen(extra) + 1;
+	req->data.length = strlen(extra);
 	req->data.flags = 1;
 	return 0;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 50a4719..91dc36c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -334,7 +334,6 @@ #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSU
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
 
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 1358856..a50a013 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	20	17.2.06
+ * Version :	21	14.3.06
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
  * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
@@ -69,9 +69,14 @@ #define _LINUX_WIRELESS_H
 
 /***************************** INCLUDES *****************************/
 
+/* This header is used in user-space, therefore need to be sanitised
+ * for that purpose. Those includes are usually not compatible with glibc.
+ * To know which includes to use in user-space, check iwlib.h. */
+#ifdef __KERNEL__
 #include <linux/types.h>		/* for "caddr_t" et al		*/
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/if.h>			/* for IFNAMSIZ and co... */
+#endif	/* __KERNEL__ */
 
 /***************************** VERSION *****************************/
 /*
@@ -80,7 +85,7 @@ #include <linux/if.h>			/* for IFNAMSIZ 
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	20
+#define WIRELESS_EXT	21
 
 /*
  * Changes :
@@ -208,6 +213,14 @@ #define WIRELESS_EXT	20
  * V19 to V20
  * ----------
  *	- RtNetlink requests support (SET/GET)
+ *
+ * V20 to V21
+ * ----------
+ *	- Remove (struct net_device *)->get_wireless_stats()
+ *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
+ *	- Power/Retry relative values no longer * 100000
+ *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
  */
 
 /**************************** CONSTANTS ****************************/
@@ -448,6 +461,7 @@ #define IW_QUAL_DBM		0x08	/* Level + Noi
 #define IW_QUAL_QUAL_INVALID	0x10	/* Driver doesn't provide value */
 #define IW_QUAL_LEVEL_INVALID	0x20
 #define IW_QUAL_NOISE_INVALID	0x40
+#define IW_QUAL_RCPI		0x80	/* Level + Noise are 802.11k RCPI */
 #define IW_QUAL_ALL_INVALID	0x70
 
 /* Frequency flags */
@@ -500,10 +514,12 @@ #define IW_RETRY_ON		0x0000	/* No detail
 #define IW_RETRY_TYPE		0xF000	/* Type of parameter */
 #define IW_RETRY_LIMIT		0x1000	/* Maximum number of retries*/
 #define IW_RETRY_LIFETIME	0x2000	/* Maximum duration of retries in us */
-#define IW_RETRY_MODIFIER	0x000F	/* Modify a parameter */
+#define IW_RETRY_MODIFIER	0x00FF	/* Modify a parameter */
 #define IW_RETRY_MIN		0x0001	/* Value is a minimum  */
 #define IW_RETRY_MAX		0x0002	/* Value is a maximum */
 #define IW_RETRY_RELATIVE	0x0004	/* Value is not in seconds/ms/us */
+#define IW_RETRY_SHORT		0x0010	/* Value is for short packets  */
+#define IW_RETRY_LONG		0x0020	/* Value is for long packets */
 
 /* Scanning request flags */
 #define IW_SCAN_DEFAULT		0x0000	/* Default scan of the driver */
@@ -1017,7 +1033,7 @@ struct	iw_range
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
 
-	__u32		enc_capa; /* IW_ENC_CAPA_* bit field */
+	__u32		enc_capa;	/* IW_ENC_CAPA_* bit field */
 };
 
 /*
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1347276..f47f319 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -344,8 +344,6 @@ static ssize_t wireless_show(struct clas
 		if(dev->wireless_handlers &&
 		   dev->wireless_handlers->get_wireless_stats)
 			iw = dev->wireless_handlers->get_wireless_stats(dev);
-		else if (dev->get_wireless_stats)
-			iw = dev->get_wireless_stats(dev);
 		if (iw != NULL)
 			ret = (*format)(iw, buf);
 	}
@@ -465,8 +463,7 @@ int netdev_register_sysfs(struct net_dev
 		*groups++ = &netstat_group;
 
 #ifdef WIRELESS_EXT
-	if (net->get_wireless_stats
-	    || (net->wireless_handlers && net->wireless_handlers->get_wireless_stats))
+	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
 
diff --git a/net/core/wireless.c b/net/core/wireless.c
index de0bde4..61457d8 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -68,6 +68,14 @@
  *
  * v8 - 17.02.06 - Jean II
  *	o RtNetlink requests support (SET/GET)
+ *
+ * v8b - 03.08.06 - Herbert Xu
+ *	o Fix Wireless Event locking issues.
+ *
+ * v9 - 14.3.06 - Jean II
+ *	o Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	o Make standard_ioctl_num and standard_event_num unsigned
+ *	o Remove (struct net_device *)->get_wireless_stats()
  */
 
 /***************************** INCLUDES *****************************/
@@ -234,24 +242,24 @@ static const struct iw_ioctl_description
 	[SIOCSIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
 	[SIOCGIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
 	[SIOCSIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCGIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCSIWRATE	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
@@ -338,8 +346,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const int standard_ioctl_num = (sizeof(standard_ioctl) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_ioctl_num = (sizeof(standard_ioctl) /
+					    sizeof(struct iw_ioctl_description));
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -389,8 +397,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const int standard_event_num = (sizeof(standard_event) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_event_num = (sizeof(standard_event) /
+					    sizeof(struct iw_ioctl_description));
 
 /* Size (in bytes) of the various private data types */
 static const char iw_priv_type_size[] = {
@@ -465,17 +473,6 @@ static inline struct iw_statistics *get_
 	   (dev->wireless_handlers->get_wireless_stats != NULL))
 		return dev->wireless_handlers->get_wireless_stats(dev);
 
-	/* Old location, field to be removed in next WE */
-	if(dev->get_wireless_stats) {
-		static int printed_message;
-
-		if (!printed_message++)
-			printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
-				dev->name);
-
-		return dev->get_wireless_stats(dev);
-	}
-
 	/* Not found */
 	return (struct iw_statistics *) NULL;
 }
@@ -1843,8 +1840,33 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
  */
 
 #ifdef WE_EVENT_RTNETLINK
+/* ---------------------------------------------------------------- */
+/*
+ * Locking...
+ * ----------
+ *
+ * Thanks to Herbert Xu <herbert@gondor.apana.org.au> for fixing
+ * the locking issue in here and implementing this code !
+ *
+ * The issue : wireless_send_event() is often called in interrupt context,
+ * while the Netlink layer can never be called in interrupt context.
+ * The fully formed RtNetlink events are queued, and then a tasklet is run
+ * to feed those to Netlink.
+ * The skb_queue is interrupt safe, and its lock is not held while calling
+ * Netlink, so there is no possibility of dealock.
+ * Jean II
+ */
+
 static struct sk_buff_head wireless_nlevent_queue;
 
+static int __init wireless_nlevent_init(void)
+{
+	skb_queue_head_init(&wireless_nlevent_queue);
+	return 0;
+}
+
+subsys_initcall(wireless_nlevent_init);
+
 static void wireless_nlevent_process(unsigned long data)
 {
 	struct sk_buff *skb;
@@ -1921,13 +1943,6 @@ static inline void rtmsg_iwinfo(struct n
 	tasklet_schedule(&wireless_nlevent_tasklet);
 }
 
-static int __init wireless_nlevent_init(void)
-{
-	skb_queue_head_init(&wireless_nlevent_queue);
-	return 0;
-}
-
-subsys_initcall(wireless_nlevent_init);
 #endif	/* WE_EVENT_RTNETLINK */
 
 /* ---------------------------------------------------------------- */
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 75320b6..2aa779d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -80,10 +80,10 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
 	if((sm->associnfo.associating || sm->associated) &&
-	   (data->essid.flags && data->essid.length && extra)) {
+	   (data->essid.flags && data->essid.length)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == (data->essid.length - 1) &&
+		if(n && n->essid.len == data->essid.length &&
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
@@ -109,8 +109,8 @@ ieee80211softmac_wx_set_essid(struct net
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
-	if (data->essid.flags && data->essid.length && extra /*required?*/) {
-		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
+	if (data->essid.flags && data->essid.length) {
+		length = min((int)data->essid.length, IW_ESSID_MAX_SIZE);
 		if (length) {
 			memcpy(sm->associnfo.req_essid.data, extra, length);
 			sm->associnfo.static_essid = 1;
-- 
John W. Linville
linville@tuxdriver.com
