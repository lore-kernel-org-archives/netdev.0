From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()
Date: Tue, 05 Jul 2011 15:22:33 +0200
Message-ID: <4E131019.8020200@trash.net>
References: <1309416426.2532.119.camel@edumazet-laptop>	 <4E0C278B.7010403@yandex.ru>	 <1309433652.1994.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E0C651A.1000300@trash.net>	 <1309446900.1994.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E0C8902.8070303@earthlink.net> <4E0C8D7F.3000902@trash.net>	 <1309453730.5846.31.camel@tiger.regit.org>	 <1309455919.2515.3.camel@edumazet-laptop>	 <1309503610.2515.18.camel@edumazet-laptop>	 <20110701074936.GR16021@Chamillionaire.breakpoint.cc> <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, Eric Leblond <eric@regit.org>,
	sclark46@earthlink.net, Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39479 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186Ab1GENWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:22:35 -0400
In-Reply-To: <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.07.2011 17:27, Eric Dumazet wrote:
> Le vendredi 01 juillet 2011 =E0 09:49 +0200, Florian Westphal a =E9cr=
it :
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Number one offender is the nfnl_lock mutex hold each time we give a
>>> verdict.
>>
>> Yes, the nfnl mutex is fairly annoying for nfqueue.
>>
>> Unfortunately it is not possible to just remove it
>> completely since it also protects against module removal.
>>
>=20
> I believe it can, just add appropriate synchronization points.
>=20
>> But I guess even having to grab a refcount would be
>> a huge win as opposed to holding on to the nfnl mutex...
>>
>> We'd also need to audit all ->call implementations; most
>> of them assume the nfnl_mutex is being hold.
>=20
> CC netdev
>=20
> We can do another way : Introduce a new ->call_rcu() implementation
> and convert places where we prefer not holding nfnf_mutex.
>=20
> If/when all places are converted, remove the ->call() field for good.

We've talked about this a few times, but we have some pretty deep
call chains especially in ctnetlink, which are using sleeping
allocations. Not sure whether we really want to convert those.
An alternative would be to push locking down one level and have
the subsystem decide whether to use RCU or the mutex. However that
would require taking a reference to the subsystem in nfnetlink to
avoid module unloda races.

> With following two patches, I was able to reach more than 2.000.000 p=
ps
> without losses on my setup (limited by my lab setup), instead of less
> than 500.000 pps

That sounds pretty impressive.
