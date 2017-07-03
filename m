From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: locking issues in macvtap (looks like due to tap: Extending tap
 device create/destroy APIs)
Date: Mon, 3 Jul 2017 16:15:27 +0200
Message-ID: <abc8057f-5a6c-f3d1-ffda-46d583c273cd@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, KVM list <kvm@vger.kernel.org>,
        "linux-kernel@vger.kernel.org >> Linux Kernel Mailing List"
        <linux-kernel@vger.kernel.org>
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34065 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932902AbdGCOPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 10:15:39 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v63EDbOr088760
        for <netdev@vger.kernel.org>; Mon, 3 Jul 2017 10:15:34 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2beyttf5yy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 10:15:33 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
        Mon, 3 Jul 2017 08:15:33 -0600
Content-Language: en-IE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sainath,

with rcu debugging and lock debugging I get the following splats.
I think doing a mutex_lock while in an rcu read-side is not allowed,
since mutex_lock can sleep.

This is in 4.11 and 4.12 and seems to be introduced with commit
d9f1f61c0801a7("tap: Extending tap device create/destroy APIs").


Christian


[  125.678015] ===============================
[  125.678018] [ ERR: suspicious RCU usage.  ]
[  125.678022] 4.11.0+ #18 Not tainted
[  125.678025] -------------------------------
[  125.678028] ./include/linux/rcupdate.h:521 Illegal context switch in RCU read-side critical section!
[  125.678031] 
               other info that might help us debug this:

[  125.678035] 
               rcu_scheduler_active = 2, debug_locks = 0
[  125.678038] 2 locks held by libvirtd/3050:
[  125.678041]  #0:  (rtnl_mutex){+.+.+.}, at: [<0000000000772b02>] rtnl_newlink+0x2ea/0x880
[  125.678057]  #1:  (rcu_read_lock){......}, at: [<000003ff800dad00>] tap_get_minor+0x0/0x1d8 [tap]
[  125.678068] 
               stack backtrace:
