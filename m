From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Tue, 13 Jan 2009 08:52:45 +0100
Message-ID: <496C484D.6060502@cosmosbay.com>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>	<200901122038.05199.denys@visp.net.lb>	<Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>	<200901122201.19616.denys@visp.net.lb>	<496C198A.4060502@trash.net> <20090112232811.46100689@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44932 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbZAMHw7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:52:59 -0500
In-Reply-To: <20090112232811.46100689@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Tue, 13 Jan 2009 05:33:14 +0100
> Patrick McHardy <kaber@trash.net> wrote:
>=20
>> Denys Fedoryschenko wrote:
>>> They are enabled
>>>
>>> Router-Dora /config # zcat /proc/config.gz |grep HIGH_RES
>>> CONFIG_HIGH_RES_TIMERS=3Dy
>>> Router-Dora /config # zcat /proc/config.gz |grep HZ
>>> CONFIG_NO_HZ=3Dy
>> Its odd that HZ=3D1000 solved the problem despite HR timers being ac=
tive.
>> Are you sure they're actually enabled? You should see something like
>> this in the ringbuffer:
>>
>> [    0.241972] Switched to high resolution mode on CPU 0
>> [    0.242708] Switched to high resolution mode on CPU 1
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> Even with NO_HZ the regular kernel won't schedule timers sooner
> than HZ. I believe it caused regressions so it was disabled.

Are you sure of this Stephen ?

This is not what I see with a CBQ setup, shaping a Gigabit interface wi=
th 60 Mb constraint

tc qdisc del dev eth2 root

tc qdisc add dev eth2 root handle 1: cbq avpkt 1000 rate 1000Mbit bandw=
idth 1000Mbit

tc class add dev eth2 parent 1:  classid 1:1   cbq allot 1500 rate 1000=
Mbit prio 1 avpkt 1500 bounded

# VOIP : essayons d'espacer un peu les paquets plutot que de les envoye=
r en burst
tc class add dev eth2 parent 1:1 classid 1:11 cbq allot 1500 rate 60Mbi=
t avpkt 200 bounded

tc filter add dev eth2 protocol ip parent 1: u32 \
                match ip dst 10.170.72.0/24 \
        flowid 1:11

All following RTP frames are sent at once by the producer, yet we can s=
ee them leaving machine at the right rate

08:47:59.492059 IP 10.170.74.20.40026 > 10.170.72.109.8270: UDP, length=
 172
08:47:59.492066 IP 10.170.74.20.40002 > 10.170.72.109.12540: UDP, lengt=
h 172
08:47:59.492104 IP 10.170.74.20.40016 > 10.170.72.110.8230: UDP, length=
 172
08:47:59.492109 IP 10.170.74.20.40044 > 10.170.72.109.4040: UDP, length=
 172
08:47:59.492136 IP 10.170.74.20.40038 > 10.170.72.109.13780: UDP, lengt=
h 172
08:47:59.492163 IP 10.170.74.20.40060 > 10.170.72.110.7670: UDP, length=
 172
08:47:59.492191 IP 10.170.74.20.40066 > 10.170.72.109.8860: UDP, length=
 172
08:47:59.492219 IP 10.170.74.20.40020 > 10.170.72.110.12160: UDP, lengt=
h 172
08:47:59.492246 IP 10.170.74.20.40078 > 10.170.72.110.12010: UDP, lengt=
h 172
08:47:59.492273 IP 10.170.74.20.40010 > 10.170.72.109.12670: UDP, lengt=
h 172
08:47:59.492306 IP 10.170.74.20.40018 > 10.170.72.109.4340: UDP, length=
 172
08:47:59.492333 IP 10.170.74.20.40008 > 10.170.72.109.7450: UDP, length=
 172
08:47:59.492361 IP 10.170.74.20.40024 > 10.170.72.110.10300: UDP, lengt=
h 172
08:47:59.492388 IP 10.170.74.20.40006 > 10.170.72.109.13390: UDP, lengt=
h 172
08:47:59.492389 IP 10.170.74.20.40036 > 10.170.72.109.9040: UDP, length=
 172
08:47:59.492416 IP 10.170.74.20.40042 > 10.170.72.110.5420: UDP, length=
 172
08:47:59.492444 IP 10.170.74.20.40040 > 10.170.72.109.8080: UDP, length=
 172
08:47:59.492470 IP 10.170.74.20.40048 > 10.170.72.110.17010: UDP, lengt=
h 172
08:47:59.492502 IP 10.170.74.20.40032 > 10.170.72.109.8340: UDP, length=
 172
08:47:59.492529 IP 10.170.74.20.40004 > 10.170.72.109.8420: UDP, length=
 172

2.6.27.10 kernel, HZ=3D1000, HighRES timers on

Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 5
Switched to high resolution mode on CPU 4
Switched to high resolution mode on CPU 7
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 6
Switched to high resolution mode on CPU 2

