From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2] l2tp: fix use-after-free during module unload
Date: Fri,  2 Sep 2016 10:22:54 +0200
Message-ID: <996e12b7faf7fd20ba9c0c76614fd5bb4a3d70c4.1472804437.git.sd@queasysnail.net>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60396 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752131AbcIBIXB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 04:23:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnel deletion is delayed by both a workqueue (l2tp_tunnel_delete -> wq
 -> l2tp_tunnel_del_work) and RCU (sk_destruct -> RCU ->
l2tp_tunnel_destruct).

By the time l2tp_tunnel_destruct() runs to destroy the tunnel and finish
destroying the socket, the private data reserved via the net_generic
mechanism has already been freed, but l2tp_tunnel_destruct() actually
uses this data.

Make sure tunnel deletion for the netns has completed before returning
from l2tp_exit_net() by first flushing the tunnel removal workqueue, and
then waiting for RCU callbacks to complete.

Fixes: 167eb17e0b17 ("l2tp: create tunnel sockets in the right namespace")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
v2: fix typo in commit message, spotted by Sergei Shtylyov

 net/l2tp/l2tp_core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1e40dacaa137..a2ed3bda4ddc 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1855,6 +1855,9 @@ static __net_exit void l2tp_exit_net(struct net *net)
 		(void)l2tp_tunnel_delete(tunnel);
 	}
 	rcu_read_unlock_bh();
+
+	flush_workqueue(l2tp_wq);
+	rcu_barrier();
 }
 
 static struct pernet_operations l2tp_net_ops = {
-- 
2.9.3
