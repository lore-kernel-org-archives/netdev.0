From: Ben Greear <greearb@candelatech.com>
Subject: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 14:43:36 -0700
Message-ID: <4F70E308.7070908@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39181 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab2CZVnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 17:43:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test case is complicated...creating 100 virtual wifi devices, running DHCP,
setting up routing rules, and most likely some ipv6 stuff as well.  It's all
automated by our tool, so hard to say exactly which command or set of commands
is causing this.  I read the ipv6 portion of the patch several times and do
not see a problem.

This kernel has no additional patches or out-of-tree modules loaded.

Here are two samples of output from the serial console.  The problem reproduces
100% of the time on this machine.


BUG: sleeping function called from invalid context at /home/greearb/git/linux-3..
0.dev.y/kernel/mutex.c:271
in_atomic(): 0, irqs_disabled(): 0, pid: 8897, name: ip
1 lock held by ip/8897:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa01f2190>] rcu_read_lock+0x0/0x35 [[
ipv6]
Pid: 8897, comm: ip Tainted: G         C  3.0.20+ #10
Call Trace:
  [<ffffffffa01f24fd>] ? rcu_read_unlock+0x23/0x23 [ipv6]
  [<ffffffff8103e46d>] __might_sleep+0x111/0x115
  [<ffffffff81447c04>] mutex_lock_nested+0x20/0x3b
  [<ffffffff8139bb59>] rtnl_lock+0x12/0x14
  [<ffffffff8139bc67>] rtnetlink_rcv_msg+0xe4/0x1ec
  [<ffffffff8139bb83>] ? rtnetlink_rcv+0x28/0x28
  [<ffffffff813ae578>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff8139bb7c>] rtnetlink_rcv+0x21/0x28
  [<ffffffff813ae353>] netlink_unicast+0xe9/0x152
  [<ffffffff813aeb1a>] netlink_sendmsg+0x240/0x25e
  [<ffffffff8137fadc>] ? rcu_read_unlock+0x21/0x23
  [<ffffffff8137aab1>] __sock_sendmsg_nosec+0x58/0x61
  [<ffffffff8137c0e0>] __sock_sendmsg+0x3d/0x48
  [<ffffffff8137c952>] sock_sendmsg+0xa3/0xbc
  [<ffffffff8137c3b0>] ? move_addr_to_user+0x71/0x8e
  [<ffffffff810fbebd>] ? fget_light+0x35/0xac
  [<ffffffff8137c9d3>] ? sockfd_lookup_light+0x1b/0x53
  [<ffffffff8137cf16>] sys_sendto+0xfa/0x11f
  [<ffffffff810fbd9a>] ? fcheck_files+0xb7/0xee
  [<ffffffff810fbebd>] ? fget_light+0x35/0xac
  [<ffffffff810cfedf>] ? remove_vma+0x7a/0x82
  [<ffffffff81095f21>] ? audit_syscall_entry+0x119/0x145
  [<ffffffff8144df12>] system_call_fastpath+0x16/0x1b

================================================
[ BUG: lock held when returning to user space! ]
------------------------------------------------
ip/8897 is leaving the kernel with locks still held!
1 lock held by ip/8897:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa01f2190>] rcu_read_lock+0x0/0x35 [[
ipv6]



BUG: sleeping function called from invalid context at /home/greearb/git/linux-3.0.dev.y/mm/memory.c:3904
in_atomic(): 0, irqs_disabled(): 0, pid: 4953, name: ip
1 lock held by ip/4953:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa0154190>] rcu_read_lock+0x0/0x35 [ipv6]
Pid: 4953, comm: ip Tainted: G         C  3.0.20+ #10
Call Trace:
  [<ffffffff8103e46d>] __might_sleep+0x111/0x115
  [<ffffffff810c977b>] might_fault+0x2f/0x9e
  [<ffffffff81386032>] ? copy_from_user+0x2a/0x2c
  [<ffffffff810c979a>] ? might_fault+0x4e/0x9e
  [<ffffffff8137c360>] move_addr_to_user+0x21/0x8e
  [<ffffffff8137c54c>] __sys_recvmsg+0x17f/0x21e
  [<ffffffff810fbebd>] ? fget_light+0x35/0xac
  [<ffffffff8137c9d3>] ? sockfd_lookup_light+0x1b/0x53
  [<ffffffff810fbd9a>] ? fcheck_files+0xb7/0xee
  [<ffffffff810fbebd>] ? fget_light+0x35/0xac
  [<ffffffff810cfedf>] ? remove_vma+0x7a/0x82
  [<ffffffff8137ccf0>] sys_recvmsg+0x3d/0x5b
eth1: no IPv6 routers present
  [<ffffffff8144df12>] system_call_fastpath+0x16/0x1b

================================================
[ BUG: lock held when returning to user space! ]
------------------------------------------------
ip/4953 is leaving the kernel with locks still held!
1 lock held by ip/4953:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa0154190>] rcu_read_lock+0x0/0x35 [ipv6]
ADDRCONF(NETDEV_UP): sta49: link is not ready



[greearb@fs3 linux-3.0.dev.y]$ git bisect bad
8a533666d1591cf4ea596c6bd710e2fe682cb56a is the first bad commit
commit 8a533666d1591cf4ea596c6bd710e2fe682cb56a
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Feb 9 16:13:19 2012 -0500

     net: fix NULL dereferences in check_peer_redir()

     [ Upstream commit d3aaeb38c40e5a6c08dd31a1b64da65c4352be36, along
       with dependent backports of commits:
          69cce1d1404968f78b177a0314f5822d5afdbbfb
          9de79c127cccecb11ae6a21ab1499e87aa222880
          218fa90f072e4aeff9003d57e390857f4f35513e
          580da35a31f91a594f3090b7a2c39b85cb051a12
          f7e57044eeb1841847c24aa06766c8290c202583
          e049f28883126c689cf95859480d9ee4ab23b7fa ]

     Gergely Kalman reported crashes in check_peer_redir().

     It appears commit f39925dbde778 (ipv4: Cache learned redirect
     information in inetpeer.) added a race, leading to possible NULL ptr
     dereference.

     Since we can now change dst neighbour, we should make sure a reader can
     safely use a neighbour.

     Add RCU protection to dst neighbour, and make sure check_peer_redir()
     can be called safely by different cpus in parallel.

     As neighbours are already freed after one RCU grace period, this patch
     should not add typical RCU penalty (cache cold effects)

     Many thanks to Gergely for providing a pretty report pointing to the
     bug.

     Reported-by: Gergely Kalman <synapse@hippy.csoma.elte.hu>
     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>
     Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
