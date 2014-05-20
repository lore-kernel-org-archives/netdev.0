From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 06/13] openvswitch: Minimize dp and vport
	critical sections.
Date: Tue, 20 May 2014 02:00:19 -0700
Message-ID: <1400576419-2348-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Move most memory allocations away from the ovs_mutex critical
sections.  vport allocations still happen while the lock is taken, as
changing that would require major refactoring. Also, vports are
created very rarely so it should not matter.

Change ovs_dp_cmd_get() now only takes the rcu_read_lock(), rather
than ovs_lock(), as nothing need to be changed.  This was done by
ovs_vport_cmd_get() already.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 218 +++++++++++++++++++++++----------------------
 1 file changed, 110 insertions(+), 108 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index cb5d64a..f3bcdac 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1164,23 +1164,9 @@ error:
 	return -EMSGSIZE;
 }
 
-/* Must be called with ovs_mutex. */
-static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp,
-					     struct genl_info *info, u8 cmd)
+static struct sk_buff *ovs_dp_cmd_alloc_info(struct genl_info *info)
 {
-	struct sk_buff *skb;
-	int retval;
-
-	skb = genlmsg_new_unicast(ovs_dp_cmd_msg_size(), info, GFP_KERNEL);
-	if (!skb)
-		return ERR_PTR(-ENOMEM);
-
-	retval = ovs_dp_cmd_fill_info(dp, skb, info->snd_portid, info->snd_seq, 0, cmd);
-	if (retval < 0) {
-		kfree_skb(skb);
-		return ERR_PTR(retval);
-	}
-	return skb;
+	return genlmsg_new_unicast(ovs_dp_cmd_msg_size(), info, GFP_KERNEL);
 }
 
 /* Called with rcu_read_lock or ovs_mutex. */
@@ -1233,12 +1219,14 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
 		goto err;
 
-	ovs_lock();
+	reply = ovs_dp_cmd_alloc_info(info);
+	if (!reply)
+		return -ENOMEM;
 
 	err = -ENOMEM;
 	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
 	if (dp == NULL)
-		goto err_unlock_ovs;
+		goto err_free_reply;
 
 	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
@@ -1273,6 +1261,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_dp_change(dp, a);
 
+	/* So far only local changes have been made, now need the lock. */
+	ovs_lock();
+
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
@@ -1291,10 +1282,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_ports_array;
 	}
 
-	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
-	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto err_destroy_local_port;
+	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
+				   info->snd_seq, 0, OVS_DP_CMD_NEW);
+	BUG_ON(err < 0);
 
 	ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
 	list_add_tail_rcu(&dp->list_node, &ovs_net->dps);
@@ -1304,9 +1294,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	ovs_notify(&dp_datapath_genl_family, reply, info);
 	return 0;
 
-err_destroy_local_port:
-	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 err_destroy_ports_array:
+	ovs_unlock();
 	kfree(dp->ports);
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
@@ -1315,8 +1304,8 @@ err_destroy_table:
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
-err_unlock_ovs:
-	ovs_unlock();
+err_free_reply:
+	kfree_skb(reply);
 err:
 	return err;
 }
@@ -1354,16 +1343,19 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
+	reply = ovs_dp_cmd_alloc_info(info);
+	if (!reply)
+		return -ENOMEM;
+
 	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	err = PTR_ERR(dp);
 	if (IS_ERR(dp))
-		goto unlock;
+		goto err_unlock_free;
 
-	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_DEL);
-	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto unlock;
+	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
+				   info->snd_seq, 0, OVS_DP_CMD_DEL);
+	BUG_ON(err < 0);
 
 	__dp_destroy(dp);
 	ovs_unlock();
@@ -1371,8 +1363,10 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_notify(&dp_datapath_genl_family, reply, info);
 
 	return 0;
-unlock:
+
+err_unlock_free:
 	ovs_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1382,29 +1376,30 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
+	reply = ovs_dp_cmd_alloc_info(info);
+	if (!reply)
+		return -ENOMEM;
+
 	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	err = PTR_ERR(dp);
 	if (IS_ERR(dp))
-		goto unlock;
+		goto err_unlock_free;
 
 	ovs_dp_change(dp, info->attrs);
 
-	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
-	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
-		genl_set_err(&dp_datapath_genl_family, sock_net(skb->sk), 0,
-			     0, err);
-		err = 0;
-		goto unlock;
-	}
+	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
+				   info->snd_seq, 0, OVS_DP_CMD_NEW);
+	BUG_ON(err < 0);
 
 	ovs_unlock();
 	ovs_notify(&dp_datapath_genl_family, reply, info);
 
 	return 0;
-unlock:
+
+err_unlock_free:
 	ovs_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1414,24 +1409,26 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
-	ovs_lock();
+	reply = ovs_dp_cmd_alloc_info(info);
+	if (!reply)
+		return -ENOMEM;
+
+	rcu_read_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	if (IS_ERR(dp)) {
 		err = PTR_ERR(dp);
-		goto unlock;
-	}
-
-	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
-	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
-		goto unlock;
+		goto err_unlock_free;
 	}
+	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
+				   info->snd_seq, 0, OVS_DP_CMD_NEW);
+	BUG_ON(err < 0);
+	rcu_read_unlock();
 
-	ovs_unlock();
 	return genlmsg_reply(reply, info);
 
-unlock:
-	ovs_unlock();
+err_unlock_free:
+	rcu_read_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1544,7 +1541,12 @@ error:
 	return err;
 }
 
