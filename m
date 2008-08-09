From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Sat, 09 Aug 2008 09:34:25 +0200
Message-ID: <1218267265.29098.48.camel@lappy.programming.kicks-ass.net>
References: <506429.22669.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:59987 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbYHIHeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 03:34:46 -0400
In-Reply-To: <506429.22669.qm@web82107.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-08-08 at 18:23 -0700, David Witbrodt wrote:
> I have tracked the regression down to an RCU problem.
> 
> I added some printk()'s to the function inet_register_protosw() in
> net/ipv4/af_inet.c, as seen in this diff:
> 
> ===== BEGIN DIFF ==========
>       * non-permanent entry.  This means that when we remove this entry, the
>       * system automatically returns to the old behavior.
>       */
> +    printk ("     Adding new protocol\n");
>      list_add_rcu(&p->list, last_perm);
> +
>  out:
> +    printk ("     Unlocking spinlock\n");
>      spin_unlock_bh(&inetsw_lock);
>  
> +    printk ("     Calling synchronize_net()\n");
>      synchronize_net();
>  
>      return;
> ===== END DIFF ==========
> 
> A kernel built with these changes freezes with "Calling synchronize_net()"
> as the last printed line.
> 
> I located the function synchronize_net() in net/core/dev.c, and it was easy
> to add some printk()'s there:
> 
> ===== BEGIN DIFF ==========
>  
> void synchronize_net(void)
>  {
> +    printk ("   synchronize_net(): calling might_sleep()\n");
>      might_sleep();
> +
> +    printk ("   synchronize_net(): calling synchronize_rcu()\n");
>      synchronize_rcu();
>  }
> ===== END DIFF ==========
> 
> The kernel built with these changes froze with "synchronize_net(): 
> calling synchronize_rcu()" as the last line on the screen.
> 
> After reading some documentation in Documentation/RCU/, it looks like 
> something is misusing RCU -- and, according to the Documentation, those kinds 
> of mistakes are easy to make.  Maybe necessary calls to
>  
>     rcu_read_lock()
>     rcu_read_unlock()
> 
> are missing, and something about my hardware is triggering a freeze that 
> doesn't occur on most hardware.
> 
> 
> For some reason, turning off the HPET by booting with "hpet=disabled" keeps
> the freeze from happening.  Just reading a couple of those docs about RCU
> made me dizzy, so I hope someone familiar with RCU issues will take a look
> at the code in the files I've listed.  Surely you guys can take it from here
> now?!
> 
> If not, just give me some experimental code changes to make to get my 2.6.26
> and 2.6.27 kernels working again without disabling HPET!!!


The typical way to deadlock like this is do something like:

 rcu_read_lock();

   synchronize_rcu();

 rcu_read_unlock();

While I cannot immediately see any such usage in the function you
quoted, it could be on of the callers.. let me browse some code..

Can't seem to find anything like that.

What's weird though - is that HPET makes any difference on these network
code paths.

Could we end up calling rcu too soon? I doubt we bring up ipv4 before
rcu..


