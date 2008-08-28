From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 20:57:02 +0200
Message-ID: <48B6F4FE.6010308@cosmosbay.com>
References: <20080827.201020.17601834.davem@davemloft.net> <21915755.1327801219904892242.JavaMail.root@ouachita> <20080828072218.GI26610@one.firstfloor.org> <200808281948.52608.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Joe Malicki <jmalicki@metacarta.com>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.48]:47747 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbYH1S5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 14:57:18 -0400
In-Reply-To: <200808281948.52608.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a =E9crit :
> My small IMHO regarding SO_TIMESTAMP.
>=20
> 1)Right now i have 400-500 Mbps passing router. If i will run=20
> 5 "pings" ,simultaneous ,under _USER_ privileges(i know ping is suid)=
,=20
> instead of free 20% CPU time, i will have 1-2% free CPU time. Sure i =
know=20
> ping is suid program, but it is has been "like this" since long time.=
 By=20
> security psychos it will be caled DoS.
>=20

>=20

So... if using ping on your machine has direct an noticeable effect on =
cpu load, problem is elsewhere
(if no ping is running, you dont have skb timestamping, but still getns=
timeofday() is the top function in oprofile)

1) Do you have any netfilter rule using xt_time ?
   (This module also calls __net_timestamp(skb))

2) You maybe have a bad program that do something expensive relative to=
 kernel time services.


bad_program()
{
while (1) {
    struct timeval t0,t1;
    gettimeofday(&tv0, NULL); // or whatever function that calls getnst=
imeofday()
    do_small_work();
    gettimeofday(&tv1, NULL); // or whatever function that calls getnst=
imeofday()
    add_stat_event(&tv1, &tv0);
}

> 2)Usefullness of this option. What is a difference if on almost idle =
machine=20
> timestamp retrieved on higher level or lower level?=20
> And why we need on highly loaded server so high precision timestamp (=
with=20
> expensive timer), if in my case enabling any socket with SO_TIMESTAMP=
=20
> creating delays more than 10ms(up to 100ms)?

Your setup is probably not common.
You want a PersonnalComputer class machine acts as a SuperCiscoDevice(T=
M),
while most PC machines dont use more than 10% of CPU power in average..=
=2E

Many existing programs depend on current SO_TIMESTAMP.
We wont break them to solve a particular problem (yet to be demonstrate=
d)

>=20
> 3)Who is most users of SO_TIMESTAMP? iputils which is installed on al=
most=20
> _ANY_ linux machine? busybox which is using same option? Many others=20
> userspace multiplatform applications? Or banks? I dont take much in a=
ccount=20
> dhcpd, who is maybe abusing this option.
>=20
> So there is few good solutions available (IMHO):
> 1)Introduce some SO_REALTIMESTAMP (anyway even SO_TIMESTAMP not defin=
ed in any=20
> standard) for banks and ntp folks, who need them. And even give them =
timespec=20
> instead timeval, so they will be even more happy with resolution.

kernel already provides nanosecond resolution :)
Check SO_TIMESTAMPNS and SCM_TIMESTAMPNS





