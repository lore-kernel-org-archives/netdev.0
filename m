From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 3/4] [Net] Support Xen accelerated network plugin
	modules
Date: Tue, 22 May 2007 08:15:08 +0100
Message-ID: <1179818108.4145.18.camel@moonstone.uk.level5networks.com>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
	 <20070521105258.7988fd6e@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com, herbert@gondor.apana.org.au
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:7078 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754954AbXEVHPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 03:15:14 -0400
In-Reply-To: <20070521105258.7988fd6e@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-21 at 10:52 -0700, Stephen Hemminger wrote:
> On Fri, 18 May 2007 14:16:48 +0100
> Kieran Mansley <kmansley@solarflare.com> wrote:
> 
> > Add support to Xen netfront for accelerated plugin module
> > 
> >
> > 
> > +/*
> > + * List of all netfront accelerator plugin modules available.  Each
> > + * list entry is of type struct netfront_accelerator.
> > + */ 
> > +static struct list_head accelerators_list;
> > +/*
> > + * Lock to protect access to accelerators_list, and also used to
> > + * protect the hooks_usecount field in struct netfront_accelerator
> > + * against concurrent access 
> > + */
> > +static spinlock_t accelerators_lock;
> > +
> 
> 
> Your locking model is more complex than it needs to be.
> If you just used RCU for access, and depended on the existing RT netlink
> mutex (a.k.a big network lock), for setup; then you wouldn't need to
> do any of your own locking.

The complexity arises from the requirement to not take additional locks
on the data path, and not hold a lock during the calls from netfront
into the accelerated plugin.  The lock and ref count aren't really
providing mutual exclusion, but ensuring the function pointers persist
and are consistent while they're in use.  RCU on its own wouldn't
prevent the accelerated plugin being unloaded while netfront was using
one of the hooks.  Wrapping each one of these calls with the big network
lock would be OK, but then we'd be holding locks while calling into the
hooks.

I could remove the lock and ref count as you suggest if I increased the
plugin module's use count to prevent it being unloaded, but then we'd
need some mechanism to signal that a network interface should no longer
be accelerated so that the hooks can be removed, module use count
decreased, and module safely unloaded.

This is something I'm happy to change if necessary, but I thought I
should explain why it's complex before going ahead.  If you still think
it needs changing, then let me know.

Kieran

