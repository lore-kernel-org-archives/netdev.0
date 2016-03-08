From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH] net: dsa: Fix cleanup resources upon module removal
Date: Tue,  8 Mar 2016 10:36:20 +0100
Message-ID: <1457429780-7665-1-git-send-email-narmstrong@baylibre.com>
References: <20151207.163608.1805578623951785262.davem@davemloft.net>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: davem@davemloft.net, f.fainelli@gmail.com, andrew@lunn.ch,
	rmk+kernel@arm.linux.org.uk, pavel.nakonechny@skitlab.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207.163608.1805578623951785262.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initial commit badly merged into the dsa_resume method instead
of the dsa_remove_dst method.
As consequence, the dst->master_netdev->dsa_ptr is not set to NULL on
removal and re-bind of the dsa device fails with error -17.

Fixes: b0dc635d923c ("net: dsa: cleanup resources upon module removal ")
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

David, Florian, Andrew,

This fix is quite urgent since it breaks all the removal cleanup.

Thanks,
Neil

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fa4daba..d8fb47f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -935,6 +935,14 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
+	dst->master_netdev->dsa_ptr = NULL;
+
+	/* If we used a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point get sent
+	 * without the tag and go through the regular receive path.
+	 */
+	wmb();
+
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
 
@@ -988,14 +996,6 @@ static int dsa_suspend(struct device *d)
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 	int i, ret = 0;
 
-	dst->master_netdev->dsa_ptr = NULL;
-
-	/* If we used a tagging format that doesn't have an ethertype
-	 * field, make sure that all packets from this point get sent
-	 * without the tag and go through the regular receive path.
-	 */
-	wmb();
-
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
 
-- 
1.9.1
