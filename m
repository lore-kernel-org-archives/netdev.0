From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 16:17:01 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809041554050.3117@nehalem.linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au> <20080903214634.ea17ff53.akpm@linux-foundation.org> <alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org> <20080903223318.84b6ce8b.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org> <20080904012544.cabed847.akpm@linux-foundation.org> <alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org> <20080904015701.5959623a.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org> <20080904104554.32ffebea.akpm@linux-foundation.org> <alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org> <20080904113408.d47c65f6.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	john stultz <johnstul@us.ibm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 5 Sep 2008, Thomas Gleixner wrote:
>  
> > BUG: unable to handle kernel NULL pointer dereference at 00000040
> > IP: [<c0126e7f>] get_next_timer_interrupt+0xe9/0x1ab
> 
> Cute, NULL pointer in the timer check code. Can you please addr2line
> the exact code line or upload the vmlinux somewhere ?

Use "scrips/decodecode" (with AFLAGS=--32 since this is x86-32). It shows 
(after some cleanup and editing):

	   3:	89 f1                	mov    %esi,%ecx
	   5:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	   8:	8b 45 d0             	mov    -0x30(%ebp),%eax
	   b:	89 d3                	mov    %edx,%ebx
	   d:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
	  10:	89 45 d8             	mov    %eax,-0x28(%ebp)
	  13:	8b 00                	mov    (%eax),%eax
	  15:	eb 14                	jmp    0x2b   ----------------------+
	  17:	8b 40 08             	mov    0x8(%eax),%eax  <--------+   |
	  1a:	bb 01 00 00 00       	mov    $0x1,%ebx		|   |
	  1f:	3b 45 cc             	cmp    -0x34(%ebp),%eax		|   |
	  22:	0f 49 45 cc          	cmovns -0x34(%ebp),%eax		|   |
	  26:	89 45 cc             	mov    %eax,-0x34(%ebp)		|   |
	  29:	89 d0                	mov    %edx,%eax		|   |
***	  2b:	8b 10                	mov    (%eax),%edx		| <-+
	  2d:	0f 18 02             	prefetchnta (%edx)		| 
	  30:	90                   	nop    				|
	  31:	3b 45 d8             	cmp    -0x28(%ebp),%eax		|
	  34:	75 e1                	jne    17  ---------------------+
	  36:	85 db                	test   %ebx,%ebx
	  38:	89 da                	mov    %ebx,%edx
	  3a:	74 0c                	je     0x48
	  3c:	85 f6                	test   %esi,%esi
	  3e:	74 04                	je     0x44

and that "prefetchnta" is a dead giveaway: it's a "list_for_each_entry()" 
loop. And looking at the registers:

> > Pid: 0, comm: swapper Not tainted (2.6.27-rc5 #18)
> > EIP: 0060:[<c0126e7f>] EFLAGS: 00010013 CPU: 0
> > EIP is at get_next_timer_interrupt+0xe9/0x1ab
> > EAX: 00000040 EBX: 00000001 ECX: 0000001d EDX: 00000040
> > ESI: 0000001d EDI: c05bc700 EBP: c0469f1c ESP: c0469ee4
> >  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> > Process swapper (pid: 0, ti=c0468000 task=c04343c0 task.ti=c0468000)
> > Stack: ffff1cef c013cc1d c05bcf28 00000000 c05bd010 c05bc798 00ffff1d c05bcf28 
> >        c05bd128 c05bd328 c05bd528 00000000 b65eb8b3 0000000f c0469f4c c013816f 
> >        00000000 b65c1f00 0000000f ffff1cef 00000046 00000096 c04b11c0 00000000 
> > Call Trace:
> >  [<c013cc1d>] ? __lock_acquire+0x671/0x6b7
> >  [<c013816f>] ? tick_nohz_stop_sched_tick+0x13f/0x2ba

since %eax == %edx, it's not the first iteration through the loop.

IOW, it's this loop (kernel/timer.c, line 863):

                        list_for_each_entry(nte, varp->vec + slot, entry) {
                                found = 1;
                                if (time_before(nte->expires, expires))
                                        expires = nte->expires;
                        }


as can be seen by looking at the loop body (that "mov $0x1,%ebx" thing
is the "found = 1;" thing.

The next list entry pointer is obviously corrupt: it's 0x00000040, which 
is clearly not a valid pointer. 

Looks like %ecx contains 'slot' (0x1d), but that's the only other piece
of info I can see in the register state.

I do wonder if there isn't some memory corruption going on here. The 
SElinux thing didn't look very sane either (even if it's a SElinux 
permission issue, the inode is corrupt, since the mode is crap).

			Linus
