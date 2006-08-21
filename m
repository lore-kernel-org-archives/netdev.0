From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 04/14] ipw2200: Reassociate even if set the same essid.
Date: Mon, 21 Aug 2006 11:37:26 +0800
Message-ID: <20060821033726.GA5353@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9276 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932582AbWHUDjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:39:21 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch traps the case when the essid is being set to its
current value. If the essid is being set again and we are already
associated, chances are some other parameters have also been altered.
I think it is safer to do the re-association for this case.

Signed-off-by: Bill Moss <bmoss@clemson.edu>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

17e85d1ad3dd9c8dc48d63dcc6cd531b3b8fb685
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 27e87d1..e929f88 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8837,7 +8837,6 @@ static int ipw_wx_set_essid(struct net_d
 			    union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-        char *essid;
         int length;
 
         mutex_lock(&priv->mutex);
@@ -8852,12 +8851,14 @@ static int ipw_wx_set_essid(struct net_d
                 return 0;
         }
 
-	length = min(wrqu->essid.length, IW_ESSID_MAX_SIZE);
-	essid = extra;
+	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
+	if (!extra[length - 1])
+		length--;
 
 	priv->config |= CFG_STATIC_ESSID;
 
-	if (priv->essid_len == length && !memcmp(priv->essid, extra, length)) {
+	if (priv->essid_len == length && !memcmp(priv->essid, extra, length)
+	    && (priv->status & (STATUS_ASSOCIATED | STATUS_ASSOCIATING))) {
 		IPW_DEBUG_WX("ESSID set to current ESSID.\n");
 		mutex_unlock(&priv->mutex);
 		return 0;
@@ -8867,7 +8868,7 @@ static int ipw_wx_set_essid(struct net_d
 		     length);
 
 	priv->essid_len = length;
-	memcpy(priv->essid, essid, priv->essid_len);
+	memcpy(priv->essid, extra, priv->essid_len);
 
 	/* Network configuration changed -- force [re]association */
 	IPW_DEBUG_ASSOC("[re]association triggered due to ESSID change.\n");
-- 
1.2.6
