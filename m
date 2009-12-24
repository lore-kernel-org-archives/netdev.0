From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v2] llc enhancements
Date: Thu, 24 Dec 2009 14:17:02 +0200
Message-ID: <200912241417.03003.opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com> <4B3327D3.7080704@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12311 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751498AbZLXMUW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 07:20:22 -0500
In-Reply-To: <4B3327D3.7080704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 December 2009 10:35:31 you wrote:
> Le 24/12/2009 00:45, Octavian Purdila a =E9crit :
> > This patch modifies the LLC code to scale the socket lookup code fo=
r a
> > large number of interfaces and large number of sockets bound to the
> > same SAP. We use it for STP traffic generation from a large number =
of
> > virtual STP ports, via virtual network interfaces.
> >
> > In the process we converted the socket lookup code and sap list to =
use
> > RCU. It also contains some general cleanups (use dev_hard_header
> > instead of handcrafting the headers) and enhancements (LLC_OPT_PKTI=
NFO).
> >
> > This is the 2nd version. Changes from the previous version:
> >
> > - added SO_BINDTODEVICE support for faster bind operations
> > - converted the socket lookup code and sap list to RCU
> > - optimized multicast delivery ala Eric
> > - remove some unused APIs (which should be private anyway)
> >
> > Many thanks to Eric Dumazet for his continuous guidance and to Jare=
k
> > Poplawski for spotting a locking bug in the previous version.
>=20
> Pretty impressive work Octavian !
>=20
> My only concerns (before drinking my coffee, I might be wrong...) are=
 :
>=20
> 1) Patch 7/9 : __llc_lookup_established()
>    Checking slot number is not enough I am afraid. A socket can be fr=
eed,
>    re-allocated, inserted in another sap hash list on _same_ slot num=
ber.
>    We dont have this problem with UDP/TCP since we have only
>    one hash table on machine, but with llc, we might have many sap ha=
sh
>  tables.
>=20
>    So before if (llc_estab_match(sap, daddr, laddr, rc)) test, you pr=
obably
>    need to check if we found a socket hashed on a different hash tabl=
e and
>    restart the lookup.
>=20

Woudn't the sap check after the the atomic_inc check take care of this?

        rcu_read_lock();
again:
        sk_nulls_for_each_rcu(rc, node, laddr_hb) {
                if (llc_estab_match(sap, daddr, laddr, rc)) {
                        /* Extra checks required by SLAB_DESTROY_BY_RCU=
 */
                        if (unlikely(!atomic_inc_not_zero(&rc->sk_refcn=
t) ||
                                     llc_sk(rc)->sap !=3D sap))
                                goto again;
                        if (unlikely(!llc_estab_match(sap, daddr, laddr=
, rc))) {
                                sock_put(rc);
                                continue;
                        }
                        goto found;
                }
        }

But, I found a leak issue: if the sap check fails we should sock_put th=
e socket before trying again !=20

> 2) the WARN_ON() removal in patch 7/9 :
>=20
>  void llc_sap_close(struct llc_sap *sap)
>  {
> -	WARN_ON(!hlist_nulls_empty(&sap->sk_list));
>  	llc_del_sap(sap);
>  	kfree(sap);
>  }
>=20
> I believe we should keep the sanity test some time, converted to
>  sk_laddr_hash[] variant.

I think adding counter would be necessary for this - to avoid iterating=
 over all the hash buckets. Does that sound ok?

Thanks !
