From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/11] IB/ipoib: Flip to new dev walk API
Date: Mon, 17 Oct 2016 19:15:47 -0700
Message-ID: <1476756953-30923-6-git-send-email-dsa@cumulusnetworks.com>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32820 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755705AbcJRCRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 22:17:00 -0400
Received: by mail-pa0-f41.google.com with SMTP id vu5so66617378pab.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 19:17:00 -0700 (PDT)
In-Reply-To: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert ipoib_get_net_dev_match_addr to the new upper device walk API.
This is just a code conversion; no functional change is intended.

v2
- removed typecast of data

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 37 +++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 5636fc3da6b8..cc059218c962 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -292,6 +292,25 @@ static struct net_device *ipoib_get_master_net_dev(struct net_device *dev)
 	return dev;
 }
 
+struct ipoib_walk_data {
+	const struct sockaddr *addr;
+	struct net_device *result;
+};
+
+static int ipoib_upper_walk(struct net_device *upper, void *_data)
+{
+	struct ipoib_walk_data *data = _data;
+	int ret = 0;
+
+	if (ipoib_is_dev_match_addr_rcu(data->addr, upper)) {
+		dev_hold(upper);
+		data->result = upper;
+		ret = 1;
+	}
+
+	return ret;
+}
+
 /**
  * Find a net_device matching the given address, which is an upper device of
  * the given net_device.
@@ -304,27 +323,21 @@ static struct net_device *ipoib_get_master_net_dev(struct net_device *dev)
 static struct net_device *ipoib_get_net_dev_match_addr(
 		const struct sockaddr *addr, struct net_device *dev)
 {
-	struct net_device *upper,
-			  *result = NULL;
-	struct list_head *iter;
+	struct ipoib_walk_data data = {
+		.addr = addr,
+	};
 
 	rcu_read_lock();
 	if (ipoib_is_dev_match_addr_rcu(addr, dev)) {
 		dev_hold(dev);
-		result = dev;
+		data.result = dev;
 		goto out;
 	}
 
-	netdev_for_each_all_upper_dev_rcu(dev, upper, iter) {
-		if (ipoib_is_dev_match_addr_rcu(addr, upper)) {
-			dev_hold(upper);
-			result = upper;
-			break;
-		}
-	}
+	netdev_walk_all_upper_dev_rcu(dev, ipoib_upper_walk, &data);
 out:
 	rcu_read_unlock();
-	return result;
+	return data.result;
 }
 
 /* returns the number of IPoIB netdevs on top a given ipoib device matching a
-- 
2.1.4
