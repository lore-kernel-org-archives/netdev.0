From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 16 Mar 2009 23:22:01 +0100
Message-ID: <49BED109.3020504@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60973 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbZCPWWx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 18:22:53 -0400
In-Reply-To: <20090313.153851.11725991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 13 Mar 2009 23:30:31 +0100
>=20
>> David Miller a =E9crit :
>>>> Also, when an event was queued for later invocation, I also needed=
 to keep
>>>> a reference on "struct socket" to make sure it doesnt disappear be=
fore
>>>> the invocation. Not all sockets are RCU guarded (we added RCU only=
 for=20
>>>> some protocols (TCP, UDP ...). So I found keeping a read_lock
>>>> on callback was the easyest thing to do. I now realize we might
>>>> overflow preempt_count, so special care is needed.
>>> You're using this in UDP so... make the rule that you can't use
>>> this with a non-RCU-quiescent protocol.
>> UDP/TCP only ? I though many other protocols (not all using RCU) wer=
e
>> using sock_def_readable() too...
>=20
> Maybe create a inet_def_readable() just for this purpose :-)


Here is the last incantation of the patch, that of course should be
split in two parts and better Changelog for further discussion on lkml.

We need to take a reference on sock when queued on a softirq delay
list. RCU wont help here because of SLAB_DESTROY_BY_RCU thing :
Another cpu could free/reuse the socket before we have a chance to
call softirq_delay_exec()

UDP & UDPLite use this delayed wakeup feature.

Thank you

[PATCH] softirq: Introduce mechanism to defer wakeups

Some network workloads need to call scheduler too many times. For examp=
le,
each received multicast frame can wakeup many threads. ksoftirqd is the=
n
not able to drain NIC RX queues in time and we get frame losses and hig=
h
latencies.

