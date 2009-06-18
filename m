From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] cfg80211: make aware of net namespaces
Date: Thu, 18 Jun 2009 14:07:49 +0200
Message-ID: <1245326869.13790.18.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In order to make cfg80211/nl80211 aware of network namespaces,
we have to do the following things:

 * del_virtual_intf method takes an interface index rather
   than a netdev pointer - simply change this

 * nl80211 uses init_net a lot, it changes to use the sender's
   network namespace

 * scan requests use the interface index, hold a netdev pointer
   and reference instead

 * we want a wiphy and its associated virtual interfaces to be
   in one netns together, so
    - we need to be able to change ns for a given interface, so
      export dev_change_net_namespace()
    - for each virtual interface set the NETIF_F_NETNS_LOCAL
      flag, and clear that flag only when the wiphy changes ns,
      to disallow breaking this invariant

 * when a network namespace goes away, we need to reparent the
   wiphy to init_net

 * cfg80211 users that support creating virtual interfaces must
   create them in the wiphy's namespace, currently this affects
   only mac80211

The end result is that you can now switch an entire wiphy into
a different network namespace with the new command
	iw phy#<idx> set netns <pid>
and all virtual interfaces will follow (or the operation fails).

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/linux/nl80211.h |    9 ++
 include/net/cfg80211.h  |   17 +++-
 net/core/dev.c          |    1 
 net/mac80211/cfg.c      |   14 ---
 net/mac80211/iface.c    |    1 
 net/wireless/core.c     |   75 ++++++++++++++++++--
 net/wireless/core.h     |    5 +
 net/wireless/nl80211.c  |  178 +++++++++++++++++++++++++++++++++---------------
 net/wireless/scan.c     |   15 +---
 9 files changed, 231 insertions(+), 84 deletions(-)

