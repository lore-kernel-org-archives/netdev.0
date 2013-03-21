From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: reduce net_rx_action() latency to 2 HZ
Date: Thu, 21 Mar 2013 10:43:14 -0700
Message-ID: <1363887794.4431.29.camel@edumazet-glaptop>
References: <1362503713.15793.121.camel@edumazet-glaptop>
	  <CAP=VYLrvXREA=HGnnUCi2N77yRdktQDop1PpzJkveXDihJ3DOw@mail.gmail.com>
	 <1363879647.4431.8.camel@edumazet-glaptop> <514B429C.5070605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Tom Herbert <therbert@google.com>,
	Steven Rostedt <rostedt@goodmis.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <514B429C.5070605@windriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-21 at 13:25 -0400, Paul Gortmaker wrote:

> That is also reasonably portable back to 2.6.34.  And it is more
> interesting too -- it will be interesting in a preempt_rt context
> too, once RT moves ahead off the current 3.6 baseline, which still
> has the old count-limit of 10 vs the new 2ms time limit.
> 
> RT (3.4 and 3.6 based) currently has this patch from Steven:
> http://git.kernel.org/cgit/linux/kernel/git/paulg/3.6-rt-patches.git/tree/net-tx-action-avoid-livelock-on-rt.patch

Interesting, as Google has an internal patch removing this trylock() as
well.

I think I should upstream it eventually ;)

commit 2f0a3f573b531dc57c268fd809dc65169edae369
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Dec 13 09:18:01 2012 -0800

    net-dev_xmit_hold_queues: fix a busy loop in net_tx_action
    
    Under load, net_tx_action() fails to acquire qdisc lock
    and reschedules qdisc in a never ending loop.
    
    The spin_trylock() has almost no chance to complete because
    of ticket spinlock and xmit_hold_queue holding the lock for long
    period of times.
    
