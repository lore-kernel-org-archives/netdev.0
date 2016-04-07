From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 5/8] net: mediatek: fix mtk_pending_work
Date: Thu,  7 Apr 2016 21:26:47 +0200
Message-ID: <1460057210-55786-6-git-send-email-blogic@openwrt.org>
References: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
 <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1460057210-55786-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver supports 2 MACs. Both run on the same DMA ring. If we hit a TX
timeout we need to stop both netdevs before restarting them again. If we
don't do this, mtk_stop() wont shutdown DMA and the consecutive call to
mtk_open() wont restart DMA and enable IRQs.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   31 ++++++++++++++++++---------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4ebc42e..60b66ab 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1430,19 +1430,30 @@ static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static void mtk_pending_work(struct work_struct *work)
 {
-	struct mtk_mac *mac = container_of(work, struct mtk_mac, pending_work);
-	struct mtk_eth *eth = mac->hw;
-	struct net_device *dev = eth->netdev[mac->id];
-	int err;
+	struct mtk_eth *eth = container_of(work, struct mtk_eth, pending_work);
+	int err, i;
+	unsigned long restart = 0;
 
 	rtnl_lock();
-	mtk_stop(dev);
 
-	err = mtk_open(dev);
-	if (err) {
-		netif_alert(eth, ifup, dev,
-			    "Driver up/down cycle failed, closing device.\n");
-		dev_close(dev);
+	/* stop all devices to make sure that dma is properly shut down */
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!netif_oper_up(eth->netdev[i]))
+			continue;
+		mtk_stop(eth->netdev[i]);
+		__set_bit(i, &restart);
+	}
+
+	/* restart DMA and enable IRQs */
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!test_bit(i, &restart))
+			continue;
+		err = mtk_open(eth->netdev[i]);
+		if (err) {
+			netif_alert(eth, ifup, eth->netdev[i],
+			      "Driver up/down cycle failed, closing device.\n");
+			dev_close(eth->netdev[i]);
+		}
 	}
 	rtnl_unlock();
 }
-- 
1.7.10.4
