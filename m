From: Wang Xingtong <wangxingtong@cn.fujitsu.com>
Subject: Re: [PATCH V2] IPv6 : add multicast routing verify which net_device
 is lo
Date: Wed, 21 Dec 2011 17:01:21 +0800
Message-ID: <4EF1A061.5030005@cn.fujitsu.com>
References: <4EF059B3.1020705@cn.fujitsu.com>	<1324379424-18055-1-git-send-email-gaofeng@cn.fujitsu.com> <20111221.011506.1770356582907889299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58392 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752121Ab1LUJC1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 04:02:27 -0500
In-Reply-To: <20111221.011506.1770356582907889299.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Tue, 20 Dec 2011 19:10:24 +0800
>=20
>> In currently routing subsystem, when we lookup a multicast routing
>> to send muticast packets to outside, rt6_device_match will return
>> the rt6_info which it's match first. If we add a multicast route on
>> loopback devices beforce the others interface, rt6_device_match will
>> retrun the rt6_info which rt6i_dev->name is "lo". But, obviously,
>> we can't send a muticast packet to outside using loopback devices.
>> It case all multicast packets blocking.
>>
>> Commit 4af04aba93f47699e disabled kernel add multicast route on lo
>> automatically. However,  we can't surmise the routing-add order or
>> interdict add multicast routing on loopback devices in user space.
>> The bug still exist. So, i think, more stronger routing subsystem is
>> necessary.
>>
>> Signed-off-by: Wang xingtong <wangxingtong@cn.fujitsu.com>
>=20
> Ok, this is getting rediculious.  I want to revert all of this
> stuff.
>=20
> How about, instead, we stop userland adding explicit addresses to the
> loopback device since that's what started behaving differently
> recently and causes these problems in the first place?

OK, David, I reproduce this as following :

1) ip -6 route show | grep ff00
    unreachable ff00::/8 dev lo  metric 1024  error -101
    ff00::/8 dev eth1  metric 1024

2) ip -6 route del ff00::/8 dev eth1
    ip -6 route del ff00::/8 dev lo

3) ip -6 route add ff00::/8 dev lo
    ip -6 route add ff00::/8 dev eth1

now, if we join to the multicast group with the interface index is=20
specified as 0, not restrict devices( oif =3D=3D 0 ), not restrict sadd=
r (=20
saddr =3D=3D :: ), rt6_device_match  will return rt6_info which=20
rt6i_dev->name is "lo" all the while, and rt6i_dev->error is
"-ENETUNREACH".  we got "ENODEV" at userspace,  all multicast packets=20
will be blocked .

But, in fact, eth1 can be uesd and we missed. This is a bug in routing=20
system=EF=BC=8C isn't it=EF=BC=9F

This patch add multicast routing check-up in rt6_device_match to arrest
it return loopback device when we isn't specified interface and saddr.

thanks,

wang xingtong
