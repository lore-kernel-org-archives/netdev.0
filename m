From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next 3/6] bonding: make bond_alb use 8021q's dev->vlan_info
 instead of vlan_list
Date: Fri, 09 Aug 2013 13:13:58 +0200
Message-ID: <5204CEF6.1030200@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com> <1375981079-2936-4-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967573Ab3HILRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 07:17:44 -0400
In-Reply-To: <1375981079-2936-4-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 06:57 PM, Veaceslav Falico wrote:
> RFC -> v1: use the changed __vlan_find_dev_next, which now works with
> 	   vlan's net_device instead of vlan's id. Also, fix a subtle race
> 	   condition if we remove the only vlan while looping through
> 	   MAX_LP_BURST - we end up with using the old vlan_id, so set it
> 	   to 0 if we don't have vlans.
> v1  -> v2: no change.
> 
> In alb mode, we only need each vlan's id (that is on top of bond) to tag
> learning packets, so get them via __vlan_find_dev_next(bond->dev, last_dev).
> 
> We must also find *any* vlan (including last id stored in current_alb_vlan)
> if we can't find anything >= current_alb_vlan id.
> 
> For that, we verify if bond has any vlans at all, and if yes - find the
> next vlan id after current_alb_vlan id. So, if vlan id is not 0, we tag the
> skb.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_alb.c |   47 ++++++++++++++++++++++++++++-----------
>  drivers/net/bonding/bond_alb.h |    2 +-
>  2 files changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 2684329..ced5753 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -974,8 +974,9 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
>  {
>  	struct bonding *bond = bond_get_bond_by_slave(slave);
>  	struct learning_pkt pkt;
> +	struct net_device *vlan_dev;
>  	int size = sizeof(struct learning_pkt);
> -	int i;
> +	int i, vlan_id;
Styling nitpick: maybe re-arrange them longest -> shortest ?

>  
>  	memset(&pkt, 0, size);
>  	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
> @@ -1000,22 +1001,42 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
>  		skb->priority = TC_PRIO_CONTROL;
>  		skb->dev = slave->dev;
>  
> +		rcu_read_lock();
Would've saved a couple of lines if we could move the rcu_read_lock inside the
if {} block but I know that you're keeping the bond_vlan_used() result here, but
I think that with the new functions we're covered i.e. if the vlan has
disappeared between the call to bond_vlan_used and the afterwards we'll get NULL
and just drop the packet, but this can be reworked to continue with the packet
without a vlan if one is not found that is to send it without tag :-)
>  		if (bond_vlan_used(bond)) {
> -			struct vlan_entry *vlan;
> -
> -			vlan = bond_next_vlan(bond,
> -					      bond->alb_info.current_alb_vlan);
> -
> -			bond->alb_info.current_alb_vlan = vlan;
> -			if (!vlan) {
> +			/* first try to find the previously used vlan by
> +			 * id, which might have gone away already
> +			 */
> +			vlan_id = bond->alb_info.current_alb_vlan;
> +			vlan_dev = __vlan_find_dev_deep(bond->dev,
> +							htons(ETH_P_8021Q),
> +							vlan_id);
> +
> +			/* search for the next one, if not found - for any */
> +			if (vlan_dev)
> +				vlan_dev = __vlan_find_dev_next(bond->dev,
> +								vlan_dev);
> +			if (!vlan_dev)
> +				vlan_dev = __vlan_find_dev_next(bond->dev,
> +								NULL);
> +
This part really looks ambiguous, I've left a comment that concerns it in my
reply to patch 02.

> +			if (vlan_dev) {
> +				vlan_id = vlan_dev_vlan_id(vlan_dev);
> +				bond->alb_info.current_alb_vlan = vlan_id;
> +			} else {
> +				bond->alb_info.current_alb_vlan = 0;
> +				rcu_read_unlock();
>  				kfree_skb(skb);
>  				continue;
>  			}
> +		} else
> +			vlan_id = 0;
Styling nitpick: if {} else {}

Cheers,
 Nik
