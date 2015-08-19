From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Tue, 18 Aug 2015 19:05:37 -0700 (PDT)
Message-ID: <20150818.190537.1494539251161022002.davem@davemloft.net>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
	<20150818214017.GA14914@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vinschen@redhat.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
	ivecera@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbbHSCFi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 22:05:38 -0400
In-Reply-To: <20150818214017.GA14914@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 18 Aug 2015 23:40:17 +0200

> Corinna Vinschen <vinschen@redhat.com> :
>> The r8169 driver collects statistical information returned by
>> @get_stats64 by counting them in the driver itself, even though many
>> (but not all) of the values are already collected by tally counters
>> (TCs) in the NIC.  Some of these TC values are not returned by
>> @get_stats64.  Especially the received multicast packages are missin=
g
>> from /proc/net/dev.
>> Rectify this by fetching the TCs and returning them from
>> rtl8169_get_stats64.
>=20
> It is not exactly a some / many / not all / confused [*] picture
> - get_stats64 provides software managed values
> - ethtool provides hardware only values
>=20
> [*] ok, rx_missed is kinda special.
>=20
>> The counters collected in the driver obviously disappear as soon as =
the
>> driver is unloaded so after a driver is loaded the counters always s=
tart
>> at 0.  The TCs are only reset by a power cycle and there's no known =
way
>> to reset them programatically. Without further considerations the va=
lues
>> collected by the driver would not match up against the TC values.
>=20
> I'd rather:
> 1. keep software and hardware stats separated
> 2. push to userspace the responsibility to offset device specific har=
dware
>    values jumps
>=20
> My 0.02 =A4.

Any value that is provided by ->get_stats64() should be provided by wha=
tever
mechanism is available and determined to be "prudent" for the device in
question.  If the device is not tracking the event, this means pure sof=
tware
counters.

If the device tracks the event, you should attempt to use the hardware
facility to provide the ->get_stats64() values.

If the hardware provides counters not starting at zero on driver load,
one option to handle that is to load the initial values of all of
those counters and calculate diffs at ->get_stats64() time.

Otherwise, if you don't want to calculate diffs, you must use software
computed counters.

Ethtool stats are for values provided by the hardware which are outside=
 of
the collection defined by ->get_stats64().  Some drivers also use it fo=
r
providing per-RX-queue and per-TX-queue statistics.
