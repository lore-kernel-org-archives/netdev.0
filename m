From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] net/core: fix for_each_netdev_feature
Date: Tue,  3 Nov 2015 10:15:59 -0500
Message-ID: <1446563759-17713-1-git-send-email-jarod@redhat.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbbKCPQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 10:16:10 -0500
In-Reply-To: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Nikolay and further explained by Geert, the initial
for_each_netdev_feature macro was broken, as feature would get set outside
of the block of code it was intended to run in, thus only ever working for
the first feature bit in the mask. While less pretty this way, this is
tested and confirmed functional with multiple feature bits set in
NETIF_F_UPPER_DISABLES.

[root@dell-per730-01 ~]# ethtool -K bond0 lro off
...
[  242.761394] bond0: Disabling feature 0x0000000000008000 on lower dev p5p2.
[  243.552178] bnx2x 0000:06:00.1 p5p2: using MSI-X  IRQs: sp 74  fp[0] 76 ... fp[7] 83
[  244.353978] bond0: Disabling feature 0x0000000000008000 on lower dev p5p1.
[  245.147420] bnx2x 0000:06:00.0 p5p1: using MSI-X  IRQs: sp 62  fp[0] 64 ... fp[7] 71

[root@dell-per730-01 ~]# ethtool -K bond0 gro off
...
[  251.925645] bond0: Disabling feature 0x0000000000004000 on lower dev p5p2.
[  252.713693] bnx2x 0000:06:00.1 p5p2: using MSI-X  IRQs: sp 74  fp[0] 76 ... fp[7] 83
[  253.499085] bond0: Disabling feature 0x0000000000004000 on lower dev p5p1.
[  254.290922] bnx2x 0000:06:00.0 p5p1: using MSI-X  IRQs: sp 62  fp[0] 64 ... fp[7] 71

Fixes: fd867d51f ("net/core: generic support for disabling netdev features down stack")
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Nikolay Aleksandrov <razor@blackwall.org>
CC: Michal Kubecek <mkubecek@suse.cz>
CC: Alexander Duyck <alexander.duyck@gmail.com>
CC: Geert Uytterhoeven <geert@linux-m68k.org>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 include/linux/netdev_features.h | 6 ++----
 net/core/dev.c                  | 8 ++++++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 0f5837a..f0d8734 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -125,10 +125,8 @@ enum {
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 
-#define for_each_netdev_feature(mask_addr, feature)				\
-	int bit;								\
-	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)	\
-		feature = __NETIF_F_BIT(bit);
+#define for_each_netdev_feature(mask_addr, bit)	\
+	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/dev.c b/net/core/dev.c
index c4d2b43..8ce3f74 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6293,8 +6293,10 @@ static netdev_features_t netdev_sync_upper_features(struct net_device *lower,
 {
 	netdev_features_t upper_disables = NETIF_F_UPPER_DISABLES;
 	netdev_features_t feature;
+	int feature_bit;
 
-	for_each_netdev_feature(&upper_disables, feature) {
+	for_each_netdev_feature(&upper_disables, feature_bit) {
+		feature = __NETIF_F_BIT(feature_bit);
 		if (!(upper->wanted_features & feature)
 		    && (features & feature)) {
 			netdev_dbg(lower, "Dropping feature %pNF, upper dev %s has it off.\n",
@@ -6311,8 +6313,10 @@ static void netdev_sync_lower_features(struct net_device *upper,
 {
 	netdev_features_t upper_disables = NETIF_F_UPPER_DISABLES;
 	netdev_features_t feature;
+	int feature_bit;
 
-	for_each_netdev_feature(&upper_disables, feature) {
+	for_each_netdev_feature(&upper_disables, feature_bit) {
+		feature = __NETIF_F_BIT(feature_bit);
 		if (!(features & feature) && (lower->features & feature)) {
 			netdev_dbg(upper, "Disabling feature %pNF on lower dev %s.\n",
 				   &feature, lower->name);
-- 
1.8.3.1
