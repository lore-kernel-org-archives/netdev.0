From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v6 1/2] bridge: netlink: make setlink/dellink notifications more accurate
Date: Fri, 27 Oct 2017 13:19:36 +0300
Message-ID: <1509099577-5959-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1f6df7e3-cd05-9b96-9f45-49c433011ff2@cumulusnetworks.com>
 <1509099577-5959-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, mrv@mojatatu.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, makita.toshiaki@lab.ntt.co.jp,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:46105 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752456AbdJ0K22 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 06:28:28 -0400
Received: by mail-wm0-f65.google.com with SMTP id m72so2637664wmc.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 03:28:27 -0700 (PDT)
In-Reply-To: <1509099577-5959-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch we had cases that either sent notifications when there
were in fact no changes (e.g. non-existent vlan delete) or didn't send
notifications when there were changes (e.g. vlan add range with an error in
the middle, port flags change + vlan update error). This patch sends down
a boolean to the functions setlink/dellink use and if there is even a
single configuration change (port flag, vlan add/del, port state) then
we always send a notification. This is all done to keep backwards
compatibility with the opportunistic vlan delete, where one could
specify a vlan range that has missing vlans inside and still everything
in that range will be cleared, this is mostly used to clear the whole
vlan config with a single call, i.e. range 1-4094.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
---
v6: no changes

 net/bridge/br_netlink.c        | 44 +++++++++++++++++++++++++-----------------
 net/bridge/br_netlink_tunnel.c | 14 +++++++++-----
 net/bridge/br_private_tunnel.h |  3 ++-
 3 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index fb61b6c79235..d0290ede9342 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -506,7 +506,7 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 }
 
 static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
-			int cmd, struct bridge_vlan_info *vinfo)
+			int cmd, struct bridge_vlan_info *vinfo, bool *changed)
 {
 	int err = 0;
 
@@ -517,21 +517,24 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 			 * per-VLAN entry as well
 			 */
 			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
-			if (err)
-				break;
 		} else {
 			vinfo->flags |= BRIDGE_VLAN_INFO_BRENTRY;
 			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
 		}
+		if (!err)
+			*changed = true;
 		break;
 
 	case RTM_DELLINK:
 		if (p) {
-			nbp_vlan_delete(p, vinfo->vid);
-			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-				br_vlan_delete(p->br, vinfo->vid);
-		} else {
-			br_vlan_delete(br, vinfo->vid);
+			if (!nbp_vlan_delete(p, vinfo->vid))
+				*changed = true;
+
+			if ((vinfo->flags & BRIDGE_VLAN_INFO_MASTER) &&
+			    !br_vlan_delete(p->br, vinfo->vid))
+				*changed = true;
+		} else if (!br_vlan_delete(br, vinfo->vid)) {
+			*changed = true;
 		}
 		break;
 	}
@@ -542,7 +545,8 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 static int br_process_vlan_info(struct net_bridge *br,
 				struct net_bridge_port *p, int cmd,
 				struct bridge_vlan_info *vinfo_curr,
-				struct bridge_vlan_info **vinfo_last)
+				struct bridge_vlan_info **vinfo_last,
+				bool *changed)
 {
 	if (!vinfo_curr->vid || vinfo_curr->vid >= VLAN_VID_MASK)
 		return -EINVAL;
@@ -572,7 +576,7 @@ static int br_process_vlan_info(struct net_bridge *br,
 		       sizeof(struct bridge_vlan_info));
 		for (v = (*vinfo_last)->vid; v <= vinfo_curr->vid; v++) {
 			tmp_vinfo.vid = v;
-			err = br_vlan_info(br, p, cmd, &tmp_vinfo);
+			err = br_vlan_info(br, p, cmd, &tmp_vinfo, changed);
 			if (err)
 				break;
 		}
@@ -581,13 +585,13 @@ static int br_process_vlan_info(struct net_bridge *br,
 		return err;
 	}
 
-	return br_vlan_info(br, p, cmd, vinfo_curr);
+	return br_vlan_info(br, p, cmd, vinfo_curr, changed);
 }
 
 static int br_afspec(struct net_bridge *br,
 		     struct net_bridge_port *p,
 		     struct nlattr *af_spec,
-		     int cmd)
+		     int cmd, bool *changed)
 {
 	struct bridge_vlan_info *vinfo_curr = NULL;
 	struct bridge_vlan_info *vinfo_last = NULL;
@@ -607,7 +611,8 @@ static int br_afspec(struct net_bridge *br,
 				return err;
 			err = br_process_vlan_tunnel_info(br, p, cmd,
 							  &tinfo_curr,
-							  &tinfo_last);
+							  &tinfo_last,
+							  changed);
 			if (err)
 				return err;
 			break;
@@ -616,7 +621,7 @@ static int br_afspec(struct net_bridge *br,
 				return -EINVAL;
 			vinfo_curr = nla_data(attr);
 			err = br_process_vlan_info(br, p, cmd, vinfo_curr,
-						   &vinfo_last);
+						   &vinfo_last, changed);
 			if (err)
 				return err;
 			break;
@@ -804,6 +809,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
+	bool changed = false;
 	int err = 0;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
@@ -839,14 +845,15 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		}
 		if (err)
 			goto out;
