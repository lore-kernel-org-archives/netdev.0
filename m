From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 00:49:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330224902.GM3808@dualathlon.random>
References: <20040329222926.GF3808@dualathlon.random> <200403302005.AAA00466@yakov.inr.ac.ru> <20040330211450.GI3808@dualathlon.random> <20040330133000.098761e2.davem@redhat.com> <20040330213742.GL3808@dualathlon.random> <20040330142210.080dbe38.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, dipankar@in.ibm.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040330142210.080dbe38.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2004 at 02:22:10PM -0800, David S. Miller wrote:
> Otherwise, keep in mind what I said, and also as Robert mentioned every
> single local_bh_enable() is going to call do_softirq() if the count falls
> to zero.

I was less concerned about the do_sofitrq in local_bh_enable, since that
runs in a scheduler-aware context, so at least the timeslice is
definitely accounted for and it'll schedule at some point (unlike with
an hardirq flood). Actually the length of the default timeslice matters
too here, lowering the max timeslice to 10msec would certainly reduce
the effect.

call_rcu_bh will fix the local_bh_enable too. The only problem with
call_rcu_bh is how to queue the tasklets in every cpu (an IPI sounds
overkill at high frequency, because effectively here we're running the rcu
callbacks in a potential fast path).  OTOH if we've to add a spinlock to
queue the tasklet, then we might as well take a spinlock in the routing
cache in the first place (at least for this workload).
