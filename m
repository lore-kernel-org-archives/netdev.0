From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Sun, 05 Jan 2014 23:35:54 -0800
Message-ID: <52CA5CDA.1020503@gmail.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2014 07:21 PM, Jason Wang wrote:
> L2 fowarding offload will bypass the rx handler of real device. This will make
> the packet could not be forwarded to macvtap device. Another problem is the
> dev_hard_start_xmit() called for macvtap does not have any synchronization.
>
> Fix this by forbidding L2 forwarding for macvtap.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/macvlan.c |    5 ++++-
>   1 files changed, 4 insertions(+), 1 deletions(-)
>

I must be missing something.

The lower layer device should set skb->dev to the correct macvtap
device on receive so that in netif_receive_skb_core() the macvtap
handler is hit. Skipping the macvlan receive handler should be OK
because the switching was done by the hardware. If I read macvtap.c
correctly macvlan_common_newlink() is called with 'dev' where 'dev'
is the macvtap device. Any idea what I'm missing? I guess I'll need
to setup a macvtap test case.

And what synchronization are you worried about on dev_hard_start_xmit()?
In the L2 forwarding offload case macvlan_open() clears the NETIF_F_LLTX
flag so HARD_TX_LOCK protects the driver txq. We might hit this warning
in dev_queue_xmit() though,

   net_crit_ratelimited("Virtual device %s asks to queue packet!\n",

Perhaps we can remove it.

> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 60406b0..5360f73 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -338,6 +338,8 @@ static const struct header_ops macvlan_hard_header_ops = {
>   	.cache_update	= eth_header_cache_update,
>   };
>
> +static struct rtnl_link_ops macvlan_link_ops;
> +
>   static int macvlan_open(struct net_device *dev)
>   {
>   	struct macvlan_dev *vlan = netdev_priv(dev);
> @@ -353,7 +355,8 @@ static int macvlan_open(struct net_device *dev)
>   		goto hash_add;
>   	}
>
> -	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
> +	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD &&
> +	    dev->rtnl_link_ops == &macvlan_link_ops) {
>   		vlan->fwd_priv =
>   		      lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev, dev);
>
>


-- 
John Fastabend         Intel Corporation
