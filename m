From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 3/4] ipv4: drop unneeded and misleading RCU lock in ip_route_input_noref()
Date: Fri,  6 Oct 2017 14:57:48 +0200
Message-ID: <f08aa1512ea415221e94bf53f5a5182468f090ae.1507294365.git.pabeni@redhat.com>
References: <cover.1507294365.git.pabeni@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507294365.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling CONFIG_RCU_NOREF_DEBUG gives the following splat on the
first ingress IPv4 packet:

       1 noref entities escaped an RCU section, nesting 259, leaked noref list  ffff8edcefb1dc00
       ------------[ cut here ]------------
       WARNING: CPU: 0 PID: 0 at kernel/rcu/noref_debug.c:87 __rcu_check_noref+0xf8/0x100
       Modules linked in: intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel crypto_simd glue_helper cryptd mei_me ipmi_ssif sg mei mxm_wmi iTCO_wdt iTCO_vendor_support dcdbas lpc_ich ipmi_si pcspkr ipmi_devintf ipmi_msghandler shpchp wmi acpi_power_meter nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod mgag200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm igb drm ixgbe mdio ahci ptp crc32c_intel i2c_algo_bit libahci pps_core i2c_core libata dca dm_mirror dm_region_hash dm_log dm_mod
       CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc1.noref_3+ #1609
       Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.4.3 01/17/2017
       task: ffffffffae019500 task.stack: ffffffffae000000
       RIP: 0010:__rcu_check_noref+0x7b/0xd0
       RSP: 0018:ffff900afbe03b30 EFLAGS: 00010246
       RAX: 0000000000000034 RBX: ffff900afbfd2500 RCX: 0000000000000000
       RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000202
       RBP: ffff900afbe03b48 R08: 0000000000000000 R09: 0000000000000000
       R10: 0000000000000001 R11: 00000000c388883e R12: 0000000000000103
       R13: 000000001d24100a R14: ffff900af13e0000 R15: 0000000000000000
       FS:  0000000000000000(0000) GS:ffff900afbe00000(0000) knlGS:0000000000000000
       CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
       CR2: 00005589ce876398 CR3: 0000001ff52f9005 CR4: 00000000003606f0
       DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
       DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
       Call Trace:
        <IRQ>
        ip_route_input_noref+0xa6/0x150
        ? ip_route_input_noref+0x5/0x150
        ip_rcv_finish+0x78/0x5e0
        ip_rcv+0x2a7/0x540
        ? packet_rcv+0x52/0x450
        __netif_receive_skb_core+0x3b9/0xe10
        ? netif_receive_skb_internal+0x40/0x390
        __netif_receive_skb+0x18/0x60
        netif_receive_skb_internal+0x8d/0x390
        ? netif_receive_skb_internal+0x40/0x390
        napi_gro_receive+0x15c/0x1f0
        igb_clean_rx_irq+0x36d/0x7f0 [igb]
        igb_poll+0x303/0x780 [igb]
        ? save_stack_trace+0x1b/0x20
        ? __lock_acquire+0xcf2/0x11c0
        ? net_rx_action+0xb4/0x520
        net_rx_action+0x27d/0x520
        __do_softirq+0xd1/0x4f5
        irq_exit+0xfb/0x110
        do_IRQ+0x67/0x120
        common_interrupt+0xa7/0xa7
        </IRQ>
       RIP: 0010:cpuidle_enter_state+0xd0/0x360
       RSP: 0018:ffffffffae003df8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff79
       RAX: ffffffffae019500 RBX: ffffd7d67c604400 RCX: 0000000000000000
       RDX: ffffffffae019500 RSI: 0000000000000001 RDI: ffffffffae019500
       RBP: ffffffffae003e30 R08: 0000000000000000 R09: 0000000000000000
       R10: 0000000000000001 R11: 0000000000000018 R12: 0000000000000004
       R13: 0000000000000000 R14: ffffd7d67c604400 R15: 00000009c8eafd50
        ? cpuidle_enter_state+0xc9/0x360
        cpuidle_enter+0x17/0x20
        call_cpuidle+0x23/0x40
        do_idle+0x183/0x200
        cpu_startup_entry+0x73/0x80
        rest_init+0xc3/0xd0
        start_kernel+0x4f7/0x518
        ? set_init_arg+0x5a/0x5a
        x86_64_start_reservations+0x24/0x26
        x86_64_start_kernel+0x6f/0x72
        secondary_startup_64+0xa5/0xa5
       Code: f6 75 07 5b 41 5c 41 5d 5d c3 80 3d eb e4 ff 00 00 75 1a 44 89 e2 48 c7 c7 88 54 e7 ad 31 c0 c6 05 d6 e4 ff 00 01 e8 28 af fe ff <0f> ff 41 bd 07 00 00 00 48 8b 33 48 85 f6 74 06 44 39 63 10 74

The rcu protection in ip_route_input_noref() is unneeded and
misleading: the caller still needs to acquire and retain the rcu
lock until the skb - carrying a noref dst on successful return -
is either dropped or the relevant dst is forced to a ref-counted
version.

This change just drops the unneeded lock.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/route.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..5a6ca1f16d3f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2069,14 +2069,9 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			 u8 tos, struct net_device *dev)
 {
 	struct fib_result res;
-	int err;
 
 	tos &= IPTOS_RT_MASK;
-	rcu_read_lock();
-	err = ip_route_input_rcu(skb, daddr, saddr, tos, dev, &res);
-	rcu_read_unlock();
-
-	return err;
+	return ip_route_input_rcu(skb, daddr, saddr, tos, dev, &res);
 }
 EXPORT_SYMBOL(ip_route_input_noref);
 
-- 
2.13.6
