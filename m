From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [Xen-devel] [PATCH 4/4] [Net] Support accelerated network
	plugin modules
Date: Mon, 18 Jun 2007 16:31:59 +0100
Message-ID: <1182180720.4116.46.camel@moonstone.uk.level5networks.com>
References: <1181904393.4121.55.camel@moonstone.uk.level5networks.com>
	 <4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
	 <1181924563.4121.94.camel@moonstone.uk.level5networks.com>
	 <4e777ed10706151103w35ae4acv149d82aba0b59775@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Zhu Han <schumi.han@gmail.com>, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:31801 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763614AbXFRPcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 11:32:09 -0400
In-Reply-To: <4e777ed10706151103w35ae4acv149d82aba0b59775@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-15 at 14:03 -0400, Zhu Han wrote:
> On 6/15/07, Kieran Mansley <kmansley@solarflare.com> wrote:
> >
> > The lock protects the use_count variable.  The use_count variable
> > prevents the plugin module unloading while it is being used.  I couldn't
> > just use the lock to prevent the module unloading as the hook function
> > (i) might block (and holding a spin_lock would be rather antisocial)
> > (ii) might call back into netfront and try to take the lock again, which
> > would deadlock.
> >
> 
> If the hook routine blocks on the other code path instead of tx/rx
> path,  why not use a simple atomic reference count. When the reference
> count reachs zero, free it. Considering you can synchronzie on tx/rx
> path, the free will not happen under the critical code path. So the
> uninitialize work could be done inside the free routine even if it
> blocks.

Switching to atomics could be of benefit.  This would make the
hooks_usecount a kref, and due to the third rule of krefs (from the kref
docs) we'd still need synchronisation around most of the kref_get calls,
but as in some of the cases we have this lock for the list access
already, I'm guessing that would be OK.  I can prepare another version
of the patches with this change, as I'm currently making a number of
other changes as suggested by Keir.

I suspect that some would still prefer a full switch to using RCU
however.  I hope you don't mind me following up to all the locking-
related questions in this one email.  The use of RCU seems to centre
around whether or not the hooks functions can (or indeed should) block,
and whether it will result in a useful increase in performance.  I've
taken another look at RCU today to see if I could make it work.

The reason for hooks blocking is not well defined as there is only one
implementation of an accelerator, and so I'm not sure what other
accelerator modules might do.  However, the one we've written makes use
of xenbus during a number of the callbacks, and I suspect this is likely
to be pretty common.  Many xenbus calls can block.  For example, during
the probe hook call, it accesses xenstore to gather information from the
backend.  During a suspend or resume hook call, it may need to do things
such as unregister or register a xenbus watch.  These are just examples
rather than a definitive list.

If RCU is the way to go, these calls would all have to be made non-
blocking, by for example using a work queue to perform the blocking work
later.  This would be OK, but would need an additional few functions on
the interface between netfront and the accelerator, and complicate
netfront a little more.  For example, the accelerator's suspend hook
returning would no longer signify that the plugin had completed it's
suspended-related work, so netfront would have to wait for a
"suspend_done" call from the plugin before it could itself return.  In
these cases the total locking overhead is likely to be similar to the
current case, while the code would have become more complex.

None of this would affect the data path locking overhead (which is
already zero by design).  One thing I note from looking into RCU is that
the call_rcu callback function may be invoked from bottom-half context.
To give us the zero-additional-locking-overhead-on-the-data-path-
property that the current approach has, we call the following when
trying to disable the hooks:
                netif_poll_disable(vif_state->np->netdev);
                netif_tx_lock_bh(vif_state->np->netdev);
As both of these can block and so are not suitable for bottom-half
execution we'd either have to find an alternative (e.g. use RCU on the
data path, which would clearly increase the locking overhead) or defer
this work to another context, which would again complicate matters.

In all I feel that RCU is not the right solution here: I can see it
resulting in more code, harder to write plugins and little benefit as
the data path performance would (at best) not be affected.  

Perhaps a good way forward is for me to produce another iteration of the
patches using atomics/kref in place of the hooks_usecount and fewer
spin_locks as described at the start, and then see if that is
acceptable.

Thanks for taking the time to look at the patches,

Kieran

