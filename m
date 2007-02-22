From: divy@chelsio.com
Subject: [PATCH 1/7] cxgb3 - manage sysfs attributes per port
Date: Thu, 22 Feb 2007 03:59:20 -0800
Message-ID: <20070222115920.9983.8657.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8557 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161061AbXBVL70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:59:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

sysfs attributes are now managed per port, no longer per adapter.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 43583ed..59f2b51 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -434,27 +434,25 @@ static int setup_sge_qsets(struct adapte
 
 static ssize_t attr_show(struct device *d, struct device_attribute *attr,
 			 char *buf,
-			 ssize_t(*format) (struct adapter *, char *))
+			 ssize_t(*format) (struct net_device *, char *))
 {
 	ssize_t len;
-	struct adapter *adap = to_net_dev(d)->priv;
 
 	/* Synchronize with ioctls that may shut down the device */
 	rtnl_lock();
-	len = (*format) (adap, buf);
+	len = (*format) (to_net_dev(d), buf);
 	rtnl_unlock();
 	return len;
 }
 
 static ssize_t attr_store(struct device *d, struct device_attribute *attr,
 			  const char *buf, size_t len,
-			  ssize_t(*set) (struct adapter *, unsigned int),
+			  ssize_t(*set) (struct net_device *, unsigned int),
 			  unsigned int min_val, unsigned int max_val)
 {
 	char *endp;
 	ssize_t ret;
 	unsigned int val;
-	struct adapter *adap = to_net_dev(d)->priv;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -464,7 +462,7 @@ static ssize_t attr_store(struct device
 		return -EINVAL;
 
 	rtnl_lock();
-	ret = (*set) (adap, val);
+	ret = (*set) (to_net_dev(d), val);
 	if (!ret)
 		ret = len;
 	rtnl_unlock();
@@ -472,8 +470,9 @@ static ssize_t attr_store(struct device
 }
 
 #define CXGB3_SHOW(name, val_expr) \
-static ssize_t format_##name(struct adapter *adap, char *buf) \
+static ssize_t format_##name(struct net_device *dev, char *buf) \
 { \
+	struct adapter *adap = dev->priv; \
 	return sprintf(buf, "%u\n", val_expr); \
 } \
 static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
@@ -482,8 +481,10 @@ static ssize_t show_##name(struct device
 	return attr_show(d, attr, buf, format_##name); \
 }
 
-static ssize_t set_nfilters(struct adapter *adap, unsigned int val)
+static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
 {
+	struct adapter *adap = dev->priv;
+
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
 	if (val && adap->params.rev == 0)
@@ -500,8 +501,10 @@ static ssize_t store_nfilters(struct dev
 	return attr_store(d, attr, buf, len, set_nfilters, 0, ~0);
 }
 
-static ssize_t set_nservers(struct adapter *adap, unsigned int val)
+static ssize_t set_nservers(struct net_device *dev, unsigned int val)
 {
+	struct adapter *adap = dev->priv;
+
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
 	if (val > t3_mc5_size(&adap->mc5) - adap->params.mc5.nfilters)
