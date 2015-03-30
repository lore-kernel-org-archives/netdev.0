From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] openvswitch: Return vport module ref before destruction
Date: Mon, 30 Mar 2015 13:57:41 +0200
Message-ID: <9cf67a5f127d80bb7db0bd1af1e33505f93e1a01.1427715582.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60601 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbC3L5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 07:57:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return module reference before invoking the respective vport
->destroy() function. This is needed as ovs_vport_del() is not
invoked inside an RCU read side critical section so the kfree
can occur immediately before returning to ovs_vport_del().

Returning the module reference before ->destroy() is safe because
the module unregistration is blocked on ovs_lock which we hold
while destroying the datapath.

Fixes: 62b9c8d0372d ("ovs: Turn vports with dependencies into separate modules")
Reported-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
@Dave: Please also queue for 3.19.x stable series

 net/openvswitch/vport.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index ec2954f..067a3ff 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -274,10 +274,8 @@ void ovs_vport_del(struct vport *vport)
 	ASSERT_OVSL();
 
 	hlist_del_rcu(&vport->hash_node);
-
-	vport->ops->destroy(vport);
-
 	module_put(vport->ops->owner);
+	vport->ops->destroy(vport);
 }
 
 /**
-- 
1.9.3
