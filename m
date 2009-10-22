From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6 0/4] net: change the way
	mc_list is	accessed
Date: Thu, 22 Oct 2009 15:54:47 +0200
Message-ID: <20091022135446.GG2868@psychotron.lab.eng.brq.redhat.com>
References: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mchehab@infradead.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	linux-media@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/media/dvb/dvb-core/dvb_net.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 8c9ae0a..eb50fb0 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1110,17 +1110,16 @@ static int dvb_net_feed_stop(struct net_device *dev)
 }
 
 
-static int dvb_set_mc_filter (struct net_device *dev, struct dev_mc_list *mc)
+static void dvb_set_mc_filter(void *data, unsigned char *addr)
 {
-	struct dvb_net_priv *priv = netdev_priv(dev);
+	struct dvb_net_priv *priv = data;
 
 	if (priv->multi_num == DVB_NET_MULTICAST_MAX)
-		return -ENOMEM;
+		return;
 
-	memcpy(priv->multi_macs[priv->multi_num], mc->dmi_addr, 6);
+	memcpy(priv->multi_macs[priv->multi_num], addr, ETH_ALEN);
 
 	priv->multi_num++;
-	return 0;
 }
 
 
@@ -1140,21 +1139,14 @@ static void wq_set_multicast_list (struct work_struct *work)
 	} else if ((dev->flags & IFF_ALLMULTI)) {
 		dprintk("%s: allmulti mode\n", dev->name);
 		priv->rx_mode = RX_MODE_ALL_MULTI;
-	} else if (dev->mc_count) {
-		int mci;
-		struct dev_mc_list *mc;
-
+	} else if (netdev_mc_count(dev)) {
 		dprintk("%s: set_mc_list, %d entries\n",
-			dev->name, dev->mc_count);
+			dev->name, netdev_mc_count(dev));
 
 		priv->rx_mode = RX_MODE_MULTI;
 		priv->multi_num = 0;
 
-		for (mci = 0, mc=dev->mc_list;
-		     mci < dev->mc_count;
-		     mc = mc->next, mci++) {
-			dvb_set_mc_filter(dev, mc);
-		}
+		netdev_mc_walk(dev, dvb_set_mc_filter, priv);
 	}
 
 	netif_addr_unlock_bh(dev);
-- 
1.6.2.5


------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
