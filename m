From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net] tipc: fix missing spinlock init in broadcast code
Date: Thu, 14 Feb 2013 19:43:33 -0500
Message-ID: <1360889013-4394-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62787 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759774Ab3BOAnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

After commit 3c294cb3 "tipc: remove the bearer congestion mechanism",
we try to grab the broadcast bearer lock when sending multicast
messages over the broadcast link. This will cause an oops because
the lock is never initialized. This is an old bug, but the lock
was never actually used before commit 3c294cb3, so that why it was
not visible until now.  The oops will look something like:

	BUG: spinlock bad magic on CPU#2, daemon/147
	lock: bcast_bearer+0x48/0xffffffffffffd19a [tipc],
	.magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
	Pid: 147, comm: daemon Not tainted 3.8.0-rc3+ #206
	Call Trace:
	spin_dump+0x8a/0x8f
	spin_bug+0x21/0x26
	do_raw_spin_lock+0x114/0x150
	_raw_spin_lock_bh+0x19/0x20
	tipc_bearer_blocked+0x1f/0x40 [tipc]
	tipc_link_send_buf+0x82/0x280 [tipc]
	? __alloc_skb+0x9f/0x2b0
	tipc_bclink_send_msg+0x77/0xa0 [tipc]
	tipc_multicast+0x11b/0x1b0 [tipc]
	send_msg+0x225/0x530 [tipc]
	sock_sendmsg+0xca/0xe0

The above can be triggered by running the multicast demo program.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[PG: I've marked this as "net" since git describe --contains 3c294cb3
gives v3.8-rc1~139^2~242^2~5 --- i.e. the now closing 3.8 dev cycle.]

 net/tipc/bcast.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 54f89f9..2655c9f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -774,6 +774,7 @@ void tipc_bclink_init(void)
 	bcl->owner = &bclink->node;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
+	spin_lock_init(&bcbearer->bearer.lock);
 	bcl->b_ptr = &bcbearer->bearer;
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
-- 
1.8.1.2
