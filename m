From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 1 Apr 2004 15:16:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401131657.GB18585@dualathlon.random>
References: <20040331225259.GT2143@dualathlon.random> <200404010643.KAA08190@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Dipankar Sarma <dipankar@in.ibm.com>,
        "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200404010643.KAA08190@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 01, 2004 at 10:43:45AM +0400, kuznet@ms2.inr.ac.ru wrote:
> What's about some accounting do_softirq() in some way as a starting point?
> F.e. one way is to account all timer ticks happened while do_softirq()
> to ksoftirqd instead of current process (I am not sure that this is even
> possible without race conditions). Or something like that.

This sounds reasonable. However as a start I was thinking at having
hardirq run only the softirq they posted actively, and local_bh_enable
run only the softirq that have been posted by the critical section (not
from hardirqs happening on top of it). And leave everything else for
ksoftirqd. this will complicate the bitmask setting and bitmask
management but it sounds doable.

This will still leave some unfariness under an irq driven flood (partly
a feature to provide as usual the lowest possible latency for stuff like
not busy routers where NAPI isn't needed) but at least it avoids hardirq
to overload excessively the task that happens to run with bh disabled
most of the time, and it will^Wshould allow NAPI to offload the softirq
to ksoftirqd completely.

comments?
