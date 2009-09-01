From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: neighbour table RCU
Date: Tue, 1 Sep 2009 18:55:34 +0300
Message-ID: <200909011855.34175.opurdila@ixiacom.com>
References: <20090831150453.3437a65c@nehalam> <4A9CC429.5020803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:16029 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753989AbZIAP5x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:57:53 -0400
In-Reply-To: <4A9CC429.5020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 September 2009 09:50:17 Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
> > Looking at the neighbour table, it should be possible to get
> > rid of the two reader/writer locks.  The hash table lock is pretty
> > amenable to RCU, but the dynamic resizing makes it non-trivial.
> > Thinking of using a combination of RCU and sequence counts so that =
the
> > reader would just rescan if resize was in progress.
>
> I am not sure neigh_tbl_lock rwlock should be changed, I did not
> see any contention on it.
>

Speaking about neighbour optimizations, here is a RFC patch which makes=
 the=20
tables double linked, for constant time deletion. It has given us a sig=
nificant=20
performance improvement - in less then usual setups though, with lots o=
f=20
neighbours.

Would something like this be acceptable for upstream? (pardon the p4 di=
ff dump=20
:) - but I think it will give a rough idea, if acceptable will clean it=
 up and=20
properly submit it)

BTW, would switching to list_head be better?

Thanks,
tavi

=3D=3D=3D=3D //packages/linux-2.6.7/main/src/include/net/neighbour.h#2 =
(text) =3D=3D=3D=3D

@@ -56,6 +56,7 @@
 struct neigh_parms
 {
        struct neigh_parms *next;
+       struct neigh_parms **pprev;
        int     (*neigh_setup)(struct neighbour *);
        struct neigh_table *tbl;
        int     entries;

=3D=3D=3D=3D //packages/linux-2.6.7/main/src/net/core/neighbour.c#3 (te=
xt) =3D=3D=3D=3D

@@ -1127,8 +1127,10 @@
                }
                p->sysctl_table =3D NULL;
                write_lock_bh(&tbl->lock);
-               p->next         =3D tbl->parms.next;
+               if ((p->next =3D tbl->parms.next))
+                       p->next->pprev =3D &p->next;
                tbl->parms.next =3D p;
+               p->pprev =3D &tbl->parms.next;
                write_unlock_bh(&tbl->lock);
        }
        return p;
@@ -1136,21 +1138,14 @@
=20
 void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *=
parms)
 {
-       struct neigh_parms **p;
-
        if (!parms || parms =3D=3D &tbl->parms)
                return;
        write_lock_bh(&tbl->lock);
-       for (p =3D &tbl->parms.next; *p; p =3D &(*p)->next) {
-               if (*p =3D=3D parms) {
-                       *p =3D parms->next;
-                       write_unlock_bh(&tbl->lock);
-                       kfree(parms);
-                       return;
-               }
-       }
+       if ((*parms->pprev =3D parms->next))
+               parms->next->pprev =3D parms->pprev;
        write_unlock_bh(&tbl->lock);
-       NEIGH_PRINTK1("neigh_parms_release: not found\n");
+       kfree(parms);
+       return;
 }
