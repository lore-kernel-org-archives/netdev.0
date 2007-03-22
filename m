From: Patrick McHardy <kaber@trash.net>
Subject: [BRIDGE]: Fix fdb RCU race
Date: Thu, 22 Mar 2007 19:29:09 +0100
Message-ID: <4602CAF5.609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090809080205010504010806"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42309 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964844AbXCVS3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 14:29:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090809080205010504010806
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix what looks like a RCU race. Untested since this is only
used by ATM, which I don't have.


--------------090809080205010504010806
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[BRIDGE]: Fix fdb RCU race

br_fdb_get use atomic_inc to increase the refcount of an element found
on a RCU protected list, which can lead to the following race:

CPU0					CPU1

					br_fdb_get:   rcu_read_lock
					__br_fdb_get: find element
fdb_delete:   hlist_del_rcu
	      br_fdb_put
br_fdb_put:   atomic_dec_and_test
	      call_rcu(fdb_rcu_free)	br_fdb_get:   atomic_inc
						      rcu_read_unlock
fdb_rcu_free: kmem_cache_free

Use atomic_inc_not_zero instead.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6965873e9db0cb3f9a8412bd541a5309dcfb6eb6
tree 152e90dc86fe96ca7cb8f0e280827920ddb62247
parent 8559840c4ca3f2fff73a882803bc8916078fac1f
author Patrick McHardy <kaber@trash.net> Thu, 22 Mar 2007 19:20:08 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 22 Mar 2007 19:20:08 +0100

 net/bridge/br_fdb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index def2e40..8d566c1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -197,8 +197,8 @@ struct net_bridge_fdb_entry *br_fdb_get(struct net_bridge *br,
 
 	rcu_read_lock();
 	fdb = __br_fdb_get(br, addr);
-	if (fdb)
-		atomic_inc(&fdb->use_count);
+	if (fdb && !atomic_inc_not_zero(&fdb->use_count))
+		fdb = NULL;
 	rcu_read_unlock();
 	return fdb;
 }

--------------090809080205010504010806--
