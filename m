From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: [PATCH] mac80211_hwsim: Allow wmediumd to attach to radios created in its netns
Date: Sat, 14 May 2016 10:34:44 +0200
Message-ID: <1463214884-5983-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Registering wmediumd is currently limited to the initial network
namespace. This patch enables wmediumd to attach from non-initial
network namespaces using a user namespace having CAP_NET_ADMIN. A
registered wmediumd can forward frames on radios that have been created
in the same network namespace, even if they have been moved to other
network namespaces.

The wmediumd Netlink portid is tracked per net namespace. Additionally,
the portid is stored on all radios created in that net namespace to
simplify the portid lookup in the data path.

Signed-off-by: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 92 +++++++++++++++++++++++++++++------
 1 file changed, 76 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a16cd0c..5bb9f0a 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -41,8 +41,6 @@ MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Software simulator of 802.11 radio(s) for mac80211");
 MODULE_LICENSE("GPL");
 
-static u32 wmediumd_portid;
-
 static int radios = 2;
 module_param(radios, int, 0444);
 MODULE_PARM_DESC(radios, "Number of simulated radios");
@@ -258,6 +256,7 @@ static int hwsim_netgroup;
 
 struct hwsim_net {
 	int netgroup;
+	u32 wmediumd;
 };
 
 static inline int hwsim_net_get_netgroup(struct net *net)
@@ -274,6 +273,20 @@ static inline void hwsim_net_set_netgroup(struct net *net)
 	hwsim_net->netgroup = hwsim_netgroup++;
 }
 
+static inline u32 hwsim_net_get_wmediumd(struct net *net)
+{
+	struct hwsim_net *hwsim_net = net_generic(net, hwsim_net_id);
+
+	return hwsim_net->wmediumd;
+}
+
+static inline void hwsim_net_set_wmediumd(struct net *net, u32 portid)
+{
+	struct hwsim_net *hwsim_net = net_generic(net, hwsim_net_id);
+
+	hwsim_net->wmediumd = portid;
+}
+
 static struct class *hwsim_class;
 
 static struct net_device *hwsim_mon; /* global monitor netdev */
