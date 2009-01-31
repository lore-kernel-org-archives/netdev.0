From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 6/6] netfilter: convert x_tables to use RCU
Date: Sat, 31 Jan 2009 18:27:45 +0100
Message-ID: <49848A11.7020908@cosmosbay.com>
References: <20090130215700.965611970@vyatta.com> <20090130215729.658203821@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55270 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbZAaR1y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 12:27:54 -0500
In-Reply-To: <20090130215729.658203821@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Replace existing reader/writer lock with Read-Copy-Update to
> elminate the overhead of a read lock on each incoming packet.
> This should reduce the overhead of iptables especially on SMP
> systems.
>=20
> The previous code used a reader-writer lock for two purposes.
> The first was to ensure that the xt_table_info reference was not in
> process of being changed. Since xt_table_info is only freed via one
> routine, it was a direct conversion to RCU.
>=20
> The other use of the reader-writer lock was to to block changes
> to counters while they were being read. This synchronization was
> fixed by the previous patch.  But still need to make sure table info
> isn't going away.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> ---
>  include/linux/netfilter/x_tables.h |   10 ++++++--
>  net/ipv4/netfilter/arp_tables.c    |   16 ++++++-------
>  net/ipv4/netfilter/ip_tables.c     |   27 +++++++++++-----------
>  net/ipv6/netfilter/ip6_tables.c    |   16 ++++++-------
>  net/netfilter/x_tables.c           |   45 ++++++++++++++++++++++++++=
-----------
>  5 files changed, 70 insertions(+), 44 deletions(-)

OK, I have a last comment Stephen

(I tested your patches on my dev machine and got nice results)

In net/ipv4/netfilter/ip_tables.c,
get_counters() can be quite slow on large firewalls, and it is
called from alloc_counters() with BH disabled, but also from __do_repla=
ce()
without BH disabled.

So get_counters() first iterates on set_entry_to_counter() for current =
cpu
but might be interrupted and we get bad results...

Solution is to always use seqcount_t protection, and no BH disabling at=
 all.

Then, I wonder if all this is valid, since alloc_counters() might be su=
pposed
to perform an atomic snapshots of all counters. This was possible becau=
se
of a write_lock_bh(), but does it make any sense to block all packets f=
or
such a long time ??? If this is a strong requirement, I am afraid we ha=
ve
to make other changes...


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/netfilter/ip_tables.c |   25 +++----------------------
 1 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index 7c50e2e..d208b25 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -900,25 +900,8 @@ get_counters(const struct xt_table_info *t,
 {
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu;
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
-	 */
-	curcpu =3D raw_smp_processor_id();
-
-	i =3D 0;
-	IPT_ENTRY_ITERATE(t->entries[curcpu],
-			  t->size,
-			  set_entry_to_counter,
-			  counters,
-			  &i);
=20
 	for_each_possible_cpu(cpu) {
-		if (cpu =3D=3D curcpu)
-			continue;
 		i =3D 0;
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
@@ -939,15 +922,12 @@ static struct xt_counters * alloc_counters(struct=
 xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize =3D sizeof(struct xt_counters) * private->number;
-	counters =3D vmalloc_node(countersize, numa_node_id());
+	counters =3D __vmalloc(countersize, GFP_KERNEL | __GFP_ZERO, PAGE_KER=
NEL);
=20
 	if (counters =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
=20
-	/* First, sum counters... */
-	local_bh_disable();
 	get_counters(private, counters);
-	local_bh_enable();
=20
 	return counters;
 }
@@ -1209,7 +1189,8 @@ __do_replace(struct net *net, const char *name, u=
nsigned int valid_hooks,
 	void *loc_cpu_old_entry;
=20
 	ret =3D 0;
-	counters =3D vmalloc(num_counters * sizeof(struct xt_counters));
+	counters =3D __vmalloc(num_counters * sizeof(struct xt_counters),
+			     GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto out;

