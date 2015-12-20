From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: NULL pointer deref in dccp (inet_csk_listen_start/inet_csk_get_port)
Date: Sun, 20 Dec 2015 17:11:45 +0100
Message-ID: <5676D341.5080407@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Iles <jamie.iles@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I've been running into the following oops:

[ 1128.895622] BUG: unable to handle kernel NULL pointer dereference at 
           (null)
[ 1128.896010] IP: [<          (null)>]           (null)
[ 1128.896010] PGD 179ee067 PUD 189b1067 PMD 0
[ 1128.896010] Oops: 0010 [#1] PREEMPT SMP
[ 1128.896010] CPU: 1 PID: 1023 Comm: a.out Not tainted 4.4.0-rc5+ #64
[ 1128.896010] task: ffff88001a7e72c0 ti: ffff880017534000 task.ti: 
ffff880017534000
[ 1128.896010] RIP: 0010:[<0000000000000000>]  [<          (null)>] 
       (null)
[ 1128.896010] RSP: 0018:ffff880017537e60  EFLAGS: 00010246
[ 1128.896010] RAX: ffffffff820deec0 RBX: ffff880019e12e00 RCX: 
000000000000a90c
[ 1128.896010] RDX: 0000000000000001 RSI: ffff880019e12e00 RDI: 
ffff880018f23f00
[ 1128.896010] RBP: ffff880017537ed0 R08: 00007f0788df40f4 R09: 
00000000fe0ab1db
[ 1128.896010] R10: 0000000000000000 R11: 0000000000000206 R12: 
000000000000a90c
[ 1128.896010] R13: ffffffff828233c0 R14: ffff880018f23f00 R15: 
ffff8800196b1db0
[ 1128.896010] FS:  00007f078872f700(0000) GS:ffff88001a900000(0000) 
knlGS:0000000000000000
[ 1128.896010] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1128.896010] CR2: 0000000000000000 CR3: 0000000018832000 CR4: 
00000000001406a0
[ 1128.896010] Stack:
[ 1128.896010]  ffffffff81ae7190 0000000000000005 ffff880018f23f00 
0000000600000000
[ 1128.896010]  ffffffff810dc981 ffffffff8311b380 0000000000000000 
0000a90cffffffff
[ 1128.896010]  0000400000000001 ffff880018f23f00 000000000000007d 
000000000000007d
[ 1128.896010] Call Trace:
[ 1128.896010]  [<ffffffff81ae7190>] ? inet_csk_get_port+0x4c0/0x820
[ 1128.896010]  [<ffffffff810dc981>] ? 
__raw_callee_save___pv_queued_spin_unlock+0x11/0x20
[ 1128.896010]  [<ffffffff81ae9158>] inet_csk_listen_start+0x78/0xf0
[ 1128.896010]  [<ffffffff81c9d2fe>] inet_dccp_listen+0xbe/0x120
[ 1128.896010]  [<ffffffff81a2459c>] SyS_listen+0xcc/0xe0
[ 1128.896010]  [<ffffffff81e8532e>] entry_SYSCALL_64_fastpath+0x12/0x71
[ 1128.896010] Code:  Bad RIP value.
[ 1128.896010] RIP  [<          (null)>]           (null)
[ 1128.896010]  RSP <ffff880017537e60>
[ 1128.896010] CR2: 0000000000000000
[ 1128.896010] ---[ end trace 583887ed13928755 ]---

It looks like the same thing that Dave Jones ran into a couple of times
before:

https://www.mail-archive.com/netdev@vger.kernel.org/msg73745.html
https://www.mail-archive.com/netdev@vger.kernel.org/msg87675.html

I am able to reproduce this reliably within ~30 seconds or so (as non-root).

Jamie Iles and I been able to narrow it down to a race between connect()
and listen() on AF_INET6/IPPROTO_DCCP sockets:

- Thread A does connect() which calls dccp_v6_connect() which sets
icsk->icsk_af_ops = &dccp_ipv6_mapped. However, dccp_ipv6_mapped has
->bind_conflict == NULL.

- Thread B does listen() which calls into inet_csk_get_port() and tries
to call inet_csk(sk)->icsk_af_ops->bind_conflict.

Using the following patch we can no longer reproduce this specific issue:

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c6d050..0c27e71 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -947,6 +947,7 @@ static const struct inet_connection_sock_af_ops 
dccp_ipv6_mapped = {
         .getsockopt        = ipv6_getsockopt,
         .addr2sockaddr     = inet6_csk_addr2sockaddr,
         .sockaddr_len      = sizeof(struct sockaddr_in6),
+       .bind_conflict     = inet6_csk_bind_conflict,
  #ifdef CONFIG_COMPAT
         .compat_setsockopt = compat_ipv6_setsockopt,
         .compat_getsockopt = compat_ipv6_getsockopt,

If you think this is the right fix, we can submit a proper patch.

Thanks,


Vegard
