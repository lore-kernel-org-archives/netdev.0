From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] irda: ali-ircc: Fix deadlock in ali_ircc_sir_change_speed()
Date: Sat, 12 Sep 2015 00:34:48 +0300
Message-ID: <1442007288-31322-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ali_ircc_sir_change_speed() is always called with self->lock held,
so acquiring the lock inside it leads to unavoidable deadlock.

Call graph:
ali_ircc_sir_change_speed() is called from ali_ircc_change_speed()
  ali_ircc_fir_hard_xmit() under spin_lock_irqsave(&self->lock, flags);
  ali_ircc_sir_hard_xmit() under spin_lock_irqsave(&self->lock, flags);
  ali_ircc_net_ioctl() under spin_lock_irqsave(&self->lock, flags);
  ali_ircc_dma_xmit_complete()
    ali_ircc_fir_interrupt()
      ali_ircc_interrupt() under spin_lock(&self->lock);
  ali_ircc_sir_write_wakeup()
    ali_ircc_sir_interrupt()
      ali_ircc_interrupt() under spin_lock(&self->lock);

The patch removes spin_lock/unlock from ali_ircc_sir_change_speed().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/irda/ali-ircc.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 58ae11a14bb6..64bb44d5d867 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1031,7 +1031,6 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
 static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 {
 	struct ali_ircc_cb *self = priv;
-	unsigned long flags;
 	int iobase; 
 	int fcr;    /* FIFO control reg */
 	int lcr;    /* Line control reg */
@@ -1061,8 +1060,6 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	/* Update accounting for new speed */
 	self->io.speed = speed;
 
-	spin_lock_irqsave(&self->lock, flags);
-
 	divisor = 115200/speed;
 	
 	fcr = UART_FCR_ENABLE_FIFO;
@@ -1089,9 +1086,6 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	/* without this, the connection will be broken after come back from FIR speed,
 	   but with this, the SIR connection is harder to established */
 	outb((UART_MCR_DTR | UART_MCR_RTS | UART_MCR_OUT2), iobase+UART_MCR);
-	
-	spin_unlock_irqrestore(&self->lock, flags);
-	
 }
 
 static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
-- 
1.9.1
