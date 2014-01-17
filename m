From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 net-next 07/12] bonding: use the new options to
 correctly set last_arp_rx
Date: Fri, 17 Jan 2014 15:32:17 -0500
Message-ID: <20140117203217.GD19452@hmsreliant.think-freely.org>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
 <1389977940-17084-8-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33233 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbaAQUc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 15:32:27 -0500
Content-Disposition: inline
In-Reply-To: <1389977940-17084-8-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 05:58:55PM +0100, Veaceslav Falico wrote:
> Now that the options are in place - arp_validate can be set to receive all
> the traffic or only arp packets to verify if the slave is up, when the
> slave isn't validated.
> 
> CC: Rob Landley <rob@landley.net>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Nikolay Aleksandrov <nikolay@redhat.com>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 532a452..48491d9 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2290,15 +2290,16 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  	struct arphdr *arp = (struct arphdr *)skb->data;
>  	unsigned char *arp_ptr;
>  	__be32 sip, tip;
> -	int alen;
> +	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
>  
> -	slave->last_arp_rx = jiffies;
> -
> -	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
> +	if (!slave_do_arp_validate(bond, slave)) {
> +		if ((slave_do_arp_validate_only(bond, slave) && is_arp) ||
> +		    !slave_do_arp_validate_only(bond, slave))
> +			slave->last_arp_rx = jiffies;
>  		return RX_HANDLER_ANOTHER;
> -
> -	if (!slave_do_arp_validate(bond, slave))
> -		goto out_unlock;
> +	} else if (!is_arp) {
> +		return RX_HANDLER_ANOTHER;
> +	}
>  
>  	alen = arp_hdr_len(bond->dev);
>  
> -- 
> 1.8.4
> 
> 

Seems ok
Acked-by: Neil Horman <nhorman@tuxdriver.com>
