From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 16:26:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF48F8A5BE.BCC1EAD8-ON88256DD6.0002173E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





About the patch below, I am still not clear about dev->reg_state
(NETREG_UNREGISTERING)
being used correctly, or how netdev_run_todo works correctly, so possibly
the race may not be
fixed. I am trying to reproduce this again. I will look some more into
this.

thanks,

- KK



|---------+------------------------------->
|         |           krkumar@us.ltcfwd.li|
|         |           nux.ibm.com         |
|         |           Sent by:            |
|         |           netdev-bounce@oss.sg|
|         |           i.com               |
|         |                               |
|         |                               |
|         |           11/05/2003 04:00 PM |
|         |                               |
|---------+------------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       davem@redhat.com                                                                                |
  |       cc:       netdev@oss.sgi.com                                                                              |
  |       Subject:  [PATCH] panic during unregister_netdevice()                                                     |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




Hi dave,

While doing a test comprising of :

insmod e100
ifup eth0
rmmod e100

on test9-bk9 bits, I got the following Oops :

Nov  5 14:54:58 linux kernel: Unable to handle kernel paging request at
virtual address 0260025d
Nov  5 14:54:58 linux kernel:  printing eip:
Nov  5 14:54:58 linux kernel: c0318a5a
Nov  5 14:54:58 linux kernel: *pde = 00000000
Nov  5 14:54:58 linux kernel: Oops: 0000 [#1]
Nov  5 14:54:58 linux kernel: CPU:    0
Nov  5 14:54:58 linux kernel: EIP:    0060:[__rta_fill+90/160]    Not
tainted
Nov  5 14:54:58 linux kernel: EIP:    0060:[<c0318a5a>]    Not tainted
Nov  5 14:54:58 linux kernel: EFLAGS: 00010282
Nov  5 14:54:58 linux kernel: EIP is at __rta_fill+0x5a/0xa0
Nov  5 14:54:58 linux kernel: eax: 00000008   ebx: 00000004   ecx: 00000001
edx: c94fe980
Nov  5 14:54:58 linux kernel: esi: 0260025d   edi: c7e8a054   ebp: c1553e64
esp: c1553e48
Nov  5 14:54:58 linux kernel: ds: 007b   es: 007b   ss: 0068
Nov  5 14:54:58 linux kernel: Process events/0 (pid: 4, threadinfo=c1552000
task=c152c670)
Nov  5 14:54:58 linux kernel: Stack: c1553e6c c011b36e c0433800 00000008
c7e8a050 ce77a000 00000000 c1553e98
Nov  5 14:54:58 linux kernel:        c0318fee c94fe980 0000000a 00000004
0260025d c030a268 00000000 c7e8a000
Nov  5 14:54:58 linux kernel:        011b000e c94fe980 ce77a000 00000011
c1553ec8 c031943c c94fe980 ce77a000
Nov  5 14:54:58 linux kernel: Call Trace:
Nov  5 14:54:58 linux kernel:  [recalc_task_prio+126/384]
recalc_task_prio+0x7e/0x180
Nov  5 14:54:58 linux kernel:  [<c011b36e>] recalc_task_prio+0x7e/0x180
Nov  5 14:54:58 linux kernel:  [rtnetlink_fill_ifinfo+862/1264]
rtnetlink_fill_ifinfo+0x35e/0x4f0
Nov  5 14:54:58 linux kernel:  [<c0318fee>]
rtnetlink_fill_ifinfo+0x35e/0x4f0
Nov  5 14:54:58 linux kernel:  [alloc_skb+72/240] alloc_skb+0x48/0xf0
Nov  5 14:54:58 linux kernel:  [<c030a268>] alloc_skb+0x48/0xf0
Nov  5 14:54:58 linux kernel:  [rtmsg_ifinfo+92/208] rtmsg_ifinfo+0x5c/0xd0
Nov  5 14:54:58 linux kernel:  [<c031943c>] rtmsg_ifinfo+0x5c/0xd0
Nov  5 14:54:58 linux kernel:  [rtnetlink_event+48/117]
rtnetlink_event+0x30/0x75
Nov  5 14:54:58 linux kernel:  [<c0319980>] rtnetlink_event+0x30/0x75
Nov  5 14:54:58 linux kernel:  [notifier_call_chain+45/80]
notifier_call_chain+0x2d/0x50
Nov  5 14:54:58 linux kernel:  [<c013055d>] notifier_call_chain+0x2d/0x50
Nov  5 14:54:58 linux kernel:  [netdev_wait_allrefs+242/320]
netdev_wait_allrefs+0xf2/0x140
Nov  5 14:54:58 linux kernel:  [<c0310d52>] netdev_wait_allrefs+0xf2/0x140
Nov  5 14:54:58 linux kernel:  [netdev_run_todo+347/608]
netdev_run_todo+0x15b/0x260
Nov  5 14:54:58 linux kernel:  [<c0310efb>] netdev_run_todo+0x15b/0x260
Nov  5 14:54:58 linux kernel:  [worker_thread+531/800]
worker_thread+0x213/0x320
Nov  5 14:54:58 linux kernel:  [<c01333a3>] worker_thread+0x213/0x320
Nov  5 14:54:58 linux kernel:  [linkwatch_event+0/48]
linkwatch_event+0x0/0x30
Nov  5 14:54:58 linux kernel:  [<c0319c60>] linkwatch_event+0x0/0x30
Nov  5 14:54:58 linux kernel:  [default_wake_function+0/48]
default_wake_function+0x0/0x30
Nov  5 14:54:58 linux kernel:  [<c011d030>] default_wake_function+0x0/0x30
Nov  5 14:54:58 linux kernel:  [ret_from_fork+6/20] ret_from_fork+0x6/0x14
Nov  5 14:54:58 linux kernel:  [<c01097e6>] ret_from_fork+0x6/0x14
Nov  5 14:54:58 linux kernel:  [default_wake_function+0/48]
default_wake_function+0x0/0x30
Nov  5 14:54:58 linux kernel:  [<c011d030>] default_wake_function+0x0/0x30
Nov  5 14:54:58 linux kernel:  [worker_thread+0/800]
worker_thread+0x0/0x320
Nov  5 14:54:58 linux kernel:  [<c0133190>] worker_thread+0x0/0x320
Nov  5 14:54:58 linux kernel:  [kernel_thread_helper+5/24]
kernel_thread_helper+0x5/0x18
Nov  5 14:54:58 linux kernel:  [<c010753d>] kernel_thread_helper+0x5/0x18
Nov  5 14:54:58 linux kernel:
Nov  5 14:54:58 linux kernel: Code: f3 a5 f6 c3 02 74 02 66 a5 f6 c3 01 74
01 a4 8b 5d f4 8b 75


I think the problem is as follows (changed between 2.4 and 2.6).
unregister_netdevice() drops the last reference to the device and waits
for the ref counter for the dev to drop to zero. While it is OK for
unregister_netdevice to call notifier_call_chain (since it does a dev_put
at the end of the routine), netdev_wait_allrefs() cannot do the same until
it gets it's own reference. The dev can disappear during this when the
last reference gets dropped by the process holding it.

Following patch should fix it. I will try to reproduce this with and
without the patch to be certain.

Thanks,

- KK

diff -ruN linux-2.6.0-test9-bk9/net/core/dev.c
linux-2.6.0-test9-bk9.new/net/core/dev.c
--- linux-2.6.0-test9-bk9/net/core/dev.c         2003-11-05
15:43:21.000000000 -0800
+++ linux-2.6.0-test9-bk9.new/net/core/dev.c           2003-11-05
15:43:50.000000000 -0800
@@ -2749,8 +2749,10 @@
                                     rtnl_exlock();

                                     /* Rebroadcast unregister notification
*/
+                                    dev_hold(dev);
                                     notifier_call_chain(&netdev_chain,

NETDEV_UNREGISTER, dev);
+                                    dev_put(dev);

                                     if
(test_bit(__LINK_STATE_LINKWATCH_PENDING,
                                                      &dev->state)) {
