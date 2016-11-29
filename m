From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2] vxlan: fix a potential issue when create a new vxlan fdb entry.
Date: Tue, 29 Nov 2016 09:59:36 +0800
Message-ID: <1480384776-8252-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:24667 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcK2B7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 20:59:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_fdb_append may return error, so add the proper check,
otherwise it will cause memory leak.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Changes in v2:
  - Unnecessary to initialize rc to zero.
---
 drivers/net/vxlan.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 21e92be..bb70dd5 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -611,6 +611,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	struct vxlan_rdst *rd = NULL;
 	struct vxlan_fdb *f;
 	int notify = 0;
+	int rc;
 
 	f = __vxlan_find_mac(vxlan, mac);
 	if (f) {
@@ -641,8 +642,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		if ((flags & NLM_F_APPEND) &&
 		    (is_multicast_ether_addr(f->eth_addr) ||
 		     is_zero_ether_addr(f->eth_addr))) {
-			int rc = vxlan_fdb_append(f, ip, port, vni, ifindex,
-						  &rd);
+			rc = vxlan_fdb_append(f, ip, port, vni, ifindex, &rd);
 
 			if (rc < 0)
 				return rc;
@@ -673,7 +673,11 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		INIT_LIST_HEAD(&f->remotes);
 		memcpy(f->eth_addr, mac, ETH_ALEN);
 
-		vxlan_fdb_append(f, ip, port, vni, ifindex, &rd);
+		rc = vxlan_fdb_append(f, ip, port, vni, ifindex, &rd);
+		if (rc < 0) {
+			kfree(f);
+			return rc;
+		}
 
 		++vxlan->addrcnt;
 		hlist_add_head_rcu(&f->hlist,
-- 
1.8.3.1
