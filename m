From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] hyperv: netvsc: Neaten netvsc_send_pkt by using a
 temporary
Date: Mon, 31 Jul 2017 10:05:21 -0700
Message-ID: <20170731100521.63ef6120@xeon-e3>
References: <963fb1dd54804ccd30b1e1249aad4e55ff8d5300.1501449550.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        devel@linuxdriverproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <963fb1dd54804ccd30b1e1249aad4e55ff8d5300.1501449550.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Jul 2017 14:19:30 -0700
Joe Perches <joe@perches.com> wrote:

> Repeated dereference of nvmsg.msg.v1_msg.send_rndis_pkt can be
> shortened by using a temporary.  Do so.
> 
> No change in object code.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good, several other places also suffer from to long.variable.name.wordiness.

Please rebase this on net-next.

> ---
>  drivers/net/hyperv/netvsc.c | 24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 06f39a99da7c..fede1546cdc6 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -743,6 +743,7 @@ static inline int netvsc_send_pkt(
>  	struct sk_buff *skb)
>  {
>  	struct nvsp_message nvmsg;
> +	struct nvsp_1_message_send_rndis_packet *rpkt;

const?

>  	struct netvsc_channel *nvchan
>  		= &net_device->chan_table[packet->q_idx];
>  	struct vmbus_channel *out_channel = nvchan->channel;
> @@ -754,21 +755,17 @@ static inline int netvsc_send_pkt(
>  	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
>  
>  	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
> -	if (skb != NULL) {
> -		/* 0 is RMC_DATA; */
> -		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 0;
> -	} else {
> -		/* 1 is RMC_CONTROL; */
> -		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 1;
> -	}
> +	rpkt = &nvmsg.msg.v1_msg.send_rndis_pkt;
> +	if (skb != NULL)
> +		rpkt->channel_type = 0;		/* 0 is RMC_DATA */
> +	else
> +		rpkt->channel_type = 1;		/* 1 is RMC_CONTROL */
>  
> -	nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_index =
> -		packet->send_buf_index;
> +	rpkt->send_buf_section_index = packet->send_buf_index;
>  	if (packet->send_buf_index == NETVSC_INVALID_INDEX)
> -		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
> +		rpkt->send_buf_section_size = 0;
>  	else
> -		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size =
> -			packet->total_data_buflen;
> +		rpkt->send_buf_section_size = packet->total_data_buflen;
>  
>  	req_id = (ulong)skb;
>  
> @@ -776,8 +773,7 @@ static inline int netvsc_send_pkt(
>  		return -ENODEV;
>  
>  	if (packet->page_buf_cnt) {
> -		pgbuf = packet->cp_partial ? (*pb) +
> -			packet->rmsg_pgcnt : (*pb);
> +		pgbuf = packet->cp_partial ? *pb + packet->rmsg_pgcnt : *pb;
>  		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
>  						      pgbuf,
>  						      packet->page_buf_cnt,

This part just changed (got rid of indirection) in net-next.
