From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 6 Jan 2016 14:19:41 +0800
Message-ID: <568CB1FD.4030907@gmail.com>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36623 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbcAFGTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:19:48 -0500
Received: by mail-pf0-f173.google.com with SMTP id 65so188264458pff.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 22:19:48 -0800 (PST)
In-Reply-To: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IMHO, this should fix in bonding driver because the active slave mtu 
should be the same with the master.
bonding master's mtu is changed to path MTU, then slave dev's MTU should 
be changed, too.

Zhu Yanjun
On 01/06/2016 01:49 PM, Wengang Wang wrote:
> A problem is found that we are looking for route basing a bonding device and
> deal with path MTU there: The path MTU is set to the active slave device, not
> the bonding master.
>
> The patch tries to fix the issue by letting build_skb_flow_key() take care
> of the transition of device index from bonding slave to the master.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   net/ipv4/route.c | 11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 85f184e..3053f10 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
>   			       const struct sock *sk)
>   {
>   	const struct iphdr *iph = ip_hdr(skb);
> -	int oif = skb->dev->ifindex;
> +	int oif;
> +	struct net_device *master = NULL;
> +
>   	u8 tos = RT_TOS(iph->tos);
>   	u8 prot = iph->protocol;
>   	u32 mark = skb->mark;
>   
> +	if (skb->dev->flags & IFF_SLAVE)
> +		master = netdev_master_upper_dev_get(skb->dev);
> +	if (master)
> +		oif = master->ifindex;
> +	else
> +		oif = skb->dev->ifindex;
> +
>   	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>   }
>   