--- wireless-testing.orig/include/net/cfg80211.h	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/include/net/cfg80211.h	2009-06-18 13:54:23.000000000 +0200
@@ -542,7 +542,7 @@ struct cfg80211_ssid {
  * @ie: optional information element(s) to add into Probe Request or %NULL
  * @ie_len: length of ie in octets
  * @wiphy: the wiphy this was for
- * @ifidx: the interface index
+ * @dev: the interface
  */
 struct cfg80211_scan_request {
 	struct cfg80211_ssid *ssids;
@@ -554,7 +554,7 @@ struct cfg80211_scan_request {
 
 	/* internal */
 	struct wiphy *wiphy;
-	int ifidx;
+	struct net_device *dev;
 };
 
 /**
@@ -781,7 +781,8 @@ enum tx_power_setting {
  * @resume: wiphy device needs to be resumed
  *
  * @add_virtual_intf: create a new virtual interface with the given name,
- *	must set the struct wireless_dev's iftype.
+ *	must set the struct wireless_dev's iftype. Beware: You must create
+ *	the new netdev in the wiphy's network namespace!
  *
  * @del_virtual_intf: remove the virtual interface determined by ifindex.
  *
@@ -865,7 +866,7 @@ struct cfg80211_ops {
 	int	(*add_virtual_intf)(struct wiphy *wiphy, char *name,
 				    enum nl80211_iftype type, u32 *flags,
 				    struct vif_params *params);
-	int	(*del_virtual_intf)(struct wiphy *wiphy, int ifindex);
+	int	(*del_virtual_intf)(struct wiphy *wiphy, struct net_device *dev);
 	int	(*change_virtual_intf)(struct wiphy *wiphy,
 				       struct net_device *dev,
 				       enum nl80211_iftype type, u32 *flags,
@@ -993,6 +994,9 @@ struct cfg80211_ops {
  * @frag_threshold: Fragmentation threshold (dot11FragmentationThreshold);
  *	-1 = fragmentation disabled, only odd values >= 256 used
  * @rts_threshold: RTS threshold (dot11RTSThreshold); -1 = RTS/CTS disabled
+ * @net: the network namespace this wiphy currently lives in
+ * @netnsok: if set to false, do not allow changing the netns of this
+ *	wiphy at all
  */
 struct wiphy {
 	/* assign these fields before you register the wiphy */
@@ -1006,6 +1010,8 @@ struct wiphy {
 	bool custom_regulatory;
 	bool strict_regulatory;
 
+	bool netnsok;
+
 	enum cfg80211_signal_type signal_type;
 
 	int bss_priv_size;
@@ -1044,6 +1050,9 @@ struct wiphy {
 	/* dir in debugfs: ieee80211/<wiphyname> */
 	struct dentry *debugfsdir;
 
+	/* the network namespace this phy lives in currently */
+	struct net *net;
+
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
 
--- wireless-testing.orig/net/mac80211/cfg.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/mac80211/cfg.c	2009-06-18 13:54:23.000000000 +0200
@@ -57,19 +57,9 @@ static int ieee80211_add_iface(struct wi
 	return 0;
 }
 
-static int ieee80211_del_iface(struct wiphy *wiphy, int ifindex)
+static int ieee80211_del_iface(struct wiphy *wiphy, struct net_device *dev)
 {
-	struct net_device *dev;
-	struct ieee80211_sub_if_data *sdata;
-
-	/* we're under RTNL */
-	dev = __dev_get_by_index(&init_net, ifindex);
-	if (!dev)
-		return -ENODEV;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-
-	ieee80211_if_remove(sdata);
+	ieee80211_if_remove(IEEE80211_DEV_TO_SUB_IF(dev));
 
 	return 0;
 }
--- wireless-testing.orig/net/wireless/nl80211.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2009-06-18 14:03:46.000000000 +0200
@@ -14,8 +14,10 @@
 #include <linux/rtnetlink.h>
 #include <linux/netlink.h>
 #include <linux/etherdevice.h>
+#include <net/net_namespace.h>
 #include <net/genetlink.h>
 #include <net/cfg80211.h>
+#include <net/sock.h>
 #include "core.h"
 #include "nl80211.h"
 #include "reg.h"
@@ -27,24 +29,26 @@ static struct genl_family nl80211_fam = 
 	.hdrsize = 0,		/* no private header */
 	.version = 1,		/* no particular meaning now */
 	.maxattr = NL80211_ATTR_MAX,
+	.netnsok = true,
 };
 
 /* internal helper: get drv and dev */
-static int get_drv_dev_by_info_ifindex(struct nlattr **attrs,
+static int get_drv_dev_by_info_ifindex(struct genl_info *info,
 				       struct cfg80211_registered_device **drv,
 				       struct net_device **dev)
 {
+	struct nlattr **attrs = info->attrs;
 	int ifindex;
 
 	if (!attrs[NL80211_ATTR_IFINDEX])
 		return -EINVAL;
 
 	ifindex = nla_get_u32(attrs[NL80211_ATTR_IFINDEX]);
-	*dev = dev_get_by_index(&init_net, ifindex);
+	*dev = dev_get_by_index(info->net, ifindex);
 	if (!*dev)
 		return -ENODEV;
 
-	*drv = cfg80211_get_dev_from_ifindex(ifindex);
+	*drv = cfg80211_get_dev_from_ifindex(info->net, ifindex);
 	if (IS_ERR(*drv)) {
 		dev_put(*dev);
 		return PTR_ERR(*drv);
@@ -128,6 +132,7 @@ static struct nla_policy nl80211_policy[
 		.len = sizeof(struct nl80211_sta_flag_update),
 	},
 	[NL80211_ATTR_CONTROL_PORT] = { .type = NLA_FLAG },
+	[NL80211_ATTR_PID] = { .type = NLA_U32 },
 };
 
 /* IE validation */
@@ -345,6 +350,10 @@ static int nl80211_send_wiphy(struct sk_
 	CMD(deauth, DEAUTHENTICATE);
 	CMD(disassoc, DISASSOCIATE);
 	CMD(join_ibss, JOIN_IBSS);
+	if (dev->wiphy.netnsok) {
+		i++;
+		NLA_PUT_U32(msg, i, NL80211_CMD_SET_WIPHY_NETNS);
+	}
 
 #undef CMD
 	nla_nest_end(msg, nl_cmds);
@@ -364,6 +373,8 @@ static int nl80211_dump_wiphy(struct sk_
 
 	mutex_lock(&cfg80211_mutex);
 	list_for_each_entry(dev, &cfg80211_drv_list, list) {
+		if (!net_eq(dev->wiphy.net, sock_net(skb->sk)))
+			continue;
 		if (++idx <= start)
 			continue;
 		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
@@ -668,6 +679,8 @@ static int nl80211_dump_interface(struct
 
 	mutex_lock(&cfg80211_mutex);
 	list_for_each_entry(dev, &cfg80211_drv_list, list) {
+		if (!net_eq(dev->wiphy.net, sock_net(skb->sk)))
+			continue;
 		if (wp_idx < wp_start) {
 			wp_idx++;
 			continue;
@@ -708,7 +721,7 @@ static int nl80211_get_interface(struct 
 	struct net_device *netdev;
 	int err;
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &dev, &netdev);
+	err = get_drv_dev_by_info_ifindex(info, &dev, &netdev);
 	if (err)
 		return err;
 
@@ -776,7 +789,7 @@ static int nl80211_set_interface(struct 
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -899,25 +912,24 @@ static int nl80211_new_interface(struct 
 static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *drv;
-	int ifindex, err;
 	struct net_device *dev;
+	int err;
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
-	ifindex = dev->ifindex;
-	dev_put(dev);
 
 	if (!drv->ops->del_virtual_intf) {
 		err = -EOPNOTSUPP;
 		goto out;
 	}
 
-	err = drv->ops->del_virtual_intf(&drv->wiphy, ifindex);
+	err = drv->ops->del_virtual_intf(&drv->wiphy, dev);
 
  out:
+	dev_put(dev);
 	cfg80211_put_dev(drv);
  unlock_rtnl:
 	rtnl_unlock();
@@ -974,7 +986,7 @@ static int nl80211_get_key(struct sk_buf
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1056,7 +1068,7 @@ static int nl80211_set_key(struct sk_buf
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1127,7 +1139,7 @@ static int nl80211_new_key(struct sk_buf
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1174,7 +1186,7 @@ static int nl80211_del_key(struct sk_buf
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1219,7 +1231,7 @@ static int nl80211_addset_beacon(struct 
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1306,7 +1318,7 @@ static int nl80211_del_beacon(struct sk_
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -1516,13 +1528,13 @@ static int nl80211_dump_station(struct s
 
 	rtnl_lock();
 
-	netdev = __dev_get_by_index(&init_net, ifidx);
+	netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
 	if (!netdev) {
 		err = -ENODEV;
 		goto out_rtnl;
 	}
 
-	dev = cfg80211_get_dev_from_ifindex(ifidx);
+	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
 	if (IS_ERR(dev)) {
 		err = PTR_ERR(dev);
 		goto out_rtnl;
@@ -1581,7 +1593,7 @@ static int nl80211_get_station(struct sk
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -1619,14 +1631,15 @@ static int nl80211_get_station(struct sk
 /*
  * Get vlan interface making sure it is on the right wiphy.
  */
-static int get_vlan(struct nlattr *vlanattr,
+static int get_vlan(struct genl_info *info,
 		    struct cfg80211_registered_device *rdev,
 		    struct net_device **vlan)
 {
+	struct nlattr *vlanattr = info->attrs[NL80211_ATTR_STA_VLAN];
 	*vlan = NULL;
 
 	if (vlanattr) {
-		*vlan = dev_get_by_index(&init_net, nla_get_u32(vlanattr));
+		*vlan = dev_get_by_index(info->net, nla_get_u32(vlanattr));
 		if (!*vlan)
 			return -ENODEV;
 		if (!(*vlan)->ieee80211_ptr)
@@ -1681,7 +1694,7 @@ static int nl80211_set_station(struct sk
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -1692,7 +1705,7 @@ static int nl80211_set_station(struct sk
 		goto out;
 	}
 
-	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	err = get_vlan(info, drv, &params.vlan);
 	if (err)
 		goto out;
 
@@ -1757,7 +1770,7 @@ static int nl80211_new_station(struct sk
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -1768,7 +1781,7 @@ static int nl80211_new_station(struct sk
 		goto out;
 	}
 
-	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	err = get_vlan(info, drv, &params.vlan);
 	if (err)
 		goto out;
 
@@ -1807,7 +1820,7 @@ static int nl80211_del_station(struct sk
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -1913,13 +1926,13 @@ static int nl80211_dump_mpath(struct sk_
 
 	rtnl_lock();
 
-	netdev = __dev_get_by_index(&init_net, ifidx);
+	netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
 	if (!netdev) {
 		err = -ENODEV;
 		goto out_rtnl;
 	}
 
-	dev = cfg80211_get_dev_from_ifindex(ifidx);
+	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
 	if (IS_ERR(dev)) {
 		err = PTR_ERR(dev);
 		goto out_rtnl;
@@ -1983,7 +1996,7 @@ static int nl80211_get_mpath(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2042,7 +2055,7 @@ static int nl80211_set_mpath(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2090,7 +2103,7 @@ static int nl80211_new_mpath(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2132,7 +2145,7 @@ static int nl80211_del_mpath(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2183,7 +2196,7 @@ static int nl80211_set_bss(struct sk_buf
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2302,7 +2315,7 @@ static int nl80211_get_mesh_params(struc
 	rtnl_lock();
 
 	/* Look up our device */
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2419,7 +2432,7 @@ static int nl80211_set_mesh_params(struc
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2675,7 +2688,7 @@ static int nl80211_trigger_scan(struct s
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto out_rtnl;
 
@@ -2797,14 +2810,16 @@ static int nl80211_trigger_scan(struct s
 		       request->ie_len);
 	}
 
-	request->ifidx = dev->ifindex;
+	request->dev = dev;
 	request->wiphy = &drv->wiphy;
 
 	drv->scan_req = request;
 	err = drv->ops->scan(&drv->wiphy, dev, request);
 
-	if (!err)
+	if (!err) {
 		nl80211_send_scan_start(drv, dev);
+		dev_hold(dev);
+	}
 
  out_free:
 	if (err) {
@@ -2899,11 +2914,11 @@ static int nl80211_dump_scan(struct sk_b
 		cb->args[0] = ifidx;
 	}
 
-	netdev = dev_get_by_index(&init_net, ifidx);
+	netdev = dev_get_by_index(sock_net(skb->sk), ifidx);
 	if (!netdev)
 		return -ENODEV;
 
-	dev = cfg80211_get_dev_from_ifindex(ifidx);
+	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
 	if (IS_ERR(dev)) {
 		err = PTR_ERR(dev);
 		goto out_put_netdev;
@@ -2963,7 +2978,7 @@ static int nl80211_authenticate(struct s
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3040,7 +3055,7 @@ static int nl80211_associate(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3124,7 +3139,7 @@ static int nl80211_deauthenticate(struct
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3189,7 +3204,7 @@ static int nl80211_disassociate(struct s
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3264,7 +3279,7 @@ static int nl80211_join_ibss(struct sk_b
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3324,7 +3339,7 @@ static int nl80211_leave_ibss(struct sk_
 
 	rtnl_lock();
 
-	err = get_drv_dev_by_info_ifindex(info->attrs, &drv, &dev);
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
 		goto unlock_rtnl;
 
@@ -3353,6 +3368,47 @@ unlock_rtnl:
 	return err;
 }
 
+static int nl80211_wiphy_netns(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	struct net *net;
+	int err;
+	u32 pid;
+
+	if (!info->attrs[NL80211_ATTR_PID])
+		return -EINVAL;
+
+	pid = nla_get_u32(info->attrs[NL80211_ATTR_PID]);
+
+	rtnl_lock();
+
+	drv = cfg80211_get_dev_from_info(info);
+	if (IS_ERR(drv)) {
+		err = PTR_ERR(drv);
+		goto out;
+	}
+
+	net = get_net_ns_by_pid(pid);
+	if (IS_ERR(net)) {
+		err = PTR_ERR(net);
+		goto out;
+	}
+
+	err = 0;
+
+	/* check if anything to do */
+	if (net_eq(drv->wiphy.net, net))
+		goto out_put_net;
+
+	err = cfg80211_switch_netns(drv, net);
+ out_put_net:
+	put_net(net);
+ out:
+	cfg80211_put_dev(drv);
+	rtnl_unlock();
+	return err;
+}
+
 static struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_GET_WIPHY,
@@ -3566,6 +3622,12 @@ static struct genl_ops nl80211_ops[] = {
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NL80211_CMD_SET_WIPHY_NETNS,
+		.doit = nl80211_wiphy_netns,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 static struct genl_multicast_group nl80211_mlme_mcgrp = {
 	.name = "mlme",
@@ -3597,7 +3659,8 @@ void nl80211_notify_dev_rename(struct cf
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_config_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_config_mcgrp.id, GFP_KERNEL);
 }
 
 static int nl80211_add_scan_req(struct sk_buff *msg,
@@ -3672,7 +3735,8 @@ void nl80211_send_scan_start(struct cfg8
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
@@ -3690,7 +3754,8 @@ void nl80211_send_scan_done(struct cfg80
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
@@ -3708,7 +3773,8 @@ void nl80211_send_scan_aborted(struct cf
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 /*
@@ -3793,7 +3859,8 @@ static void nl80211_send_mlme_event(stru
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
@@ -3857,7 +3924,8 @@ static void nl80211_send_mlme_timeout(st
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
@@ -3904,7 +3972,8 @@ void nl80211_send_ibss_bssid(struct cfg8
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, gfp);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
  nla_put_failure:
@@ -3944,7 +4013,8 @@ void nl80211_michael_mic_failure(struct 
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast_netns(rdev->wiphy.net, msg, 0,
+				nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
--- wireless-testing.orig/net/wireless/core.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/wireless/core.c	2009-06-18 14:07:09.000000000 +0200
@@ -106,7 +106,7 @@ __cfg80211_drv_from_info(struct genl_inf
 
 	if (info->attrs[NL80211_ATTR_IFINDEX]) {
 		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
-		dev = dev_get_by_index(&init_net, ifindex);
+		dev = dev_get_by_index(info->net, ifindex);
 		if (dev) {
 			if (dev->ieee80211_ptr)
 				byifidx =
@@ -151,13 +151,13 @@ cfg80211_get_dev_from_info(struct genl_i
 }
 
 struct cfg80211_registered_device *
-cfg80211_get_dev_from_ifindex(int ifindex)
+cfg80211_get_dev_from_ifindex(struct net *net, int ifindex)
 {
 	struct cfg80211_registered_device *drv = ERR_PTR(-ENODEV);
 	struct net_device *dev;
 
 	mutex_lock(&cfg80211_mutex);
-	dev = dev_get_by_index(&init_net, ifindex);
+	dev = dev_get_by_index(net, ifindex);
 	if (!dev)
 		goto out;
 	if (dev->ieee80211_ptr) {
@@ -228,6 +228,42 @@ int cfg80211_dev_rename(struct cfg80211_
 	return 0;
 }
 
+int cfg80211_switch_netns(struct cfg80211_registered_device *drv,
+			  struct net *net)
+{
+	struct wireless_dev *wdev;
+	int err = 0;
+
+	if (!drv->wiphy.netnsok)
+		return -EOPNOTSUPP;
+
+	list_for_each_entry(wdev, &drv->netdev_list, list) {
+		wdev->netdev->features &= ~NETIF_F_NETNS_LOCAL;
+		err = dev_change_net_namespace(wdev->netdev, net, "wlan%d");
+		if (err)
+			break;
+		wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
+	}
+
+	if (err) {
+		/* failed -- clean up to old netns */
+		net = drv->wiphy.net;
+
+		list_for_each_entry_continue_reverse(wdev, &drv->netdev_list,
+						     list) {
+			wdev->netdev->features &= ~NETIF_F_NETNS_LOCAL;
+			err = dev_change_net_namespace(wdev->netdev, net,
+							"wlan%d");
+			WARN_ON(err);
+			wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
+		}
+	}
+
+	drv->wiphy.net = net;
+
+	return err;
+}
+
 static void cfg80211_rfkill_poll(struct rfkill *rfkill, void *data)
 {
 	struct cfg80211_registered_device *drv = data;
@@ -310,6 +346,8 @@ struct wiphy *wiphy_new(const struct cfg
 	drv->wiphy.dev.class = &ieee80211_class;
 	drv->wiphy.dev.platform_data = drv;
 
+	drv->wiphy.net = &init_net;
+
 	drv->rfkill_ops.set_block = cfg80211_rfkill_set_block;
 	drv->rfkill = rfkill_alloc(dev_name(&drv->wiphy.dev),
 				   &drv->wiphy.dev, RFKILL_TYPE_WLAN,
@@ -542,6 +580,9 @@ static int cfg80211_netdev_notifier_call
 	case NETDEV_REGISTER:
 		mutex_lock(&rdev->devlist_mtx);
 		list_add(&dev->ieee80211_ptr->list, &rdev->netdev_list);
+		/* can only change netns with wiphy */
+		dev->features |= NETIF_F_NETNS_LOCAL;
+
 		if (sysfs_create_link(&dev->dev.kobj, &rdev->wiphy.dev.kobj,
 				      "phy80211")) {
 			printk(KERN_ERR "wireless: failed to add phy80211 "
@@ -591,10 +632,32 @@ static struct notifier_block cfg80211_ne
 	.notifier_call = cfg80211_netdev_notifier_call,
 };
 
-static int cfg80211_init(void)
+static void __net_exit cfg80211_pernet_exit(struct net *net)
+{
+	struct cfg80211_registered_device *drv;
+
+	mutex_lock(&cfg80211_mutex);
+	rtnl_lock();
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		if (net_eq(drv->wiphy.net, net))
+			WARN_ON(cfg80211_switch_netns(drv, &init_net));
+	}
+	rtnl_unlock();
+	mutex_unlock(&cfg80211_mutex);
+}
+
+static struct pernet_operations cfg80211_pernet_ops = {
+	.exit = cfg80211_pernet_exit,
+};
+
+static int __init cfg80211_init(void)
 {
 	int err;
 
+	err = register_pernet_subsys(&cfg80211_pernet_ops);
+	if (err)
+		goto out_fail_pernet;
+
 	err = wiphy_sysfs_init();
 	if (err)
 		goto out_fail_sysfs;
@@ -622,9 +685,10 @@ out_fail_nl80211:
 out_fail_notifier:
 	wiphy_sysfs_exit();
 out_fail_sysfs:
+	unregister_pernet_subsys(&cfg80211_pernet_ops);
+out_fail_pernet:
 	return err;
 }
-
 subsys_initcall(cfg80211_init);
 
 static void cfg80211_exit(void)
@@ -634,5 +698,6 @@ static void cfg80211_exit(void)
 	unregister_netdevice_notifier(&cfg80211_netdev_notifier);
 	wiphy_sysfs_exit();
 	regulatory_exit();
+	unregister_pernet_subsys(&cfg80211_pernet_ops);
 }
 module_exit(cfg80211_exit);
--- wireless-testing.orig/net/wireless/core.h	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/wireless/core.h	2009-06-18 13:54:23.000000000 +0200
@@ -144,10 +144,13 @@ struct wiphy *wiphy_idx_to_wiphy(int wip
 
 /* identical to cfg80211_get_dev_from_info but only operate on ifindex */
 extern struct cfg80211_registered_device *
-cfg80211_get_dev_from_ifindex(int ifindex);
+cfg80211_get_dev_from_ifindex(struct net *net, int ifindex);
 
 extern void cfg80211_put_dev(struct cfg80211_registered_device *drv);
 
+int cfg80211_switch_netns(struct cfg80211_registered_device *drv,
+			  struct net *net);
+
 /* free object */
 extern void cfg80211_dev_free(struct cfg80211_registered_device *drv);
 
--- wireless-testing.orig/net/wireless/scan.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/wireless/scan.c	2009-06-18 13:54:23.000000000 +0200
@@ -24,9 +24,7 @@ void cfg80211_scan_done(struct cfg80211_
 	union iwreq_data wrqu;
 #endif
 
-	dev = dev_get_by_index(&init_net, request->ifidx);
-	if (!dev)
-		goto out;
+	dev = request->dev;
 
 	WARN_ON(request != wiphy_to_dev(request->wiphy)->scan_req);
 
@@ -47,7 +45,6 @@ void cfg80211_scan_done(struct cfg80211_
 
 	dev_put(dev);
 
- out:
 	kfree(request);
 }
 EXPORT_SYMBOL(cfg80211_scan_done);
@@ -586,7 +583,7 @@ int cfg80211_wext_siwscan(struct net_dev
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
-	rdev = cfg80211_get_dev_from_ifindex(dev->ifindex);
+	rdev = cfg80211_get_dev_from_ifindex(dev_net(dev), dev->ifindex);
 
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
@@ -611,7 +608,7 @@ int cfg80211_wext_siwscan(struct net_dev
 	}
 
 	creq->wiphy = wiphy;
-	creq->ifidx = dev->ifindex;
+	creq->dev = dev;
 	creq->ssids = (void *)(creq + 1);
 	creq->channels = (void *)(creq->ssids + 1);
 	creq->n_channels = n_channels;
@@ -648,8 +645,10 @@ int cfg80211_wext_siwscan(struct net_dev
 	if (err) {
 		rdev->scan_req = NULL;
 		kfree(creq);
-	} else
+	} else {
 		nl80211_send_scan_start(rdev, dev);
+		dev_hold(dev);
+	}
  out:
 	cfg80211_put_dev(rdev);
 	return err;
@@ -942,7 +941,7 @@ int cfg80211_wext_giwscan(struct net_dev
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
-	rdev = cfg80211_get_dev_from_ifindex(dev->ifindex);
+	rdev = cfg80211_get_dev_from_ifindex(dev_net(dev), dev->ifindex);
 
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
--- wireless-testing.orig/net/mac80211/iface.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/mac80211/iface.c	2009-06-18 13:57:17.000000000 +0200
@@ -812,6 +812,7 @@ int ieee80211_if_add(struct ieee80211_lo
 			    name, ieee80211_if_setup);
 	if (!ndev)
 		return -ENOMEM;
+	dev_net_set(ndev, local->hw.wiphy->net);
 
 	ndev->needed_headroom = local->tx_headroom +
 				4*6 /* four MAC addresses */
--- wireless-testing.orig/include/linux/nl80211.h	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/include/linux/nl80211.h	2009-06-18 13:54:23.000000000 +0200
@@ -242,6 +242,9 @@
  * @NL80211_CMD_LEAVE_IBSS: Leave the IBSS -- no special arguments, the IBSS is
  *	determined by the network interface.
  *
+ * @NL80211_CMD_SET_WIPHY_NETNS: Set a wiphy's netns. Note that all devices
+ *	associated with this wiphy must be down and will follow.
+ *
  * @NL80211_CMD_MAX: highest used command number
  * @__NL80211_CMD_AFTER_LAST: internal use
  */
@@ -310,6 +313,8 @@ enum nl80211_commands {
 	NL80211_CMD_JOIN_IBSS,
 	NL80211_CMD_LEAVE_IBSS,
 
+	NL80211_CMD_SET_WIPHY_NETNS,
+
 	/* add new commands above here */
 
 	/* used to define NL80211_CMD_MAX below */
@@ -511,6 +516,8 @@ enum nl80211_commands {
  *	authorized by user space. Otherwise, port is marked authorized by
  *	default in station mode.
  *
+ * @NL80211_ATTR_PID: Process ID of a network namespace.
+ *
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
  */
@@ -619,6 +626,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_CONTROL_PORT,
 
+	NL80211_ATTR_PID,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
--- wireless-testing.orig/net/core/dev.c	2009-06-18 13:45:22.000000000 +0200
+++ wireless-testing/net/core/dev.c	2009-06-18 13:54:23.000000000 +0200
@@ -5011,6 +5011,7 @@ int dev_change_net_namespace(struct net_
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(dev_change_net_namespace);
 
 static int dev_cpu_callback(struct notifier_block *nfb,
 			    unsigned long action,


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
