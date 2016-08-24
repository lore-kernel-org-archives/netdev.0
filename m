From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 10:41:24 -0700
Message-ID: <CAOrHB_Dw1MJnfeD034HzGWkMrzEhP6PUKGFP3jDJzeNyRSZcHg@mail.gmail.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
 <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com> <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:55511 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754126AbcHXRl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 13:41:29 -0400
Received: from mfilter27-d.gandi.net (mfilter27-d.gandi.net [217.70.178.155])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 82796C5A68
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 19:41:27 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter27-d.gandi.net (mfilter27-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3LTgmaBmCR3p for <netdev@vger.kernel.org>;
        Wed, 24 Aug 2016 19:41:26 +0200 (CEST)
Received: from mail-it0-f45.google.com (mail-it0-f45.google.com [209.85.214.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 07F3AC5A65
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 19:41:25 +0200 (CEST)
Received: by mail-it0-f45.google.com with SMTP id n128so47167141ith.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 10:41:25 -0700 (PDT)
In-Reply-To: <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 9:37 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 8/24/16 10:28 AM, pravin shelar wrote:
>>> How do you feel about implementing the do_output() idea I suggested above?
>>> I'm happy to provide testing and review.
>>
>> I am not sure about changing do_output(). why not just use same scheme
>> to track mpls header in OVS datapath as done in mpls device?
>>
>
> was just replying with the same.
>
> Something like this should be able to handle multiple labels. The inner network header is set once and the outer one pointing to MPLS is adjusted each time a label is pushed:
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1ecbd7715f6d..0f37b17e3a73 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -162,10 +162,16 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         if (skb_cow_head(skb, MPLS_HLEN) < 0)
>                 return -ENOMEM;
>
> +       if (!skb->inner_protocol) {
> +               skb_set_inner_network_header(skb, skb->mac_len);
> +               skb_set_inner_protocol(skb, skb->protocol);
> +       }
> +
>         skb_push(skb, MPLS_HLEN);
>         memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
>                 skb->mac_len);
>         skb_reset_mac_header(skb);
> +       skb_set_network_header(skb, skb->mac_len);
>
>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>         *new_mpls_lse = mpls->mpls_lse;
> @@ -173,8 +179,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
>
>         update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
> -       if (!skb->inner_protocol)
> -               skb_set_inner_protocol(skb, skb->protocol);
> +
>         skb->protocol = mpls->mpls_ethertype;
>
>         invalidate_flow_key(key);
>
>
>
>
> If it does, what else needs to be changed in OVS to handle the network layer now pointing to the MPLS labels?
>
You also need to change pop_mpls().

Anyways I was thinking about the neigh output functions skb pull
issue, where it is using network-header offset. Can we use mac_len?
this way we would not use any inner offsets for MPLS skb and current
scheme used by OVS datapath works.
