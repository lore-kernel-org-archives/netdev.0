From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Tue, 29 Sep 2015 15:52:07 -0700
Message-ID: <CALx6S35Jg1fOCkXM3zkzPW=GbKV0Ake5NKc8iq2CJ255nKJgag@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
	<CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
	<1443464822.4674.109.camel@infradead.org>
	<CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
	<1443468381.4674.115.camel@infradead.org>
	<CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
	<CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
	<CALx6S35f8hWfBktvou9B41EwFoODYZJZyfetOdLmeeLcuMHT9A@mail.gmail.com>
	<1443510778.4674.123.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36738 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbbI2WwI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:52:08 -0400
Received: by igcrk20 with SMTP id rk20so89109244igc.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:52:08 -0700 (PDT)
In-Reply-To: <1443510778.4674.123.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 12:12 AM, David Woodhouse <dwmw2@infradead.org>=
 wrote:
> On Mon, 2015-09-28 at 20:04 -0700, Tom Herbert wrote:
>>
>> > I've been pondering a bit of a redesign in this space.  I think th=
e
>> > skb struct should be explicit in its instructions to hardware for
>> > which offloads to do for each packet.
>> >
>> > In this way, the stack would be *directly* telling the drivers wha=
t to
>> > do (and what not to do), solving all sorts of bugs and really impr=
oving
>> > driver reliability and implementation.
>> >
>> Doesn't CHECKSUM_PARTIAL with csum_offset and csum_start already tel=
l
>> the driver unambiguously what to do wrt checksum offload?
>
> Right. That's precisely what we *do* have. But as things stand, we
> can't *use* it to its full capability.
>
> It's fine for decent devices which can handle such explicit
> instructions (advertised by the NETIF_F_HW_CSUM feature).
>
> The problem is the crappy devices that can *only* checksum UDP and TC=
P
> frames, advertised with the NETIF_F_IP{V6,}_CSUM features. We make a
> primitive attempt *not* to feed arbitrary checksum requests to such
> hardware. But we fail =E2=80=94 we end up feeding *all* Legacy IP pac=
kets to a
> NETIF_F_IP_CSUM device, and *all* IPv6 packets to a NETIF_F_IPV6_CSUM
> device, regardless of whether they're *actually* TCP or UDP packets.
>
Please look at ixgbe_tx_csum in ixgbe driver. This one example of how
a driver can determine whether the checksum being offloaded is TCP or
UDP. The bug in this driver is that skb_checksum_help is not called
for a protocol the driver isn't looking for. In particular, I believe
this driver will probably send packets with invalid checksums when
TCP/UDP is used with IPv6 packets that contain extension headers.

Tom

> That's the problem I'm trying to solve. And then we *can* make full u=
se
> of the generic checksum offload (I had it working for ICMPv6 at one
> point: http://lists.openwall.net/netdev/2013/01/14/38 ).
>
> --
> David Woodhouse                            Open Source Technology Cen=
tre
> David.Woodhouse@intel.com                              Intel Corporat=
ion
>
