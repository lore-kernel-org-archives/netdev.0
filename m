From: N N Ashok <nalkunda@egr.msu.edu>
Subject: Re: Kernel locking up in module
Date: Tue, 15 Jul 2003 21:28:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307152128.34341.nalkunda@egr.msu.edu>
References: <OFF7117350.353FDF6E-ON88256D64.00016172@us.ibm.com> <200307142031.15122.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <200307142031.15122.nalkunda@egr.msu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 14 July 2003 20:31, N N Ashok scrawled:
> On Monday 14 July 2003 20:28, Krishna Kumar scrawled:
> > > > but the variable is non-null every other time I insert the module.
> >
> > Are you adding any new devices after the init() routine executes ? You
> > seem to have exited the for loop due to bwusage becoming NULL, not the
> > dev (while both should be null).
>
> Hi,
>      I am not modifying the dev list in anyway. I am just accessing the
> list to get the stats for each device (get_stats()). And exactly as you
> said, the bwusage becomes NULL before dev,although there is a one-to-one
> correspondence between the list of dev and bwusage.
>
> > > You are not locking out the bottom half receive thread so it will
> >
> > deadlock
> >
> > Stephen, I don't understand how this is a deadlock ? His handler runs
> > only in the bottom half and he has no other code which runs in regular or
> > hard interrupt context. But you might want to try doing the mod_timer
> > after dropping
> > the lock to avoid a race (though not very likely ?). Unless it is
> > re-entrant,
> > which seems unlikely since he is using a 1 second timeout.
>
>      I did have mod_timer() after unlocking but then I thought maybe
> modifying the timer without locking it might cause some problem. So I put
> it within the locked code.
>
> > BTW, you are assigning 'data' in your routine, which is OK,
> >             unsigned long *data = (unsigned long *) ptr;
> > but if you reference it, that will crash the system since it is referring
> > to a local stack variable of another routine.
>
>      I had been using data in my routine earlier, I used it instead of the
> 'count' variable to limit the number of times the routine was executed. But
> again, thinking that might be the problem, I used a static variable in the
> routine.
>
>      After getting the replies, I tried to use spin_lock_bh() as well as
> write_lock_bh() to lock/unlock, but the routine still exists with the
> bwusage being NULL. Infact, it exits with bwusage being NULL every
> alternate time I insert the module. Might or might not be just a
> coincidence.
>
> Thanks again,
> Ashok
>
> > - KK
> >
> > On Monday 14 July 2003 18:49, Stephen Hemminger scrawled:
> > > On Mon, 14 Jul 2003 17:46:30 -0400
> > >
> > > N N Ashok <nalkunda@egr.msu.edu> wrote:
> > > > Hi All,
> > > >     I am creating a module to measure the outgoing bandwidth usage on
> >
> > the
> >
> > > > interfaces. It uses the get_stats() of the device to get the current
> > > > stats and then computes the bandwidth usage. The algorithm for the
> >
> > usage
> >
> > > > calculation are borrowed from iproute2 package (tc/tc_estimator.c).
> > > > The problem is that the kernel keeps locking up. I am using rwlock_t
> > > > locks
> >
> > to
> >
> > > > lock the data. In the code, I traverse the list of bwuage structures
> >
> > and
> >
> > > > as a debug message am printing whether the traversal ended in the
> > > > variable becoming null (which it should if everything went right),
> > > > but the variable is non-null every other time I insert the module.
> > > > printk(KERN_INFO "bwestimator: dev: %s. bwusage: %s.\n", dev ?
> > > > "non-null" : "null", bwusage ? "non-null" : "null");
> > > >
> > > >   I think this has got to do with some locking issues. As this is my
> > > > first go at the kernel locking, I might have used the wrong kind of
> > > > locks. I have attached the module source, header and the log messages
> >
> > as
> >
> > > > I inserted the module a couple of times. I request you all to please
> >
> > help
> >
> > > > me as I am totally lost here.
> > > >
> > > > Thanks,
> > > > Ashok
> > >
> > > You are not locking out the bottom half receive thread so it will
> >
> > deadlock
> >
> > > when it runs while your code holds the top half lock.

        From what I read in "Understanding the Linux Kernel", the timer 
routine that I setup is executed from the bottom half. Also in the book it 
says that data structures accessed in deferrable functions (which a bottom 
handler is I think), there is no need of any kind of locking/protection 
required for uniprocessor machines. Also it says that if we try to acquire a 
spin_lock on a uniprocessor in the kernel, then the kernel control path that 
does have the lock will not get a chance to release the lock and hence we 
will have a deadlock.
       In this context, I am unable to understand whether I should use locking 
and if so which kind. Do I need to disable the IRQs (_irq) when I take the 
lock? Or do I disable the bottom halves (_bh) ? Please help me in 
understanding and resolving the problem as it is required for my thesis.

Thanks and Regards,
Ashok
