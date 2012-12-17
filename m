From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: [PATCH] atm: use scnprintf() instead of sprintf()
Date: Mon, 17 Dec 2012 11:00:01 -0500
Message-ID: <20121217110001.3eaf3ac5@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chen Gang <gang.chen@asianux.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:57997 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab2LQQAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 11:00:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As reported by Chen Gang <gang.chen@asianux.com>, we should ensure there
is enough space when formatting the sysfs buffers.

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
---
 net/atm/atm_sysfs.c |   40 +++++++++++++++-------------------------
 1 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index f49da58..350bf62 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -14,49 +14,45 @@ static ssize_t show_type(struct device *cdev,
 			 struct device_attribute *attr, char *buf)
 {
 	struct atm_dev *adev = to_atm_dev(cdev);
-	return sprintf(buf, "%s\n", adev->type);
+
+	return scnprintf(buf, PAGE_SIZE, "%s\n", adev->type);
 }
 
 static ssize_t show_address(struct device *cdev,
 			    struct device_attribute *attr, char *buf)
 {
-	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
-	int i;
-
-	for (i = 0; i < (ESI_LEN - 1); i++)
-		pos += sprintf(pos, "%02x:", adev->esi[i]);
-	pos += sprintf(pos, "%02x\n", adev->esi[i]);
 
-	return pos - buf;
+	return scnprintf(buf, PAGE_SIZE, "%pM\n", adev->esi);
 }
 
 static ssize_t show_atmaddress(struct device *cdev,
 			       struct device_attribute *attr, char *buf)
 {
 	unsigned long flags;
-	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
 	struct atm_dev_addr *aaddr;
 	int bin[] = { 1, 2, 10, 6, 1 }, *fmt = bin;
-	int i, j;
+	int i, j, count = 0;
 
 	spin_lock_irqsave(&adev->lock, flags);
 	list_for_each_entry(aaddr, &adev->local, entry) {
 		for (i = 0, j = 0; i < ATM_ESA_LEN; ++i, ++j) {
 			if (j == *fmt) {
-				pos += sprintf(pos, ".");
+				count += scnprintf(buf + count,
+						   PAGE_SIZE - count, ".");
 				++fmt;
 				j = 0;
 			}
-			pos += sprintf(pos, "%02x",
-				       aaddr->addr.sas_addr.prv[i]);
+			count += scnprintf(buf + count,
+					   PAGE_SIZE - count, "%02x",
+					   aaddr->addr.sas_addr.prv[i]);
 		}
-		pos += sprintf(pos, "\n");
+		count += scnprintf(buf + count, PAGE_SIZE - count, "\n");
 	}
 	spin_unlock_irqrestore(&adev->lock, flags);
 
-	return pos - buf;
+	return count;
 }
 
 static ssize_t show_atmindex(struct device *cdev,
@@ -64,25 +60,21 @@ static ssize_t show_atmindex(struct device *cdev,
 {
 	struct atm_dev *adev = to_atm_dev(cdev);
 
-	return sprintf(buf, "%d\n", adev->number);
+	return scnprintf(buf, PAGE_SIZE, "%d\n", adev->number);
 }
 
 static ssize_t show_carrier(struct device *cdev,
 			    struct device_attribute *attr, char *buf)
 {
-	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
 
-	pos += sprintf(pos, "%d\n",
-		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
-
-	return pos - buf;
+	return scnprintf(buf, PAGE_SIZE, "%d\n",
+			 adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
 }
 
 static ssize_t show_link_rate(struct device *cdev,
 			      struct device_attribute *attr, char *buf)
 {
-	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
 	int link_rate;
 
@@ -100,9 +92,7 @@ static ssize_t show_link_rate(struct device *cdev,
 	default:
 		link_rate = adev->link_rate * 8 * 53;
 	}
-	pos += sprintf(pos, "%d\n", link_rate);
-
-	return pos - buf;
+	return scnprintf(buf, PAGE_SIZE, "%d\n", link_rate);
 }
 
 static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
-- 
1.7.7.6
