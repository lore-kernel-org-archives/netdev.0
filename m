From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 01:52:54 +0200
Message-ID: <20080717235254.GA6833@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40296 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932186AbYGQXxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 19:53:18 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> > A regression to v2.6.26:
> >
> > I started getting this skb-head corruption message today, on a T60
> > laptop with e1000:
> >
> > PM: Removing info for No Bus:vcs11
> > device: 'vcs11': device_create_release
> > =============================================================================
> > BUG skbuff_head_cache: Poison overwritten
> > -----------------------------------------------------------------------------
> >
> > INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
> 
> 1. Notice the range. It's just a single byte.
> 2. Notice the value. It's just a ++.
> 
> Probably a stray increment of a uint8_t somewhere on a freed object?
> 
> The offset from the beginning of the object is 0xf658ae9c - 0xf658ae00 
> = 0x9c.
> 
> How big is a struct sk_buff? Hm.. it is in fact quite big. Now what 
> member has offset 0x9c? Seems to depend on your config. Is there any 
> way you can figure it out, Ingo? I'll try it with your config too.

hmm ... your analysis gave me a wonderful albeit admittedly remote idea:

 If only we had some kernel technology that could track and validate 
 memory accesses, and point out the cases where we access uninitialized 
 memory, just like Valgrind?

... something like kmemcheck? ;-)

So i booted that box with tip/master and kmemcheck enabled. (plus a few 
fixlets to make networking allocations be properly tracked by 
kmemcheck.)

It was a slow bootup and long wait, but it gave a few hits here:

kmemcheck: Caught 8-bit read from uninitialized memory (f653ad24)
iiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuiuuuuuuuuuuuuuuuuuuuuuuuuuu
                                    ^

