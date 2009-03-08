From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Sun, 08 Mar 2009 17:46:13 +0100
Message-ID: <49B3F655.6030308@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	cl@linux-foundation.org, Brian Bloniarz <bmb@athenacr.com>
To: kchang@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44800 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbZCHQqc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 12:46:32 -0400
In-Reply-To: <49B2266C.9050701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>=20
> I have more questions :
>=20
> What is the maximum latency you can afford on the delivery of the pac=
ket(s) ?
>=20
> Are user apps using real time scheduling ?
>=20
> I had an idea, that keep cpu handling NIC interrupts only delivering =
packets to
> socket queues, and not messing with scheduler : fast queueing, and wa=
keing up
> a workqueue (on another cpu) to perform the scheduler work. But that =
means
> some extra latency (in the order of 2 or 3 us I guess)
>=20
> We could enter in this mode automatically, if the NIC rx handler *see=
* more than
> N packets are waiting in NIC queue : In case of moderate or light tra=
fic, no
> extra latency would be necessary. This would mean some changes in NIC=
 driver.
>=20
> Hum, then, if NIC rx handler is run beside the ksoftirqd, we already =
know
> we are in a stress situation, so maybe no driver changes are necessar=
y :
> Just test if we run ksoftirqd...
>=20

Here is a patch that helps. It's still an RFC of course, since its some=
what ugly :)

I am now able to have 8 receivers on my 8 cpus machine, with one multic=
ast packet every 10 us,
without any loss. (standard setup, no affinity games)

oprofile results see that scheduler overhead vanished, we get back to p=
ure network profile :)

(First offender being __copy_skb_header because of the atomic_inc on ds=
t refcount)

CPU: Core 2, speed 3000.43 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
126329   126329        20.4296  20.4296    __copy_skb_header
31395    157724         5.0771  25.5067    udp_queue_rcv_skb
29191    186915         4.7207  30.2274    sock_def_readable
26284    213199         4.2506  34.4780    sock_queue_rcv_skb
26010    239209         4.2063  38.6842    kmem_cache_alloc
20040    259249         3.2408  41.9251    __udp4_lib_rcv
19570    278819         3.1648  45.0899    skb_queue_tail
17799    296618         2.8784  47.9683    bnx2_poll_work
17267    313885         2.7924  50.7606    skb_release_data
14663    328548         2.3713  53.1319    __skb_recv_datagram
14443    342991         2.3357  55.4676    __slab_alloc
13248    356239         2.1424  57.6100    copy_to_user
13138    369377         2.1246  59.7347    __sk_mem_schedule
12004    381381         1.9413  61.6759    __skb_clone
11924    393305         1.9283  63.6042    skb_clone
11077    404382         1.7913  65.3956    lock_sock_nested
10320    414702         1.6689  67.0645    ip_route_input
9622     424324         1.5560  68.6205    dst_release
8344     432668         1.3494  69.9699    __slab_free
8124     440792         1.3138  71.2837    mwait_idle
7066     447858         1.1427  72.4264    udp_recvmsg
6652     454510         1.0757  73.5021    netif_receive_skb
6386     460896         1.0327  74.5349    ipt_do_table
6010     466906         0.9719  75.5068    release_sock
6003     472909         0.9708  76.4776    memcpy_toiovec
5697     478606         0.9213  77.3989    __alloc_skb
5671     484277         0.9171  78.3160    copy_from_user
5031     489308         0.8136  79.1296    sysenter_past_esp
4753     494061         0.7686  79.8982    bnx2_interrupt
4429     498490         0.7162  80.6145    sock_rfree


[PATCH] softirq: Introduce mechanism to defer wakeups

Some network workloads need to call scheduler too many times. For examp=
le,
each received multicast frame can wakeup many threads. ksoftirqd is the=
n
not able to drain NIC RX queues and we get frame losses and high latenc=
ies.

