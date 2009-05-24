From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [Bug #13339] rtable leak in ipv4/route.c
Date: Mon, 25 May 2009 00:34:37 +0200
Message-ID: <4A19CB7D.8000004@cosmosbay.com>
References: <ZPPBiNHr1LC.A.9ZH.K9bGKB@chimera> <uSztiUhmDDC.A.U8H.a9bGKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Alexander V. Lukyanov" <lav-L+1EwoRT+D8@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <uSztiUhmDDC.A.U8H.a9bGKB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki a =C3=A9crit :
> This message has been generated automatically as a part of a report
> of recent regressions.
>=20
> The following bug entry is on the current list of known regressions
> from 2.6.29.  Please verify if it still should be listed and let me k=
now
> (either way).
>=20
>=20
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> Subject		: rtable leak in ipv4/route.c
> Submitter	: Alexander V. Lukyanov <lav-L+1EwoRT+D8@public.gmane.org>
> Date		: 2009-05-18 14:10 (7 days old)
>=20

Bug was present in 2.6.29, so its a regression from 2.6.28

It is solved and available in David tree (net-2.6), and scheduled for s=
table submission

commit 1ddbcb005c395518c2cd0df504cff3d4b5c85853
net: fix rtable leak in net/ipv4/route.c

Alexander V. Lukyanov found a regression in 2.6.29 and made a complete
analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
Quoted here because its a perfect one :

begin_of_quotation
 2.6.29 patch has introduced flexible route cache rebuilding. Unfortuna=
tely the
 patch has at least one critical flaw, and another problem.

 rt_intern_hash calculates rthi pointer, which is later used for new en=
try
 insertion. The same loop calculates cand pointer which is used to clea=
n the
 list. If the pointers are the same, rtable leak occurs, as first the c=
and is
 removed then the new entry is appended to it.

 This leak leads to unregister_netdevice problem (usage count > 0).

 Another problem of the patch is that it tries to insert the entries in=
 certain
 order, to facilitate counting of entries distinct by all but QoS param=
eters.
 Unfortunately, referencing an existing rtable entry moves it to list b=
eginning,
 to speed up further lookups, so the carefully built order is destroyed=
=2E

 For the first problem the simplest patch it to set rthi=3D0 when rthi=3D=
=3Dcand, but
 it will also destroy the ordering.
end_of_quotation

Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
(net: implement emergency route cache rebulds when gc_elasticity is exc=
eeded)

Trying to keep dst_entries ordered is too complex and breaks the fact t=
hat
order should depend on the frequency of use for garbage collection.

A possible fix is to make rt_intern_hash() simpler, and only makes
rt_check_expire() a litle bit smarter, being able to cope with an arbit=
rary
entries order. The added loop is running on cache hot data, while cpu
is prefetching next object, so should be unnoticied.

Reported-and-analyzed-by: Alexander V. Lukyanov <lav-L+1EwoRT+D8@public.gmane.org>
Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks
