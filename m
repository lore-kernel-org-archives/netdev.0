From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 04 Sep 2011 09:35:10 +0200
Message-ID: <4E632A2E.5040805@gmail.com>
References: <20110902172220.830228928@vyatta.com>	<20110902172247.396753508@vyatta.com>	<4E614CF7.7030700@gmail.com>	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>	<4E6272BC.4020707@gmail.com> <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42389 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab1IDHfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 03:35:09 -0400
Received: by wyh22 with SMTP id 22so2891990wyh.19
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2011 00:35:07 -0700 (PDT)
In-Reply-To: <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/09/2011 06:14, Stephen Hemminger a =E9crit :

>> Instead of asserting carrier when the bridge have no port, can't we =
assert carrier when the three
>> following condition are true at the same time :
>>
>> - The bridge have no port.
>> - At least one IP address is setup on the bridge.
>> - The two above conditions are true for more than a configurable amo=
unt of seconds, with a default
>> of 10, for example.
>>
>> This would only delay carrier on for a few seconds for the regressio=
n and keep the current behavior
>> (carrier off until at least 1 port is on) for DHCP.
>
> This fails on two counts:
> 1. Bridge's often run without IP addresses!
> 2. DHCP won't try and send out request until carrier is true.

Sorry, I missed to say that we should of course also assert carrier on =
if one port has carrier on.

And rethinking about it, the delay is probably useless :

bridge_carrier_on =3D at_least_one_port_has_carrier_on | (bridge_has_no=
_port & bridge_has_at_least_one_ip)

That way :
- for those using bridge without any port, manually setting the IP will=
 assert carrier on. (By the=20
way, why don't they use a dummy device instead?)

- for those using bridge with ports:
-- Using any kind of autoconfig will work as expected. Carrier will onl=
y be asserted at the time=20
first port get carrier.
-- Using static IP confifiguration, carrier will possibly be erroneousl=
y reported as on during the=20
small time gap between IP address configuration and first port is added=
 to the bridge. This time gap=20
may be removed by simply configuring the IP after the first port is add=
ed. This is probably already=20
true for most distribs. And anyway, this time gap is probably not a pro=
blem.
-- Carrier will also be erroneously reported as on after removing the l=
ast port, if the bridge still=20
has an IP. (But we can arrange for this not to happen).

And in order to ensure user really understand why carrier is on of off,=
 we can simply issue an INFO=20
message for the non-natural case (bridge_has_no_port & bridga_has_at_le=
ast_one_ip).

I consider all this reasonable.

	Nicolas.
