From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: mdb: fix double add notification
Date: Mon, 13 Jul 2015 06:36:19 -0700
Message-ID: <1436794579-4188-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, amwang@redhat.com,
	davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35842 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbbGMNga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 09:36:30 -0400
Received: by pachj5 with SMTP id hj5so32404495pac.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 06:36:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the mdb add/del code was introduced there have been 2 br_mdb_notify
calls when doing br_mdb_add() resulting in 2 notifications on each add.

Example:
 Command: bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
 Before patch:
 root@debian:~# bridge monitor all
 [MDB]dev br0 port eth1 grp 239.0.0.1 permanent
 [MDB]dev br0 port eth1 grp 239.0.0.1 permanent

 After patch:
 root@debian:~# bridge monitor all
 [MDB]dev br0 port eth1 grp 239.0.0.1 permanent

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: cfd567543590 ("bridge: add support of adding and deleting mdb entries")
---
 net/bridge/br_mdb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index c11cf2611db0..1198a3dbad95 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -351,7 +351,6 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	if (state == MDB_TEMPORARY)
 		mod_timer(&p->timer, now + br->multicast_membership_interval);
 
-	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 	return 0;
 }
 
-- 
1.9.1
