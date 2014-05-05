From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: macb: Fix race between HW and driver
Date: Mon, 05 May 2014 17:12:12 -0400 (EDT)
Message-ID: <20140505.171212.1953119275767909182.davem@davemloft.net>
References: <7c62baab-5f60-4f04-87f7-6b53fecc4746@CH1EHSMHS038.ehs.local>
	<20140505.170959.2172440110209805460.davem@davemloft.net>
	<433e19f4-93b3-458e-842e-33c511fdee74@CO9EHSMHS005.ehs.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michal.simek@xilinx.com, nicolas.ferre@atmel.com, git@xilinx.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: soren.brinkmann@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756357AbaEEVMO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 17:12:14 -0400
In-Reply-To: <433e19f4-93b3-458e-842e-33c511fdee74@CO9EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=F6ren Brinkmann <soren.brinkmann@xilinx.com>
Date: Mon, 5 May 2014 14:10:23 -0700

> On Mon, 2014-05-05 at 05:09PM -0400, David Miller wrote:
>> From: S=F6ren Brinkmann <soren.brinkmann@xilinx.com>
>> Date: Mon, 5 May 2014 14:05:19 -0700
>>=20
>> > On Mon, 2014-05-05 at 04:56PM -0400, David Miller wrote:
>> >> From: Soren Brinkmann <soren.brinkmann@xilinx.com>
>> >> Date: Sun,  4 May 2014 15:43:02 -0700
>> >>=20
>> >> > Under "heavy" RX load, the driver cannot handle the descriptors=
 fast
>> >> > enough. In detail, when a descriptor is consumed, its used flag=
 is
>> >> > cleared and once the RX budget is consumed all descriptors with=
 a
>> >> > cleared used flag are prepared to receive more data. Under load=
 though,
>> >> > the HW may constantly receive more data and use those descripto=
rs with a
>> >> > cleared used flag before they are actually prepared for next us=
age.
>> >> >=20
>> >> > The head and tail pointers into the RX-ring should always be va=
lid and
>> >> > we can omit clearing and checking of the used flag.
>> >> >=20
>> >> > Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>> >>=20
>> >> Isn't the RX_USED bit the only thing that controls what RX entrie=
s
>> >> the chip will try to use?
>> >>=20
>> >> I can't see how you can just remove the RX_USED bit handling
>> >> altogether.
>> >>=20
>> >> The problem actually seems to be that in the current code we clea=
r the
>> >> RX_USED bit before we actually reallocate the buffer and set it u=
p.
>> >>=20
>> >> It should be a bug to see the RX_USED bit set in gem_rx_refill(),=
 and
>> >> the only reason why it can happen is exactly because you're clear=
ing it
>> >> too early in gem_rx().
>> >=20
>> > I don't follow. The HW uses the descriptor and the driver handles =
the
>> > received data. So, in gem_rx_refill we should actually only replac=
e
>> > descriptor which have the RX_USED _set_, not? Currently the test t=
ests
>> > for the opposite, since SW clears RX_USED in gem_rx. This patch ju=
st
>> > removes those two parts. The RX_USED is left as is (HW should have=
 set
>> > it). And in gem_rx_refill we simply rely on the head and tail poin=
ters
>> > to refill the used descriptors. I didn't see a reason to do the ad=
ditional
>> > checking of the RX_USED bit.
>> > After the refill the RX_USED flags are of course cleared for all
>> > refilled descriptors.
>>=20
>> Aha, that makes sense, I didn't notice that RX_USED is cleared as a =
side
>> effect of gem_rx_refill()'s work.
>>=20
>> I'll apply this series, thanks for explaining.
>=20
> Thanks, but we probably wanna wait for Nicolas to test on his platfor=
ms
> using macb?

We can always apply a fixup or revert.
