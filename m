From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] tcp: attach SYNACK messages to request sockets instead
 of listener
Date: Thu, 29 Oct 2015 15:58:41 -0700
Message-ID: <1446159521.6254.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36398 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820AbbJ2W6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 18:58:43 -0400
Received: by pacik9 with SMTP id ik9so5815714pac.3
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 15:58:42 -0700 (PDT)
In-Reply-To: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 21:49 +0000, Haiyang Zhang wrote:
> Hi Eric,
> 
> I saw a panic in __dev_kfree_skb_any() when I ssh into some 
> Ubuntu VM with latest Linux-next tree on Hyper-V host.
> With git bisecting, I found the patch below is the first commit
> with this issue. I also included the stack trace here.
> Do you have any idea about what the problem might be?
> 
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=ca6fb06518836ef9b65dc0aac02ff97704d52a05
> author  Eric Dumazet <edumazet@google.com> 2015-10-02 18:43:35 (GMT) 
> commit ca6fb06518836ef9b65dc0aac02ff97704d52a05 (patch) 
> tcp: attach SYNACK messages to request sockets instead of listener
> 
> Stack trace:
> [   96.235084] general protection fault: 0000 [#1] SMP
> [   96.235084] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ebtabl
> e_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip
> 6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_
> nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter ip_tables hyperv_keyboard pcspkr
> hv_utils serio_raw i2c_piix4 hyperv_fb i2c_core acpi_cpufreq uinput xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_
> acpi hid_hyperv hv_netvsc hv_storvsc ata_piix libata hv_vmbus floppy dm_mirror dm_region_hash dm_log dm_mod
> [   96.235084] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.3.0-rc6-next-20151021+ #1
> [   96.235084] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
> [   96.235084] task: ffff880101bf0000 ti: ffff880101bf8000 task.ti: ffff880101bf8000
> [   96.235084] RIP: 0010:[<ffffffff8158b17c>]  [<ffffffff8158b17c>] sock_wfree+0x4c/0x60
> [   96.235084] RSP: 0018:ffff880102643da8  EFLAGS: 00010292
> [   96.235084] RAX: 00000000000004ff RBX: ffff8800f2d50000 RCX: 0000000000000000
> [   96.235084] RDX: ffff8800f1af0000 RSI: 0000000000000001 RDI: ffff8800f2d50000
> [   96.235084] RBP: ffff880102643db8 R08: ffff8800f2086000 R09: 000000000007efc8
> [   96.235084] R10: ffff880036800000 R11: 0000000000000000 R12: ffff8800f2d50124
> [   96.235084] R13: ffff880036800000 R14: ffff880035d80000 R15: ffff8800f39b7c00
> [   96.770086] FS:  0000000000000000(0000) GS:ffff880102640000(0000) knlGS:0000000000000000
> [   96.770086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   96.770086] CR2: 00007efefe680514 CR3: 0000000036bee000 CR4: 00000000000006e0
> [   96.770086] Stack:
> [   96.770086]  ffff8800f2e93800 ffff8800f2e93800 ffff880102643dd0 ffffffff8158c42f
> [   96.770086]  ffff8800f2e93800 ffff880102643de8 ffffffff8158dac2 ffff8800f2087000
> [   96.770086]  ffff880102643e08 ffffffff8158e06c ffff8800f2087000 0000000000001000
> [   96.770086] Call Trace:
> [   96.770086]  <IRQ>
> [   96.770086]  [<ffffffff8158c42f>] skb_release_head_state+0x4f/0xb0
> [   96.770086]  [<ffffffff8158dac2>] skb_release_all+0x12/0x30
> [   96.770086]  [<ffffffff8158e06c>] consume_skb+0x2c/0x70
> [   96.770086]  [<ffffffff8159f885>] __dev_kfree_skb_any+0x35/0x40
> [   96.770086]  [<ffffffffa00ef0fc>] netvsc_xmit_completion+0x1c/0x20 [hv_netvsc]
> [   96.770086]  [<ffffffffa00f12c7>] netvsc_channel_cb+0x217/0x3f0 [hv_netvsc]
> [   96.770086]  [<ffffffffa0059584>] vmbus_on_event+0x154/0x190 [hv_vmbus]
> [   96.770086]  [<ffffffff81083495>] tasklet_action+0xe5/0xf0
> [   96.770086]  [<ffffffff810836f7>] __do_softirq+0xd7/0x2a0
> [   96.770086]  [<ffffffff81083b65>] irq_exit+0xf5/0x100
> [   96.770086]  [<ffffffff8104da4e>] hyperv_vector_handler+0x3e/0x50
> [   96.770086]  [<ffffffff816ae717>] hyperv_callback_vector+0x87/0x90
> [   96.770086]  <EOI>
> [   96.770086]  [<ffffffff810635a6>] ? native_safe_halt+0x6/0x10
> [   96.770086]  [<ffffffff81021aee>] default_idle+0x1e/0xa0
> [   96.770086]  [<ffffffff8102227f>] arch_cpu_idle+0xf/0x20
> [   96.770086]  [<ffffffff810c1492>] default_idle_call+0x32/0x40
> [   96.770086]  [<ffffffff810c17be>] cpu_startup_entry+0x2be/0x330
> [   96.770086]  [<ffffffff810503a0>] start_secondary+0x190/0x1d0
> [   96.770086] Code: 80 e6 02 74 19 f0 41 29 04 24 74 05 5b 41 5c 5d c3 48 89 df e8 b6 f8 ff ff 5b 41 5c 5d c3 83 e8 01
> f0 29 83 24 01 00 00 48 89 df <ff> 93 a0 02 00 00 b8 01 00 00 00 eb cd 0f 1f 80 00 00 00 00 66
> [   96.770086] RIP  [<ffffffff8158b17c>] sock_wfree+0x4c/0x60
> [   96.770086]  RSP <ffff880102643da8>
> [   97.572206] ---[ end trace 0d1199c7e6a1aaa4 ]---
> [   97.573146] Kernel panic - not syncing: Fatal exception in interrupt
> [   97.573146] Kernel Offset: disabled
> [   97.573146] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
> 
> Thanks,
> - Haiyang
> 

Thanks for this report.

Somehow I knew such bugs would surface ;)

Please try following debugging patch ?

We need to identify which part of the kernel is messed up.

diff --git a/include/net/sock.h b/include/net/sock.h
index aeed5c95f3ca..a643499d37e2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1951,6 +1951,14 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 	}
 }
 
+/* This helper checks if a socket is a full socket,
+ * ie _not_ a timewait or request socket.
+ */
+static inline bool sk_fullsock(const struct sock *sk)
+{
+	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
+}
+
 /*
  *	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
@@ -1962,6 +1970,10 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
+	if (!sk_fullsock(sk)) {
+		WARN_ON_ONCE(1);
+		return;
+	}
 	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
@@ -2223,14 +2235,6 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 	return NULL;
 }
 
-/* This helper checks if a socket is a full socket,
- * ie _not_ a timewait or request socket.
- */
-static inline bool sk_fullsock(const struct sock *sk)
-{
-	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
-}
-
 /* This helper checks if a socket is a LISTEN or NEW_SYN_RECV
  * SYNACK messages can be attached to either ones (depending on SYNCOOKIE)
  */
