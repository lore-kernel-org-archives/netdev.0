From: Dave Jones <davej@redhat.com>
Subject: Re: recvmsg sleeping from invalid context
Date: Sat, 14 Jan 2012 16:43:34 -0500
Message-ID: <20120114214334.GA28423@redhat.com>
References: <20120113182401.GA25885@redhat.com>
 <20120113.102712.600185688659703015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	glommer@parallels.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120113.102712.600185688659703015.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 10:27:12AM -0800, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Fri, 13 Jan 2012 13:24:01 -0500
 > 
 > > getting a ton of these on the latest head (099469502f62fbe0d7e4f0b83a2f22538367f734)
 > > 
 > > BUG: sleeping function called from invalid context at mm/memory.c:3905
 > > in_atomic(): 0, irqs_disabled(): 0, pid: 1067, name: NetworkManager
 > > INFO: lockdep is turned off.
 > > Pid: 1067, comm: NetworkManager Not tainted 3.2.0+ #22
 > > Call Trace:
 > >  [<ffffffff81099415>] __might_sleep+0x145/0x200
 > >  [<ffffffff811752a4>] might_fault+0x34/0xb0
 > >  [<ffffffff81551555>] ? sock_def_readable+0x25/0x1a0
 > >  [<ffffffff8155c387>] put_cmsg+0x77/0x120
 > >  [<ffffffff8159379c>] netlink_recvmsg+0x35c/0x480
 > >  [<ffffffff8155201a>] ? sock_update_classid+0x9a/0x260
 > >  [<ffffffff81552052>] ? sock_update_classid+0xd2/0x260
 > >  [<ffffffff81549fbd>] sock_recvmsg+0x11d/0x140
 > >  [<ffffffff811752c3>] ? might_fault+0x53/0xb0
 > >  [<ffffffff8117530c>] ? might_fault+0x9c/0xb0
 > >  [<ffffffff811752c3>] ? might_fault+0x53/0xb0
 > >  [<ffffffff8154b1b3>] __sys_recvmsg+0x153/0x2d0
 > >  [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
 > >  [<ffffffff8109fd11>] ? get_parent_ip+0x11/0x50
 > >  [<ffffffff816ac23d>] ? sub_preempt_count+0x9d/0xd0
 > >  [<ffffffff811bc43b>] ? fget_light+0xfb/0x470
 > >  [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
 > >  [<ffffffff8154e2e9>] sys_recvmsg+0x49/0x90
 > >  [<ffffffff816b00e9>] system_call_fastpath+0x16/0x1b
 > 
 > Sigh, I suspect the new socket memcg code, which I didn't want to
 > even apply in the first place. :-/
 > 
 > Glauber, please fix this.

How new is 'new' ?

interestingly, I now started getting these in 3.1.9 where I never noticed them before.


BUG: sleeping function called from invalid context at mm/memory.c:3905
in_atomic(): 1, irqs_disabled(): 0, pid: 962, name: NetworkManager
1 lock held by NetworkManager/962:
 #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff815f610d>] inet6_dump_fib+0x3d/0x3d0
Pid: 962, comm: NetworkManager Not tainted 3.1.9-1.fc16.x86_64.debug #1
Call Trace:
 [<ffffffff8105fbd0>] __might_sleep+0xf0/0x120
 [<ffffffff81160f68>] might_fault+0x38/0xb0
 [<ffffffff81519070>] ? sock_def_error_report+0x120/0x120
 [<ffffffff81523877>] put_cmsg+0x77/0x120
 [<ffffffff815587ec>] netlink_recvmsg+0x35c/0x480
 [<ffffffff81518d2e>] ? sock_update_classid+0x8e/0x190
 [<ffffffff81518d68>] ? sock_update_classid+0xc8/0x190
 [<ffffffff815122ad>] sock_recvmsg+0x11d/0x140
 [<ffffffff81160f8c>] ? might_fault+0x5c/0xb0
 [<ffffffff81160fd5>] ? might_fault+0xa5/0xb0
 [<ffffffff81160f8c>] ? might_fault+0x5c/0xb0
 [<ffffffff81513373>] __sys_recvmsg+0x153/0x2d0
 [<ffffffff810a8f28>] ? sched_clock_cpu+0xa8/0x110
 [<ffffffff810b6bfd>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff810a8fff>] ? local_clock+0x6f/0x80
 [<ffffffff810b74a5>] ? lock_release_holdtime.part.9+0x15/0x1a0
 [<ffffffff811a4bef>] ? fget_light+0xcf/0x3b0
 [<ffffffff811a4c07>] ? fget_light+0xe7/0x3b0
 [<ffffffff811a4b68>] ? fget_light+0x48/0x3b0
 [<ffffffff81516359>] sys_recvmsg+0x49/0x90
 [<ffffffff81669dc2>] system_call_fastpath+0x16/0x1b
