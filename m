From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 17:50:13 -0700 (PDT)
Message-ID: <20050513.175013.00786860.davem@davemloft.net>
References: <Pine.LNX.4.61.0505121942190.14917@linux.site>
	<20050512.211935.67881321.davem@davemloft.net>
	<Pine.LNX.4.61.0505131648140.14917@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0505131648140.14917@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arthur Kepner <akepner@sgi.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 16:57:51 -0700 (PDT)

> I found that the reason is that, 
> under high receive load, most of the time (~80%) the 
> tag in the status block changes between the time that 
> it's read (and saved as last_tag) in tg3_poll(), and when 
> it's written back to MAILBOX_INTERRUPT_0 in 
> tg3_restart_ints(). If I understand the way the status 
> tag works, that means that the card will immediately 
> generate another interrupt. That's consistent with 
> what I'm seeing - a much higher interrupt rate when the 
> tagged status patch is used.

Thanks for tracking this down.

Perhaps we can make the logic in tg3_poll() smarter about
this.  Something like:

	tg3_process_phy_events();
	tg3_tx();
	tg3_rx();

	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
		tp->last_tag = sblk->status_tag;
	rmb();
	done = !tg3_has_work(tp);
	if (done) {
		spin_lock_irqsave(&tp->lock, flags);
		__netif_rx_complete(netdev);
		tg3_restart_ints(tp);
		spin_unlock_irqrestore(&tp->lock, flags);
	}
	return (done ? 0 : 1);

Basically, move the last_tag sample to after we do the
work, then recheck the RX/TX producer/consumer indexes.
