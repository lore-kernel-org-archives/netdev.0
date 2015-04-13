From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 12:25:12 -0700
Message-ID: <552C1818.9090904@intel.com>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us> <1428934475-15349-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	f.fainelli@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28838 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416AbbDMTZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:14 -0400
In-Reply-To: <1428934475-15349-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 4/13/2015 7:14 AM, Jiri Pirko wrote:
> Turned out that "switchdev" sticks. So just unify all releated terms to
> use this prefix.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   drivers/net/bonding/bond_main.c      |   4 +-
>   drivers/net/ethernet/rocker/rocker.c |  10 +--
>   drivers/net/team/team.c              |   4 +-
>   include/net/switchdev.h              | 106 +++++++++++++--------------
>   net/bridge/br.c                      |  18 ++---
>   net/bridge/br_netlink.c              |   6 +-
>   net/bridge/br_stp.c                  |   2 +-
>   net/core/net-sysfs.c                 |   2 +-
>   net/core/rtnetlink.c                 |   2 +-
>   net/ipv4/fib_trie.c                  |  40 +++++------
>   net/switchdev/switchdev.c            | 134 +++++++++++++++++------------------
>   11 files changed, 161 insertions(+), 167 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 78dde56..e96f029 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4037,8 +4037,8 @@ static const struct net_device_ops bond_netdev_ops = {
>   	.ndo_add_slave		= bond_enslave,
>   	.ndo_del_slave		= bond_release,
>   	.ndo_fix_features	= bond_fix_features,
> -	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
> -	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
> +	.ndo_bridge_setlink	= ndo_dflt_switchdev_port_bridge_setlink,
> +	.ndo_bridge_dellink	= ndo_dflt_switchdev_port_bridge_dellink,
>   	.ndo_features_check	= passthru_features_check,
>   };
>   
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index a87b177..6d31aeb 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3377,17 +3377,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
>   		container_of(work, struct rocker_fdb_learn_work, work);
>   	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
>   	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
> -	struct netdev_switch_notifier_fdb_info info;
> +	struct switchdev_notifier_fdb_info info;
>   
>   	info.addr = lw->addr;
>   	info.vid = lw->vid;
>   
>   	if (learned && removing)
> -		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
> -					     lw->dev, &info.info);
> +		call_switchdev_notifiers(NETDEV_SWITCH_FDB_DEL,
> +					 lw->dev, &info.info);
>   	else if (learned && !removing)
> -		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_ADD,
> -					     lw->dev, &info.info);
> +		call_switchdev_notifiers(NETDEV_SWITCH_FDB_ADD,
> +					 lw->dev, &info.info);
>   
>   	kfree(work);
>   }
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 6928448..cfe8496 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1977,8 +1977,8 @@ static const struct net_device_ops team_netdev_ops = {
>   	.ndo_del_slave		= team_del_slave,
>   	.ndo_fix_features	= team_fix_features,
>   	.ndo_change_carrier     = team_change_carrier,
> -	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
> -	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
> +	.ndo_bridge_setlink     = ndo_dflt_switchdev_port_bridge_setlink,
> +	.ndo_bridge_dellink     = ndo_dflt_switchdev_port_bridge_dellink,
>   	.ndo_features_check	= passthru_features_check,
>   };
>   
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index d2e69ee..9b43228 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -43,124 +43,124 @@ struct swdev_ops {
>   				      u8 tos, u8 type, u32 tb_id);
>   };
>   
> -enum netdev_switch_notifier_type {
> +enum switchdev_notifier_type {
>   	NETDEV_SWITCH_FDB_ADD = 1,
>   	NETDEV_SWITCH_FDB_DEL,
Should these enums also be changed to SWITCHDEV_FDB_ prefix?

Thanks
Sridhar
