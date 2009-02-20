From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] iptables: xt_hashlimit fix
Date: Fri, 20 Feb 2009 19:10:42 +0100
Message-ID: <499EF222.3060507@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45978 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbZBTSKy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 13:10:54 -0500
In-Reply-To: <499DEF49.3040602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> The reader/writer lock in ip_tables is acquired in the critical path=
 of
>> processing packets and is one of the reasons just loading iptables c=
an cause
>> a 20% performance loss. The rwlock serves two functions:
>>
>> 1) it prevents changes to table state (xt_replace) while table is in=
 use.
>>    This is now handled by doing rcu on the xt_table. When table is
>>    replaced, the new table(s) are put in and the old one table(s) ar=
e freed
>>    after RCU period.
>>
>> 2) it provides synchronization when accesing the counter values.
>>    This is now handled by swapping in new table_info entries for eac=
h cpu
>>    then summing the old values, and putting the result back onto one
>>    cpu.  On a busy system it may cause sampling to occur at differen=
t
>>    times on each cpu, but no packet/byte counts are lost in the proc=
ess.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Sucessfully tested on my dual quad core machine too, but iptables onl=
y (no ipv6 here)
>=20
> BTW, my new "tbench 8" result is 2450 MB/s, (it was 2150 MB/s not so =
long ago)
>=20
> Thanks Stephen, thats very cool stuff, yet another rwlock out of kern=
el :)

Damned this broke xt_hashlimit, version=3D0

Look file "net/netfilter/xt_hashlimit.c" line 706

    /* Ugly hack: For SMP, we only want to use one set */
    r->u.master =3D r;

=46ile "include/linux/netfilter/xt_hashlimit.h"

struct xt_hashlimit_info {
        char name [IFNAMSIZ];           /* name */
        struct hashlimit_cfg cfg;

        /* Used internally by the kernel */
        struct xt_hashlimit_htable *hinfo;
        union {
                void *ptr;
                struct xt_hashlimit_info *master;
        } u;
};


So, it appears some modules are using pointers to themselves, what a ha=
ck :(

We probably need an audit of other modules.

(net/netfilter/xt_statistic.c, net/netfilter/xt_quota.c,
net/netfilter/xt_limit.c ...)

Unfortunatly I wont have time to do this in following days, any volunte=
er ?

Thank you

[PATCH] netfilter: xt_hashlimit fix

Commit 784544739a25c30637397ace5489eeb6e15d7d49
(netfilter: iptables: lock free counters) broke xt_hashlimit netfilter =
module :

This module was storing a pointer inside its xt_hashlimit_info, and thi=
s pointer
is not relocated when we temporarly switch tables (iptables -L).

This hack is not not needed at all (probably a leftover from
ancient time), as each cpu should and can access to its own copy.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 2482055..a5b5369 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -565,8 +565,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 static bool
 hashlimit_mt_v0(const struct sk_buff *skb, const struct xt_match_param=
 *par)
 {
-	const struct xt_hashlimit_info *r =3D
-		((const struct xt_hashlimit_info *)par->matchinfo)->u.master;
+	const struct xt_hashlimit_info *r =3D par->matchinfo;
 	struct xt_hashlimit_htable *hinfo =3D r->hinfo;
 	unsigned long now =3D jiffies;
 	struct dsthash_ent *dh;
@@ -702,8 +701,6 @@ static bool hashlimit_mt_check_v0(const struct xt_m=
tchk_param *par)
 	}
 	mutex_unlock(&hlimit_mutex);
=20
-	/* Ugly hack: For SMP, we only want to use one set */
-	r->u.master =3D r;
 	return true;
 }
=20

