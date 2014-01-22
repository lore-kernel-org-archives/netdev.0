From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 3/3] reciprocal_divide: update/correction of the algorithm
Date: Wed, 22 Jan 2014 02:02:30 +0100
Message-ID: <1390352550-4511-4-git-send-email-hannes@stressinduktion.org>
References: <1390352550-4511-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	linux-kernel@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390352550-4511-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jakub Zawadzki noticed that some divisions by reciprocal_divide()
were not correct [1][2], which he could also show with BPF code
after divisions are transformed into reciprocal_value() for runtime
invariance which can be passed to reciprocal_divide() later on;
reverse in BPF dump ended up with a different, off-by-one K in
some situations.

This has been fixed by Eric Dumazet in commit aee636c4809fa5
("bpf: do not use reciprocal divide"). This follow-up patch
improves reciprocal_value() and reciprocal_divide() to work in
all cases by using Granlund and Montgomery method, so that also
future use is safe and without any non-obvious side-effects.
Known problems with the old implementation were that division by 1
always returned 0 and some off-by-ones when the dividend and divisor
where very large. This seemed to not be problematic with its
current users, as far as we can tell. Eric Dumazet checked for
the slab usage, we cannot surely say so in the case of flex_array.
Still, in order to fix that, we propose an extension from the
original implementation from commit 6a2d7a955d8d resp. [3][4],
by using the algorithm proposed in "Division by Invariant Integers
Using Multiplication" [5], Torbj=C3=B6rn Granlund and Peter L.
Montgomery, that is, pseudocode for q =3D n/d where q, n, d is in
u32 universe:

1) Initialization:

  int l =3D ceil(log_2 d)
  uword m' =3D floor((1<<32)*((1<<l)-d)/d)+1
  int sh_1 =3D min(l,1)
  int sh_2 =3D max(l-1,0)

2) For q =3D n/d, all uword:

  uword t =3D (n*m')>>32
  q =3D (t+((n-t)>>sh_1))>>sh_2

The assembler implementation from Agner Fog [6] also helped a lot
while implementing. We have tested the implementation on x86_64,
ppc64, i686, s390x; on x86_64/haswell we're still half the latency
compared to normal divide.

Joint work with Daniel Borkmann.

  [1] http://www.wireshark.org/~darkjames/reciprocal-buggy.c
  [2] http://www.wireshark.org/~darkjames/set-and-dump-filter-k-bug.c
  [3] https://gmplib.org/~tege/division-paper.pdf
  [4] http://homepage.cs.uiowa.edu/~jones/bcd/divide.html
  [5] http://citeseerx.ist.psu.edu/viewdoc/summary?doi=3D10.1.1.1.2556
  [6] http://www.agner.org/optimize/asmlib.zip

Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: linux-kernel@vger.kernel.org
Cc: Jesse Gross <jesse@nicira.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Jakub Zawadzki <darkjames-ws@darkjames.pl>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/bonding/bond_main.c    | 24 ++++++++++++++++-------
 drivers/net/bonding/bond_netlink.c |  4 ----
 drivers/net/bonding/bond_options.c | 15 ++++++++++-----
 drivers/net/bonding/bond_sysfs.c   |  5 -----
 drivers/net/bonding/bonding.h      |  3 +++
 include/linux/flex_array.h         |  3 ++-
 include/linux/reciprocal_div.h     | 39 ++++++++++++++++++++----------=
--------
 include/linux/slab_def.h           |  4 +++-
 include/net/red.h                  |  3 ++-
 lib/flex_array.c                   |  7 ++++++-
 lib/reciprocal_div.c               | 24 +++++++++++++++++++----
 net/sched/sch_netem.c              |  6 ++++--
 12 files changed, 88 insertions(+), 49 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 3220b48..f100bd9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -79,7 +79,6 @@
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
 #include <net/flow_keys.h>
-#include <linux/reciprocal_div.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -3596,8 +3595,9 @@ static void bond_xmit_slave_id(struct bonding *bo=
nd, struct sk_buff *skb, int sl
  */
 static u32 bond_rr_gen_slave_id(struct bonding *bond)
 {
-	int packets_per_slave =3D bond->params.packets_per_slave;
 	u32 slave_id;
+	struct reciprocal_value reciprocal_packets_per_slave;
+	int packets_per_slave =3D bond->params.packets_per_slave;
=20
 	switch (packets_per_slave) {
 	case 0:
@@ -3607,8 +3607,10 @@ static u32 bond_rr_gen_slave_id(struct bonding *=
bond)
 		slave_id =3D bond->rr_tx_counter;
 		break;
 	default:
+		reciprocal_packets_per_slave =3D
+			bond->params.reciprocal_packets_per_slave;
 		slave_id =3D reciprocal_divide(bond->rr_tx_counter,
-					     packets_per_slave);
+					     reciprocal_packets_per_slave);
 		break;
 	}
 	bond->rr_tx_counter++;
@@ -4343,10 +4345,18 @@ static int bond_check_params(struct bond_params=
 *params)
 	params->resend_igmp =3D resend_igmp;
 	params->min_links =3D min_links;
 	params->lp_interval =3D lp_interval;
-	if (packets_per_slave > 1)
-		params->packets_per_slave =3D reciprocal_value(packets_per_slave);
-	else
-		params->packets_per_slave =3D packets_per_slave;
+	params->packets_per_slave =3D packets_per_slave;
+	if (packets_per_slave > 0) {
+		params->reciprocal_packets_per_slave =3D
+			reciprocal_value(packets_per_slave);
+	} else {
+		/* reciprocal_packets_per_slave is unused if
+		 * packets_per_slave is 0 or 1, just initialize it
+		 */
+		params->reciprocal_packets_per_slave =3D
+			(struct reciprocal_value) { 0 };
+	}
+
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
 		params->primary[IFNAMSIZ - 1] =3D 0;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/b=
ond_netlink.c
index 21c6488..e852655 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -19,7 +19,6 @@
 #include <linux/if_ether.h>
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
-#include <linux/reciprocal_div.h>
 #include "bonding.h"
=20
 int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb)
