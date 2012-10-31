From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Wed, 31 Oct 2012 23:04:35 +0100
Message-ID: <20121031220435.GA25157@shrek.podlesie.net>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
 <20121030182001.GA30373@shrek.podlesie.net>
 <20121031094147.GA1004@shrek.podlesie.net>
 <20121031160352.68353ecc@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121031160352.68353ecc@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 04:03:52PM -0400, chas williams - CONTRACTOR wrote:
> 
> reversing the order of the push and close certainly seems like the right
> thing to do. i would like to see if it would fix your problem.  making
> the minimal change to get something working would be preferred before
> adding additional complexity.  i am just surprised we havent seen this
> bug before.

Yes, it fixes the problem and it's probably the best fix for original
issue.

There are also some minor potential issues in pppoatm driver:

	- locking issues, but now only between pppoatm_send() and
	  vcc_sendmsg() and maybe some other functions,

	- missing check for SS_CONNECTED in pppoatm_ioctl,

	- problem described in comment in pppoatm_may_send() when
	  sk->sk_sndbuf < MTU, sk_wmem_alloc_get() should be added
	  there

but I think that for now the patch that changes the order of push
and close is sufficient.

I probably saw that bug a log time ago (around 2.6.30), but it was
too rare to see what caused panic, but after 
9d02daf754238adac48fa075ee79e7edd3d79ed3 (pppoatm: Fix excessive queue bloat)
this bug occurs much more frequently.

Thanks.

Krzysiek

-- >8 --
Subject: [PATCH] atm: detach protocol before closing vcc

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
1.8.0.172.g62af90c
