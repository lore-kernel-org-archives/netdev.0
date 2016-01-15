From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Fri, 15 Jan 2016 17:01:06 -0200
Message-ID: <20160115190106.GG6074@mrl.redhat.com>
References: <CACT4Y+YjpSKvD5t8e6wKzE8+j3rFzf_Ep+23WjW1Mg3ws6cOCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+YjpSKvD5t8e6wKzE8+j3rFzf_Ep+23WjW1Mg3ws6cOCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 10:52:31AM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program causes use-after-free in __sctp_connect:
> 
...
> INFO: Freed in sctp_association_put+0x150/0x250 age=0 cpu=3 pid=15267
> [<      none      >] __slab_free+0x1fc/0x320 mm/slub.c:2678
> [<     inline     >] slab_free mm/slub.c:2833
> [<      none      >] kfree+0x2a8/0x2d0 mm/slub.c:3662
> [<     inline     >] sctp_association_destroy net/sctp/associola.c:424
> [<      none      >] sctp_association_put+0x150/0x250 net/sctp/associola.c:860
> [<      none      >] sctp_wait_for_connect+0x37c/0x4f0 net/sctp/socket.c:7067
                         ^^^^^^^^^^^^^^
> [<      none      >] __sctp_connect+0x905/0xb90 net/sctp/socket.c:1215
> [<      none      >] __sctp_setsockopt_connectx+0x198/0x1d0
> net/sctp/socket.c:1328
> [<     inline     >] sctp_setsockopt_connectx net/sctp/socket.c:1360
> [<      none      >] sctp_setsockopt+0x226/0x3630 net/sctp/socket.c:3728
> [<      none      >] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2642
> [<     inline     >] SYSC_setsockopt net/socket.c:1752
> [<      none      >] SyS_setsockopt+0x158/0x240 net/socket.c:1731
> [<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185

This one may sher some light on that other socket leak one, because the
association shouldn't have been freed at that point.
Now, how it managed to unbalance that refcnt, hmm...
