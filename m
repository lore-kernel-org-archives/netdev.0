From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 13:41:13 +0100
Message-ID: <1482324073.2260.4.camel@stressinduktion.org>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
         <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
         <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
         <20161219.203623.119653805184192345.davem@davemloft.net>
         <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
         <CAM_iQpUgqJEG544HqH1iwdQFL9-nV3-hMuuH_eU9OnJ--pX+jg@mail.gmail.com>
         <20161220221214.w3zerfiy4wu6apee@codemonkey.org.uk>
         <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
         <1482323232.2260.2.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44228 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750745AbcLUMlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 07:41:17 -0500
In-Reply-To: <1482323232.2260.2.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 13:27 +0100, Hannes Frederic Sowa wrote: 
> @@ -555,8 +566,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
>                 goto out;
>  
>         offset = rp->offset;
> -       total_len = inet_sk(sk)->cork.base.length;
> -       if (offset >= total_len - 1) {
> +       transport_len = raw6_corked_transport_len(sk);
> +       if (offset >= transport_len - 1) {
>                 err = -EINVAL;
>                 ip6_flush_pending_frames(sk);
>                 goto out;
> @@ -598,7 +609,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
>                 tmp_csum = csum_sub(tmp_csum, csum_unfold(csum));
>  
>         csum = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
> -                              total_len, fl6->flowi6_proto, tmp_csum);
> +                              transport_len, fl6->flowi6_proto, tmp_csum);
>  
> 

Ops, here we need actually the total_len plus the opt->opt_nflen to
always calculate the correct checksum.
