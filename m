From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Thu, 24 Jul 2014 12:05:31 -0400
Message-ID: <53D12ECB.2040600@oracle.com>
References: <53C2FF3D.4030201@oracle.com> <20140714.150847.1399242734159771901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, a.ryabinin@samsung.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140714.150847.1399242734159771901.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2014 06:08 PM, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Sun, 13 Jul 2014 17:50:53 -0400
> 
>> While fuzzing with trinity inside a KVM tools guest running the latest -next
>> kernel with the KASAN patchset, I've stumbled on the following spew:
>  ...
>> It's similar to another variation:
>  ...
>> I've tried debugging it, but I don't see a code path that could lead to that.
> 
> Both of these cases involve working with pointers declared with
> DECLARE_SOCKADDR, maybe that somehow confuses ASAN code generation?
> 

Hey David,

Sorry for the delay.

I've confirmed that it's not ASAN's fault by adding:

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1b38f7f..81d86b9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2331,7 +2331,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *so
        err = scm_send(sock, msg, siocb->scm, true);
        if (err < 0)
                return err;
-
+       BUG_ON(msg->msg_namelen && !msg->msg_name);
        if (msg->msg_namelen) {
                err = -EINVAL;
                if (addr->nl_family != AF_NETLINK)

And got:

[ 1322.890135] kernel BUG at net/netlink/af_netlink.c:2334!
[ 1322.890135] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1322.890135] Dumping ftrace buffer:
[ 1322.890135]    (ftrace buffer empty)
[ 1322.890135] Modules linked in:
[ 1322.890135] CPU: 8 PID: 31343 Comm: trinity-c259 Not tainted 3.16.0-rc6-next-20140724-sasha-00046-g7324c87-dirty #931
[ 1322.890135] task: ffff880311268000 ti: ffff88031bf5c000 task.ti: ffff88031bf5c000
[ 1322.890135] RIP: 0010:[<ffffffffb567e01b>]  [<ffffffffb567e01b>] netlink_sendmsg+0xc6b/0xce0
[ 1322.902991] RSP: 0018:ffff88031bf5faa0  EFLAGS: 00010246
[ 1322.902991] RAX: 0000000000000000 RBX: ffff88031bf5fb38 RCX: dfff97060a600000
[ 1322.902991] RDX: ffff88031bf5fe80 RSI: 0000000000000000 RDI: ffff88031bf5fe80
[ 1322.902991] RBP: ffff88031bf5fb80 R08: dfff97060a600000 R09: 0000000000000000
[ 1322.902991] R10: 0000000000000080 R11: 0000000000000001 R12: ffff88031bf5fe78
[ 1322.902991] R13: ffff8801d18fd388 R14: 0000000000000000 R15: 0000000000feff98
[ 1322.902991] FS:  00007f67138b8700(0000) GS:ffff8801de000000(0000) knlGS:0000000000000000
[ 1322.902991] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1322.902991] CR2: 00007f6708260088 CR3: 000000036ad59000 CR4: 00000000000006a0
[ 1322.902991] Stack:
[ 1322.902991]  ffff8801de1e2dc0 ffff88025efbb118 ffffffffb9b9ae30 000000000000092d
[ 1322.902991]  ffff880311268d00 ffff88031bf5fae0 ffffffffb121185d 0000000000000001
[ 1322.902991]  ffff88031bf5faf8 ffff88031bf5fea8 ffff8801d7d9c220 0000000000000000
[ 1322.902991] Call Trace:
[ 1322.902991]  [<ffffffffb121185d>] ? get_parent_ip+0xd/0x50
[ 1322.902991]  [<ffffffffb559bc3a>] sock_sendmsg+0xca/0x100
[ 1322.902991]  [<ffffffffb13b32ed>] ? might_fault+0xed/0x100
[ 1322.902991]  [<ffffffffb13b327a>] ? might_fault+0x7a/0x100
[ 1322.902991]  [<ffffffffb55b3ced>] ? verify_iovec+0xcd/0x180
[ 1322.902991]  [<ffffffffb559cb52>] ___sys_sendmsg+0x312/0x530
[ 1322.902991]  [<ffffffffb124f42e>] ? put_lock_stats.isra.13+0xe/0x30
[ 1322.902991]  [<ffffffffb124fad1>] ? lock_release_holdtime+0x121/0x260
[ 1322.902991]  [<ffffffffb125b2bb>] ? lock_release_non_nested+0x42b/0x4f0
[ 1322.902991]  [<ffffffffb124f004>] ? check_chain_key+0x1f4/0x2e0
[ 1322.902991]  [<ffffffffb559daeb>] __sys_sendmmsg+0x9b/0x1c0
[ 1322.902991]  [<ffffffffb125496d>] ? trace_hardirqs_on_caller+0x1ad/0x380
[ 1322.902991]  [<ffffffffb1254b4d>] ? trace_hardirqs_on+0xd/0x10
[ 1322.902991]  [<ffffffffb10b9222>] ? syscall_trace_enter+0x1e2/0x540
[ 1322.902991]  [<ffffffffb125496d>] ? trace_hardirqs_on_caller+0x1ad/0x380
[ 1322.902991]  [<ffffffffb559dc22>] SyS_sendmmsg+0x12/0x30
[ 1322.902991]  [<ffffffffb5e43a13>] tracesys+0xe1/0xe6
[ 1322.902991] Code: e4 00 00 00 8b 4d 98 45 31 c9 41 b8 d0 00 00 00 48 89 de 8b 55 90 48 c7 04 24 00 00 00 00 4c 89 ef e8 da cb ff ff e9 8d f8 ff ff <0f> 0b e8 5e 3f b9 fb 48 8b bd 68 ff ff ff e8 c2 be da fb 48 8b
[ 1322.902991] RIP  [<ffffffffb567e01b>] netlink_sendmsg+0xc6b/0xce0
[ 1322.902991]  RSP <ffff88031bf5faa0>


Thanks,
Sasha
