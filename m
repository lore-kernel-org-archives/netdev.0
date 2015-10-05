From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 5 Oct 2015 09:23:55 -0700
Message-ID: <CALx6S34LzN5z3r3U-N_tu_xpzuohiVu1B9-NO5neyDhbmJ20BA@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
	<CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
	<1443464822.4674.109.camel@infradead.org>
	<CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
	<1443468381.4674.115.camel@infradead.org>
	<CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
	<CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
	<CALx6S35f8hWfBktvou9B41EwFoODYZJZyfetOdLmeeLcuMHT9A@mail.gmail.com>
	<1443510778.4674.123.camel@infradead.org>
	<CALx6S35Jg1fOCkXM3zkzPW=GbKV0Ake5NKc8iq2CJ255nKJgag@mail.gmail.com>
	<1444043817.4674.162.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35964 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbbJEQX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 12:23:56 -0400
Received: by ioii196 with SMTP id i196so191006144ioi.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 09:23:56 -0700 (PDT)
In-Reply-To: <1444043817.4674.162.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 4:16 AM, David Woodhouse <dwmw2@infradead.org> w=
rote:
> On Tue, 2015-09-29 at 15:52 -0700, Tom Herbert wrote:
>> Please look at ixgbe_tx_csum in ixgbe driver. This one example of ho=
w
>> a driver can determine whether the checksum being offloaded is TCP o=
r
>> UDP. The bug in this driver is...
>
> I think it serves better as an example of why we don't *want* drivers
> doing that kind of thing for themselves... :)
>
> I propose we steal some high bits from csum_offset, as you suggested,
> and use them to indicate a 'checksum type', which will include TCP an=
d
> UDP.
>
> Then the filter in netif_skb_features() can trivially do the right
> thing for NETIF_F_IP{V6,}_CSUM devices, so avoid feeding them packets
> they can't handle.
>
> You mentioned that you actually want to deprecate those feature flags=
 =E2=80=94
> which works for me, but it's kind of orthogonal. If we do that we'd
> still want to provide generic functions that such drivers can use as
> their .ndo_features_check() method. And we'd *still* want to do the
> check based on a simple flag, rather than grubbing around in the pack=
et
> data. (And the drivers if they *are* asked to do the checksum will
> sometimes care whether it's TCP vs. UDP too).
>
> I don't think we want drivers calling skb_checksum_help() for
> themselves; we want the pre-filter. Mainly because we *definitely*
> don't want drivers calling gso_skb_segment() for themselves in the sa=
me
> situation =E2=80=94 see the comment I posted on Friday about the r816=
9 instance
> of that. ('Re: [PATCH net-next 3/3] r8169: support IPv6').
>
David, here is what I am currently thinking the interface should be:

1) Drivers may advertise NETIF_F_HW_CSUM. The stack will indicate
checksum offload exclusively using the
CHECKSUM_PARTIAL/csum_start/csum_offset interface. No additional
interfaces (bits in skbuff should not be needed)
2) A driver may inspect packets via ndo_check to decide if it wants to
offload the checksum, if not cancels NETIF_F_HW_CSUM in the packet.
3) In driver xmit when CHECKSUM_PARTIAL is set the driver MUST
correctly resolve the checksum-- either by properly offloading to the
device or calling skb_checksum_help.
4) To help drivers for devices with limited offload capabilities we'll
define a helper function to check for typical restrictions (.e.g. IPv4
only, TCP/UDP only. no encapsulation, no IPv6 extension headers,
etc.). I am working on this helper function and will send RFC shortly.

Tom

> --
> David Woodhouse                            Open Source Technology Cen=
tre
> David.Woodhouse@intel.com                              Intel Corporat=
ion
>
