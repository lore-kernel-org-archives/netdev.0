From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to optimize
 signaling the host
Date: Mon, 11 May 2015 08:59:53 +0000
Message-ID: <BY2PR0301MB0711C1248DF6677217A310BCA0DB0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1431317294-16442-1-git-send-email-kys@microsoft.com>
 <1431323894.2884.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431323894.2884.4.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Sunday, May 10, 2015 10:58 PM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to
> optimize signaling the host
> 
> On Sun, 2015-05-10 at 21:08 -0700, K. Y. Srinivasan wrote:
> > Based on the information given to this driver (via the xmit_more skb flag),
> > we can defer signaling the host if more packets are on the way. This will
> help
> > make the host more efficient since it can potentially process a larger batch
> of
> > packets. Implement this optimization.
> 
> trivia:
> 
> I think that indirecting
> VMBUS_DATA_PACKET_FLAG_COMPLETTION_REQUESTED
> into a non-const temporary isn't very useful.
> 
> Whenever overly long identifiers like VMBUS_<FOO> is used,
> I think that it'd be better to use it directly and ignore
> 80 column warnings.

Thanks Joe; if Dave agrees, I can send v6 of this patch out.

Regards,

K. Y
> 
> Same with the "sizeof(struct nvsp_message)" on two lines.
> 
> > diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> []
> > @@ -743,6 +743,8 @@ static inline int netvsc_send_pkt(
> >  	u64 req_id;
> >  	int ret;
> >  	struct hv_page_buffer *pgbuf;
> > +	u32 vmbus_flags =
> VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
> > +	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel-
> >outbound);
> []
> > @@ -769,30 +771,41 @@ static inline int netvsc_send_pkt(
> []
> > +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> > +						      pgbuf,
> > +						      packet->page_buf_cnt,
> > +						      &nvmsg,
> > +						      sizeof(struct
> > +							     nvsp_message),
> > +						      req_id,
> > +						      vmbus_flags,
> > +						      !packet->xmit_more);
> 
> []
> 
> >  			netif_tx_stop_queue(netdev_get_tx_queue(
> >  					    ndev, q_idx));
> 
> This could be on one line too.
> 
