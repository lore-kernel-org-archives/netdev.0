From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Thu, 15 Mar 2012 20:47:19 +0200
Message-ID: <20120315204719.487b6ffe@vostro>
References: <20120314190156.622c8cd5@vostro>
	<1331745314.6022.27.camel@edumazet-glaptop>
	<20120314192945.65867e9f@vostro>
	<1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	<20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
	<20120314223343.23dc9df3@vostro>
	<20120314205319.GA28394@electric-eye.fr.zoreil.com>
	<20120315080635.1f76512b@vostro>
	<20120315171148.0050714d@vostro>
	<1331827906.4874.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46495 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757690Ab2COSr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 14:47:58 -0400
Received: by bkcik5 with SMTP id ik5so2361495bkc.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 11:47:57 -0700 (PDT)
In-Reply-To: <1331827906.4874.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Mar 2012 09:11:46 -0700 Eric Dumazet
<eric.dumazet@gmail.com> wrote:

> On Thu, 2012-03-15 at 17:11 +0200, Timo Teras wrote:
> > On Thu, 15 Mar 2012 08:06:35 +0200 Timo Teras <timo.teras@iki.fi>
> > wrote:
> > 
> > > On Wed, 14 Mar 2012 21:53:19 +0100 Francois Romieu
> > > <romieu@fr.zoreil.com> wrote:
> > > 
> > > > Timo Teras <timo.teras@iki.fi> :
> > > > [...]
> > > > > # ethtool -S eth2
> > > > > NIC statistics:
> > > > >      tx_packets: 2069391193
> > > > >      rx_packets: 3245815642
> > > > >      tx_errors: 0
> > > > >      rx_errors: 645238
> > > > >      rx_missed: 31414
> > > > 
> > > > It does not look like stuff for the higher layers guys.
> > > > 
> > > > Can you tshark -w foobar on the sender side and
> > > > 'while : ; do sleep 1; ethtool -S eth2 >> glop; done' on the
> > > > receiver during a bad wget (a big zero filled file should
> > > > compress well).
> > > 
> > > Indeed.
> > > 
> > > It seems that my earlier test about the "GRO off" effect were
> > > mistaken (I used accidentally proxy, and that gave the illusion
> > > that things are working. Whoops.)
> > > 
> > > So far I changed the cross-over cable and it didn't help. However,
> > > forcing the NIC to 100mbit/full-duplex mode fixes the rx_errors.
> > > It seems that something bad is happening in the gigabit mode.
> > > 
> > > I wonder if it's using pause frames and that's messing things up.
> > > Seems that I can't turn it off, though.
> > > 
> > > I can also double check my cables, though it is factory made
> > > Cat-5E cross-over cable; and happens with two different cables.
> > 
> > Ok. So far I have two of these boxes with same r8169 hardware. Both
> > generate bad packets on transmit only; and on both 3 nic systems
> > it's the middle eth1 nic. The symptoms are identical: in 1GB mode I
> > have minor packet loss, where as 100Mbit/s mode seems to work just
> > fine.
> > 
> > The first box, that I've been talking so far about, is as mentioned
> > connected to another similar box. The r8169 there reports rx_errors.
> > The cable is ok; I've tried with two different ones.
> > 
> > The other broken box is connected to a HP ProCurve 4202vl-48G, and
> > the switch is reporting drops due to FCS Rx errors.
> > 
> > So I have two broken pieces of hardware, or there is a driver bug.
> > 
> > I'll try upgrading my kernel to 3.0.x series on the sender box and
> > see if it's fixing anything. Suggestions for further testing would
> > be appreciated.
> 
> r8169 has to make an additional copy of incoming frames, because of
> hardware flaw and security requirements.
> 
> This was added in 2.6.37 or 2.6.38, dont remember exactly.
> 
> So your cpu might be to slow to handle the load at 1Gb speed.
> 
> If you have one flow, there is nothing to do, but if your workload has
> several flows and your machine is SMP, you can try RPS/RFS as
> documented in Documentation/networking/scaling.txt

No. It's exactly the same amount of traffic on link: approx
50-80mbit/s. If link is in 100mbit/s mode, everything is perfect. But
if link is in 1gbit/s mode (but having only the 50-80mbit/s in average),
it's getting packet loss (and kills TCP performance).

There is definitely a hardware or a driver issue.
