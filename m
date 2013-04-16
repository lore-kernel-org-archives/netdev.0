From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 1/2] openvswitch: Preallocate reply skb in ovs_vport_cmd_set().
Date: Tue, 16 Apr 2013 13:17:28 -0700
Message-ID: <1366143449-8605-2-git-send-email-jesse@nicira.com>
References: <1366143449-8605-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:59222 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S936118Ab3DPURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:17:24 -0400
Received: by mail-pd0-f200.google.com with SMTP id w11so701751pde.11
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 13:17:24 -0700 (PDT)
In-Reply-To: <1366143449-8605-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocation of the Netlink notification skb can potentially fail
after changing vport configuration.  In general, we try to avoid
this by undoing any change we made but that is difficult for existing
objects.  This avoids the problem by preallocating the buffer (which
is fixed size).

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c |   30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index a4b7247..6980c3e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1593,10 +1593,8 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 		return ERR_PTR(-ENOMEM);
 
 	retval = ovs_vport_cmd_fill_info(vport, skb, portid, seq, 0, cmd);
-	if (retval < 0) {
-		kfree_skb(skb);
-		return ERR_PTR(retval);
-	}
+	BUG_ON(retval < 0);
+
 	return skb;
 }
 
@@ -1726,24 +1724,32 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	    nla_get_u32(a[OVS_VPORT_ATTR_TYPE]) != vport->ops->type)
 		err = -EINVAL;
 
+	reply = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!reply) {
+		err = -ENOMEM;
+		goto exit_unlock;
+	}
+
 	if (!err && a[OVS_VPORT_ATTR_OPTIONS])
 		err = ovs_vport_set_options(vport, a[OVS_VPORT_ATTR_OPTIONS]);
 	if (err)
-		goto exit_unlock;
+		goto exit_free;
+
 	if (a[OVS_VPORT_ATTR_UPCALL_PID])
 		vport->upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
-					 OVS_VPORT_CMD_NEW);
-	if (IS_ERR(reply)) {
-		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
-				ovs_dp_vport_multicast_group.id, PTR_ERR(reply));
-		goto exit_unlock;
-	}
+	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
+				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
+	BUG_ON(err < 0);
 
 	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
 
+	rtnl_unlock();
+	return 0;
+
+exit_free:
+	kfree_skb(reply);
 exit_unlock:
 	rtnl_unlock();
 	return err;
-- 
1.7.10.4
