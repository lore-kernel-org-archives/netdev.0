From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] netconsole: fix NULL pointer dereference
Date: Wed, 23 Oct 2013 15:04:49 +0200
Message-ID: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab3JWNIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 09:08:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to disable the netconsole (enabled = 0) before setting nt->np.dev
to NULL because otherwise we might still have users after the
netpoll_cleanup() since nt->enabled is set afterwards and we can
have a message which will result in a NULL pointer dereference.
It is very easy to hit dereferences all over the netpoll_send_udp function
by running the following two loops in parallel:
while [ 1 ]; do echo 1 > enabled; echo 0 > enabled; done;
while [ 1 ]; do echo 00:11:22:33:44:55 > remote_mac; done;
(the second loop is to generate messages, it can be done by anything)

We're safe to set nt->np.dev = NULL and nt->enabled = 0 with the spinlock
since it's required in the write_msg() function.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Taking the spinlock seems like the cleanest way to insure there's noone
running in parallel, but I'm open to suggestions as I'm not satisfied with
the looks of this. I'll prepare a net-next patchset for netconsole soon to
clean it up properly, all of these can be easily simplified.

 drivers/net/netconsole.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index adeee61..1505dcb 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -310,6 +310,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			     const char *buf,
 			     size_t count)
 {
+	unsigned long flags;
 	int enabled;
 	int err;
 
@@ -342,6 +343,13 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		printk(KERN_INFO "netconsole: network logging started\n");
 
 	} else {	/* 0 */
+		/* We need to disable the netconsole before cleaning it up
+		 * otherwise we might end up in write_msg() with
+		 * nt->np.dev == NULL and nt->enabled == 1
+		 */
+		spin_lock_irqsave(&target_list_lock, flags);
+		nt->enabled = 0;
+		spin_unlock_irqrestore(&target_list_lock, flags);
 		netpoll_cleanup(&nt->np);
 	}
 
-- 
1.8.1.4
