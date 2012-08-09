From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Thu, 9 Aug 2012 11:43:32 +0000
Message-ID: <201208091143.32972.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <50226779.6060201@codethink.co.uk> <50239815.6020108@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Molton <ian.molton@codethink.co.uk>,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	ben.dooks@codethink.co.uk, dale@farnsworth.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:54478 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab2HILoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 07:44:24 -0400
In-Reply-To: <50239815.6020108@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On 08/08/12 14:19, Ian Molton wrote:
 > On 08/08/12 13:39, Arnd Bergmann wrote:
 >> On Wednesday 08 August 2012, Ian Molton wrote:
 >>> This method would require a small amount of rework in the driver to
 >>> set up <n> ports, rather than just one.
 >> This looks quite nice, but it is still very much incompatible with the
 >> existing binding. Obviously we can abandon an existing binding and
 >> introduce a second one for the same hardware, but that should not
 >> be taken lightly.
 > Fair, however the existing users aren't anywhere near as
 > numerous as the new ones.

Depends on how you count the numbers. I see at least three machines
supported in the kernel with the old binding and none with the new one
so far ;-)

 >> I don't fully understand your concern with the overlapping
 >> registers, mostly because I still don't know all the combinations
 >> that are actually valid here. Let me try to say what I understood
 >> so far, and you can correct me if that's wrong:
 >>
 >> * A system can have multiple instances of an mv64360 ethernet
 >> block, with a register area of 0x2000 bytes.
 >> * Each such block can have three MACs and three PHYs.
 >> * The first 0x400 bytes in the register space control the three
 >>   PHYs and the remaining registers control the MACs.
 >> * While this is meant to be used in a way that you assign
 >>   the each of the three PHYs to one of the MACs, this is not
 >>   always done, and sometimes you use a different PHY (?), or
 >>   one from a different instance of the mv64360 ethernet block
 >>   on the same SoC?.
 > Nearly - the whole block is 0x2000 in size, yes. And each one
 > can have 3 MACs and PHYs, as you say.
 >
 > There is SMI @ 0x2000 - just one for all ports, and in many
 > (all?) cases, for all all the other controllers on the SoC to
 > share. On the armadaXP SoC, for example, each ethernet
 > block has its own alias of the same bas SMI reg. (there are
 > 4 blocks)
 >
 > ethernet0@ 0x2400
 > ## regs in order: Main regs, MIB counters, Special mcast table, Mcast
 > table, Unicast table.
 >    port0 has regs at +0x0000 *0x1000 +0x1400 +0x1500 +0x1600
 >    port1 has regs at +0x0400 *0x1080 +0x1800 +0x1900 +0x1a00
 >    port2 has regs at +0x0800 *0x1100 +0x1c00 +0x1d00 +0x1e00
 > ethernet1@ 0x6400
 >   port0 has regs at +0x0000 *0x1000 +0x1400 +0x1500 +0x1600
 > ...
 >
 > As you can see, instead of putting port1 at +0x1700 or so,
 > marvell have overlapped the register files - in fact, doubly
 > so, since port1 + 0x1080 is right in the middle of
 > (port0 + 0x1000) -> (port0 + 0x16ff), so one cant simply map two
 > sets of regs like 0x0000->0x03ff and 0x1000->0x16ff for port one
 > either.

This could theoretically be dealt with by having 5 register ranges
per device, but that would cause extra overhead and also be
incompatible with the existing binding. I think showing one
parent device with children at address 0, 1 and 2 is ok. The driver
already knows all those offsets and they are always the same
for all variants of mv643xx, right?

	Arnd
