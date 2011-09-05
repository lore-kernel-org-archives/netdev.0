From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Mon, 05 Sep 2011 13:51:45 +0900
Message-ID: <4E645561.3050500@sfc.wide.ad.jp>
References: <20110902172220.830228928@vyatta.com> <20110902172247.396753508@vyatta.com> <4E614CF7.7030700@gmail.com> <20110902151100.327af0bf@nehalam.ftrdhcpuser.net> <4E6272BC.4020707@gmail.com> <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net> <4E632A2E.5040805@gmail.com> <20110904093634.685d7c56@nehalam.ftrdhcpuser.net> <4E63B175.6020106@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?B?Tmljb2xhcyBkZSBQ?= =?UTF-8?B?ZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Achmad Basuki <abazh@sfc.wide.ad.jp>
To: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:46858 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750764Ab1IEEwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 00:52:10 -0400
In-Reply-To: <4E63B175.6020106@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/11 02:12, Krzysztof Ol=C4=99dzki wrote:
> On 2011-09-04 18:36, Stephen Hemminger wrote:
>> On Sun, 04 Sep 2011 09:35:10 +0200
>> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:
>>
>>> Le 04/09/2011 06:14, Stephen Hemminger a =C3=A9crit :
>>>
>>>>> Instead of asserting carrier when the bridge have no port, can't =
we assert carrier when the three
>>>>> following condition are true at the same time :
>>>>>
>>>>> - The bridge have no port.
>>>>> - At least one IP address is setup on the bridge.
>>>>> - The two above conditions are true for more than a configurable =
amount of seconds, with a default
>>>>> of 10, for example.
>>>>>
>>>>> This would only delay carrier on for a few seconds for the regres=
sion and keep the current behavior
>>>>> (carrier off until at least 1 port is on) for DHCP.
>>>>
>>>> This fails on two counts:
>>>> 1. Bridge's often run without IP addresses!
>>>> 2. DHCP won't try and send out request until carrier is true.
>>>
>>> Sorry, I missed to say that we should of course also assert carrier=
 on if one port has carrier on.
>>>
>>> And rethinking about it, the delay is probably useless :
>>>
>>> bridge_carrier_on =3D at_least_one_port_has_carrier_on | (bridge_ha=
s_no_port&  bridge_has_at_least_one_ip)
>>>
>>> That way :
>>> - for those using bridge without any port, manually setting the IP =
will assert carrier on. (By the
>>> way, why don't they use a dummy device instead?)
>>>
>>> - for those using bridge with ports:
>>> -- Using any kind of autoconfig will work as expected. Carrier will=
 only be asserted at the time
>>> first port get carrier.
>>> -- Using static IP confifiguration, carrier will possibly be errone=
ously reported as on during the
>>> small time gap between IP address configuration and first port is a=
dded to the bridge. This time gap
>>> may be removed by simply configuring the IP after the first port is=
 added. This is probably already
>>> true for most distribs. And anyway, this time gap is probably not a=
 problem.
>>> -- Carrier will also be erroneously reported as on after removing t=
he last port, if the bridge still
>>> has an IP. (But we can arrange for this not to happen).
>>>
>>> And in order to ensure user really understand why carrier is on of =
off, we can simply issue an INFO
>>> message for the non-natural case (bridge_has_no_port&  bridga_has_a=
t_least_one_ip).
>>>
>>> I consider all this reasonable.
>>>
>>>     Nicolas.
>>
>> Any bridge behaviour based on IP address configuration is a
>> layering violation and won't work.  The problem is related to dynami=
c issues
>> with IPv6 and DHCP and needs to be addressed at that level.
>
> Maybe we can simply add a switch controlling if a bridge with no atta=
ched ports has carrier off (default) or on.
>
> For example:
>  echo {0|1} > /sys/devices/virtual/net/brX/bridge/orphaned_carrier
>
>  brctl orphaned_carrier brX {on|off}
>
> Best regards,
>
>                 Krzysztof Ol=C4=99dzki
My colleague investigated the problem. In the case of libvirt, there ar=
e 2 issues at hand:
- dnsmasq cannot bind to port 53 for IPv6 address, therefore fails.
- radvd fails to start because the interface is treated as being down.

This blog entry from Daniel Berrange explains the configuration used by=
 libvirt:
http://berrange.com/posts/2011/06/16/providing-ipv6-connectivity-to-vir=
tual-guests-with-libvirt-and-kvm/
It's quite possible that other users may have the same problem in the f=
uture if they plan to use radvd or
dnsmasq on a bridge interface. I'm not sure if there are other applicat=
ions that depend on the carrier on
a bridge interface to function properly. Come to think of it, unless th=
e user is aware of the change
in carrier on the bridge interface, it is very hard for them to diagnos=
e the problem and apply the right
solution (toggling the carrier). Ideally, there is no reason why dnsmas=
q and radvd should be started if
there is no port attached to a bridge interface. But, we cannot assume =
that's how it is done.

I think that it is prudent that the whole commit should be reverted bec=
ause the problem may not be limited
to libvirt use case.
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
