From: Andre Correa <andre.correa@pobox.com>
Subject: Bad: scheduling while atomic! in 2.6.8.1
Date: Thu, 02 Sep 2004 12:40:05 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41373ED5.5070606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, andre.correa@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi, I set up a Linux box as a firewall with 4 NICs (3C905) on a Dell 
with 2.6.8.1 and iptables 1.2.11. 3 NICs have several IP addresses and 
the 4th has 4 VLANs associated. This box is plugged on Cisco switches.

Everything was fine, firewalling OK, until I plugged the 4th NIC. When 
traffic start to flow the box logs a _LOT_ of errors on syslog:

<snip>
Sep  1 03:58:48 fw01 kernel: bad: scheduling while atomic!
Sep  1 03:58:48 fw01 kernel:  [<c028bddc>] schedule+0x3c/0x428
Sep  1 03:58:48 fw01 kernel:  [<c0230c74>] sys_socketcall+0x150/0x1f4
Sep  1 03:58:48 fw01 kernel:  [<c0103c0e>] work_resched+0x5/0x16
Sep  1 03:58:48 fw01 kernel: bad: scheduling while atomic!
Sep  1 03:58:48 fw01 kernel:  [<c028bddc>] schedule+0x3c/0x428
Sep  1 03:58:48 fw01 kernel:  [<c0232a63>] __kfree_skb+0xd3/0xd8
Sep  1 03:58:48 fw01 kernel:  [<c028c5d4>] schedule_timeout+0x14/0xb0
Sep  1 03:58:48 fw01 kernel:  [<c02862ac>] unix_wait_for_peer+0xac/0xc8
Sep  1 03:58:48 fw01 kernel:  [<c010f348>] autoremove_wake_function+0x0/0x40
Sep  1 03:58:48 fw01 kernel:  [<c010f348>] autoremove_wake_function+0x0/0x40
Sep  1 03:58:48 fw01 kernel:  [<c0286d4f>] unix_dgram_sendmsg+0x39b/0x4b0
Sep  1 03:58:48 fw01 kernel:  [<c022f6b1>] sock_aio_write+0x101/0x10c
Sep  1 03:58:48 fw01 kernel:  [<c013d6e6>] do_sync_write+0x7a/0xac
Sep  1 03:58:48 fw01 kernel:  [<c023298b>] kfree_skbmem+0x17/0x1c
Sep  1 03:58:48 fw01 kernel:  [<c0232a63>] __kfree_skb+0xd3/0xd8
Sep  1 03:58:48 fw01 kernel:  [<c013d7cd>] vfs_write+0xb5/0xd4
Sep  1 03:58:48 fw01 kernel:  [<c013d898>] sys_write+0x40/0x6c
Sep  1 03:58:48 fw01 kernel:  [<c0103be7>] syscall_call+0x7/0xb
Sep  1 03:58:48 fw01 kernel: bad: scheduling while atomic!
Sep  1 03:58:48 fw01 kernel:  [<c028bddc>] schedule+0x3c/0x428
Sep  1 03:58:49 fw01 kernel:  [<c0230c74>] sys_socketcall+0x150/0x1f4
Sep  1 03:58:49 fw01 kernel:  [<c0103c0e>] work_resched+0x5/0x16
Sep  1 03:58:49 fw01 kernel: bad: scheduling while atomic!
Sep  1 03:58:49 fw01 kernel:  [<c028bddc>] schedule+0x3c/0x428
Sep  1 03:58:49 fw01 kernel:  [<c0232a63>] __kfree_skb+0xd3/0xd8
Sep  1 03:58:49 fw01 kernel:  [<c028c5d4>] schedule_timeout+0x14/0xb0
Sep  1 03:58:49 fw01 kernel:  [<c02862ac>] unix_wait_for_peer+0xac/0xc8
Sep  1 03:58:49 fw01 kernel:  [<c010f348>] autoremove_wake_function+0x0/0x40
Sep  1 03:58:49 fw01 kernel:  [<c010f348>] autoremove_wake_function+0x0/0x40
Sep  1 03:58:49 fw01 kernel:  [<c0286d4f>] unix_dgram_sendmsg+0x39b/0x4b0
Sep  1 03:58:49 fw01 kernel:  [<c022f6b1>] sock_aio_write+0x101/0x10c
Sep  1 03:58:49 fw01 kernel:  [<c013d6e6>] do_sync_write+0x7a/0xac
Sep  1 03:58:49 fw01 kernel:  [<c023298b>] kfree_skbmem+0x17/0x1c
Sep  1 03:58:49 fw01 kernel:  [<c0232a63>] __kfree_skb+0xd3/0xd8
Sep  1 03:58:49 fw01 kernel:  [<c013d7cd>] vfs_write+0xb5/0xd4
Sep  1 03:58:49 fw01 kernel:  [<c013d898>] sys_write+0x40/0x6c
Sep  1 03:58:49 fw01 kernel:  [<c0103be7>] syscall_call+0x7/0xb
<snip>

I got more then 110Mb of it in ~2 hours of tests. Shutting down 
interface doesn't stop it, just a reboot takes the machine back to its 
normal state, if cable is unplugged.

I've tested NIC, cable, PCI slot, switch port, switch and even changed 
the box itself, but nothing helped. When I take VLAN down, on Cisco 
switch, no errors are logged. If I go back to 2.6.7 + VLAN, no errors 
too, all OK.

It seens to be related to VLAN on 2.6.8.1 only. Searching kernel source 
I found that it comes from kernel/sched.c, but it doesn't tells me much.

<snip>
         /*
          * Test if we are atomic.  Since do_exit() needs to call into
          * schedule() atomically, we ignore that path for now.
          * Otherwise, whine if we are scheduling when we should not be.
          */
         if (likely(!(current->state & (TASK_DEAD | TASK_ZOMBIE)))) {
                 if (unlikely(in_atomic())) {
                         printk(KERN_ERR "bad: scheduling while atomic!\n");
                         dump_stack();
                 }
         }
<snip>

Does anybody can help on it?! Does it look like a bug or what?

Any help is appreciated.

tks

Andre
