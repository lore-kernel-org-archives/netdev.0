From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 11:00:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E77C0@AcuExch.aculab.com>
References: <CAKPWWNHxTaTRLrAV2_u--cq+jUkqWAoA56qJnassaxhgcVL+yA@mail.gmail.com>
 <CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Grant Grundler <grantgrundler@gmail.com>
To: 'Alon Nafta' <alon@privatecore.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57868 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752861AbaCXLAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 07:00:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17768-02 for <netdev@vger.kernel.org>;
 Mon, 24 Mar 2014 11:00:51 +0000 (GMT)
In-Reply-To: <CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alon Nafta
> Hi,
> 
> Has anyone looked at this patch?
> 
> Thanks,
> Alon
> 
> On Mon, Feb 24, 2014 at 10:11 AM, Alon Nafta <alon@privatecore.com> wrote:
> > From: Alon Nafta <alon@privatecore.com>
> >
> > Linux Kernel 3.14 contains multiple overflow conditions that are triggered
> > as hardware inputs are not properly validated when parsing Ethernet packets.
> > This may allow a local attacker to cause an overflow, resulting in a denial
> > of service or potentially allowing the execution of arbitrary code.

These are lengths written by hardware, so will only be wrong if the
hardware is broken.
If the hardware is broken (or replaced by something malicious)
then it can do anything it likes.
Invalid values in ring entries are the least of your worries.

It also isn't clear that generating an overlong packet is
any better.

> > The programmatic error resides in the use of an integer type to describe
> > packet lengths, without proper validation to disallow negative values. In
> > all three (3) bugs this patch fixes, a value of 0x30000 of the hardware
> > signal, named status, will result in a value of 0xffffffff for pkt_len, and
> > an allocation of a socket buffer with size of 0x1. This results in an
> > overflow when data is copied into that buffer.
> >
> > Signed-off-by: Alon Nafta <alon@privatecore.com>
> > Reviewed-by: Grant Grundler <grantgrundler@gmail.com>
> > ---
> > diff -uprN -X linux-3.14-rc3/Documentation/dontdiff
> > linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c
> > linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c
> > --- linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
> > 17:59:14.704084300 -0800
> > +++ linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
> > 18:23:08.987749400 -0800
> > @@ -1635,8 +1635,8 @@ de4x5_rx(struct net_device *dev)
> >   if (status & RD_OF)           lp->pktStats.rx_overflow++;
> >       } else {                          /* A valid frame received */
> >   struct sk_buff *skb;
> > - short pkt_len = (short)(le32_to_cpu(lp->rx_ring[entry].status)
> > -                             >> 16) - 4;
> > + short pkt_len = (short)((le32_to_cpu(lp->rx_ring[entry].status)
> > +                             >> 16) - 4) & 0x7fff;

There isn't much point masking with 0x7fff and then casting to (short).
Actually changing the variable to 'unsigned int' might generate
better code.

	David
