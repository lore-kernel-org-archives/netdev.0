From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 4/6] openvswitch: Move common genl notify
	code into ovs_notify()
Date: Fri, 29 Mar 2013 14:46:50 +0100
Message-ID: <5b68e87ed56a93f00d070e064991c2fbfb1a097e.1364563347.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1364563346.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1364563346.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1364563346.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 net/openvswitch/datapath.c | 36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 49ee37b..d406503 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -71,6 +71,13 @@ static int ovs_net_id __read_mostly;
 static void rehash_flow_table(struct work_struct *work);
 static DECLARE_DELAYED_WORK(rehash_flow_wq, rehash_flow_table);
 
+static void ovs_notify(struct sk_buff *skb, struct genl_info *info,
+		       struct genl_multicast_group *grp)
+{
+	genl_notify(skb, genl_info_net(info), info->snd_portid,
+		    grp->id, info->nlhdr, GFP_KERNEL);
+}
+
 /**
  * DOC: Locking:
  *
@@ -1061,9 +1068,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (!IS_ERR(reply))
-		genl_notify(reply, genl_info_net(info), info->snd_portid,
-			   ovs_dp_flow_multicast_group.id, info->nlhdr,
-			   GFP_KERNEL);
+		ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
 	else
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
@@ -1150,8 +1155,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_flow_deferred_free(flow);
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_flow_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
 	return 0;
 }
 
@@ -1383,9 +1387,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	list_add_tail(&dp->list_node, &ovs_net->dps);
 	rtnl_unlock();
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
-		    GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 	return 0;
 
 err_destroy_local_port:
@@ -1453,9 +1455,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	__dp_destroy(dp);
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
-		    GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 
 	return 0;
 }
@@ -1479,9 +1479,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		return 0;
 	}
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
-		    GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 
 	return 0;
 }
@@ -1727,8 +1725,8 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		ovs_dp_detach_port(vport);
 		goto exit_unlock;
 	}
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+
+	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
 
 exit_unlock:
 	rtnl_unlock();
@@ -1769,8 +1767,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
 
 exit_unlock:
 	rtnl_unlock();
@@ -1804,8 +1801,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	err = 0;
 	ovs_dp_detach_port(vport);
 
-	genl_notify(reply, genl_info_net(info), info->snd_portid,
-		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
 
 exit_unlock:
 	rtnl_unlock();
-- 
1.7.11.7
