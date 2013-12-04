From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] forcedeth: run loopback test only on chipsets that support it
Date: Wed,  4 Dec 2013 18:06:51 +0100
Message-ID: <1386176811-7114-1-git-send-email-ivecera@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932556Ab3LDRGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 12:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver incorrectly run loopback test on chips that don't support it.
Loopback test is only supported by chips that has DEV_HAS_TEST_EXTENDED
flag and returns 4 (NV_TEST_COUNT_EXTENDED) as test count.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 2d045be..1e8b951 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5150,8 +5150,10 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int result;
-	memset(buffer, 0, nv_get_sset_count(dev, ETH_SS_TEST)*sizeof(u64));
+	int result, count;
+
+	count = nv_get_sset_count(dev, ETH_SS_TEST);
+	memset(buffer, 0, count * sizeof(u64));
 
 	if (!nv_link_test(dev)) {
 		test->flags |= ETH_TEST_FL_FAILED;
@@ -5195,7 +5197,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			return;
 		}
 
-		if (!nv_loopback_test(dev)) {
+		if (count > NV_TEST_COUNT_BASE && !nv_loopback_test(dev)) {
 			test->flags |= ETH_TEST_FL_FAILED;
 			buffer[3] = 1;
 		}
-- 
1.8.3.2
