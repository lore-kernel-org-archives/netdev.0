From: Nix <nix@esperi.org.uk>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under high network load, yet again: redux
Date: Mon, 06 Apr 2015 00:29:12 +0100
Message-ID: <87mw2mw3w7.fsf@spindle.srvr.nix>
References: <874mov7otu.fsf@spindle.srvr.nix>
	<20150404210518.GA7698@electric-eye.fr.zoreil.com>
	<877ftqxpea.fsf@spindle.srvr.nix>
	<20150405231510.GA15719@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:42623 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbbDEX3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 19:29:20 -0400
In-Reply-To: <20150405231510.GA15719@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Mon, 6 Apr 2015 01:15:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 Apr 2015, Francois Romieu outgrape:

> Nix <nix@esperi.org.uk> :
> [...]
>> Gross or not, it seems to work: I've loaded it enough to crash it half a
>> dozen times, and not a crash. However, the rx_dropped stats on the link
>> aren't going up, so maybe I've just been lucky.
>
> Rx descriptors are now recycled as soon as they are processed whereas the
> driver used to perform a complete processing batch before recycling any
> descriptor. It could make a huge difference.

Ah, of course, nothing bounds rx rates :( I was stupidly thinking the
TX_RING_SIZE / TX_QUEUE_LEN gap would help us, but of course that's on
the other side. I just shouldn't read code when thick with cold, I make
really stupid thinkos... tx != rx dammit, it's not like they even share
much code in this driver, with rx being run out of napipoll and tx still
being direct...

(I'm still surprised a 64-entry RX ring can run us out of memory,
though: 64 * 1500 isn't that big, even for atomic allocations...)

> The pre-patch rx batch recycling did not include any barrier between
> rp->rx_ring[entry].addr and rp->rx_ring[entry].rx_status updates to
> enforce the ordering.

I bet that's the crucial part. At high rx rates in the pre-patch driver,
you fill up the ring and then lose that race, and disaster ensues.

> Whatever the outcome I'll have to clean my mess though.

Your mess has a) fixed the problem and b) fixed the problem *during the
easter break*. Major kudos.
