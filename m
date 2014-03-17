From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netpoll: send arp reply on master device immediately
Date: Mon, 17 Mar 2014 16:41:18 +0400
Message-ID: <5326ED6E.9030001@cogentembedded.com>
References: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, nhorman@tuxdriver.com
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:61283 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906AbaCQMlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:41:21 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so3572682lab.41
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 05:41:20 -0700 (PDT)
In-Reply-To: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-03-2014 11:41, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> 1. the arp queue has been moved from slave device to master, so the
> master device netpoll_info should be as input of service_arp_queue()
> 2. not need to check if ni is NULL or not, since it has been used before.

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> ---
>   net/core/netpoll.c |   26 ++++++++++++--------------
>   1 file changed, 12 insertions(+), 14 deletions(-)

> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a664f78..dd0a796 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -229,21 +229,19 @@ static void netpoll_poll_dev(struct net_device *dev)
>   	up(&ni->dev_lock);
>
>   	if (dev->flags & IFF_SLAVE) {
[...]
> +		struct net_device *bond_dev;
> +		struct sk_buff *skb;
> +		struct netpoll_info *bond_ni;
>
> -	service_neigh_queue(ni);
> +		bond_dev = netdev_master_upper_dev_get_rcu(dev);
> +		bond_ni = rcu_dereference_bh(bond_dev->npinfo);
> +		while ((skb = skb_dequeue(&ni->neigh_tx))) {
> +			skb->dev = bond_dev;
> +			skb_queue_tail(&bond_ni->neigh_tx, skb);
> +		}
> +		service_neigh_queue(bond_ni);
> +	} else
> +		service_neigh_queue(ni);

     The *else* branch should also have {}, according to 
Documentation/CodingStyle.

WBR, Sergei
