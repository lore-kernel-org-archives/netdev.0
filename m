From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 11/17] ipv6: fib: Allow non-FIB users to take
 reference on route
Date: Wed, 19 Jul 2017 19:17:27 +0300
Message-ID: <20170719161727.GC6078@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-12-jiri@resnulli.us>
 <606f31c5-c5f9-193a-9527-6e47f827dd75@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20051.outbound.protection.outlook.com ([40.107.2.51]:27296
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932080AbdGSQRh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 12:17:37 -0400
Content-Disposition: inline
In-Reply-To: <606f31c5-c5f9-193a-9527-6e47f827dd75@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 09:49:37AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > Listeners of the FIB notification chain are expected to be able to take
> > and release a reference on notified IPv6 routes. This is needed in the
> > case of drivers capable of offloading these routes to a capable device.
> > 
> > Since notifications are sent in an atomic context, these drivers need to
> > take a reference on the route, prepare a work item to offload the route
> > and release the reference at the end of the work.
> > 
> > Currently, rt6i_ref is used to indicate in how many FIB nodes a route
> > appears. Different code paths rely on rt6i_ref being 0 to indicate the
> > route is no longer used by the FIB.
> > 
> > For example, whenever a route is deleted or replaced, fib6_purge_rt() is
> > run to make sure the route is no longer present in intermediate nodes. A
> > BUG_ON() at the end of the function is executed in case the reference
> > count isn't 1, as it's only supposed to appear in the non-intermediate
> > node from which it's going to be deleted.
> > 
> > Instead of changing the semantics of rt6i_ref, a new reference count is
> > added, so that external users could also take a reference on routes
> > without modifying rt6i_ref.
> > 
> > To make sure external users don't release routes used by the FIB, the
> > reference count is set to 1 upon creation of a route and decremented by
> > the FIB upon rt6_release().
> > 
> > The reference count is atomic, as it's not protected by any locks and
> > placed in the 40 bytes hole after the existing rt6i_ref.
> 
> I'd rather not add another reference counter. Debugging reference leaks
> is a huge PITA now; adding another counter just makes it worse.
> 
> Why can't the BUG_ON in fib6_purge_rt be removed since there are other
> reference holders now?

I did exactly that in the beginning, but it didn't sit right with me for
the exact reason you mentioned - it can be a PITA to debug.

If we use rt6i_ref for something other than FIB references, then it
breaks existing code that relies on rt6i_ref being 0 to indicate it's
no longer used by the FIB. A non-zero value can now mean "not used by
the FIB, but waiting for some module to drop the reference in its
workqueue".

The BUG_ON() mentioned in the commit message is just one example.
Another check was added by you in commit 8048ced9b.

So I think we both want the same thing, but I'm not sure how your
approach is safer.

Thanks