This patch adds an infrastructure to delay part of work done in
sock_def_readable() at end of do_softirq()


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/interrupt.h |    9 +++++++++
 include/net/sock.h        |    1 +
 kernel/softirq.c          |   29 ++++++++++++++++++++++++++++-
 net/core/sock.c           |   21 +++++++++++++++++++--
 4 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 9127f6b..62caaae 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -295,6 +295,15 @@ extern void send_remote_softirq(struct call_single=
_data *cp, int cpu, int softir
 extern void __send_remote_softirq(struct call_single_data *cp, int cpu=
,
 				  int this_cpu, int softirq);
=20
+/*
+ * delayed works : should be delayed at do_softirq() end
+ */
+struct softirq_del {
+	struct softirq_del	*next;
+	void 			(*func)(struct softirq_del *);
+};
+int softirq_del(struct softirq_del *sdel, void (*func)(struct softirq_=
del *));
+
 /* Tasklets --- multithreaded analogue of BHs.
=20
    Main feature differing them of generic softirqs: tasklet
diff --git a/include/net/sock.h b/include/net/sock.h
index eefeeaf..95841de 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -260,6 +260,7 @@ struct sock {
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot_creator;
+	struct softirq_del	sk_del;
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
diff --git a/kernel/softirq.c b/kernel/softirq.c
index bdbe9de..40fe527 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -158,6 +158,33 @@ void local_bh_enable_ip(unsigned long ip)
 }
 EXPORT_SYMBOL(local_bh_enable_ip);
=20
+
+static DEFINE_PER_CPU(struct softirq_del *, softirq_del_head);
+int softirq_del(struct softirq_del *sdel, void (*func)(struct softirq_=
del *))
+{
+	if (cmpxchg(&sdel->func, NULL, func) =3D=3D NULL) {
+		sdel->next =3D __get_cpu_var(softirq_del_head);
+		__get_cpu_var(softirq_del_head) =3D sdel;
+		return 1;
+	}
+	return 0;
+}
+
+static void softirqdel_exec(void)
+{
+	struct softirq_del *sdel;
+	void (*func)(struct softirq_del *);
+
+	while ((sdel =3D __get_cpu_var(softirq_del_head)) !=3D NULL) {
+		__get_cpu_var(softirq_del_head) =3D sdel->next;
+		func =3D sdel->func;
+		sdel->func =3D NULL;
+		(*func)(sdel);
+		}
+}
+
+
+
 /*
  * We restart softirq processing MAX_SOFTIRQ_RESTART times,
  * and we fall back to softirqd after that.
@@ -219,7 +246,7 @@ restart:
=20
 	if (pending)
 		wakeup_softirqd();
-
+	softirqdel_exec();
 	trace_softirq_exit();
=20
 	account_system_vtime(current);
diff --git a/net/core/sock.c b/net/core/sock.c
index 5f97caa..f9ee8dd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1026,6 +1026,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 #endif
=20
 		rwlock_init(&newsk->sk_dst_lock);
+		newsk->sk_del.func =3D NULL;
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1634,12 +1635,27 @@ static void sock_def_error_report(struct sock *=
sk)
 	read_unlock(&sk->sk_callback_lock);
 }
=20
+static void sock_readable_defer(struct softirq_del *sdel)
+{
+	struct sock *sk =3D container_of(sdel, struct sock, sk_del);
+
+	wake_up_interruptible_sync(sk->sk_sleep);
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
+		if (in_softirq()) {
+			if (!softirq_del(&sk->sk_del, sock_readable_defer))
+				goto unlock;
+			return;
+		}
+		wake_up_interruptible_sync(sk->sk_sleep);
+	}
+unlock:
 	read_unlock(&sk->sk_callback_lock);
 }
=20
@@ -1720,6 +1736,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 		sk->sk_sleep	=3D	NULL;
=20
 	rwlock_init(&sk->sk_dst_lock);
+	sk->sk_del.func		=3D	NULL;
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,

