From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Tue, 14 Apr 2009 10:19:36 -0700
Message-ID: <20090414101936.1d70879c@nehalam>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
	<20090413095309.631cf395@nehalam>
	<49E48136.5060700@trash.net>
	<49E49C65.8060808@cosmosbay.com>
	<20090414074554.7fa73e2f@nehalam>
	<49E4B0A5.70404@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757087AbZDNRT7@vger.kernel.org>
In-Reply-To: <49E4B0A5.70404@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Apr 2009 17:49:57 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Tue, 14 Apr 2009 16:23:33 +0200
> > Eric Dumazet <dada1@cosmosbay.com> wrote:
> >=20
> >> Patrick McHardy a =C3=A9crit :
> >>> Stephen Hemminger wrote:
> >>>> This is an alternative version of ip/ip6/arp tables locking usin=
g
> >>>> per-cpu locks.  This avoids the overhead of synchronize_net() du=
ring
> >>>> update but still removes the expensive rwlock in earlier version=
s.
> >>>>
> >>>> The idea for this came from an earlier version done by Eric Duza=
met.
> >>>> Locking is done per-cpu, the fast path locks on the current cpu
> >>>> and updates counters.  The slow case involves acquiring the lock=
s on
> >>>> all cpu's.
> >>>>
> >>>> The mutex that was added for 2.6.30 in xt_table is unnecessary s=
ince
> >>>> there already is a mutex for xt[af].mutex that is held.
> >>>>
> >>>> Tested basic functionality (add/remove/list), but don't have tes=
t cases
> >>>> for stress, ip6tables or arptables.
> >>> Thanks Stephen, I'll do some testing with ip6tables.
> >> Here is the patch I cooked on top of Stephen one to get proper loc=
king.
> >=20
> > I see no demonstrated problem with locking in my version.
>=20
> Yes, I did not crash any machine around there, should we wait for a b=
ug report ? :)
>=20
> > The reader/writer race is already handled. On replace the race of
> >=20
> > CPU 0                          CPU 1
> >                            lock (iptables(1))
> >                            refer to oldinfo
> > swap in new info
> > foreach CPU
> >    lock iptables(i)
> >    (spin)                  unlock(iptables(1))
> >    read oldinfo
> >    unlock
> > ...
> >=20
> > The point is my locking works, you just seem to feel more comfortab=
le with
> > a global "stop all CPU's" solution.
>=20
> Oh right, I missed that xt_replace_table() was *followed* by a get_co=
unters()
> call, but I am pretty sure something is needed in xt_replace_table().
>=20
> A memory barrier at least (smp_wmb())
>=20
> As soon as we do "table->private =3D newinfo;", other cpus might fetc=
h incorrect
> values for newinfo->fields.
>=20
> In the past, we had a write_lock_bh()/write_unlock_bh() pair that was
> doing this for us.
> Then we had rcu_assign_pointer() that also had this memory barrier im=
plied.
>=20
> Even if vmalloc() calls we do before calling xt_replace_table() proba=
bly
> already force barriers, add one for reference, just in case we change=
 callers
> logic to call kmalloc() instead of vmalloc() or whatever...
>

You are right, doing something with barrier would be safer there.
How about using xchg?

@@ -682,26 +668,19 @@ xt_replace_table(struct xt_table *table,
 	      struct xt_table_info *newinfo,
 	      int *error)
 {
-	struct xt_table_info *oldinfo, *private;
+	struct xt_table_info *private;
=20
 	/* Do the substitution. */
-	mutex_lock(&table->lock);
 	private =3D table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters !=3D private->number) {
 		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		mutex_unlock(&table->lock);
 		*error =3D -EAGAIN;
 		return NULL;
 	}
-	oldinfo =3D private;
-	rcu_assign_pointer(table->private, newinfo);
-	newinfo->initial_entries =3D oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
-
-	synchronize_net();
-	return oldinfo;
+	newinfo->initial_entries =3D private->initial_entries;
+	return xchg(&table->private, newinfo);
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
=20
P.s: we all missed the ordering bug in the RCU version??
