From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] ip_tunnel: GSO: Add check for nested encap.
Date: Tue, 10 Jun 2014 08:34:07 -0700
Message-ID: <CA+mtBx9aGBv0arWRdtZbDJpSuzBcan9FEJVRqW5NxJghJrCSVQ@mail.gmail.com>
References: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:44274 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbaFJPeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 11:34:08 -0400
Received: by mail-ig0-f176.google.com with SMTP id a13so5268092igq.3
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 08:34:07 -0700 (PDT)
In-Reply-To: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 4:39 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Current networking stack can only handle single encap packet
> for GSO.  Following patch adds check for already encapsulated
> packet so that we can drop it.
>
We're going to need double encap to support UDP/GRE. The software
stack should be able to mostly work with multiple encapsulations (one
exception would be if there were multiple UDP encapsulations with
mixed enabling of checksums).  We could add GSO_SKB_SW for arbitrary
encapsulation combinations that  we know HW doesn't implement.

> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_tunnel_core.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> index f4c987b..b150546 100644
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -122,12 +122,16 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
>  {
>         int err;
>
> -       if (likely(!skb->encapsulation)) {
> +       if (skb_is_gso(skb)) {
> +               if (unlikely(skb->encapsulation)) {
> +                       /* Current networking GSO stack can handle
> +                        * only one level of encapsulation. */
> +                       err = -ENOSYS;
> +                       goto error;
> +               }
>                 skb_reset_inner_headers(skb);
>                 skb->encapsulation = 1;
> -       }
>
> -       if (skb_is_gso(skb)) {
>                 err = skb_unclone(skb, GFP_ATOMIC);
>                 if (unlikely(err))
>                         goto error;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
