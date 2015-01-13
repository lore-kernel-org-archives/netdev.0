From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 12/12] net: rocker: implement delete flow routine
Date: Tue, 13 Jan 2015 13:40:15 -0800
Message-ID: <20150113214014.13874.27794.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:56189 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbAMVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:40:33 -0500
Received: by mail-oi0-f47.google.com with SMTP id z81so4485292oif.6
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:40:33 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |   46 +++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 8acd730..0b400c4 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4439,7 +4439,51 @@ static int rocker_set_flows(struct net_device *dev,
 static int rocker_del_flows(struct net_device *dev,
 			    struct net_flow_rule *flow)
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
+		if (rocker_goto_value(flow->table_id) != entry->key.tbl_id ||
+		    flow->uid != entry->cookie)
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
+		if (rocker_goto_value(flow->table_id) !=
+			ROCKER_GROUP_TYPE_GET(group->group_id) ||
+		    flow->uid != group->cookie)
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
 
