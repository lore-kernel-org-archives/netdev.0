From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] gro: Make GRO aware of lightweight tunnels.
Date: Wed, 20 Jan 2016 18:16:28 -0800
Message-ID: <1453342588.1223.352.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453336048-49406-1-git-send-email-jesse@kernel.org>
	 <1453337308.1223.345.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42g+bc-+=qjZ=Ha8580aZf5=o+2CS6pM1m-gKu47sbPTxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, John <john.phillips5@hpe.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32876 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbcAUCQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:16:30 -0500
Received: by mail-pf0-f180.google.com with SMTP id e65so14690374pfe.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:16:29 -0800 (PST)
In-Reply-To: <CAEh+42g+bc-+=qjZ=Ha8580aZf5=o+2CS6pM1m-gKu47sbPTxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 17:47 -0800, Jesse Gross wrote:

> Just to merge the two threads together, all of protocols that would be
> affected by this also have "normal" GRO handlers that will run when
> the packet is first received. There's no argument that that is
> preferable if it is available. However, GRO cells do provide a
> performance benefit in other situations so it would be nice to avoid
> disabling it if possible.

Note that having a second stage GRO can introduce packet reorders,
because GRO packets given to the second layer simply bypass GRO engine.

Say sender sends P1,P2,P3

Receiver gets P1 alone, put P1 in the GRO cell (2nd layer)

Then we get P2 and P3, aggregated by first layer.

We decap tunnel header, then give P2-P3 to 2nd GRO engine, P2-P3 is
directly given to upper stack. [1]

Then P1 will follow later.

-> packets received out of order. Slow paths on both senders and
receiver, extra sack, ...

[1]

static enum gro_result dev_gro_receive(struct napi_struct *napi, struct
sk_buff *skb)
{
...
        if (!(skb->dev->features & NETIF_F_GRO))
                goto normal;

        if (skb_is_gso(skb) || skb_has_frag_list(skb) || skb->csum_bad)
                goto normal;
