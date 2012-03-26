From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v3] Ethernet driver for the WIZnet W5300 chip
Date: Mon, 26 Mar 2012 15:05:04 +0600
Message-ID: <4F703140.5030005@permonline.ru>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru> <1332586938-2804-1-git-send-email-msink@permonline.ru> <1332605415.3487.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332605415.3487.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

24.03.2012 22:10, Eric Dumazet wrote:
> As there is no tx interrupt at the end of transmit to eventually XON the
> queue, you cant XOFF it when there it no room in transmit queue.

Actually there is, but is unused in original driver, don't know why.


> Rule to use NETDEV_TX_BUSY is :
>
> Before returning NETDEV_TX_BUSY, qdisc must have been stopped by
> netif_stop_queue(ndev) (and tx completion might call netif_wake_queue()
> later)

I tried handle this situation, and it seems to work perfectly:

@@ -377,7 +377,8 @@ static int w5300_start_tx(struct sk_buff *skb, 
struct net_device *ndev)
          struct w5300_private *priv = netdev_priv(ndev);

          if (unlikely(w5300_read32(priv, W5300_S0_TX_FSR) < skb->len)) {
-                ndev->stats.tx_dropped++;
+                netif_stop_queue(ndev);
+                w5300_write(priv, W5300_S0_IMR, S0_IR_RECV | S0_IR_SENDOK);
                  return NETDEV_TX_BUSY;
          }

@@ -443,6 +444,12 @@ static irqreturn_t w5300_interrupt(int irq, void 
*ndev_instance)
                  __napi_schedule(&priv->napi);
          }

+        if (unlikely(netif_queue_stopped(ndev))) {
+                w5300_write(priv, W5300_S0_IR, S0_IR_SENDOK);
+                w5300_write(priv, W5300_S0_IMR, S0_IR_RECV);
+                netif_wake_queue(ndev);
+        }
+
          return IRQ_HANDLED;
  }

-- 
Mike
