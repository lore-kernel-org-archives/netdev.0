From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/2] bridge: vlan: Prevent possible use-after-free
Date: Fri, 30 Oct 2015 17:46:19 +0100
Message-ID: <1446223580-1464-2-git-send-email-razor@blackwall.org>
References: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	nikolay@cumulusnetworks.com, idosch@mellanox.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34169 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599AbbJ3QqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:46:24 -0400
Received: by wikq8 with SMTP id q8so14990555wik.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:46:23 -0700 (PDT)
In-Reply-To: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When adding a port to a bridge we initialize VLAN filtering on it. We do
not bail out in case an error occurred in nbp_vlan_init, as it can be
used as a non VLAN filtering bridge.

However, if VLAN filtering is required and an error occurred in
nbp_vlan_init, we should set vlgrp to NULL, so that VLAN filtering
functions (e.g. br_vlan_find, br_get_pvid) will know the struct is
invalid and will not try to access it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f0d0cc4744f..1054696323d7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -914,6 +914,8 @@ out:
 	return ret;
 
 err_vlan_add:
+	RCU_INIT_POINTER(p->vlgrp, NULL);
+	synchronize_rcu();
 	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
 	kfree(vg);
-- 
2.4.3
