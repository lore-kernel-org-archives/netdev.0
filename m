From: frank.blaschka@de.ibm.com
Subject: [patch 06/10] [PATCH] qeth: suspicious rcu_dereference_check in recovery
Date: Tue, 20 Dec 2011 09:56:32 +0100
Message-ID: <20111220085736.122805720@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:48963 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab1LTI6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:58:03 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:58 -0000
Content-Disposition: inline; filename=606-qeth-rtnl-lock.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

qeth layer3 recovery invokes its set_multicast_list function, which
invokes function __vlan_find_dev_deep requiring rcu_read_lock or
rtnl lock. This causes kernel messages:

kernel: [ INFO: suspicious rcu_dereference_check() usage. ]
kernel: ---------------------------------------------------
kernel: net/8021q/vlan_core.c:70 invoked rcu_dereference_check() without protection!

kernel: stack backtrace:
kernel: CPU: 0 Not tainted 3.1.0 #9
kernel: Process qeth_recover (pid: 2078, task: 000000007e584680, ksp: 000000007e3e3930)
kernel: 000000007e3e3d08 000000007e3e3c88 0000000000000002 0000000000000000 
kernel:       000000007e3e3d28 000000007e3e3ca0 000000007e3e3ca0 00000000005e77ce 
kernel:       0000000000000000 0000000000000001 ffffffffffffffff 0000000000000001 
kernel:       000000000000000d 000000000000000c 000000007e3e3cf0 0000000000000000 
kernel:       0000000000000000 0000000000100a18 000000007e3e3c88 000000007e3e3cc8 
kernel: Call Trace:
kernel: ([<0000000000100926>] show_trace+0xee/0x144)
kernel: [<00000000005d395c>] __vlan_find_dev_deep+0xb0/0x108
kernel: [<00000000004acd3a>] qeth_l3_set_multicast_list+0x976/0xe38
kernel: [<00000000004ae0f4>] __qeth_l3_set_online+0x75c/0x1498
kernel: [<00000000004aefec>] qeth_l3_recover+0xc4/0x1d0
kernel: [<0000000000185372>] kthread+0xa6/0xb0
kernel: [<00000000005ed4c6>] kernel_thread_starter+0x6/0xc
kernel: [<00000000005ed4c0>] kernel_thread_starter+0x0/0xc

The patch makes sure the rtnl lock is held once qeth recovery invokes
its set_multicast_list function.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3492,14 +3492,13 @@ contin:
 	else
 		netif_carrier_off(card->dev);
 	if (recover_flag == CARD_STATE_RECOVER) {
+		rtnl_lock();
 		if (recovery_mode)
 			__qeth_l3_open(card->dev);
-		else {
-			rtnl_lock();
+		else
 			dev_open(card->dev);
-			rtnl_unlock();
-		}
 		qeth_l3_set_multicast_list(card->dev);
+		rtnl_unlock();
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
