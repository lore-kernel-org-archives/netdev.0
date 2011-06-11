From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] snmp: reduce percpu needs by 50%
Date: Sat, 11 Jun 2011 07:45:51 +0200
Message-ID: <1307771151.2872.72.camel@edumazet-laptop>
References: <1307598598.3980.76.camel@edumazet-laptop>
	 <20110609063450.GD15448@one.firstfloor.org>
	 <1307602166.3980.92.camel@edumazet-laptop>
	 <20110608.235113.2177191884416780789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-arch@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110608.235113.2177191884416780789.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SNMP mibs use two percpu arrays, one used in BH context, another in USER
context. With increasing number of cpus in machines, and fact that ipv6
uses per network device ipstats_mib, this is consuming a lot of memory
if many network devices are registered.

commit be281e554e2a (ipv6: reduce per device ICMP mib sizes) shrinked
percpu needs for ipv6, but we can reduce memory use a bit more.

With recent percpu infrastructure (irqsafe_cpu_inc() ...), we no longer
need this BH/USER separation since we can update counters in a single
x86 instruction, regardless of the BH/USER context.

Other arches than x86 might need to disable irq in their
irqsafe_cpu_inc() implementation : If this happens to be a problem, we
can make SNMP_ARRAY_SZ arch dependent, but a previous poll
( https://lkml.org/lkml/2011/3/17/174 ) to arch maintainers did not
raise strong opposition.

Only on 32bit arches, we need to disable BH for 64bit counters updates
done from USER context (currently used for IP MIB)

This also reduces vmlinux size :

1) x86_64 build
$ size vmlinux.before vmlinux.after
   text	   data	    bss	    dec	    hex	filename
7853650	1293772	1896448	11043870	 a8841e	vmlinux.before
7850578	1293772	1896448	11040798	 a8781e	vmlinux.after

2) i386  build
$ size vmlinux.before vmlinux.afterpatch 
   text	   data	    bss	    dec	    hex	filename
6039335	 635076	3670016	10344427	 9dd7eb	vmlinux.before
6037342	 635076	3670016	10342434	 9dd022	vmlinux.afterpatch

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: Tejun Heo <tj@kernel.org>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org
CC: linux-arch@vger.kernel.org
---
 include/net/snmp.h |   85 ++++++++++++++++---------------------------
 net/ipv4/af_inet.c |   52 +++++++++++---------------
 2 files changed, 55 insertions(+), 82 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 479083a..8f0f9ac 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -116,57 +116,51 @@ struct linux_xfrm_mib {
 	unsigned long	mibs[LINUX_MIB_XFRMMAX];
 };
 
-/* 
- * FIXME: On x86 and some other CPUs the split into user and softirq parts
- * is not needed because addl $1,memory is atomic against interrupts (but 
- * atomic_inc would be overkill because of the lock cycles). Wants new 
- * nonlocked_atomic_inc() primitives -AK
- */ 
+#define SNMP_ARRAY_SZ 1
+
 #define DEFINE_SNMP_STAT(type, name)	\
-	__typeof__(type) __percpu *name[2]
+	__typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
 #define DEFINE_SNMP_STAT_ATOMIC(type, name)	\
 	__typeof__(type) *name
 #define DECLARE_SNMP_STAT(type, name)	\
-	extern __typeof__(type) __percpu *name[2]
-
-#define SNMP_STAT_BHPTR(name)	(name[0])
-#define SNMP_STAT_USRPTR(name)	(name[1])
+	extern __typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
 
 #define SNMP_INC_STATS_BH(mib, field)	\
 			__this_cpu_inc(mib[0]->mibs[field])
+
 #define SNMP_INC_STATS_USER(mib, field)	\
-			this_cpu_inc(mib[1]->mibs[field])
+			irqsafe_cpu_inc(mib[0]->mibs[field])
+
 #define SNMP_INC_STATS_ATOMIC_LONG(mib, field)	\
 			atomic_long_inc(&mib->mibs[field])
