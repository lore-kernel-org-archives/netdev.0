From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 18:45:25 +0200
Message-ID: <87290c65-6276-7b57-e3e7-eacb223c172f@stressinduktion.org>
References: <20160920142700.GJ8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jbenc@redhat.com, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55286 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753964AbcITQp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:45:28 -0400
In-Reply-To: <20160920142700.GJ8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.09.2016 16:27, Sowmini Varadhan wrote:
> The vxlan header is at offset (14 + 20 + 8) into the packet,
> so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
> functions to modify flags and vni field in the vxh.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  drivers/net/vxlan.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
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
>  
>  		if (!skb_is_gso(skb)) {
>  			skb->ip_summed = CHECKSUM_NONE;
> 

The easiest way would be to make struct vxlanhdr __packed. Probably the
best way out of this instead of randomly adding put/get unaligned.

Bye,
Hannes
