From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Sat, 5 Jan 2008 07:10:02 +0100
Message-ID: <20080105061002.GA22739@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist> <20080104034357.GA2113@atjola.homenet> <20080104084517.GA21628@rhlx01.hs-esslingen.de> <20080104101740.GA4406@atjola.homenet> <20080104224352.GA7853@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:48480 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751686AbYAEGKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 01:10:06 -0500
Content-Disposition: inline
In-Reply-To: <20080104224352.GA7853@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.04 23:43:52 +0100, Andreas Mohr wrote:
> On Fri, Jan 04, 2008 at 11:17:40AM +0100, Bj=F6rn Steinbrink wrote:
> > On 2008.01.04 09:45:17 +0100, Andreas Mohr wrote:
> > > And then it needs these card I/O functions wrapped into two
> > > functions which interface with driver- and OS-related MAC
> > > variables (struct variables ALWAYS stored in usual system order,
> > > NOT H/W order!!!!!!) which optionally reverse the address (if
> > > needed for a particular card).
> >=20
> > Hu? The MAC address is only ever reversed when the card is not in
> > use, why the hell would you want to reverse anything when the rest
> > of the OS is involved? This whole reversing stuff is purely before
> > and after the card is actually used. It's not that you need to
> > reverse the address to communicate with the card, it's just
> > initially wrong on the card.
>=20
> Huhrmm? OK, let me ask this then: So what you're saying is that the
> address is only initially wrong (e.g. due to card EEPROM content
> somehow initializing the registers in wrong order on power-on), it's
> not _always_ supposed to be stored in wrong order during operation.
>=20
> IOW, the default card state after power-on is _unusable_ (due to
> invalidly ordered MAC address) and has to be _corrected_ by the
> driver, _initially_ only?

Yeah. _But_, all deduced from the code.

> OTOH I know that at least acx100 has a _permanently_ wrong-ordered MA=
C
> address setup, i.e. it's required to have it in "wrong" order _during
> operation_. And I wouldn't be surprised to see several examples of
> other hardware having a permanently wrongly-ordered address
> requirement, given the amount of MAC reversal in Linux drivers.
>
> Couldn't it be by chance that it's _believed_ to be
> reversed-on-power-on only, whereas those cards should _actually_ have
> it reversed-during-lifetime instead? Such a misunderstanding might
> explain a lot of trouble...

Humm... Wouldn't that have made itself evident? The card's not running
in promisc mode all the time, so there should be some problems if the
card would expect the MAC in the reversed order, right? (At least I see
some code that can switch it into promisc mode, so I assume that it is
not enabled all the time).

There _is_ a comment about some cards not generating any TX interrupts
at all. But that seems to predate any card that stores the MAC address
in correct order (the patch for that came after git, the comment
predates git). So assuming that the card wants the address in reversed
order at runtime, would likely imply that _no_ card would generate TX
interrupts (unless promisc?), and the comment basically invalidates tha=
t
assumption.

> > > And then there will never be any confusion about any MAC address
> > > format anywhere any more, right?
> >=20
> > At probing time, you'll have to know whether the address you read
> > from the hardware is reversed or not. Unless you write it back in
> > reversed order when you release the card, you need a flag that at
> > least survives until nv_probe is called the next time. kexec does
> > not write it back, so you do need such a flag. But the flag
> > apparently doesn't survive a suspend/resume cycle, so you need to
> > write back the reversed address then. But the flag will survive a
> > rmmod + modprobe cycle, so you need to reset it when writing back
> > the reversed address.
>=20
> If it's indeed reversed-on-power-on only, then one probably cannot do
> much about it, thus I'd give up and simply check the MAC address for
> validity (should be very easy to check for a simple reversal by
> checking for the manufacturer-specific fingerprint in reverse order).
> Keeping _any_ sort of state to record the fact that it used to be
> reversed or now is reversed is futile (or rather: catastrophic) given
> the complexity of suspend / virtualisation or whichever other nice
> operations Linux may invent in the future ;)

There was once a patch that checked the vendor specific address part,
long ago. No idea what happened to it. But for kexec, I'd say that that
is broken, too.

- ifconfig eth0 hw ether 00:11:22:00:00:01
- $kexec_incantation

- nv_probe sees 00:11:22:00:00:01
- doesn't match the vendor stuff
- becomes 01:00:00:22:11:00

Oops, that's not quite the expected thing.

No way to tell whether we have to reverse from the address alone AFAICT=
=2E

Bj=F6rn
