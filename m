From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 2/4] virtio-net: transmit napi
Date: Mon, 6 Mar 2017 17:21:32 +0800
Message-ID: <d60512a1-4210-b0c8-c672-bb6e3779936d@redhat.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753428AbdCFJ34 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 04:29:56 -0500
In-Reply-To: <20170303143909.80001-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月03日 22:39, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Convert virtio-net to a standard napi tx completion path. This enables
> better TCP pacing using TCP small queues and increases single stream
> throughput.
>
> The virtio-net driver currently cleans tx descriptors on transmission
> of new packets in ndo_start_xmit. Latency depends on new traffic, so
> is unbounded. To avoid deadlock when a socket reaches its snd limit,
> packets are orphaned on tranmission. This breaks socket backpressure,
> including TSQ.
>
> Napi increases the number of interrupts generated compared to the
> current model, which keeps interrupts disabled as long as the ring
> has enough free descriptors. Keep tx napi optional for now. Follow-on
> patches will reduce the interrupt cost.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   drivers/net/virtio_net.c | 73 ++++++++++++++++++++++++++++++++++++++++--------
>   1 file changed, 61 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 8c21e9a4adc7..9a9031640179 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -33,6 +33,8 @@
>   static int napi_weight = NAPI_POLL_WEIGHT;
>   module_param(napi_weight, int, 0444);
>   
> +static int napi_tx_weight = NAPI_POLL_WEIGHT;
> +

Maybe we should use module_param for this? Or in the future, use 
tx-frames-irq for a per-device configuration.

Thanks
