From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] vxlan: fix too large pskb_may_pull with remote checksum
Date: Wed, 16 Mar 2016 10:09:38 -0700
Message-ID: <CALx6S37=BFPfFB5Jwug5VeNJG2qtmVsRxCq-sW=q1knz73ZwhA@mail.gmail.com>
References: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34000 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598AbcCPRJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:09:39 -0400
Received: by mail-io0-f173.google.com with SMTP id m184so67270178iof.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 10:09:39 -0700 (PDT)
In-Reply-To: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 9:35 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The vxlan header is pulled at this point, don't include it again in the
> calculation.
>
Hmm, I think I missing something obvious. Where was the pull of the
vxlan header done?

Thanks,
Tom

> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> This was previously part of the VXLAN-GPE patchset but it's not really
> related (especially not after the discussion that RCO should not be allowed
> together with GPE). I'm sending it separately.
> ---
>  drivers/net/vxlan.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 800106a7246c..1eb8347f440c 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1143,7 +1143,7 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
>  static bool vxlan_remcsum(struct vxlanhdr *unparsed,
>                           struct sk_buff *skb, u32 vxflags)
>  {
> -       size_t start, offset, plen;
> +       size_t start, offset;
>
>         if (!(unparsed->vx_flags & VXLAN_HF_RCO) || skb->remcsum_offload)
>                 goto out;
> @@ -1151,9 +1151,7 @@ static bool vxlan_remcsum(struct vxlanhdr *unparsed,
>         start = vxlan_rco_start(unparsed->vx_vni);
>         offset = start + vxlan_rco_offset(unparsed->vx_vni);
>
> -       plen = sizeof(struct vxlanhdr) + offset + sizeof(u16);
> -
> -       if (!pskb_may_pull(skb, plen))
> +       if (!pskb_may_pull(skb, offset + sizeof(u16)))
>                 return false;
>
>         skb_remcsum_process(skb, (void *)(vxlan_hdr(skb) + 1), start, offset,
> --
> 1.8.3.1
>
