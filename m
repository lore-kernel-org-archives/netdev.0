From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: Leak in ipv6_gso_segment()?
Date: Fri, 2 Jun 2017 14:25:15 -0400
Message-ID: <CAEfhGizesRT9YOfKs09mbnA+PKnG5i2ERmPNyx_+Z6LZ1_bcFQ@mail.gmail.com>
References: <1496233562.3992.10.camel@decadent.org.uk> <20170602.140506.1833605091602891315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ben Hutchings <ben@decadent.org.uk>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:36527 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdFBSZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:25:18 -0400
Received: by mail-qt0-f177.google.com with SMTP id f55so65405304qta.3
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 11:25:18 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by smtp.gmail.com with ESMTPSA id z203sm15518602qkb.46.2017.06.02.11.25.16
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 11:25:17 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id c13so65464832qtc.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 11:25:16 -0700 (PDT)
In-Reply-To: <20170602.140506.1833605091602891315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 2, 2017 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 31 May 2017 13:26:02 +0100
>
>> If I'm not mistaken, ipv6_gso_segment() now leaks segs if
>> ip6_find_1stfragopt() fails.  I'm not sure whether the fix would be as
>> simple as adding a kfree_skb(segs) or whether more complex cleanup is
>> needed.
>
> I think we need to use kfree_skb_list(), like the following.
I think this is problematic as well.  ipv6_gso_segment could
previously return errors, in which case the caller uses kfree_skb (ex
validate_xmit_skb() -> skb_gso_segment -> ...
callbacks.gso_segment()).  Having the kfree_skb_list here would cause
a double free if I'm reading this correctly.

My first guess was going to be skb_gso_error_unwind(), but I'm still
trying to understand that code...

Sorry again for the fallout from this bug fix.  This is my first time
down this code path and I clearly didn't understand it fully :/

> Can someone please audit and review this for me?  We need to
> get this to -stable.
>
> Thanks.
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 280268f..cdb3728 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -116,8 +116,10 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>
>                 if (udpfrag) {
>                         int err = ip6_find_1stfragopt(skb, &prevhdr);
> -                       if (err < 0)
> +                       if (err < 0) {
> +                               kfree_skb_list(segs);
>                                 return ERR_PTR(err);
> +                       }
>                         fptr = (struct frag_hdr *)((u8 *)ipv6h + err);
>                         fptr->frag_off = htons(offset);
>                         if (skb->next)
