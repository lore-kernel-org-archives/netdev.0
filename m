From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 12/12] net: rocker: implement delete flow routine
Date: Tue, 20 Jan 2015 12:31:33 -0800
Message-ID: <20150120203131.1741.52435.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:64008 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbATUbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:31:53 -0500
Received: by mail-ob0-f176.google.com with SMTP id va2so12350752obc.7
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:31:53 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |   46 +++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 3ceb313..ba48e88 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4436,7 +4436,51 @@ static int rocker_set_rules(struct net_device *dev,
 static int rocker_del_rules(struct net_device *dev,
 			    struct net_flow_rule *rule)
 {
-	return -EOPNOTSUPP;
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_flow_tbl_entry *entry;
+	struct rocker_group_tbl_entry *group;
+	struct hlist_node *tmp;
+	int bkt, err = -EEXIST;
+	unsigned long flags;
+
+	spin_lock_irqsave(&rocker_port->rocker->flow_tbl_lock, flags);
+	hash_for_each_safe(rocker_port->rocker->flow_tbl,
+			   bkt, tmp, entry, entry) {
+		if (rocker_goto_value(rule->table_id) != entry->key.tbl_id ||
+		    rule->uid != entry->cookie)
+			continue;
+
+		hash_del(&entry->entry);
+		err = 0;
+		break;
+	}
+	spin_unlock_irqrestore(&rocker_port->rocker->flow_tbl_lock, flags);
+
+	if (!err)
+		goto done;
+
+	spin_lock_irqsave(&rocker_port->rocker->group_tbl_lock, flags);
+	hash_for_each_safe(rocker_port->rocker->group_tbl,
+			   bkt, tmp, group, entry) {
+		if (rocker_goto_value(rule->table_id) !=
+			ROCKER_GROUP_TYPE_GET(group->group_id) ||
+		    rule->uid != group->cookie)
+			continue;
+
+		hash_del(&group->entry);
+		err = 0;
+		break;
+	}
+	spin_unlock_irqrestore(&rocker_port->rocker->group_tbl_lock, flags);
+
+done:
+	if (!err) {
+		err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
+				      rocker_cmd_flow_tbl_del,
+				      entry, NULL, NULL, true);
+		kfree(entry);
+	}
+	return err;
 }
 #endif
 