+
 #define SNMP_INC_STATS(mib, field)	\
-			this_cpu_inc(mib[!in_softirq()]->mibs[field])
+			irqsafe_cpu_inc(mib[0]->mibs[field])
+
 #define SNMP_DEC_STATS(mib, field)	\
-			this_cpu_dec(mib[!in_softirq()]->mibs[field])
+			irqsafe_cpu_dec(mib[0]->mibs[field])
+
 #define SNMP_ADD_STATS_BH(mib, field, addend)	\
 			__this_cpu_add(mib[0]->mibs[field], addend)
+
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
-			this_cpu_add(mib[1]->mibs[field], addend)
+			irqsafe_cpu_add(mib[0]->mibs[field], addend)
+
 #define SNMP_ADD_STATS(mib, field, addend)	\
-			this_cpu_add(mib[!in_softirq()]->mibs[field], addend)
+			irqsafe_cpu_add(mib[0]->mibs[field], addend)
 /*
  * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
  * to make @ptr a non-percpu pointer.
  */
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib[0]) *ptr; \
-		preempt_disable(); \
-		ptr = this_cpu_ptr((mib)[!in_softirq()]); \
-		ptr->mibs[basefield##PKTS]++; \
-		ptr->mibs[basefield##OCTETS] += addend;\
-		preempt_enable(); \
+		irqsafe_cpu_inc(mib[0]->mibs[basefield##PKTS]);		\
+		irqsafe_cpu_add(mib[0]->mibs[basefield##OCTETS], addend);	\
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib[0]) *ptr = \
-			__this_cpu_ptr((mib)[0]); \
-		ptr->mibs[basefield##PKTS]++; \
-		ptr->mibs[basefield##OCTETS] += addend;\
+		__this_cpu_inc(mib[0]->mibs[basefield##PKTS]);		\
+		__this_cpu_add(mib[0]->mibs[basefield##OCTETS], addend);	\
 	} while (0)
 
 
@@ -179,40 +173,20 @@ struct linux_xfrm_mib {
 		ptr->mibs[field] += addend;				\
 		u64_stats_update_end(&ptr->syncp);			\
 	} while (0)
+
 #define SNMP_ADD_STATS64_USER(mib, field, addend) 			\
 	do {								\
-		__typeof__(*mib[0]) *ptr;				\
-		preempt_disable();					\
-		ptr = __this_cpu_ptr((mib)[1]);				\
-		u64_stats_update_begin(&ptr->syncp);			\
-		ptr->mibs[field] += addend;				\
-		u64_stats_update_end(&ptr->syncp);			\
-		preempt_enable();					\
+		local_bh_disable();					\
+		SNMP_ADD_STATS64_BH(mib, field, addend);		\
+		local_bh_enable();					\
 	} while (0)
+
 #define SNMP_ADD_STATS64(mib, field, addend)				\
-	do {								\
-		__typeof__(*mib[0]) *ptr;				\
-		preempt_disable();					\
-		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
-		u64_stats_update_begin(&ptr->syncp);			\
-		ptr->mibs[field] += addend;				\
-		u64_stats_update_end(&ptr->syncp);			\
-		preempt_enable();					\
-	} while (0)
+		SNMP_ADD_STATS64_USER(mib, field, addend)
+
 #define SNMP_INC_STATS64_BH(mib, field) SNMP_ADD_STATS64_BH(mib, field, 1)
 #define SNMP_INC_STATS64_USER(mib, field) SNMP_ADD_STATS64_USER(mib, field, 1)
 #define SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
-#define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
-	do {								\
-		__typeof__(*mib[0]) *ptr;				\
-		preempt_disable();					\
-		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
-		u64_stats_update_begin(&ptr->syncp);			\
-		ptr->mibs[basefield##PKTS]++;				\
-		ptr->mibs[basefield##OCTETS] += addend;			\
-		u64_stats_update_end(&ptr->syncp);			\
-		preempt_enable();					\
-	} while (0)
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
 	do {								\
 		__typeof__(*mib[0]) *ptr;				\
@@ -222,6 +196,12 @@ struct linux_xfrm_mib {
 		ptr->mibs[basefield##OCTETS] += addend;			\
 		u64_stats_update_end(&ptr->syncp);			\
 	} while (0)
+#define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
+	do {								\
+		local_bh_disable();					\
+		SNMP_UPD_PO_STATS64_BH(mib, basefield, addend);		\
+		local_bh_enable();					\
+	} while (0)
 #else
 #define SNMP_INC_STATS64_BH(mib, field)		SNMP_INC_STATS_BH(mib, field)
 #define SNMP_INC_STATS64_USER(mib, field)	SNMP_INC_STATS_USER(mib, field)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9c19260..260ccf0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1437,11 +1437,11 @@ EXPORT_SYMBOL_GPL(inet_ctl_sock_create);
 unsigned long snmp_fold_field(void __percpu *mib[], int offt)
 {
 	unsigned long res = 0;
-	int i;
+	int i, j;
 
 	for_each_possible_cpu(i) {
-		res += *(((unsigned long *) per_cpu_ptr(mib[0], i)) + offt);
-		res += *(((unsigned long *) per_cpu_ptr(mib[1], i)) + offt);
+		for (j = 0; j < SNMP_ARRAY_SZ; j++)
+			res += *(((unsigned long *) per_cpu_ptr(mib[j], i)) + offt);
 	}
 	return res;
 }
@@ -1455,28 +1455,19 @@ u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		void *bhptr, *userptr;
+		void *bhptr;
 		struct u64_stats_sync *syncp;
-		u64 v_bh, v_user;
+		u64 v;
 		unsigned int start;
 
-		/* first mib used by softirq context, we must use _bh() accessors */
-		bhptr = per_cpu_ptr(SNMP_STAT_BHPTR(mib), cpu);
+		bhptr = per_cpu_ptr(mib[0], cpu);
 		syncp = (struct u64_stats_sync *)(bhptr + syncp_offset);
 		do {
 			start = u64_stats_fetch_begin_bh(syncp);
-			v_bh = *(((u64 *) bhptr) + offt);
+			v = *(((u64 *) bhptr) + offt);
 		} while (u64_stats_fetch_retry_bh(syncp, start));
 
-		/* second mib used in USER context */
-		userptr = per_cpu_ptr(SNMP_STAT_USRPTR(mib), cpu);
-		syncp = (struct u64_stats_sync *)(userptr + syncp_offset);
-		do {
-			start = u64_stats_fetch_begin(syncp);
-			v_user = *(((u64 *) userptr) + offt);
-		} while (u64_stats_fetch_retry(syncp, start));
-
-		res += v_bh + v_user;
+		res += v;
 	}
 	return res;
 }
@@ -1488,25 +1479,28 @@ int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
 	BUG_ON(ptr == NULL);
 	ptr[0] = __alloc_percpu(mibsize, align);
 	if (!ptr[0])
-		goto err0;
+		return -ENOMEM;
+#if SNMP_ARRAY_SZ == 2 
 	ptr[1] = __alloc_percpu(mibsize, align);
-	if (!ptr[1])
-		goto err1;
+	if (!ptr[1]) {
+		free_percpu(ptr[0]);
+		ptr[0] = NULL;
+		return -ENOMEM;
+	}
+#endif
 	return 0;
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] = NULL;
-err0:
-	return -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(snmp_mib_init);
 
-void snmp_mib_free(void __percpu *ptr[2])
+void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
 {
+	int i;
+
 	BUG_ON(ptr == NULL);
-	free_percpu(ptr[0]);
-	free_percpu(ptr[1]);
-	ptr[0] = ptr[1] = NULL;
+	for (i = 0; i < SNMP_ARRAY_SZ; i++) {
+		free_percpu(ptr[i]);
+		ptr[i] = NULL;
+	}
 }
 EXPORT_SYMBOL_GPL(snmp_mib_free);
 
