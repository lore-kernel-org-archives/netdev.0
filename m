From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH] pppoatm: don't send frames to destroyed vcc
Date: Sat,  6 Oct 2012 14:19:51 +0200
Message-ID: <1349525991-21462-1-git-send-email-krzysiek@podlesie.net>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org, Krzysztof Mazur <krzysiek@podlesie.net>
To: mitch@sfgoth.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pppoatm_send() uses vcc->send() directly and does not check if vcc
is ready for send(). This causes Oops when send() is used after
vcc_destroy_socket() at least with usbatm driver:

Oops: 0000 [#1] PREEMPT
Pid: 0, comm: swapper Not tainted 3.6.0-krzysiek-00001-gb7cd93b-dirty #60    /AK32
EIP: 0060:[<c01413c6>] EFLAGS: 00010082 CPU: 0
EIP is at __wake_up_common+0x16/0x70
EAX: 30707070 EBX: 00000292 ECX: 00000001 EDX: dca75fc0
ESI: 00000000 EDI: de7f500f EBP: df409f24 ESP: df409f08
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
CR0: 8005003b CR2: 30707070 CR3: 1c920000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process swapper (pid: 0, ti=df408000 task=c07bd4e0 task.ti=c07b0000)
Stack:
 00000000 00000001 00000001 dca75fc0 00000292 00000000 de7f500f df409f3c
 c0143299 00000000 00000000 dc84f000 dc84f000 df409f4c c0602bf0 00000000
 dc84f000 df409f58 c0604301 dc840cc0 df409fb4 c04672e5 c076a240 00000000
Call Trace:
 [<c0143299>] __wake_up+0x29/0x50
 [<c0602bf0>] vcc_write_space+0x40/0x80
 [<c0604301>] atm_pop_raw+0x21/0x30
 [<c04672e5>] usbatm_tx_process+0x2a5/0x380
 [<c0126cf9>] tasklet_action+0x39/0x70
 [<c0126f1f>] __do_softirq+0x7f/0x120
 [<c0126ea0>] ? local_bh_enable_ip+0xa0/0xa0
 <IRQ>

Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
indicate that vcc is not ready.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
This bug can be easily triggered with 9d02daf754238adac48fa075ee79e7edd3d79ed3
(pppoatm: Fix excessive queue bloat) present in Linux >= 3.5-rc1.
Steps to reproduce (tested with 9d02daf75 and v3.6):
$ ping -i 0.1 some.host.via.modem &
unplug ADSL line
sleep 3
plug ADSL line
The Oops occurs almost always.

On Linux v3.0.44, v3.4.12 the above steps did not trigger the bug, but
I saw similar Oops also on kernels < 3.5-rc1, but I was never able to
reproduce it or save kernel log.

This bug also exists in some stable kernels.

Maybe it's better to drop frame:
	if (..) {
		kfree_skb(skb);
		return 1;
	}
instead of
	goto nospace;

The full Oops + some logs from Linux 3.6.0 with some minor changes
(copying kernel log to VRAM after crash and enabled usbatm debugging with
some additional debug).

ATM dev 0: usbatm_atm_close entered
ATM dev 0: usbatm_atm_close: deallocating vcc 0xdca75e20 with vpi 0 vci 35
ATM dev 0: usbatm_cancel_send entered
ATM dev 0: usbatm_cancel_send: popping skb 0xdc840840
ATM dev 0: usbatm_cancel_send: popping current skb (0xdcb26740)
ATM dev 0: usbatm_cancel_send done
ATM dev 0: usbatm_atm_close successful
ATM dev 0: usbatm_atm_send entered (skb 0xdc840cc0, len 10) vcc=dc84f000
ATM dev 0: usbatm_atm_send queue skb: dc840cc0 vcc dc84f000
ATM dev 0: usbatm_atm_send entered (skb 0xdc84c920, len 10) vcc=dc84f000
ATM dev 0: usbatm_atm_send queue skb: dc84c920 vcc dc84f000
ATM dev 0: usbatm_tx_process skb dcb26740
  len=86
ATM dev 0: usbatm_tx_process skb dc840cc0
  len=10
usbatm_rx_process: 4991 callbacks suppressed
ATM dev 0: usbatm_rx_process: status 0 in frame 0!
ATM dev 0: usbatm_rx_process: status 0 in frame 1!
ATM dev 0: usbatm_rx_process: status 0 in frame 2!
ATM dev 0: usbatm_rx_process: status 0 in frame 0!
ATM dev 0: usbatm_rx_process: status 0 in frame 1!
ATM dev 0: usbatm_rx_process: status 0 in frame 2!
ATM dev 0: usbatm_rx_process: status 0 in frame 0!
ATM dev 0: usbatm_rx_process: status 0 in frame 1!
ATM dev 0: usbatm_rx_process: status 0 in frame 2!
ATM dev 0: usbatm_rx_process: status 0 in frame 0!
ATM dev 0: usbatm_atm_open: vpi 0, vci 35
ATM dev 0: usbatm_atm_open: allocated vcc data 0xdca75c20
ATM dev 0: usbatm_atm_send entered (skb 0xdcda8b40, len 12) vcc=d2761c00
ATM dev 0: usbatm_atm_send queue skb: dcda8b40 vcc d2761c00
ATM dev 0: usbatm_tx_process skb dc840cc0
  len=10
ATM dev 0: usbatm_atm_send entered (skb 0xdc8406c0, len 12) vcc=d2761c00
ATM dev 0: usbatm_atm_send queue skb: dc8406c0 vcc d2761c00
ATM dev 0: usbatm_tx_process skb dc840cc0
  len=10
ATM dev 0: usbatm_tx_process skb dc840cc0
  len=10
ATM dev 0: usbatm_tx_process pop skb dc840cc0, vcc dc84f000%
BUG: unable to handle kernel paging request at 30707070
IP: [<c01413c6>] __wake_up_common+0x16/0x70
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
Pid: 0, comm: swapper Not tainted 3.6.0-krzysiek-00001-gb7cd93b-dirty #60    /AK32 
EIP: 0060:[<c01413c6>] EFLAGS: 00010082 CPU: 0
EIP is at __wake_up_common+0x16/0x70
EAX: 30707070 EBX: 00000292 ECX: 00000001 EDX: dca75fc0
ESI: 00000000 EDI: de7f500f EBP: df409f24 ESP: df409f08
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
CR0: 8005003b CR2: 30707070 CR3: 1c920000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process swapper (pid: 0, ti=df408000 task=c07bd4e0 task.ti=c07b0000)
Stack:
 00000000 00000001 00000001 dca75fc0 00000292 00000000 de7f500f df409f3c
 c0143299 00000000 00000000 dc84f000 dc84f000 df409f4c c0602bf0 00000000
 dc84f000 df409f58 c0604301 dc840cc0 df409fb4 c04672e5 c076a240 00000000
Call Trace:
 [<c0143299>] __wake_up+0x29/0x50
 [<c0602bf0>] vcc_write_space+0x40/0x80
 [<c0604301>] atm_pop_raw+0x21/0x30
 [<c04672e5>] usbatm_tx_process+0x2a5/0x380
 [<c0126cf9>] tasklet_action+0x39/0x70
 [<c0126f1f>] __do_softirq+0x7f/0x120
 [<c0126ea0>] ? local_bh_enable_ip+0xa0/0xa0
 <IRQ> 

 [<c01271de>] ? irq_exit+0x6e/0x90
 [<c0103be3>] ? do_IRQ+0x43/0xb0
 [<c0144f9c>] ? sched_clock_local.constprop.1+0x4c/0x1a0
 [<c0626369>] ? common_interrupt+0x29/0x30
 [<c02f458b>] ? acpi_idle_enter_simple+0xf5/0x122
 [<c04bd81e>] ? cpuidle_enter+0x1e/0x30
 [<c04bdb08>] ? cpuidle_idle_call+0x68/0xd0
 [<c0109155>] ? cpu_idle+0x45/0x80
 [<c060b4df>] ? rest_init+0x63/0x74
 [<c07fd851>] ? start_kernel+0x25e/0x264
 [<c07fd42e>] ? repair_env_string+0x51/0x51
 [<c07fd26e>] ? i386_start_kernel+0x44/0x46
Code: c3 8d 74 26 00 31 f6 31 db eb cc 66 90 0f b6 4d e8 d3 eb eb bb 55 89 e5 57 56 53 83 ec 10 89 45 f0 89 55 ec 89 c2 8b 00 89 4d e8 <8b> 18 8d 70 f4 83 eb 0c 39 c2 75 0a eb 37 8d 74 26 00 89 de 89
EIP: [<c01413c6>] __wake_up_common+0x16/0x70 SS:ESP 0068:df409f08
CR2: 0000000030707070
---[ end trace bc86ff846f3d97ec ]---
Kernel panic - not syncing: Fatal exception in interrupt

 net/atm/pppoatm.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 226dca9..0dcb5dc 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -269,6 +269,8 @@ static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
 static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
+	struct atm_vcc *vcc;
+
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
 	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
@@ -301,6 +303,12 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 		return 1;
 	}
 
+	vcc = ATM_SKB(skb)->vcc;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
+			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
+			|| !test_bit(ATM_VF_READY, &vcc->flags))
+		goto nospace;
+
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
-- 
1.7.12.2.2.g1c3c581
