From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v2 RESEND 1/4] macvlan: support mac address changes
 when fwd_priv is enable
Date: Mon, 09 Jun 2014 12:51:35 -0400
Message-ID: <5395E617.5080307@redhat.com>
References: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com> <1402127143-6456-2-git-send-email-dingtianhong@huawei.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>
To: Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net, edumazet@google.com,
	makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932653AbaFIQwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 12:52:03 -0400
In-Reply-To: <1402127143-6456-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[.. CC John Fastabend <john.r.fastabend@intel.com> ]

On 06/07/2014 03:45 AM, Ding Tianhong wrote:
> If lowerdev supports L2 forwarding offload, the macvlan's hw address
> will be set to the rar of the lowerdev and no need to set uc list,
> and when the macvlan's hw address changes, the macvlan should remove
> the old fwd and rebuild a new fwd for the macvlan.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/macvlan.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 453d55a..67485ab 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -523,6 +523,27 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>  		if (macvlan_addr_busy(vlan->port, addr))
>  			return -EBUSY;
>  
> +		if (vlan->fwd_priv) {
> +			lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev,
> +								   vlan->fwd_priv);
> +			vlan->fwd_priv = NULL;
> +			ether_addr_copy(dev->perm_addr, dev->dev_addr);
> +			ether_addr_copy(dev->dev_addr, addr);
> +			vlan->fwd_priv =
> +			    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
> +								       dev);
> +			/* If we get a NULL pointer back, or if we get an error
> +			 * then we should restore the old mac address and fwd.
> +			 */
> +			if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
> +				ether_addr_copy(dev->dev_addr, dev->perm_addr);
> +				vlan->fwd_priv =
> +				    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
> +									       dev);
> +				return -EINVAL;
> +			}
> +			return 0;
> +		}

Calling del_stations add_station causes all sorts of VMDQ/ring
operations to happen...  Not sure if we can do that while we have a live
macvlan/macvtap that is capable of transmitting data.

Wouldn't it be sufficient to have a call to call to update with mac
filter with the appropriate VMDQ.

John, I defer to you here.  The above looks really heavy-weight and
I am not sure if its correct.

Thanks
-vlad

>  		if (!vlan->port->passthru) {
>  			err = dev_uc_add(lowerdev, addr);
>  			if (err)
> 
