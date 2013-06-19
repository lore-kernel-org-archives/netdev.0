From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 0/1] net: lls select poll
	support
Date: Wed, 19 Jun 2013 05:13:36 -0700
Message-ID: <1371644016.3252.302.camel@edumazet-glaptop>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 13:04 +0300, Eliezer Tamir wrote:

> One question: do we need in sock_poll() to test that sock->sk is not null?
> (Thanks to Willem de Bruijn for pointing this out.) 

Why sock->sk could be NULL in sock_poll() ?

This is the thing I am not sure [1]

Normally, sock_poll() should be called only if the current thread owns a
reference on the file. And we should not dismantle sock->sk while a
reference is owned.

Apparently, epoll() might break this assumption, but I was unable to
track it yet. epoll() doesn't hold file refcount, because it relies on
eventpoll_release_file() being called from __fput()


[1] We do have some crashes occurrences here on some Google machines
(Google-Bug-id: 8940884) , because tcp_poll() hits a NULL sock->sk

<4>[206994.855824] RIP: 0010:[<ffffffff8026e2e8>]  [<ffffffff8026e2e8>] tcp_poll+0x18/0x1b0
<4>[206994.863652] RSP: 0018:ffff8806c7921e48  EFLAGS: 00010246
<4>[206994.869038] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff8806c7921f10
<4>[206994.876241] RDX: 0000000000000000 RSI: ffff880292d52300 RDI: ffff88034a8837c0
<4>[206994.883443] RBP: ffff8806c7921e58 R08: 00007f7cadc3c000 R09: ffff88034a8837c0
<4>[206994.890648] R10: 00000000fffffff2 R11: ffffffff8088ffc0 R12: ffff880699960d98
<4>[206994.897850] R13: 0000000000000000 R14: ffff8804924dab58 R15: 0000000000002000
<4>[206994.905055] FS:  00007f7c98726700(0000) GS:ffff88027fc80000(0000) knlGS:00000000f4cf8b40
<4>[206994.913210] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[206994.919028] CR2: 00000000000000c0 CR3: 0000000494ab2000 CR4: 00000000000006e0
<4>[206994.926233] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[206994.933437] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[206994.940640] Process java (pid: 8736, threadinfo ffff8806c7920000, task ffff8806990d0400)
<4>[206994.948795] Stack:
<4>[206994.950890]  0000000000000000 ffff880699960d40 ffff8806c7921e68 ffffffff802604da
<4>[206994.958422]  ffff8806c7921f78 ffffffff8024f528 ffff88069b6e4a80 00007f7cadc3c000
<4>[206994.965956]  ffff8806fffffff2 ffff8806c7921f10 ffffffff80aaa6f0 ffffffff80aaa6f0
<4>[206994.973488] Call Trace:
<4>[206994.976023]  [<ffffffff802604da>] sock_poll+0x1a/0x20
<4>[206994.981148]  [<ffffffff8024f528>] sys_epoll_wait+0x788/0x940
<4>[206994.986881]  [<ffffffff802d81b0>] ? ep_send_events_proc+0x120/0x120
<4>[206994.993226]  [<ffffffff8072e032>] system_call_fastpath+0x16/0x1b



------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
