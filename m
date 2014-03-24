From: Alon Nafta <alon@privatecore.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 09:41:21 -0700
Message-ID: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
References: <CAKPWWNHxTaTRLrAV2_u--cq+jUkqWAoA56qJnassaxhgcVL+yA@mail.gmail.com>
	<CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E77C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Grant Grundler <grantgrundler@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34842 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbaCXQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 12:41:23 -0400
Received: by mail-la0-f41.google.com with SMTP id gl10so3852449lab.14
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 09:41:21 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E77C0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for commenting on this.

In regards to your comment about hardware-induced problems, from a
holistic point of view, IMHO any buffer overflow should get fixed.
Specifically, on a locked down, DMA-protected system using any of
these drivers as its network interface, exploiting the driver remains
as one of the few practical ways of "getting in", while other HW-based
attack vectors can be mitigated.

In regards to the patch itself, I agree and was debating myself about
the specific change I should suggest. My intention was to stay as
close as possible to the original code but I can certainly cast to
unsigned instead.

Alon

On Mon, Mar 24, 2014 at 4:00 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alon Nafta
>> Hi,
>>
>> Has anyone looked at this patch?
>>
>> Thanks,
>> Alon
>>
>> On Mon, Feb 24, 2014 at 10:11 AM, Alon Nafta <alon@privatecore.com> wrote:
>> > From: Alon Nafta <alon@privatecore.com>
>> >
>> > Linux Kernel 3.14 contains multiple overflow conditions that are triggered
>> > as hardware inputs are not properly validated when parsing Ethernet packets.
>> > This may allow a local attacker to cause an overflow, resulting in a denial
>> > of service or potentially allowing the execution of arbitrary code.
>
> These are lengths written by hardware, so will only be wrong if the
> hardware is broken.
> If the hardware is broken (or replaced by something malicious)
> then it can do anything it likes.
> Invalid values in ring entries are the least of your worries.
>
> It also isn't clear that generating an overlong packet is
> any better.
>
>> > The programmatic error resides in the use of an integer type to describe
>> > packet lengths, without proper validation to disallow negative values. In
>> > all three (3) bugs this patch fixes, a value of 0x30000 of the hardware
>> > signal, named status, will result in a value of 0xffffffff for pkt_len, and
>> > an allocation of a socket buffer with size of 0x1. This results in an
>> > overflow when data is copied into that buffer.
>> >
>> > Signed-off-by: Alon Nafta <alon@privatecore.com>
>> > Reviewed-by: Grant Grundler <grantgrundler@gmail.com>
>> > ---
>> > diff -uprN -X linux-3.14-rc3/Documentation/dontdiff
>> > linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c
>> > linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c
>> > --- linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
>> > 17:59:14.704084300 -0800
>> > +++ linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
>> > 18:23:08.987749400 -0800
>> > @@ -1635,8 +1635,8 @@ de4x5_rx(struct net_device *dev)
>> >   if (status & RD_OF)           lp->pktStats.rx_overflow++;
>> >       } else {                          /* A valid frame received */
>> >   struct sk_buff *skb;
>> > - short pkt_len = (short)(le32_to_cpu(lp->rx_ring[entry].status)
>> > -                             >> 16) - 4;
>> > + short pkt_len = (short)((le32_to_cpu(lp->rx_ring[entry].status)
>> > +                             >> 16) - 4) & 0x7fff;
>
> There isn't much point masking with 0x7fff and then casting to (short).
> Actually changing the variable to 'unsigned int' might generate
> better code.
>
>         David
>
>
>
