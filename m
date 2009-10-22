From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 2/4] 8139too: use mc helpers to
	access	multicast list
Date: Thu, 22 Oct 2009 15:53:08 +0200
Message-ID: <20091022135308.GE2868@psychotron.lab.eng.brq.redhat.com>
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
 drivers/net/8139too.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 7e333f7..f0c3670 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2501,6 +2501,15 @@ static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 	return &dev->stats;
 }
 
+static void mc_walker(void *data, unsigned char *addr)
+{
+	u32 *mc_filter = data;
+	int bit_nr;
+
+	bit_nr = ether_crc(ETH_ALEN, addr) >> 26;
+	mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+}
+
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */
 
@@ -2509,7 +2518,7 @@ static void __set_rx_mode (struct net_device *dev)
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp;
 
 	pr_debug("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n",
@@ -2521,22 +2530,17 @@ static void __set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit)
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
-		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
-		     i++, mclist = mclist->next) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
-
-			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+		if (!netdev_mc_empty(dev))
 			rx_mode |= AcceptMulticast;
-		}
+		mc_filter[1] = mc_filter[0] = 0;
+		netdev_mc_walk(dev, mc_walker, mc_filter);
 	}
 
 	/* We can safely update without stopping the chip. */
-- 
1.6.2.5


------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
