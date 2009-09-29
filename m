From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 17:12:33 +0200
Message-ID: <200909291712.33099.borntraeger@de.ibm.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <20090929142538.GA10180@redhat.com> <20090929144554.GA10937@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>,
	Scott James Remnant <scott@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:47527 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbZI2PM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 11:12:57 -0400
In-Reply-To: <20090929144554.GA10937@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 29 September 2009 16:45:54 schrieb Oleg Nesterov:
> I think Christian's patch only needs the small fixup.

Oleg, Evgeniy,

just in case the discussion concludes that my patch is fine,
here is a fixed version.

[PATCH] connector: Fix sid connector

The sid connector gives the following warning:
Badness at kernel/softirq.c:143
[...]
Call Trace:
([<000000013fe04100>] 0x13fe04100)
 [<000000000048a946>] sk_filter+0x9a/0xd0
 [<000000000049d938>] netlink_broadcast+0x2c0/0x53c
 [<00000000003ba9ae>] cn_netlink_send+0x272/0x2b0
 [<00000000003baef0>] proc_sid_connector+0xc4/0xd4
 [<0000000000142604>] __set_special_pids+0x58/0x90
 [<0000000000159938>] sys_setsid+0xb4/0xd8
 [<00000000001187fe>] sysc_noemu+0x10/0x16
 [<00000041616cb266>] 0x41616cb266

The warning is
--->    WARN_ON_ONCE(in_irq() || irqs_disabled());

The network code must not be called with disabled interrupts but
sys_setsid holds the tasklist_lock with spinlock_irq while calling
the connector. We can safely move proc_sid_connector from
__set_special_pids to sys_setsid.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

---
 kernel/exit.c |    4 +---
 kernel/sys.c  |    2 ++
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c
+++ linux-2.6/kernel/exit.c
@@ -359,10 +359,8 @@ void __set_special_pids(struct pid *pid)
 {
 	struct task_struct *curr = current->group_leader;
 
-	if (task_session(curr) != pid) {
+	if (task_session(curr) != pid)
 		change_pid(curr, PIDTYPE_SID, pid);
-		proc_sid_connector(curr);
-	}
 
 	if (task_pgrp(curr) != pid)
 		change_pid(curr, PIDTYPE_PGID, pid);
Index: linux-2.6/kernel/sys.c
===================================================================
--- linux-2.6.orig/kernel/sys.c
+++ linux-2.6/kernel/sys.c
@@ -1110,6 +1110,8 @@ SYSCALL_DEFINE0(setsid)
 	err = session;
 out:
 	write_unlock_irq(&tasklist_lock);
+	if (err > 0)
+		proc_sid_connector(sid);
 	return err;
 }
 
