From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v3] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Wed, 19 Mar 2014 16:40:05 -0400 (EDT)
Message-ID: <20140319.164005.1815461875771862691.davem@davemloft.net>
References: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 18 Mar 2014 15:15:22 -0700

> +struct ndis_obj_header {
> +	u8 type;
> +	u8 rev;
> +	u16 size;
> +} __packed;
> +
> +
> +/* ndis_recv_scale_cap/cap_flag */

One empty line is sufficient, we don't need two of them here.

> +extern u8 netvsc_hash_key[];

We no longer use extern in header file function declarations.

> +	u32 processor_masks_offset;
> +	u32 num_processor_masks;
> +	u32 processor_masks_entry_size;
> +};
> +
> +
>  /* Fwd declaration */

Again, one empty line is enough.

> @@ -120,6 +217,7 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
>  int netvsc_recv_callback(struct hv_device *device_obj,
>  			struct hv_netvsc_packet *packet,
>  			struct ndis_tcp_ip_checksum_info *csum_info);
> +extern void netvsc_channel_cb(void *context);

Again, please remove this extern in function declarations.

> +		if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
> +			!net_device->start_remove &&
> +			(hv_ringbuf_avail_percent(&channel->outbound) >
> +			RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))

For the second time, this is not properly indented.  Multi-line
conditionals should be formatted like this:

	if (CONDITION1 OPERATOR
	    CONDITION2 OPERATOR
	    ...)

etc.  For example, this specifically should be:

		if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
		    !net_device->start_remove &&
		    (hv_ringbuf_avail_percent(&channel->outbound) >
		     RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))

Generally speaking, if you are only using TAB characters to indent,
you are probably doing it wrong.

You should use the appropriate number of TAB _and_ SPACE characters
necessary to start the line at exactly the first column after the
openning parenthesis of the appropriate construct.

> @@ -668,9 +756,11 @@ static int netvsc_probe(struct hv_device *dev,
>  	struct net_device *net = NULL;
>  	struct net_device_context *net_device_ctx;
>  	struct netvsc_device_info device_info;
> +	struct netvsc_device *nvdev;
>  	int ret;
>  
> -	net = alloc_etherdev(sizeof(struct net_device_context));
> +	net = alloc_etherdev_mq(sizeof(struct net_device_context),
> +				num_online_cpus());
>  	if (!net)
>  		return -ENOMEM;
>  

num_online_cpus() can change, will your driver accomodate this?

> +}
> +
> +
>  static int rndis_filter_query_device_link_status(struct rndis_device *dev)

One empty line is sufficient.

>  }
>  
> +
> +static void netvsc_sc_open(struct vmbus_channel *new_sc)

Likewise.

> +	ret = vmbus_open(new_sc, nvscdev->ring_size * PAGE_SIZE,
> +		nvscdev->ring_size * PAGE_SIZE, NULL, 0,
> +		netvsc_channel_cb, new_sc);

When function arguments span multiple lines the function call
shall be indented as:

	func(A, B, C,
	     D, E, F);

That is, the second and subsequent lines are indented, using
the appropriate number of TAB _and_ SPACE characters, necessary
to reach exactly the first column after the openning parenthesis.

There are several other cases of this, please audit your entire
submission for this problem.

If proper indentation causes lines to significantly exceed 80
columns, consider helper functions or local variables to
allieve the problem.

> +	ret = rndis_filter_query_device(rndis_device,
> +		OID_GEN_RECEIVE_SCALE_CAPABILITIES, &rsscap, &rsscap_size);

Same problem.
