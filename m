From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: WARNING in strp_data_ready
Date: Mon, 30 Oct 2017 14:44:06 -0700
Message-ID: <de320d00-dced-fd39-056b-6c67290254e0@gmail.com>
References: <001a11421c7436e541055c4c7cf0@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: syzbot
        <bot+c91c53af67f9ebe599a337d2e70950366153b295@syzkaller.appspotmail.com>,
        davem@davemloft.net, ebiggers@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        syzkaller-bugs@googlegroups.com, tom@quantonium.net,
        xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a11421c7436e541055c4c7cf0@google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/2017 08:20 AM, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on 73d3393ada4f70fa3df5639c8d438f2f034c0ecb
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> WARNING: CPU: 0 PID: 2996 at ./include/net/sock.h:1505 sock_owned_by_me include/net/sock.h:1505 [inline]
> WARNING: CPU: 0 PID: 2996 at ./include/net/sock.h:1505 sock_owned_by_user include/net/sock.h:1511 [inline]
> WARNING: CPU: 0 PID: 2996 at ./include/net/sock.h:1505 strp_data_ready+0x2b7/0x390 net/strparser/strparser.c:404
> Kernel panic - not syncing: panic_on_warn set ...
> 
> CPU: 0 PID: 2996 Comm: syzkaller142210 Not tainted 4.14.0-rc5+ #138
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  panic+0x1e4/0x417 kernel/panic.c:181
>  __warn+0x1c4/0x1d9 kernel/panic.c:542
>  report_bug+0x211/0x2d0 lib/bug.c:183
>  fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:178
>  do_trap_no_signal arch/x86/kernel/traps.c:212 [inline]
>  do_trap+0x260/0x390 arch/x86/kernel/traps.c:261
>  do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:298
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:311
>  invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
> RIP: 0010:sock_owned_by_me include/net/sock.h:1505 [inline]
> RIP: 0010:sock_owned_by_user include/net/sock.h:1511 [inline]
> RIP: 0010:strp_data_ready+0x2b7/0x390 net/strparser/strparser.c:404
> RSP: 0018:ffff8801db206b18 EFLAGS: 00010206
> RAX: ffff8801d1e02080 RBX: ffff8801dad74c48 RCX: 0000000000000000
> RDX: 0000000000000100 RSI: ffff8801d29fa0a0 RDI: ffffffff85cbede0
> RBP: ffff8801db206b38 R08: 0000000000000005 R09: 1ffffffff0ce0bcd
> R10: ffff8801db206a00 R11: dffffc0000000000 R12: ffff8801d29fa000
> R13: ffff8801dad74c50 R14: ffff8801d4350a92 R15: 0000000000000001
>  psock_data_ready+0x56/0x70 net/kcm/kcmsock.c:353

Looks like KCM is calling sk_data_ready() without first taking the
sock lock.

/* Called with lower sock held */
static void kcm_rcv_strparser(struct strparser *strp, struct sk_buff *skb)
{
 [...]
	if (kcm_queue_rcv_skb(&kcm->sk, skb)) {

In this case kcm->sk is not the same lock the comment is referring to.
And kcm_queue_rcv_skb() will eventually call sk_data_ready().

@Tom, how about wrapping the sk_data_ready call in {lock|release}_sock?
I don't have anything better in mind immediately.

Thanks,
John