Pid: 2484, comm: arping Not tainted (2.6.26-tip #20187)
EIP: 0060:[<c05e973c>] EFLAGS: 00010282 CPU: 0
EIP is at __copy_skb_header+0x7c/0x100
EAX: 00000000 EBX: f653acc0 ECX: f653ac00 EDX: f653ac00
ESI: f653ac50 EDI: f653ad10 EBP: c09b9e84 ESP: c09ddaa8
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: f71c2700 CR3: 36513000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff4ff0 DR7: 00000400
 [<c05e97e7>] __skb_clone+0x27/0xe0
 [<c05eb101>] skb_clone+0x41/0x60
 [<c065cbf1>] packet_rcv+0xc1/0x290
 [<c05f07ad>] netif_receive_skb+0x20d/0x400
 [<c03b2aa7>] e1000_receive_skb+0x47/0x180
 [<c03b3983>] e1000_clean_rx_irq+0x223/0x2e0
 [<c03b225b>] e1000_clean+0x5b/0x200
 [<c05f29db>] net_rx_action+0xfb/0x160
 [<c0129092>] __do_softirq+0x82/0xf0
 [<c0105b8a>] call_on_stack+0x1a/0x30

false positive? Find below the quick hacks i did to pre-initialize skb 
allocations that have RX DMA into them.

another one is:

kmemcheck: Caught 8-bit read from uninitialized memory (f653a902)
iiuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu
  ^

Pid: 2575, comm: hcid Not tainted (2.6.26-tip #20187)
EIP: 0060:[<c02b9926>] EFLAGS: 00010293 CPU: 0
EIP is at __copy_to_user_ll+0x46/0x70
EAX: 00000004 EBX: b7f3c478 ECX: 00000002 EDX: f653a900
ESI: f653a902 EDI: b7f3c47a EBP: f668ceec ESP: c09ddbc8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: f71c2700 CR3: 3668d000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff4ff0 DR7: 00000400
 [<c02b9e4a>] copy_to_user+0x3a/0x50
 [<c068b1b0>] hci_get_dev_list+0x100/0x120
 [<c068fe53>] hci_sock_ioctl+0x143/0x2c0
 [<c05e6a41>] sock_ioctl+0xc1/0x1d0
 [<c0187aad>] vfs_ioctl+0x2d/0x90
 [<c0187d7b>] do_vfs_ioctl+0x26b/0x2d0
 [<c0187e37>] sys_ioctl+0x57/0x70
 [<c0103c01>] sysenter_past_esp+0x6a/0x91
 [<ffffffff>] 0xffffffff

this might actually be genuine use of uninitialized memory, hm? Or 
perhaps gcc optimizing out bitmasks and kmemcheck not coping with it?

a third type was this:

kmemcheck: Caught 8-bit read from uninitialized memory (f653a2a4)
iiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuiuuuuuuuuuuuuuuuuuuuuuuuuuu
                                    ^

Pid: 2771, comm: ssh Not tainted (2.6.26-tip #20187)
EIP: 0060:[<c05e973c>] EFLAGS: 00010282 CPU: 0
EIP is at __copy_skb_header+0x7c/0x100
EAX: 00000000 EBX: f653a240 ECX: f6762000 EDX: f6762000
ESI: f6762050 EDI: f653a290 EBP: f675cd28 ESP: c09ddce8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: f71c2700 CR3: 367e3000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff4ff0 DR7: 00000400
 [<c05e97e7>] __skb_clone+0x27/0xe0
 [<c05eb101>] skb_clone+0x41/0x60
 [<c062fbd1>] tcp_transmit_skb+0x41/0x800
 [<c06328c3>] tcp_connect+0x293/0x330
 [<c0636676>] tcp_v4_connect+0x3d6/0x550
 [<c0642359>] inet_stream_connect+0x1b9/0x240
 [<c05e4e66>] sys_connect+0x86/0xa0
 [<c05e66d0>] sys_socketcall+0x220/0x260
 [<c0103c01>] sysenter_past_esp+0x6a/0x91
 [<ffffffff>] 0xffffffff

this too is likely a false positive related to RX packets?

none of this looks netconsole related.

I'll keep the box running under kmemcheck - maybe something pops up.

	Ingo

------------------->
Subject: kmemcheck/net hacks
From: Ingo Molnar <mingo@elte.hu>

---
 include/asm-generic/siginfo.h |    8 ++++++++
 include/linux/fs.h            |    4 ++--
 include/linux/netdevice.h     |    4 ++--
 include/linux/skbuff.h        |    6 +++++-
 include/net/inet_sock.h       |    3 ++-
 include/net/tcp.h             |   11 +++++++++++
 kernel/signal.c               |   12 ++++++++++++
 net/core/skbuff.c             |    6 ++++++
 net/ipv4/tcp_output.c         |    4 ++++
 9 files changed, 52 insertions(+), 6 deletions(-)

Index: linux/include/asm-generic/siginfo.h
===================================================================
--- linux.orig/include/asm-generic/siginfo.h
+++ linux/include/asm-generic/siginfo.h
@@ -278,11 +278,19 @@ void do_schedule_next_timer(struct sigin
 
 static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
 {
+#ifdef CONFIG_KMEMCHECK
+	memcpy(to, from, sizeof(*to));
+#else
+	/*
+	 * Optimization, only copy up to the size of the largest known
+	 * union member:
+	 */
 	if (from->si_code < 0)
 		memcpy(to, from, sizeof(*to));
 	else
 		/* _sigchld is currently the largest know union member */
 		memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
+#endif
 }
 
 #endif
Index: linux/include/linux/fs.h
===================================================================
--- linux.orig/include/linux/fs.h
+++ linux/include/linux/fs.h
@@ -922,8 +922,8 @@ struct file_lock {
 	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
 	struct file *fl_file;
-	unsigned char fl_flags;
-	unsigned char fl_type;
+	unsigned int fl_flags;
+	unsigned int fl_type;
 	loff_t fl_start;
 	loff_t fl_end;
 
Index: linux/include/linux/netdevice.h
===================================================================
--- linux.orig/include/linux/netdevice.h
+++ linux/include/linux/netdevice.h
@@ -199,8 +199,8 @@ struct dev_addr_list
 {
 	struct dev_addr_list	*next;
 	u8			da_addr[MAX_ADDR_LEN];
-	u8			da_addrlen;
-	u8			da_synced;
+	unsigned int		da_addrlen;
+	unsigned int		da_synced;
 	int			da_users;
 	int			da_gusers;
 };
Index: linux/include/linux/skbuff.h
===================================================================
--- linux.orig/include/linux/skbuff.h
+++ linux/include/linux/skbuff.h
@@ -1208,7 +1208,11 @@ static inline void __skb_queue_purge(str
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb;
+#ifdef CONFIG_KMEMCHECK
+	gfp_mask |= __GFP_ZERO;
+#endif
+	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
Index: linux/include/net/inet_sock.h
===================================================================
--- linux.orig/include/net/inet_sock.h
+++ linux/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				__filler   : 3;
 	struct ip_options	*opt;
 };
 
Index: linux/include/net/tcp.h
===================================================================
--- linux.orig/include/net/tcp.h
+++ linux/include/net/tcp.h
@@ -966,6 +966,17 @@ static inline void tcp_openreq_init(stru
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	req->mss = rx_opt->mss_clamp;
 	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
+#ifdef CONFIG_KMEMCHECK
+	/* bitfield init */
+	ireq->snd_wscale =
+	ireq->rcv_wscale =
+	ireq->tstamp_ok =
+	ireq->sack_ok =
+	ireq->wscale_ok =
+	ireq->ecn_ok =
+	ireq->acked =
+	ireq->__filler = 0;
+#endif
 	ireq->tstamp_ok = rx_opt->tstamp_ok;
 	ireq->sack_ok = rx_opt->sack_ok;
 	ireq->snd_wscale = rx_opt->snd_wscale;
Index: linux/kernel/signal.c
===================================================================
--- linux.orig/kernel/signal.c
+++ linux/kernel/signal.c
@@ -841,6 +841,12 @@ static int send_signal(int sig, struct s
 		list_add_tail(&q->list, &pending->list);
 		switch ((unsigned long) info) {
 		case (unsigned long) SEND_SIG_NOINFO:
+			/*
+			 * Make sure we always have a fully initialized
+			 * siginfo struct:
+			 */
+			memset(&q->info, 0, sizeof(q->info));
+
 			q->info.si_signo = sig;
 			q->info.si_errno = 0;
 			q->info.si_code = SI_USER;
@@ -848,6 +854,12 @@ static int send_signal(int sig, struct s
 			q->info.si_uid = current->uid;
 			break;
 		case (unsigned long) SEND_SIG_PRIV:
+			/*
+			 * Make sure we always have a fully initialized
+			 * siginfo struct:
+			 */
+			memset(&q->info, 0, sizeof(q->info));
+
 			q->info.si_signo = sig;
 			q->info.si_errno = 0;
 			q->info.si_code = SI_KERNEL;
Index: linux/net/core/skbuff.c
===================================================================
--- linux.orig/net/core/skbuff.c
+++ linux/net/core/skbuff.c
@@ -225,6 +225,9 @@ struct sk_buff *__alloc_skb(unsigned int
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
+#ifdef CONFIG_KMEMCHECK
+		memset(child, 0, offsetof(struct sk_buff, tail));
+#endif
 		skb->fclone = SKB_FCLONE_ORIG;
 		atomic_set(fclone_ref, 1);
 
@@ -257,6 +260,9 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev_to_node(&dev->dev);
 	struct sk_buff *skb;
 
+#ifdef CONFIG_KMEMCHECK
+	gfp_mask |= __GFP_ZERO;
+#endif
 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
Index: linux/net/ipv4/tcp_output.c
===================================================================
--- linux.orig/net/ipv4/tcp_output.c
+++ linux/net/ipv4/tcp_output.c
@@ -333,6 +333,10 @@ static inline void TCP_ECN_send(struct s
 static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 {
 	skb->csum = 0;
+	skb->local_df = skb->cloned = skb->ip_summed = skb->nohdr =
+		skb->nfctinfo = 0;
+	skb->pkt_type = skb->fclone = skb->ipvs_property = skb->peeked =
+		skb->nf_trace = 0;
 
 	TCP_SKB_CB(skb)->flags = flags;
 	TCP_SKB_CB(skb)->sacked = 0;
