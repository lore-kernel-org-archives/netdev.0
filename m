From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: sxgbe: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:53:20 -0700
Message-ID: <20171025105320.GA146603@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byungho An <bh74.an@samsung.com>, Girish K S <ks.giri@samsung.com>,
        Vipul Pandya <vipul.pandya@samsung.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Byungho An <bh74.an@samsung.com>
Cc: Girish K S <ks.giri@samsung.com>
Cc: Vipul Pandya <vipul.pandya@samsung.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 89831adb8eb7..fd35d8004a78 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -105,9 +105,9 @@ void sxgbe_disable_eee_mode(struct sxgbe_priv_data * const priv)
  *  If there is no data transfer and if we are not in LPI state,
  *  then MAC Transmitter can be moved to LPI state.
  */
-static void sxgbe_eee_ctrl_timer(unsigned long arg)
+static void sxgbe_eee_ctrl_timer(struct timer_list *t)
 {
-	struct sxgbe_priv_data *priv = (struct sxgbe_priv_data *)arg;
+	struct sxgbe_priv_data *priv = from_timer(priv, t, eee_ctrl_timer);
 
 	sxgbe_enable_eee_mode(priv);
 	mod_timer(&priv->eee_ctrl_timer, SXGBE_LPI_TIMER(eee_timer));
@@ -134,8 +134,7 @@ bool sxgbe_eee_init(struct sxgbe_priv_data * const priv)
 			return false;
 
 		priv->eee_active = 1;
-		setup_timer(&priv->eee_ctrl_timer, sxgbe_eee_ctrl_timer,
-			    (unsigned long)priv);
+		timer_setup(&priv->eee_ctrl_timer, sxgbe_eee_ctrl_timer, 0);
 		priv->eee_ctrl_timer.expires = SXGBE_LPI_TIMER(eee_timer);
 		add_timer(&priv->eee_ctrl_timer);
 
@@ -1002,13 +1001,13 @@ static void sxgbe_disable_mtl_engine(struct sxgbe_priv_data *priv)
 
 /**
  * sxgbe_tx_timer: mitigation sw timer for tx.
- * @data: data pointer
+ * @t: timer pointer
  * Description:
  * This is the timer handler to directly invoke the sxgbe_tx_clean.
  */
-static void sxgbe_tx_timer(unsigned long data)
+static void sxgbe_tx_timer(struct timer_list *t)
 {
-	struct sxgbe_tx_queue *p = (struct sxgbe_tx_queue *)data;
+	struct sxgbe_tx_queue *p = from_timer(p, t, txtimer);
 	sxgbe_tx_queue_clean(p);
 }
 
@@ -1028,8 +1027,7 @@ static void sxgbe_tx_init_coalesce(struct sxgbe_priv_data *priv)
 		struct sxgbe_tx_queue *p = priv->txq[queue_num];
 		p->tx_coal_frames =  SXGBE_TX_FRAMES;
 		p->tx_coal_timer = SXGBE_COAL_TX_TIMER;
-		setup_timer(&p->txtimer, sxgbe_tx_timer,
-			    (unsigned long)&priv->txq[queue_num]);
+		timer_setup(&p->txtimer, sxgbe_tx_timer, 0);
 		p->txtimer.expires = SXGBE_COAL_TIMER(p->tx_coal_timer);
 		add_timer(&p->txtimer);
 	}
-- 
2.7.4


-- 
Kees Cook
Pixel Security
