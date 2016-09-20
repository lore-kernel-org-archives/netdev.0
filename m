From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in vxlan_build_skb()
Date: Tue, 20 Sep 2016 08:31:10 -0700
Message-ID: <CALx6S34c=Ftn1PfQ+YRDvbbWUmFW0R1zGC2jgkY0G7Fcx_SM7g@mail.gmail.com>
References: <20160920142700.GJ8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35339 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754599AbcITPbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:31:12 -0400
Received: by mail-qk0-f194.google.com with SMTP id w204so1283503qka.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 08:31:11 -0700 (PDT)
In-Reply-To: <20160920142700.GJ8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 7:27 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> The vxlan header is at offset (14 + 20 + 8) into the packet,
> so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
> functions to modify flags and vni field in the vxh.
>
I'm wondering if VXLAN is just the tip of the iceberg. Wouldn't this
is also be a problem in GRE and Geneve when they encapsulate Ethernet?
What about the outer IP header, wouldn't that potentially have
unaligned accesses also when creating it?

Tom

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
>                 goto out_free;
>
>         vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -       vxh->vx_flags = VXLAN_HF_VNI;
> -       vxh->vx_vni = vxlan_vni_field(vni);
> +       put_unaligned(VXLAN_HF_VNI, &vxh->vx_flags);
> +       put_unaligned(vxlan_vni_field(vni), &vxh->vx_vni);
>
>         if (type & SKB_GSO_TUNNEL_REMCSUM) {
>                 unsigned int start;
> +               __be32 tmpvni = get_unaligned(&vxh->vx_vni);
>
>                 start = skb_checksum_start_offset(skb) - sizeof(struct vxlanhdr);
> -               vxh->vx_vni |= vxlan_compute_rco(start, skb->csum_offset);
> -               vxh->vx_flags |= VXLAN_HF_RCO;
> +               tmpvni |= vxlan_compute_rco(start, skb->csum_offset);
> +               put_unaligned(tmpvni, &vxh->vx_vni);
> +               put_unaligned(VXLAN_HF_VNI | VXLAN_HF_RCO, &vxh->vx_flags);
>
>                 if (!skb_is_gso(skb)) {
>                         skb->ip_summed = CHECKSUM_NONE;
> --
> 1.7.1
>
