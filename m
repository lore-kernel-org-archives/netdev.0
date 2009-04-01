From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] percpu: convert SNMP mibs to new infra
Date: Wed, 01 Apr 2009 20:44:47 +0200
Message-ID: <49D3B61F.8010507@cosmosbay.com>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D3A0C2.9000403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36140 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761443AbZDASpC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 14:45:02 -0400
In-Reply-To: <49D3A0C2.9000403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Ingo Molnar a =E9crit :
>>
>> [ Btw., it's definitely cool that you will make heavy use for it for=
=20
>>   SNMP mib statistics - please share with us your experiences with=20
>>   the facilities - good or bad experiences alike! ]
>=20
> I tried but I miss kind of an indirect percpu_add() function.
>=20
> because of Net namespaces, mibs are dynamically allocated, and
> current percpu_add() works on static percpu only (because of added
> per_cpu__ prefix)
>=20
> #define percpu_add(var, val)   percpu_to_op("add", per_cpu__##var, va=
l)
>=20
> I tried adding :
>=20
> #define dyn_percpu_add(var, val)   percpu_to_op("add", var, val)
>=20
> But I dont know it this is the plan ?
> Should we get rid of "per_cpu__" prefix and use a special ELF section=
/
> marker instead ?
>=20

Here is a preliminary patch for SNMP mibs that seems to work well on x8=
6_32

[RFC] percpu: convert SNMP mibs to new infra

Some arches can use percpu infrastructure for safe changes to mibs.
(percpu_add() is safe against preemption and interrupts), but
we want the real thing (a single instruction), not an emulation.

On arches still using an emulation, its better to keep the two views
per mib and preemption disable/enable

This shrinks size of mibs by 50%, but also shrinks vmlinux text size
(minimum IPV4 config)

$ size vmlinux.old vmlinux.new
   text    data     bss     dec     hex filename
4308458  561092 1728512 6598062  64adae vmlinux.old
4303834  561092 1728512 6593438  649b9e vmlinux.new



Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 arch/x86/include/asm/percpu.h |    3 +++
 include/net/snmp.h            |   27 ++++++++++++++++++++++-----
 net/ipv4/af_inet.c            |   28 +++++++++++++++++++---------
 3 files changed, 44 insertions(+), 14 deletions(-)


diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percp=
u.h
index aee103b..6b82f6b 100644
--- a/arch/x86/include/asm/percpu.h
+++ b/arch/x86/include/asm/percpu.h
@@ -135,6 +135,9 @@ do {							\
 #define percpu_read(var)	percpu_from_op("mov", per_cpu__##var)
 #define percpu_write(var, val)	percpu_to_op("mov", per_cpu__##var, val=
)
 #define percpu_add(var, val)	percpu_to_op("add", per_cpu__##var, val)
+#define indir_percpu_add(var, val)	percpu_to_op("add", *(var), val)
+#define indir_percpu_inc(var)       percpu_to_op("add", *(var), 1)
+#define indir_percpu_dec(var)       percpu_to_op("add", *(var), -1)
 #define percpu_sub(var, val)	percpu_to_op("sub", per_cpu__##var, val)
 #define percpu_and(var, val)	percpu_to_op("and", per_cpu__##var, val)
 #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 57c9362..ef9ed31 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -123,15 +123,31 @@ struct linux_xfrm_mib {
 };
=20
 /*=20
- * FIXME: On x86 and some other CPUs the split into user and softirq p=
arts
+ * On x86 and some other CPUs the split into user and softirq parts
  * is not needed because addl $1,memory is atomic against interrupts (=
but=20
- * atomic_inc would be overkill because of the lock cycles). Wants new=
=20
- * nonlocked_atomic_inc() primitives -AK
+ * atomic_inc would be overkill because of the lock cycles).
  */=20
+#ifdef CONFIG_X86
+# define SNMP_ARRAY_SZ 1
+#else
+# define SNMP_ARRAY_SZ 2
+#endif
+
 #define DEFINE_SNMP_STAT(type, name)	\
-	__typeof__(type) *name[2]
+	__typeof__(type) *name[SNMP_ARRAY_SZ]
 #define DECLARE_SNMP_STAT(type, name)	\
-	extern __typeof__(type) *name[2]
+	extern __typeof__(type) *name[SNMP_ARRAY_SZ]
+
+#if SNMP_ARRAY_SZ =3D=3D 1
+#define SNMP_INC_STATS(mib, field)	indir_percpu_inc(&mib[0]->mibs[fiel=
d])
+#define SNMP_INC_STATS_BH(mib, field)	SNMP_INC_STATS(mib, field)
+#define SNMP_INC_STATS_USER(mib, field) SNMP_INC_STATS(mib, field)
+#define SNMP_DEC_STATS(mib, field)	indir_percpu_dec(&mib[0]->mibs[fiel=
d])
+#define SNMP_ADD_STATS_BH(mib, field, addend) 	\
+				indir_percpu_add(&mib[0]->mibs[field], addend)
+#define SNMP_ADD_STATS_USER(mib, field, addend) 	\
+				indir_percpu_add(&mib[0]->mibs[field], addend)
+#else
=20
 #define SNMP_STAT_BHPTR(name)	(name[0])
 #define SNMP_STAT_USRPTR(name)	(name[1])
@@ -160,5 +176,6 @@ struct linux_xfrm_mib {
 		per_cpu_ptr(mib[1], get_cpu())->mibs[field] +=3D addend; \
 		put_cpu(); \
 	} while (0)
+#endif
=20
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f03373..badb568 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1366,27 +1366,37 @@ unsigned long snmp_fold_field(void *mib[], int =
offt)
=20
 	for_each_possible_cpu(i) {
 		res +=3D *(((unsigned long *) per_cpu_ptr(mib[0], i)) + offt);
+#if SNMP_ARRAY_SZ =3D=3D 2
 		res +=3D *(((unsigned long *) per_cpu_ptr(mib[1], i)) + offt);
+#endif
 	}
 	return res;
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
=20
-int snmp_mib_init(void *ptr[2], size_t mibsize)
+int snmp_mib_init(void *ptr[SNMP_ARRAY_SZ], size_t mibsize)
 {
 	BUG_ON(ptr =3D=3D NULL);
 	ptr[0] =3D __alloc_percpu(mibsize, __alignof__(unsigned long long));
 	if (!ptr[0])
-		goto err0;
+		return -ENOMEM;
+#if SNMP_ARRAY_SZ =3D=3D 2
 	ptr[1] =3D __alloc_percpu(mibsize, __alignof__(unsigned long long));
-	if (!ptr[1])
-		goto err1;
+	if (!ptr[1]) {
+		free_percpu(ptr[0]);
+		ptr[0] =3D NULL;
+		return -ENOMEM;
+	}
+#endif
+	{
+	int i;
+	printk(KERN_INFO "snmp_mib_init(%u) %p ", (unsigned int)mibsize, ptr[=
0]);
+	for_each_possible_cpu(i) {
+		printk(KERN_INFO "%p ", per_cpu_ptr(ptr[0], i));
+		}
+	printk(KERN_INFO "\n");
+	}
 	return 0;
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] =3D NULL;
-err0:
-	return -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(snmp_mib_init);
=20

