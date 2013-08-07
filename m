From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 3.11] genetlink: fix family dump race
Date: Wed,  7 Aug 2013 14:39:23 +0200
Message-ID: <1375879163-2116-1-git-send-email-johannes@sipsolutions.net>
Cc: Andrei Otcheretianski <andrei.otcheretianski@intel.com>,
	Ilan Peer <ilan.peer@intel.com>,
	Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:59259 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433Ab3HGMj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 08:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

When dumping generic netlink families, only the first dump call
is locked with genl_lock(), which protects the list of families,
and thus subsequent calls can access the data without locking,
racing against family addition/removal. This can cause a crash.
Fix it - the locking needs to be conditional because the first
time around it's already locked.

BUG: unable to handle kernel paging request at f8467360
IP: [<c14c56bb>] ctrl_dumpfamily+0x6b/0xe0
EIP: 0060:[<c14c56bb>] EFLAGS: 00210297 CPU: 2
EIP is at ctrl_dumpfamily+0x6b/0xe0
EAX: f8467378 EBX: f8467340 ECX: 00000000 EDX: ec1610c4
ESI: 00000001 EDI: c2077cc0 EBP: c46c3c00 ESP: c46c3bd4
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
CR0: 80050033 CR2: f8467360 CR3: 26e54000 CR4: 001407d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process wpa_supplicant (pid: 20081, ti=c46c2000 task=c44640b0 task.ti=c46c2000)
Call Trace:
 [<c14c20bc>] netlink_dump+0x5c/0x200
 [<c14c3450>] __netlink_dump_start+0x140/0x160
 [<c14c5172>] genl_rcv_msg+0x102/0x270
 [<c14c4b5e>] netlink_rcv_skb+0x8e/0xb0
 [<c14c505c>] genl_rcv+0x1c/0x30
 [<c14c456b>] netlink_unicast+0x17b/0x1c0
 [<c14c47d4>] netlink_sendmsg+0x224/0x370
 [<c1485adf>] sock_sendmsg+0xff/0x120
 [<c1486b0a>] __sys_sendmsg+0x24a/0x260
 [<c1487fdb>] sys_sendmsg+0x3b/0x60
 [<c1488683>] sys_socketcall+0x283/0x2e0
 [<c15b7c1f>] sysenter_do_call+0x12/0x38
Code: 8d 3c c5 c0 7c 07 c2 8b 04 c5 c0 7c 07 c2 39 c7 8d 58 c8 75 16 eb 71 90 81 7d ec 00 1f 86 c1 74 10 8b 43 38 39 c7 8d 58 c8 74 5d <80> 7b 20 00 74 e7 83 c6 01 3b 75 f0 7c e8 8b 55 e8 8b 42 04 8b

Cc: stable@vger.kernel.org
Reported-by: Andrei Otcheretianski <andrei.otcheretianski@intel.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2fd6dbe..6b6a03a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -789,6 +789,10 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
+	bool need_locking = chains_to_skip || fams_to_skip;
+
+	if (need_locking)
+		genl_lock();
 
 	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
@@ -810,6 +814,9 @@ errout:
 	cb->args[0] = i;
 	cb->args[1] = n;
 
+	if (need_locking)
+		genl_unlock();
+
 	return skb->len;
 }
 
-- 
1.8.0
