From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 17:11:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330151148.GX3808@dualathlon.random>
References: <20040329184550.GA4540@in.ibm.com> <20040329222926.GF3808@dualathlon.random> <20040330050614.GA4669@in.ibm.com> <20040330053515.GA4815@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dipankar Sarma <dipankar@in.ibm.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>,
        rusty@au1.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srivatsa Vaddagiri <vatsa@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040330053515.GA4815@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2004 at 11:05:15AM +0530, Srivatsa Vaddagiri wrote:
> On Tue, Mar 30, 2004 at 10:36:14AM +0530, Srivatsa Vaddagiri wrote:
> > kthread_stop does:
> > 
> > 	1. kthread_stop_info.k = k;
> >         2. wake_up_process(k);
> > 
> > and if ksoftirqd were to do :
> > 
> > 	a. while (!kthread_should_stop()) {
> >         b.         __set_current_state(TASK_INTERRUPTIBLE);
> >         c.         schedule();
> >            }
> > 
> > 
> > There is a (narrow) possibility here that a) happens _after_ 1) as well as 
> > b) _after_ 2).
> 
> hmm .. I meant a) happening _before_ 1) and b) happening _after_ 2) ..
> 
> > 
> >         a. __set_current_state(TASK_INTERRUPTIBLE);
> > 	b. while (!kthread_should_stop()) {
> >         c.         schedule();
> >         d.         __set_current_state(TASK_INTERRUPTIBLE);
> >            }
> > 
> >         e. __set_current_state(TASK_RUNNING);
> > 
> > In this case, even if b) happens _after_ 1) and c) _after_ 2), 
> 
> Again I meant "even if b) happens _before_ 1) and c) _after_ 2) !!
> 
> > schedule simply returns immediately because task's state would have been set 
> > to TASK_RUNNING by 2). It goes back to the kthread_should_stop() check and 
> > exits!

you're right, I had a private email exchange with Andrew about this
yesterday, he promptly pointed it out too. But my point is that the
previous code was broken too, it wasn't me breaking the code, I only
simplified already broken code instead of fixing it for real. His tree
should get the proper fixes soon. All those __ in front of the
set_current_state in that function made the ordering worthless and
that's why I cleaned them up.

The softirq part in the patch however is orthogonal to the above races,
so I didn't post an update since it didn't impact testing.
