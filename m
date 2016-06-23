From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC v2 3/3] vsockmon: Add vsock hooks
Date: Thu, 23 Jun 2016 15:09:22 +0300
Message-ID: <1ba72b1f-c535-3798-cb21-e5d4d1ce622b@cogentembedded.com>
References: <20160622161102.8250-1-ggarcia@deic.uab.cat>
 <20160622161102.8250-4-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhansen@vmware.com, stefanha@redhat.com
To: ggarcia@abra.uab.cat, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34974 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbcFWMJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 08:09:25 -0400
Received: by mail-lf0-f50.google.com with SMTP id l188so93273877lfe.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 05:09:25 -0700 (PDT)
In-Reply-To: <20160622161102.8250-4-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/22/2016 7:11 PM, ggarcia@abra.uab.cat wrote:

> From: Gerard Garcia <ggarcia@deic.uab.cat>
>
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  drivers/vhost/vsock.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 73 insertions(+)
>
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 17bfe4e..e8621cc 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
[...]
> @@ -45,6 +47,69 @@ struct vhost_vsock {
>  	u32 guest_cid;
>  };
>
> +static struct sk_buff *
> +virtio_vsock_pkt_to_skb(struct virtio_vsock_pkt *pkt)
> +{
> +	struct sk_buff *skb;
> +	struct af_vsockmon_hdr *hdr;
> +	void *payload;
> +
> +	u32 skb_len = sizeof(struct af_vsockmon_hdr) + pkt->len;
> +
> +	skb = alloc_skb(skb_len, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, sizeof(struct af_vsockmon_hdr));
> +
> +	if (pkt->len) {
> +		payload = skb_put(skb, pkt->len);
> +		memcpy(payload, pkt->buf, pkt->len);
> +	}
> +
> +	hdr = (struct af_vsockmon_hdr *) skb_push(skb, sizeof(*hdr));
> +
> +	hdr->src_cid = pkt->hdr.src_cid;
> +	hdr->src_port = pkt->hdr.src_port;
> +	hdr->dst_cid = pkt->hdr.dst_cid;
> +	hdr->dst_port = pkt->hdr.dst_port;
> +	hdr->t = AF_VSOCK_T_VIRTIO;
> +
> +	switch(pkt->hdr.op) {
> +		case VIRTIO_VSOCK_OP_REQUEST:
> +		case VIRTIO_VSOCK_OP_RESPONSE:
> +			hdr->op = AF_VSOCK_OP_CONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RST:
> +		case VIRTIO_VSOCK_OP_SHUTDOWN:
> +			hdr->op = AF_VSOCK_OP_DISCONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RW:
> +			hdr->op = AF_VSOCK_OP_PAYLOAD;
> +			break;
> +		case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
> +		case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
> +			hdr->op = AF_VSOCK_OP_CONTROL;
> +			break;
> +		default:
> +			hdr->op = AF_VSOCK_OP_UNKNOWN;
> +			break;
> +	}

    CodingStyle: *switch* and *case* should be at the same indentation level.

[...]

MBR, Sergei
