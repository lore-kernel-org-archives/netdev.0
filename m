From: Ben Pfaff <blp@nicira.com>
Subject: deadlink in genetlink?
Date: Mon, 24 Sep 2007 12:46:22 -0700
Message-ID: <87y7evzw1d.fsf@blp.benpfaff.org>
Reply-To: Ben Pfaff <blp@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.lnh.mail.rcn.net ([207.172.157.102]:36899 "EHLO
	smtp02.lnh.mail.rcn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757381AbXIXTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 15:55:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Sorry about the duplicate mail, Thomas: I got the netdev address
wrong on the first try.]

lockdep reported a circular dependency between cb_mutex and
genl_mutex, as follows:

-> #1 (nlk->cb_mutex){--..}:
       [<c0127b5d>] __lock_acquire+0x9c8/0xb98
       [<c01280f6>] lock_acquire+0x5d/0x75
       [<c027adc1>] __mutex_lock_slowpath+0xdb/0x247
       [<c027af49>] mutex_lock+0x1c/0x1f
       [<c0236aa0>] netlink_dump_start+0xa9/0x12f
          ---> takes cb_mutex
       [<c0237fa6>] genl_rcv_msg+0xa3/0x14c
       [<c0235aa5>] netlink_run_queue+0x6f/0xe1
       [<c0237772>] genl_rcv+0x2d/0x4e
          ---> trylocks genl_mutex
       [<c0235ef0>] netlink_data_ready+0x15/0x55
       [<c0234e98>] netlink_sendskb+0x1f/0x36
       [<c0235772>] netlink_unicast+0x1a6/0x1c0
       [<c0235ecf>] netlink_sendmsg+0x238/0x244
       [<c021a92e>] sock_sendmsg+0xcb/0xe4
       [<c021aa98>] sys_sendmsg+0x151/0x1af
       [<c021b850>] sys_socketcall+0x203/0x222
       [<c01025d2>] syscall_call+0x7/0xb
       [<ffffffff>] 0xffffffff

-> #0 (genl_mutex){--..}:
       [<c0127a46>] __lock_acquire+0x8b1/0xb98
       [<c01280f6>] lock_acquire+0x5d/0x75
       [<c027adc1>] __mutex_lock_slowpath+0xdb/0x247
       [<c027af49>] mutex_lock+0x1c/0x1f
       [<c023717d>] genl_lock+0xd/0xf
       [<c023806f>] ctrl_dumpfamily+0x20/0xdd
          ---> takes genl_mutex
       [<c0234bfa>] netlink_dump+0x50/0x168
          ---> takes cb_mutex
       [<c02360f2>] netlink_recvmsg+0x15f/0x22f
       [<c021a84a>] sock_recvmsg+0xd5/0xee
       [<c021b24e>] sys_recvmsg+0xf5/0x187
       [<c021b865>] sys_socketcall+0x218/0x222
       [<c01025d2>] syscall_call+0x7/0xb
       [<ffffffff>] 0xffffffff

The "trylock" in genl_rcv doesn't prevent the deadlock, because
it's not the last lock acquired.  Perhaps this can be fixed by
not acquiring the genl_mutex in ctrl_dumpfamily; it silences
lockdep, at least.  It is not clear to me what the value of
taking the mutex is there.

If this is an appropriate fix, here is a patch for it.

Signed-off-by: Ben Pfaff <blp@nicira.com>

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 8c11ca4..2e79035 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -616,9 +616,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
-	if (chains_to_skip != 0)
-		genl_lock();
-
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
 			continue;
@@ -636,9 +633,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 errout:
-	if (chains_to_skip != 0)
-		genl_unlock();
-
 	cb->args[0] = i;
 	cb->args[1] = n;
 

-- 
Ben Pfaff
Nicira Networks, Inc.
