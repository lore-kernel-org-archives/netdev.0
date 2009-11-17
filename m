From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: Fix register_vlan_dev() error path
Date: Tue, 17 Nov 2009 15:41:26 +0100
Message-ID: <4B02B616.3020801@gmail.com>
References: <4B01558F.5000306@gmail.com> <20091117.002037.229474882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42100 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZKQOlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 09:41:24 -0500
In-Reply-To: <20091117.002037.229474882.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

> Eric, please make allocation failure cause the vlan_setup()
> to fail and propagate -EFAULT back to the caller.

Sure ! (You meant -ENOMEM probably...)

While testing my new patch in OOM situations, I found following bug
in vlan code, that gave me crashes or infinite loops.


[PATCH] vlan: Fix register_vlan_dev() error path

In case register_netdevice() returns an error, and a new vlan_group was
allocated and inserted in vlan_group_hash[] we call vlan_group_free() w=
ithout
deleting group from hash table. Future lookups can give infinite loops =
or crashes.

We must delete the vlan_group using RCU safe procedure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8836575..a29c5ab 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -281,8 +281,11 @@ out_uninit_applicant:
 	if (ngrp)
 		vlan_gvrp_uninit_applicant(real_dev);
 out_free_group:
-	if (ngrp)
-		vlan_group_free(ngrp);
+	if (ngrp) {
+		hlist_del_rcu(&ngrp->hlist);
+		/* Free the group, after all cpu's are done. */
+		call_rcu(&ngrp->rcu, vlan_rcu_free);
+	}
 	return err;
 }
=20
