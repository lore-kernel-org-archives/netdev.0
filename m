From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) replay netdev notifier events on registration
Date: Thu, 15 Jan 2004 00:42:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115004255.62dc8b95.davem@redhat.com>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
	<20040114164416.753a62fc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, chas@cmf.nrl.navy.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040114164416.753a62fc.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 16:44:16 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Possible problems:
> qeth: s390 driver -- bug, code is narcissistic and thinks it only gets
> 	notified about it's own devices.
> 
> atm/mpc: only looks for "lec" devices, don't know if they could exist
> 	before it starts.

These are both hard errors and potential bogus pointer derefences, they both
assume the type of dev->priv.  The atm/mpc case has a netdev->name==NULL
test which is a funny relic :-)

Both these cases ought to be fixed.  However, the atm/mpc case poses an issue,
how to identify "my" devices?  We've established that the textual name is
basically arbitrary and not a reliable key.  Currently I see only two
possible reliable solutions, but I like neither of them:

1) Device driver doing this needs to keep own list of net devices it
   has created.  Then it's notifiier code does something like:

	if (!find_in_mpoa_devlist(dev))
		return NOTIFY_DONE;

2) Add a type cookie or similar to the generic netdev, only devices
   which need to identify themselves in these generic kind of cases
   add identifier values there, so currently that would be MPOA and
   QETH, then the code goes:

	if (dev->type_cookie == NETDEV_TYPE_MPOA)
		return NOTIFY_DONE;

But as stated I think both of these ideas absolutely stink.

... wait...

Ok, I have an idea, consider this.  We add a netdev->notifier()
method.  We create a new routine to net/core/dev.c:

static void run_netdev_notifiers(int event, struct net_device *dev)
{
	notifier_call_chain(&netdev_chain, event, dev);

	if (dev->notifier)
		dev->notifier(dev, event);
}

Then replace all the notifier_call_chain(&netdev_chain, ...) calls
in net/core/dev.c with invocations of run_netdev_notifiers().

I believe we can (and thus should) add an ASSERT_RTNL() to this new
run_netdev_notifiers() functions, although I'm not %100 sure.

What do you think Stephen?

> Unrelated problems:
> ddp: registers for notifier before it is initialized

Just moving it down to the end of atalk_init() should fix this?
Actually, I don't really see any potential problem here.

> ipmr: no locking for add/delete

Not a problem, RTNL semaphore is held.

> ipfwadm: no module owner on /proc interface

Please elaborate.  I don't see the ipfwadm netdev event notifier
messing with procfs stuff, or is this happen at a level or two of
indirection somewhere else?

> The following are okay:

Thanks for the audit.
