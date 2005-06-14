From: Grant Grundler <iod00d@hp.com>
Subject: [PATCH] tg3_msi() and weakly ordered memory
Date: Mon, 13 Jun 2005 20:37:15 -0700
Message-ID: <20050614033715.GA22376@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@oss.sgi.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,
I reviewed the "new" (to me) use of tags and MSI in tg3_msi() and
tg3_poll() and I like the new scheme. It's pretty clean.

But I did come up with four potential "issues" - mostly revolving
around enforcing order of memory access on weakly ordered platforms:

1) tg3_poll() and tg3_msi() are not consistent with use of rmb().
   tg3_poll has an rmb() between reading status_tag and tg3_has_work().
   The patch (against tg3 v3.29) below adds a similar rmb() to tg3_msi().

   Does tg3_msi() need a "rmb()" like in the attached patch?
   Or rather a mb() to deal with clearing SD_STATUS_UPDATED bit?


2) tg3_poll() and tg3_msi() are not consistent on how they clear
   the SD_STATUS_UPDATED bit. tg3_poll() does not clear SD_STATUS_UPDATED
   bit after reading status_tag. I think everytime the driver discovers
   the status_tag changed, it should to clear SD_STATUS_UPDATED.
   Michael, can you confirm/deny that offhand?

   I'm not sure anymore what order the sblk fields (status_tag, tx_consumer,
   and rx_producer) should be read before clearing SD_STATUS_UPDATED bit.
   I expect a recommended order exists.
   ISTR something like:
	read status_tag
	rmb()
	read tx_consumer and rx_producer
	mb()
	clear SD_STATUS_UPDATED


3) Based on the above sequence, tg3 might need one more rmb() between
   reading sblk status_tag and the inline code for tg3_has_work(). 


4) I'd also prefer if tg3 would read tx_consumer/rx_producer fields
   *only* in tg3_msi() and tg3_poll() when sblk status_tag is read.
   All other references (e.g. tg3_has_work(), tg3_rx(), etc) would use
   a cached copy of those fields.
   My goal would be to reduce the competition for access to sblk
   cacheline and get the memory ordering issues right.
   My fear is regularly reading the cacheline by the CPU will take
   away exclusive (write) access from the IO subsystem and ping-pong
   the cacheline more often than necessary.
   Would you entertain a patch for this?


thanks,
grant


Signed-off-by: Grant Grundler <iodood@hp.com>

--- a/drivers/net/tg3.c	25 May 2005 17:12:47 -0000	1.35
+++ b/drivers/net/tg3.c	14 Jun 2005 01:37:43 -0000
@@ -2946,6 +2946,7 @@ static irqreturn_t tg3_msi(int irq, void
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	tp->last_tag = sblk->status_tag;
+	rmb():
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
