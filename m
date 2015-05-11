From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Sun, 10 May 2015 22:58:14 -0700
Message-ID: <1431323894.2884.4.camel@perches.com>
References: <1431317294-16442-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431317294-16442-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-05-10 at 21:08 -0700, K. Y. Srinivasan wrote:
> Based on the information given to this driver (via the xmit_more skb flag),
> we can defer signaling the host if more packets are on the way. This will help
> make the host more efficient since it can potentially process a larger batch of
> packets. Implement this optimization.

trivia:

I think that indirecting VMBUS_DATA_PACKET_FLAG_COMPLETTION_REQUESTED
into a non-const temporary isn't very useful.

Whenever overly long identifiers like VMBUS_<FOO> is used,
I think that it'd be better to use it directly and ignore
80 column warnings.

Same with the "sizeof(struct nvsp_message)" on two lines.

> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
[]
> @@ -743,6 +743,8 @@ static inline int netvsc_send_pkt(
>  	u64 req_id;
>  	int ret;
>  	struct hv_page_buffer *pgbuf;
> +	u32 vmbus_flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
> +	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
[]
> @@ -769,30 +771,41 @@ static inline int netvsc_send_pkt(
[]
> +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> +						      pgbuf,
> +						      packet->page_buf_cnt,
> +						      &nvmsg,
> +						      sizeof(struct
> +							     nvsp_message),
> +						      req_id,
> +						      vmbus_flags,
> +						      !packet->xmit_more);

[]

>  			netif_tx_stop_queue(netdev_get_tx_queue(
>  					    ndev, q_idx));

This could be on one line too.
