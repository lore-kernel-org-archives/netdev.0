From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 2/2] net: dsa: register hwmon for any provided function
Date: Thu, 16 Apr 2015 14:38:19 -0400
Message-ID: <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A switch driver may only provide one of the temperature limit accessors,
or the temperature alarm getter. So register the hwmon subsystem if any
of the related functions is provided.

Thus, check get_temp to set the visibility of temp1_input.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 67d2983..6b68994 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -157,6 +157,10 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
 	umode_t mode = 0;
 
 	switch (index) {
+	case 0: /* temp1_input */
+		if (drv->get_temp)
+			mode |= S_IRUGO;
+		break;
 	case 1: /* temp1_max */
 		if (drv->get_temp_limit)
 			mode |= S_IRUGO;
@@ -310,7 +314,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * register with hardware monitoring subsystem.
 	 * Treat registration error as non-fatal and ignore it.
 	 */
-	if (drv->get_temp) {
+	if (drv->get_temp || drv->get_temp_limit || drv->set_temp_limit ||
+	    drv->get_temp_alarm) {
 		const char *netname = netdev_name(dst->master_netdev);
 		char hname[IFNAMSIZ + 1];
 		int i, j;
-- 
2.3.5
