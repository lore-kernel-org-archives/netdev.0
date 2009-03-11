From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Wed, 11 Mar 2009 04:00:38 +0100
Message-ID: <49B72956.9050504@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com> <49B3F655.6030308@cosmosbay.com> <49B59EA3.3000208@athenacr.com> <49B5FA84.9000301@cosmosbay.com> <49B6F645.2070408@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52247 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbZCKDAv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 23:00:51 -0400
In-Reply-To: <49B6F645.2070408@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Hi Eric,
>=20
> FYI: with your patch applied and lockdep enabled, I see:
> [   39.114628] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> [   39.121964] [ BUG: lock held when returning to user space! ]
> [   39.127704] ------------------------------------------------
> [   39.133461] msgtest/5242 is leaving the kernel with locks still he=
ld!
> [   39.140132] 1 lock held by msgtest/5242:
> [   39.144287]  #0:  (clock-AF_INET){-.-?}, at: [<ffffffff8041f5b9>]
> sock_def_readable+0x19/0xb0

And you told me you were not a kernel hacker ;)

>=20
> I can't reproduced this with the mcasttest program yet, it
> was with an internal test program which does some userspace
> processing on the messages. I'll let you know if I find a way
> to reproduce it with a simple program I can share.

I reproduced it as well here quite easily with a tcpdump of a tcp sessi=
on,
thanks for the report.

It seems  "if (in_softirq())" doesnt do what I thought.

I wanted to test if we were called from __do_softirq() handler,
since only this function is calling softirq_delay_exec()
to dequeue events.

It appears I have to make current->softirq_context available
even if !CONFIG_TRACE_IRQFLAGS

Here is an updated version of the patch.

I also made the call to softirq_delay_exec() is performed
with interrupts enabled, and that preempt count wont
overflow if many events are queued.

[PATCH] softirq: Introduce mechanism to defer wakeups

Some network workloads need to call scheduler too many times. For examp=
le,
each received multicast frame can wakeup many threads. ksoftirqd is the=
n
not able to drain NIC RX queues and we get frame losses and high latenc=
ies.

This patch adds an infrastructure to delay part of work done in
sock_def_readable() at end of do_softirq(). This need to
make available current->softirq_context even if !CONFIG_TRACE_IRQFLAGS


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/interrupt.h |   18 +++++++++++++++++
 include/linux/irqflags.h  |    7 ++----
 include/linux/sched.h     |    2 -
 include/net/sock.h        |    1
 kernel/softirq.c          |   34 +++++++++++++++++++++++++++++++++
 net/core/sock.c           |   37 ++++++++++++++++++++++++++++++++++--
 6 files changed, 92 insertions(+), 7 deletions(-)


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
index 74bde13..fe55ec4 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -13,6 +13,9 @@
=20
 #include <linux/typecheck.h>
=20
+#define trace_softirq_enter()	do { current->softirq_context++; } while=
 (0)
+#define trace_softirq_exit()	do { current->softirq_context--; } while =
(0)
+
 #ifdef CONFIG_TRACE_IRQFLAGS
   extern void trace_softirqs_on(unsigned long ip);
   extern void trace_softirqs_off(unsigned long ip);
@@ -24,8 +27,6 @@
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
@@ -38,8 +39,6 @@
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
index eefeeaf..1bfd9b8 100644
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
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 9041ea7..c601730 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -158,6 +158,38 @@ void local_bh_enable_ip(unsigned long ip)
 }
 EXPORT_SYMBOL(local_bh_enable_ip);
=20
+
+#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
+
+static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) =3D =
{
+	SOFTIRQ_DELAY_END
+};
+
+/*
+ * Preemption is disabled by caller
+ */
+int softirq_delay_queue(struct softirq_delay *sdel)
+{
+	if (cmpxchg(&sdel->next, NULL, __get_cpu_var(softirq_delay_head)) =3D=
=3D NULL) {
+		__get_cpu_var(softirq_delay_head) =3D sdel;
+		return 1;
+	}
+	return 0;
+}
+
+static void softirq_delay_exec(void)
+{
+	struct softirq_delay *sdel;
+
+	while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D SOFTIRQ_DELA=
Y_END) {
+		__get_cpu_var(softirq_delay_head) =3D sdel->next;
+		sdel->next =3D NULL;
+		sdel->func(sdel);
+		}
+}
+
+
+
 /*
  * We restart softirq processing MAX_SOFTIRQ_RESTART times,
  * and we fall back to softirqd after that.
@@ -211,6 +243,8 @@ restart:
 		pending >>=3D 1;
 	} while (pending);
=20
+	softirq_delay_exec();
+
 	local_irq_disable();
=20
 	pending =3D local_softirq_pending();
diff --git a/net/core/sock.c b/net/core/sock.c
index 5f97caa..d51d57d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -212,6 +212,8 @@ __u32 sysctl_rmem_default __read_mostly =3D SK_RMEM=
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
@@ -1026,6 +1028,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 #endif
=20
 		rwlock_init(&newsk->sk_dst_lock);
+		softirq_delay_init(&newsk->sk_delay, sock_readable_defer);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1634,12 +1637,41 @@ static void sock_def_error_report(struct sock *=
sk)
 	read_unlock(&sk->sk_callback_lock);
 }
=20
+static void sock_readable_defer(struct softirq_delay *sdel)
+{
+	struct sock *sk =3D container_of(sdel, struct sock, sk_delay);
+
+	wake_up_interruptible_sync(sk->sk_sleep);
+	/*
+	 * Before unlocking, we increase preempt_count,
+	 * as it was decreased in sock_def_readable()
+	 */
+	preempt_disable();
+	read_unlock(&sk->sk_callback_lock);
+}
+
 static void sock_def_readable(struct sock *sk, int len)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_sync(sk->sk_sleep);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
+		if (current->softirq_context) {
+			/*
+			 * If called from __do_softirq(), we want to delay
+			 * calls to wake_up_interruptible_sync()
+			 */
+			if (!softirq_delay_queue(&sk->sk_delay))
+				goto unlock;
+			/*
+			 * We keep sk->sk_callback_lock read locked,
+			 * but decrease preempt_count to avoid an overflow
+			 */
+			preempt_enable_no_resched();
+			return;
+		}
+		wake_up_interruptible_sync(sk->sk_sleep);
+	}
+unlock:
 	read_unlock(&sk->sk_callback_lock);
 }
=20
@@ -1720,6 +1752,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 		sk->sk_sleep	=3D	NULL;
=20
 	rwlock_init(&sk->sk_dst_lock);
+	softirq_delay_init(&sk->sk_delay, sock_readable_defer);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,

