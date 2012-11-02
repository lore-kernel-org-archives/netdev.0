From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Fri, 2 Nov 2012 11:54:24 +0100
Message-ID: <20121102105424.GA19410@shrek.podlesie.net>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
 <20121030182001.GA30373@shrek.podlesie.net>
 <20121031094147.GA1004@shrek.podlesie.net>
 <20121031160352.68353ecc@thirdoffive.cmf.nrl.navy.mil>
 <20121031220435.GA25157@shrek.podlesie.net>
 <20121101102628.6e3d3cae@thirdoffive.cmf.nrl.navy.mil>
 <20121102094018.GA14960@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-modem2.podlesie.net ([83.13.132.46]:60981 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762490Ab2KBKy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 06:54:26 -0400
Content-Disposition: inline
In-Reply-To: <20121102094018.GA14960@shrek.podlesie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 02, 2012 at 10:40:18AM +0100, Krzysztof Mazur wrote:
> On Thu, Nov 01, 2012 at 10:26:28AM -0400, chas williams - CONTRACTOR wrote:
> > On Wed, 31 Oct 2012 23:04:35 +0100
> > Krzysztof Mazur <krzysiek@podlesie.net> wrote:
> > > 	- missing check for SS_CONNECTED in pppoatm_ioctl,
> > 
> > in practice you will never run into this because a pvc is immediately
> > put into SS_CONNECTED mode (right before the userspace open()
> > returns).  however, should it check?  yes.  i dont see anything
> > preventing you from running ppp on svc's.
> 
> I can confirm that the problem really exists, without connect() in pppoatm
> plugin in pppd, I have seen an Oops and panic. I will send appropriate
> patch.

I'm sending the patch that fixes this issue. Works correctly with original
pppd, and does not crash with pppd without connect() - the pppd just
logs:

pppd[3460]: ioctl(ATM_SETBACKEND): Invalid argument

and exits.

Krzysiek

-- >8 --
Subject: [PATCH] pppoatm: allow assign only on a connected socket

The pppoatm does not check if the used vcc is in connected state,
causing an Oops in pppoatm_send() when vcc->send() is called
on not fully connected socket.

Now pppoatm can be assigned only on connected sockets; otherwise
-EINVAL error is returned.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
BUG: unable to handle kernel NULL pointer dereference at   (null)
IP: [<  (null)>]   (null)
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
Pid: 4154, comm: pppd Not tainted 3.6.0-krzysiek-00002-g3ff1093 #95    /AK32 
EIP: 0060:[<00000000>] EFLAGS: 00010202 CPU: 0
EIP is at 0x0
EAX: d95f7800 EBX: d9d4ba80 ECX: d95f7800 EDX: d9d4ba80
ESI: ffffffff EDI: 00000001 EBP: 000001c0 ESP: d9823f34
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
CR0: 8005003b CR2: 00000000 CR3: 1e7b6000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process pppd (pid: 4154, ti=d9822000 task=d99918a0 task.ti=d9822000)
Stack:
 c060cd9b c043a2ca d99ed860 d99ed864 d9d4ba80 08094f22 c043a228 d9d4ba80
 d99ed860 0000000c c043a347 ffffffff 0000000c d94311a0 08094f22 c043a290
 c019f72e d9823f9c 00000003 09df1090 d94311a0 08094f22 00000008 d9822000
Call Trace:
 [<c060cd9b>] ? pppoatm_send+0x6b/0x300
 [<c043a2ca>] ? ppp_write+0x3a/0xe0
 [<c043a228>] ? ppp_channel_push+0x38/0xa0
 [<c043a347>] ? ppp_write+0xb7/0xe0
 [<c043a290>] ? ppp_channel_push+0xa0/0xa0
 [<c019f72e>] ? vfs_write+0x8e/0x140
 [<c019f88c>] ? sys_write+0x3c/0x70
 [<c062ab50>] ? sysenter_do_call+0x12/0x26
Code:  Bad EIP value.
EIP: [<00000000>] 0x0 SS:ESP 0068:d9823f34
CR2: 0000000000000000
---[ end trace e29cf1805f576278 ]---
Kernel panic - not syncing: Fatal exception in interrupt

 net/atm/pppoatm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 226dca9..f27a07a 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -406,6 +406,8 @@ static int pppoatm_ioctl(struct socket *sock, unsigned int cmd,
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
+		if (sock->state != SS_CONNECTED)
+			return -EINVAL;
 		return pppoatm_assign_vcc(atmvcc, argp);
 		}
 	case PPPIOCGCHAN:
-- 
1.8.0.172.g62af90c
