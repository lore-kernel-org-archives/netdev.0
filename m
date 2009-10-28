From: Steve Chen <schen@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 08:32:37 -0500
Message-ID: <1256736757.3153.412.camel@linux-1lbu>
References: <1256683583.3153.389.camel@linux-1lbu>
	 <4AE81A70.5060307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:54910 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1753796AbZJ1NYq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 09:24:46 -0400
In-Reply-To: <4AE81A70.5060307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 11:18 +0100, Eric Dumazet wrote:
> Steve Chen a =C3=A9crit :
> > Multicast packet reassembly can fail
> >=20
> > When multicast connections with multiple fragments are received by =
the same
> > node from more than one Ethernet ports, race condition between frag=
ments
> > from each Ethernet port can cause fragment reassembly to fail leadi=
ng to
> > packet drop.  This is because packets from each Ethernet port appea=
rs identical
> > to the the code that reassembles the Ethernet packet.
> >=20
> > The solution is evaluate the Ethernet interface number in addition =
to all other
> > parameters so that every packet can be uniquely identified.  The ex=
isting
> > iif field in struct ipq is now used to generate the hash key, and i=
if is also
> > used for comparison in case of hash collision.
> >=20
> > Please note that q->saddr ^ (q->iif << 5) is now being passed into
> > ipqhashfn to generate the hash key.  This is borrowed from the rout=
ing
> > code.
> >=20
> > Signed-off-by: Steve Chen <schen@mvista.com>
> > Signed-off-by: Mark Huth <mhuth@mvista.com>
> >=20
>=20
> This makes no sense to me, but I need to check the code.
>=20
> How interface could matter in IP defragmentation ?
> And why multicast is part of the equation ?
>=20
> If defrag fails, this must be for other reason,
> and probably needs another fix.
>=20
> Check line 219 of net/ipv4/inet_fragment.c
>=20
> #ifdef CONFIG_SMP
>         /* With SMP race we have to recheck hash table, because
>          * such entry could be created on other cpu, while we
>          * promoted read lock to write lock.
>          */
>         hlist_for_each_entry(qp, n, &f->hash[hash], list) {
>                 if (qp->net =3D=3D nf && f->match(qp, arg)) {
>                         atomic_inc(&qp->refcnt);
>                         write_unlock(&f->lock);
>                         qp_in->last_in |=3D INET_FRAG_COMPLETE;   <<<=
 HERE >>>
>                         inet_frag_put(qp_in, f);
>                         return qp;
>                 }
>         }
> #endif
>=20
> I really wonder why we set INET_FRAG_COMPLETE here

I sent the specific scenario the patch tries to address to the list in
an earlier e-mail.  Would it be beneficial if I post the test code
somewhere so everyone can have access?

Regards,

Steve

