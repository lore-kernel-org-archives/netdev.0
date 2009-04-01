From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 19:13:38 +0200
Message-ID: <49D3A0C2.9000403@cosmosbay.com>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932678AbZDAROT@vger.kernel.org>
In-Reply-To: <20090401161218.GB3859@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Jeremy Fitzhardinge a =E9crit :
>>> Eric Dumazet wrote:
>>>> While playing with new percpu_{read|write|add|sub} stuff in networ=
k tree,
>>>> I found x86 asm was a litle bit optimistic.
>>>>
>>>> We need to tell gcc that percpu_{write|add|sub|or|xor} are modyfin=
g
>>>> memory and possibly eflags. We could add another parameter to
>>>> percpu_to_op()
>>>> to separate the plain "mov" case (not changing eflags),
>>>> but let keep it simple for the moment.
>>>>  =20
>>> Did you observe an actual failure that this patch fixed?
>>>
>> Not in current tree, as we dont use yet percpu_xxxx() very much.
>>
>> If deployed for SNMP mibs with hundred of call sites,
>> can you guarantee it will work as is ?
>=20
> Do we "guarantee" it for you? No.
>=20
> Is it expected to work just fine? Yes.
>=20
> Are there any known bugs in this area? No.

Good to know. So I shut up. I am a jerk and should blindly trust
linux kernel, sorry.

>=20
> Will we fix it if it's demonstrated to be broken? Of course! :-)
>=20
> [ Btw., it's definitely cool that you will make heavy use for it for=20
>   SNMP mib statistics - please share with us your experiences with=20
>   the facilities - good or bad experiences alike! ]

I tried but I miss kind of an indirect percpu_add() function.

because of Net namespaces, mibs are dynamically allocated, and
current percpu_add() works on static percpu only (because of added
per_cpu__ prefix)

#define percpu_add(var, val)   percpu_to_op("add", per_cpu__##var, val)

I tried adding :

#define dyn_percpu_add(var, val)   percpu_to_op("add", var, val)

But I dont know it this is the plan ?
Should we get rid of "per_cpu__" prefix and use a special ELF section/
marker instead ?

I have a patch to add percpu_inc() and percpu_dec(), I am not
sure its worth it...

[PATCH] percpu: Adds percpu_inc() and percpu_dec()

Increments and decrements are quite common operations for SNMP mibs.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percp=
u.h
index aee103b..248be11 100644
--- a/arch/x86/include/asm/percpu.h
+++ b/arch/x86/include/asm/percpu.h
@@ -103,6 +103,29 @@ do {							\
 	}						\
 } while (0)
=20
+#define percpu_to_op0(op, var)				\
+do {							\
+	switch (sizeof(var)) {				\
+	case 1:						\
+		asm(op "b "__percpu_arg(0)		\
+		    : "+m" (var));			\
+		break;					\
+	case 2:						\
+		asm(op "w "__percpu_arg(0)		\
+		    : "+m" (var));			\
+		break;					\
+	case 4:						\
+		asm(op "l "__percpu_arg(0)		\
+		    : "+m" (var));			\
+		break;					\
+	case 8:						\
+		asm(op "q "__percpu_arg(0)		\
+		    : "+m" (var));			\
+		break;					\
+	default: __bad_percpu_size();			\
+	}						\
+} while (0)
+
 #define percpu_from_op(op, var)				\
 ({							\
 	typeof(var) ret__;				\
@@ -139,6 +162,8 @@ do {							\
 #define percpu_and(var, val)	percpu_to_op("and", per_cpu__##var, val)
 #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)
 #define percpu_xor(var, val)	percpu_to_op("xor", per_cpu__##var, val)
+#define percpu_inc(var)		percpu_to_op0("inc", per_cpu__##var)
+#define percpu_dec(var)		percpu_to_op0("dec", per_cpu__##var)
=20
 /* This is not atomic against other CPUs -- CPU preemption needs to be=
 off */
 #define x86_test_and_clear_bit_percpu(bit, var)				\
diff --git a/include/asm-generic/percpu.h b/include/asm-generic/percpu.=
h
index 00f45ff..c57357e 100644
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -120,6 +120,14 @@ do {									\
 # define percpu_sub(var, val)		__percpu_generic_to_op(var, (val), -=3D=
)
 #endif
=20
+#ifndef percpu_inc
+# define percpu_inc(var)			do { percpu_add(var, 1); } while (0)
+#endif
+
+#ifndef percpu_dec
+# define percpu_dec(var)			do { percpu_sub(var, 1); } while (0)
+#endif
+
 #ifndef percpu_and
 # define percpu_and(var, val)		__percpu_generic_to_op(var, (val), &=3D=
)
 #endif
