From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 21 Jun 2005 16:56:34 -0700 (PDT)
Message-ID: <20050621.165634.07642938.davem@davemloft.net>
References: <20050614154625.GB24371@esmail.cup.hp.com>
	<1118771563.7059.30.camel@rh4>
	<20050614211530.GB25516@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: iod00d@hp.com
In-Reply-To: <20050614211530.GB25516@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, here is the patch I came up with as a result of this thread.

Michael stated he would investigate using a pure tag comparison in
place of tg3_has_work() when the chip is using tagged interrupts.

Thanks.

[TG3]: Fix missing memory barriers and SD_STATUS_UPDATED bit clearing.

There must be a rmb() between reading the status block tag
and calling tg3_has_work().  This was missing in tg3_mis()
and tg3_interrupt_tagged().  tg3_poll() got it right.

Also, SD_STATUS_UPDATED must be cleared in the status block
right before we call tg3_has_work().  Only tg3_poll() got this
wrong.

Based upon patches and commentary from Grant Grundler and
Michael Chan.

Signed-off-by: David S. Miller <davem@davemloft.net>

--- 1/drivers/net/tg3.c.~1~	2005-06-21 16:39:19.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-06-21 16:47:55.000000000 -0700
@@ -2929,6 +2929,7 @@
 	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
 		tp->last_tag = sblk->status_tag;
 	rmb();
+	sblk->status &= ~SD_STATUS_UPDATED;
 
 	/* if no more work, tell net stack and NIC we're done */
 	done = !tg3_has_work(tp);
@@ -2964,6 +2965,7 @@
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	tp->last_tag = sblk->status_tag;
+	rmb();
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3051,6 +3053,7 @@
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
 		tp->last_tag = sblk->status_tag;
+		rmb();
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
