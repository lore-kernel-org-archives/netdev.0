From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 11:18:24 +0100
Message-ID: <4AE81A70.5060307@gmail.com>
References: <1256683583.3153.389.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49416 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbZJ1KTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:19:39 -0400
In-Reply-To: <1256683583.3153.389.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Chen a =E9crit :
> Multicast packet reassembly can fail
>=20
> When multicast connections with multiple fragments are received by th=
e same
> node from more than one Ethernet ports, race condition between fragme=
nts
> from each Ethernet port can cause fragment reassembly to fail leading=
 to
> packet drop.  This is because packets from each Ethernet port appears=
 identical
> to the the code that reassembles the Ethernet packet.
>=20
> The solution is evaluate the Ethernet interface number in addition to=
 all other
> parameters so that every packet can be uniquely identified.  The exis=
ting
> iif field in struct ipq is now used to generate the hash key, and iif=
 is also
> used for comparison in case of hash collision.
>=20
> Please note that q->saddr ^ (q->iif << 5) is now being passed into
> ipqhashfn to generate the hash key.  This is borrowed from the routin=
g
> code.
>=20
> Signed-off-by: Steve Chen <schen@mvista.com>
> Signed-off-by: Mark Huth <mhuth@mvista.com>
>=20

This makes no sense to me, but I need to check the code.

How interface could matter in IP defragmentation ?
And why multicast is part of the equation ?

If defrag fails, this must be for other reason,
and probably needs another fix.

Check line 219 of net/ipv4/inet_fragment.c

#ifdef CONFIG_SMP
        /* With SMP race we have to recheck hash table, because
         * such entry could be created on other cpu, while we
         * promoted read lock to write lock.
         */
        hlist_for_each_entry(qp, n, &f->hash[hash], list) {
                if (qp->net =3D=3D nf && f->match(qp, arg)) {
                        atomic_inc(&qp->refcnt);
                        write_unlock(&f->lock);
                        qp_in->last_in |=3D INET_FRAG_COMPLETE;   <<< H=
ERE >>>
                        inet_frag_put(qp_in, f);
                        return qp;
                }
        }
#endif

I really wonder why we set INET_FRAG_COMPLETE here
