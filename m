From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/irda/bfin_sir: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:50:06 -0700
Message-ID: <20171005005006.GA23177@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/staging/irda/drivers/bfin_sir.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/irda/drivers/bfin_sir.c b/drivers/staging/irda/drivers/bfin_sir.c
index 3151b580dbd6..59e409b68349 100644
--- a/drivers/staging/irda/drivers/bfin_sir.c
+++ b/drivers/staging/irda/drivers/bfin_sir.c
@@ -22,6 +22,8 @@ static int max_rate = 57600;
 static int max_rate = 115200;
 #endif
 
+static void bfin_sir_rx_dma_timeout(struct timer_list *t);
+
 static void turnaround_delay(int mtt)
 {
 	long ticks;
@@ -57,7 +59,7 @@ static void bfin_sir_init_ports(struct bfin_sir_port *sp, struct platform_device
 	sp->clk = get_sclk();
 #ifdef CONFIG_SIR_BFIN_DMA
 	sp->tx_done        = 1;
-	init_timer(&(sp->rx_dma_timer));
+	timer_setup(&sp->rx_dma_timer, bfin_sir_rx_dma_timeout, 0);
 #endif
 }
 
@@ -317,10 +319,12 @@ static void bfin_sir_dma_rx_chars(struct net_device *dev)
 		async_unwrap_char(dev, &self->stats, &self->rx_buff, port->rx_dma_buf.buf[i]);
 }
 
-void bfin_sir_rx_dma_timeout(struct net_device *dev)
+static void bfin_sir_rx_dma_timeout(struct timer_list *t)
 {
+	struct bfin_sir_port *port = from_timer(port, t, rx_dma_timer);
+	struct net_device *dev = port->dev;
 	struct bfin_sir_self *self = netdev_priv(dev);
-	struct bfin_sir_port *port = self->sir_port;
+
 	int x_pos, pos;
 	unsigned long flags;
 
@@ -405,8 +409,6 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 	set_dma_start_addr(port->rx_dma_channel, (unsigned long)port->rx_dma_buf.buf);
 	enable_dma(port->rx_dma_channel);
 
-	port->rx_dma_timer.data = (unsigned long)(dev);
-	port->rx_dma_timer.function = (void *)bfin_sir_rx_dma_timeout;
 
 #else
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
