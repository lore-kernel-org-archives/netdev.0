From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 25/27] vlan: unlink the upper neighbour before unregistering
Date: Wed, 25 Sep 2013 09:20:30 +0200
Message-ID: <1380093632-1842-26-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604Ab3IYHVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:12 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On netdev unregister we're removing also all of its sysfs-associated stuff,
including the sysfs symlinks that are controlled by netdev neighbour code.
Also, it's a subtle race condition - cause we can still access it after
unregistering.

Move the unlinking right before the unregistering to fix both.

CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v2:
    New patch.

 net/8021q/vlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 69b4a35..b3d17d1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -98,14 +98,14 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		vlan_gvrp_request_leave(dev);
 
 	vlan_group_set_device(grp, vlan->vlan_proto, vlan_id, NULL);
+
+	netdev_upper_dev_unlink(real_dev, dev);
 	/* Because unregister_netdevice_queue() makes sure at least one rcu
 	 * grace period is respected before device freeing,
 	 * we dont need to call synchronize_net() here.
 	 */
 	unregister_netdevice_queue(dev, head);
 
-	netdev_upper_dev_unlink(real_dev, dev);
-
 	if (grp->nr_vlan_devs == 0) {
 		vlan_mvrp_uninit_applicant(real_dev);
 		vlan_gvrp_uninit_applicant(real_dev);
-- 
1.8.4
