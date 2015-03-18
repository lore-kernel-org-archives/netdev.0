From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V3 2/2 net-next] hyperv: Support batched notification
Date: Wed, 18 Mar 2015 11:08:42 +0800
Message-ID: <1426648122.5207.0@smtp.corp.redhat.com>
References: <1426608145-14139-1-git-send-email-kys@microsoft.com>
 <1426608167-14180-1-git-send-email-kys@microsoft.com>
 <1426608167-14180-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1426608167-14180-2-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On Wed, Mar 18, 2015 at 12:02 AM, K. Y. Srinivasan <kys@microsoft.com> 
wrote:
> Optimize notifying the host by deferring notification until there
> are no more packets to be sent. This will help in batching the 
> requests
> on the host.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h   |    2 +-
>  drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
>  drivers/net/hyperv/netvsc_drv.c   |    2 +-
>  drivers/net/hyperv/rndis_filter.c |    2 +-
>  4 files changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/hyperv/hyperv_net.h 
> b/drivers/net/hyperv/hyperv_net.h
> index 4815843..3fd9896 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -184,7 +184,7 @@ struct rndis_device {
>  int netvsc_device_add(struct hv_device *device, void 
> *additional_info);
>  int netvsc_device_remove(struct hv_device *device);
>  int netvsc_send(struct hv_device *device,
> -		struct hv_netvsc_packet *packet);
> +		struct hv_netvsc_packet *packet, bool kick_q);
>  void netvsc_linkstatus_callback(struct hv_device *device_obj,
>  				struct rndis_message *resp);
>  int netvsc_recv_callback(struct hv_device *device_obj,
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 208eb05..9003b94 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -707,7 +707,7 @@ static u32 netvsc_copy_to_send_buf(struct 
> netvsc_device *net_device,
>  }
>  
>  int netvsc_send(struct hv_device *device,
> -			struct hv_netvsc_packet *packet)
> +			struct hv_netvsc_packet *packet, bool kick_q)
>  {
>  	struct netvsc_device *net_device;
>  	int ret = 0;
> @@ -719,6 +719,7 @@ int netvsc_send(struct hv_device *device,
>  	u32 msg_size = 0;
>  	struct sk_buff *skb = NULL;
>  	u16 q_idx = packet->q_idx;
> +	u32 vmbus_flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
>  
>  
>  	net_device = get_outbound_net_device(device);
> @@ -768,18 +769,21 @@ int netvsc_send(struct hv_device *device,
>  		return -ENODEV;
>  
>  	if (packet->page_buf_cnt) {
> -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
>  						  packet->page_buf,
>  						  packet->page_buf_cnt,
>  						  &sendMessage,
>  						  sizeof(struct nvsp_message),
> -						  req_id);
> +						  req_id,
> +						  vmbus_flags,
> +						  kick_q);
>  	} else {
> -		ret = vmbus_sendpacket(out_channel, &sendMessage,
> +		ret = vmbus_sendpacket_ctl(out_channel, &sendMessage,
>  				sizeof(struct nvsp_message),
>  				req_id,
>  				VM_PKT_DATA_INBAND,
> -				VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
> +				vmbus_flags,
> +				kick_q);
>  	}
>  
>  	if (ret == 0) {
> diff --git a/drivers/net/hyperv/netvsc_drv.c 
> b/drivers/net/hyperv/netvsc_drv.c
> index a06bd66..eae58db 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -556,7 +556,7 @@ do_send:
>  	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
>  					skb, &packet->page_buf[0]);
>  
> -	ret = netvsc_send(net_device_ctx->device_ctx, packet);
> +	ret = netvsc_send(net_device_ctx->device_ctx, packet, 
> !skb->xmit_more);
>  

Looks like the issue of V2 still there (E.g we need to kick when 
hv_ringbuffer_write() returns -EAGAIN?
> 
>  drop:
>  	if (ret == 0) {
> diff --git a/drivers/net/hyperv/rndis_filter.c 
> b/drivers/net/hyperv/rndis_filter.c
> index ca81de0..05f3792 100644
> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -238,7 +238,7 @@ static int rndis_filter_send_request(struct 
> rndis_device *dev,
>  
>  	packet->send_completion = NULL;
>  
> -	ret = netvsc_send(dev->net_dev->dev, packet);
> +	ret = netvsc_send(dev->net_dev->dev, packet, true);
>  	return ret;
>  }
>  
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
