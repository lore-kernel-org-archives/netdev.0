From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 2/2] mac80211_hwsim: Allow managing radios from non-initial namespaces
Date: Tue,  3 May 2016 08:53:18 +0200
Message-ID: <1462258398-6749-3-git-send-email-martin@strongswan.org>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:47042 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbcECHAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 03:00:41 -0400
In-Reply-To: <1462258398-6749-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While wiphys can be moved into network namespaces over nl80211, the
creation and removal of hwsim radios is currently limited to the initial
namespace. This patch allows management of namespaced radios from the
owning namespace by setting genetlink netnsok.

To prevent two arbitrary namespaces from communicating over the simulated
shared medium, radios are separated by netgroups. Each radio created in
the same namespace lives in the same netgroup and hence can communicate
with other radios in that group. When moving radios to other namespaces,
the netgroup is preserved, so two radios having the same netgroup can
communicate even if not in the same namespace; This allows a controlling
namespace to create radios and move them to other namespaces for
communication.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 88 +++++++++++++++++++++++++++++++++--
 1 file changed, 85 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index c757f14..91bd440 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -30,6 +30,8 @@
 #include <linux/module.h>
 #include <linux/ktime.h>
 #include <net/genetlink.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include "mac80211_hwsim.h"
 
 #define WARN_QUEUE 100
@@ -39,6 +41,7 @@ MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Software simulator of 802.11 radio(s) for mac80211");
 MODULE_LICENSE("GPL");
 
+static unsigned int hwsim_net_id;
 static u32 wmediumd_portid;
 
 static int radios = 2;
