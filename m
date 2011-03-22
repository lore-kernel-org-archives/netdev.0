From: Simon Horman <horms@verge.net.au>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 10:18:01 +0900
Message-ID: <20110322011801.GE27019@verge.net.au>
References: <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
 <1300730838.2884.578.camel@edumazet-laptop>
 <1300738540.2837.5.camel@edumazet-laptop>
 <20110321221357.GF22625@verge.net.au>
 <20110321232921.GG22625@verge.net.au>
 <20110322000130.GC27019@verge.net.au>
 <20110322001706.GD27019@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110322001706.GD27019@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2011 at 09:17:07AM +0900, Simon Horman wrote:
> On Tue, Mar 22, 2011 at 09:01:33AM +0900, Simon Horman wrote:
> > On Tue, Mar 22, 2011 at 08:29:21AM +0900, Simon Horman wrote:
> > > On Tue, Mar 22, 2011 at 07:13:58AM +0900, Simon Horman wrote:
> > > > On Mon, Mar 21, 2011 at 09:15:40PM +0100, Eric Dumazet wrote:
> > > > > Le lundi 21 mars 2011 =C3=A0 19:07 +0100, Eric Dumazet a =C3=A9=
crit :
> > > > > > Le lundi 21 mars 2011 =C3=A0 18:39 +0100, Ingo Molnar a =C3=
=A9crit :
> > > > > > > here's the same but with kallsyms enabled.
> > > > > > >=20
> > > > > > > Thanks,
> > > > > > >=20
> > > > > > > 	Ingo
> > > > > > >=20
> > > > > > > [    9.585627] initcall 0xffffffff81d5b806 returned 0 aft=
er 0 usecs
> > > > > > > [    9.588960] calling  0xffffffff81d5b9da @ 1
> > > > > > > [    9.592303] IPVS: Creating netns size=3D1272 id=3D0
> > > > > > > [    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu=
=2E
> > > > > > > [    9.602298] IPVS: cannot register namespace.
> > > > > > > [    9.605627] IPVS: can't setup control
> > > > > >=20
> > > > > > It seems IPVS is busted in case of memory allocation error =
in=20
> > > > > > __ip_vs_control_init()
> > > > > >=20
> > > > > > IPVS deinits its "struct netns_ipvs" space, but something (=
in IPVS) uses
> > > > > > it after free.
> > > > > >=20
> > > > > > __ip_vs_init() seems to be called before ip_vs_init() compl=
etes
> > > > > > correctly. We then keep in net->ipvs a pointer to some free=
d memory.
> > > > > >=20
> > > > > > Commit 14e405461e664b7 did some changes in this area
> > > > > >=20
> > > > > > Simon, any idea ?
> > > > > >=20
> > > > > >=20
> > > > >=20
> > > > > For the time being, we can avoid the false memory allocation =
error (and
> > > > > leak)
> > > >=20
> > > > Sorry, that typo is my work.
> > >=20
> > > With your patch applied I now see the following
> > >=20
> > > ffff880003bbf1a0 corresponds to &ipvs->app_key in __ip_vs_app_ini=
t().
> > > I'll continue looking into this.
> > >=20
> > > [   12.610000] IPVS: Creating netns size=3D2456 id=3D0
> > > [   12.630000] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ES=
P)
> > > [   12.640000] BUG: key ffff880003bbf1a0 not in .data!
> > > [   12.640000] ------------[ cut here ]------------
> > > [   12.640000] WARNING: at kernel/lockdep.c:2701
> > > lockdep_init_map+0x37b/0x570()
> > > [   12.640000] Hardware name: Bochs
> > > [   12.640000] Pid: 1, comm: swapper Tainted: G        W
> > > 2.6.38-kexec-06330-g69b7efe-dirty #122
> > > [   12.650000] Call Trace:
> > > [   12.650000]  [<ffffffff8102e685>] warn_slowpath_common+0x75/0x=
b0
> > > [   12.650000]  [<ffffffff8102e6d5>] warn_slowpath_null+0x15/0x20
> > > [   12.650000]  [<ffffffff8105967b>] lockdep_init_map+0x37b/0x570
> > > [   12.650000]  [<ffffffff8105829d>] ? trace_hardirqs_on+0xd/0x10
> > > [   12.650000]  [<ffffffff81055ad8>] debug_mutex_init+0x38/0x50
> > > [   12.650000]  [<ffffffff8104bc4c>] __mutex_init+0x5c/0x70
> > > [   12.650000]  [<ffffffff81685ee7>] __ip_vs_app_init+0x64/0x86
> > > [   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
> > > [   12.660000]  [<ffffffff811b1c33>] T.620+0x43/0x170
> > > [   12.660000]  [<ffffffff811b1e9a>] ? register_pernet_subsys+0x1=
a/0x40
> > > [   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
> > > [   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
> > > [   12.660000]  [<ffffffff811b1db7>] register_pernet_operations+0=
x57/0xb0
> > > [   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
> > > [   12.670000]  [<ffffffff811b1ea9>] register_pernet_subsys+0x29/=
0x40
> > > [   12.670000]  [<ffffffff81685f19>] ip_vs_app_init+0x10/0x12
> > > [   12.670000]  [<ffffffff81685a87>] ip_vs_init+0x4c/0xff
> > > [   12.670000]  [<ffffffff8166562c>] do_one_initcall+0x7a/0x12e
> > > [   12.670000]  [<ffffffff8166583e>] kernel_init+0x13e/0x1c2
> > > [   12.670000]  [<ffffffff8128c134>] kernel_thread_helper+0x4/0x1=
0
> > > [   12.670000]  [<ffffffff8128ad40>] ? restore_args+0x0/0x30
> > > [   12.680000]  [<ffffffff81665700>] ? kernel_init+0x0/0x1c2
> > > [   12.680000]  [<ffffffff8128c130>] ? kernel_thread_helper+0x0/0=
x10
> > > [   12.680000] ---[ end trace 4eaa2a86a8e2da23 ]---
> >=20
> > It seems that the problem above was introduced by
> > ab8a5e8408c3 ("IPVS: netns awareness to ip_vs_app").
> > I assume the hungs are the cause:
>=20
> s/hungs/hunks below/
>=20
> I am a little unsure of what to do about this.
>=20
> The problem seems to be that ipvs->app_key is not in static storage.
> But I'm not sure how to resolve that given that the struct netns_ipvs=
 is
> per-network namespace. So I guess that the locking needs to be re-wor=
ked.
> Again, I'm a little unsure of what the best way forward is.

I had an idea for a fix over breakfast.

IPVS: Use global mutex in ip_vs_app.c

As part of the work to make IPVS network namespace aware
__ip_vs_app_mutex was replaced by a per-namespace lock,
ipvs->app_mutex. ipvs->app_key is also supplied for debugging purposes.

Unfortunately this implementation results in ipvs->app_key residing
in non-static storage which at the very least causes a lockdep warning.

This patch takes the rather heavy-handed approach of reinstating
__ip_vs_app_mutex which will cover access to the ipvs->list_head
of all network namespaces.

[   12.610000] IPVS: Creating netns size=3D2456 id=3D0
[   12.630000] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   12.640000] BUG: key ffff880003bbf1a0 not in .data!
[   12.640000] ------------[ cut here ]------------
[   12.640000] WARNING: at kernel/lockdep.c:2701 lockdep_init_map+0x37b=
/0x570()
[   12.640000] Hardware name: Bochs
[   12.640000] Pid: 1, comm: swapper Tainted: G        W 2.6.38-kexec-0=
6330-g69b7efe-dirty #122
[   12.650000] Call Trace:
[   12.650000]  [<ffffffff8102e685>] warn_slowpath_common+0x75/0xb0
[   12.650000]  [<ffffffff8102e6d5>] warn_slowpath_null+0x15/0x20
[   12.650000]  [<ffffffff8105967b>] lockdep_init_map+0x37b/0x570
[   12.650000]  [<ffffffff8105829d>] ? trace_hardirqs_on+0xd/0x10
[   12.650000]  [<ffffffff81055ad8>] debug_mutex_init+0x38/0x50
[   12.650000]  [<ffffffff8104bc4c>] __mutex_init+0x5c/0x70
[   12.650000]  [<ffffffff81685ee7>] __ip_vs_app_init+0x64/0x86
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff811b1c33>] T.620+0x43/0x170
[   12.660000]  [<ffffffff811b1e9a>] ? register_pernet_subsys+0x1a/0x40
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff811b1db7>] register_pernet_operations+0x57/0x=
b0
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.670000]  [<ffffffff811b1ea9>] register_pernet_subsys+0x29/0x40
[   12.670000]  [<ffffffff81685f19>] ip_vs_app_init+0x10/0x12
[   12.670000]  [<ffffffff81685a87>] ip_vs_init+0x4c/0xff
[   12.670000]  [<ffffffff8166562c>] do_one_initcall+0x7a/0x12e
[   12.670000]  [<ffffffff8166583e>] kernel_init+0x13e/0x1c2
[   12.670000]  [<ffffffff8128c134>] kernel_thread_helper+0x4/0x10
[   12.670000]  [<ffffffff8128ad40>] ? restore_args+0x0/0x30
[   12.680000]  [<ffffffff81665700>] ? kernel_init+0x0/0x1c2
[   12.680000]  [<ffffffff8128c130>] ? kernel_thread_helper+0x0/0x1glob=
al0

