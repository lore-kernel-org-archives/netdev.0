From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] 8139cp: properly config rx mode after resuming
Date: Sat, 31 Dec 2011 17:44:42 +0800
Message-ID: <20111231094442.5433.76076.stgit@dhcp-8-146.nay.redhat.com>
References: <20111231094433.5433.67602.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akong@redhat.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111231094433.5433.67602.stgit@dhcp-8-146.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rx mode should be reset after resming, so unconditionally updating rx
mode rather than conditionally updating based on the value we
remembered, otherwise unexpected value may be used by the nic after
resuming.

btw. I find and test this when debugging guest hibernation in qemu, as
I did not have a 8139cp card in hand, this patch is untested in a
physical 8139cp card, plase review it carefully.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 886e6be..cc6b391 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -859,7 +859,6 @@ static void __cp_set_rx_mode (struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int rx_mode;
-	u32 tmp;
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
@@ -886,11 +885,9 @@ static void __cp_set_rx_mode (struct net_device *dev)
 	}
 
 	/* We can safely update without stopping the chip. */
-	tmp = cp_rx_config | rx_mode;
-	if (cp->rx_config != tmp) {
-		cpw32_f (RxConfig, tmp);
-		cp->rx_config = tmp;
-	}
+	cp->rx_config = cp_rx_config | rx_mode;
+	cpw32_f(RxConfig, cp->rx_config);
+
 	cpw32_f (MAR0 + 0, mc_filter[0]);
 	cpw32_f (MAR0 + 4, mc_filter[1]);
 }
