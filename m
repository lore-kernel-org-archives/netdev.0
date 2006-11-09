From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take23 0/5] kevent: Generic event handling mechanism.
Date: Thu, 09 Nov 2006 08:52:45 +0100
Message-ID: <4552DE4D.7000007@cosmosbay.com>
References: <1154985aa0591036@2ka.mipt.ru>
 <20061107141718.f7414b31.akpm@osdl.org> <20061108082147.GA2447@2ka.mipt.ru>
 <200611081551.14671.dada1@cosmosbay.com>
 <20061108140307.da7d815f.akpm@osdl.org>
 <Pine.LNX.4.64.0611081442420.23154@alien.or.mcafeemobile.com>
 <45526339.3040506@cosmosbay.com>
 <Pine.LNX.4.64.0611081526350.23154@alien.or.mcafeemobile.com>
 <4552D7A6.4060505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Andrew Morton <akpm@osdl.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:6097 "EHLO smtp.Neuf.fr")
	by vger.kernel.org with ESMTP id S1753913AbWKIHwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 02:52:39 -0500
In-reply-to: <4552D7A6.4060505@cosmosbay.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Davide Libenzi a =E9crit :
>> Lost forever means? If there are more processes watching some fd=20
>> (external events), they all get their own copy of the events in thei=
r=20
>> own private epoll fd. It's not that we "steal" things out of the=20
>> kernel, is not a 1:1 producer/consumer thing (one producer, 1 queue)=
=2E=20
>> It's one producer, broadcast to all listeners (consumers) thing. The=
=20
>> only case where it'd matter is in the case of multiple threads shari=
ng=20
>> the same epoll fd.
>=20
> In my particular epoll application, the producer is tcp stack, and I=20
> have one consumer. If an network event is lost in the EFAULT handling=
,=20
> its lost forever. In any case, my application do provide a correct us=
er=20
> area, so this problem is only theorical.

I realize I was not explicit, and dit not answer your question (Lost fo=
rever=20
means ?)

                 if (epi->revents) {
                         if (__put_user(epi->revents,
                                        &events[eventcnt].events) ||
                             __put_user(epi->event.data,
                                        &events[eventcnt].data))
                                 return -EFAULT;
 >>                        if (epi->event.events & EPOLLONESHOT)
 >>                                epi->event.events &=3D EP_PRIVATE_BI=
TS;
                         eventcnt++;
                 }

If one EPOLLONESHOT event is correctly copied to user space, its status=
 is=20
updated.

If other ready events in the same epoll_wait() call cannot be transferr=
ed=20
because of an EFAULT (we reach the real end of user provided area), thi=
s=20
EPOLLONESHOT event is lost forever, because it wont be requeued in read=
y list.

Eric

