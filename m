From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) replay netdev notifier events on registration
Date: Thu, 15 Jan 2004 11:51:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115115158.4c78e2ae.davem@redhat.com>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
	<20040114164416.753a62fc.shemminger@osdl.org>
	<20040115004255.62dc8b95.davem@redhat.com>
	<20040115101617.0782fcca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, chas@cmf.nrl.navy.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040115101617.0782fcca.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004 10:16:17 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Thu, 15 Jan 2004 00:42:55 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > Ok, I have an idea, consider this.  We add a netdev->notifier()
> > method.  We create a new routine to net/core/dev.c:
> > 
> > static void run_netdev_notifiers(int event, struct net_device *dev)
> > {
> > 	notifier_call_chain(&netdev_chain, event, dev);
> > 
> > 	if (dev->notifier)
> > 		dev->notifier(dev, event);
> > }
> > 
> > Then replace all the notifier_call_chain(&netdev_chain, ...) calls
> > in net/core/dev.c with invocations of run_netdev_notifiers().
> > 
> > I believe we can (and thus should) add an ASSERT_RTNL() to this new
> > run_netdev_notifiers() functions, although I'm not %100 sure.
> > 
> > What do you think Stephen?
> 
> Feeling stupid this morning, how wold this help?  Would device set
> dev->notifier and not register for other notifications?

That's correct.  This eliminates the "am I a type FOO device", because
this netdev->notifier() call would be implication only run on the correct
device types.

> Rather than a single notifier why not add a dev->notify_chain and
> do:
> 	notifier_call_chain(&netdev_chain, event, dev);
> 	notifier_call_chain(dev->notify_chain, event, dev);
> 
> But the whole programming model of responding to callbacks seems bassackwards
> in these cases, because the device can process the same events (up/down)
> on the front side (open/close) rather than getting callbacks.  At least in the
> qeth case it seems like a messed up design.  

qeth is a mess period, it tries to be overly clever because of the things it is
trying to achieve and as a result it's an abominable piece of complexity.

I don't see how a "dev->notify_chain" like scheme could work...
Oh I see, this way the driver can register multiple private device-type specific
notifiers.  Yes, this looks like a fine way to do this too.

But really, the driver too could do all of it's "notifiers" in the one dev->notifier()
method.

I'm not overly picky about using one scheme over another.
