From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Fri, 08 Apr 2005 13:58:43 -0700
Message-ID: <200504082059.j38KwhaG009173@death.nxdomain.ibm.com>
References: <herbert@gondor.apana.org.au>
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: Message from Herbert Xu <herbert@gondor.apana.org.au>
   of "Fri, 08 Apr 2005 22:36:28 +1000." <E1DJsiq-0006xJ-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
[...]
>However, this is a bit of an eye sore as it is the only place
>where rtmsg_ifinfo is called from softirq context.  In fact,
>this is probably the only place where CHANGEADDR (and perhaps
>even call_netdevice_notifiers) is called from softirq context.

	I looked as well, and didn't find anywhere else doing the netdev
related notifiers from softirq.  

[...]
>Nevertheless, I'd like to ask the possibility for bond to not do
>this from softirq context.
>
>I looked at bond_alb.c briefly and it appears that the MAC addresses
>aren't actually set from the timers.  It is however set in user
>context with spin locks held to guard against the timer.

	There are several paths from a timer context, e.g.,

timer -> bond_mii_monitor -> bond_change_active_slave ->
bond_alb_handle_active_change -> alb_set_slave_mac_addr

	There are also calls that go through bond_select_active_slave
(then on to bond_change_active_slave).  In all of these cases, the path
is taken when a link failure is detected.

	Running the timers function from a work queue instead (to get a
sleepable context) is technically possible.  I'm not sure how much
overhead that would add (given that the link monitor timer typically
runs on intervals in the 10 - 50 ms range).  Getting the locks out is a
little trickier; I've only looked at it briefly and don't see a simple
way to do it.  Well, at least that isn't, shall we say, less than
elegant: e.g., a work queue out of line call that just changes the MAC
address.  I'm not sure what extra delay that kind of scheme would add to
the failover time for the link.

>I looked at one of those places: alb_handle_addr_collision_on_attach.
>As far as I can see, there is no need for the address change to occur
>under the write_lock.

	That case, yes, could be rearranged to do the assignment outside
the lock without too much pain.

>So if you have time, could you please comb through the bonding driver
>and let us know if it is possible to move the setting of the MAC
>address outside atomic areas.

	As I said above, the timer case doesn't have an obviously good
way to change it to do the MAC sets in a sleepable context with no
locks.  I also wonder how expensive it is to run work queue events every
10ms as compared to running timer events every 10ms?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
