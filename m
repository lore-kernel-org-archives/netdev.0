From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Fri, 03 Apr 2009 15:28:57 -0400
Message-ID: <49D66379.7070106@athenacr.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1040 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755616AbZDCT3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 15:29:09 -0400
In-Reply-To: <49BED109.3020504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

We've been experimenting with this softirq-delay patch in production, a=
nd
have seen some hard-to-reproduce crashes. We finally managed to capture=
 a
kexec crashdump this morning.

This is the dmesg:

[53417.592868] Unable to handle kernel NULL pointer dereference at 0000=
000000000000 RIP:
[53417.598377]  [<ffffffff80243643>] __do_softirq+0xc3/0x150
[53417.606300] PGD 32abb8067 PUD 32faf5067 PMD 0
[53417.610829] Oops: 0000 [1] SMP
[53417.614032] CPU 2
[53417.616083] Modules linked in: nfs lockd nfs_acl sunrpc openafs(P) a=
utofs4 ipv6 ac sbs sbshc video output dock battery container iptable_fi=
lter ip_tables x_tables parport_pc lp parport loop joydev iTCO_wdt iTCO=
_vendor_support evdev button i5000_edac psmouse serio_raw pcspkr shpchp=
 pci_hotplug edac_core ext3 jbd mbcache sr_mod cdrom ata_generic usbhid=
 hid ata_piix sg sd_mod ehci_hcd pata_acpi uhci_hcd libata bnx2 aacraid=
 usbcore scsi_mod thermal processor fan fbcon tileblit font bitblit sof=
tcursor fuse
[53417.662067] Pid: 13039, comm: gball Tainted: P        2.6.24-19acr2-=
generic #1
[53417.669219] RIP: 0010:[<ffffffff80243643>]  [<ffffffff80243643>] __d=
o_softirq+0xc3/0x150
[53417.677368] RSP: 0018:ffff8103314f3f20  EFLAGS: 00010297
[53417.682697] RAX: ffff810084a1b000 RBX: ffffffff805ba530 RCX: 0000000=
000000000
[53417.689843] RDX: ffff8103305811e0 RSI: 0000000000000282 RDI: ffff810=
332ada580
[53417.696993] RBP: 0000000000000000 R08: ffff81032fad9f08 R09: ffff810=
332382000
[53417.704144] R10: 0000000000000000 R11: ffffffff80316ec0 R12: fffffff=
f8062b3d8
[53417.711294] R13: ffffffff8062b480 R14: 0000000000000002 R15: 0000000=
00000000a
[53417.718447] FS:  00007fab0d7b8750(0000) GS:ffff810334401b80(0000) kn=
lGS:0000000000000000
[53417.726568] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[53417.732332] CR2: 0000000000000000 CR3: 0000000329e2d000 CR4: 0000000=
0000006e0
[53417.739476] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[53417.746637] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[53417.753787] Process gball (pid: 13039, threadinfo ffff81032adde000, =
task ffff810329ff77d0)
[53417.761991] Stack:  ffffffff8062b3d8 0000000000000046 ffff8103314f3f=
68 0000000000000000
[53417.770146]  00000000000000a0 ffff81032addfee8 0000000000000000 ffff=
ffff8020d50c
[53417.777660]  ffff8103314f3f68 00000000000000c1 ffffffff8020ed25 ffff=
ffff8062c870
[53417.784961] Call Trace:
[53417.787635]  <IRQ>  [<ffffffff8020d50c>] call_softirq+0x1c/0x30
[53417.793597]  [<ffffffff8020ed25>] do_softirq+0x35/0x90
[53417.798747]  [<ffffffff80243578>] irq_exit+0x88/0x90
[53417.803727]  [<ffffffff8020ef70>] do_IRQ+0x80/0x100
[53417.808624]  [<ffffffff8020c891>] ret_from_intr+0x0/0xa
[53417.813862]  <EOI>  [<ffffffff803e53c8>] skb_release_all+0x18/0x150
[53417.820164]  [<ffffffff803e4ad9>] __kfree_skb+0x9/0x90
[53417.825327]  [<ffffffff80437612>] udp_recvmsg+0x222/0x260
[53417.830744]  [<ffffffff80231264>] source_load+0x34/0x70
[53417.835984]  [<ffffffff80232a9a>] find_busiest_group+0x1fa/0x850
[53417.842019]  [<ffffffff803e0100>] sock_common_recvmsg+0x30/0x50
[53417.847958]  [<ffffffff803de1ca>] sock_recvmsg+0x14a/0x160
[53417.853462]  [<ffffffff80231c21>] update_curr+0x71/0x100
[53419.858789]  [<ffffffff802320fd>] __dequeue_entity+0x3d/0x50
[53417.864469]  [<ffffffff80253ab0>] autoremove_wake_function+0x0/0x30
[53417.870758]  [<ffffffff8046662f>] thread_return+0x3a/0x57b
[53417.876262]  [<ffffffff803df73e>] sys_recvfrom+0xfe/0x190
[53417.881680]  [<ffffffff802e2a95>] sys_epoll_wait+0x245/0x4e0
[53417.887358]  [<ffffffff80233e20>] default_wake_function+0x0/0x10
[53417.893384]  [<ffffffff8020c37e>] system_call+0x7e/0x83
[53417.898628]
[53417.900134]
[53417.900134] Code: 48 8b 11 48 89 cf 65 48 8b 04 25 08 00 00 00 4a 89=
 14 20 ff
