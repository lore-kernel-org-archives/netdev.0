From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] bridge: disable softirqs around br_fdb_update to avoid lockup
Date: Sat,  6 Jun 2015 06:49:00 -0700
Message-ID: <1433598540-13814-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1433490777-22880-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:34775 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932463AbbFFNtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 09:49:10 -0400
Received: by qcej9 with SMTP id j9so38611371qce.1
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 06:49:09 -0700 (PDT)
In-Reply-To: <1433490777-22880-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_update() can be called in process context in the following way:
br_fdb_add() -> __br_fdb_add() -> br_fdb_update() (if NTF_USE flag is set)
so we need to disable softirqs because there are softirq users of the
hash_lock. One easy way to reproduce this is to modify the bridge utility
to set NTF_USE, enable stp and then set maxageing to a low value so
br_fdb_cleanup() is called frequently and then just add new entries in
a loop. This happens because br_fdb_cleanup() is called from timer/softirq
context. The spin locks in br_fdb_update were _bh before commit f8ae737deea1
("[BRIDGE]: forwarding remove unneeded preempt and bh diasables")
and at the time that commit was correct because br_fdb_update() couldn't be
called from process context, but that changed after commit:
292d1398983f ("bridge: add NTF_USE support")
Using local_bh_disable/enable around br_fdb_update() allows us to keep
using the spin_lock/unlock in br_fdb_update for the fast-path.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: 292d1398983f ("bridge: add NTF_USE support")
---
v2: new patch, uses local_bh_disable/enable instead of _bh variant
    of spinlocks to keep the fast-path optimization. Please drop
    "bridge: use _bh spinlock variant for br_fdb_update to avoid lockup"
    in favor of this one.

 net/bridge/br_fdb.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e0670d7054f9..659fb96672e4 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -796,9 +796,11 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
 	int err = 0;
 
 	if (ndm->ndm_flags & NTF_USE) {
+		local_bh_disable();
 		rcu_read_lock();
 		br_fdb_update(p->br, p, addr, vid, true);
 		rcu_read_unlock();
+		local_bh_enable();
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
 		err = fdb_add_entry(p, addr, ndm->ndm_state,
-- 
1.7.10.4
