From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head room in the skb
Date: Tue, 24 Nov 2015 09:56:20 +0100
Message-ID: <87vb8rlqrv.fsf@vitty.brq.redhat.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
	<1448321346-21357-1-git-send-email-kys@microsoft.com>
	<1448321346-21357-8-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448321346-21357-8-git-send-email-kys@microsoft.com>
	(K. Y. Srinivasan's message of "Mon, 23 Nov 2015 15:29:04 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"K. Y. Srinivasan" <kys@microsoft.com> writes:

> The rndis header is 116 bytes big and can be placed in the default
> head room that will be available in the skb.

We have the following in include/linux/netdevice.h:

#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
# if defined(CONFIG_MAC80211_MESH)
#  define LL_MAX_HEADER 128
# else
#  define LL_MAX_HEADER 96
# endif
#else
# define LL_MAX_HEADER 32
#endif

In case someone disables MAC80211_MESH in his kernel config we're in
troubles again. I suggest we add additional patch here making sure it is
128 bytes for Hyper-V:

#if defined(CONFIG_HYPERV_NET)
# define LL_MAX_HEADER 128
#elseif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
...

> Since the netvsc packet
> is less than 48 bytes, we can use the skb control buffer
> for the netvsc packet. With these changes we don't need to
> ask for additional head room.
>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h |    3 +++
>  drivers/net/hyperv/netvsc_drv.c |   28 +++++++++-------------------
>  2 files changed, 12 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index 9504ca9..e15dc2c 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -124,6 +124,9 @@ struct ndis_tcp_ip_checksum_info;
>  /*
>   * Represent netvsc packet which contains 1 RNDIS and 1 ethernet frame
>   * within the RNDIS
> + *
> + * The size of this structure is less than 48 bytes and we can now
> + * place this structure in the skb->cb field.
>   */
>  struct hv_netvsc_packet {
>  	/* Bookkeeping stuff */
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 947b778..9b6c507 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -432,7 +432,6 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
>  	u32 net_trans_info;
>  	u32 hash;
>  	u32 skb_length;
> -	u32 pkt_sz;
>  	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
>  	struct netvsc_stats *tx_stats = this_cpu_ptr(net_device_ctx->tx_stats);
>
> @@ -460,16 +459,19 @@ check_size:
>  		goto check_size;
>  	}
>
> -	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
> -
> -	ret = skb_cow_head(skb, pkt_sz);
> +	/*
> +	 * Place the rndis header in the skb head room and
> +	 * the skb->cb will be used for hv_netvsc_packet
> +	 * structure.
> +	 */
> +	ret = skb_cow_head(skb, RNDIS_AND_PPI_SIZE);
>  	if (ret) {
>  		netdev_err(net, "unable to alloc hv_netvsc_packet\n");
>  		ret = -ENOMEM;
>  		goto drop;
>  	}
> -	/* Use the headroom for building up the packet */
> -	packet = (struct hv_netvsc_packet *)skb->head;
> +	/* Use the skb control buffer for building up the packet */
> +	packet = (struct hv_netvsc_packet *)skb->cb;
>
>  	packet->status = 0;
>  	packet->xmit_more = skb->xmit_more;
> @@ -482,8 +484,7 @@ check_size:
>  	packet->is_data_pkt = true;
>  	packet->total_data_buflen = skb->len;
>
> -	rndis_msg = (struct rndis_message *)((unsigned long)packet +
> -				sizeof(struct hv_netvsc_packet));
> +	rndis_msg = (struct rndis_message *)skb->head;
>
>  	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
>
> @@ -1071,16 +1072,12 @@ static int netvsc_probe(struct hv_device *dev,
>  	struct netvsc_device_info device_info;
>  	struct netvsc_device *nvdev;
>  	int ret;
> -	u32 max_needed_headroom;
>
>  	net = alloc_etherdev_mq(sizeof(struct net_device_context),
>  				num_online_cpus());
>  	if (!net)
>  		return -ENOMEM;
>
> -	max_needed_headroom = sizeof(struct hv_netvsc_packet) +
> -			      RNDIS_AND_PPI_SIZE;
> -
>  	netif_carrier_off(net);
>
>  	net_device_ctx = netdev_priv(net);
> @@ -1116,13 +1113,6 @@ static int netvsc_probe(struct hv_device *dev,
>  	net->ethtool_ops = &ethtool_ops;
>  	SET_NETDEV_DEV(net, &dev->device);
>
> -	/*
> -	 * Request additional head room in the skb.
> -	 * We will use this space to build the rndis
> -	 * heaser and other state we need to maintain.
> -	 */
> -	net->needed_headroom = max_needed_headroom;
> -
>  	/* Notify the netvsc driver of the new device */
>  	memset(&device_info, 0, sizeof(device_info));
>  	device_info.ring_size = ring_size;

-- 
  Vitaly