[53417.909430] RIP  [<ffffffff80243643>] __do_softirq+0xc3/0x150
[53417.915210]  RSP <ffff8103314f3f20>

The disassembly where it crashed:
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
ffffffff8024361b:       d1 ed                   shr    %ebp
rcu_bh_qsctr_inc():
/local/home/bmb/doc/kernels/linux-hardy-eric/include/linux/rcupdate.h:1=
30
ffffffff8024361d:       48 8b 40 08             mov    0x8(%rax),%rax
ffffffff80243621:       41 c7 44 05 08 01 00    movl   $0x1,0x8(%r13,%r=
ax,1)
ffffffff80243628:       00 00
__do_softirq():
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
ffffffff8024362a:       75 d8                   jne    ffffffff80243604=
 <__do_softirq+0x84>
softirq_delay_exec():
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
ffffffff8024362c:       48 8b 14 24             mov    (%rsp),%rdx
ffffffff80243630:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
ffffffff80243637:       00 00
ffffffff80243639:       48 8b 0c 10             mov    (%rax,%rdx,1),%r=
cx
ffffffff8024363d:       48 83 f9 01             cmp    $0x1,%rcx
ffffffff80243641:       74 29                   je     ffffffff8024366c=
 <__do_softirq+0xec>
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
ffffffff80243643:       48 8b 11                mov    (%rcx),%rdx
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
ffffffff80243646:       48 89 cf                mov    %rcx,%rdi
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
ffffffff80243649:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
ffffffff80243650:       00 00
ffffffff80243652:       4a 89 14 20             mov    %rdx,(%rax,%r12,=
1)
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
ffffffff80243656:       ff 51 08                callq  *0x8(%rcx)
/local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
ffffffff80243659:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
ffffffff80243660:       00 00
ffffffff80243662:       4a 8b 0c 20             mov    (%rax,%r12,1),%r=
cx
ffffffff80243666:       48 83 f9 01             cmp    $0x1,%rcx
ffffffff8024366a:       75 d7                   jne    ffffffff80243643=
 <__do_softirq+0xc3>
raw_local_irq_disable():
/local/home/bmb/doc/kernels/linux-hardy-eric/debian/build/build-generic=
/include2/asm/irqflags_64.h:76
ffffffff8024366c:       fa                      cli

And softirq.c line numbers:
    218   * Because locking is provided by subsystem, please note
    219   * that sdel->func(sdel) is responsible for setting sdel->next=
 to NULL
    220   */
    221  static void softirq_delay_exec(void)
    222  {
    223          struct softirq_delay *sdel;
    224
    225          while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D=
 SOFTIRQ_DELAY_END) {
    226                  __get_cpu_var(softirq_delay_head) =3D sdel->ne=
xt;
    227                  sdel->func(sdel);       /*      sdel->next =3D=
 NULL;*/
    228                  }
    229  }

