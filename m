From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: Kernel locking up in module
Date: Mon, 14 Jul 2003 17:28:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF7117350.353FDF6E-ON88256D64.00016172@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: N N Ashok <nalkunda@egr.msu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





> > but the variable is non-null every other time I insert the module.

Are you adding any new devices after the init() routine executes ? You
seem to have exited the for loop due to bwusage becoming NULL, not the
dev (while both should be null).

> You are not locking out the bottom half receive thread so it will
deadlock

Stephen, I don't understand how this is a deadlock ? His handler runs only
in the bottom half and he has no other code which runs in regular or hard
interrupt context. But you might want to try doing the mod_timer after
dropping
the lock to avoid a race (though not very likely ?). Unless it is
re-entrant,
which seems unlikely since he is using a 1 second timeout.

BTW, you are assigning 'data' in your routine, which is OK,
            unsigned long *data = (unsigned long *) ptr;
but if you reference it, that will crash the system since it is referring
to a local stack variable of another routine.

- KK



|---------+---------------------------->
|         |           N N Ashok        |
|         |           <nalkunda@egr.msu|
|         |           .edu>            |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           07/14/2003 04:35 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Stephen Hemminger <shemminger@osdl.org>                                                         |
  |       cc:       netdev@oss.sgi.com                                                                              |
  |       Subject:  Re: Kernel locking up in module                                                                 |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




On Monday 14 July 2003 18:49, Stephen Hemminger scrawled:
> On Mon, 14 Jul 2003 17:46:30 -0400
>
> N N Ashok <nalkunda@egr.msu.edu> wrote:
> > Hi All,
> >     I am creating a module to measure the outgoing bandwidth usage on
the
> > interfaces. It uses the get_stats() of the device to get the current
> > stats and then computes the bandwidth usage. The algorithm for the
usage
> > calculation are borrowed from iproute2 package (tc/tc_estimator.c). The
> > problem is that the kernel keeps locking up. I am using rwlock_t locks
to
> > lock the data. In the code, I traverse the list of bwuage structures
and
> > as a debug message am printing whether the traversal ended in the
> > variable becoming null (which it should if everything went right), but
> > the variable is non-null every other time I insert the module.
> >          printk(KERN_INFO "bwestimator: dev: %s. bwusage: %s.\n", dev ?
> > "non-null" : "null", bwusage ? "non-null" : "null");
> >
> >   I think this has got to do with some locking issues. As this is my
> > first go at the kernel locking, I might have used the wrong kind of
> > locks. I have attached the module source, header and the log messages
as
> > I inserted the module a couple of times. I request you all to please
help
> > me as I am totally lost here.
> >
> > Thanks,
> > Ashok
>
> You are not locking out the bottom half receive thread so it will
deadlock
> when it runs while your code holds the top half lock.

Hi Stephen,
Thanks for the reply.
Do I used write_lock_bh()/write_unlock_bh() for my lock (bwusage_head_lock)

while still using read_lock() for dev_base_lock ?

Thanks,
Ashok
