From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net] net/ncsi: Don't assume last available channel exists
Date: Wed, 20 Sep 2017 14:12:51 +1000
Message-ID: <20170920041251.14635-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When handling new VLAN tags in NCSI we check the maximum allowed number
of filters on the last active ("hot") channel. However if the 'add'
callback is called before NCSI has configured a channel, this causes a
NULL dereference.

Check that we actually have a hot channel, and warn if it is missing.

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/ncsi-manage.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 3fd3c39e6278..fc800f934beb 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1420,7 +1420,10 @@ int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 	}
 
 	ndp = TO_NCSI_DEV_PRIV(nd);
-	ncf = ndp->hot_channel->filters[NCSI_FILTER_VLAN];
+	if (!ndp) {
+		netdev_warn(dev, "ncsi: No ncsi_dev_priv?\n");
+		return 0;
+	}
 
 	/* Add the VLAN id to our internal list */
 	list_for_each_entry_rcu(vlan, &ndp->vlan_vids, list) {
@@ -1432,11 +1435,17 @@ int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 		}
 	}
 
-	if (n_vids >= ncf->total) {
-		netdev_info(dev,
-			    "NCSI Channel supports up to %u VLAN tags but %u are already set\n",
-			    ncf->total, n_vids);
-		return -EINVAL;
+	if (!ndp->hot_channel) {
+		netdev_warn(dev,
+			    "ncsi: no available filter to check maximum\n");
+	} else {
+		ncf = ndp->hot_channel->filters[NCSI_FILTER_VLAN];
+		if (n_vids >= ncf->total) {
+			netdev_info(dev,
+				    "NCSI Channel supports up to %u VLAN tags but %u are already set\n",
+				    ncf->total, n_vids);
+			return -EINVAL;
+		}
 	}
 
 	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
-- 
2.14.1