This patch adds an infrastructure to delay work done in
sock_def_readable() at end of do_softirq(). This needs to
make available current->softirq_context even if !CONFIG_TRACE_IRQFLAGS


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/interrupt.h |   18 +++++++++++++++
 include/linux/irqflags.h  |   11 ++++-----
 include/linux/sched.h     |    2 -
 include/net/sock.h        |    2 +
 include/net/udplite.h     |    1
 kernel/lockdep.c          |    2 -
 kernel/softirq.c          |   42 ++++++++++++++++++++++++++++++++++--
 lib/locking-selftest.c    |    4 +--
 net/core/sock.c           |   41 +++++++++++++++++++++++++++++++++++
 net/ipv4/udp.c            |    7 ++++++
 net/ipv6/udp.c            |    7 ++++++
 11 files changed, 125 insertions(+), 12 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 9127f6b..a773d0c 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -295,6 +295,24 @@ extern void send_remote_softirq(struct call_single=
_data *cp, int cpu, int softir
 extern void __send_remote_softirq(struct call_single_data *cp, int cpu=
,
 				  int this_cpu, int softirq);
=20
+/*
+ * softirq delayed works : should be delayed at do_softirq() end
+ */
+struct softirq_delay {
+	struct softirq_delay	*next;
+	void 			(*func)(struct softirq_delay *);
+};
+
+int softirq_delay_queue(struct softirq_delay *sdel);
+
+static inline void softirq_delay_init(struct softirq_delay *sdel,
+				      void (*func)(struct softirq_delay *))
+{
+	sdel->next =3D NULL;
+	sdel->func =3D func;
+}
+
+
 /* Tasklets --- multithreaded analogue of BHs.
=20
    Main feature differing them of generic softirqs: tasklet
diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 74bde13..30c1e01 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -13,19 +13,21 @@
=20
 #include <linux/typecheck.h>
=20
+#define softirq_enter()	do { current->softirq_context++; } while (0)
+#define softirq_exit()	do { current->softirq_context--; } while (0)
+#define softirq_context(p)	((p)->softirq_context)
+#define running_from_softirq()  (softirq_context(current) > 0)
+
 #ifdef CONFIG_TRACE_IRQFLAGS
   extern void trace_softirqs_on(unsigned long ip);
   extern void trace_softirqs_off(unsigned long ip);
   extern void trace_hardirqs_on(void);
   extern void trace_hardirqs_off(void);
 # define trace_hardirq_context(p)	((p)->hardirq_context)
-# define trace_softirq_context(p)	((p)->softirq_context)
 # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
 # define trace_hardirq_enter()	do { current->hardirq_context++; } whil=
e (0)
 # define trace_hardirq_exit()	do { current->hardirq_context--; } while=
 (0)
-# define trace_softirq_enter()	do { current->softirq_context++; } whil=
e (0)
-# define trace_softirq_exit()	do { current->softirq_context--; } while=
 (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled =3D 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
@@ -33,13 +35,10 @@
 # define trace_softirqs_on(ip)		do { } while (0)
 # define trace_softirqs_off(ip)		do { } while (0)
 # define trace_hardirq_context(p)	0
-# define trace_softirq_context(p)	0
 # define trace_hardirqs_enabled(p)	0
 # define trace_softirqs_enabled(p)	0
 # define trace_hardirq_enter()		do { } while (0)
 # define trace_hardirq_exit()		do { } while (0)
-# define trace_softirq_enter()		do { } while (0)
-# define trace_softirq_exit()		do { } while (0)
 # define INIT_TRACE_IRQFLAGS
 #endif
=20
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8c216e0..5dd8487 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1320,8 +1320,8 @@ struct task_struct {
 	unsigned long softirq_enable_ip;
 	unsigned int softirq_enable_event;
 	int hardirq_context;
-	int softirq_context;
 #endif
+	int softirq_context;
 #ifdef CONFIG_LOCKDEP
 # define MAX_LOCK_DEPTH 48UL
 	u64 curr_chain_key;
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..0160a83 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -260,6 +260,7 @@ struct sock {
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot_creator;
+	struct softirq_delay	sk_delay;
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
@@ -960,6 +961,7 @@ extern void *sock_kmalloc(struct sock *sk, int size=
,
 			  gfp_t priority);
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
+extern void inet_def_readable(struct sock *sk, int len);
=20
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
diff --git a/include/net/udplite.h b/include/net/udplite.h
index afdffe6..7ce0ee0 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -25,6 +25,7 @@ static __inline__ int udplite_getfrag(void *from, cha=
r *to, int  offset,
 /* Designate sk as UDP-Lite socket */
 static inline int udplite_sk_init(struct sock *sk)
 {
+	sk->sk_data_ready =3D inet_def_readable;
 	udp_sk(sk)->pcflag =3D UDPLITE_BIT;
 	return 0;
 }
diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 06b0c35..9873b40 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -1807,7 +1807,7 @@ print_usage_bug(struct task_struct *curr, struct =
held_lock *this,
 	printk("%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] takes:\n",
 		curr->comm, task_pid_nr(curr),
 		trace_hardirq_context(curr), hardirq_count() >> HARDIRQ_SHIFT,
-		trace_softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
+		softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
 		trace_hardirqs_enabled(curr),
 		trace_softirqs_enabled(curr));
 	print_lock(this);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index bdbe9de..91a1714 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -158,6 +158,42 @@ void local_bh_enable_ip(unsigned long ip)
 }
 EXPORT_SYMBOL(local_bh_enable_ip);
=20
+
+#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
+static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) =3D =
{
+	SOFTIRQ_DELAY_END
+};
+
+/*
+ * Caller must disable preemption, and take care of appropriate
+ * locking and refcounting
+ */
+int softirq_delay_queue(struct softirq_delay *sdel)
+{
+	if (!sdel->next) {
+		sdel->next =3D __get_cpu_var(softirq_delay_head);
+		__get_cpu_var(softirq_delay_head) =3D sdel;
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Because locking is provided by subsystem, please note
+ * that sdel->func(sdel) is responsible for setting sdel->next to NULL
+ */
+static void softirq_delay_exec(void)
+{
+	struct softirq_delay *sdel;
+
+	while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D SOFTIRQ_DELA=
Y_END) {
+		__get_cpu_var(softirq_delay_head) =3D sdel->next;
+		sdel->func(sdel);	/*	sdel->next =3D NULL;*/
+		}
+}
+
+
+
 /*
  * We restart softirq processing MAX_SOFTIRQ_RESTART times,
  * and we fall back to softirqd after that.
@@ -180,7 +216,7 @@ asmlinkage void __do_softirq(void)
 	account_system_vtime(current);
=20
 	__local_bh_disable((unsigned long)__builtin_return_address(0));
-	trace_softirq_enter();
+	softirq_enter();
=20
 	cpu =3D smp_processor_id();
 restart:
@@ -211,6 +247,8 @@ restart:
 		pending >>=3D 1;
 	} while (pending);
=20
+	softirq_delay_exec();
+
 	local_irq_disable();
=20
 	pending =3D local_softirq_pending();
@@ -220,7 +258,7 @@ restart:
 	if (pending)
 		wakeup_softirqd();
=20
-	trace_softirq_exit();
+	softirq_exit();
=20
 	account_system_vtime(current);
 	_local_bh_enable();
diff --git a/lib/locking-selftest.c b/lib/locking-selftest.c
index 280332c..1aa7351 100644
--- a/lib/locking-selftest.c
+++ b/lib/locking-selftest.c
@@ -157,11 +157,11 @@ static void init_shared_classes(void)
 #define SOFTIRQ_ENTER()				\
 		local_bh_disable();		\
 		local_irq_disable();		\
-		trace_softirq_enter();		\
+		softirq_enter();		\
 		WARN_ON(!in_softirq());
=20
 #define SOFTIRQ_EXIT()				\
-		trace_softirq_exit();		\
+		softirq_exit();		\
 		local_irq_enable();		\
 		local_bh_enable();
=20
diff --git a/net/core/sock.c b/net/core/sock.c
index 0620046..c8745d1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -213,6 +213,8 @@ __u32 sysctl_rmem_default __read_mostly =3D SK_RMEM=
_MAX;
 /* Maximal space eaten by iovec or ancilliary data plus some space */
 int sysctl_optmem_max __read_mostly =3D sizeof(unsigned long)*(2*UIO_M=
AXIOV+512);
=20
+static void sock_readable_defer(struct softirq_delay *sdel);
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int op=
tlen)
 {
 	struct timeval tv;
@@ -1074,6 +1076,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 #endif
=20
 		rwlock_init(&newsk->sk_dst_lock);
+		softirq_delay_init(&newsk->sk_delay, sock_readable_defer);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1691,6 +1694,43 @@ static void sock_def_readable(struct sock *sk, i=
nt len)
 	read_unlock(&sk->sk_callback_lock);
 }
