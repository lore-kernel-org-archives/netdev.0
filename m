From: Lekensteyn <lekensteyn@gmail.com>
Subject: [REGRESSION,v3.7-rc5,bisected] 100% CPU usage in softirqd, unable to shutdown
Date: Mon, 12 Nov 2012 22:20:59 +0100
Message-ID: <5934660.4HuQirPM4Z@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Xiaotian Feng <dannyfeng@tencent.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47663 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab2KLVVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 16:21:13 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so3625292eek.19
        for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 13:21:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After upgrading from 3.7-rc4 to 3.7-rc5 I found that I was unable to suspend 
without locking up the system afterwards. Neither was I able to shutdown as it 
would simply hang where it should halt. The second suspend/resume in a session 
would make Networkmanager hang.

When looking in my process list, I saw that softirqd was using one full CPU 
core. Watching the contents of /proc/softirqs showed that the tasklet number 
would rapidly increase.

I got this message when trying to suspend for the second time in a session:

 Freezing user space processes ... 
 Freezing of tasks failed after 20.01 seconds (1 tasks refusing to freeze, 
wq_busy=0):
 NetworkManager  R  running task        0   332      1 0x00000004
  ffff88023169d628 ffffffff81549b86 ffff8802316e4470 ffff88023169dfd8
  ffff88023169dfd8 ffff88023169dfd8 ffff8802316e4470 ffff8802316e4470
  ffff88023169d698 ffff88023bc92a80 ffff88022fd3db70 ffff88022fd3dc90
 Call Trace:
  [<ffffffff81549b9e>] ? __schedule+0x13e/0x760
  [<ffffffff8154a4f9>] schedule+0x29/0x70
  [<ffffffff810722aa>] sys_sched_yield+0x4a/0x60
  [<ffffffff8154a7c2>] yield+0x32/0x40
  [<ffffffff810451f5>] tasklet_kill+0x35/0x80
  [<ffffffffa017c2f3>] jme_close+0xd3/0x850 [jme]
  [<ffffffff8146325d>] __dev_close_many+0x7d/0xc0
  [<ffffffff814632cd>] __dev_close+0x2d/0x40
  [<ffffffff81469551>] __dev_change_flags+0xa1/0x180
  [<ffffffff814696e8>] dev_change_flags+0x28/0x70
  [<ffffffff81475b68>] do_setlink+0x378/0xa00
  [<ffffffff81078a56>] ? find_busiest_group+0x36/0x490
  [<ffffffff812d5821>] ? nla_parse+0x31/0xe0
  [<ffffffff812d5821>] ? nla_parse+0x31/0xe0
  [<ffffffff81477e6e>] rtnl_newlink+0x36e/0x590
  [<ffffffff81286e16>] ? apparmor_capable+0x26/0x90
  [<ffffffff81477694>] rtnetlink_rcv_msg+0x114/0x300
  [<ffffffff8114d1c3>] ? __kmalloc_node_track_caller+0x63/0x1b0
  [<ffffffff8145b65b>] ? __alloc_skb+0x8b/0x290
  [<ffffffff81477580>] ? __rtnl_unlock+0x20/0x20
  [<ffffffff8148f471>] netlink_rcv_skb+0xb1/0xc0
  [<ffffffff814748f5>] rtnetlink_rcv+0x25/0x40
  [<ffffffff8148ed8b>] netlink_unicast+0x19b/0x220
  [<ffffffff8148f111>] netlink_sendmsg+0x301/0x3c0
  [<ffffffff8144f8ec>] sock_sendmsg+0xbc/0xf0
  [<ffffffff81450797>] ? sock_recvmsg+0xd7/0x110
  [<ffffffff8145045c>] __sys_sendmsg+0x3ac/0x3c0
  [<ffffffff810854dc>] ? ktime_get_ts+0x4c/0xf0
  [<ffffffff81452699>] sys_sendmsg+0x49/0x90
  [<ffffffff81553906>] system_call_fastpath+0x1a/0x1f

Bisecting leads to:
commit 175c0dffef310fc7d7f026ca4a7682beb2fbd8ec
Author: Xiaotian Feng <xtfeng@gmail.com>
Date:   Wed Oct 31 00:29:57 2012 +0000

    drivers/net: use tasklet_kill in device remove/close process
    
    Some driver uses tasklet_disable in device remove/close process,
    tasklet_disable will inc tasklet->count and return. If the tasklet
    is not handled yet because some softirq pressure, the tasklet will
    placed on the tasklet_vec, never have a chance to excute. This might
    lead to ksoftirqd heavy loaded, wakeup with pending_softirq, but
    tasklet is disabled. tasklet_kill should be used in this case.
    
    Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
    Cc: "David S. Miller" <davem@davemloft.net>
    Cc: netdev@vger.kernel.org
    Signed-off-by: David S. Miller <davem@davemloft.net>
(if it wasn't obvious, I have an Ethernet device that needs the "jme" driver, 
04:00.5 Ethernet controller [0200]: JMicron Technology Corp. JMC250 PCI 
Express Gigabit Ethernet Controller [197b:0250] (rev 03))

Since 3.7, I sometimes get the below messages during suspend, but it would 
never hang:
smpboot: CPU 2 is now offline                                                                                                                                                                                                    
NOHZ: local_softirq_pending 02                                                                                                                                                                                                   
NOHZ: local_softirq_pending 202                                                                                                                                                                                                  
NOHZ: local_softirq_pending 202
NOHZ: local_softirq_pending 02
NOHZ: local_softirq_pending 202
NOHZ: local_softirq_pending 202
smpboot: CPU 3 is now offline

Time for a revert or do you have an other proposed fix?

Regards,
Peter