So it's crashing because __get_cpu_var(softirq_delay_head)) is NULL som=
ehow.

We aren't running a recent kernel -- we're running Ubuntu Hardy's 2.6.2=
4-19,
with a backported version of this patch. One more atypical thing is tha=
t
we run openafs, 1.4.6.dfsg1-2.

Like I said, I have a full vmcore (3, actually) and would be happy to p=
ost any
more information you'd like to know.

Thanks,
Brian Bloniarz

Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 13 Mar 2009 23:30:31 +0100
>>
>>> David Miller a =E9crit :
>>>>> Also, when an event was queued for later invocation, I also neede=
d to keep
>>>>> a reference on "struct socket" to make sure it doesnt disappear b=
efore
>>>>> the invocation. Not all sockets are RCU guarded (we added RCU onl=
y for=20
>>>>> some protocols (TCP, UDP ...). So I found keeping a read_lock
>>>>> on callback was the easyest thing to do. I now realize we might
>>>>> overflow preempt_count, so special care is needed.
>>>> You're using this in UDP so... make the rule that you can't use
>>>> this with a non-RCU-quiescent protocol.
>>> UDP/TCP only ? I though many other protocols (not all using RCU) we=
re
>>> using sock_def_readable() too...
>> Maybe create a inet_def_readable() just for this purpose :-)
>=20
>=20
> Here is the last incantation of the patch, that of course should be
> split in two parts and better Changelog for further discussion on lkm=
l.
>=20
> We need to take a reference on sock when queued on a softirq delay
> list. RCU wont help here because of SLAB_DESTROY_BY_RCU thing :
> Another cpu could free/reuse the socket before we have a chance to
> call softirq_delay_exec()
>=20
> UDP & UDPLite use this delayed wakeup feature.
>=20
> Thank you
>=20
> [PATCH] softirq: Introduce mechanism to defer wakeups
>=20
> Some network workloads need to call scheduler too many times. For exa=
mple,
> each received multicast frame can wakeup many threads. ksoftirqd is t=
hen
> not able to drain NIC RX queues in time and we get frame losses and h=
igh
> latencies.
>=20
> This patch adds an infrastructure to delay work done in
> sock_def_readable() at end of do_softirq(). This needs to
> make available current->softirq_context even if !CONFIG_TRACE_IRQFLAG=
S
>=20
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/linux/interrupt.h |   18 +++++++++++++++
>  include/linux/irqflags.h  |   11 ++++-----
>  include/linux/sched.h     |    2 -
>  include/net/sock.h        |    2 +
>  include/net/udplite.h     |    1
>  kernel/lockdep.c          |    2 -
>  kernel/softirq.c          |   42 ++++++++++++++++++++++++++++++++++-=
-
>  lib/locking-selftest.c    |    4 +--
>  net/core/sock.c           |   41 +++++++++++++++++++++++++++++++++++
>  net/ipv4/udp.c            |    7 ++++++
>  net/ipv6/udp.c            |    7 ++++++
>  11 files changed, 125 insertions(+), 12 deletions(-)
>=20
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 9127f6b..a773d0c 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -295,6 +295,24 @@ extern void send_remote_softirq(struct call_sing=
le_data *cp, int cpu, int softir
>  extern void __send_remote_softirq(struct call_single_data *cp, int c=
pu,
>  				  int this_cpu, int softirq);
> =20
> +/*
> + * softirq delayed works : should be delayed at do_softirq() end
> + */
> +struct softirq_delay {
> +	struct softirq_delay	*next;
> +	void 			(*func)(struct softirq_delay *);
> +};
> +
> +int softirq_delay_queue(struct softirq_delay *sdel);
> +
> +static inline void softirq_delay_init(struct softirq_delay *sdel,
> +				      void (*func)(struct softirq_delay *))
> +{
> +	sdel->next =3D NULL;
> +	sdel->func =3D func;
> +}
> +
> +
>  /* Tasklets --- multithreaded analogue of BHs.
> =20
>     Main feature differing them of generic softirqs: tasklet
> diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
> index 74bde13..30c1e01 100644
> --- a/include/linux/irqflags.h
> +++ b/include/linux/irqflags.h
> @@ -13,19 +13,21 @@
> =20
>  #include <linux/typecheck.h>
> =20
> +#define softirq_enter()	do { current->softirq_context++; } while (0)
> +#define softirq_exit()	do { current->softirq_context--; } while (0)
> +#define softirq_context(p)	((p)->softirq_context)
> +#define running_from_softirq()  (softirq_context(current) > 0)
> +
>  #ifdef CONFIG_TRACE_IRQFLAGS
>    extern void trace_softirqs_on(unsigned long ip);
>    extern void trace_softirqs_off(unsigned long ip);
>    extern void trace_hardirqs_on(void);
>    extern void trace_hardirqs_off(void);
>  # define trace_hardirq_context(p)	((p)->hardirq_context)
> -# define trace_softirq_context(p)	((p)->softirq_context)
>  # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
>  # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
>  # define trace_hardirq_enter()	do { current->hardirq_context++; } wh=
ile (0)
>  # define trace_hardirq_exit()	do { current->hardirq_context--; } whi=
le (0)
> -# define trace_softirq_enter()	do { current->softirq_context++; } wh=
ile (0)
> -# define trace_softirq_exit()	do { current->softirq_context--; } whi=
le (0)
>  # define INIT_TRACE_IRQFLAGS	.softirqs_enabled =3D 1,
>  #else
>  # define trace_hardirqs_on()		do { } while (0)
> @@ -33,13 +35,10 @@
>  # define trace_softirqs_on(ip)		do { } while (0)
>  # define trace_softirqs_off(ip)		do { } while (0)
>  # define trace_hardirq_context(p)	0
> -# define trace_softirq_context(p)	0
>  # define trace_hardirqs_enabled(p)	0
>  # define trace_softirqs_enabled(p)	0
>  # define trace_hardirq_enter()		do { } while (0)
>  # define trace_hardirq_exit()		do { } while (0)
> -# define trace_softirq_enter()		do { } while (0)
> -# define trace_softirq_exit()		do { } while (0)
>  # define INIT_TRACE_IRQFLAGS
>  #endif
> =20
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 8c216e0..5dd8487 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1320,8 +1320,8 @@ struct task_struct {
>  	unsigned long softirq_enable_ip;
>  	unsigned int softirq_enable_event;
>  	int hardirq_context;
> -	int softirq_context;
>  #endif
> +	int softirq_context;
>  #ifdef CONFIG_LOCKDEP
>  # define MAX_LOCK_DEPTH 48UL
>  	u64 curr_chain_key;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 4bb1ff9..0160a83 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -260,6 +260,7 @@ struct sock {
>  	unsigned long	        sk_lingertime;
>  	struct sk_buff_head	sk_error_queue;
>  	struct proto		*sk_prot_creator;
> +	struct softirq_delay	sk_delay;
>  	rwlock_t		sk_callback_lock;
>  	int			sk_err,
>  				sk_err_soft;
> @@ -960,6 +961,7 @@ extern void *sock_kmalloc(struct sock *sk, int si=
ze,
>  			  gfp_t priority);
>  extern void sock_kfree_s(struct sock *sk, void *mem, int size);
>  extern void sk_send_sigurg(struct sock *sk);
> +extern void inet_def_readable(struct sock *sk, int len);
> =20
>  /*
>   * Functions to fill in entries in struct proto_ops when a protocol
> diff --git a/include/net/udplite.h b/include/net/udplite.h
> index afdffe6..7ce0ee0 100644
> --- a/include/net/udplite.h
> +++ b/include/net/udplite.h
> @@ -25,6 +25,7 @@ static __inline__ int udplite_getfrag(void *from, c=
har *to, int  offset,
>  /* Designate sk as UDP-Lite socket */
>  static inline int udplite_sk_init(struct sock *sk)
>  {
> +	sk->sk_data_ready =3D inet_def_readable;
>  	udp_sk(sk)->pcflag =3D UDPLITE_BIT;
>  	return 0;
>  }
> diff --git a/kernel/lockdep.c b/kernel/lockdep.c
> index 06b0c35..9873b40 100644
> --- a/kernel/lockdep.c
> +++ b/kernel/lockdep.c
> @@ -1807,7 +1807,7 @@ print_usage_bug(struct task_struct *curr, struc=
t held_lock *this,
>  	printk("%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] takes:\n",
>  		curr->comm, task_pid_nr(curr),
>  		trace_hardirq_context(curr), hardirq_count() >> HARDIRQ_SHIFT,
> -		trace_softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
> +		softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
>  		trace_hardirqs_enabled(curr),
>  		trace_softirqs_enabled(curr));
>  	print_lock(this);
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index bdbe9de..91a1714 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -158,6 +158,42 @@ void local_bh_enable_ip(unsigned long ip)
>  }
>  EXPORT_SYMBOL(local_bh_enable_ip);
> =20
> +
> +#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
> +static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) =3D=
 {
> +	SOFTIRQ_DELAY_END
> +};
> +
> +/*
> + * Caller must disable preemption, and take care of appropriate
> + * locking and refcounting
> + */
> +int softirq_delay_queue(struct softirq_delay *sdel)
> +{
> +	if (!sdel->next) {
> +		sdel->next =3D __get_cpu_var(softirq_delay_head);
> +		__get_cpu_var(softirq_delay_head) =3D sdel;
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Because locking is provided by subsystem, please note
> + * that sdel->func(sdel) is responsible for setting sdel->next to NU=
LL
> + */
> +static void softirq_delay_exec(void)
> +{
> +	struct softirq_delay *sdel;
> +
> +	while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D SOFTIRQ_DE=
LAY_END) {
> +		__get_cpu_var(softirq_delay_head) =3D sdel->next;
> +		sdel->func(sdel);	/*	sdel->next =3D NULL;*/
> +		}
> +}
> +
> +
> +
>  /*
>   * We restart softirq processing MAX_SOFTIRQ_RESTART times,
>   * and we fall back to softirqd after that.
> @@ -180,7 +216,7 @@ asmlinkage void __do_softirq(void)
>  	account_system_vtime(current);
> =20
>  	__local_bh_disable((unsigned long)__builtin_return_address(0));
> -	trace_softirq_enter();
> +	softirq_enter();
> =20
>  	cpu =3D smp_processor_id();
>  restart:
> @@ -211,6 +247,8 @@ restart:
>  		pending >>=3D 1;
>  	} while (pending);
> =20
> +	softirq_delay_exec();
> +
>  	local_irq_disable();
> =20
>  	pending =3D local_softirq_pending();
> @@ -220,7 +258,7 @@ restart:
>  	if (pending)
>  		wakeup_softirqd();
> =20
> -	trace_softirq_exit();
> +	softirq_exit();
> =20
>  	account_system_vtime(current);
>  	_local_bh_enable();
> diff --git a/lib/locking-selftest.c b/lib/locking-selftest.c
> index 280332c..1aa7351 100644
> --- a/lib/locking-selftest.c
> +++ b/lib/locking-selftest.c
> @@ -157,11 +157,11 @@ static void init_shared_classes(void)
>  #define SOFTIRQ_ENTER()				\
>  		local_bh_disable();		\
>  		local_irq_disable();		\
> -		trace_softirq_enter();		\
> +		softirq_enter();		\
>  		WARN_ON(!in_softirq());
> =20
>  #define SOFTIRQ_EXIT()				\
> -		trace_softirq_exit();		\
> +		softirq_exit();		\
>  		local_irq_enable();		\
>  		local_bh_enable();
> =20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 0620046..c8745d1 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -213,6 +213,8 @@ __u32 sysctl_rmem_default __read_mostly =3D SK_RM=
EM_MAX;
>  /* Maximal space eaten by iovec or ancilliary data plus some space *=
/
>  int sysctl_optmem_max __read_mostly =3D sizeof(unsigned long)*(2*UIO=
_MAXIOV+512);
> =20
> +static void sock_readable_defer(struct softirq_delay *sdel);
> +
>  static int sock_set_timeout(long *timeo_p, char __user *optval, int =
optlen)
>  {
>  	struct timeval tv;
> @@ -1074,6 +1076,7 @@ struct sock *sk_clone(const struct sock *sk, co=
nst gfp_t priority)
>  #endif
> =20
>  		rwlock_init(&newsk->sk_dst_lock);
> +		softirq_delay_init(&newsk->sk_delay, sock_readable_defer);
>  		rwlock_init(&newsk->sk_callback_lock);
>  		lockdep_set_class_and_name(&newsk->sk_callback_lock,
>  				af_callback_keys + newsk->sk_family,
> @@ -1691,6 +1694,43 @@ static void sock_def_readable(struct sock *sk,=
 int len)
>  	read_unlock(&sk->sk_callback_lock);
>  }
> =20
> +/*
> + * helper function called by softirq_delay_exec(),
> + * if inet_def_readable() queued us.
> + */
> +static void sock_readable_defer(struct softirq_delay *sdel)
> +{
> +	struct sock *sk =3D container_of(sdel, struct sock, sk_delay);
> +
> +	sdel->next =3D NULL;
> +	/*
> +	 * At this point, we dont own a lock on socket, only a reference.
> +	 * We must commit above write, or another cpu could miss a wakeup
> +	 */
> +	smp_wmb();
> +	sock_def_readable(sk, 0);
> +	sock_put(sk);
> +}
> +
> +/*
> + * Custom version of sock_def_readable()
> + * We want to defer scheduler processing at the end of do_softirq()
> + * Called with socket locked.
> + */
> +void inet_def_readable(struct sock *sk, int len)
> +{
> +	if (running_from_softirq()) {
> +		if (softirq_delay_queue(&sk->sk_delay))
> +			/*
> +			 * If we queued this socket, take a reference on it
> +			 * Caller owns socket lock, so write to sk_delay.next
> +			 * will be committed before unlock.
> +			 */
> +			sock_hold(sk);
> +	} else
> +		sock_def_readable(sk, len);
> +}
> +
>  static void sock_def_write_space(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> @@ -1768,6 +1808,7 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
>  		sk->sk_sleep	=3D	NULL;
> =20
>  	rwlock_init(&sk->sk_dst_lock);
> +	softirq_delay_init(&sk->sk_delay, sock_readable_defer);
>  	rwlock_init(&sk->sk_callback_lock);
>  	lockdep_set_class_and_name(&sk->sk_callback_lock,
>  			af_callback_keys + sk->sk_family,
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 05b7abb..1cc0907 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1342,6 +1342,12 @@ void udp_destroy_sock(struct sock *sk)
>  	release_sock(sk);
>  }
> =20
> +static int udp_init_sock(struct sock *sk)
> +{
> +	sk->sk_data_ready =3D inet_def_readable;
> +	return 0;
> +}
> +
>  /*
>   *	Socket option code for UDP
>   */
> @@ -1559,6 +1565,7 @@ struct proto udp_prot =3D {
>  	.connect	   =3D ip4_datagram_connect,
>  	.disconnect	   =3D udp_disconnect,
>  	.ioctl		   =3D udp_ioctl,
> +	.init		   =3D udp_init_sock,
>  	.destroy	   =3D udp_destroy_sock,
>  	.setsockopt	   =3D udp_setsockopt,
>  	.getsockopt	   =3D udp_getsockopt,
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 84b1a29..1a9f8d4 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -960,6 +960,12 @@ void udpv6_destroy_sock(struct sock *sk)
>  	inet6_destroy_sock(sk);
>  }
> =20
> +static int udpv6_init_sock(struct sock *sk)
> +{
> +	sk->sk_data_ready =3D inet_def_readable;
> +	return 0;
> +}
> +
>  /*
>   *	Socket option code for UDP
>   */
> @@ -1084,6 +1090,7 @@ struct proto udpv6_prot =3D {
>  	.connect	   =3D ip6_datagram_connect,
>  	.disconnect	   =3D udp_disconnect,
>  	.ioctl		   =3D udp_ioctl,
> +	.init 		   =3D udpv6_init_sock,
>  	.destroy	   =3D udpv6_destroy_sock,
>  	.setsockopt	   =3D udpv6_setsockopt,
>  	.getsockopt	   =3D udpv6_getsockopt,
>=20

