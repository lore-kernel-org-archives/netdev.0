From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: [PATCH] sky2: fix hang on Yukon-EC (0xb6) rev 1
Date: Tue, 24 Jan 2006 14:19:56 +0100
Message-ID: <43D6297C.8000900@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030474AbWAXNWX@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch for sky2 fixes a hang on Yukon-EC (0xb6) rev 1
where suddenly no more interrupts were delivered.

I don't know the real cause of the hang due to lack of docs,
but the patch has been running stable for a few hours
whereas the unmodified driver will hang after less than
2 minutes.

Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/

Signed-off-by: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>

--- linux-2.6.15/drivers/net/sky2.c	2006-01-23 23:41:35.000000000 +0100
+++ linux-2.6.15/drivers/net/sky2.c	2006-01-24 14:12:12.000000000 +0100
@@ -1913,8 +1913,26 @@
 	}
 
 exit_loop:
+	/* Is this really a good idea?
+	 * We clear all IRQs although there may be pending work due to
+	 * - packets arrived since start of this function
+	 * - the (++work_done >= to_do) abort
+	 */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 
+	/* Pending resolution of the comment above, at least kick the
+	 * STAT_LEV_TIMER_CTRL timer.
+	 * This fixes my hangs on Yukon-EC (0xb6) rev 1.
+	 * The if clause is there to start the timer only if it has been
+	 * configured correctly and not been disabled via ethtool.
+	 * Maybe it would be sufficient to only restart the timer if
+	 * there is pending work. Without docs, that is hard to say.
+	 */
+	if (sky2_read8(hw, STAT_LEV_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_LEV_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_LEV_TIMER_CTRL, TIM_START);
+	}
+
 	sky2_tx_check(hw, 0, tx_done[0]);
 	sky2_tx_check(hw, 1, tx_done[1]);
 
