From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 08/11] rocker: Flip to the new dev walk API
Date: Fri, 14 Oct 2016 18:28:48 -0700
Message-ID: <1476494931-31813-9-git-send-email-dsa@cumulusnetworks.com>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35689 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753265AbcJOB3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 21:29:08 -0400
Received: by mail-pf0-f180.google.com with SMTP id s8so56384989pfj.2
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 18:29:07 -0700 (PDT)
In-Reply-To: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert rocker to the new dev walk API. This is just a code conversion;
no functional change is intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 5424fb341613..9310adc0bcbb 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2839,20 +2839,37 @@ static bool rocker_port_dev_check_under(const struct net_device *dev,
 	return true;
 }
 
+struct rocker_walk_data {
+	struct rocker *rocker;
+	struct rocker_port *port;
+};
+
+static int rocker_lower_dev_walk(struct net_device *lower_dev, void *_data)
+{
+	struct rocker_walk_data *data = (struct rocker_walk_data *)_data;
+	int ret = 0;
+
+	if (rocker_port_dev_check_under(lower_dev, data->rocker)) {
+		data->port = netdev_priv(lower_dev);
+		ret = 1;
+	}
+
+	return ret;
+}
+
 struct rocker_port *rocker_port_dev_lower_find(struct net_device *dev,
 					       struct rocker *rocker)
 {
-	struct net_device *lower_dev;
-	struct list_head *iter;
+	struct rocker_walk_data data;
 
 	if (rocker_port_dev_check_under(dev, rocker))
 		return netdev_priv(dev);
 
-	netdev_for_each_all_lower_dev(dev, lower_dev, iter) {
-		if (rocker_port_dev_check_under(lower_dev, rocker))
-			return netdev_priv(lower_dev);
-	}
-	return NULL;
+	data.rocker = rocker;
+	data.port = NULL;
+	netdev_walk_all_lower_dev(dev, rocker_lower_dev_walk, &data);
+
+	return data.port;
 }
 
 static int rocker_netdevice_event(struct notifier_block *unused,
-- 
2.1.4
