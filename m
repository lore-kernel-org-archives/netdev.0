From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 1 Apr 2004 10:43:45 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404010643.KAA08190@yakov.inr.ac.ru>
References: <20040331225259.GT2143@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se (Robert Olsson),
        dipankar@in.ibm.com (Dipankar Sarma),
        davem@redhat.com (David S. Miller), kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andrea@suse.de (Andrea Arcangeli)
In-Reply-To: <20040331225259.GT2143@dualathlon.random> from "Andrea Arcangeli" at Apr 01, 2004 12:52:59 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I didn't focus much on the irq count, but now that I look at it, it
> looks like the biggest source of softirq in irq context is the timer
> irq, not the network irq. That explains the problem and why NAPI
> couldn't avoid the softirq load in irq context, NAPI avoids the network
> irqs, but the softirqs keeps running in irq context.
> 
> So lowering HZ to 100 should mitigate the problem significantly.

Plus local_bh_enable(), which was actually the first source discovered
by Robert year ago. It does not contribute now, but Robert could turn it on
starting some non-trivial process context workload.

We have lots of places where we do local_bh_disable/enable() several times
in row and each of them triggers full do_softirq() run without schedule()
in between. See?

The thing which I want to say is: source of do_softirq() does not matter.
All of them happening outside of ksoftirqd are equally bad, unaccountable,
uncontrollable and will show up in some situation.

What's about some accounting do_softirq() in some way as a starting point?
F.e. one way is to account all timer ticks happened while do_softirq()
to ksoftirqd instead of current process (I am not sure that this is even
possible without race conditions). Or something like that.

Alexey
