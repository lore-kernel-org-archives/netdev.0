From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH net] ipv4: reject RTNH_F_LINKDOWN for incompatible routes
Date: Sat, 9 Jul 2016 21:10:02 +0200
Message-ID: <57814C0A.8080404@oracle.com>
References: <1468054815-24766-1-git-send-email-ja@ssi.bg>
 <20160709172327.GP18787@gospo.rdu.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26967 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756620AbcGITKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 15:10:24 -0400
In-Reply-To: <20160709172327.GP18787@gospo.rdu.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2016 07:23 PM, Andy Gospodarek wrote:
> On Sat, Jul 09, 2016 at 12:00:15PM +0300, Julian Anastasov wrote:
>> Vegard Nossum is reporting for a crash in fib_dump_info (fib_nhs==1)
>> when nh_dev = NULL. Problem happens when RTNH_F_LINKDOWN is
>> provided from user space for routes that do not use the flag,
>> catched with netlink fuzzer.
>
> Can you also include the panic log in the changelog or at a minimum post
> it here?

Pid: 50, comm: netlink.exe Not tainted 4.7.0-rc5+
RIP: 0033:[<00000000602b3d18>]
RSP: 0000000062623890  EFLAGS: 00010202
RAX: 0000000000000000 RBX: 000000006261b800 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000024 RDI: 000000006245ba00
RBP: 00000000626238f0 R08: 000000000000029c R09: 0000000000000000
R10: 0000000062468038 R11: 000000006245ba00 R12: 000000006245ba00
R13: 00000000625f96c0 R14: 00000000601e16f0 R15: 0000000000000000
Kernel panic - not syncing: Kernel mode fault at addr 0x2e0, ip 0x602b3d18
CPU: 0 PID: 50 Comm: netlink.exe Not tainted 4.7.0-rc5+ #581
Stack:
  626238f0 960226a02 00000400 000000fe
  62623910 600afca7 62623970 62623a48
  62468038 00000018 00000000 00000000
Call Trace:
  [<602b3e93>] rtmsg_fib+0xd3/0x190
  [<602b6680>] fib_table_insert+0x260/0x500
  [<602b0e5d>] inet_rtm_newroute+0x4d/0x60
  [<60250def>] rtnetlink_rcv_msg+0x8f/0x270
  [<60267079>] netlink_rcv_skb+0xc9/0xe0
  [<60250d4b>] rtnetlink_rcv+0x3b/0x50
  [<60265400>] netlink_unicast+0x1a0/0x2c0
  [<60265e47>] netlink_sendmsg+0x3f7/0x470
  [<6021dc9a>] sock_sendmsg+0x3a/0x90
  [<6021e0d0>] ___sys_sendmsg+0x300/0x360
  [<6021fa64>] __sys_sendmsg+0x54/0xa0
  [<6021fac0>] SyS_sendmsg+0x10/0x20
  [<6001ea68>] handle_syscall+0x88/0x90
  [<600295fd>] userspace+0x3fd/0x500
  [<6001ac55>] fork_handler+0x85/0x90

$ addr2line -e vmlinux -i 0x602b3d18
include/linux/inetdevice.h:222
net/ipv4/fib_semantics.c:1264

220 static inline struct in_device *__in_dev_get_rtnl(const struct 
net_device *dev)
221 {
222         return rtnl_dereference(dev->ip_ptr);
223 }

1263                 if (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN) {
1264                         in_dev = __in_dev_get_rtnl(fi->fib_nh->nh_dev);
1265                         if (in_dev &&

>> RTNH_F_LINKDOWN should be used only for link routes, not for
>> local routes or for routes with error code. Do not complicate
>> fast path with more checks, reject the flag early when configured
>> for incompatible routes.
>
> Did the netlink fuzzer (trinity?) happen to check any of the other flags
> (liks RTNH_F_DEAD) that are normally set by the kernel but could be
> problematic when send down from userspace?

I honestly don't know -- the fuzzer (based on AFL) doesn't know anything
about netlink in particular, so if it passed/tested any other flags it
was by chance and not by design.


Vegard
