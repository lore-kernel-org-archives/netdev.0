From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 30 May 2012 10:40:31 +0200
Message-ID: <1338367231.2760.125.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	 <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
	 <20120530090602.6204d857.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49024 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199Ab2E3Ikg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:40:36 -0400
Received: by bkcji2 with SMTP id ji2so3860934bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 01:40:35 -0700 (PDT)
In-Reply-To: <20120530090602.6204d857.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 09:06 +0900, Hiroaki SHIMODA wrote:
> While reading the bql code, I have some questions.
> 
> 1) dql_completed() and dql_queued() can be called concurrently,
>    so dql->num_queued could change while processing
>    dql_completed().
>    Is it intentional to refer num_queued from "dql->" each time ?
> 

not sure it can have problems, but doing the read once is indeed a good
plan.

> 2) From the comment in the code
>    *   - The queue was over-limit in the previous interval and
>    *     when enqueuing it was possible that all queued data
>    *     had been consumed.
> 
>    and
> 
>    * Queue was not starved, check if the limit can be decreased.
>    * A decrease is only considered if the queue has been busy in
>    * the whole interval (the check above). 
> 
>    the calculation of all_prev_completed should take into account
>    completed == dql->prev_num_queued case ?
>    On current implementation, limit shrinks easily and some NIC
>    hit TX stalls.
>    To mitigate TX stalls, should we fix all_prev_completed rather
>    than individual driver ?
> 

Not sure what you mean

> 3) limit calculation fails to consider integer wrap around in
>    one place ?
> 

Yes

> Here is the patch what I meant.
> 
> diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
> @@ -11,22 +11,27 @@
>  #include <linux/dynamic_queue_limits.h>
>  
>  #define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
> +#define POSDIFFI(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
> +#define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
>  
>  /* Records completed count and recalculates the queue limit */
>  void dql_completed(struct dql *dql, unsigned int count)
>  {
>  	unsigned int inprogress, prev_inprogress, limit;
> -	unsigned int ovlimit, all_prev_completed, completed;
> +	unsigned int ovlimit, completed, num_queued;
> +	bool all_prev_completed;
> +
> +	num_queued = dql->num_queued;


I suggest :

	num_queued = ACCESS_ONCE(dql->num_queued);
	
Or else compiler is free to do whatever he wants.
