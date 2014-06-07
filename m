From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: netlink executing RO memory
Date: Sat, 07 Jun 2014 11:07:14 -0400
Message-ID: <53932AA2.4050204@oracle.com>
References: <5390D152.30702@oracle.com> <53915571.7050801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53915571.7050801@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2014 01:45 AM, Sasha Levin wrote:
> On 06/05/2014 04:21 PM, Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest running the latest -next
>> kernel I've stumbled on the following spew:
>>
>> [  306.065161] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
>> [  306.067295] BUG: unable to handle kernel paging request at ffff880053b8fd08
> 
> Same issue reproduced multiple times with exactly the same trace, so I think that it
> rules out random memory corruption.

I might have another lead of this: I caught debug objects complaining about freeing
active objects:

[  592.020501] ODEBUG: free active (active state 1) object type: rcu_head hint:           (null)
[  592.020501] Modules linked in:
[  592.020501] CPU: 15 PID: 16543 Comm: trinity-c47 Not tainted 3.15.0-rc8-next-20140606-sasha-00021-ga9d3a0b-dirty #596
[  592.020501]  0000000000000009 ffff880224793988 ffffffff9350fe6b 0000000000000002
[  592.020501]  ffff8802247939d8 ffff8802247939c8 ffffffff9015f96c ffff88000fd40cf8
[  592.020501]  ffff88006d9a9870 ffffffff9508a000 ffffffff948fbd48 ffffffff97891e90
[  592.020501] Call Trace:
[  592.020501] dump_stack (lib/dump_stack.c:52)
[  592.020501] warn_slowpath_common (kernel/panic.c:430)
[  592.020501] warn_slowpath_fmt (kernel/panic.c:445)
[  592.020501] debug_print_object (lib/debugobjects.c:265)
[  592.020501] __debug_check_no_obj_freed (lib/debugobjects.c:698)
[  592.020501] debug_check_no_obj_freed (lib/debugobjects.c:727)
[  592.020501] __vunmap (mm/vmalloc.c:1457)
[  592.020501] vfree (mm/vmalloc.c:1505)
[  592.020501] netlink_skb_destructor (net/netlink/af_netlink.c:882)
[  592.020501] skb_release_head_state (net/core/skbuff.c:566)
[  592.020501] skb_release_all (net/core/skbuff.c:584)
[  592.020501] __kfree_skb (net/core/skbuff.c:529 net/core/skbuff.c:600)
[  592.020501] consume_skb (net/core/skbuff.c:672)
[  592.020501] skb_free_datagram (include/net/sock.h:1419 include/net/sock.h:1450 net/core/datagram.c:244)
[  592.020501] netlink_recvmsg (net/netlink/af_netlink.c:2482)
[  592.020501] ? preempt_count_sub (kernel/sched/core.c:2602)
[  592.020501] sock_aio_read (net/socket.c:917 net/socket.c:935)
[  592.020501] ? rw_copy_check_uvector (fs/read_write.c:753)
[  592.020501] do_sync_readv_writev (fs/read_write.c:683)
[  592.020501] do_readv_writev (fs/read_write.c:837)
[  592.020501] ? vtime_account_user (kernel/sched/cputime.c:687)
[  592.020501] ? get_parent_ip (kernel/sched/core.c:2546)
[  592.020501] ? __fget_light (include/linux/rcupdate.h:428 include/linux/fdtable.h:80 fs/file.c:684)
[  592.020501] vfs_readv (fs/read_write.c:866)
[  592.020501] SyS_readv (fs/read_write.c:892 fs/read_write.c:884)
[  592.020501] tracesys (arch/x86/kernel/entry_64.S:542)

I can't link them together (stacks don't match with what I'd expect to see in that
case), but that might be related somehow.


Thanks,
Sasha
