From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Thu, 29 Oct 2009 06:31:19 +0100
Message-ID: <4AE928A7.3010501@gmail.com>
References: <1256683583.3153.389.camel@linux-1lbu>	<4AE81A70.5060307@gmail.com> <20091028.215738.66603083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: schen@mvista.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56221 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbZJ2Fba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 01:31:30 -0400
In-Reply-To: <20091028.215738.66603083.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 28 Oct 2009 11:18:24 +0100
>=20
>> Check line 219 of net/ipv4/inet_fragment.c
>>
>> #ifdef CONFIG_SMP
>>         /* With SMP race we have to recheck hash table, because
>>          * such entry could be created on other cpu, while we
>>          * promoted read lock to write lock.
>>          */
>>         hlist_for_each_entry(qp, n, &f->hash[hash], list) {
>>                 if (qp->net =3D=3D nf && f->match(qp, arg)) {
>>                         atomic_inc(&qp->refcnt);
>>                         write_unlock(&f->lock);
>>                         qp_in->last_in |=3D INET_FRAG_COMPLETE;   <<=
< HERE >>>
>>                         inet_frag_put(qp_in, f);
>>                         return qp;
>>                 }
>>         }
>> #endif
>>
>> I really wonder why we set INET_FRAG_COMPLETE here
>=20
> What has happened here is that another cpu created an identical
> frag entry before we took the write lock.
>=20
> So we're letting that other cpu's entry stand, and will release
> our local one and not use it at all.
>=20
> Setting INET_FRAG_COMPLETE does two things:
>=20
> 1) It makes sure input frag processing skips this entry if such
>    code paths happen to see it for some reason.
>=20
> 2) INET_FRAG_COMPLETE must be set when inet_frag_destroy() gets
>    called by inet_frag_put() when it drops the refcount to zero.
>    There is an assertion on INET_FRAG_COMPLETE in inet_frag_destroy.
>=20
> Hope that clears things up.


Yes thanks David, this is clear now.
