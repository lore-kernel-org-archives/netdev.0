From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: [PATCH v2 2/2] mac80211_hwsim: Allow managing radios from non-initial namespaces
Date: Mon,  9 May 2016 18:33:59 +0200
Message-ID: <1462811639-29906-3-git-send-email-martin@strongswan.org>
References: <1462811639-29906-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462811639-29906-1-git-send-email-martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While wiphys can be moved into network namespaces over nl80211, the
creation and removal of hwsim radios is currently limited to the initial
namespace. This patch allows management of namespaced radios from the
owning namespace by setting genetlink netnsok.

To prevent two arbitrary namespaces to communicate over the simulated
shared medium, radios are separated by netgroups. Each radio created in
the same namespace lives in the same netgroup and hence can communicate
with other radios in that group. When moving radios to other namespaces,
the netgroup is preserved, so two radios having the same netgroup can
communicate even if not in the same namespace; This allows a controlling
namespace to create radios and move them to other namespaces for
communication.

When a net namespace owning a radio exits, the radio is destroyed unless
it was created in the initial network namespace. This keeps the previous
behavior by returning them to the init namespace, but prevents unprivileged
users from creating radios in the initial namespace.

Signed-off-by: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 97 +++++++++++++++++++++++++++++++++--
 1 file changed, 94 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index c757f14..303d94d 100644
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
@@ -250,6 +252,28 @@ static inline void hwsim_clear_chanctx_magic(struct ieee80211_chanctx_conf *c)
 	cp->magic = 0;
 }
 
+static unsigned int hwsim_net_id;
+
+static int hwsim_netgroup;
+
+struct hwsim_net {
+	int netgroup;
+};
+
+static inline int hwsim_net_get_netgroup(struct net *net)
+{
+	struct hwsim_net *hwsim_net = net_generic(net, hwsim_net_id);
+
+	return hwsim_net->netgroup;
+}
+
+static inline void hwsim_net_set_netgroup(struct net *net)
+{
+	struct hwsim_net *hwsim_net = net_generic(net, hwsim_net_id);
+
+	hwsim_net->netgroup = hwsim_netgroup++;
+}
+
 static struct class *hwsim_class;
 
 static struct net_device *hwsim_mon; /* global monitor netdev */
@@ -526,6 +550,9 @@ struct mac80211_hwsim_data {
 	 */
 	u64 group;
 
+	/* group shared by radios created in the same netns */
+	int netgroup;
+
 	int power_level;
 
 	/* difference between this hw's clock and the real clock, in usecs */
@@ -568,6 +595,7 @@ static struct genl_family hwsim_genl_family = {
 	.name = "MAC80211_HWSIM",
 	.version = 1,
 	.maxattr = HWSIM_ATTR_MAX,
+	.netnsok = true,
 };
 
 enum hwsim_multicast_groups {
@@ -1202,6 +1230,9 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 		if (!(data->group & data2->group))
 			continue;
 
+		if (data->netgroup != data2->netgroup)
+			continue;
+
 		if (!hwsim_chans_compat(chan, data2->tmp_chan) &&
 		    !hwsim_chans_compat(chan, data2->channel)) {
 			ieee80211_iterate_active_interfaces_atomic(
@@ -2349,6 +2380,7 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 	struct ieee80211_hw *hw;
 	enum nl80211_band band;
 	const struct ieee80211_ops *ops = &mac80211_hwsim_ops;
+	struct net *net;
 	int idx;
 
 	if (WARN_ON(param->channels > 1 && !param->use_chanctx))
@@ -2366,6 +2398,13 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
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
 
@@ -2541,6 +2580,8 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 	data->group = 1;
 	mutex_init(&data->mutex);
 
+	data->netgroup = hwsim_net_get_netgroup(net);
+
 	/* Enable frame retransmissions for lossy channels */
 	hw->max_rates = 4;
 	hw->max_rate_tries = 11;
@@ -3013,6 +3054,9 @@ static int hwsim_del_radio_nl(struct sk_buff *msg, struct genl_info *info)
 				continue;
 		}
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), genl_info_net(info)))
+			continue;
+
 		list_del(&data->list);
 		spin_unlock_bh(&hwsim_radio_lock);
 		mac80211_hwsim_del_radio(data, wiphy_name(data->hw->wiphy),
@@ -3039,6 +3083,9 @@ static int hwsim_get_radio_nl(struct sk_buff *msg, struct genl_info *info)
 		if (data->idx != idx)
 			continue;
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), genl_info_net(info)))
+			continue;
+
 		skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 		if (!skb) {
 			res = -ENOMEM;
@@ -3078,6 +3125,9 @@ static int hwsim_dump_radio_nl(struct sk_buff *skb,
 		if (data->idx < idx)
 			continue;
 
+		if (!net_eq(wiphy_net(data->hw->wiphy), sock_net(skb->sk)))
+			continue;
+
 		res = mac80211_hwsim_get_radio(skb, data,
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, cb,
@@ -3117,13 +3167,13 @@ static const struct genl_ops hwsim_ops[] = {
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
@@ -3205,6 +3255,40 @@ failure:
 	return -EINVAL;
 }
 
+static __net_init int hwsim_init_net(struct net *net)
+{
+	hwsim_net_set_netgroup(net);
+
+	return 0;
+}
+
+static void __net_exit hwsim_exit_net(struct net *net)
+{
+	struct mac80211_hwsim_data *data, *tmp;
+
+	spin_lock_bh(&hwsim_radio_lock);
+	list_for_each_entry_safe(data, tmp, &hwsim_radios, list) {
+		if (!net_eq(wiphy_net(data->hw->wiphy), net))
+			continue;
+
+		/* Radios created in init_net are returned to init_net. */
+		if (data->netgroup == hwsim_net_get_netgroup(&init_net))
+			continue;
+
+		list_del(&data->list);
+		INIT_WORK(&data->destroy_work, destroy_radio);
+		schedule_work(&data->destroy_work);
+	}
+	spin_unlock_bh(&hwsim_radio_lock);
+}
+
+static struct pernet_operations hwsim_net_ops = {
+	.init = hwsim_init_net,
+	.exit = hwsim_exit_net,
+	.id   = &hwsim_net_id,
+	.size = sizeof(struct hwsim_net),
+};
+
 static void hwsim_exit_netlink(void)
 {
 	/* unregister the notifier */
@@ -3241,10 +3325,14 @@ static int __init init_mac80211_hwsim(void)
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
@@ -3362,6 +3450,8 @@ out_free_radios:
 	mac80211_hwsim_free();
 out_unregister_driver:
 	platform_driver_unregister(&mac80211_hwsim_driver);
+out_unregister_pernet:
+	unregister_pernet_device(&hwsim_net_ops);
 	return err;
 }
 module_init(init_mac80211_hwsim);
@@ -3375,5 +3465,6 @@ static void __exit exit_mac80211_hwsim(void)
 	mac80211_hwsim_free();
 	unregister_netdev(hwsim_mon);
 	platform_driver_unregister(&mac80211_hwsim_driver);
+	unregister_pernet_device(&hwsim_net_ops);
 }
 module_exit(exit_mac80211_hwsim);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