@@ -452,9 +451,6 @@ static int bond_fill_info(struct sk_buff *skb,
 		goto nla_put_failure;
=20
 	packets_per_slave =3D bond->params.packets_per_slave;
-	if (packets_per_slave > 1)
-		packets_per_slave =3D reciprocal_value(packets_per_slave);
-
 	if (nla_put_u32(skb, IFLA_BOND_PACKETS_PER_SLAVE,
 			packets_per_slave))
 		goto nla_put_failure;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/b=
ond_options.c
index 945a666..85e4348 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -16,7 +16,6 @@
 #include <linux/netdevice.h>
 #include <linux/rwlock.h>
 #include <linux/rcupdate.h>
-#include <linux/reciprocal_div.h>
 #include "bonding.h"
=20
 int bond_option_mode_set(struct bonding *bond, int mode)
@@ -671,11 +670,17 @@ int bond_option_packets_per_slave_set(struct bond=
ing *bond,
 		pr_warn("%s: Warning: packets_per_slave has effect only in balance-r=
r mode\n",
 			bond->dev->name);
=20
-	if (packets_per_slave > 1)
-		bond->params.packets_per_slave =3D
+	bond->params.packets_per_slave =3D packets_per_slave;
+	if (packets_per_slave > 0) {
+		bond->params.reciprocal_packets_per_slave =3D
 			reciprocal_value(packets_per_slave);
-	else
-		bond->params.packets_per_slave =3D packets_per_slave;
+	} else {
+		/* reciprocal_packets_per_slave is unused if
+		 * packets_per_slave is 0 or 1, just initialize it
+		 */
+		bond->params.reciprocal_packets_per_slave =3D
+			(struct reciprocal_value) { 0 };
+	}
=20
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 011f163..c083e9a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -39,7 +39,6 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <linux/nsproxy.h>
-#include <linux/reciprocal_div.h>
=20
 #include "bonding.h"
=20
@@ -1374,10 +1373,6 @@ static ssize_t bonding_show_packets_per_slave(st=
ruct device *d,
 {
 	struct bonding *bond =3D to_bond(d);
 	unsigned int packets_per_slave =3D bond->params.packets_per_slave;
-
-	if (packets_per_slave > 1)
-		packets_per_slave =3D reciprocal_value(packets_per_slave);
-
 	return sprintf(buf, "%u\n", packets_per_slave);
 }
=20
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 8a935f8..0a616c4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,6 +23,8 @@
 #include <linux/netpoll.h>
 #include <linux/inetdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/reciprocal_div.h>
+
 #include "bond_3ad.h"
 #include "bond_alb.h"
=20
@@ -171,6 +173,7 @@ struct bond_params {
 	int resend_igmp;
 	int lp_interval;
 	int packets_per_slave;
+	struct reciprocal_value reciprocal_packets_per_slave;
 };
=20
 struct bond_parm_tbl {
diff --git a/include/linux/flex_array.h b/include/linux/flex_array.h
index 6843cf1..b6efb0c 100644
--- a/include/linux/flex_array.h
+++ b/include/linux/flex_array.h
@@ -2,6 +2,7 @@
 #define _FLEX_ARRAY_H
=20
 #include <linux/types.h>
+#include <linux/reciprocal_div.h>
 #include <asm/page.h>
=20
 #define FLEX_ARRAY_PART_SIZE PAGE_SIZE
@@ -22,7 +23,7 @@ struct flex_array {
 			int element_size;
 			int total_nr_elements;
 			int elems_per_part;
-			u32 reciprocal_elems;
+			struct reciprocal_value reciprocal_elems;
 			struct flex_array_part *parts[];
 		};
 		/*
diff --git a/include/linux/reciprocal_div.h b/include/linux/reciprocal_=
div.h
index f9c90b3..8c5a3fb 100644
--- a/include/linux/reciprocal_div.h
+++ b/include/linux/reciprocal_div.h
@@ -4,29 +4,32 @@
 #include <linux/types.h>
=20
 /*
- * This file describes reciprocical division.
+ * This algorithm is based on the paper "Division by Invariant
+ * Integers Using Multiplication" by Torbj=C3=B6rn Granlund and Peter
+ * L. Montgomery.
  *
- * This optimizes the (A/B) problem, when A and B are two u32
- * and B is a known value (but not known at compile time)
+ * The assembler implementation from Agner Fog, which this code is
+ * based on, can be found here:
+ * http://www.agner.org/optimize/asmlib.zip
  *
- * The math principle used is :
- *   Let RECIPROCAL_VALUE(B) be (((1LL << 32) + (B - 1))/ B)
- *   Then A / B =3D (u32)(((u64)(A) * (R)) >> 32)
- *
- * This replaces a divide by a multiply (and a shift), and
- * is generally less expensive in CPU cycles.
+ * This optimization for A/B is helpful if the divisor B is mostly
+ * runtime invariant. The reciprocal of B is calculated in the
+ * slow-path with reciprocal_value(). The fast-path can then just use
+ * a much faster multiplication operation with a variable dividend A
+ * to calculate the division A/B.
  */
=20
-/*
- * Computes the reciprocal value (R) for the value B of the divisor.
- * Should not be called before each reciprocal_divide(),
- * or else the performance is slower than a normal divide.
- */
-extern u32 reciprocal_value(u32 B);
+struct reciprocal_value {
+	u32 m;
+	u8 sh1, sh2;
+};
=20
+struct reciprocal_value reciprocal_value(u32 d);
=20
-static inline u32 reciprocal_divide(u32 A, u32 R)
+static inline u32 reciprocal_divide(u32 a, struct reciprocal_value R)
 {
-	return (u32)(((u64)A * R) >> 32);
+	u32 t =3D (u32)(((u64)a * R.m) >> 32);
+	return (t + ((a - t) >> R.sh1)) >> R.sh2;
 }
-#endif
+
+#endif /* _LINUX_RECIPROCAL_DIV_H */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 09bfffb..96e8aba 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_SLAB_DEF_H
 #define	_LINUX_SLAB_DEF_H
=20
+#include <linux/reciprocal_div.h>
+
 /*
  * Definitions unique to the original Linux SLAB allocator.
  */
@@ -12,7 +14,7 @@ struct kmem_cache {
 	unsigned int shared;
=20
 	unsigned int size;
-	u32 reciprocal_buffer_size;
+	struct reciprocal_value reciprocal_buffer_size;
 /* 2) touched by every alloc & free from the backend */
=20
 	unsigned int flags;		/* constant flags */
diff --git a/include/net/red.h b/include/net/red.h
index 168bb2f..76e0b5f 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -130,7 +130,8 @@ struct red_parms {
 	u32		qth_max;	/* Max avg length threshold: Wlog scaled */
 	u32		Scell_max;
 	u32		max_P;		/* probability, [0 .. 1.0] 32 scaled */
-	u32		max_P_reciprocal; /* reciprocal_value(max_P / qth_delta) */
+	/* reciprocal_value(max_P / qth_delta) */
+	struct reciprocal_value	max_P_reciprocal;
 	u32		qth_delta;	/* max_th - min_th */
 	u32		target_min;	/* min_th + 0.4*(max_th - min_th) */
 	u32		target_max;	/* min_th + 0.6*(max_th - min_th) */
diff --git a/lib/flex_array.c b/lib/flex_array.c
index 6948a66..2eed22f 100644
--- a/lib/flex_array.c
+++ b/lib/flex_array.c
@@ -90,8 +90,8 @@ struct flex_array *flex_array_alloc(int element_size,=
 unsigned int total,
 {
 	struct flex_array *ret;
 	int elems_per_part =3D 0;
-	int reciprocal_elems =3D 0;
 	int max_size =3D 0;
+	struct reciprocal_value reciprocal_elems =3D { 0 };
=20
 	if (element_size) {
 		elems_per_part =3D FLEX_ARRAY_ELEMENTS_PER_PART(element_size);
@@ -119,6 +119,11 @@ EXPORT_SYMBOL(flex_array_alloc);
 static int fa_element_to_part_nr(struct flex_array *fa,
 					unsigned int element_nr)
 {
+	/*
+	 * if element_size =3D=3D 0 we don't get here, so we never touch
+	 * the zeroed fa->reciprocal_elems, which would yield invalid
+	 * results
+	 */
 	return reciprocal_divide(element_nr, fa->reciprocal_elems);
 }
=20
diff --git a/lib/reciprocal_div.c b/lib/reciprocal_div.c
index 75510e9..4641524 100644
--- a/lib/reciprocal_div.c
+++ b/lib/reciprocal_div.c
@@ -1,11 +1,27 @@
+#include <linux/kernel.h>
 #include <asm/div64.h>
 #include <linux/reciprocal_div.h>
 #include <linux/export.h>
=20
-u32 reciprocal_value(u32 k)
+/*
+ * For a description of the algorithm please have a look at
+ * include/linux/reciprocal_div.h
+ */
+
+struct reciprocal_value reciprocal_value(u32 d)
 {
-	u64 val =3D (1LL << 32) + (k - 1);
-	do_div(val, k);
-	return (u32)val;
+	struct reciprocal_value R;
+	u64 m;
+	int l;
+
+	l =3D fls(d - 1);
+	m =3D ((1ULL << 32) * ((1ULL << l) - d));
+	do_div(m, d);
+	++m;
+	R.m =3D (u32)m;
+	R.sh1 =3D min(l, 1);
+	R.sh2 =3D max(l - 1, 0);
+
+	return R;
 }
 EXPORT_SYMBOL(reciprocal_value);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a2bfc37..de1059a 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -91,7 +91,7 @@ struct netem_sched_data {
 	u64 rate;
 	s32 packet_overhead;
 	u32 cell_size;
-	u32 cell_size_reciprocal;
+	struct reciprocal_value cell_size_reciprocal;
 	s32 cell_overhead;
=20
 	struct crndstate {
@@ -725,9 +725,11 @@ static void get_rate(struct Qdisc *sch, const stru=
ct nlattr *attr)
 	q->rate =3D r->rate;
 	q->packet_overhead =3D r->packet_overhead;
 	q->cell_size =3D r->cell_size;
+	q->cell_overhead =3D r->cell_overhead;
 	if (q->cell_size)
 		q->cell_size_reciprocal =3D reciprocal_value(q->cell_size);
-	q->cell_overhead =3D r->cell_overhead;
+	else
+		q->cell_size_reciprocal =3D (struct reciprocal_value) { 0 };
 }
=20
 static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
--=20
1.8.4.2
