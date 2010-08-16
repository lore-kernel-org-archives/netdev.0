From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 22:22:10 +0200
Message-ID: <1281990130.2487.70.camel@edumazet-laptop>
References: <20100814.220945.232761341.davem@davemloft.net>
	 <1281869722.2942.20.camel@edumazet-laptop>
	 <1281883637.2942.42.camel@edumazet-laptop>
	 <20100816.123607.57459160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, Peter Zijlstra <peterz@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35880 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521Ab0HPUW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 16:22:26 -0400
In-Reply-To: <20100816.123607.57459160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 12:36 -0700, David Miller a =C3=A9cri=
t :

> I'm hesistent to say that we should put this kind of patch in.
>=20
> It will shut up lockdep for this specific case, but it also means
> that if we do any other kinds of locking in this sequence we will
> not validate it.
>=20
> The valuable of this is open for debate I guess.
>=20
> But locking is hard so I would say that disabling lockdep to kill a
> warning it generates should be an absolute last resort.
>=20
> I also don't think making the locking mechanics conditional upon
> LOCKDEP is sane either, exactly because it means lockdep is testing
> something other than what actually gets used in practice. :-)

Hmm, maybe just disable BH, not for whole duration, but for each cpu.

Its a bit late here and I prefer to close this problem before whole
earth shout on me.

Thanks

[PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive

After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont block
bottom half more than necessary), lockdep can raise a warning
because we attempt to lock a spinlock with BH enabled, while
the same lock is usually locked by another cpu in a softirq context.

Disable again BH to avoid these lockdep warnings.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Diagnosed-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Peter Zijlstra <peterz@infradead.org>
---
 net/ipv4/netfilter/arp_tables.c |    2 ++
 net/ipv4/netfilter/ip_tables.c  |    2 ++
 net/ipv6/netfilter/ip6_tables.c |    2 ++
 3 files changed, 6 insertions(+)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 6bccba3..51d6c31 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -735,6 +735,7 @@ static void get_counters(const struct xt_table_info=
 *t,
 		if (cpu =3D=3D curcpu)
 			continue;
 		i =3D 0;
+		local_bh_disable();
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
@@ -742,6 +743,7 @@ static void get_counters(const struct xt_table_info=
 *t,
 			++i;
 		}
 		xt_info_wrunlock(cpu);
+		local_bh_enable();
 	}
 	put_cpu();
 }
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index c439721..97b64b2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -909,6 +909,7 @@ get_counters(const struct xt_table_info *t,
 		if (cpu =3D=3D curcpu)
 			continue;
 		i =3D 0;
+		local_bh_disable();
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
@@ -916,6 +917,7 @@ get_counters(const struct xt_table_info *t,
 			++i; /* macro does multi eval of i */
 		}
 		xt_info_wrunlock(cpu);
+		local_bh_enable();
 	}
 	put_cpu();
 }
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index 5359ef4..29a7bca 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -922,6 +922,7 @@ get_counters(const struct xt_table_info *t,
 		if (cpu =3D=3D curcpu)
 			continue;
 		i =3D 0;
+		local_bh_disable();
 		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
 			ADD_COUNTER(counters[i], iter->counters.bcnt,
@@ -929,6 +930,7 @@ get_counters(const struct xt_table_info *t,
 			++i;
 		}
 		xt_info_wrunlock(cpu);
+		local_bh_enable();
 	}
 	put_cpu();
 }


