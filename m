From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Sat, 17 Mar 2012 11:56:25 +0200
Message-ID: <20120317115625.3fc04de4@vostro>
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
	<20120315191118.GA19809@electric-eye.fr.zoreil.com>
	<20120316221557.235f5ffd@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38098 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab2CQJ5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 05:57:10 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so4592582wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 02:57:09 -0700 (PDT)
In-Reply-To: <20120316221557.235f5ffd@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Mar 2012 22:15:57 +0200 Timo Teras <timo.teras@iki.fi> wrote:

> On Thu, 15 Mar 2012 20:11:18 +0100 Francois Romieu
> <romieu@fr.zoreil.com> wrote:
> 
> > Timo Teras <timo.teras@iki.fi> :
> > [...]
> > > The other broken box is connected to a HP ProCurve 4202vl-48G, and
> > > the switch is reporting drops due to FCS Rx errors.
> > [...]
> > > So I have two broken pieces of hardware, or there is a driver bug.
> > 
> > I'll take blame for any bug in the driver. However many ethernet
> > controllers are and the PCI 8169 is no exception.
> 
> Ok.
> 
> As a side though, all these devices suffered from the bug I fixed
> earlier. See commit 024a07bac (r8169: fix random mdio_write failures).
> Also, all these devices probably got garbage written to their PHY. So
> I'm wondering if it is possible that it caused some permanent damage?
> 
> Would it be possible to dump/compare the related things?
> 
> Additional pointer to this direction is that one of the "broken" boxes
> has different PCI ID for the "broken NIC" of the three. The hardware
> is Jetway daughter board with the three NICs on single board. So it
> sounds really weird that one of those NICs chips would be from
> different series. I wonder if the PCI ID and other stuff could have
> got corrupted in EEPROM or something similar.

It seems that we have working eeprom reading code in commit 6709fe9a27e4
"r8169: read MAC address from EEPROM on init (2nd attempt)" which later
got reverted due to problems. I'm now wondering if those problems were
actually caused by unrelated issues that got later fixed in 78f1cd02457
"r8169: fix broken register writes".

I wonder if it'd be worth to do the eeprom reading and expose it via
ethtool so I can compare those. Or as easy alternative, enabling the VPD
bit in Config1 should allow me to read the EEPROM contents using the PCI
/sys/.../vpd interface, right?

And maybe re-introduce the reading of the MAC from there on reboot. Or
if could just do:
-	Cfg9346_Lock    = 0x00,
+	Cfg9346_Lock    = 0x40,

The 0x40 apparently means "Auto-load: the EEPROM contents will be
reloaded when PCI RSTB signal is asserted, and will automatically
resume to normal 0x00 mode after the load".
