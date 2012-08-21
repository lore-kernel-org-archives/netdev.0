From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: [PATCH 1/1] ipv4: ipmr_expire_timer causes crash when removing net namespace
Date: Mon, 20 Aug 2012 17:15:35 -0700
Message-ID: <CA+HUmGgAx-APi4DRr=M2nUMfiO8yjcxovvqkTuX7=ZpUDbo5Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41594 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428Ab2HUAPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 20:15:36 -0400
Received: by obbuo13 with SMTP id uo13so10331882obb.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 17:15:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv4 mr_table's are freed without checking if their
ipmr_expire_timer is active.
This patch applies to ipv4 the same logic as in ipv6 and deletes the
timer and performs other cleanups before the structure is freed.

We have seen mr_table's being freed with their ipmr_expire_timer
active when removing net namespaces, as in the following backtrace:

[<ffffffff813e1f7b>] ipmr_rules_exit+0x9d/0xd9
[<ffffffff8137e435>] ? net_drop_ns+0x39/0x39
[<ffffffff8137e435>] ? net_drop_ns+0x39/0x39
[<ffffffff813e1fe6>] ipmr_net_exit+0x2f/0x34
[<ffffffff8137dd2e>] ops_exit_list+0x25/0x4e
[<ffffffff8137e523>] cleanup_net+0xee/0x180
[<ffffffff81045f16>] process_one_work+0x17e/0x29a
[<ffffffff81046b18>] worker_thread+0xfe/0x182
[<ffffffff81046a1a>] ? manage_workers.clone.19+0x16d/0x16d
[<ffffffff8104a235>] kthread+0x84/0x8c
[<ffffffff81450ce4>] kernel_thread_helper+0x4/0x10
[<ffffffff8104a1b1>] ? kthread_freezable_should_stop+0x41/0x41
[<ffffffff81450ce0>] ? gs_change+0x13/0x13

When this happens unpredictable crashes such as the following one have
occured in run_timer_softirq:

<4>------------[ cut here ]------------
<2>kernel BUG at kernel/timer.c:1085!
<4>invalid opcode: 0000 [#1] SMP
<4>CPU 0
<4>Modules linked in: xt_mark xt_comment macvtap iptable_mangle xt_hl xt_state
xt_limit ipt_REJECT vfat fat loop dummy tulip xt_tcpudp iptable_filter veth
nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc macvlan dm_mirror dm_region_hash
dm_log uinput bonding kvm_intel kvm fuse xt_multiport iptable_nat ip_tables
nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q ioatdma
i5k_amb dca sg iTCO_wdt iTCO_vendor_support coretemp shpchp i2c_i801 i5400_edac
edac_core pcspkr serio_raw microcode sr_mod cdrom ehci_hcd uhci_hcd igb
netxen_nic radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core dm_mod
[last unloaded: mperf]
<4>
<4>Pid: 15426, comm: cc1 Not tainted
3.4.8-827282.2012fruggeriArora34.fc14.x86_64 #1 Supermicro X7DWU/X7DWU
<4>RIP: 0010:[<ffffffff8103bffb>]  [<ffffffff8103bffb>] cascade+0x56/0x7a
<4>RSP: 0000:ffff8802afc03e10  EFLAGS: 00010082
<4>RAX: 3031003336333530 RBX: ffffffff81d88740 RCX: 00000001015b8d00
<4>RDX: ffff8800b3209028 RSI: ffff8800a9c19028 RDI: ffffffff81d88740
<4>RBP: ffff8802afc03e40 R08: ffff8802afc0d640 R09: ffff8802afc03e38
<4>R10: 0000000000000158 R11: ffffffff81605b25 R12: ffff8802afc03e10
<4>R13: 000000000000000d R14: ffff8802afc03e10 R15: ffff880254f93fd8
<4>FS:  00007f9b63c98720(0000) GS:ffff8802afc00000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>CR2: 00007f9b6188f000 CR3: 00000002a10c6000 CR4: 00000000000007e0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process cc1 (pid: 15426, threadinfo ffff880254f92000, task ffff8800b90ad7c0)
<4>Stack:
<4> ffff8800a7336028 ffff8800a9c19028 ffffffff81d88740 0000000000000000
<4> ffff8802afc03ea0 ffff880254f93fd8 ffff8802afc03ee0 ffffffff8103c0bb
<4> ffff8802afc0d650 ffff8802afc03e68 ffff880254f93fd8 ffffffff81d8a360
<4>Call Trace:
<4> <IRQ>
<4> [<ffffffff8103c0bb>] run_timer_softirq+0x9c/0x288
<4> [<ffffffff81060cf3>] ? ktime_get+0x59/0x95
<4> [<ffffffff8101b81e>] ? apic_write+0x11/0x13
<4> [<ffffffff81036060>] __do_softirq+0xb6/0x195
<4> [<ffffffff810668a8>] ? tick_program_event+0x1f/0x21
<4> [<ffffffff81450d5c>] call_softirq+0x1c/0x30
<4> [<ffffffff81003d6f>] do_softirq+0x41/0x7e
<4> [<ffffffff810362fd>] irq_exit+0x3f/0x9a
<4> [<ffffffff8101bdc7>] smp_apic_timer_interrupt+0x77/0x85
<4> [<ffffffff8145040a>] apic_timer_interrupt+0x6a/0x70
<4> <EOI>
<4>Code: 89 45 d0 48 8b 46 08 48 89 45 d8 4c 89 30 48 89 36 48 89 76 08 48 8b
75 d0 4c 8b 26 eb 1e 48 8b 46 18 48 83 e0 fe 48 39 c3 74 02 <0f> 0b 48 89 df e8
c8 e4 ff ff 4c 89 e6 4d 8b 24 24 4c 39 f6 75
<1>RIP  [<ffffffff8103bffb>] cascade+0x56/0x7a
<4> RSP <ffff8802afc03e10>



Tested in Linux 3.4.8.

Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>

Index: linux-3.4.x86_64/net/ipv4/ipmr.c
===================================================================
--- linux-3.4.x86_64.orig/net/ipv4/ipmr.c
+++ linux-3.4.x86_64/net/ipv4/ipmr.c
@@ -124,6 +124,8 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 static struct kmem_cache *mrt_cachep __read_mostly;

 static struct mr_table *ipmr_new_table(struct net *net, u32 id);
+static void ipmr_free_table(struct mr_table *mrt);
+
 static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 			 struct sk_buff *skb, struct mfc_cache *cache,
 			 int local);
@@ -131,6 +133,7 @@ static int ipmr_cache_report(struct mr_t
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm);
+static void mroute_clean_tables(struct mr_table *mrt);
 static void ipmr_expire_process(unsigned long arg);

 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
@@ -271,7 +274,7 @@ static void __net_exit ipmr_rules_exit(s

 	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
 		list_del(&mrt->list);
-		kfree(mrt);
+		ipmr_free_table(mrt);
 	}
 	fib_rules_unregister(net->ipv4.mr_rules_ops);
 }
@@ -299,7 +302,7 @@ static int __net_init ipmr_rules_init(st

 static void __net_exit ipmr_rules_exit(struct net *net)
 {
-	kfree(net->ipv4.mrt);
+	ipmr_free_table(net->ipv4.mrt);
 }
 #endif

@@ -336,6 +339,13 @@ static struct mr_table *ipmr_new_table(s
 	return mrt;
 }

+static void ipmr_free_table(struct mr_table *mrt)
+{
+	del_timer(&mrt->ipmr_expire_timer);
+	mroute_clean_tables(mrt);
+	kfree(mrt);
+}
+
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */

 static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
