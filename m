From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 11:52:12 +0200
Message-ID: <471C72CC.3090100@cosmosbay.com>
References: <20071022092350.5c75b3bd@poseidon.drzeus.cx>	<20071022.013105.74746322.davem@davemloft.net>	<20071022104208.78c79467@poseidon.drzeus.cx>	<20071022.020538.74751031.davem@davemloft.net> <20071022112605.11f7893e@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pierre Ossman <drzeus@drzeus.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:1660 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXJVJw0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 05:52:26 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2a22.orange.fr (SMTP Server) with ESMTP id C63D470000AA
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 11:52:24 +0200 (CEST)
In-Reply-To: <20071022112605.11f7893e@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pierre Ossman a =E9crit :
> On Mon, 22 Oct 2007 02:05:38 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>
>  =20
>> From: Pierre Ossman <drzeus@drzeus.cx>
>> Date: Mon, 22 Oct 2007 10:42:08 +0200
>>
>>    =20
>>> This seems like a rather evil layering violation.
>>>      =20
>> This has a 10+ year precedence and it's why the Linux networking sta=
ck
>> is so fast.  If you read any other driver you would have seen the
>> skb_reserve() call every one of them do to align the headers.
>>
>>    =20
>
> The norm seems to be to not comment this call. It's hardly obvious.
>
>  =20
This is not obvious you are right, but documented in=20
include/linux/skbuff.h (lines 1150 ...)

/*
 * CPUs often take a performance hit when accessing unaligned memory
 * locations. The actual performance hit varies, it can be small if the
 * hardware handles it or large if we have to take an exception and fix=
 it
 * in software.
 *
 * Since an ethernet header is 14 bytes network drivers often end up wi=
th
 * the IP header at an unaligned offset. The IP header can be aligned b=
y
 * shifting the start of the packet by 2 bytes. Drivers should do this
 * with:
 *
 * skb_reserve(NET_IP_ALIGN);
 *
 * The downside to this alignment of the IP header is that the DMA is n=
ow
 * unaligned. On some architectures the cost of an unaligned DMA is hig=
h
 * and this cost outweighs the gains made by aligning the IP header.
 *
 * Since this trade off varies between architectures, we allow NET_IP_A=
LIGN
 * to be overridden.
 */
#ifndef NET_IP_ALIGN
#define NET_IP_ALIGN    2
#endif

But then, many drivers dont use NET_IP_ALIGN but a hardcoded 2

drivers/net/pcnet32.c:608:              skb_reserve(rx_skbuff, 2);
drivers/net/pcnet32.c:1214:                     skb_reserve(newskb, 2);
drivers/net/pcnet32.c:1245:             skb_reserve(skb, 2);    /* 16=20
byte align */
drivers/net/pcnet32.c:2396:                     skb_reserve(rx_skbuff, =
2);
drivers/net/sundance.c:989:             skb_reserve(skb, 2);    /* 16=20
byte align the IP header. */
drivers/net/sundance.c:1312:                            skb_reserve(skb=
,=20
2);    /* 16 byte align the IP header */
drivers/net/sundance.c:1375:                    skb_reserve(skb, 2); /*=
=20
Align IP on 16 byte boundaries */




