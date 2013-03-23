From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] 8021q: fix a potential use-after-free
Date: Sat, 23 Mar 2013 13:14:07 +0800
Message-ID: <1364015648-4195-1-git-send-email-amwang@redhat.com>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536Ab3CWFOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Mar 2013 01:14:23 -0400
In-Reply-To: <1363938600-26129-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

vlan_vid_del() could possibly free ->vlan_info after a RCU grace
period, however, we may still refer to the freed memory area
by 'grp' pointer. Found by code inspection.

This patch moves vlan_vid_del() as behind as possible.

Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/8021q/vlan.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a187144..85addcd 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -86,13 +86,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	grp = &vlan_info->grp;
 
-	/* Take it out of our own structures, but be sure to interlock with
-	 * HW accelerating devices or SW vlan input packet processing if
-	 * VLAN is not 0 (leave it there for 802.1p).
-	 */
-	if (vlan_id)
-		vlan_vid_del(real_dev, vlan_id);
-
 	grp->nr_vlan_devs--;
 
 	if (vlan->flags & VLAN_FLAG_MVRP)
@@ -114,6 +107,13 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		vlan_gvrp_uninit_applicant(real_dev);
 	}
 
+	/* Take it out of our own structures, but be sure to interlock with
+	 * HW accelerating devices or SW vlan input packet processing if
+	 * VLAN is not 0 (leave it there for 802.1p).
+	 */
+	if (vlan_id)
+		vlan_vid_del(real_dev, vlan_id);
+
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
 }
-- 
1.7.7.6
