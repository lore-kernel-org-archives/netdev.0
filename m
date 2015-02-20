From: Jan Yenya Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Fri, 20 Feb 2015 19:26:59 +0100
Message-ID: <20150220182659.GW13963@fi.muni.cz>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
 <1424455977-21903-6-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:40702 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbbBTS16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 13:27:58 -0500
Content-Disposition: inline
In-Reply-To: <1424455977-21903-6-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fabian Frederick wrote:
: Use helper functions to access current->state.
: Direct assignments are prone to races and therefore buggy.
: 
: current->state = TASK_RUNNING is replaced by __set_current_state()
: 
: Thanks to Peter Zijlstra for the exact definition of the problem.

	OK, thanks. Although I wonder whether real users of COSA (an ISA-based
WAN card) do exist.

Acked-By: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

-Y.

: 
: Suggested-By: Peter Zijlstra <peterz@infradead.org>
: Signed-off-by: Fabian Frederick <fabf@skynet.be>
: ---
:  drivers/net/wan/cosa.c | 12 ++++++------
:  1 file changed, 6 insertions(+), 6 deletions(-)
: 
: diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
: index 83c39e2..88d121d 100644
: --- a/drivers/net/wan/cosa.c
: +++ b/drivers/net/wan/cosa.c
: @@ -806,21 +806,21 @@ static ssize_t cosa_read(struct file *file,
:  	spin_lock_irqsave(&cosa->lock, flags);
:  	add_wait_queue(&chan->rxwaitq, &wait);
:  	while (!chan->rx_status) {
: -		current->state = TASK_INTERRUPTIBLE;
: +		set_current_state(TASK_INTERRUPTIBLE);
:  		spin_unlock_irqrestore(&cosa->lock, flags);
:  		schedule();
:  		spin_lock_irqsave(&cosa->lock, flags);
:  		if (signal_pending(current) && chan->rx_status == 0) {
:  			chan->rx_status = 1;
:  			remove_wait_queue(&chan->rxwaitq, &wait);
: -			current->state = TASK_RUNNING;
: +			__set_current_state(TASK_RUNNING);
:  			spin_unlock_irqrestore(&cosa->lock, flags);
:  			mutex_unlock(&chan->rlock);
:  			return -ERESTARTSYS;
:  		}
:  	}
:  	remove_wait_queue(&chan->rxwaitq, &wait);
: -	current->state = TASK_RUNNING;
: +	__set_current_state(TASK_RUNNING);
:  	kbuf = chan->rxdata;
:  	count = chan->rxsize;
:  	spin_unlock_irqrestore(&cosa->lock, flags);
: @@ -890,14 +890,14 @@ static ssize_t cosa_write(struct file *file,
:  	spin_lock_irqsave(&cosa->lock, flags);
:  	add_wait_queue(&chan->txwaitq, &wait);
:  	while (!chan->tx_status) {
: -		current->state = TASK_INTERRUPTIBLE;
: +		set_current_state(TASK_INTERRUPTIBLE);
:  		spin_unlock_irqrestore(&cosa->lock, flags);
:  		schedule();
:  		spin_lock_irqsave(&cosa->lock, flags);
:  		if (signal_pending(current) && chan->tx_status == 0) {
:  			chan->tx_status = 1;
:  			remove_wait_queue(&chan->txwaitq, &wait);
: -			current->state = TASK_RUNNING;
: +			__set_current_state(TASK_RUNNING);
:  			chan->tx_status = 1;
:  			spin_unlock_irqrestore(&cosa->lock, flags);
:  			up(&chan->wsem);
: @@ -905,7 +905,7 @@ static ssize_t cosa_write(struct file *file,
:  		}
:  	}
:  	remove_wait_queue(&chan->txwaitq, &wait);
: -	current->state = TASK_RUNNING;
: +	__set_current_state(TASK_RUNNING);
:  	up(&chan->wsem);
:  	spin_unlock_irqrestore(&cosa->lock, flags);
:  	kfree(kbuf);
: -- 
: 2.1.0

-- 
| Jan "Yenya" Kasprzak   <kas at {fi.muni.cz - work | yenya.net - private}> |
| New GPG 4096R/A45477D5 -- see http://www.fi.muni.cz/~kas/pgp-rollover.txt |
| http://www.fi.muni.cz/~kas/     Journal: http://www.fi.muni.cz/~kas/blog/ |
||| "New and improved" is only really improved if it also takes backwards |||
||| compatibility into account, rather than saying "now everybody must do |||
||| things the new and improved - and different - way"   --Linus Torvalds |||
