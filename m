From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] bonding: fix bond_arp_rcv() race of curr_active_slave
Date: Thu, 20 Feb 2014 19:49:28 +0800
Message-ID: <5305EBC8.3070207@huawei.com>
References: <1392894477-5477-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:49720 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbaBTLts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 06:49:48 -0500
In-Reply-To: <1392894477-5477-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/20 19:07, Veaceslav Falico wrote:
> bond->curr_active_slave can be changed between its deferences, even to
> NULL, and thus we might panic.
> 
> We're always holding the rcu (rx_handler->bond_handle_frame()->bond_arp_rcv())
> so fix this by rcu_dereferencing() it and using the saved.
> 
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> Fixes: aeea64a ("bonding: don't trust arp requests unless active slave really works")
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 71edf03..bd70bbc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2254,6 +2254,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  		 struct slave *slave)
>  {
>  	struct arphdr *arp = (struct arphdr *)skb->data;
> +	struct slave *curr_active_slave;
>  	unsigned char *arp_ptr;
>  	__be32 sip, tip;
>  	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
> @@ -2299,6 +2300,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
>  		 &sip, &tip);
>  
> +	curr_active_slave = rcu_dereference(bond->curr_active_slave);
> +
>  	/*
>  	 * Backup slaves won't see the ARP reply, but do come through
>  	 * here for each ARP probe (so we swap the sip/tip to validate
> @@ -2312,11 +2315,12 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  	 * is done to avoid endless looping when we can't reach the
>  	 * arp_ip_target and fool ourselves with our own arp requests.
>  	 */
> +
>  	if (bond_is_active_slave(slave))
>  		bond_validate_arp(bond, slave, sip, tip);
> -	else if (bond->curr_active_slave &&
> -		 time_after(slave_last_rx(bond, bond->curr_active_slave),
> -			    bond->curr_active_slave->last_link_up))
> +	else if (curr_active_slave &&
> +		 time_after(slave_last_rx(bond, curr_active_slave),
> +			    curr_active_slave->last_link_up))
>  		bond_validate_arp(bond, slave, tip, sip);
>  
>  out_unlock:
> 

Acked-by: Ding Tianhong <dingtianhong@huawei.com>