Signed-off-by: Simon Horman <horms@verge.net.au>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans@schillstrom.com>
---
 include/net/ip_vs.h            |    2 --
 net/netfilter/ipvs/ip_vs_app.c |   23 ++++++++++-------------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 272f593..30b49ed 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -801,8 +801,6 @@ struct netns_ipvs {
 	struct list_head	rs_table[IP_VS_RTAB_SIZE];
 	/* ip_vs_app */
 	struct list_head	app_list;
-	struct mutex		app_mutex;
-	struct lock_class_key	app_key;	/* mutex debuging */
=20
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_=
app.c
index 5c48ffb..2dc6de1 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -43,6 +43,8 @@ EXPORT_SYMBOL(register_ip_vs_app);
 EXPORT_SYMBOL(unregister_ip_vs_app);
 EXPORT_SYMBOL(register_ip_vs_app_inc);
=20
+static DEFINE_MUTEX(__ip_vs_app_mutex);
+
 /*
  *	Get an ip_vs_app object
  */
@@ -167,14 +169,13 @@ int
 register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 p=
roto,
 		       __u16 port)
 {
-	struct netns_ipvs *ipvs =3D net_ipvs(net);
 	int result;
=20
-	mutex_lock(&ipvs->app_mutex);
+	mutex_lock(&__ip_vs_app_mutex);
=20
 	result =3D ip_vs_app_inc_new(net, app, proto, port);
=20
-	mutex_unlock(&ipvs->app_mutex);
+	mutex_unlock(&__ip_vs_app_mutex);
=20
 	return result;
 }
