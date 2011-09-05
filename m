From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Mon, 05 Sep 2011 19:18:38 +0200
Message-ID: <4E65046E.1020005@gmail.com>
References: <20110902172220.830228928@vyatta.com>	<20110902172247.396753508@vyatta.com>	<4E614CF7.7030700@gmail.com>	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>	<4E6272BC.4020707@gmail.com>	<20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>	<4E632A2E.5040805@gmail.com> <20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33011 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1IERSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:18:35 -0400
Received: by wyh22 with SMTP id 22so3788846wyh.19
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2011 10:18:34 -0700 (PDT)
In-Reply-To: <20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/09/2011 18:36, Stephen Hemminger a =E9crit :
> On Sun, 04 Sep 2011 09:35:10 +0200
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 04/09/2011 06:14, Stephen Hemminger a =E9crit :
>>
>>>> Instead of asserting carrier when the bridge have no port, can't w=
e assert carrier when the three
>>>> following condition are true at the same time :
>>>>
>>>> - The bridge have no port.
>>>> - At least one IP address is setup on the bridge.
>>>> - The two above conditions are true for more than a configurable a=
mount of seconds, with a default
>>>> of 10, for example.
>>>>
>>>> This would only delay carrier on for a few seconds for the regress=
ion and keep the current behavior
>>>> (carrier off until at least 1 port is on) for DHCP.
>>>
>>> This fails on two counts:
>>> 1. Bridge's often run without IP addresses!
>>> 2. DHCP won't try and send out request until carrier is true.
>>
>> Sorry, I missed to say that we should of course also assert carrier =
on if one port has carrier on.
>>
>> And rethinking about it, the delay is probably useless :
>>
>> bridge_carrier_on =3D at_least_one_port_has_carrier_on | (bridge_has=
_no_port&  bridge_has_at_least_one_ip)
>>
>> That way :
>> - for those using bridge without any port, manually setting the IP w=
ill assert carrier on. (By the
>> way, why don't they use a dummy device instead?)
>>
>> - for those using bridge with ports:
>> -- Using any kind of autoconfig will work as expected. Carrier will =
only be asserted at the time
>> first port get carrier.
>> -- Using static IP confifiguration, carrier will possibly be erroneo=
usly reported as on during the
>> small time gap between IP address configuration and first port is ad=
ded to the bridge. This time gap
>> may be removed by simply configuring the IP after the first port is =
added. This is probably already
>> true for most distribs. And anyway, this time gap is probably not a =
problem.
>> -- Carrier will also be erroneously reported as on after removing th=
e last port, if the bridge still
>> has an IP. (But we can arrange for this not to happen).
>>
>> And in order to ensure user really understand why carrier is on of o=
ff, we can simply issue an INFO
>> message for the non-natural case (bridge_has_no_port&  bridga_has_at=
_least_one_ip).
>>
>> I consider all this reasonable.
>>
>> 	Nicolas.
>
> Any bridge behaviour based on IP address configuration is a
> layering violation and won't work.  The problem is related to dynamic=
 issues
> with IPv6 and DHCP and needs to be addressed at that level.

Well, this is not a bridge behavior, this is a behavior of the local (n=
on physical) interface of the=20
bridge. If this interface were physical, it would have been external to=
 the bridge (on one of the=20
hosts connected to the bridge).  As such, this behavior is not related =
to the layering of the=20
bridge, so I don't consider it a layering violation.

My proposed change doesn't impact the way the bridge works (forwards pa=
ckets) in any way.

And it really solves both issues.

	Nicolas.
