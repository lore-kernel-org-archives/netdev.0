From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 17:39:19 -0700
Message-ID: <1116031159.6214.8.camel@rh4>
References: <Pine.LNX.4.61.0505121942190.14917@linux.site>
 <20050512.211935.67881321.davem@davemloft.net>
 <Pine.LNX.4.61.0505131648140.14917@linux.site>
 <20050513.175013.00786860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050513.175013.00786860.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-13 at 17:50 -0700, David S.Miller wrote:

> Perhaps we can make the logic in tg3_poll() smarter about
> this.  Something like:
> 
> 	tg3_process_phy_events();
> 	tg3_tx();
> 	tg3_rx();
> 
> 	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
> 		tp->last_tag = sblk->status_tag;
> 	rmb();
> 	done = !tg3_has_work(tp);
> 	if (done) {
> 		spin_lock_irqsave(&tp->lock, flags);
> 		__netif_rx_complete(netdev);
> 		tg3_restart_ints(tp);
> 		spin_unlock_irqrestore(&tp->lock, flags);
> 	}
> 	return (done ? 0 : 1);
> 
> Basically, move the last_tag sample to after we do the
> work, then recheck the RX/TX producer/consumer indexes.
> 

I like this. I think it will work well.
