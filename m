From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC 6/7] genetlink: Add allocation flag to genlmsg_unicast()
Date: Wed,  6 Jul 2016 09:28:35 +0900
Message-ID: <1467764916-4983-7-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/gtp.c                     | 3 ++-
 drivers/net/team/team.c               | 5 +++--
 drivers/net/wireless/mac80211_hwsim.c | 2 +-
 fs/dlm/netlink.c                      | 2 +-
 include/net/genetlink.h               | 8 +++++---
 kernel/taskstats.c                    | 2 +-
 net/hsr/hsr_netlink.c                 | 6 ++++--
 net/l2tp/l2tp_netlink.c               | 8 +++++---
 net/openvswitch/datapath.c            | 3 ++-
 net/tipc/netlink_compat.c             | 2 +-
 net/wireless/nl80211.c                | 9 +++++----
 11 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 97e0cbc..0156abb 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1210,7 +1210,8 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_free;
 
 	rcu_read_unlock();
-	return genlmsg_unicast(genl_info_net(info), skb2, info->snd_portid);
+	return genlmsg_unicast(genl_info_net(info), skb2, info->snd_portid,
+			       GFP_ATOMIC);
 
 err_unlock_free:
 	kfree_skb(skb2);
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f9eebea..3d40b55 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2194,7 +2194,8 @@ static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid,
+			       GFP_KERNEL);
 
 err_msg_put:
 	nlmsg_free(msg);
@@ -2240,7 +2241,7 @@ typedef int team_nl_send_func_t(struct sk_buff *skb,
 
 static int team_nl_send_unicast(struct sk_buff *skb, struct team *team, u32 portid)
 {
-	return genlmsg_unicast(dev_net(team->dev), skb, portid);
+	return genlmsg_unicast(dev_net(team->dev), skb, portid, gfp_any());
 }
 
 static int team_nl_fill_one_option_get(struct sk_buff *skb, struct team *team,
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 382109bb..5c7bf77 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1008,7 +1008,7 @@ static int hwsim_unicast_netgroup(struct mac80211_hwsim_data *data,
 	rcu_read_lock();
 	for_each_net_rcu(net) {
 		if (data->netgroup == hwsim_net_get_netgroup(net)) {
-			res = genlmsg_unicast(net, skb, portid);
+			res = genlmsg_unicast(net, skb, portid, GFP_ATOMIC);
 			found = true;
 			break;
 		}
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 1e6e227..c498616 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -59,7 +59,7 @@ static int send_data(struct sk_buff *skb)
 
 	genlmsg_end(skb, data);
 
-	return genlmsg_unicast(&init_net, skb, listener_nlportid);
+	return genlmsg_unicast(&init_net, skb, listener_nlportid, GFP_NOFS);
 }
 
 static int user_cmd(struct sk_buff *skb, struct genl_info *info)
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index b107a35..5f0f2ff 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -331,10 +331,12 @@ int genlmsg_multicast_allns(struct genl_family *family,
  * genlmsg_unicast - unicast a netlink message
  * @skb: netlink message as socket buffer
  * @portid: netlink portid of the destination socket
+ * @flags: allocation flags
  */
-static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 portid)
+static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb,
+				  u32 portid, gfp_t flags)
 {
-	return nlmsg_unicast(net->genl_sock, skb, portid, 0);
+	return nlmsg_unicast(net->genl_sock, skb, portid, flags);
 }
 
 /**
@@ -344,7 +346,7 @@ static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 port
  */
 static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
 {
-	return genlmsg_unicast(genl_info_net(info), skb, info->snd_portid);
+	return genlmsg_unicast(genl_info_net(info), skb, info->snd_portid, 0);
 }
 
 /**
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index b3f05ee..ecfcaff 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -140,7 +140,7 @@ static void send_cpu_listeners(struct sk_buff *skb,
 			if (!skb_next)
 				break;
 		}
-		rc = genlmsg_unicast(&init_net, skb_cur, s->pid);
+		rc = genlmsg_unicast(&init_net, skb_cur, s->pid, GFP_KERNEL);
 		if (rc == -ECONNREFUSED) {
 			s->valid = 0;
 			delcount++;
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index d4d1617..dcc674f 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -351,7 +351,8 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 		goto nla_put_failure;
 
 	genlmsg_end(skb_out, msg_head);
-	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
+	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid,
+			GFP_KERNEL);
 
 	return 0;
 
@@ -433,7 +434,8 @@ static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 	rcu_read_unlock();
 
 	genlmsg_end(skb_out, msg_head);
-	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
+	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid,
+			GFP_KERNEL);
 
 	return 0;
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 1d02e8d..5a3cc56 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -100,7 +100,8 @@ static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid,
+			       GFP_KERNEL);
 
 err_out:
 	nlmsg_free(msg);
@@ -450,7 +451,7 @@ static int l2tp_nl_cmd_tunnel_get(struct sk_buff *skb, struct genl_info *info)
 	if (ret < 0)
 		goto err_out;
 
-	return genlmsg_unicast(net, msg, info->snd_portid);
+	return genlmsg_unicast(net, msg, info->snd_portid, GFP_KERNEL);
 
 err_out:
 	nlmsg_free(msg);
@@ -820,7 +821,8 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
 	if (ret < 0)
 		goto err_out;
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid,
+			       GFP_KERNEL);
 
 err_out:
 	nlmsg_free(msg);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 524c0fd..374e0ec 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -542,7 +542,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
-	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
+	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid,
+			      GFP_ATOMIC);
 	user_skb = NULL;
 out:
 	if (err)
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 3ad9fab..205577c 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1210,7 +1210,7 @@ send:
 	rep_nlh = nlmsg_hdr(msg.rep);
 	memcpy(rep_nlh, info->nlhdr, len);
 	rep_nlh->nlmsg_len = msg.rep->len;
-	genlmsg_unicast(msg.net, msg.rep, NETLINK_CB(skb).portid);
+	genlmsg_unicast(msg.net, msg.rep, NETLINK_CB(skb).portid, GFP_KERNEL);
 
 	return err;
 }
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 244d552..e608937 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -12648,7 +12648,7 @@ static bool __nl80211_unexpected_frame(struct net_device *dev, u8 cmd,
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
+	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid, gfp);
 	return true;
 
  nla_put_failure:
@@ -12733,7 +12733,7 @@ int nl80211_send_mgmt(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
+	return genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid, gfp);
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -13245,7 +13245,8 @@ void cfg80211_report_obss_beacon(struct wiphy *wiphy,
 
 		genlmsg_end(msg, hdr);
 
-		genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, reg->nlportid);
+		genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, reg->nlportid,
+				GFP_ATOMIC);
 	}
 	spin_unlock_bh(&rdev->beacon_registrations_lock);
 	return;
@@ -13623,7 +13624,7 @@ void cfg80211_crit_proto_stopped(struct wireless_dev *wdev, gfp_t gfp)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
+	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid, gfp);
 	return;
 
  nla_put_failure:
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
