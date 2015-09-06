From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: bridge: check __vlan_vid_del for error
Date: Sat,  5 Sep 2015 21:27:57 -0400
Message-ID: <1441502877-31972-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since __vlan_del can return an error code, change its inner function
__vlan_vid_del to return an eventual error from switchdev_port_obj_del.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_vlan.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 3cd8cc9..5f5a02b 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -117,10 +117,11 @@ out_filt:
 	return err;
 }
 
-static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
-			   u16 vid)
+static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
+			  u16 vid)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	int err = 0;
 
 	/* If driver uses VLAN ndo ops, use 8021q to delete vid
 	 * on device, otherwise try switchdev ops to delete vid.
@@ -137,8 +138,12 @@ static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 			},
 		};
 
-		switchdev_port_obj_del(dev, &vlan_obj);
+		err = switchdev_port_obj_del(dev, &vlan_obj);
+		if (err == -EOPNOTSUPP)
+			err = 0;
 	}
+
+	return err;
 }
 
 static int __vlan_del(struct net_port_vlans *v, u16 vid)
@@ -151,7 +156,11 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 
 	if (v->port_idx) {
 		struct net_bridge_port *p = v->parent.port;
-		__vlan_vid_del(p->dev, p->br, vid);
+		int err;
+
+		err = __vlan_vid_del(p->dev, p->br, vid);
+		if (err)
+			return err;
 	}
 
 	clear_bit(vid, v->vlan_bitmap);
-- 
2.5.1