[  125.678073] CPU: 26 PID: 3050 Comm: libvirtd Not tainted 4.11.0+ #18
[  125.678076] Hardware name: IBM 2964 NC9 704 (LPAR)
[  125.678079] Stack:
[  125.678081]        000000fa977cb230 000000fa977cb2c0 0000000000000003 0000000000000000
[  125.678091]        000000fa977cb360 000000fa977cb2d8 000000fa977cb2d8 0000000000000020
[  125.678100]        0000000000000000 000003ff00000020 000000fa0000000a 000000fa0000000a
[  125.678109]        000000000000000c 000000fa977cb328 0000000000000000 0000000000000000
[  125.678119]        00000000008e2510 00000000001139ac 000000fa977cb2c0 000000fa977cb318
[  125.678150] Call Trace:
[  125.678157] ([<0000000000113872>] show_trace+0xea/0xf0)
[  125.678160]  [<0000000000113950>] show_stack+0x68/0xe0 
[  125.678165]  [<000000000057ef8c>] dump_stack+0x94/0xd8 
[  125.678172]  [<00000000001a4422>] ___might_sleep+0x21a/0x268 
[  125.678177]  [<00000000008ca842>] __mutex_lock+0x52/0x968 
[  125.678180]  [<00000000008cb192>] mutex_lock_nested+0x3a/0x48 
[  125.678184]  [<000003ff800dadd6>] tap_get_minor+0xd6/0x1d8 [tap] 
[  125.678188]  [<000003ff801773a2>] macvtap_device_event+0x9a/0x1a0 [macvtap] 
[  125.678191]  [<000000000019bfbe>] notifier_call_chain+0x56/0x98 
[  125.678195]  [<000000000019c1b2>] raw_notifier_call_chain+0x32/0x40 
[  125.678200]  [<000000000075d014>] register_netdevice+0x3f4/0x508 
[  125.678204]  [<000003ff801718a0>] macvlan_common_newlink+0x360/0x430 [macvlan] 
[  125.678207]  [<000003ff80177564>] macvtap_newlink+0xbc/0xf0 [macvtap] 
[  125.678211]  [<0000000000772e32>] rtnl_newlink+0x61a/0x880 
[  125.678214]  [<000000000077313c>] rtnetlink_rcv_msg+0xa4/0x248 
[  125.678219]  [<000000000079cec0>] netlink_rcv_skb+0xd8/0x108 
[  125.678222]  [<000000000076f538>] rtnetlink_rcv+0x48/0x58 
[  125.678226]  [<000000000079c750>] netlink_unicast+0x178/0x1f8 
[  125.678229]  [<000000000079cbd4>] netlink_sendmsg+0x304/0x3b0 
[  125.678233]  [<0000000000730676>] sock_sendmsg+0x6e/0x80 
[  125.678237]  [<00000000007311b0>] ___sys_sendmsg+0x2a0/0x2a8 
[  125.678240]  [<00000000007324d8>] __sys_sendmsg+0x60/0xa8 
[  125.678244]  [<0000000000732ed4>] SyS_socketcall+0x33c/0x390 
[  125.678248]  [<00000000008d08bc>] system_call+0xc4/0x258 
[  125.678251] INFO: lockdep is turned off.
[  125.678255] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:747
[  125.678257] in_atomic(): 1, irqs_disabled(): 0, pid: 3050, name: libvirtd
[  125.678261] INFO: lockdep is turned off.
[  125.678264] CPU: 26 PID: 3050 Comm: libvirtd Not tainted 4.11.0+ #18
[  125.678267] Hardware name: IBM 2964 NC9 704 (LPAR)
[  125.678269] Stack:
[  125.678272]        000000fa977cb230 000000fa977cb2c0 0000000000000003 0000000000000000
[  125.678281]        000000fa977cb360 000000fa977cb2d8 000000fa977cb2d8 0000000000000020
[  125.678290]        0000000000000000 000000fa00000020 000000fa0000000a 000000fa0000000a
[  125.678298]        000000000000000c 000000fa977cb328 0000000000000000 0000000000000000
[  125.678308]        00000000008e2510 00000000001139ac 000000fa977cb2c0 000000fa977cb318
[  125.678323] Call Trace:
[  125.678326] ([<0000000000113872>] show_trace+0xea/0xf0)
[  125.678330]  [<0000000000113950>] show_stack+0x68/0xe0 
[  125.678334]  [<000000000057ef8c>] dump_stack+0x94/0xd8 
[  125.678337]  [<00000000001a438e>] ___might_sleep+0x186/0x268 
[  125.678341]  [<00000000008ca842>] __mutex_lock+0x52/0x968 
[  125.678346]  [<00000000008cb192>] mutex_lock_nested+0x3a/0x48 
[  125.678350]  [<000003ff800dadd6>] tap_get_minor+0xd6/0x1d8 [tap] 
[  125.678354]  [<000003ff801773a2>] macvtap_device_event+0x9a/0x1a0 [macvtap] 
[  125.678357]  [<000000000019bfbe>] notifier_call_chain+0x56/0x98 
[  125.678360]  [<000000000019c1b2>] raw_notifier_call_chain+0x32/0x40 
[  125.678364]  [<000000000075d014>] register_netdevice+0x3f4/0x508 
[  125.678368]  [<000003ff801718a0>] macvlan_common_newlink+0x360/0x430 [macvlan] 
[  125.678371]  [<000003ff80177564>] macvtap_newlink+0xbc/0xf0 [macvtap] 
[  125.678374]  [<0000000000772e32>] rtnl_newlink+0x61a/0x880 
[  125.678377]  [<000000000077313c>] rtnetlink_rcv_msg+0xa4/0x248 
[  125.678380]  [<000000000079cec0>] netlink_rcv_skb+0xd8/0x108 
[  125.678382]  [<000000000076f538>] rtnetlink_rcv+0x48/0x58 
[  125.678386]  [<000000000079c750>] netlink_unicast+0x178/0x1f8 
[  125.678389]  [<000000000079cbd4>] netlink_sendmsg+0x304/0x3b0 
[  125.678392]  [<0000000000730676>] sock_sendmsg+0x6e/0x80 
[  125.678395]  [<00000000007311b0>] ___sys_sendmsg+0x2a0/0x2a8 
[  125.678398]  [<00000000007324d8>] __sys_sendmsg+0x60/0xa8 
[  125.678401]  [<0000000000732ed4>] SyS_socketcall+0x33c/0x390 
[  125.678404]  [<00000000008d08bc>] system_call+0xc4/0x258 
[  125.678407] INFO: lockdep is turned off.
