From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next v2] bonding: Display LACP info only to
 CAP_NET_ADMIN capable user
Date: Thu, 18 Jun 2015 04:17:36 -0700
Message-ID: <1434626256.27504.208.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434589182-7953-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:36458 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbbFRLRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 07:17:51 -0400
Received: by wgzl5 with SMTP id l5so60885861wgz.3
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 04:17:50 -0700 (PDT)
In-Reply-To: <1434589182-7953-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-17 at 17:59 -0700, Mahesh Bandewar wrote:
> Actor and Partner details can be accessed via proc-fs, sys-fs
> entries or netlink interface. These interfaces are world readable
> at this moment. The earlier patch-series made the LACP communication
> secure to avoid nuisance attack from within the same L2 domain but
> it did not prevent "someone unprivileged" looking at that information
> on host and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_netlink.c |  11 ++--
>  drivers/net/bonding/bond_procfs.c  | 101 +++++++++++++++++++------------------
>  drivers/net/bonding/bond_sysfs.c   |  12 ++---
>  3 files changed, 67 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
> index 5580fcde738f..3fd3aa4b145e 100644
> --- a/drivers/net/bonding/bond_netlink.c
> +++ b/drivers/net/bonding/bond_netlink.c
> @@ -600,18 +600,23 @@ static int bond_fill_info(struct sk_buff *skb,
>  
>  	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>  		struct ad_info info;
> +		u8 zero_mac[ETH_ALEN];
>  
> +		eth_zero_addr(zero_mac);
>  		if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
> -				bond->params.ad_actor_sys_prio))
> +				capable(CAP_NET_ADMIN) ?
> +				bond->params.ad_actor_sys_prio : 0))
>  			goto nla_put_failure;
>  
>  		if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
> -				bond->params.ad_user_port_key))
> +				capable(CAP_NET_ADMIN) ?
> +				bond->params.ad_user_port_key : 0))
>  			goto nla_put_failure;
>  
>  		if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
>  			    sizeof(bond->params.ad_actor_system),
> -			    &bond->params.ad_actor_system))
> +			    capable(CAP_NET_ADMIN) ?
> +			    &bond->params.ad_actor_system : &zero_mac))
>  			goto nla_put_failure;
>  

Hmm... I would rather not send these fake attributes at all ?
