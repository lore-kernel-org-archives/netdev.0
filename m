From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 23:27:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330212735.GJ3808@dualathlon.random>
References: <20040329184550.GA4540@in.ibm.com> <20040329222926.GF3808@dualathlon.random> <20040330144324.GA3778@in.ibm.com> <20040330195315.GB3773@in.ibm.com> <20040330204731.GG3808@dualathlon.random> <20040330210648.GB3956@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dipankar Sarma <dipankar@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040330210648.GB3956@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 02:36:48AM +0530, Dipankar Sarma wrote:
> Not necessarily, we can do a call_rcu_bh() just for softirqs with 
> softirq handler completion as a quiescent state. That will likely
> help with the route cache overflow problem atleast.

cute, I like this. You're right all we care about is a quiscient point
against softirq context (this should work fine against regular kernel
context under local_bh_disable too).  This really sounds a smart and
optimal and finegriend solution to me.  The only thing I'm concerned
about is if it slowdown further the fast paths, but I can imagine that
you can implement it purerly with tasklets and no change to the fast
paths (I mean, I wouldn't enjoy further instrumentations like the stuff
you had to add to the scheduler especially in the preempt case). I mean,
you've just to run 1 magic takklet per cpu then you declare the
quiscient point. The only annoyance will be the queueing of these
tasklets in every cpu, that may need IPIs or some nasty locking. Of
course we should use the higher prio tasklets, so they run before the
other softirqs.

Is this the suggestion from Alexey or did he suggest something else? the
details of his suggestion weren't clear to me.

after call_rcu_bh everything else w.r.t. softirq/scheduler will return
low prio. I mean, the everything else will return a "irq load
(hardirq+softirq) runs on top of kernel context and they're not
accounted by the scheduler" like it has always been in the last thousand
kernel releases ;) that may need solving eventually, but still the
routing cache sounds optimal with the call_rcu_bh.
