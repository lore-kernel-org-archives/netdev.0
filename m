From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/11][TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG
 flag.
Date: Sat, 05 May 2007 12:48:09 -0700 (PDT)
Message-ID: <20070505.124809.83621910.davem@davemloft.net>
References: <1178326457.4859.23.camel@dell>
	<20070505094612.GB9592@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933223AbXEETsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 15:48:23 -0400
In-Reply-To: <20070505094612.GB9592@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 5 May 2007 10:46:12 +0100

> On Fri, May 04, 2007 at 05:54:17PM -0700, Michael Chan wrote:
> > +	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
> > +		 ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
> > +		  tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
> > +		/* Back to back register writes can cause problems on this chip,
> > +		 * the workaround is to read back all reg writes except those to
> > +		 * mailbox regs.  See tg3_write_indirect_reg32().
> > +		 *
> > +		 * PCI Express 5750_A0 rev chips need this workaround too.
> > +		 */
> >  		tp->write32 = tg3_write_flush_reg32;
> 
> This comment is a little odd now.  What about
> 
> 		/*
> 		 * Back to back register writes can cause problems on these
> 		 * chips, the workaround is to read back all reg writes
> 		 * except those to mailbox regs.
> 		 *
> 		 * See tg3_write_indirect_reg32().
> 		 */
> 
> instead?

Looks nicer to me too.  I made this modification and added some
more verbiage to the changelog as suggested by Jeff Garzik when
I applied this, as follows:

commit 98efd8a6be79550767f5a9be6f3db8e7e9b747da
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Sat May 5 12:47:25 2007 -0700

    [TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG flag.
    
    This patch removes the use of the TG3_FLAG_5701_REG_WRITE_BUG flag.
    It's logic is only used to set a function pointer and thus the
    logic can be collapsed and the flag removed.
    
    [ Comment tidy by Christoph Hellwig. -DaveM ]
    
    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ff157b7..4154e12 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10673,17 +10673,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX)
 		tp->tg3_flags |= TG3_FLAG_TXD_MBOX_HWBUG;
 
-	/* Back to back register writes can cause problems on this chip,
-	 * the workaround is to read back all reg writes except those to
-	 * mailbox regs.  See tg3_write_indirect_reg32().
-	 *
-	 * PCI Express 5750_A0 rev chips need this workaround too.
-	 */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
-	    ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
-	     tp->pci_chip_rev_id == CHIPREV_ID_5750_A0))
-		tp->tg3_flags |= TG3_FLAG_5701_REG_WRITE_BUG;
-
 	if ((pci_state_reg & PCISTATE_BUS_SPEED_HIGH) != 0)
 		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
@@ -10707,8 +10696,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* Various workaround register access methods */
 	if (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG)
 		tp->write32 = tg3_write_indirect_reg32;
-	else if (tp->tg3_flags & TG3_FLAG_5701_REG_WRITE_BUG)
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
+		 ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+		  tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
+		/*
+		 * Back to back register writes can cause problems on these
+		 * chips, the workaround is to read back all reg writes
+		 * except those to mailbox regs.
+		 *
+		 * See tg3_write_indirect_reg32().
+		 */
 		tp->write32 = tg3_write_flush_reg32;
+	}
+
 
 	if ((tp->tg3_flags & TG3_FLAG_TXD_MBOX_HWBUG) ||
 	    (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dd04a46..c52acb0 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2199,7 +2199,6 @@ struct tg3 {
 #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
 #define TG3_FLAG_USE_MI_INTERRUPT	0x00000010
 #define TG3_FLAG_ENABLE_ASF		0x00000020
-#define TG3_FLAG_5701_REG_WRITE_BUG	0x00000040
 #define TG3_FLAG_POLL_SERDES		0x00000080
 #define TG3_FLAG_MBOX_WRITE_REORDER	0x00000100
 #define TG3_FLAG_PCIX_TARGET_HWBUG	0x00000200
