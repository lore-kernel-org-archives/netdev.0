From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu,  4 May 2017 23:10:56 +0300
Message-ID: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0043.outbound.protection.outlook.com ([104.47.33.43]:40688
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751472AbdEDULt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 16:11:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This patch fixes the crash that happens when driver tries to collect statistics
from already released "aq_vec" object.
If adapter is in "down" state we still allow user to see statistics from HW.

V2: fixed braces around "aq_vec_free".

Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index cdb0299..9ee1c50 100644
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
@@ -959,8 +959,10 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
 		goto err_exit;
 
 	for (i = AQ_DIMOF(self->aq_vec); i--;) {
-		if (self->aq_vec[i])
+		if (self->aq_vec[i]) {
 			aq_vec_free(self->aq_vec[i]);
+			self->aq_vec[i] = NULL;
+		}
 	}
 
 err_exit:;
-- 
2.7.4
