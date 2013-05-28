From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net-next 1/4] igb: refactor and simplify time sync
 interrupt handling
Date: Tue, 28 May 2013 15:24:08 +0000
Message-ID: <CDCA19C9.1E862%matthew.vick@intel.com>
References: <e81791002acaf082ace4ec7bb1fa24ab6633fd49.1369645944.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50222 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934551Ab3E1PYK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 11:24:10 -0400
In-Reply-To: <e81791002acaf082ace4ec7bb1fa24ab6633fd49.1369645944.git.richardcochran@gmail.com>
Content-Language: en-US
Content-ID: <08ED8FE7B26B5D4E91ACCFB0FE9E9691@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>The code that handles the time sync interrupt is repeated in three
>different places. This patch refactors the identical code blocks into
>a single helper function. Also, reading the TSICR register already
>acknowledges the time sync interrupts, and so there is no need to
>write that register at all.
>
>Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>---
> drivers/net/ethernet/intel/igb/igb_main.c |   47
>+++++++++++------------------
> 1 file changed, 17 insertions(+), 30 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>b/drivers/net/ethernet/intel/igb/igb_main.c
>index 6a0c1b6..d25a965 100644
>--- a/drivers/net/ethernet/intel/igb/igb_main.c
>+++ b/drivers/net/ethernet/intel/igb/igb_main.c
>@@ -5035,6 +5035,17 @@ void igb_update_stats(struct igb_adapter *adapter,
> 	}
> }
> 
>+static void igb_tsync_interrupt(struct igb_adapter *adapter)
>+{
>+	struct e1000_hw *hw = &adapter->hw;
>+	u32 tsicr = rd32(E1000_TSICR);
>+
>+	if (tsicr & E1000_TSICR_TXTS) {
>+		/* retrieve hardware timestamp */
>+		schedule_work(&adapter->ptp_tx_work);
>+	}
>+}
>+
> static irqreturn_t igb_msix_other(int irq, void *data)
> {
> 	struct igb_adapter *adapter = data;
>@@ -5066,16 +5077,8 @@ static irqreturn_t igb_msix_other(int irq, void
>*data)
> 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
> 	}
> 
>-	if (icr & E1000_ICR_TS) {
>-		u32 tsicr = rd32(E1000_TSICR);
>-
>-		if (tsicr & E1000_TSICR_TXTS) {
>-			/* acknowledge the interrupt */
>-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
>-			/* retrieve hardware timestamp */
>-			schedule_work(&adapter->ptp_tx_work);
>-		}
>-	}
>+	if (icr & E1000_ICR_TS)
>+		igb_tsync_interrupt(adapter);
> 
> 	wr32(E1000_EIMS, adapter->eims_other);
> 
>@@ -5850,16 +5853,8 @@ static irqreturn_t igb_intr_msi(int irq, void
>*data)
> 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
> 	}
> 
>-	if (icr & E1000_ICR_TS) {
>-		u32 tsicr = rd32(E1000_TSICR);
>-
>-		if (tsicr & E1000_TSICR_TXTS) {
>-			/* acknowledge the interrupt */
>-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
>-			/* retrieve hardware timestamp */
>-			schedule_work(&adapter->ptp_tx_work);
>-		}
>-	}
>+	if (icr & E1000_ICR_TS)
>+		igb_tsync_interrupt(adapter);
> 
> 	napi_schedule(&q_vector->napi);
> 
>@@ -5904,16 +5899,8 @@ static irqreturn_t igb_intr(int irq, void *data)
> 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
> 	}
> 
>-	if (icr & E1000_ICR_TS) {
>-		u32 tsicr = rd32(E1000_TSICR);
>-
>-		if (tsicr & E1000_TSICR_TXTS) {
>-			/* acknowledge the interrupt */
>-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
>-			/* retrieve hardware timestamp */
>-			schedule_work(&adapter->ptp_tx_work);
>-		}
>-	}
>+	if (icr & E1000_ICR_TS)
>+		igb_tsync_interrupt(adapter);
> 
> 	napi_schedule(&q_vector->napi);
> 
>-- 
>1.7.10.4

NAK due to the question you raised in the other thread--this will break
1588 on the 82580, but there was really no way for you to know that. As I
mentioned before, I'm getting the internal discussion going to confirm
that.

Matthew
