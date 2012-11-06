From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 3/7] pppoatm: allow assign only on a connected socket
Date: Tue,  6 Nov 2012 23:16:58 +0100
Message-ID: <1352240222-363-4-git-send-email-krzysiek@podlesie.net>
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

The pppoatm does not check if used vcc is in connected state,
causing an Oops in pppoatm_send() when vcc->send() is called
on not fully connected socket.

Now pppoatm can be assigned only on connected sockets; otherwise
-EINVAL error is returned.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
Oops triggered by pppd with pppoatm plugin with removed connect():

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
1.8.0.233.g54991f2
