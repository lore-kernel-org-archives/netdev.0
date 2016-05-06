From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH v2] net: arc/emac: Move arc_emac_tx_clean() into arc_emac_tx() and disable tx interrut
Date: Fri,  6 May 2016 20:19:16 +0800
Message-ID: <1462537156-10489-1-git-send-email-wxt@rock-chips.com>
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	Shuyu Wei <sy.w@outlook.com>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org, Caesar Wang <wxt@rock-chips.com>,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuyu Wei <sy.w@outlook.com>

Doing tx_clean() inside poll() may scramble the tx ring buffer if
tx() is running. This will cause tx to stop working, which can be
reproduced by simultaneously downloading two large files at high speed.

Moving tx_clean() into tx() will prevent this. And tx interrupt is no
longer needed now.

Picked the Shuyu's patch up, the patch is sent on
https://patchwork.kernel.org/patch/8356821/, since that make sense for
rockchip platform.
Note: Many people feedback the cransh problems with rk3036/rk3188 emac when
download the heavy loading and this patch is indeed can fix the crash.

The crash log as the followings:
...
[ 2191.996127 ] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-rc6 #114
[ 2192.002475 ] Hardware name: Rockchip (Device Tree)
[ 2192.007174 ] Backtrace:
[ 2192.009658 ] [<c00134d4>] (dump_backtrace) from [<c0013680>]
    (show_stack+0x18/0x1c)
[ 2192.017220 ]  r7:c051c4f8 r6:ef463180 r5:c05b7000 r4:00000000
[ 2192.022948 ] [<c0013668>] (show_stack) from [<c0219d90>]
    (dump_stack+0x90/0xa0)
[ 2192.030176 ] [<c0219d00>] (dump_stack) from [<c00b2cd4>]
    (bad_page+0xdc/0x12c)
[ 2192.037302 ]  r5:c059a100 r4:c05f430c
[ 2192.040913 ] [<c00b2bf8>] (bad_page) from [<c00b606c>]
    (get_page_from_freelist+0x388/0x95c)
[ 2192.049166 ]  r9:00000008 r8:ef463180 r7:c051c4d0 r6:00000000
    r5:00000000 r4:c051c4e4
[ 2192.056982 ] [<c00b5ce4>] (get_page_from_freelist) from
[<c00b6880>] (__alloc_pages_nodemask+0xd8/0x8e8)
[ 2192.066362 ]  r10:c001b068 r9:00000000 r8:ee0b02b0 r7:60000113
    r6:00000003 r5:02095220
[ 2192.074254 ]  r4:c05ca1c0
[ 2192.076809 ] [<c00b67a8>] (__alloc_pages_nodemask) from
[<c00b7140>] (__alloc_page_frag+0xb0/0x160)
[ 2192.085757 ]  r10:c001b068 r9:00000000 r8:ee0b02b0 r7:60000113
    r6:02080020 r5:00000740
[ 2192.093650 ]  r4:eedbc884
[ 2192.096207 ] [<c00b7090>] (__alloc_page_frag) from [<c03273b4>]
    (__netdev_alloc_skb+0xa0/0x104)
[ 2192.104806 ]  r7:60000113 r6:eedbc884 r5:ee0b0000 r4:00000740
[ 2192.110525 ] [<c0327314>] (__netdev_alloc_skb) from [<c02aac00>]
    (arc_emac_poll+0x318/0x57c)
[ 2192.118865 ]  r9:00000000 r8:ee0b02b0 r7:0000019c r6:ee163780
    r5:00000670 r4:ee0b0000
[ 2192.126683 ] [<c02aa8e8>] (arc_emac_poll) from [<c0339ed8>]
    (net_rx_action+0x1f0/0x2ec)
[ 2192.134590 ]  r10:c0599df8 r9:c059a100 r8:00073760 r7:0000012c
    r6:00000028 r5:c02aa8e8
[ 2192.142483 ]  r4:ee0b04e0
[ 2192.145040 ] [<c0339ce8>] (net_rx_action) from [<c0026f5c>]
    (__do_softirq+0x134/0x258)
[ 2192.152860 ]  r10:c059a080 r9:40000003 r8:00000003 r7:00000100
    r6:c0598000 r5:c059a08c
[ 2192.160751 ]  r4:00000000
...

Signed-off-by: Shuyu Wei <sy.w@outlook.com>
Tested-by: Michael Niewoehner <linux@mniewoehner.de>
Tested-by: Xing Zheng <zhengxing@rock-chips.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Caesar Wang <wxt@rock-chips.com>
---

 drivers/net/ethernet/arc/emac_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..4f4e25e 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -311,12 +311,10 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	unsigned int work_done;
 
-	arc_emac_tx_clean(ndev);
-
 	work_done = arc_emac_rx(ndev, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
+		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
 	}
 
 	return work_done;
@@ -345,9 +343,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 	/* Reset all flags except "MDIO complete" */
 	arc_reg_set(priv, R_STATUS, status);
 
-	if (status & (RXINT_MASK | TXINT_MASK)) {
+	if (status & RXINT_MASK) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
+			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -461,7 +459,7 @@ static int arc_emac_open(struct net_device *ndev)
 	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
 
 	/* Enable interrupts */
-	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
+	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Set CONTROL */
 	arc_reg_set(priv, R_CTRL,
@@ -594,7 +592,7 @@ static int arc_emac_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts */
-	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
+	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Disable EMAC */
 	arc_reg_clr(priv, R_CTRL, EN_MASK);
@@ -656,6 +654,8 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	__le32 *info = &priv->txbd[*txbd_curr].info;
 	dma_addr_t addr;
 
+	arc_emac_tx_clean(ndev);
+
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
 
-- 
1.9.1
