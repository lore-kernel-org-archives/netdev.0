From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Wed, 30 Nov 2016 20:22:43 +0200
Message-ID: <20161130182243.cpoyoqvxuv2bnn4y@splinter.mtl.com>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
 <1480500546-2544-12-git-send-email-jiri@resnulli.us>
 <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
 <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
 <043a2ba9-1e19-c3cd-a930-59e8cb0d5f7a@stressinduktion.org>
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
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51501 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755971AbcK3SWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:22:46 -0500
Content-Disposition: inline
In-Reply-To: <043a2ba9-1e19-c3cd-a930-59e8cb0d5f7a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 05:49:56PM +0100, Hannes Frederic Sowa wrote:
> On 30.11.2016 17:32, Ido Schimmel wrote:
> > On Wed, Nov 30, 2016 at 04:37:48PM +0100, Hannes Frederic Sowa wrote:
> >> On 30.11.2016 11:09, Jiri Pirko wrote:
> >>> From: Ido Schimmel <idosch@mellanox.com>
> >>>
> >>> Make sure the device has a complete view of the FIB tables by invoking
> >>> their dump during module init.
> >>>
> >>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> >>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >>> ---
> >>>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 23 ++++++++++++++++++++++
> >>>  1 file changed, 23 insertions(+)
> >>>
> >>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>> index 14bed1d..d176047 100644
> >>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >>> @@ -2027,8 +2027,23 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
> >>>  	return NOTIFY_DONE;
> >>>  }
> >>>  
> >>> +static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
> >>> +{
> >>> +	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
> >>> +
> >>> +	/* Flush pending FIB notifications and then flush the device's
> >>> +	 * table before requesting another dump. Do that with RTNL held,
> >>> +	 * as FIB notification block is already registered.
> >>> +	 */
> >>> +	mlxsw_core_flush_owq();
> >>> +	rtnl_lock();
> >>> +	mlxsw_sp_router_fib_flush(mlxsw_sp);
> >>> +	rtnl_unlock();
> >>> +}
> >>> +
> >>>  int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
> >>>  {
> >>> +	fib_dump_cb_t *cb = mlxsw_sp_router_fib_dump_flush;
> >>>  	int err;
> >>>  
> >>>  	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
> >>> @@ -2048,8 +2063,16 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
> >>>  
> >>>  	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
> >>>  	register_fib_notifier(&mlxsw_sp->fib_nb);
> >>
> >> Sorry to pick in here again:
> >>
> >> There is a race here. You need to protect the registration of the fib
> >> notifier as well by the sequence counter. Updates here are not ordered
> >> in relation to this code below.
> > 
> > You mean updates that can be received after you registered the notifier
> > and until the dump started? I'm aware of that and that's OK. This
> > listener should be able to handle duplicates.
> 
> I am not concerned about duplicates, but about ordering deletes and
> getting an add from the RCU code you will add the node to hw while it is
> deleted in the software path. You probably will ignore the delete
> because nothing is installed in hw and later add the node which was
> actually deleted but just reordered which happend on another CPU, no?

Are you referring to reordering in the workqueue? We already covered
this using an ordered workqueue, which has one context of execution
system-wide.

> > I've a follow up patchset that introduces a new event in switchdev
> > notification chain called SWITCHDEV_SYNC, which is sent when port
> > netdevs are enslaved / released  from a master device (points in time
> > where kernel<->device can get out of sync). It will invoke
> > re-propagation of configuration from different parts of the stack
> > (e.g. bridge driver, 8021q driver, fib/neigh code), which can result
> > in duplicates.
> 
> Okay, understood. I wonder how we can protect against accidentally abort
> calls actually. E.g. if I start to inject routes into my routing domain
> how can I make sure the box doesn't die after I try to insert enough
> routes. Do we need to touch quagga etc?

The whole point of moving abort mechanism to the driver is that the
system won't die, but instead routing will be done in the kernel. If you
respect hardware limitations, then there's no reason for abort mechanism
to kick in.