+		changed = true;
 	}
 
 	if (afspec) {
 		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
-				afspec, RTM_SETLINK);
+				afspec, RTM_SETLINK, &changed);
 	}
 
-	if (err == 0)
+	if (changed)
 		br_ifinfo_notify(RTM_NEWLINK, p);
 out:
 	return err;
@@ -857,6 +864,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
+	bool changed = false;
 	int err = 0;
 
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -869,8 +877,8 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		return -EINVAL;
 
 	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
-			afspec, RTM_DELLINK);
-	if (err == 0)
+			afspec, RTM_DELLINK, &changed);
+	if (changed)
 		/* Send RTM_NEWLINK because userspace
 		 * expects RTM_NEWLINK for vlan dels
 		 */
diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
index 3712c7f0e00c..da8cb99fd259 100644
--- a/net/bridge/br_netlink_tunnel.c
+++ b/net/bridge/br_netlink_tunnel.c
@@ -198,7 +198,7 @@ static const struct nla_policy vlan_tunnel_policy[IFLA_BRIDGE_VLAN_TUNNEL_MAX +
 };
 
 static int br_vlan_tunnel_info(struct net_bridge_port *p, int cmd,
-			       u16 vid, u32 tun_id)
+			       u16 vid, u32 tun_id, bool *changed)
 {
 	int err = 0;
 
@@ -208,9 +208,12 @@ static int br_vlan_tunnel_info(struct net_bridge_port *p, int cmd,
 	switch (cmd) {
 	case RTM_SETLINK:
 		err = nbp_vlan_tunnel_info_add(p, vid, tun_id);
+		if (!err)
+			*changed = true;
 		break;
 	case RTM_DELLINK:
-		nbp_vlan_tunnel_info_delete(p, vid);
+		if (!nbp_vlan_tunnel_info_delete(p, vid))
+			*changed = true;
 		break;
 	}
 
@@ -254,7 +257,8 @@ int br_parse_vlan_tunnel_info(struct nlattr *attr,
 int br_process_vlan_tunnel_info(struct net_bridge *br,
 				struct net_bridge_port *p, int cmd,
 				struct vtunnel_info *tinfo_curr,
-				struct vtunnel_info *tinfo_last)
+				struct vtunnel_info *tinfo_last,
+				bool *changed)
 {
 	int err;
 
@@ -272,7 +276,7 @@ int br_process_vlan_tunnel_info(struct net_bridge *br,
 			return -EINVAL;
 		t = tinfo_last->tunid;
 		for (v = tinfo_last->vid; v <= tinfo_curr->vid; v++) {
-			err = br_vlan_tunnel_info(p, cmd, v, t);
+			err = br_vlan_tunnel_info(p, cmd, v, t, changed);
 			if (err)
 				return err;
 			t++;
@@ -283,7 +287,7 @@ int br_process_vlan_tunnel_info(struct net_bridge *br,
 		if (tinfo_last->flags)
 			return -EINVAL;
 		err = br_vlan_tunnel_info(p, cmd, tinfo_curr->vid,
-					  tinfo_curr->tunid);
+					  tinfo_curr->tunid, changed);
 		if (err)
 			return err;
 		memset(tinfo_last, 0, sizeof(struct vtunnel_info));
diff --git a/net/bridge/br_private_tunnel.h b/net/bridge/br_private_tunnel.h
index 4a447a378ab3..a259471bfd78 100644
--- a/net/bridge/br_private_tunnel.h
+++ b/net/bridge/br_private_tunnel.h
@@ -26,7 +26,8 @@ int br_process_vlan_tunnel_info(struct net_bridge *br,
 				struct net_bridge_port *p,
 				int cmd,
 				struct vtunnel_info *tinfo_curr,
-				struct vtunnel_info *tinfo_last);
+				struct vtunnel_info *tinfo_last,
+				bool *changed);
 int br_get_vlan_tunnel_info_size(struct net_bridge_vlan_group *vg);
 int br_fill_vlan_tunnel_info(struct sk_buff *skb,
 			     struct net_bridge_vlan_group *vg);
-- 
2.1.4
