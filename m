From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 06:18:51 -0800
Message-ID: <1448461131.24696.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <1448418495.22599.320.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448430210.22599.322.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448430210.22599.322.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-24 at 21:43 -0800, Eric Dumazet wrote:
> On Tue, 2015-11-24 at 18:28 -0800, Eric Dumazet wrote:
> > Dmitry, could you test following patch with your setup ?
> > 
> > ( I tried to reproduce the error you reported but could not )
> > 
> > Inode can be freed (without RCU grace period), but not the socket or
> > sk_wq
> > 
> > By using sk_wq in the critical paths, we do not dereference the inode,
> > 
> > 
> 
> I finally was able to reproduce the warning (with more instances running
> in parallel), and apparently this patch solves the problem.

OK I got another one :

This means we also need to move SOCK_ASYNC_WAITDATA and
SOCK_ASYNC_NOSPACE from sock->flags into storage protected by RCU (in
struct socket_wq)

Patch will be much bigger, as we have many 

set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags)
clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
and similar calls.

[ 7040.574519] ==================================================================
[ 7040.581838] AddressSanitizer: heap-use-after-free in sock_wake_async
[ 7040.588229] Read of size 8 by thread T977831:
[ 7040.592647]  [<ffffffff8effddd1>] sock_wake_async+0xd1/0xf0
[ 7040.598264]  [<ffffffff8f006084>] sock_def_readable+0xa4/0xb0
[ 7040.604071]  [<ffffffff8f13fec6>] unix_stream_sendmsg+0x326/0x730
[ 7040.611561]  [<ffffffff8effee33>] sock_aio_write+0x253/0x280
[ 7040.617412]  [<ffffffff8eb09493>] do_sync_write+0xe3/0x130
[ 7040.622945]  [<ffffffff8eb09ded>] vfs_write+0x2dd/0x300
[ 7040.628267]  [<ffffffff8eb0ad92>] SyS_write+0x72/0xd0
[ 7040.633380]  [<ffffffff8f1db322>] system_call_fastpath+0x16/0x1b
[ 7040.639442] 
[ 7040.640969] Freed by thread T977830:
[ 7040.644587]  [<ffffffff8effe22a>] sock_destroy_inode+0x4a/0x50
[ 7040.650472]  [<ffffffff8eb34584>] destroy_inode+0x64/0xa0
[ 7040.655921]  [<ffffffff8eb3478d>] evict+0x1cd/0x2a0
[ 7040.660850]  [<ffffffff8eb3549e>] iput+0x2ae/0x340
[ 7040.665689]  [<ffffffff8eb2f7c0>] dput.part.20+0x3f0/0x660
[ 7040.671235]  [<ffffffff8eb2fa49>] dput+0x19/0x20
[ 7040.675915]  [<ffffffff8eb0c419>] __fput+0x219/0x350
[ 7040.680940]  [<ffffffff8eb0c59e>] ____fput+0xe/0x10
[ 7040.685881]  [<ffffffff8e92c10e>] task_work_run+0xee/0x100
[ 7040.691424]  [<ffffffff8e8790bd>] do_notify_resume+0x12d/0x140
[ 7040.697314]  [<ffffffff8f1db5bf>] int_signal+0x12/0x17
[ 7040.702507] 
[ 7040.704039] Allocated by thread T977733:
[ 7040.708008]  [<ffffffff8effe25b>] sock_alloc_inode+0x2b/0x140
[ 7040.713796]  [<ffffffff8eb33392>] alloc_inode+0x32/0xf0
[ 7040.719080]  [<ffffffff8eb36431>] new_inode_pseudo+0x11/0x80
[ 7040.724803]  [<ffffffff8effdae7>] sock_alloc+0x37/0x110
[ 7040.730102]  [<ffffffff8efff365>] __sock_create+0x95/0x340
[ 7040.735652]  [<ffffffff8efff6c8>] sock_create+0x88/0xc0
[ 7040.740935]  [<ffffffff8f001701>] SyS_socketpair+0x51/0x2c0
[ 7040.746574]  [<ffffffff8f1db322>] system_call_fastpath+0x16/0x1b
[ 7040.752626] 
[ 7040.754156] The buggy address ffff880987ed2c08 is located 8 bytes inside
[ 7040.754156]  of 624-byte region [ffff880987ed2c00, ffff880987ed2e70)
[ 7040.767219] 
[ 7040.768771] Memory state around the buggy address:
[ 7040.773640]  ffff880987ed2700: ffffffff ffffffff ffffffff ffffffrr
[ 7040.779867]  ffff880987ed2800: rrrrrrrr rrrrrrrr rrrrrrrr ffffffff
[ 7040.786127]  ffff880987ed2900: ffffffff ffffffff ffffffff ffffffff
[ 7040.792380]  ffff880987ed2a00: ffffffff ffffffff ffffffff ffffffff
[ 7040.798631]  ffff880987ed2b00: ffffffrr rrrrrrrr rrrrrrrr rrrrrrrr
[ 7040.804890] >ffff880987ed2c00: ffffffff ffffffff ffffffff ffffffff
[ 7040.811114]                     ^
[ 7040.814519]  ffff880987ed2d00: ffffffff ffffffff ffffffff ffffffff
[ 7040.820786]  ffff880987ed2e00: ffffffff ffffffrr rrrrrrrr rrrrrrrr
[ 7040.827053]  ffff880987ed2f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
[ 7040.833315]  ffff880987ed3000: rrrrrrrr ffffffff ffffffff ffffffff
[ 7040.839579]  ffff880987ed3100: ffffffff ffffffff ffffffff ffffffff
[ 7040.845803] Legend:
[ 7040.847937]  f - 8 freed bytes
[ 7040.851026]  r - 8 redzone bytes
[ 7040.854298]  . - 8 allocated bytes
[ 7040.857752]  x=1..7 - x allocated bytes + (8-x) redzone bytes
[ 7040.863537] ==================================================================
