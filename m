From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: fix length computation in rt_check_expire()
Date: Wed, 20 May 2009 06:54:22 +0200
Message-ID: <4A138CFE.5070901@cosmosbay.com>
References: <20090519162048.GB28034@hmsreliant.think-freely.org>	<4A12FEDA.7040806@cosmosbay.com>	<20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33246 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbZETEyj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 00:54:39 -0400
In-Reply-To: <20090519.150517.62361946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 19 May 2009 15:24:50 -0400
>=20
>>> Moving whole group in front would defeat the purpose of move, actua=
lly,
>>> since rank in chain is used to decay the timeout in garbage collect=
or.
>>> (search for tmo >>=3D 1; )
>>>
>> Argh, so the list is implicitly ordered by expiration time.  That
>> really defeats the entire purpose of doing grouping in the ilst at
>> all.  If thats the case, then I agree, its probably better to to
>> take the additional visitation hit in in check_expire above than to
>> try and preserve ordering.
>=20
> Yes, this seems best.
>=20
> I was worried that somehow the ordering also influences lookups,
> because the TOS bits don't go into the hash so I worried that it woul=
d
> be important that explicit TOS values appear before wildcard ones.
> But it doesn't appear that this is an issue, we don't have wildcard
> TOSs in the rtable entries, they are always explicit.
>=20
> So I would like to see an explicit final patch from Eric so we can ge=
t
> this fixed now.
>=20

I would like to split patches because we have two bugs indeed, and
I prefer to get attention for both problems, I dont remember Neil ackno=
wledged
the length computation problem.

=46irst and small patch, candidate for net-2.6 and stable (for 2.6.29) =
:

Thank you

[PATCH] net: fix length computation in rt_check_expire()

rt_check_expire() computes average and standard deviation of chain leng=
ths,
but not correclty reset length to 0 at beginning of each chain.
This probably gives overflows for sum2 (and sum) on loaded machines ins=
tead=20
of meaningful results.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/route.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c4c60e9..869cf1c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -785,7 +785,7 @@ static void rt_check_expire(void)
 	static unsigned int rover;
 	unsigned int i =3D rover, goal;
 	struct rtable *rth, **rthp;
-	unsigned long length =3D 0, samples =3D 0;
+	unsigned long samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
 	u64 mult;
=20
@@ -795,9 +795,9 @@ static void rt_check_expire(void)
 	goal =3D (unsigned int)mult;
 	if (goal > rt_hash_mask)
 		goal =3D rt_hash_mask + 1;
-	length =3D 0;
 	for (; goal > 0; goal--) {
 		unsigned long tmo =3D ip_rt_gc_timeout;
+		unsigned long length;
=20
 		i =3D (i + 1) & rt_hash_mask;
 		rthp =3D &rt_hash_table[i].chain;
@@ -809,6 +809,7 @@ static void rt_check_expire(void)
=20
 		if (*rthp =3D=3D NULL)
 			continue;
+		length =3D 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth =3D *rthp) !=3D NULL) {
 			if (rt_is_expired(rth)) {

