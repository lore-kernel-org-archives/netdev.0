From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v2)
Date: Wed, 6 Jan 2016 17:43:18 +0800
Message-ID: <568CE1B6.1070603@gmail.com>
References: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33830 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbcAFJn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 04:43:27 -0500
Received: by mail-pf0-f174.google.com with SMTP id e65so183218332pfe.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 01:43:27 -0800 (PST)
In-Reply-To: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2016 05:03 PM, Wengang Wang wrote:
> In a bonding setting, we determines fragment size according to MTU and
s/determines/determine

Thanks a lot.
Zhu Yanjun
> PMTU associated to the bonding master. If the slave finds the fragment
> size is too big, it drops the fragment and calls ip_rt_update_pmtu(),
> passing _skb_ and _pmtu_, trying to update the path MTU.
> Problem is that the target device that function ip_rt_update_pmtu actually
> tries to update is the slave (skb->dev), not the master. Thus since no
> PMTU change happens on master, the fragment size for later packets doesn't
> change so all later fragments/packets are dropped too.
>
> The fix is letting build_skb_flow_key() take care of the transition of
> device index from bonding slave to the master. That makes the master become
> the target device that ip_rt_update_pmtu tries to update PMTU to.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   net/ipv4/route.c | 10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 85f184e..fffc7e6 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -523,10 +523,18 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
>   			       const struct sock *sk)
>   {
>   	const struct iphdr *iph = ip_hdr(skb);
> -	int oif = skb->dev->ifindex;
>   	u8 tos = RT_TOS(iph->tos);
> +	struct net_device *master;
>   	u8 prot = iph->protocol;
>   	u32 mark = skb->mark;
> +	int oif;
> +
> +	if (skb->dev->flags & IFF_SLAVE) {
> +		master = netdev_master_upper_dev_get(skb->dev);
> +		oif = master->ifindex;
> +	} else {
> +		oif = skb->dev->ifindex;
> +	}
>   
>   	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>   }
