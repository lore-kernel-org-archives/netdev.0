From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Wed, 02 Oct 2013 00:08:11 -0700
Message-ID: <524BC65B.4080803@gmail.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32> <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com> <1380140209-24587-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@intel.com,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:54793 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3JBHI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 03:08:28 -0400
Received: by mail-oa0-f50.google.com with SMTP id j1so401246oag.37
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 00:08:27 -0700 (PDT)
In-Reply-To: <1380140209-24587-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2013 01:16 PM, Neil Horman wrote:
> Add a operations structure that allows a network interface to export the fact
> that it supports package forwarding in hardware between physical interfaces and
> other mac layer devices assigned to it (such as macvlans).  this operaions
> structure can be used by virtual mac devices to bypass software switching so
> that forwarding can be done in hardware more efficiently.

Some additional nits below which maybe you have already thought of.

>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: john.fastabend@intel.com
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>   drivers/net/macvlan.c      | 37 +++++++++++++++++++++++++++++++++++++
>   include/linux/if_macvlan.h |  1 +
>   include/linux/netdevice.h  | 10 ++++++++++
>   net/core/dev.c             |  3 +++
>   4 files changed, 51 insertions(+)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 9bf46bd..0c37b30 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -296,8 +296,16 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
>   	unsigned int len = skb->len;
>   	int ret;
>   	const struct macvlan_dev *vlan = netdev_priv(dev);
> +	const struct l2_forwarding_accel_ops *l2a_ops = vlan->lowerdev->l2a_ops;
> +
> +	if (l2a_ops->l2_accel_xmit) {
> +		ret = l2a_ops->l2_accel_xmit(skb, vlan->l2a_priv);
> +		if (likely(ret == NETDEV_TX_OK))

maybe dev_xmit_complete() would be more appropriate?

> +			goto update_stats;
> +	}
>
>   	ret = macvlan_queue_xmit(skb, dev);
> +update_stats:
>   	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
>   		struct macvlan_pcpu_stats *pcpu_stats;
>
> @@ -336,6 +344,7 @@ static int macvlan_open(struct net_device *dev)
>   {
>   	struct macvlan_dev *vlan = netdev_priv(dev);
>   	struct net_device *lowerdev = vlan->lowerdev;
> +	const struct l2_forwarding_accel_ops *l2a_ops = lowerdev->l2a_ops;
>   	int err;
>
>   	if (vlan->port->passthru) {
> @@ -347,6 +356,19 @@ static int macvlan_open(struct net_device *dev)
>   		goto hash_add;

Looks like this might break in the passthru case? If you don't call
l2_accel_add_dev here but still use the l2_accel_xmit.

>   	}
>
> +	if (l2a_ops->l2_accel_add_dev) {

In the error cases it might be preferred to fallback to the
non-offloaded software path. For example hardware may have a limit
to the number of VSIs that can be created but we wouldn't want to
push that up the stack.

> +		/* The lowerdev supports l2 switching
> +		 * try to add this macvlan to it
> +		 */
> +		vlan->l2a_priv = kzalloc(l2a_ops->priv_size, GFP_KERNEL);
> +		if (!vlan->l2a_priv)
> +			return -ENOMEM;
> +		err = l2a_ops->l2_accel_add_dev(vlan->lowerdev,
> +						dev, vlan->l2a_priv);
> +		if (err < 0)
> +			return err;
> +	}
> +
>   	err = -EBUSY;
>   	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
>   		goto out;
> @@ -367,6 +389,13 @@ hash_add:
>   del_unicast:
>   	dev_uc_del(lowerdev, dev->dev_addr);
>   out:
> +	if (vlan->l2a_priv) {

Add a feature flag here so it can be disabled.

> +		if (l2a_ops->l2_accel_del_dev)
> +			l2a_ops->l2_accel_del_dev(vlan->lowerdev,
> +						  vlan->l2a_priv);
> +		kfree(vlan->l2a_priv);
> +		vlan->l2a_priv = NULL;
> +	}
>   	return err;
>   }

[...]

Thanks,
John


-- 
John Fastabend         Intel Corporation
