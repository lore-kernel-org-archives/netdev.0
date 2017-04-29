From: Scott Wood <swood@redhat.com>
Subject: [PATCH net] bnx2x: Align RX buffers
Date: Fri, 28 Apr 2017 19:17:41 -0500
Message-ID: <20170429001741.14563-1-swood@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Michal Schmidt <mschmidt@redhat.com>,
        linuxppc-dev@lists.ozlabs.org, Scott Wood <swood@redhat.com>
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163675AbdD2ARo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 20:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x driver is not providing proper alignment on the receive buffers it
passes to build_skb(), causing skb_shared_info to be misaligned.
skb_shared_info contains an atomic, and while PPC normally supports
unaligned accesses, it does not support unaligned atomics.

Aligning the size of rx buffers will ensure that page_frag_alloc() returns
aligned addresses.

This can be reproduced on PPC by setting the network MTU to 1450 (or other
non-multiple-of-4) and then generating sufficient inbound network traffic
(one or two large "wget"s usually does it), producing the following oops:

Unable to handle kernel paging request for unaligned access at address 0xc00000ffc43af656
Faulting instruction address: 0xc00000000080ef8c
Oops: Kernel access of bad area, sig: 7 [#1]
SMP NR_CPUS=2048
NUMA
PowerNV
Modules linked in: vmx_crypto powernv_rng rng_core powernv_op_panel leds_powernv led_class nfsd ip_tables x_tables autofs4 xfs lpfc bnx2x mdio libcrc32c crc_t10dif crct10dif_generic crct10dif_common
CPU: 104 PID: 0 Comm: swapper/104 Not tainted 4.11.0-rc8-00088-g4c761da #2
task: c00000ffd4892400 task.stack: c00000ffd4920000
NIP: c00000000080ef8c LR: c00000000080eee8 CTR: c0000000001f8320
REGS: c00000ffffc33710 TRAP: 0600   Not tainted  (4.11.0-rc8-00088-g4c761da)
MSR: 9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>
  CR: 24082042  XER: 00000000
CFAR: c00000000080eea0 DAR: c00000ffc43af656 DSISR: 00000000 SOFTE: 1
GPR00: c000000000907f64 c00000ffffc33990 c000000000dd3b00 c00000ffcaf22100
GPR04: c00000ffcaf22e00 0000000000000000 0000000000000000 0000000000000000
GPR08: 0000000000b80008 c00000ffc43af636 c00000ffc43af656 0000000000000000
GPR12: c0000000001f6f00 c00000000fe1a000 000000000000049f 000000000000c51f
GPR16: 00000000ffffef33 0000000000000000 0000000000008a43 0000000000000001
GPR20: c00000ffc58a90c0 0000000000000000 000000000000dd86 0000000000000000
GPR24: c000007fd0ed10c0 00000000ffffffff 0000000000000158 000000000000014a
GPR28: c00000ffc43af010 c00000ffc9144000 c00000ffcaf22e00 c00000ffcaf22100
NIP [c00000000080ef8c] __skb_clone+0xdc/0x140
LR [c00000000080eee8] __skb_clone+0x38/0x140
Call Trace:
[c00000ffffc33990] [c00000000080fb74] skb_clone+0x74/0x110 (unreliable)
[c00000ffffc339c0] [c000000000907f64] packet_rcv+0x144/0x510
[c00000ffffc33a40] [c000000000827b64] __netif_receive_skb_core+0x5b4/0xd80
[c00000ffffc33b00] [c00000000082b2bc] netif_receive_skb_internal+0x2c/0xc0
[c00000ffffc33b40] [c00000000082c49c] napi_gro_receive+0x11c/0x260
[c00000ffffc33b80] [d000000066483d68] bnx2x_poll+0xcf8/0x17b0 [bnx2x]
[c00000ffffc33d00] [c00000000082babc] net_rx_action+0x31c/0x480
[c00000ffffc33e10] [c0000000000d5a44] __do_softirq+0x164/0x3d0
[c00000ffffc33f00] [c0000000000d60a8] irq_exit+0x108/0x120
[c00000ffffc33f20] [c000000000015b98] __do_irq+0x98/0x200
[c00000ffffc33f90] [c000000000027f14] call_do_irq+0x14/0x24
[c00000ffd4923a90] [c000000000015d94] do_IRQ+0x94/0x110
[c00000ffd4923ae0] [c000000000008d90] hardware_interrupt_common+0x150/0x160
--- interrupt: 501 at arch_local_irq_restore+0x5c/0x90
    LR = arch_local_irq_restore+0x40/0x90
[c00000ffd4923dd0] [c000000000172e90] tick_broadcast_oneshot_control+0x40/0x60 (unreliable)
[c00000ffd4923df0] [c0000000007ccb68] cpuidle_enter_state+0x108/0x3b0
[c00000ffd4923e50] [c000000000129284] call_cpuidle+0x44/0x80
[c00000ffd4923e70] [c000000000129660] do_idle+0x2a0/0x310
[c00000ffd4923ef0] [c000000000129910] cpu_startup_entry+0x30/0x40
[c00000ffd4923f20] [c00000000003eb24] start_secondary+0x304/0x360
[c00000ffd4923f90] [c00000000000b06c] start_secondary_prolog+0x10/0x14
Instruction dump:
7d295378 993f0086 e93e00d0 f93f00d0 813e00d8 913f00d8 39200001 913f00dc
813e00c0 e95e00c8 7d2a4a14 39490020 <7d005028> 31080001 7d00512d 40c2fff4
---[ end trace b40fe13265ac423d ]---

Fixes: d46d132cc021 ("bnx2x: use netdev_alloc_frag()")
Signed-off-by: Scott Wood <swood@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9e8c06130c09..8471664169fd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2021,6 +2021,7 @@ static void bnx2x_set_rx_buf_size(struct bnx2x *bp)
 				  ETH_OVERHEAD +
 				  mtu +
 				  BNX2X_FW_RX_ALIGN_END;
+		fp->rx_buf_size = SKB_DATA_ALIGN(fp->rx_buf_size);
 		/* Note : rx_buf_size doesn't take into account NET_SKB_PAD */
 		if (fp->rx_buf_size + NET_SKB_PAD <= PAGE_SIZE)
 			fp->rx_frag_size = fp->rx_buf_size + NET_SKB_PAD;
-- 
1.8.3.1
