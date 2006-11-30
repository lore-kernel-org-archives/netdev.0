From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:17:58 +0100
Message-ID: <20061130061758.GA2003@elte.hu>
References: <2f14bf623344.456de60a@fnal.gov> <20061129.181950.31643130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wenji@fnal.gov, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757092AbWK3GTo@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061129.181950.31643130.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> We can make explicitl preemption checks in the main loop of 
> tcp_recvmsg(), and release the socket and run the backlog if 
> need_resched() is TRUE.
> 
> This is the simplest and most elegant solution to this problem.

yeah, i like this one. If the problem is "too long locked section", then
the most natural solution is to "break up the lock", not to "boost the 
priority of the lock-holding task" (which is what the proposed patch 
does).

[ Also note that "sprinkle the code with preempt_disable()" kind of
  solutions, besides hurting interactivity, are also a pain to resolve 
  in something like PREEMPT_RT. (unlike say a spinlock, 
  preempt_disable() is quite opaque in what data structure it protects, 
  etc., making it hard to convert it to a preemptible primitive) ]

> The one suggested in your patch and paper are way overkill, there is 
> no reason to solve a TCP specific problem inside of the generic 
> scheduler.

agreed.

What we could also add is a /reverse/ mechanism to the scheduler: a task 
could query whether it has just a small amount of time left in its 
timeslice, and could in that case voluntarily drop its current lock and 
yield, and thus give up its current timeslice and wait for a new, full 
timeslice, instead of being forcibly preempted due to lack of timeslices 
with a possibly critical lock still held.

But the suggested solution here, to "prolong the running of this task 
just a little bit longer" only starts a perpetual arms race between 
users of such a facility and other kernel subsystems. (besides not being 
adequate anyway, there can always be /so/ long lock-hold times that the 
scheduler would have no other option but to preempt the task)

	Ingo
