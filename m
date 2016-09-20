From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 18:11:14 +0200
Message-ID: <20160920181114.0ac7cfa0@griffin>
References: <20160920142700.GJ8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932692AbcITQLS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 12:11:18 -0400
In-Reply-To: <20160920142700.GJ8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 10:27:00 -0400, Sowmini Varadhan wrote:
> The vxlan header is at offset (14 + 20 + 8) into the packet,
> so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
> functions to modify flags and vni field in the vxh.

How did you calculate that? IP header should be aligned to 4 bytes, UDP
header is 8 bytes, thus VXLAN header is also aligned to 4 bytes.

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e7d1668..f903fa4 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1751,15 +1751,17 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
>  		goto out_free;
>  
>  	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -	vxh->vx_flags = VXLAN_HF_VNI;
> -	vxh->vx_vni = vxlan_vni_field(vni);
> +	put_unaligned(VXLAN_HF_VNI, &vxh->vx_flags);
> +	put_unaligned(vxlan_vni_field(vni), &vxh->vx_vni);
>  
>  	if (type & SKB_GSO_TUNNEL_REMCSUM) {
>  		unsigned int start;
> +		__be32 tmpvni = get_unaligned(&vxh->vx_vni);
>  
>  		start = skb_checksum_start_offset(skb) - sizeof(struct vxlanhdr);
> -		vxh->vx_vni |= vxlan_compute_rco(start, skb->csum_offset);
> -		vxh->vx_flags |= VXLAN_HF_RCO;
> +		tmpvni |= vxlan_compute_rco(start, skb->csum_offset);
> +		put_unaligned(tmpvni, &vxh->vx_vni);
> +		put_unaligned(VXLAN_HF_VNI | VXLAN_HF_RCO, &vxh->vx_flags);

If you went this way, it would be better to make two local variables
for vx_flags and vx_vni, store to them and do a single put_unaligned
after the condition. That way, you would have two less put_unaligned and
no get_unaligned in the remote csum case. And the code would be
cleaner. And you're missing vx_flags being accessed in
vxlan_build_gbp_hdr.

But I think this is not needed at all, see above.

 Jiri
