From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Fri, 2 Dec 2016 01:14:45 +0200
Message-ID: <20161201231445.vtx7mjxuxusar3mu@splinter>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
 <1480500546-2544-12-git-send-email-jiri@resnulli.us>
 <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
 <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
 <043a2ba9-1e19-c3cd-a930-59e8cb0d5f7a@stressinduktion.org>
 <20161130182243.cpoyoqvxuv2bnn4y@splinter.mtl.com>
 <ea2a8856-59d8-1b5f-9428-b16efa8f6979@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34603 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753350AbcLAXPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:15:11 -0500
Content-Disposition: inline
In-Reply-To: <ea2a8856-59d8-1b5f-9428-b16efa8f6979@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 10:57:52PM +0100, Hannes Frederic Sowa wrote:
> On 30.11.2016 19:22, Ido Schimmel wrote:
> > On Wed, Nov 30, 2016 at 05:49:56PM +0100, Hannes Frederic Sowa wrote:
> >> On 30.11.2016 17:32, Ido Schimmel wrote:
> >>> On Wed, Nov 30, 2016 at 04:37:48PM +0100, Hannes Frederic Sowa wrote:
> >>>> On 30.11.2016 11:09, Jiri Pirko wrote:
> >>>>> From: Ido Schimmel <idosch@mellanox.com>
> >>>>>
> >>>>> Make sure the device has a complete view of the FIB tables by invoking
> >>>>> their dump during module init.
> >>>>>
> >>>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> >>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >>>>> ---
> >>>>>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 23 ++++++++++++++++++++++
> >>>>>  1 file changed, 23 insertions(+)
> >>>>>
> >>>>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>>>> index 14bed1d..d176047 100644
> >>>>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>>>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>>>> @@ -2027,8 +2027,23 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
> >>>>>  	return NOTIFY_DONE;
> >>>>>  }
> >>>>>  
> >>>>> +static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
> >>>>> +{
> >>>>> +	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
> >>>>> +
> >>>>> +	/* Flush pending FIB notifications and then flush the device's
> >>>>> +	 * table before requesting another dump. Do that with RTNL held,
> >>>>> +	 * as FIB notification block is already registered.
> >>>>> +	 */
> >>>>> +	mlxsw_core_flush_owq();
> >>>>> +	rtnl_lock();
> >>>>> +	mlxsw_sp_router_fib_flush(mlxsw_sp);
> >>>>> +	rtnl_unlock();
> >>>>> +}
> >>>>> +
> >>>>>  int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
> >>>>>  {
> >>>>> +	fib_dump_cb_t *cb = mlxsw_sp_router_fib_dump_flush;
> >>>>>  	int err;
> >>>>>  
> >>>>>  	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
> >>>>> @@ -2048,8 +2063,16 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
> >>>>>  
> >>>>>  	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
> >>>>>  	register_fib_notifier(&mlxsw_sp->fib_nb);
> >>>>
> >>>> Sorry to pick in here again:
> >>>>
> >>>> There is a race here. You need to protect the registration of the fib
> >>>> notifier as well by the sequence counter. Updates here are not ordered
> >>>> in relation to this code below.
> >>>
> >>> You mean updates that can be received after you registered the notifier
> >>> and until the dump started? I'm aware of that and that's OK. This
> >>> listener should be able to handle duplicates.
> >>
> >> I am not concerned about duplicates, but about ordering deletes and
> >> getting an add from the RCU code you will add the node to hw while it is
> >> deleted in the software path. You probably will ignore the delete
> >> because nothing is installed in hw and later add the node which was
> >> actually deleted but just reordered which happend on another CPU, no?
> > 
> > Are you referring to reordering in the workqueue? We already covered
> > this using an ordered workqueue, which has one context of execution
> > system-wide.
> 
> Ups, sorry, I missed that mail. Probably read it on the mobile phone and
> it became invisible for me later on. Busy day... ;)

Yet another reason not to read emails on your phone ;)

> The reordering in the workqueue seems fine to me and also still necessary.

Correct.

> Basically, if you delete a node right now the kernel might simply do a
> RCU_INIT_POINTER(ptr_location, NULL), which has absolutely no barriers
> or synchronization with the reader side. Thus you might get a callback
> from the notifier for a delete event on the one CPU and you end up
> queueing this fib entry after the delete queue, because the RCU walk
> isn't protected by any means.
> 
> Looking closer at this series again, I overlooked the fact that you
> fetch fib_seq using a rtnl_lock and rtnl_unlock pair, which first of all
> orders fetching of fib_seq and thus the RCU dumping after any concurrent
> executing fib table update, also the mutex_lock and unlock provide
> proper acquire and release fences, so the CPU indeed sees the effect of
> a RCU_INIT_POINTER update done on another CPU, because they pair with
> the rtnl_unlock which might happen on the other CPU.

Yep, Exactly. I had a feeling this is the issue you were referring to,
but then you were the one to suggest the use of RTNL, so I was quite
confused.

> My question is if this is a bit of luck and if we should make this
> explicit by putting the registration itself under the protection of the
> sequence counter. I favor the additional protection, e.g. if we some day
> actually we optimize the fib_seq code? Otherwise we might probably
> document this fact. :)

Well, some listeners don't require a dump, but only registration
(rocker) and in the future we might only need a dump (e.g., port being
moved to a different net namespace). So I'm not sure if bundling both
together is a good idea.

Maybe we can keep register_fib_notifier() as-is and add 'bool register'
to fib_notifier_dump() so that when set, 'nb' is also registered after
RCU walk, but before we check if the dump is consistent (unregistered if
inconsistent)?

> >>> I've a follow up patchset that introduces a new event in switchdev
> >>> notification chain called SWITCHDEV_SYNC, which is sent when port
> >>> netdevs are enslaved / released  from a master device (points in time
> >>> where kernel<->device can get out of sync). It will invoke
> >>> re-propagation of configuration from different parts of the stack
> >>> (e.g. bridge driver, 8021q driver, fib/neigh code), which can result
> >>> in duplicates.
> >>
> >> Okay, understood. I wonder how we can protect against accidentally abort
> >> calls actually. E.g. if I start to inject routes into my routing domain
> >> how can I make sure the box doesn't die after I try to insert enough
> >> routes. Do we need to touch quagga etc?
> > 
> > The whole point of moving abort mechanism to the driver is that the
> > system won't die, but instead routing will be done in the kernel. If you
> > respect hardware limitations, then there's no reason for abort mechanism
> > to kick in.
> 
> Quick follow-up question: How can I quickly find out the hw limitations
> via the kernel api?

That's a good question. Currently, you can't. However, we already have a
mechanism in place to read device's capabilities from the firmware and
we can (and should) expose some of them to the user. The best API for
that would be devlink, as it can represent the entire device as opposed
to only a port netdev like other tools.

We're also working on making the pipeline more visible to the user, so
that it would be easier for users to understand and debug their
networks. I believe a colleague of mine (Matty) presented this during
the last netdev conference.
