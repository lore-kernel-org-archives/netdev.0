From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 4/6] bridge: a netlink notification should be sent when those attributes are changed by br_sysfs_br
Date: Tue,  5 Apr 2016 11:32:39 +0800
Message-ID: <9bf0874c74438a287968ef5190599214333b52be.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1459827115.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
 <baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33252 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcDEDdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:33:09 -0400
Received: by mail-pf0-f196.google.com with SMTP id e190so151314pfe.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:33:08 -0700 (PDT)
In-Reply-To: <baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when we change the attributes of bridge or br_port by netlink,
a relevant netlink notification will be sent, but if we change them
by ioctl or sysfs, no notification will be sent.

We should ensure that whenever those attributes change internally or from
sysfs/ioctl, that a netlink notification is sent out to listeners.

Also, NetworkManager will use this in the future to listen for out-of-band
bridge master attribute updates and incorporate them into the runtime
configuration.

This patch is used for br_sysfs_br. and we also need to remove some
rtnl_trylock in old functions so that we can call it in a common one.

For group_addr_store, we cannot make it use store_bridge_parm, because
it's not a string-to-long convert, we will add notification on it
individually.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 18 +++++++++---------
 net/bridge/br_vlan.c     | 30 +++++-------------------------
 2 files changed, 14 insertions(+), 34 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 9918763..74d56dfd 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -43,7 +43,14 @@ static ssize_t store_bridge_parm(struct device *d,
 	if (endp == buf)
 		return -EINVAL;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	err = (*set)(br, val);
+	if (!err)
+		netdev_state_change(br->dev);
+	rtnl_unlock();
+
 	return err ? err : len;
 }
 
@@ -101,15 +108,7 @@ static ssize_t ageing_time_show(struct device *d,
 
 static int set_ageing_time(struct net_bridge *br, unsigned long val)
 {
-	int ret;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = br_set_ageing_time(br, val);
-	rtnl_unlock();
-
-	return ret;
+	return br_set_ageing_time(br, val);
 }
 
 static ssize_t ageing_time_store(struct device *d,
@@ -311,6 +310,7 @@ static ssize_t group_addr_store(struct device *d,
 
 	br->group_addr_set = true;
 	br_recalculate_fwd_mask(br);
+	netdev_state_change(br->dev);
 
 	rtnl_unlock();
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 9309bb4..e001152 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -651,15 +651,7 @@ int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 {
-	int err;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	err = __br_vlan_filter_toggle(br, val);
-	rtnl_unlock();
-
-	return err;
+	return __br_vlan_filter_toggle(br, val);
 }
 
 int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
@@ -713,18 +705,10 @@ err_filt:
 
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 {
-	int err;
-
 	if (val != ETH_P_8021Q && val != ETH_P_8021AD)
 		return -EPROTONOSUPPORT;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	err = __br_vlan_set_proto(br, htons(val));
-	rtnl_unlock();
-
-	return err;
+	return __br_vlan_set_proto(br, htons(val));
 }
 
 static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 vid)
@@ -855,21 +839,17 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 	if (val >= VLAN_VID_MASK)
 		return -EINVAL;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
 	if (pvid == br->default_pvid)
-		goto unlock;
+		goto out;
 
 	/* Only allow default pvid change when filtering is disabled */
 	if (br->vlan_enabled) {
 		pr_info_once("Please disable vlan filtering to change default_pvid\n");
 		err = -EPERM;
-		goto unlock;
+		goto out;
 	}
 	err = __br_vlan_set_default_pvid(br, pvid);
-unlock:
-	rtnl_unlock();
+out:
 	return err;
 }
 
-- 
2.1.0