@@ -526,6 +529,9 @@ struct mac80211_hwsim_data {
 	 */
 	u64 group;
 
+	/* group shared by radios created in the same netns */
+	int netgroup;
+
 	int power_level;
 
 	/* difference between this hw's clock and the real clock, in usecs */
@@ -568,6 +574,7 @@ static struct genl_family hwsim_genl_family = {
 	.name = "MAC80211_HWSIM",
 	.version = 1,
 	.maxattr = HWSIM_ATTR_MAX,
+	.netnsok = true,
 };
 
 enum hwsim_multicast_groups {
@@ -1202,6 +1209,9 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 		if (!(data->group & data2->group))
 			continue;
 
+		if (data->netgroup != data2->netgroup)
+			continue;
+
 		if (!hwsim_chans_compat(chan, data2->tmp_chan) &&
 		    !hwsim_chans_compat(chan, data2->channel)) {
 			ieee80211_iterate_active_interfaces_atomic(
@@ -2348,6 +2358,7 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 	struct mac80211_hwsim_data *data;
 	struct ieee80211_hw *hw;
 	enum nl80211_band band;
+	struct net *net;
 	const struct ieee80211_ops *ops = &mac80211_hwsim_ops;
 	int idx;
 
@@ -2366,6 +2377,13 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 		err = -ENOMEM;
 		goto failed;
 	}
+
+	if (info)
+		net = genl_info_net(info);
+	else
+		net = &init_net;
+	wiphy_net_set(hw->wiphy, net);
+
 	data = hw->priv;
 	data->hw = hw;
 
@@ -2541,6 +2559,8 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 	data->group = 1;
 	mutex_init(&data->mutex);
 
+	data->netgroup = *(int *)net_generic(net, hwsim_net_id);
+
 	/* Enable frame retransmissions for lossy channels */
 	hw->max_rates = 4;
 	hw->max_rate_tries = 11;
@@ -3013,6 +3033,9 @@ static int hwsim_del_radio_nl(struct sk_buff *msg, struct genl_info *info)
 				continue;
 		}
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), genl_info_net(info)))
+			continue;
+
 		list_del(&data->list);
 		spin_unlock_bh(&hwsim_radio_lock);
 		mac80211_hwsim_del_radio(data, wiphy_name(data->hw->wiphy),
@@ -3039,6 +3062,9 @@ static int hwsim_get_radio_nl(struct sk_buff *msg, struct genl_info *info)
 		if (data->idx != idx)
 			continue;
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), genl_info_net(info)))
+			continue;
+
 		skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 		if (!skb) {
 			res = -ENOMEM;
@@ -3078,6 +3104,9 @@ static int hwsim_dump_radio_nl(struct sk_buff *skb,
 		if (data->idx < idx)
 			continue;
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), sock_net(skb->sk)))
+			continue;
+
 		res = mac80211_hwsim_get_radio(skb, data,
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, cb,
@@ -3117,13 +3146,13 @@ static const struct genl_ops hwsim_ops[] = {
 		.cmd = HWSIM_CMD_NEW_RADIO,
 		.policy = hwsim_genl_policy,
 		.doit = hwsim_new_radio_nl,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 	},
 	{
 		.cmd = HWSIM_CMD_DEL_RADIO,
 		.policy = hwsim_genl_policy,
 		.doit = hwsim_del_radio_nl,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 	},
 	{
 		.cmd = HWSIM_CMD_GET_RADIO,
@@ -3205,6 +3234,52 @@ failure:
 	return -EINVAL;
 }
 
+static __net_init int hwsim_init_net(struct net *net)
+{
+	struct mac80211_hwsim_data *data;
+	bool exists = true;
+	int netgroup = 0;
+
+	spin_lock_bh(&hwsim_radio_lock);
+	while (exists) {
+		exists = false;
+		list_for_each_entry(data, &hwsim_radios, list) {
+			if (netgroup == data->netgroup) {
+				exists = true;
+				netgroup++;
+				break;
+			}
+		}
+	}
+	spin_unlock_bh(&hwsim_radio_lock);
+
+	*(int *)net_generic(net, hwsim_net_id) = netgroup;
+
+	return 0;
+}
+
+static void __net_exit hwsim_exit_net(struct net *net)
+{
+	struct mac80211_hwsim_data *entry, *tmp;
+
+	spin_lock_bh(&hwsim_radio_lock);
+	list_for_each_entry_safe(entry, tmp, &hwsim_radios, list) {
+		if (net_eq(wiphy_net(entry->hw->wiphy), net)) {
+			list_del(&entry->list);
+			INIT_WORK(&entry->destroy_work, destroy_radio);
+			schedule_work(&entry->destroy_work);
+		}
+	}
+	spin_unlock_bh(&hwsim_radio_lock);
+}
+
+static struct pernet_operations hwsim_net_ops = {
+	.init = hwsim_init_net,
+	.exit = hwsim_exit_net,
+	.id   = &hwsim_net_id,
+	.size = sizeof(int),
+};
+
 static void hwsim_exit_netlink(void)
 {
 	/* unregister the notifier */
@@ -3241,10 +3316,14 @@ static int __init init_mac80211_hwsim(void)
 	spin_lock_init(&hwsim_radio_lock);
 	INIT_LIST_HEAD(&hwsim_radios);
 
-	err = platform_driver_register(&mac80211_hwsim_driver);
+	err = register_pernet_device(&hwsim_net_ops);
 	if (err)
 		return err;
 
+	err = platform_driver_register(&mac80211_hwsim_driver);
+	if (err)
+		goto out_unregister_pernet;
+
 	hwsim_class = class_create(THIS_MODULE, "mac80211_hwsim");
 	if (IS_ERR(hwsim_class)) {
 		err = PTR_ERR(hwsim_class);
@@ -3362,6 +3441,8 @@ out_free_radios:
 	mac80211_hwsim_free();
 out_unregister_driver:
 	platform_driver_unregister(&mac80211_hwsim_driver);
+out_unregister_pernet:
+	unregister_pernet_device(&hwsim_net_ops);
 	return err;
 }
 module_init(init_mac80211_hwsim);
@@ -3375,5 +3456,6 @@ static void __exit exit_mac80211_hwsim(void)
 	mac80211_hwsim_free();
 	unregister_netdev(hwsim_mon);
 	platform_driver_unregister(&mac80211_hwsim_driver);
+	unregister_pernet_device(&hwsim_net_ops);
 }
 module_exit(exit_mac80211_hwsim);
-- 
2.7.4
