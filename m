From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Tue, 14 Dec 2004 01:56:01 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0412140143010.30724-100000@thoron.boston.redhat.com>
References: <1099288738.5070.71.camel@uganda>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <cryptoapi@lists.logix.cz>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <1099288738.5070.71.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Nov 2004, Evgeniy Polyakov wrote:

[Sorry for taking so long to get back to this].

> > c) Async engine: scheduling/batching/routing etc.
> > 
> > This seems to be the core of what you've developed so far.  I'm not sure 
> > if we need pluggable load balancers.  How would the sysadmin select the 
> > correct one?  The simpler this code is the better.
> 
> By following command:
> echo -en "simple_lb" > /sys/class/crypto_lb/lbs
> or by sending [still not implemented] connector's(netlink) command.

The real question was how would the sysadmin know which is the best load 
balancer to configure.  Start simple, make one good load balancer, and 
ponly create a pluggable framework only if a demonstratable need arises.

> > Overall I think it's a good start.  There are some chicken & egg type 
> > problems when you don't have GPL drivers, hardware or an existing async 
> > API, so I'd imagine that this will all continue to evolve:  with more 
> > hardware we can write/incorporate more drivers, with more drivers we can 
> > further refine the async support and API etc.
> 
> That is true, but I think not all parts of API should be exported as GPL
> only.

Why do you think this?


> > Here are some issues that I noticed:
> > 
> > 
> > What is main_crypto_device?  Is this a placeholder for when there are no 
> > other devices registered?
> 
> main_crypto_device is just virtual device into which all sessions are
> placed along with specific crypto device queue.
> it is usefull for cases when some driver decides that HW is broken and
> marks itself like not working, then scheduler _may_ (simple_lb does not
> have such feature) and actually _should_ move all sessions that are
> placed into broken device's queue into other devices or drop them(call
> callback with special session flag).

No reason to drop them, just fall back to software.

> > Async & sync drivers need to both be treated as crypto drivers.
> > 
> > 
> > static inline void crypto_route_free(struct crypto_route *rt)
> > {
> >         crypto_device_put(rt->dev);
> >         rt->dev = NULL;
> >         kfree(rt);
> > }
> > 
> > Why do you set rt->dev to NULL here?  It should not still be referenceable 
> > at this point.
> 
> crypto_route_free() can be called only from crypto_route_del() which
> unlinks given route thus noone can reference rt->dev(but of course
> asnyone can have it's private copy, obtained under the lock).
> Any route access is guarded by route list lock.

No, if you're about to kfree(rt), you cannot also be able to dereference 
it.

> > __crypto_route_del() etc:
> > 
> > Why are you rolling your own list management and not using the list.h 
> > functions?
> 
> It is more convenient here to use queue like sk_buf does.

Use list.h or put what you need into list.h.

> > +struct crypto_device_stat
> > +{
> > +       __u64                   scompleted;
> > +       __u64                   sfinished;
> > ...
> > 
> > Please see how networking stats are implemented (e.g. netif_rx_stats) and 
> > previous netdev discussions on 64-bit counters.  Please only use __u64 and 
> > similar when exporting structures to userspace.
> 
> I use __ prefix for any parameter that is exported to userspace.

But this structure is not.

> I've seen several attempts to convert network statistic to 64bit values,
> with backward compatibility it is not an easy task. Let's do not
> catch this again.

To clarifu: the best way to do this is to use per-cpu counters of unsigned
long and add them together in userspace.


- James
-- 
James Morris
<jmorris@redhat.com>
