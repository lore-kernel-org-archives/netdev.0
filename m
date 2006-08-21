From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 7/7] ieee80211: Workaround malformed 802.11 frames from AP
Date: Mon, 21 Aug 2006 11:34:19 +0800
Message-ID: <20060821033419.GA4820@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59479 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932546AbWHUDgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:36:14 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stop processing further but return success when we receive a malformed
packet from the AP. We need this patch to workaround some AP bugs. For
example, the beacon frames from the Orinoco AP1000 contains an IE (value
= 128) with length equals to 8 but the actual frame length is only 7.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_rx.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

b3d142a90dbe64140e390af28117983498def99d
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index d60358d..7707041 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1078,13 +1078,16 @@ static int ieee80211_parse_info_param(st
 
 	while (length >= sizeof(*info_element)) {
 		if (sizeof(*info_element) + info_element->len > length) {
-			IEEE80211_DEBUG_MGMT("Info elem: parse failed: "
-					     "info_element->len + 2 > left : "
-					     "info_element->len+2=%zd left=%d, id=%d.\n",
-					     info_element->len +
-					     sizeof(*info_element),
-					     length, info_element->id);
-			return 1;
+			IEEE80211_ERROR("Info elem: parse failed: "
+					"info_element->len + 2 > left : "
+					"info_element->len+2=%zd left=%d, id=%d.\n",
+					info_element->len +
+					sizeof(*info_element),
+					length, info_element->id);
+			/* We stop processing but don't return an error here
+			 * because some misbehaviour APs break this rule. ie.
+			 * Orinoco AP1000. */
+			break;
 		}
 
 		switch (info_element->id) {
-- 
1.2.6
