From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 for ipw2200
Date: Tue, 12 Sep 2006 14:33:23 -0700
Message-ID: <20060912213323.GA4156@bougret.hpl.hp.com>
References: <20060830010140.GF8405@bougret.hpl.hp.com> <20060912180253.GC7703@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: netdev@vger.kernel.org,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:16856 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751429AbWILVdt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 17:33:49 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060912180253.GC7703@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 12, 2006 at 02:02:59PM -0400, John W. Linville wrote:
> On Tue, Aug 29, 2006 at 06:01:40PM -0700, Jean Tourrilhes wrote:
> 
> This hunk doesn't apply to the upstream branch of wireless-2.6.
> I propose this one instead:
> 
> @@ -8875,8 +8875,6 @@ static int ipw_wx_set_essid(struct net_d
>          }
>  
>  	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
> -	if (!extra[length - 1])
> -		length--;
>  
>  	priv->config |= CFG_STATIC_ESSID;
>  
> Everything else stays the same...OK?

	Double checked, that seems to be allright.

> John

	James & Zhu : the patch for the out-of-tree driver is
attached, diffed against the driver in GIT. It should work for both
pre-WE21 and post-WE-21.
	Have fun...

	Jean

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="iw268e_we21-ipw2200-2.diff"

diff -u -p linux/drivers/net/wireless/ipw2200.20.c linux/drivers/net/wireless/ipw2200.c
--- linux/drivers/net/wireless/ipw2200.20.c	2006-09-12 14:24:09.000000000 -0700
+++ linux/drivers/net/wireless/ipw2200.c	2006-09-12 14:29:09.000000000 -0700
@@ -8855,6 +8855,14 @@ static int ipw_wx_get_wap(struct net_dev
 	return 0;
 }
 
+#if WIRELESS_EXT > 20
+#define IW_ESSID_FIX	0
+#else
+#define IW_ESSID_FIX	1
+#define IW_RETRY_LONG IW_RETRY_MAX
+#define IW_RETRY_SHORT IW_RETRY_MIN
+#endif
+
 static int ipw_wx_set_essid(struct net_device *dev,
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
@@ -8874,9 +8882,8 @@ static int ipw_wx_set_essid(struct net_d
                 return 0;
         }
 
-	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
-	if (!extra[length - 1])
-		length--;
+	length = min((int) (wrqu->essid.length - IW_ESSID_FIX),
+		     IW_ESSID_MAX_SIZE);
 
 	priv->config |= CFG_STATIC_ESSID;
 
@@ -8916,7 +8923,7 @@ static int ipw_wx_get_essid(struct net_d
 		IPW_DEBUG_WX("Getting essid: '%s'\n",
 			     escape_essid(priv->essid, priv->essid_len));
 		memcpy(extra, priv->essid, priv->essid_len);
-		wrqu->essid.length = priv->essid_len;
+		wrqu->essid.length = priv->essid_len + IW_ESSID_FIX;
 		wrqu->essid.flags = 1;	/* active */
 	} else {
 		IPW_DEBUG_WX("Getting essid: ANY\n");
@@ -8953,7 +8960,7 @@ static int ipw_wx_get_nick(struct net_de
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	IPW_DEBUG_WX("Getting nick\n");
 	mutex_lock(&priv->mutex);
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick) + IW_ESSID_FIX;
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 	mutex_unlock(&priv->mutex);
@@ -9276,9 +9283,9 @@ static int ipw_wx_set_retry(struct net_d
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
@@ -9307,11 +9314,11 @@ static int ipw_wx_get_retry(struct net_d
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

--3MwIy2ne0vdjdPXF--
