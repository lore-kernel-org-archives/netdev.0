From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v2 1/3] pppoatm: don't send frames to destroyed vcc
Date: Mon, 22 Oct 2012 19:14:49 +0200
Message-ID: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Krzysztof Mazur <krzysiek@podlesie.net>
To: davem@davemloft.net
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
Cc: David Woodhouse <dwmw2@infradead.org>
---
Previously sent with more details as:
http://marc.info/?l=linux-kernel&m=134952646810580&w=2

This patch extends race window between pppoatm_send() and vcc_destroy_socket().
This race exists also without this patch and it's fixed in patch 2.

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
1.8.0.2.g35080e9