@@ -189,11 +190,11 @@ int register_ip_vs_app(struct net *net, struct ip=
_vs_app *app)
 	/* increase the module use count */
 	ip_vs_use_count_inc();
=20
-	mutex_lock(&ipvs->app_mutex);
+	mutex_lock(&__ip_vs_app_mutex);
=20
 	list_add(&app->a_list, &ipvs->app_list);
=20
-	mutex_unlock(&ipvs->app_mutex);
+	mutex_unlock(&__ip_vs_app_mutex);
=20
 	return 0;
 }
@@ -205,10 +206,9 @@ int register_ip_vs_app(struct net *net, struct ip_=
vs_app *app)
  */
 void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
-	struct netns_ipvs *ipvs =3D net_ipvs(net);
 	struct ip_vs_app *inc, *nxt;
=20
-	mutex_lock(&ipvs->app_mutex);
+	mutex_lock(&__ip_vs_app_mutex);
=20
 	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
 		ip_vs_app_inc_release(net, inc);
@@ -216,7 +216,7 @@ void unregister_ip_vs_app(struct net *net, struct i=
p_vs_app *app)
=20
 	list_del(&app->a_list);
=20
-	mutex_unlock(&ipvs->app_mutex);
+	mutex_unlock(&__ip_vs_app_mutex);
=20
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -501,7 +501,7 @@ static void *ip_vs_app_seq_start(struct seq_file *s=
eq, loff_t *pos)
 	struct net *net =3D seq_file_net(seq);
 	struct netns_ipvs *ipvs =3D net_ipvs(net);
=20
-	mutex_lock(&ipvs->app_mutex);
+	mutex_lock(&__ip_vs_app_mutex);
=20
 	return *pos ? ip_vs_app_idx(ipvs, *pos - 1) : SEQ_START_TOKEN;
 }
@@ -535,9 +535,7 @@ static void *ip_vs_app_seq_next(struct seq_file *se=
q, void *v, loff_t *pos)
=20
 static void ip_vs_app_seq_stop(struct seq_file *seq, void *v)
 {
-	struct netns_ipvs *ipvs =3D net_ipvs(seq_file_net(seq));
-
-	mutex_unlock(&ipvs->app_mutex);
+	mutex_unlock(&__ip_vs_app_mutex);
 }
=20
 static int ip_vs_app_seq_show(struct seq_file *seq, void *v)
@@ -583,7 +581,6 @@ static int __net_init __ip_vs_app_init(struct net *=
net)
 	struct netns_ipvs *ipvs =3D net_ipvs(net);
=20
 	INIT_LIST_HEAD(&ipvs->app_list);
-	__mutex_init(&ipvs->app_mutex, "ipvs->app_mutex", &ipvs->app_key);
 	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
--=20
1.7.2.3
