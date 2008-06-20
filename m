From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 4/8] bridge: sysfs cleanup
Date: Fri, 20 Jun 2008 08:55:15 +0800
Message-ID: <485AFFF3.6070802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65385 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754424AbYFTA7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I am doing this series of patch, I notice that bridge's sysfs are
not cleanuped after failure and bridge delete.

Here is the patch for it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/bridge/br_if.c       |    2 ++
 net/bridge/br_sysfs_if.c |    9 ++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 49dd433..4b730fa 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -161,6 +161,7 @@ static void del_br(struct net_bridge *br)
 	struct net_bridge_port *p, *n;
 
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
+		br_sysfs_removeif(p);
 		del_nbp(p);
 	}
 
@@ -435,6 +436,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	br_sysfs_removeif(p);
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 7f80462..9e9d17c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -226,10 +226,17 @@ int br_sysfs_addif(struct net_bridge_port *p)
 	for (a = brport_attrs; *a; ++a) {
 		err = sysfs_create_file(&p->kobj, &((*a)->attr));
 		if (err)
-			goto out2;
+			goto out1;
 	}
 
 	err = sysfs_create_link(br->ifobj, &p->kobj, p->dev->name);
+	if (err)
+		goto out1;
+	return 0;
+out1:
+	for (a = brport_attrs; *a; ++a)
+		sysfs_remove_file(&p->kobj, &((*a)->attr));
+	sysfs_remove_link(&br->dev->dev.kobj, SYSFS_BRIDGE_PORT_LINK);
 out2:
 	return err;
 }
-- 
1.5.3.4



