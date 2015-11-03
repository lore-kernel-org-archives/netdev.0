From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] net/core: ensure features get disabled on new lower devs
Date: Tue,  3 Nov 2015 15:36:57 -0500
Message-ID: <1446583017-19021-1-git-send-email-jarod@redhat.com>
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
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With moving netdev_sync_lower_features() after the .ndo_set_features
calls, I neglected to verify that devices added *after* a flag had been
disabled on an upper device were properly added with that flag disabled as
well. This currently happens, because we exit __netdev_update_features()
when we see dev->features == features for the upper dev. We can retain the
optimization of leaving without calling .ndo_set_features with a bit of
tweaking and a goto here.

Changing err to ret was somewhat arbitrary and makes the patch look more
involved, but seems to better fit the altered use.

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
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/core/dev.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8ce3f74..90e0a62 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6402,7 +6402,7 @@ int __netdev_update_features(struct net_device *dev)
 	struct net_device *upper, *lower;
 	netdev_features_t features;
 	struct list_head *iter;
-	int err = 0;
+	int ret = 0;
 
 	ASSERT_RTNL();
 
@@ -6419,31 +6419,34 @@ int __netdev_update_features(struct net_device *dev)
 		features = netdev_sync_upper_features(dev, upper, features);
 
 	if (dev->features == features)
-		return 0;
+		goto sync_lower;
 
 	netdev_dbg(dev, "Features changed: %pNF -> %pNF\n",
 		&dev->features, &features);
 
 	if (dev->netdev_ops->ndo_set_features)
-		err = dev->netdev_ops->ndo_set_features(dev, features);
+		ret = dev->netdev_ops->ndo_set_features(dev, features);
 
-	if (unlikely(err < 0)) {
+	if (unlikely(ret < 0)) {
 		netdev_err(dev,
 			"set_features() failed (%d); wanted %pNF, left %pNF\n",
-			err, &features, &dev->features);
+			ret, &features, &dev->features);
 		return -1;
 	}
 
+	if (!ret) {
+		dev->features = features;
+		ret = 1;
+	}
+
+sync_lower:
 	/* some features must be disabled on lower devices when disabled
 	 * on an upper device (think: bonding master or bridge)
 	 */
 	netdev_for_each_lower_dev(dev, lower, iter)
 		netdev_sync_lower_features(dev, lower, features);
 
-	if (!err)
-		dev->features = features;
-
-	return 1;
+	return ret;
 }
 
 /**
-- 
1.8.3.1
