From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v4 net-next 01/12] bonding: remove bond->lock from bond_arp_rcv
Date: Tue, 18 Feb 2014 12:02:41 +0800
Message-ID: <5302DB61.4070505@huawei.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com> <1392648088-21336-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18304 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaBREDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 23:03:14 -0500
In-Reply-To: <1392648088-21336-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/17 22:41, Veaceslav Falico wrote:
> We're always called with rcu_read_lock() held (bond_arp_rcv() is only
> called from bond_handle_frame(), which is rx_handler and always called
> under rcu from __netif_receive_skb_core() ).
> 
> The slave active/passive and/or bonding params can change in-flight, however
> we don't really care about that - we only modify the last time packet was
> received, which is harmless.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3bce855..3c50bec 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2260,8 +2260,6 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
>  		return RX_HANDLER_ANOTHER;
>  
> -	read_lock(&bond->lock);
> -
>  	if (!slave_do_arp_validate(bond, slave))
>  		goto out_unlock;
>  
> @@ -2318,7 +2316,6 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  		bond_validate_arp(bond, slave, tip, sip);
>  
>  out_unlock:
> -	read_unlock(&bond->lock);
>  	if (arp != (struct arphdr *)skb->data)
>  		kfree(arp);
>  	return RX_HANDLER_ANOTHER;
> 

I think it is not enough, you should add rcu_dereference for bond->curr_active_slave, it may be changed during
the recv processing.

Regards
Ding
