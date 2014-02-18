From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next] ieee802154: fix faulty check in set_phy_params api
Date: Tue, 18 Feb 2014 14:39:27 +0100
Message-ID: <1392730767-24858-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:38595 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbaBRNjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:39:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_set_csma_params has a redundant (and impossible) check for
"retries", found by smatch. The check was supposed to be for
frame_retries, but wasn't moved during development when
phy_set_frame_retries was introduced. Also, maxBE >= 3 as required by
the standard is not enforced.

Remove the redundant check, assure max_be >= 3 and check -1 <=
frame_retries <= 7 in the correct function.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/nl-phy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index c9dfd6f..222310a 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -436,8 +436,7 @@ static int phy_set_csma_params(struct wpan_phy *phy, struct genl_info *info)
 	if (info->attrs[IEEE802154_ATTR_CSMA_MAX_BE])
 		max_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]);
 
-	if (retries > 5 || max_be > 8 || min_be > max_be ||
-	    retries < -1 || retries > 7)
+	if (retries > 5 || max_be < 3 || max_be > 8 || min_be > max_be)
 		return -EINVAL;
 
 	rc = phy->set_csma_params(phy, min_be, max_be, retries);
@@ -456,6 +455,9 @@ static int phy_set_frame_retries(struct wpan_phy *phy, struct genl_info *info)
 	s8 retries = nla_get_s8(info->attrs[IEEE802154_ATTR_FRAME_RETRIES]);
 	int rc;
 
+	if (retries < -1 || retries > 7)
+		return -EINVAL;
+
 	rc = phy->set_frame_retries(phy, retries);
 	if (rc < 0)
 		return rc;
-- 
1.9.0
