From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 10/10] mlxsw: spectrum_router: Don't abort on
 l3mdev rules
Date: Mon, 13 Mar 2017 17:22:25 +0200
Message-ID: <20170313152225.GA8034@splinter.mtl.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-10-git-send-email-jiri@resnulli.us>
 <7ba7c3ca-f9ba-0ee1-7b56-f139bc4e1fc4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55473 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750992AbdCMPW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:22:28 -0400
Content-Disposition: inline
In-Reply-To: <7ba7c3ca-f9ba-0ee1-7b56-f139bc4e1fc4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 08:59:11AM -0600, David Ahern wrote:
> On 3/13/17 1:38 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > Now that port netdevs can be enslaved to a VRF master we need to make
> > sure the device's routing tables won't be flushed upon the insertion of
> > a l3mdev rule.
> > 
> > Note that we assume the notified l3mdev rule is a simple rule as used by
> > the VRF master. We don't check for the presence of other selectors such
> > as 'iif' and 'oif'.
> > 
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> > index de54382..fa73ee2 100644
> > --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> > +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> > @@ -2552,7 +2552,8 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
> >  		break;
> >  	case FIB_EVENT_RULE_ADD: /* fall through */
> >  	case FIB_EVENT_RULE_DEL:
> > -		if (!fib_work->fr_info.rule->def)
> > +		if (!fib_work->fr_info.rule->def &&
> > +		    !fib_work->fr_info.rule->l3mdev)
> >  			mlxsw_sp_router_fib4_abort(mlxsw_sp);
> >  		fib_rule_put(fib_work->fr_info.rule);
> >  		break;
> > 
> 
> You do not want to abort if the default rules are re-ordered. For
> example, the rule for the local table is moved from priority 0 to just
> before the main. ie., from this order:

Are you aware of configurations employing the VRF device and leaving the
rule for the local table at priority 0?

> 
> $ ip ru ls
> 0:	from all lookup local
> 32766:	from all lookup main
> 32767:	from all lookup default
> 
> to this order
> $ ip ru ls
> 1000:	from all lookup [l3mdev-table]
> 32765:	from all lookup local
> 32766:	from all lookup main
> 32767:	from all lookup default
> 
> should not abort offloads.
> 
> The default flag added to rules in patch 1 is not really needed; you can
> key off basic references to hardcoded table ids: RT_TABLE_MAIN and
> RT_TABLE_LOCAL are set in stone. Simple rules (from all lookup X) where
> only the priority changes should be enough information to not abort.

OK. Will look into that. I didn't like having the local rule first, so
this might the solution.

> In addition, if rules are added that reference oif or iif that is not a
> port netdev for this h/w then why abort offloads? e.g, consider PBR
> rules related to the management interface.

I'm aware, but not sure this belongs in this patchset. I prefer to deal
with the l3mdev rule and re-ordering of the default rules first, then
move to more advanced use cases.

Thanks David.
