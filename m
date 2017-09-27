From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 16/16] net: Add support for networking over
 Thunderbolt cable
Date: Tue, 26 Sep 2017 21:47:21 -0700 (PDT)
Message-ID: <20170926.214721.734746621809140934.davem@davemloft.net>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
        <20170925110738.68382-17-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        michael.jamet@intel.com, yehezkel.bernat@intel.com,
        amir.jer.levy@intel.com, Mario.Limonciello@dell.com,
        lukas@wunner.de, andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925110738.68382-17-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Mon, 25 Sep 2017 14:07:38 +0300

> +struct thunderbolt_ip_header {
> +	u32 route_hi;
> +	u32 route_lo;
> +	u32 length_sn;
> +	uuid_t uuid;
> +	uuid_t initiator_uuid;
> +	uuid_t target_uuid;
> +	u32 type;
> +	u32 command_id;
> +} __packed;

Again, the __packed attribute should not be necessary and needs to be
removed.

> +static void tbnet_pull_tail(struct sk_buff *skb)
> +{
> +	skb_frag_t *frag = &skb_shinfo(skb)->frags[0];
> +	unsigned int pull_len;
> +	void *hdr;
> +
> +	hdr = skb_frag_address(frag);
> +	pull_len = eth_get_headlen(hdr, TBNET_RX_HDR_SIZE);
> +
> +	/* Align pull length to size of long to optimize memcpy performance */
> +	skb_copy_to_linear_data(skb, hdr, ALIGN(pull_len, sizeof(long)));

You do not need to copy here, instead you can build SKB's where the
skb->data points directly at the head of your first frag page memory.

See build_skb().

> +		skb = net->skb;
> +		if (!skb) {
> +			skb = netdev_alloc_skb_ip_align(net->dev,
> +							TBNET_RX_HDR_SIZE);
> +			net->skb = skb;
> +		}
> +		if (!skb)
> +			break;
> +
> +		/* Single small buffer we can copy directly to the
> +		 * header part of the skb.
> +		 */
> +		if (hdr->frame_count == 1 && frame_size <= TBNET_RX_HDR_SIZE) {

Here you would use build_skb() instead of netdev_alloc_skb*() for the first
frag, and keep the existing code tacking on subsequent frags using
skb_add_Rx_frag().

> +	ret = register_netdev(dev);
> +	if (ret) {
> +		free_netdev(dev);
> +		return ret;
> +	}
> +
> +	net->handler.uuid = &tbnet_svc_uuid;
> +	net->handler.callback = tbnet_handle_packet,
> +	net->handler.data = net;
> +	tb_register_protocol_handler(&net->handler);
> +
> +	tb_service_set_drvdata(svc, net);

There could be races here.

At the exact moment you call register_netdev(), your device can be
brought UP, packets transmitted, etc.  You entire set of driver code
paths can be executed.

The rest of those initializations after register_netdev() probably
are needed by the rest of the driver to function properly, so may
need to happen before register_netdev() publishes the device to the
entire world.
