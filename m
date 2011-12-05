From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: fix Rx index race between FIFO overflow recovery and NAPI handler.
Date: Mon, 5 Dec 2011 07:30:52 +0100
Message-ID: <20111205063052.GB3103@electric-eye.fr.zoreil.com>
References: <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com> <4ED538EC.4010509@wolke7.net> <20111201102000.GA14013@electric-eye.fr.zoreil.com> <4ED7E6AB.6050308@wolke7.net> <20111201222612.GA27998@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>,
	"'Jonathan Nieder'" <jrnieder@gmail.com>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>, linux-kernel@vger.kernel.org,
	"'Armin Kazmi'" <armin.kazmi@tu-dortmund.de>
To: booster@wolke7.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111201222612.GA27998@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 92fc43b4159b518f5baae57301f26d770b0834c9, rtl8169_tx_timeout ends up
resetting Rx and Tx indexes and thus racing with the NAPI handler via
-> rtl8169_hw_reset
   -> rtl_hw_reset
      -> rtl8169_init_ring_indexes

What about returning to the original state ?

rtl_hw_reset is only used by rtl8169_hw_reset and rtl8169_init_one.

The latter does not need rtl8169_init_ring_indexes because the indexes
still contain their original values from the newly allocated network
device private data area (i.e. 0).

rtl8169_hw_reset is used by:
1. rtl8169_down
   Helper for rtl8169_close. rtl8169_open explicitely inits the indexes
   anyway.
2. rtl8169_pcierr_interrupt
   Indexes are set by rtl8169_reinit_task.
3. rtl8169_interrupt
   rtl8169_hw_reset is needed when the device goes down. See 1.
4. rtl_shutdown
   System shutdown handler. Indexes are irrelevant.
5. rtl8169_reset_task
   Indexes must be set before rtl_hw_start is called.
6. rtl8169_tx_timeout
   Indexes should not be set. This is the job of rtl8169_reset_task anyway.

The removal of rtl8169_hw_reset in rtl8169_tx_timeout and its move in
rtl8169_reset_task do not change the analysis.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: hayeswang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a1e3a6..67bf078 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3935,8 +3935,6 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 			break;
 		udelay(100);
 	}
-
-	rtl8169_init_ring_indexes(tp);
 }
 
 static int __devinit
@@ -5395,14 +5393,16 @@ static void rtl8169_reset_task(struct work_struct *work)
 	if (!netif_running(dev))
 		goto out_unlock;
 
+	rtl8169_hw_reset(tp);
+
 	rtl8169_wait_for_quiescence(dev);
 
 	for (i = 0; i < NUM_RX_DESC; i++)
 		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
 
 	rtl8169_tx_clear(tp);
+	rtl8169_init_ring_indexes(tp);
 
-	rtl8169_hw_reset(tp);
 	rtl_hw_start(dev);
 	netif_wake_queue(dev);
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
@@ -5413,11 +5413,6 @@ out_unlock:
 
 static void rtl8169_tx_timeout(struct net_device *dev)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	rtl8169_hw_reset(tp);
-
-	/* Let's wait a bit while any (async) irq lands on */
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
 }
 
-- 
1.7.6.4
