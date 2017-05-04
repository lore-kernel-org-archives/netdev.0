From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu,  4 May 2017 19:33:11 +0300
Message-ID: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0043.outbound.protection.outlook.com ([104.47.38.43]:25312
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752780AbdEDQeg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 12:34:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This patch fixes the crash that happens when driver tries to collect statistics
from already released "aq_vec" object.

Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index cdb0299..3a32573 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
 	count = 0U;
 
 	for (i = 0U, aq_vec = self->aq_vec[0];
-		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
+		aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
 		data += count;
 		aq_vec_get_sw_stats(aq_vec, data, &count);
 	}
@@ -961,6 +961,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
 	for (i = AQ_DIMOF(self->aq_vec); i--;) {
 		if (self->aq_vec[i])
 			aq_vec_free(self->aq_vec[i]);
+			self->aq_vec[i] = NULL;
 	}
 
 err_exit:;
-- 
2.7.4
