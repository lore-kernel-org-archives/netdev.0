From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch] work around/fix deadlock in the bcm43xx driver by making
	netlink irq safe
Date: Fri, 30 Jun 2006 16:24:54 +0200
Message-ID: <1151677494.11434.47.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:49055 "EHLO
	laptopd505.fenrus.org") by vger.kernel.org with ESMTP
	id S1750996AbWF3OY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 10:24:56 -0400
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.4/8.13.4) with ESMTP id k5UEOtkJ013515
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 16:24:55 +0200
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.4/8.13.4/Submit) id k5UEOsI1013514
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 16:24:54 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

there is a complex deadlock in the bcm43xx driver, that apparently can
only be solved by rewriting the softmac layer.... or by the patch below
that makes the netlink lock irq safe. (details about the deadlock
available but sort of not relevant for the discussion).
Please consider this patch for 2.6.18

Signed-off-by: Arjan van de Ven <arjan@Linux.intel.com>

---
 net/netlink/af_netlink.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.17-mm4/net/netlink/af_netlink.c
===================================================================
--- linux-2.6.17-mm4.orig/net/netlink/af_netlink.c
+++ linux-2.6.17-mm4/net/netlink/af_netlink.c
@@ -157,7 +157,7 @@ static void netlink_sock_destruct(struct
 
 static void netlink_table_grab(void)
 {
-	write_lock_bh(&nl_table_lock);
+	write_lock_irq(&nl_table_lock);
 
 	if (atomic_read(&nl_table_users)) {
 		DECLARE_WAITQUEUE(wait, current);
@@ -167,9 +167,9 @@ static void netlink_table_grab(void)
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			if (atomic_read(&nl_table_users) == 0)
 				break;
-			write_unlock_bh(&nl_table_lock);
+			write_unlock_irq(&nl_table_lock);
 			schedule();
-			write_lock_bh(&nl_table_lock);
+			write_lock_irq(&nl_table_lock);
 		}
 
 		__set_current_state(TASK_RUNNING);
@@ -179,7 +179,7 @@ static void netlink_table_grab(void)
 
 static __inline__ void netlink_table_ungrab(void)
 {
-	write_unlock_bh(&nl_table_lock);
+	write_unlock_irq(&nl_table_lock);
 	wake_up(&nl_table_wait);
 }
 

