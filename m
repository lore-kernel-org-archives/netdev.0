From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Wed, 18 Jan 2017 10:18:18 -0800
Message-ID: <CAOrHB_A-oJid6RTeQB_xy0GDKsJjvEDwdTepMXN336qSi5h8AA@mail.gmail.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
 <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23> <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>,
        Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:59177 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751659AbdARSSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 13:18:23 -0500
Received: from mfilter24-d.gandi.net (mfilter24-d.gandi.net [217.70.178.152])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 62340172094
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 19:18:21 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter24-d.gandi.net (mfilter24-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id mBgzHUj5aHy0 for <netdev@vger.kernel.org>;
        Wed, 18 Jan 2017 19:18:20 +0100 (CET)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com [209.85.214.50])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id E0A991720C3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 19:18:19 +0100 (CET)
Received: by mail-it0-f50.google.com with SMTP id 203so123411565ith.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 10:18:19 -0800 (PST)
In-Reply-To: <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 8:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-01-17 at 20:21 -0800, Eric Dumazet wrote:
>> On Wed, 2017-01-18 at 03:12 +0000, Ashizuka, Yuusuke wrote:
>>
>> > indeed.
>> >
>> > In the case of TSO with i.MX6 system (highmem enabled) with 2GB memory,
>> > "this_frag->page.p" did not become highmem area.
>> > (We confirmed by transferring about 100MB of files)
>> >
>> > However, in the case of non-tso on an i.MX6 system with 2GB of memory,
>> > "this_frag->page.p" may become a highmem area.
>> > (Occurred with approximately 2MB of file transfer)
>> >
>> > For non-tso only, I do not know the reason why "this_frag-> page.p"
>> > in this driver shows highmem area.
>>
>> This worries me, since this driver does not set NETIF_F_HIGHDMA in its
>> features.
>>
>> No packet should be given to this driver with a highmem fragment
>>
>> Check is done in illegal_highdma() in net/core/dev.c
>
> This used to work.
>
> I suspect commit ec5f061564238892005257c83565a0b58ec79295
> ("net: Kill link between CSUM and SG features.")
>
> added this bug.
>
> Can you try this hot fix :
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ad5959e561166f445bdd9d7260652a338f74cfea..073b832b945257dba9ed47f4bf875605225effc9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2773,9 +2773,9 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
>         if (skb->ip_summed != CHECKSUM_NONE &&
>             !can_checksum_protocol(features, type)) {
>                 features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
> -       } else if (illegal_highdma(skb->dev, skb)) {
> -               features &= ~NETIF_F_SG;
>         }
> +       if (illegal_highdma(skb->dev, skb))
> +               features &= ~NETIF_F_SG;
>
>         return features;
>  }

Right, this high mem check should be decoupled from csum check.

Thanks,
Pravin.
