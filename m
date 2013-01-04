From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next V6 11/15] vlan: remove usage of dev->master in __vlan_find_dev_deep()
Date: Fri,  4 Jan 2013 09:48:59 +0100
Message-ID: <1357289343-817-12-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357289343-817-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Also, since all users call __vlan_find_dev_deep() with rcu_read_lock,
make no possibility to call this with rtnl mutex held only.

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 net/8021q/vlan_core.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 65e06ab..380440b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -60,21 +60,25 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	return true;
 }
 
-/* Must be invoked with rcu_read_lock or with RTNL. */
-struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
+/* Must be invoked with rcu_read_lock. */
+struct net_device *__vlan_find_dev_deep(struct net_device *dev,
 					u16 vlan_id)
 {
-	struct vlan_info *vlan_info = rcu_dereference_rtnl(real_dev->vlan_info);
+	struct vlan_info *vlan_info = rcu_dereference(dev->vlan_info);
 
 	if (vlan_info) {
 		return vlan_group_get_device(&vlan_info->grp, vlan_id);
 	} else {
 		/*
-		 * Bonding slaves do not have grp assigned to themselves.
-		 * Grp is assigned to bonding master instead.
+		 * Lower devices of master uppers (bonding, team) do not have
+		 * grp assigned to themselves. Grp is assigned to upper device
+		 * instead.
 		 */
-		if (netif_is_bond_slave(real_dev))
-			return __vlan_find_dev_deep(real_dev->master, vlan_id);
+		struct net_device *upper_dev;
+
+		upper_dev = netdev_master_upper_dev_get_rcu(dev);
+		if (upper_dev)
+			return __vlan_find_dev_deep(upper_dev, vlan_id);
 	}
 
 	return NULL;
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
