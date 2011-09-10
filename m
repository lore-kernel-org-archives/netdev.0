From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac_esp: remove redundant mutual exclusion
Date: Sun, 11 Sep 2011 01:01:34 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1109110038500.5327@nippy.intranet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mutual exclusion is redundant here because all the paths in the call graph 
leading to esp_driver_ops.send_dma_cmd() happen under spin_lock_irqsave/ 
spin_lock_irqrestore. Remove it.

Tested on a Mac Quadra 660av and a Mac LC 630.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

Part of this patch relates to Geert's m68k generic hard irq conversion 
work. Under genirq, the disable_irq() in mac_esp leads to deadlock. It 
wasn't a problem before because the m68k disable_irq() implementation is 
equivalent to genirq's disable_irq_nosync().

Index: linux-m68k/drivers/scsi/mac_esp.c
===================================================================
--- linux-m68k.orig/drivers/scsi/mac_esp.c	2011-08-28 00:33:13.000000000 +1000
+++ linux-m68k/drivers/scsi/mac_esp.c	2011-08-28 00:35:48.000000000 +1000
@@ -230,9 +230,6 @@ static void mac_esp_send_pdma_cmd(struct
 				  u32 dma_count, int write, u8 cmd)
 {
 	struct mac_esp_priv *mep = MAC_ESP_GET_PRIV(esp);
-	unsigned long flags;
-
-	local_irq_save(flags);
 
 	mep->error = 0;
 
@@ -270,8 +267,6 @@ static void mac_esp_send_pdma_cmd(struct
 			esp_count = n;
 		}
 	} while (esp_count);
-
-	local_irq_restore(flags);
 }
 
 /*
@@ -353,8 +348,6 @@ static void mac_esp_send_pio_cmd(struct
 	struct mac_esp_priv *mep = MAC_ESP_GET_PRIV(esp);
 	u8 *fifo = esp->regs + ESP_FDATA * 16;
 
-	disable_irq(esp->host->irq);
-
 	cmd &= ~ESP_CMD_DMA;
 	mep->error = 0;
 
@@ -431,8 +424,6 @@ static void mac_esp_send_pio_cmd(struct
 			scsi_esp_cmd(esp, ESP_CMD_TI);
 		}
 	}
-
-	enable_irq(esp->host->irq);
 }
 
 static int mac_esp_irq_pending(struct esp *esp)