=20
+/*
+ * helper function called by softirq_delay_exec(),
+ * if inet_def_readable() queued us.
+ */
+static void sock_readable_defer(struct softirq_delay *sdel)
+{
+	struct sock *sk =3D container_of(sdel, struct sock, sk_delay);
+
+	sdel->next =3D NULL;
+	/*
+	 * At this point, we dont own a lock on socket, only a reference.
+	 * We must commit above write, or another cpu could miss a wakeup
+	 */
+	smp_wmb();
+	sock_def_readable(sk, 0);
+	sock_put(sk);
+}
+
+/*
+ * Custom version of sock_def_readable()
+ * We want to defer scheduler processing at the end of do_softirq()
+ * Called with socket locked.
+ */
+void inet_def_readable(struct sock *sk, int len)
+{
+	if (running_from_softirq()) {
+		if (softirq_delay_queue(&sk->sk_delay))
+			/*
+			 * If we queued this socket, take a reference on it
+			 * Caller owns socket lock, so write to sk_delay.next
+			 * will be committed before unlock.
+			 */
+			sock_hold(sk);
+	} else
+		sock_def_readable(sk, len);
+}
+
 static void sock_def_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
@@ -1768,6 +1808,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 		sk->sk_sleep	=3D	NULL;
=20
 	rwlock_init(&sk->sk_dst_lock);
+	softirq_delay_init(&sk->sk_delay, sock_readable_defer);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 05b7abb..1cc0907 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1342,6 +1342,12 @@ void udp_destroy_sock(struct sock *sk)
 	release_sock(sk);
 }
=20
+static int udp_init_sock(struct sock *sk)
+{
+	sk->sk_data_ready =3D inet_def_readable;
+	return 0;
+}
+
 /*
  *	Socket option code for UDP
  */
@@ -1559,6 +1565,7 @@ struct proto udp_prot =3D {
 	.connect	   =3D ip4_datagram_connect,
 	.disconnect	   =3D udp_disconnect,
 	.ioctl		   =3D udp_ioctl,
+	.init		   =3D udp_init_sock,
 	.destroy	   =3D udp_destroy_sock,
 	.setsockopt	   =3D udp_setsockopt,
 	.getsockopt	   =3D udp_getsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 84b1a29..1a9f8d4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -960,6 +960,12 @@ void udpv6_destroy_sock(struct sock *sk)
 	inet6_destroy_sock(sk);
 }
=20
+static int udpv6_init_sock(struct sock *sk)
+{
+	sk->sk_data_ready =3D inet_def_readable;
+	return 0;
+}
+
 /*
  *	Socket option code for UDP
  */
@@ -1084,6 +1090,7 @@ struct proto udpv6_prot =3D {
 	.connect	   =3D ip6_datagram_connect,
 	.disconnect	   =3D udp_disconnect,
 	.ioctl		   =3D udp_ioctl,
+	.init 		   =3D udpv6_init_sock,
 	.destroy	   =3D udpv6_destroy_sock,
 	.setsockopt	   =3D udpv6_setsockopt,
 	.getsockopt	   =3D udpv6_getsockopt,

