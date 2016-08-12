From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH 3/3] vsockmon: Add virtio vsock hooks
Date: Fri, 12 Aug 2016 16:18:54 +0200
Message-ID: <29e24e4f-321b-96ba-4ed5-4e401bed7d4a@deic.uab.cat>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-4-ggarcia@deic.uab.cat>
 <20160810115918.GC10461@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33009 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbcHLOS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 10:18:56 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so3128074wme.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 07:18:56 -0700 (PDT)
In-Reply-To: <20160810115918.GC10461@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2016 01:59 PM, Stefan Hajnoczi wrote:
> On Mon, Aug 08, 2016 at 06:14:42PM +0200, ggarcia@abra.uab.cat wrote:
>> +static struct sk_buff *
>> +virtio_vsock_pkt_vsockmon_to_vsockmon_skb(struct virtio_vsock_pkt *pkt)
>> +{
>> +	struct sk_buff *skb;
>> +	struct af_vsockmon_hdr *hdr;
>> +	void *payload;
>> +
>> +	u32 skb_len = sizeof(struct af_vsockmon_hdr) + pkt->len;
>> +
>> +	skb = alloc_skb(skb_len, GFP_ATOMIC);
>> +	if (!skb)
>> +		return NULL;
>> +
>> +	hdr = (struct af_vsockmon_hdr *) skb_put(skb, sizeof(*hdr));
>> +
>> +	hdr->src_cid = pkt->hdr.src_cid;
>> +	hdr->src_port = pkt->hdr.src_port;
>> +	hdr->dst_cid = pkt->hdr.dst_cid;
>> +	hdr->dst_port = pkt->hdr.dst_port;
>> +	hdr->t = cpu_to_le16(AF_VSOCK_T_VIRTIO);
>> +	hdr->len = cpu_to_le16(sizeof(hdr->t_hdr));
>> +
>> +	switch(pkt->hdr.op) {
>
> Missing le16_to_cpu()
>

Right

>> +	case VIRTIO_VSOCK_OP_REQUEST:
>> +	case VIRTIO_VSOCK_OP_RESPONSE:
>> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONNECT);
>> +		break;
>> +	case VIRTIO_VSOCK_OP_RST:
>> +	case VIRTIO_VSOCK_OP_SHUTDOWN:
>> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_DISCONNECT);
>> +		break;
>> +	case VIRTIO_VSOCK_OP_RW:
>> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_PAYLOAD);
>> +		break;
>> +	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
>> +	case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
>> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONTROL);
>> +		break;
>> +	default:
>> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_UNKNOWN);
>> +		break;
>> +	}
>> +
>> +	hdr->t_hdr.virtio_hdr = pkt->hdr;
>> +
>> +	if (pkt->len) {
>> +		payload = skb_put(skb, pkt->len);
>> +		memcpy(payload, pkt->buf, pkt->len);
>> +	}
>> +
>> +	return skb;
>> +}
>> +
>> +static void vsock_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
>> +{
>> +	struct sk_buff *skb = virtio_vsock_pkt_to_vsockmon_skb(pkt);
>> +	if (skb) {
>> +		vsock_deliver_tap(skb);
>> +		kfree_skb(skb);
>
> Should this be consume_skb()?  The function's doc comment says:
>
>  *	Functions identically to kfree_skb, but kfree_skb assumes that the frame
>  *	is being dropped after a failure and notes that
>
> This isn't a failure case so kfree_skb() is not the right function.
>

I agree, consume_skb is more appropriate.
