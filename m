From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 1/2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Thu, 16 Apr 2015 14:38:18 -0400
Message-ID: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit da4759c, sysfs will only use the permissions returned by
is_visible, instead of OR'ing them with the default file mode.

This allows us to declare temp1_max with the DEVICE_ATTR_RW macro and
just return the desired permissions for the hwmon sysfs attributes in
dsa_hwmon_attrs_visible.

Also, allow temp1_max to be write-only if set_temp_limit is provided,
but not get_temp_limit.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5eaadab..67d2983 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -124,7 +124,7 @@ static ssize_t temp1_max_store(struct device *dev,
 
 	return count;
 }
-static DEVICE_ATTR(temp1_max, S_IRUGO, temp1_max_show, temp1_max_store);
+static DEVICE_ATTR_RW(temp1_max);
 
 static ssize_t temp1_max_alarm_show(struct device *dev,
 				    struct device_attribute *attr, char *buf)
@@ -154,16 +154,24 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct dsa_switch *ds = dev_get_drvdata(dev);
 	struct dsa_switch_driver *drv = ds->drv;
-	umode_t mode = attr->mode;
+	umode_t mode = 0;
 
-	if (index == 1) {
-		if (!drv->get_temp_limit)
-			mode = 0;
-		else if (drv->set_temp_limit)
+	switch (index) {
+	case 1: /* temp1_max */
+		if (drv->get_temp_limit)
+			mode |= S_IRUGO;
+		if (drv->set_temp_limit)
 			mode |= S_IWUSR;
-	} else if (index == 2 && !drv->get_temp_alarm) {
-		mode = 0;
+		break;
+	case 2: /* temp1_max_alarm */
+		if (drv->get_temp_alarm)
+			mode |= S_IRUGO;
+		break;
+	default:
+		mode = attr->mode;
+		break;
 	}
+
 	return mode;
 }
 
-- 
2.3.5
