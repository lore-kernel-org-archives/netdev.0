From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: factorize rt_do_flush for batch device unregistering
Date: Tue, 17 Nov 2009 00:03:44 +0200
Message-ID: <200911170003.44099.opurdila@ixiacom.com>
References: <200911162308.59730.opurdila@ixiacom.com> <4B01C507.9050908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9023 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752978AbZKPWGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:06:45 -0500
In-Reply-To: <4B01C507.9050908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 16 November 2009 23:32:55 you wrote:

> > @@ -5374,6 +5395,9 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
> >   *	unregister_netdevice_many - unregister many devices
> >   *	@head: list of devices
> >   *
> > + *	WARNING: This function modifies the list. It may change the order of
> > the + *	elements in the list. However, you can assume it does not add or
> > delete + *	elements to/from the list.
> 
> Sorry I dont understand this comment
> 

The  list passed to unregister_netdevice_many(), as the "head" parameter, may 
be altered, e.g. order may change between the elements.

That is because we temporarily move the items from the list to the 
rt_flush_list for the flush. When we add the items back they may not be added in 
the same place.

Perhaps the confusion comes from the fact that I did not specified which list? 
(i.e. head)

> > @@ -937,7 +937,10 @@ static int fib_netdev_event(struct notifier_block
> > *this, unsigned long event, vo struct in_device *in_dev =
> > __in_dev_get_rtnl(dev);
> >
> >  	if (event == NETDEV_UNREGISTER) {
> > -		fib_disable_ip(dev, 2);
> > +		/* if this event is part of a batch then don't flush the cache
> > +		 * now; we will receive another event at the end of the batch */
> > +		int rt_flush = list_empty(&dev->unreg_list) ? 0 : -1;
> 
> hmm... a bit ugly...
> 

Would it be better if I would add a dev_is_batch_unregister()  instead?

Or add a new device flag to explicitly signal the batch unregister?


> > +		fib_disable_ip(dev, 2, rt_flush);
> >  		return NOTIFY_DONE;
> >  	}
> >
> > @@ -955,7 +958,7 @@ static int fib_netdev_event(struct notifier_block
> > *this, unsigned long event, vo rt_cache_flush(dev_net(dev), -1);
> >  		break;
> >  	case NETDEV_DOWN:
> > -		fib_disable_ip(dev, 0);
> > +		fib_disable_ip(dev, 0, 0);
> >  		break;
> >  	case NETDEV_CHANGEMTU:
> >  	case NETDEV_CHANGE:
> 
> Are you sure you want to overload NETDEV_UNREGISTER ?
> 
> Maybe it would be cleaner to add a new value, NETDEV_UNREGISTER_PERNET or
>  something for the final loop...
> 

Hmm, I think that will allow us to get rid of the ugly test: never flush the 
cache for NETDEV_UNREGISTER, only flush it for NETDEV_UNREGISTER_PERNET. 

We just need to make sure to add NETDEV_UNREGISTER_PERNET in other places 
where NETDEV_UNREGISTER is called.

I'll try this in the next patch. Thanks for reviewing.

