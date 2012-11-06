From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 1/7] atm: detach protocol before closing vcc
Date: Tue,  6 Nov 2012 23:16:56 +0100
Message-ID: <1352240222-363-2-git-send-email-krzysiek@podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Cc: linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net, Krzysztof Mazur <krzysiek@podlesie.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vcc_destroy_socket() closes vcc before the protocol is detached
from vcc by calling vcc->push() with NULL skb. This leaves some time
window, where the protocol may call vcc->send() on closed vcc.

It happens at least with pppoatm protocol and usbatm driver, and causes
an Oops:

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

Now the protocol is detached before vcc is closed.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Suggested-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 net/atm/common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 0c0ad93..a0e4411 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -171,10 +171,10 @@ static void vcc_destroy_socket(struct sock *sk)
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 	if (vcc->dev) {
-		if (vcc->dev->ops->close)
-			vcc->dev->ops->close(vcc);
 		if (vcc->push)
 			vcc->push(vcc, NULL); /* atmarpd has no push */
+		if (vcc->dev->ops->close)
+			vcc->dev->ops->close(vcc);
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 			atm_return(vcc, skb->truesize);
-- 
1.8.0.233.g54991f2
