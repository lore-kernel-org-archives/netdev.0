From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH v2] mac802154: Keep track of the
	channel when changed
Date: Fri,  5 Apr 2013 19:03:10 -0400
Message-ID: <1365202990-9006-1-git-send-email-alan@signal11.us>
References: <515F4017.6060404@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <515F4017.6060404-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Two sections checked whether the current channel != the new channel
without ever setting the current channel variables.

1. net/mac802154/tx.c: Prevent set_channel() from getting called every
time a packet is sent.

2. net/mac802154/mib.c: Lock (pib_lock) accesses to current_channel and
current_page and make sure they are updated when the channel has been
changed.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/mac802154/mib.c | 12 +++++++++++-
 net/mac802154/tx.c  |  3 +++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index f03e55f..8ded97c 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -176,9 +176,15 @@ static void phy_chan_notify(struct work_struct *work)
 	struct mac802154_sub_if_data *priv = netdev_priv(nw->dev);
 	int res;
 
+	mutex_lock(&priv->hw->phy->pib_lock);
 	res = hw->ops->set_channel(&hw->hw, priv->page, priv->chan);
 	if (res)
 		pr_debug("set_channel failed\n");
+	else {
+		priv->hw->phy->current_channel = priv->chan;
+		priv->hw->phy->current_page = priv->page;
+	}
+	mutex_unlock(&priv->hw->phy->pib_lock);
 
 	kfree(nw);
 }
@@ -195,8 +201,11 @@ void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
 	priv->chan = chan;
 	spin_unlock_bh(&priv->mib_lock);
 
+	mutex_lock(&priv->hw->phy->pib_lock);
 	if (priv->hw->phy->current_channel != priv->chan ||
 	    priv->hw->phy->current_page != priv->page) {
+		mutex_unlock(&priv->hw->phy->pib_lock);
+
 		work = kzalloc(sizeof(*work), GFP_ATOMIC);
 		if (!work)
 			return;
@@ -204,5 +213,6 @@ void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
 		INIT_WORK(&work->work, phy_chan_notify);
 		work->dev = dev;
 		queue_work(priv->hw->dev_workqueue, &work->work);
-	}
+	} else
+		mutex_unlock(&priv->hw->phy->pib_lock);
 }
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 3fd3e07..6d16473 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -58,6 +58,9 @@ static void mac802154_xmit_worker(struct work_struct *work)
 			pr_debug("set_channel failed\n");
 			goto out;
 		}
+
+		xw->priv->phy->current_channel = xw->chan;
+		xw->priv->phy->current_page = xw->page;
 	}
 
 	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
