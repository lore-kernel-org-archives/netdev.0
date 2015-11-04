From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v2 net-next] net/core: ensure features get disabled on new lower devs
Date: Tue,  3 Nov 2015 23:09:32 -0500
Message-ID: <1446610172-21420-1-git-send-email-jarod@redhat.com>
References: <1446583017-19021-1-git-send-email-jarod@redhat.com>
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
In-Reply-To: <1446583017-19021-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With moving netdev_sync_lower_features() after the .ndo_set_features
calls, I neglected to verify that devices added *after* a flag had been
disabled on an upper device were properly added with that flag disabled as
well. This currently happens, because we exit __netdev_update_features()
when we see dev->features == features for the upper dev. We can retain the
optimization of leaving without calling .ndo_set_features with a bit of
tweaking and a goto here.

Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
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
Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
v2: Based on suggestions from Alex, and with not changing err to ret, this
patch actually becomes quite minimal and doesn't ugly up the code much.

 net/core/dev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8ce3f74..ab9b8d0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6402,7 +6402,7 @@ int __netdev_update_features(struct net_device *dev)
 	struct net_device *upper, *lower;
 	netdev_features_t features;
 	struct list_head *iter;
-	int err = 0;
+	int err = -1;
 
 	ASSERT_RTNL();
 
@@ -6419,7 +6419,7 @@ int __netdev_update_features(struct net_device *dev)
 		features = netdev_sync_upper_features(dev, upper, features);
 
 	if (dev->features == features)
-		return 0;
+		goto sync_lower;
 
 	netdev_dbg(dev, "Features changed: %pNF -> %pNF\n",
 		&dev->features, &features);
@@ -6434,6 +6434,7 @@ int __netdev_update_features(struct net_device *dev)
 		return -1;
 	}
 
+sync_lower:
 	/* some features must be disabled on lower devices when disabled
 	 * on an upper device (think: bonding master or bridge)
 	 */
@@ -6443,7 +6444,7 @@ int __netdev_update_features(struct net_device *dev)
 	if (!err)
 		dev->features = features;
 
-	return 1;
+	return err < 0 ? 0 : 1;
 }
 
 /**
-- 
1.8.3.1