@@ -552,6 +565,8 @@ struct mac80211_hwsim_data {
 
 	/* group shared by radios created in the same netns */
 	int netgroup;
+	/* wmediumd portid responsile for netgroup of this radio */
+	u32 wmediumd;
 
 	int power_level;
 
@@ -983,6 +998,29 @@ static bool hwsim_ps_rx_ok(struct mac80211_hwsim_data *data,
 	return true;
 }
 
+static int hwsim_unicast_netgroup(struct mac80211_hwsim_data *data,
+				  struct sk_buff *skb, int portid)
+{
+	struct net *net;
+	bool found = false;
+	int res = -ENOENT;
+
+	rcu_read_lock();
+	for_each_net_rcu(net) {
+		if (data->netgroup == hwsim_net_get_netgroup(net)) {
+			res = genlmsg_unicast(net, skb, portid);
+			found = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	if (!found)
+		nlmsg_free(skb);
+
+	return res;
+}
+
 static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 				       struct sk_buff *my_skb,
 				       int dst_portid)
@@ -1062,7 +1100,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	if (genlmsg_unicast(&init_net, skb, dst_portid))
+	if (hwsim_unicast_netgroup(data, skb, dst_portid))
 		goto err_free_txskb;
 
 	/* Enqueue the packet */
@@ -1355,7 +1393,7 @@ static void mac80211_hwsim_tx(struct ieee80211_hw *hw,
 	mac80211_hwsim_monitor_rx(hw, skb, channel);
 
 	/* wmediumd mode check */
-	_portid = ACCESS_ONCE(wmediumd_portid);
+	_portid = ACCESS_ONCE(data->wmediumd);
 
 	if (_portid)
 		return mac80211_hwsim_tx_frame_nl(hw, skb, _portid);
@@ -1451,7 +1489,8 @@ static void mac80211_hwsim_tx_frame(struct ieee80211_hw *hw,
 				    struct sk_buff *skb,
 				    struct ieee80211_channel *chan)
 {
-	u32 _pid = ACCESS_ONCE(wmediumd_portid);
+	struct mac80211_hwsim_data *data = hw->priv;
+	u32 _pid = ACCESS_ONCE(data->wmediumd);
 
 	if (ieee80211_hw_check(hw, SUPPORTS_RC_TABLE)) {
 		struct ieee80211_tx_info *txi = IEEE80211_SKB_CB(skb);
@@ -2796,6 +2835,20 @@ static struct mac80211_hwsim_data *get_hwsim_data_ref_from_addr(const u8 *addr)
 	return data;
 }
 
+static void hwsim_register_wmediumd(struct net *net, u32 portid)
+{
+	struct mac80211_hwsim_data *data;
+
+	hwsim_net_set_wmediumd(net, portid);
+
+	spin_lock_bh(&hwsim_radio_lock);
+	list_for_each_entry(data, &hwsim_radios, list) {
+		if (data->netgroup == hwsim_net_get_netgroup(net))
+			data->wmediumd = portid;
+	}
+	spin_unlock_bh(&hwsim_radio_lock);
+}
+
 static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 					   struct genl_info *info)
 {
@@ -2811,9 +2864,6 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	int i;
 	bool found = false;
 
-	if (info->snd_portid != wmediumd_portid)
-		return -EINVAL;
-
 	if (!info->attrs[HWSIM_ATTR_ADDR_TRANSMITTER] ||
 	    !info->attrs[HWSIM_ATTR_FLAGS] ||
 	    !info->attrs[HWSIM_ATTR_COOKIE] ||
@@ -2829,6 +2879,12 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	if (!data2)
 		goto out;
 
+	if (hwsim_net_get_netgroup(genl_info_net(info)) != data2->netgroup)
+		goto out;
+
+	if (info->snd_portid != data2->wmediumd)
+		goto out;
+
 	/* look for the skb matching the cookie passed back from user */
 	skb_queue_walk_safe(&data2->pending, skb, tmp) {
 		u64 skb_cookie;
@@ -2892,9 +2948,6 @@ static int hwsim_cloned_frame_received_nl(struct sk_buff *skb_2,
 	void *frame_data;
 	struct sk_buff *skb = NULL;
 
-	if (info->snd_portid != wmediumd_portid)
-		return -EINVAL;
-
 	if (!info->attrs[HWSIM_ATTR_ADDR_RECEIVER] ||
 	    !info->attrs[HWSIM_ATTR_FRAME] ||
 	    !info->attrs[HWSIM_ATTR_RX_RATE] ||
@@ -2920,6 +2973,12 @@ static int hwsim_cloned_frame_received_nl(struct sk_buff *skb_2,
 	if (!data2)
 		goto out;
 
+	if (hwsim_net_get_netgroup(genl_info_net(info)) != data2->netgroup)
+		goto out;
+
+	if (info->snd_portid != data2->wmediumd)
+		goto out;
+
 	/* check if radio is configured properly */
 
 	if (data2->idle || !data2->started)
@@ -2966,6 +3025,7 @@ out:
 static int hwsim_register_received_nl(struct sk_buff *skb_2,
 				      struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	struct mac80211_hwsim_data *data;
 	int chans = 1;
 
@@ -2982,10 +3042,10 @@ static int hwsim_register_received_nl(struct sk_buff *skb_2,
 	if (chans > 1)
 		return -EOPNOTSUPP;
 
-	if (wmediumd_portid)
+	if (hwsim_net_get_wmediumd(net))
 		return -EBUSY;
 
-	wmediumd_portid = info->snd_portid;
+	hwsim_register_wmediumd(net, info->snd_portid);
 
 	printk(KERN_DEBUG "mac80211_hwsim: received a REGISTER, "
 	       "switching to wmediumd mode with pid %d\n", info->snd_portid);
@@ -3152,7 +3212,7 @@ static const struct genl_ops hwsim_ops[] = {
 		.cmd = HWSIM_CMD_REGISTER,
 		.policy = hwsim_genl_policy,
 		.doit = hwsim_register_received_nl,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 	},
 	{
 		.cmd = HWSIM_CMD_FRAME,
@@ -3218,10 +3278,10 @@ static int mac80211_hwsim_netlink_notify(struct notifier_block *nb,
 
 	remove_user_radios(notify->portid);
 
-	if (notify->portid == wmediumd_portid) {
+	if (notify->portid == hwsim_net_get_wmediumd(notify->net)) {
 		printk(KERN_INFO "mac80211_hwsim: wmediumd released netlink"
 		       " socket, switching to perfect channel medium\n");
-		wmediumd_portid = 0;
+		hwsim_register_wmediumd(notify->net, 0);
 	}
 	return NOTIFY_DONE;
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
