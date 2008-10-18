From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Sat, 18 Oct 2008 10:54:18 +0200
Message-ID: <48F9A43A.7070801@cosmosbay.com>
References: <1224253423.17450.211.camel@ecld0pohly> <48F96DD6.5060904@cosmosbay.com> <48F99286.9050706@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.29]:62128 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbYJRIyh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 04:54:37 -0400
In-Reply-To: <48F99286.9050706@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp a =E9crit :
> Eric Dumazet wrote:
>>
>> Interesting stuff :)
>>
>=20
> Indeed.
>=20
>> 1) You want hardware TX stamping on all frames sent behalf a given s=
ocket
>>  Mark a WANT_HARDWARE_TX_STAMP flag at socket level
>>   Copy this flag when generating skb for this socket.
>>     When transmitting WANT_HARDWARE_TX_STAMP tagged frame to device,
>>     dont feed it to dev_queue_xmit_nit() in dev_hard_start_xmit()
>>     In NIC driver tx completion, test skb WANT_HARDWARE_TX_STAMP fla=
g.
>>     If set, get tstamp from hardware and copy it to skb tstamp,    =20
>> and call dev_queue_xmit_nit() (we might avoid cloning skb there, sin=
ce
>>     nic driver doesnt need it anymore)
>>
>>  This flag could also be set at device level, for all sent frames.=20
>> (tcpdump new option)
>>
>> 2) You want hardware RX stamping on a particular device, yet being=20
>> able to
>>   deliver system time to legacy apps, unaware of hardware tstamps.
>>
>>   Set a global flag on device, telling linux stack this device feeds=
=20
>> hardware stamp.
>>   In driver RX completion, set skb tstamp with hardware stamps.
>>
>>   Mark a WANT_HARDWARE_RX_STAMP flag at socket level, for PTP=20
>> applications.
>>
>>   In recv(), if current socket is not marked WANT_HARDWARE_RX_STAMP=20
>> and device has
>>   the global flag set, copy system time in tstamp, overrinding=20
>> hardware tstamp.
>>
>>
>=20
> Looks good to me. Just one question regarding
> 'copy system time in tstamp, overrinding hardware tstamp':
>=20
> When recv() delivers to several sockets there would be probably=20
> *different* system time values copied and delivered for the *same* sk=
b,=20
> right?

As we introduced a new skb flag for the TX part, we could reuse it in o=
rder
to copy system time to tstamp only once for the RX part.
>=20
> If so i would tend to fill both (system time and hw timestamp) on dri=
ver=20
> level into the skb and then decide on socket level what to push into=20
> user space as you suggested above.

Well, this would enlarge skb structure by 8 bytes, since you cannot use
same tstamp location to fille both 8 bytes values.
This is probably the easy way, but very expensive...




