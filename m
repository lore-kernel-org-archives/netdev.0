From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net-next, v2] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Thu, 8 May 2014 22:03:52 +0200
Message-ID: <20140508200352.GB8847@kroah.com>
References: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, May 08, 2014 at 01:41:33PM -0700, Haiyang Zhang wrote:
> This change ensures the driver can be built successfully without the
> CONFIG_SYSFS flag.
> MS-TFS: 182270
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h   |   28 ++++++++++++++++++++++++++++
>  drivers/net/hyperv/netvsc_drv.c   |   13 +++++++------
>  drivers/net/hyperv/rndis_filter.c |    4 ++--
>  3 files changed, 37 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index 4b7df5a..02358cb 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -87,6 +87,8 @@ struct ndis_recv_scale_cap { /* NDIS_RECEIVE_SCALE_CAPABILITIES */
>  #define HASH_KEYLEN NDIS_RSS_HASH_SECRET_KEY_MAX_SIZE_REVISION_2
>  extern u8 netvsc_hash_key[];
>  
> +extern unsigned int netvsc_num_queue;
> +
>  struct ndis_recv_scale_param { /* NDIS_RECEIVE_SCALE_PARAMETERS */
>  	struct ndis_obj_header hdr;
>  
> @@ -178,6 +180,32 @@ struct rndis_device {
>  	unsigned char hw_mac_adr[ETH_ALEN];
>  };
>  
> +static inline void netvsc_record_rx_queue(struct sk_buff *skb,
> +					  struct hv_netvsc_packet *packet,
> +					  struct net_device *ndev)
> +{
> +#ifdef CONFIG_SYSFS
> +	skb_record_rx_queue(skb, packet->channel->
> +			    offermsg.offer.sub_channel_index %
> +			    ndev->real_num_rx_queues);
> +#endif

Really?  Do all other wireless drivers have this type of #ifdef needed?

> +}
> +
> +static inline void netvsc_show_num_queue(struct device *dev,
> +					 struct net_device *ndev)
> +{
> +#ifdef CONFIG_SYSFS
> +	dev_info(dev, "real num tx,rx queues:%u, %u\n",
> +		 ndev->real_num_tx_queues, ndev->real_num_rx_queues);
> +#endif

Do network drivers really spam the kernel log with this type of thing?
If you have sysfs, why is this needed in the kernel log?

> +}
> +
> +static inline void netvsc_set_num_queue(unsigned int *nq)
> +{
> +#ifdef CONFIG_SYSFS
> +	*nq = num_online_cpus();
> +#endif
> +}

I really feel that something is odd here...
