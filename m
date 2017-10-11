From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net] net/ncsi: Don't limit vids based on hot_channel
Date: Wed, 11 Oct 2017 16:54:27 +1100
Message-ID: <20171011055427.30227-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we drop any new VLAN ids if there are more than the current
(or last used) channel can support. Most importantly this is a problem
if no channel has been selected yet, resulting in a segfault.

Secondly this does not necessarily reflect the capabilities of any other
channels. Instead only drop a new VLAN id if we are already tracking the
maximum allowed by the NCSI specification. Per-channel limits are
already handled by ncsi_add_filter(), but add a message to set_one_vid()
to make it obvious that the channel can not support any more VLAN ids.

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 17 +++++++++--------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index af3d636534ef..d30f7bd741d0 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -286,6 +286,7 @@ struct ncsi_dev_priv {
 	struct work_struct  work;            /* For channel management     */
 	struct packet_type  ptype;           /* NCSI packet Rx handler     */
 	struct list_head    node;            /* Form NCSI device list      */
+#define NCSI_MAX_VLAN_VIDS	15
 	struct list_head    vlan_vids;       /* List of active VLAN IDs */
 };
 
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 3fd3c39e6278..b6a449aa9d4b 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -732,6 +732,10 @@ static int set_one_vid(struct ncsi_dev_priv *ndp, struct ncsi_channel *nc,
 	if (index < 0) {
 		netdev_err(ndp->ndev.dev,
 			   "Failed to add new VLAN tag, error %d\n", index);
+		if (index == -ENOSPC)
+			netdev_err(ndp->ndev.dev,
+				   "Channel %u already has all VLAN filters set\n",
+				   nc->id);
 		return -1;
 	}
 
@@ -1403,7 +1407,6 @@ static int ncsi_kick_channels(struct ncsi_dev_priv *ndp)
 
 int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
-	struct ncsi_channel_filter *ncf;
 	struct ncsi_dev_priv *ndp;
 	unsigned int n_vids = 0;
 	struct vlan_vid *vlan;
@@ -1420,7 +1423,6 @@ int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 	}
 
 	ndp = TO_NCSI_DEV_PRIV(nd);
-	ncf = ndp->hot_channel->filters[NCSI_FILTER_VLAN];
 
 	/* Add the VLAN id to our internal list */
 	list_for_each_entry_rcu(vlan, &ndp->vlan_vids, list) {
@@ -1431,12 +1433,11 @@ int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 			return 0;
 		}
 	}
-
-	if (n_vids >= ncf->total) {
-		netdev_info(dev,
-			    "NCSI Channel supports up to %u VLAN tags but %u are already set\n",
-			    ncf->total, n_vids);
-		return -EINVAL;
+	if (n_vids >= NCSI_MAX_VLAN_VIDS) {
+		netdev_warn(dev,
+			    "tried to add vlan id %u but NCSI max already registered (%u)\n",
+			    vid, NCSI_MAX_VLAN_VIDS);
+		return -ENOSPC;
 	}
 
 	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
-- 
2.14.2
