From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v2 10/11] mlxsw: spectrum_router: Request a dump of
 FIB tables during init
Date: Wed, 23 Nov 2016 17:59:05 +0100
Message-ID: <1479920345.4035504.797158425.2C10AA0C@webmail.messagingengine.com>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479912528-4636-1-git-send-email-jiri@resnulli.us>
 <1479916800.4019894.797128001.743EBB6A@webmail.messagingengine.com>
 <20161123160453.GB1873@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41979 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933142AbcKWQ7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:59:06 -0500
In-Reply-To: <20161123160453.GB1873@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016, at 17:04, Jiri Pirko wrote:
> Wed, Nov 23, 2016 at 05:00:00PM CET, hannes@stressinduktion.org wrote:
> >On Wed, Nov 23, 2016, at 15:48, Jiri Pirko wrote:
> >> From: Ido Schimmel <idosch@mellanox.com>
> >> 
> >> Make sure the device has a complete view of the FIB tables by invoking
> >> their dump during module init.
> >> 
> >> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >> ---
> >>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16
> >>  ++++++++++++++++
> >>  1 file changed, 16 insertions(+)
> >> 
> >> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >> b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >> index 14bed1d..36a71d2 100644
> >> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> >> @@ -2027,6 +2027,21 @@ static int mlxsw_sp_router_fib_event(struct
> >> notifier_block *nb,
> >>  	return NOTIFY_DONE;
> >>  }
> >>  
> >> +static void mlxsw_sp_router_fib_dump(struct mlxsw_sp *mlxsw_sp)
> >> +{
> >> +       while (!fib_notifier_dump(&mlxsw_sp->fib_nb)) {
> >> +               /* Flush pending FIB notifications and then flush the
> >> +                * device's table before requesting another dump. Do
> >> +                * that with RTNL held, as FIB notification block is
> >> +                * already registered.
> >> +                */
> >> +               mlxsw_core_flush_owq();
> >> +               rtnl_lock();
> >> +               mlxsw_sp_router_fib_flush(mlxsw_sp);
> >> +               rtnl_unlock();
> >> +       }
> >> +}
> >
> >I think it is fine to use this kind of synchronization.
> >
> >But I think that this part of the logic still belongs into the core
> 
> Core does not know how driver handles the offloaded fibs. So only driver
> knows how/if he needs to do flush in case of retry.

Sure, but an abort function can be provided to the kernel anyway and the
driver can care about that.

> >kernel. I still think it could happen that we will loop here
> >indefinitely because of a lot of routing updates and as such would need
> >to abort this loop after a number of tries.
> 
> In theory, it is possible, howevery quite unlikely.

I think the "quite unlikely" already got us down the path to not using
rtnl_lock in the first place.

As I said, I am not sure about this as I didn't try any hardware
offloading before and delays how long it needs to be transferred to
hardware, but having a fail case for that seems like a nice improvement.
At the same time I know of Linux boxes running in internet exchanges
having several peers. The high update rates actually led to bgp
implementation specifying flap damping which is actually nowadays
considered harmful.

Seriously, while most of the time convergence in routing protocols is
good and most updates only hit the BGP user space table anyway and the
change is suppressed because recursive routing lookup idempotence, quite
unlikely events happen to the internet now and then:
http://research.dyn.com/2009/02/longer-is-not-better/, which caused *a
lot* of flapping and ongoing events on BGP routers throughout the world.

I agree it is unlikely that you have to refresh your hw dump during this
time, but who knows what customers do and what admins do in case
something like this happens. I just don't favor to looping endlessly
trying to sync up and getting into a stable state but tell the admin to
detach the control plane from the forwarding plane and sync up then.

That said, I think a sysctl for a maximum number of loops respected by
drivers that needs to do so, should be enough for the time being.

Bye,
Hannes
