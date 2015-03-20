From: Jason Wang <jasowang@redhat.com>
Subject: RE: [PATCH V3 2/2 net-next] hyperv: Support batched notification
Date: Fri, 20 Mar 2015 13:57:57 +0800
Message-ID: <1426831077.5879.6@smtp.corp.redhat.com>
References: <1426608145-14139-1-git-send-email-kys@microsoft.com>
	<1426608167-14180-1-git-send-email-kys@microsoft.com>
	<1426608167-14180-2-git-send-email-kys@microsoft.com>
	<1426648122.5207.0@smtp.corp.redhat.com>
	<BY2PR0301MB07114336B35924D353108197A0010@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB07114336B35924D353108197A0010@BY2PR0301MB0711.namprd03.prod.out
	look.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, Mar 20, 2015 at 12:53 AM, KY Srinivasan <kys@microsoft.com> 
wrote:
> 
> 
>>  -----Original Message-----
>>  From: Jason Wang [mailto:jasowang@redhat.com]
>>  Sent: Tuesday, March 17, 2015 8:09 PM
>>  To: KY Srinivasan
>>  Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
>>  kernel@vger.kernel.org; devel@linuxdriverproject.org; 
>> olaf@aepfle.de;
>>  apw@canonical.com; KY Srinivasan
>>  Subject: Re: [PATCH V3 2/2 net-next] hyperv: Support batched 
>> notification
>>  
>>  
>>  
>>  On Wed, Mar 18, 2015 at 12:02 AM, K. Y. Srinivasan 
>> <kys@microsoft.com>
>>  wrote:
>>  > Optimize notifying the host by deferring notification until there
>>  > are no more packets to be sent. This will help in batching the
>>  > requests
>>  > on the host.
>>  >
>>  > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
>>  > ---
>>  >  drivers/net/hyperv/hyperv_net.h   |    2 +-
>>  >  drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
>>  >  drivers/net/hyperv/netvsc_drv.c   |    2 +-
>>  >  drivers/net/hyperv/rndis_filter.c |    2 +-
>>  >  4 files changed, 12 insertions(+), 8 deletions(-)
>>  >
>>  > diff --git a/drivers/net/hyperv/hyperv_net.h
>>  > b/drivers/net/hyperv/hyperv_net.h
>>  > index 4815843..3fd9896 100644
>>  > --- a/drivers/net/hyperv/hyperv_net.h
>>  > +++ b/drivers/net/hyperv/hyperv_net.h
>>  > @@ -184,7 +184,7 @@ struct rndis_device {
>>  >  int netvsc_device_add(struct hv_device *device, void
>>  > *additional_info);
>>  >  int netvsc_device_remove(struct hv_device *device);
>>  >  int netvsc_send(struct hv_device *device,
>>  > -		struct hv_netvsc_packet *packet);
>>  > +		struct hv_netvsc_packet *packet, bool kick_q);
>>  >  void netvsc_linkstatus_callback(struct hv_device *device_obj,
>>  >  				struct rndis_message *resp);
>>  >  int netvsc_recv_callback(struct hv_device *device_obj,
>>  > diff --git a/drivers/net/hyperv/netvsc.c 
>> b/drivers/net/hyperv/netvsc.c
>>  > index 208eb05..9003b94 100644
>>  > --- a/drivers/net/hyperv/netvsc.c
>>  > +++ b/drivers/net/hyperv/netvsc.c
>>  > @@ -707,7 +707,7 @@ static u32 netvsc_copy_to_send_buf(struct
>>  > netvsc_device *net_device,
>>  >  }
>>  >
>>  >  int netvsc_send(struct hv_device *device,
>>  > -			struct hv_netvsc_packet *packet)
>>  > +			struct hv_netvsc_packet *packet, bool kick_q)
>>  >  {
>>  >  	struct netvsc_device *net_device;
>>  >  	int ret = 0;
>>  > @@ -719,6 +719,7 @@ int netvsc_send(struct hv_device *device,
>>  >  	u32 msg_size = 0;
>>  >  	struct sk_buff *skb = NULL;
>>  >  	u16 q_idx = packet->q_idx;
>>  > +	u32 vmbus_flags =
>>  VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
>>  >
>>  >
>>  >  	net_device = get_outbound_net_device(device);
>>  > @@ -768,18 +769,21 @@ int netvsc_send(struct hv_device *device,
>>  >  		return -ENODEV;
>>  >
>>  >  	if (packet->page_buf_cnt) {
>>  > -		ret = vmbus_sendpacket_pagebuffer(out_channel,
>>  > +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
>>  >  						  packet->page_buf,
>>  >  						  packet->page_buf_cnt,
>>  >  						  &sendMessage,
>>  >  						  sizeof(struct
>>  nvsp_message),
>>  > -						  req_id);
>>  > +						  req_id,
>>  > +						  vmbus_flags,
>>  > +						  kick_q);
>>  >  	} else {
>>  > -		ret = vmbus_sendpacket(out_channel, &sendMessage,
>>  > +		ret = vmbus_sendpacket_ctl(out_channel, &sendMessage,
>>  >  				sizeof(struct nvsp_message),
>>  >  				req_id,
>>  >  				VM_PKT_DATA_INBAND,
>>  > -
>>  	VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
>>  > +				vmbus_flags,
>>  > +				kick_q);
>>  >  	}
>>  >
>>  >  	if (ret == 0) {
>>  > diff --git a/drivers/net/hyperv/netvsc_drv.c
>>  > b/drivers/net/hyperv/netvsc_drv.c
>>  > index a06bd66..eae58db 100644
>>  > --- a/drivers/net/hyperv/netvsc_drv.c
>>  > +++ b/drivers/net/hyperv/netvsc_drv.c
>>  > @@ -556,7 +556,7 @@ do_send:
>>  >  	packet->page_buf_cnt = init_page_array(rndis_msg,
>>  rndis_msg_size,
>>  >  					skb, &packet->page_buf[0]);
>>  >
>>  > -	ret = netvsc_send(net_device_ctx->device_ctx, packet);
>>  > +	ret = netvsc_send(net_device_ctx->device_ctx, packet,
>>  > !skb->xmit_more);
>>  >
>>  
>>  Looks like the issue of V2 still there (E.g we need to kick when
>>  hv_ringbuffer_write() returns -EAGAIN?
> 
> Jason, this issue will be handled in the lower layer. I have already 
> submitted a patch to the vmbus
> Driver that correctly signals the host when EAGAIN is encountered.
> 
> Regards,
> 
> K. Y

Okay, find the mail but looks like I was not cced.

Please keep me in the cc list for hyperv patches.

Thanks
