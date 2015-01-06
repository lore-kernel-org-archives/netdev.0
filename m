From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] netlink: get rid of nl_table_lock
Date: Tue, 6 Jan 2015 23:00:50 +0000
Message-ID: <20150106230050.GA6870@casper.infradead.org>
References: <cover.1420230585.git.tgraf@suug.ch>
 <daae84cd33bfde8518b849176e25dcf3eea8014b.1420230585.git.tgraf@suug.ch>
 <20150103110211.18b11f0f@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57892 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbAFXA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:00:57 -0500
Content-Disposition: inline
In-Reply-To: <20150103110211.18b11f0f@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/15 at 11:02am, Stephen Hemminger wrote:
> As a follow on to Thomas's patch I think this would complete the
> transistion to RCU for netlink.
> Compile tested only.
> 
> 
> 
> This patch gets rid of the reader/writer nl_table_lock and replaces it
> with exclusively using RCU for reading, and a mutex for writing.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

I like it. One thing I noticed it that it leaves a mix of
native mutex unlocks and unlocks via netlink_table_ungrab().

The Open vSwitch upcall is a pretty good real world Netlink
benchmark. I'll run the tests I have to see if this has any
unexpected side effects.

>  void netlink_table_grab(void)
> -	__acquires(nl_table_lock)
>  {
> -	might_sleep();
> -
> -	write_lock_irq(&nl_table_lock);
> -
> -	if (atomic_read(&nl_table_users)) {
> -		DECLARE_WAITQUEUE(wait, current);
> -
> -		add_wait_queue_exclusive(&nl_table_wait, &wait);
> -		for (;;) {
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			if (atomic_read(&nl_table_users) == 0)
> -				break;
> -			write_unlock_irq(&nl_table_lock);
> -			schedule();
> -			write_lock_irq(&nl_table_lock);
> -		}
> -
> -		__set_current_state(TASK_RUNNING);
> -		remove_wait_queue(&nl_table_wait, &wait);
> -	}
> +	mutex_lock(&nl_table_mutex);
>  }

I left this untouched so far as I wasn't clear on what side effect
it would have to remove this as it does explicitely relax writers
right now.
