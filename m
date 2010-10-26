From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] net: Fix some corner cases in dev_can_checksum()
Date: Tue, 26 Oct 2010 11:11:32 -0700
Message-ID: <AANLkTin+H0MKSesUKXSLzi55TrdoJMxmBhAcr=p-N6S0@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-5-git-send-email-jesse@nicira.com>
	<1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
	<AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
	<1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
	<AANLkTi=PiB_oCvaFzQpUNhgV8qsn9d-jy_ejGdbOTzQe@mail.gmail.com>
	<20101026132918.GG15074@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47079 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933244Ab0JZSLd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:11:33 -0400
Received: by wyf28 with SMTP id 28so4925153wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:11:32 -0700 (PDT)
In-Reply-To: <20101026132918.GG15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 6:29 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Jesse Gross wrote:
>> On Fri, Oct 22, 2010 at 7:12 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > dev_can_checksum() incorrectly returns true in these cases:
>> >
>> > 1. The skb has both out-of-band and in-band VLAN tags and the devi=
ce
>> > =A0 supports checksum offload for the encapsulated protocol but on=
ly with
>> > =A0 one layer of encapsulation.
>> > 2. The skb has a VLAN tag and the device supports generic checksum=
ming
>> > =A0 but not in conjunction with VLAN encapsulation.
>> >
>> > Rearrange the VLAN tag checks to avoid these.
>> >
>> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>>
>> If we assume that cards cannot handle offloading for double tagged
>> packets, which is obviously the most conservative approach, we
>> probably also need to change the checks for TSO/SG. =A0There's no is=
sue
>> with extracting the protocol from the right header but we might assu=
me
>> that the card can handle double tag offloading when it can't. =A0For
>> both TSO/SG we check if there is either an in-band tag or out-of-ban=
d
>> tag and use dev->vlan_features if that is the case. =A0Maybe we need=
 to
>> handle it in software if it is double tagged.
>
> That's something to check.
>
>> On the other hand, I don't know whether it's true that cards can't
>> handle offloading for packets tagged in both manners. =A0I suppose t=
hat
>> it depends on where the offloading and tagging are in the pipeline.
>> For example, when it comes to SG I doubt that the cards care about
>> vlan tags much at all.
>
> I do know that current Solarflare controllers can parse two VLAN tags
> and generate/validate TCP/IP-style checksums after them. =A0We could =
add
> vlan2_features which would be copied to a VLAN sub-device's
> vlan_features, but then what happens when people want to handle tripl=
e
> VLAN encapsulation?

I agree, it's definitely a losing battle to keep adding vlan_features
to handle n + 1 tags.  I was just thinking that we might be able to
make some assumptions about packets tagged out-of-band, since the NIC
doesn't need to parse them at all.  If the tagging takes place late
enough in the pipeline, it might be completely transparent.

It may not be a valid assumption to make for all NICs though, so it's
probably better to be conservative.  As long as we handle it correctly
in software, we can potentially relax it later in the future.
