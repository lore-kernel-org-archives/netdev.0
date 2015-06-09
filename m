From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: make br_fdb_delete also check if the port matches
Date: Tue,  9 Jun 2015 03:34:13 -0700
Message-ID: <1433846053-16390-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33510 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbbFIKeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 06:34:24 -0400
Received: by qkhg32 with SMTP id g32so6836674qkh.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 03:34:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch the user-specified bridge port was ignored when
deleting an fdb entry and thus one could delete an entry that belonged
to any port.
Example (eth0 and eth1 are br0 ports):
bridge fdb add 00:11:22:33:44:55 dev eth0 master
bridge fdb del 00:11:22:33:44:55 dev eth1 master
(succeeds)

after the patch:
bridge fdb add 00:11:22:33:44:55 dev eth0 master
bridge fdb del 00:11:22:33:44:55 dev eth1 master
RTNETLINK answers: No such file or directory

Based on a patch by Wilson Kok.

Reported-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Note: Sending this for net-next since it changes user-visible behaviour and
      could potentially break someone's setup which relies on it.
      If this is not acceptable, we could add a new flag which specifies
      that it's an exact delete and thus leave the behaviour as it was
      before the patch.

 net/bridge/br_fdb.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index cecb482ed919..13949a71591d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -873,13 +873,15 @@ out:
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vlan)
+static int fdb_delete_by_addr_and_port(struct net_bridge_port *p,
+				       const u8 *addr, u16 vlan)
 {
+	struct net_bridge *br = p->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
 
 	fdb = fdb_find(head, addr, vlan);
-	if (!fdb)
+	if (!fdb || fdb->dst != p)
 		return -ENOENT;
 
 	fdb_delete(br, fdb);
@@ -892,7 +894,7 @@ static int __br_fdb_delete(struct net_bridge_port *p,
 	int err;
 
 	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr(p->br, addr, vid);
+	err = fdb_delete_by_addr_and_port(p, addr, vid);
 	spin_unlock_bh(&p->br->hash_lock);
 
 	return err;
-- 
2.1.0
