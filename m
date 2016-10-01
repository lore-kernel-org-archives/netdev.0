From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Sat, 1 Oct 2016 20:52:15 +0100
Message-ID: <20161001195215.GP1041@n2100.armlinux.org.uk>
References: <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
 <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010E25C@AcuExch.aculab.com>
 <af74a33e-a164-bd2f-4c63-24a128d1ffb5@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010FE38@AcuExch.aculab.com>
 <638d2aa0-eb4a-dd4b-e516-d7ad89eca627@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:38812 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbcJATwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 15:52:31 -0400
Content-Disposition: inline
In-Reply-To: <638d2aa0-eb4a-dd4b-e516-d7ad89eca627@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 07:16:12AM -0700, Eric Nelson wrote:
> On ARM, the CPU can't handle misaligned memory cycles without
> taking an alignment fault and NET_IP_ALIGN is set to 2.

Let's get this right...  With Linux on MMU parts:

On ARMv6+, unaligned memory cycles using the LDR, LDRH and corresponding
store instructions are handled in hardware without any exception being
raised.

On pre-ARMv6, such instructions raise an alignment exception, and we fix
up the load/store manually.

Where things behave the same is with the LDM (load multiple) and STM
(store multiple) instructions.  Hardware does not fix these up if they
are unaligned: it is expected that the base address will always be
aligned to a 32-bit word.

For some reason, the compiler guys have decided it's okay to use these
instructions as an optimisation, and I see no way to disable this
behaviour.

> On ARM, we have CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> but I find it hard to believe that taking alignment faults is more
> efficient than adding two bytes to the start of the frame.

... see above, hence why CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set.
It's only when the compiler decides to do silly things that things go
wrong.  However, net code does not care about that configuration
setting, so it's irrelevant to this discussion.

The issue with the networking layer is that it passes around structure
pointers which may not be "naturally aligned" - technically it goes
against the C standard specs.  However, you'll find it hard to argue
against this, so we have to accept that the networking people expect
it to work.

The optimisation that the C compiler uses (using LDM to access multiple
32-bit consecutive words) is legal and efficient when the structure
pointers are aligned as it expects, but that all breaks if the pointer
is not so aligned.  So, raising it as a bug against the C compiler isn't
going to work either.

What may work is to raise a feature request with compiler people to have
a mechanism to disable the LDM/STM optimisation for code where we know
that pointers may not be naturally aligned.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
