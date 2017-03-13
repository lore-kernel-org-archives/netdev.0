From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 10/10] mlxsw: spectrum_router: Don't abort on
 l3mdev rules
Date: Mon, 13 Mar 2017 08:59:11 -0600
Message-ID: <7ba7c3ca-f9ba-0ee1-7b56-f139bc4e1fc4@cumulusnetworks.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35141 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752314AbdCMO7O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 10:59:14 -0400
Received: by mail-pg0-f41.google.com with SMTP id b129so64622662pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 07:59:13 -0700 (PDT)
In-Reply-To: <1489390713-2634-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 1:38 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Now that port netdevs can be enslaved to a VRF master we need to make
> sure the device's routing tables won't be flushed upon the insertion of
> a l3mdev rule.
> 
> Note that we assume the notified l3mdev rule is a simple rule as used by
> the VRF master. We don't check for the presence of other selectors such
> as 'iif' and 'oif'.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> index de54382..fa73ee2 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> @@ -2552,7 +2552,8 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
>  		break;
>  	case FIB_EVENT_RULE_ADD: /* fall through */
>  	case FIB_EVENT_RULE_DEL:
> -		if (!fib_work->fr_info.rule->def)
> +		if (!fib_work->fr_info.rule->def &&
> +		    !fib_work->fr_info.rule->l3mdev)
>  			mlxsw_sp_router_fib4_abort(mlxsw_sp);
>  		fib_rule_put(fib_work->fr_info.rule);
>  		break;
> 

You do not want to abort if the default rules are re-ordered. For
example, the rule for the local table is moved from priority 0 to just
before the main. ie., from this order:

$ ip ru ls
0:	from all lookup local
32766:	from all lookup main
32767:	from all lookup default

to this order
$ ip ru ls
1000:	from all lookup [l3mdev-table]
32765:	from all lookup local
32766:	from all lookup main
32767:	from all lookup default

should not abort offloads.

The default flag added to rules in patch 1 is not really needed; you can
key off basic references to hardcoded table ids: RT_TABLE_MAIN and
RT_TABLE_LOCAL are set in stone. Simple rules (from all lookup X) where
only the priority changes should be enough information to not abort.

In addition, if rules are added that reference oif or iif that is not a
port netdev for this h/w then why abort offloads? e.g, consider PBR
rules related to the management interface.
