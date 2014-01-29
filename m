From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/ipv4: Use non-atomic allocation of udp offloads structure instance
Date: Wed, 29 Jan 2014 18:08:59 +0200
Message-ID: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:56606 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752458AbaA2QJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 11:09:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since udp_add_offload() can be called from non-sleepable context e.g
under this call tree from the vxlan driver use case:

  vxlan_socket_create() <-- holds the spinlock
  -> vxlan_notify_add_rx_port()
     -> udp_add_offload()  <-- schedules

we should allocate the udp_offloads structure in atomic manner.

Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/ipv4/udp_offload.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 25f5cee..2ffea6f 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -101,7 +101,7 @@ out:
 int udp_add_offload(struct udp_offload *uo)
 {
 	struct udp_offload_priv __rcu **head = &udp_offload_base;
-	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_KERNEL);
+	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
 
 	if (!new_offload)
 		return -ENOMEM;
-- 
1.7.1