-/* Called with ovs_mutex or RCU read lock. */
+static struct sk_buff *ovs_vport_cmd_alloc_info(void)
+{
+	return nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+}
+
+/* Called with ovs_mutex, only via ovs_dp_notify_wq(). */
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 					 u32 seq, u8 cmd)
 {
@@ -1606,33 +1608,35 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	u32 port_no;
 	int err;
 
-	err = -EINVAL;
 	if (!a[OVS_VPORT_ATTR_NAME] || !a[OVS_VPORT_ATTR_TYPE] ||
 	    !a[OVS_VPORT_ATTR_UPCALL_PID])
-		goto exit;
+		return -EINVAL;
+
+	port_no = a[OVS_VPORT_ATTR_PORT_NO]
+		? nla_get_u32(a[OVS_VPORT_ATTR_PORT_NO]) : 0;
+	if (port_no >= DP_MAX_PORTS)
+		return -EFBIG;
+
+	reply = ovs_vport_cmd_alloc_info();
+	if (!reply)
+		return -ENOMEM;
 
 	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
-		goto exit_unlock;
-
-	if (a[OVS_VPORT_ATTR_PORT_NO]) {
-		port_no = nla_get_u32(a[OVS_VPORT_ATTR_PORT_NO]);
-
-		err = -EFBIG;
-		if (port_no >= DP_MAX_PORTS)
-			goto exit_unlock;
+		goto exit_unlock_free;
 
+	if (port_no) {
 		vport = ovs_vport_ovsl(dp, port_no);
 		err = -EBUSY;
 		if (vport)
-			goto exit_unlock;
+			goto exit_unlock_free;
 	} else {
 		for (port_no = 1; ; port_no++) {
 			if (port_no >= DP_MAX_PORTS) {
 				err = -EFBIG;
-				goto exit_unlock;
+				goto exit_unlock_free;
 			}
 			vport = ovs_vport_ovsl(dp, port_no);
 			if (!vport)
@@ -1650,22 +1654,19 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	vport = new_vport(&parms);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
-		goto exit_unlock;
+		goto exit_unlock_free;
 
-	err = 0;
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
-					 OVS_VPORT_CMD_NEW);
-	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
-		ovs_dp_detach_port(vport);
-		goto exit_unlock;
-	}
+	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
+				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
+	BUG_ON(err < 0);
+	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, reply, info);
+	return 0;
 
-exit_unlock:
+exit_unlock_free:
 	ovs_unlock();
-exit:
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1676,28 +1677,26 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	int err;
 
+	reply = ovs_vport_cmd_alloc_info();
+	if (!reply)
+		return -ENOMEM;
+
 	ovs_lock();
 	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
-		goto exit_unlock;
+		goto exit_unlock_free;
 
 	if (a[OVS_VPORT_ATTR_TYPE] &&
 	    nla_get_u32(a[OVS_VPORT_ATTR_TYPE]) != vport->ops->type) {
 		err = -EINVAL;
-		goto exit_unlock;
-	}
-
-	reply = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!reply) {
-		err = -ENOMEM;
-		goto exit_unlock;
+		goto exit_unlock_free;
 	}
 
 	if (a[OVS_VPORT_ATTR_OPTIONS]) {
 		err = ovs_vport_set_options(vport, a[OVS_VPORT_ATTR_OPTIONS]);
 		if (err)
-			goto exit_free;
+			goto exit_unlock_free;
 	}
 
 	if (a[OVS_VPORT_ATTR_UPCALL_PID])
@@ -1711,10 +1710,9 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	ovs_notify(&dp_vport_genl_family, reply, info);
 	return 0;
 
-exit_free:
-	kfree_skb(reply);
-exit_unlock:
+exit_unlock_free:
 	ovs_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1725,30 +1723,33 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	int err;
 
+	reply = ovs_vport_cmd_alloc_info();
+	if (!reply)
+		return -ENOMEM;
+
 	ovs_lock();
 	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
-		goto exit_unlock;
+		goto exit_unlock_free;
 
 	if (vport->port_no == OVSP_LOCAL) {
 		err = -EINVAL;
-		goto exit_unlock;
+		goto exit_unlock_free;
 	}
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid,
-					 info->snd_seq, OVS_VPORT_CMD_DEL);
-	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto exit_unlock;
-
-	err = 0;
+	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
+				      info->snd_seq, 0, OVS_VPORT_CMD_DEL);
+	BUG_ON(err < 0);
 	ovs_dp_detach_port(vport);
+	ovs_unlock();
 
 	ovs_notify(&dp_vport_genl_family, reply, info);
+	return 0;
 
-exit_unlock:
+exit_unlock_free:
 	ovs_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
@@ -1760,24 +1761,25 @@ static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	int err;
 
+	reply = ovs_vport_cmd_alloc_info();
+	if (!reply)
+		return -ENOMEM;
+
 	rcu_read_lock();
 	vport = lookup_vport(sock_net(skb->sk), ovs_header, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
-		goto exit_unlock;
-
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid,
-					 info->snd_seq, OVS_VPORT_CMD_NEW);
-	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto exit_unlock;
-
+		goto exit_unlock_free;
+	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
+				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
+	BUG_ON(err < 0);
 	rcu_read_unlock();
 
 	return genlmsg_reply(reply, info);
 
-exit_unlock:
+exit_unlock_free:
 	rcu_read_unlock();
+	kfree_skb(reply);
 	return err;
 }
 
-- 
1.9.0
