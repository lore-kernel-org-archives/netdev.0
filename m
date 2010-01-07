From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Thu, 7 Jan 2010 02:01:22 +0100
Message-ID: <20100107010122.GA5872@electric-eye.fr.zoreil.com>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
 <20100105135732.GA24245@hmsreliant.think-freely.org>
 <4B4357A9.5010507@gmail.com>
 <20100105.124040.192660261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 49.119.116-78.rev.gaoland.net ([78.116.119.49]:33313 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932259Ab0AGHU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 02:20:28 -0500
Content-Disposition: inline
In-Reply-To: <20100105.124040.192660261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 12:40:40PM -0800, David Miller wrote:
[...]
> We can fix this without making things so slow, try harder...

I have reproduced something which seems rather close to the behavior
described in the ccc paper (I have a couple of old PCI rev 10 8169
chipset based network cards).

The setup includes two r8169 face-to-face. The target has an usual
MTU. I tweaked its skb allocation function to include 4000 bytes
of space instead of the usual 1500 something. It is grossly poisoned
to estimate the size of the actual DMA. The RX descriptor has no
knowledge of the extra buffer space above 1500 bytes.

The sender has a bigger MTU (say 6000) and it sends increasingly
sized ping. No rocket science so far.

The result looks like this (so far I checked only one descriptor at
a time when a packet is received):

entry 000 opts1 0x3281c040 opts2 0x00000000 size 066
entry 001 opts1 0x3486c5ec opts2 0x00000000 size 1518
entry 002 opts1 0x3481c040 opts2 0x00000000 size 066
entry 003 opts1 0x3486c5ed opts2 0x00000000 size 1518
entry 004 opts1 0x3486c5ee opts2 0x00000000 size 1518
entry 005 opts1 0x3481c040 opts2 0x00000000 size 066
entry 006 opts1 0x3486c5ef opts2 0x00000000 size 1522
entry 007 opts1 0x3481c040 opts2 0x00000000 size 066
entry 008 opts1 0x3486c5f0 opts2 0x00000000 size 1522 <- first test packet
entry 009 opts1 0x3486c5f1 opts2 0x00000000 size 1522
entry 010 opts1 0x3486c5f2 opts2 0x00000000 size 1522
entry 011 opts1 0x3486c5f3 opts2 0x00000000 size 1526
entry 012 opts1 0x3486c5f4 opts2 0x00000000 size 1526
entry 013 opts1 0x3486c5f5 opts2 0x00000000 size 1526 <- ... so far so good
entry 014 opts1 0x3486c5f6 opts2 0x00000000 size 1526
entry 015 opts1 0x3486c5f7 opts2 0x00000000 size 1530
entry 016 opts1 0x3486c5f8 opts2 0x00000000 size 1530
entry 017 opts1 0x3486c5f9 opts2 0x00000000 size 1530
entry 018 opts1 0x3486c5fa opts2 0x00000000 size 1530
entry 019 opts1 0x3486c5fb opts2 0x00000000 size 1534
entry 020 opts1 0x3486c5fc opts2 0x00000000 size 1534
entry 021 opts1 0x3486c5fd opts2 0x00000000 size 1534
entry 022 opts1 0x3486c5fe opts2 0x00000000 size 1534
entry 023 opts1 0x3486c5ff opts2 0x00000000 size 1536
entry 024 opts1 0x20803ff0 opts2 0x00000000 size 1536 <- problem starts here.
entry 025 opts1 0x00803ff0 opts2 0x00000000 size 1536    The lines below are
entry 026 opts1 0x00803ff0 opts2 0x00000000 size 1536    not meaningful.
entry 027 opts1 0x00803ff0 opts2 0x00000000 size 1536

The driver will mess things up because it needs the desc->opts1.RxRes bit
to be set before it claims that the packet is broken. Since this condition
is not fulfilled when opts1 = 0x20803ff0, the problem goes unnoticed and
it can be further exploited.

AFAIUI, if the driver does not lose sync (to use the paper's words), i.e.
if it notices the condition above and stops / resets the chipset, there
is not much to exploit.

-- 
Ueimor
