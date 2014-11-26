From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 08:58:27 -0800
Message-ID: <547606B3.3060808@gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35540 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbaKZQ6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 11:58:40 -0500
Received: by mail-ob0-f172.google.com with SMTP id wn1so2476620obc.17
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 08:58:39 -0800 (PST)
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 04:42 AM, Thomas Graf wrote:
> Adds various missing length checks in the bridging code for Netlink
> messages and corresponding attributes provided by user space.
>
> Thomas Graf (5):
>    bridge: Validate IFLA_BRIDGE_FLAGS attribute length
>    net: Validate IFLA_BRIDGE_MODE attribute length
>    net: Check for presence of IFLA_AF_SPEC
>    bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
>    bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK
>
>   drivers/net/ethernet/emulex/benet/be_main.c   |  5 +++++
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  5 +++++
>   net/bridge/br_netlink.c                       |  1 +
>   net/core/rtnetlink.c                          | 23 ++++++++++++++++++-----
>   4 files changed, 29 insertions(+), 5 deletions(-)
>

+Jiri

Looks like a miss in bond_netlink also? Seems like writing
a smatch or cocci check for this would be worthwhile.

>
> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
> index 3e6eebd..7b11243 100644
> --- a/drivers/net/bonding/bond_netlink.c
> +++ b/drivers/net/bonding/bond_netlink.c
> @@ -225,7 +225,12 @@ static int bond_changelink(struct net_device *bond_dev,
>
>                 bond_option_arp_ip_targets_clear(bond);
>                 nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
> -                       __be32 target = nla_get_be32(attr);
> +                       __be32 target;
> +
> +                       if (nla_len(attr) < sizeof(target))
> +                               return -EINVAL;
> +
> +                       target = nla_get_be32(attr);
>
>                         bond_opt_initval(&newval, (__force u64)target);
>                         err = __bond_opt_set(bond, BOND_OPT_ARP_TARGETS,

-- 
John Fastabend         Intel Corporation
