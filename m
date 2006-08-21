From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 03/14] ipw2200: ipw_wx_set_essid fix
Date: Mon, 21 Aug 2006 11:37:13 +0800
Message-ID: <20060821033712.GA5344@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14451 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932568AbWHUDjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:39:07 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleanups the ipw_wx_set_essid code and forces a reassociation
when setting the essid to "any". I have tested this patch with iwconfig. It
makes ipw2200 compliant with all the cases mentioned in the iwconfig man
page. The commands

iwconfig iface essid any
iwconfig iface essid -- any
iwconfig iface essid off
iwconfig iface essid on

all seemed to work correctly. None of this worked before the patch.

Note, this patch treats

iwconfig iface essid
iwconfig iface essid ""

The same. It produces an error message: essid: Unknown host.
Since an essid of "" is not mentioned in the iwconfig man page.

Signed-off-by: Bill Moss <bmoss@clemson.edu>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   39 +++++++++++++++++----------------------
 1 files changed, 17 insertions(+), 22 deletions(-)

f56340f0647db8f3c8fecc290424fdc4b7e8ad00
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 0b2c774..27e87d1 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8837,28 +8837,23 @@ static int ipw_wx_set_essid(struct net_d
 			    union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-	char *essid = "";	/* ANY */
-	int length = 0;
-	mutex_lock(&priv->mutex);
-	if (wrqu->essid.flags && wrqu->essid.length) {
-		length = wrqu->essid.length - 1;
-		essid = extra;
-	}
-	if (length == 0) {
-		IPW_DEBUG_WX("Setting ESSID to ANY\n");
-		if ((priv->config & CFG_STATIC_ESSID) &&
-		    !(priv->status & (STATUS_ASSOCIATED |
-				      STATUS_ASSOCIATING))) {
-			IPW_DEBUG_ASSOC("Attempting to associate with new "
-					"parameters.\n");
-			priv->config &= ~CFG_STATIC_ESSID;
-			ipw_associate(priv);
-		}
-		mutex_unlock(&priv->mutex);
-		return 0;
-	}
+        char *essid;
+        int length;
+
+        mutex_lock(&priv->mutex);
+
+        if (!wrqu->essid.flags)
+        {
+                IPW_DEBUG_WX("Setting ESSID to ANY\n");
+                ipw_disassociate(priv);
+                priv->config &= ~CFG_STATIC_ESSID;
+                ipw_associate(priv);
+                mutex_unlock(&priv->mutex);
+                return 0;
+        }
 
-	length = min(length, IW_ESSID_MAX_SIZE);
+	length = min(wrqu->essid.length, IW_ESSID_MAX_SIZE);
+	essid = extra;
 
 	priv->config |= CFG_STATIC_ESSID;
 
@@ -8868,7 +8863,7 @@ static int ipw_wx_set_essid(struct net_d
 		return 0;
 	}
 
-	IPW_DEBUG_WX("Setting ESSID: '%s' (%d)\n", escape_essid(essid, length),
+	IPW_DEBUG_WX("Setting ESSID: '%s' (%d)\n", escape_essid(extra, length),
 		     length);
 
 	priv->essid_len = length;
-- 
1.2.6
