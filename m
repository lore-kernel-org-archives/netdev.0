From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 3/3 net-next] hyperv: Support batched notification
Date: Thu, 12 Mar 2015 03:33:36 +0000
Message-ID: <BY2PR0301MB0711D45CB8B5AD14D5BAF75AA0060@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1426100635-9508-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-3-git-send-email-kys@microsoft.com>
 <1426129712.12154.3@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1426129712.12154.3@smtp.corp.redhat.com>
Content-Language: en-US
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



> -----Original Message-----
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Wednesday, March 11, 2015 8:09 PM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; gregkh@linuxfoundation.org; KY Srinivasan
> Subject: Re: [PATCH V2 3/3 net-next] hyperv: Support batched notification
> 
> 
> 
> On Thu, Mar 12, 2015 at 3:04 AM, K. Y. Srinivasan <kys@microsoft.com>
> wrote:
> > Optimize notifying the host by deferring notification until there are
> > no more packets to be sent. This will help in batching the requests on
> > the host.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/net/hyperv/hyperv_net.h   |    2 +-
> >  drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
> >  drivers/net/hyperv/netvsc_drv.c   |    3 ++-
> >  drivers/net/hyperv/rndis_filter.c |    2 +-
> >  4 files changed, 13 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> > b/drivers/net/hyperv/hyperv_net.h index 4815843..3fd9896 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -184,7 +184,7 @@ struct rndis_device {  int
> > netvsc_device_add(struct hv_device *device, void *additional_info);
> > int netvsc_device_remove(struct hv_device *device);  int
> > netvsc_send(struct hv_device *device,
> > -		struct hv_netvsc_packet *packet);
> > +		struct hv_netvsc_packet *packet, bool kick_q);
> >  void netvsc_linkstatus_callback(struct hv_device *device_obj,
> >  				struct rndis_message *resp);
> >  int netvsc_recv_callback(struct hv_device *device_obj, diff --git
> > a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c index
> > 208eb05..9003b94 100644
> > --- a/drivers/net/hyperv/netvsc.c
> > +++ b/drivers/net/hyperv/netvsc.c
> > @@ -707,7 +707,7 @@ static u32 netvsc_copy_to_send_buf(struct
> > netvsc_device *net_device,  }
> >
> >  int netvsc_send(struct hv_device *device,
> > -			struct hv_netvsc_packet *packet)
> > +			struct hv_netvsc_packet *packet, bool kick_q)
> >  {
> >  	struct netvsc_device *net_device;
> >  	int ret = 0;
> > @@ -719,6 +719,7 @@ int netvsc_send(struct hv_device *device,
> >  	u32 msg_size = 0;
> >  	struct sk_buff *skb = NULL;
> >  	u16 q_idx = packet->q_idx;
> > +	u32 vmbus_flags =
> VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
> >
> >
> >  	net_device = get_outbound_net_device(device); @@ -768,18
> +769,21 @@
> > int netvsc_send(struct hv_device *device,
> >  		return -ENODEV;
> >
> >  	if (packet->page_buf_cnt) {
> > -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> > +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> >  						  packet->page_buf,
> >  						  packet->page_buf_cnt,
> >  						  &sendMessage,
> >  						  sizeof(struct
> nvsp_message),
> > -						  req_id);
> > +						  req_id,
> > +						  vmbus_flags,
> > +						  kick_q);
> >  	} else {
> > -		ret = vmbus_sendpacket(out_channel, &sendMessage,
> > +		ret = vmbus_sendpacket_ctl(out_channel, &sendMessage,
> >  				sizeof(struct nvsp_message),
> >  				req_id,
> >  				VM_PKT_DATA_INBAND,
> > -
> 	VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
> > +				vmbus_flags,
> > +				kick_q);
> >  	}
> >
> >  	if (ret == 0) {
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > b/drivers/net/hyperv/netvsc_drv.c index a06bd66..80b4b29 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -384,6 +384,7 @@ static int netvsc_start_xmit(struct sk_buff *skb,
> > struct net_device *net)
> >  	u32 net_trans_info;
> >  	u32 hash;
> >  	u32 skb_length = skb->len;
> > +	bool kick_q = !skb->xmit_more;
> >
> >
> >  	/* We will atmost need two pages to describe the rndis @@ -556,7
> > +557,7 @@ do_send:
> >  	packet->page_buf_cnt = init_page_array(rndis_msg,
> rndis_msg_size,
> >  					skb, &packet->page_buf[0]);
> >
> > -	ret = netvsc_send(net_device_ctx->device_ctx, packet);
> > +	ret = netvsc_send(net_device_ctx->device_ctx, packet, kick_q);
> 
> Maybe just a !skb->xmit_more here to save a local variable.

Will fix it.

K. Y
