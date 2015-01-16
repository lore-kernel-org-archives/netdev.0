From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: make nlmsg_end() and genlmsg_end() void
Date: Fri, 16 Jan 2015 22:09:00 +0100
Message-ID: <1421442540-10244-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45127 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189AbbAPVJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 16:09:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Contrary to common expectations for an "int" return, these functions
return only a positive value -- if used correctly they cannot even
return 0 because the message header will necessarily be in the skb.

This makes the very common pattern of

  if (genlmsg_end(...) < 0) { ... }

be a whole bunch of dead code. Many places also simply do

  return nlmsg_end(...);

and the caller is expected to deal with it.

This also commonly (at least for me) causes errors, because it is very
common to write

  if (my_function(...))
    /* error condition */

and if my_function() does "return nlmsg_end()" this is of course wrong.

Additionally, there's not a single place in the kernel that actually
needs the message length returned, and if anyone needs it later then
it'll be very easy to just use skb->len there.

Remove this, and make the functions void. This removes a bunch of dead
code as described above. The patch adds lines because I did

-	return nlmsg_end(...);
+	nlmsg_end(...);
+	return 0;

I could have preserved all the function's return values by returning
skb->len, but instead I've audited all the places calling the affected
functions and found that none cared. A few places actually compared
the return value with <= 0 in dump functionality, but that could just
be changed to < 0 with no change in behaviour, so I opted for the more
efficient version.

One instance of the error I've made numerous times now is also present
in net/phonet/pn_netlink.c in the route_dumpit() function - it didn't
check for <0 or <=0 and thus broke out of the loop every single time.
I've preserved this since it will (I think) have caused the messages to
userspace to be formatted differently with just a single message for
every SKB returned to userspace. It's possible that this isn't needed
for the tools that actually use this, but I don't even know what they
are so couldn't test that changing this behaviour would be acceptable.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/acpi/event.c                  |  7 +------
 drivers/net/ethernet/rocker/rocker.c  |  3 ++-
 drivers/net/vxlan.c                   |  3 ++-
 drivers/net/wireless/mac80211_hwsim.c |  3 ++-
 drivers/scsi/pmcraid.c                |  8 +-------
 drivers/target/target_core_user.c     |  4 +---
 drivers/thermal/thermal_core.c        |  6 +-----
 fs/dlm/netlink.c                      |  7 +------
 include/net/genetlink.h               |  4 ++--
 include/net/netlink.h                 |  6 +-----
 kernel/taskstats.c                    | 13 ++-----------
 net/bridge/br_fdb.c                   |  3 ++-
 net/bridge/br_mdb.c                   |  3 ++-
 net/bridge/br_netlink.c               |  3 ++-
 net/can/gw.c                          |  3 ++-
 net/core/fib_rules.c                  |  3 ++-
 net/core/neighbour.c                  | 12 ++++++++----
 net/core/rtnetlink.c                  |  9 ++++++---
 net/decnet/dn_dev.c                   |  3 ++-
 net/decnet/dn_route.c                 |  3 ++-
 net/decnet/dn_table.c                 |  3 ++-
 net/ieee802154/netlink.c              | 12 ++----------
 net/ieee802154/nl-mac.c               |  3 ++-
 net/ieee802154/nl-phy.c               |  3 ++-
 net/ieee802154/nl802154.c             |  6 ++++--
 net/ipv4/devinet.c                    |  8 +++++---
 net/ipv4/fib_semantics.c              |  3 ++-
 net/ipv4/inet_diag.c                  |  9 ++++++---
 net/ipv4/ipmr.c                       |  3 ++-
 net/ipv4/route.c                      |  3 ++-
 net/ipv4/tcp_metrics.c                |  3 ++-
 net/ipv6/addrconf.c                   | 32 +++++++++++++++++++-------------
 net/ipv6/addrlabel.c                  |  5 +++--
 net/ipv6/ip6_fib.c                    |  1 -
 net/ipv6/ip6mr.c                      |  3 ++-
 net/ipv6/route.c                      |  3 ++-
 net/l2tp/l2tp_netlink.c               | 10 ++++++----
 net/netfilter/ipvs/ip_vs_ctl.c        |  9 ++++++---
 net/netfilter/nf_tables_api.c         | 18 ++++++++++++------
 net/netlabel/netlabel_cipso_v4.c      |  3 ++-
 net/netlabel/netlabel_mgmt.c          |  6 ++++--
 net/netlabel/netlabel_unlabeled.c     |  3 ++-
 net/netlink/diag.c                    |  3 ++-
 net/netlink/genetlink.c               |  6 ++++--
 net/nfc/netlink.c                     | 12 +++++++-----
 net/openvswitch/datapath.c            |  9 ++++++---
 net/packet/diag.c                     |  3 ++-
 net/phonet/pn_netlink.c               | 16 +++++++++++-----
 net/unix/diag.c                       |  3 ++-
 net/wireless/nl80211.c                | 27 ++++++++++++++++++---------
 net/xfrm/xfrm_user.c                  | 27 ++++++++++++++++++---------
 51 files changed, 203 insertions(+), 158 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index ef2d730734dc..e24ea4e796e4 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -100,7 +100,6 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 	struct acpi_genl_event *event;
 	void *msg_header;
 	int size;
-	int result;
 
 	/* allocate memory */
 	size = nla_total_size(sizeof(struct acpi_genl_event)) +
@@ -137,11 +136,7 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 	event->data = data;
 
 	/* send multicast genetlink message */
-	result = genlmsg_end(skb, msg_header);
-	if (result < 0) {
-		nlmsg_free(skb);
-		return result;
-	}
+	genlmsg_end(skb, msg_header);
 
 	genlmsg_multicast(&acpi_event_genl_family, skb, 0, 0, GFP_ATOMIC);
 	return 0;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cad8cf962cdf..ed1e2cde6421 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3668,7 +3668,8 @@ static int rocker_fdb_fill_info(struct sk_buff *skb,
 	if (vid && nla_put_u16(skb, NDA_VLAN, vid))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6b6b45622a0a..c5f79e7513a6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -363,7 +363,8 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 494e7335aa64..4a4c6586a8d2 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2557,7 +2557,8 @@ static int mac80211_hwsim_get_radio(struct sk_buff *skb,
 	if (res < 0)
 		goto out_err;
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 out_err:
 	genlmsg_cancel(skb, hdr);
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 8c27b6a77ec4..cf222f46eac5 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -1473,13 +1473,7 @@ static int pmcraid_notify_aen(
 	}
 
 	/* send genetlink multicast message to notify appplications */
-	result = genlmsg_end(skb, msg_header);
-
-	if (result < 0) {
-		pmcraid_err("genlmsg_end failed\n");
-		nlmsg_free(skb);
-		return result;
-	}
+	genlmsg_end(skb, msg_header);
 
 	result = genlmsg_multicast(&pmcraid_event_family, skb,
 				   0, 0, GFP_ATOMIC);
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 1157b559683b..1a1bcf71ec9d 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -784,9 +784,7 @@ static int tcmu_netlink_event(enum tcmu_genl_cmd cmd, const char *name, int mino
 	if (ret < 0)
 		goto free_skb;
 
-	ret = genlmsg_end(skb, msg_header);
-	if (ret < 0)
-		goto free_skb;
+	genlmsg_end(skb, msg_header);
 
 	ret = genlmsg_multicast(&tcmu_genl_family, skb, 0,
 				TCMU_MCGRP_CONFIG, GFP_KERNEL);
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 87e0b0782023..48491d1a81d6 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -1759,11 +1759,7 @@ int thermal_generate_netlink_event(struct thermal_zone_device *tz,
 	thermal_event->event = event;
 
 	/* send multicast genetlink message */
-	result = genlmsg_end(skb, msg_header);
-	if (result < 0) {
-		nlmsg_free(skb);
-		return result;
-	}
+	genlmsg_end(skb, msg_header);
 
 	result = genlmsg_multicast(&thermal_event_genl_family, skb, 0,
 				   0, GFP_ATOMIC);
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index e7cfbaf8d0e2..1e6e227134d7 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -56,13 +56,8 @@ static int send_data(struct sk_buff *skb)
 {
 	struct genlmsghdr *genlhdr = nlmsg_data((struct nlmsghdr *)skb->data);
 	void *data = genlmsg_data(genlhdr);
-	int rv;
 
-	rv = genlmsg_end(skb, data);
-	if (rv < 0) {
-		nlmsg_free(skb);
-		return rv;
-	}
+	genlmsg_end(skb, data);
 
 	return genlmsg_unicast(&init_net, skb, listener_nlportid);
 }
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 84125088c309..f24aa83b80b6 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -245,9 +245,9 @@ static inline void *genlmsg_put_reply(struct sk_buff *skb,
  * @skb: socket buffer the message is stored in
  * @hdr: user specific header
  */
-static inline int genlmsg_end(struct sk_buff *skb, void *hdr)
+static inline void genlmsg_end(struct sk_buff *skb, void *hdr)
 {
-	return nlmsg_end(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
+	nlmsg_end(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
 }
 
 /**
diff --git a/include/net/netlink.h b/include/net/netlink.h
index d5869b90bfbb..e010ee8da41d 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -490,14 +490,10 @@ static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
  * Corrects the netlink message header to include the appeneded
  * attributes. Only necessary if attributes have been added to
  * the message.
- *
- * Returns the total data length of the skb.
  */
-static inline int nlmsg_end(struct sk_buff *skb, struct nlmsghdr *nlh)
+static inline void nlmsg_end(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	nlh->nlmsg_len = skb_tail_pointer(skb) - (unsigned char *)nlh;
-
-	return skb->len;
 }
 
 /**
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 670fff88a961..21f82c29c914 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -111,13 +111,8 @@ static int send_reply(struct sk_buff *skb, struct genl_info *info)
 {
 	struct genlmsghdr *genlhdr = nlmsg_data(nlmsg_hdr(skb));
 	void *reply = genlmsg_data(genlhdr);
-	int rc;
 
-	rc = genlmsg_end(skb, reply);
-	if (rc < 0) {
-		nlmsg_free(skb);
-		return rc;
-	}
+	genlmsg_end(skb, reply);
 
 	return genlmsg_reply(skb, info);
 }
@@ -134,11 +129,7 @@ static void send_cpu_listeners(struct sk_buff *skb,
 	void *reply = genlmsg_data(genlhdr);
 	int rc, delcount = 0;
 
-	rc = genlmsg_end(skb, reply);
-	if (rc < 0) {
-		nlmsg_free(skb);
-		return;
-	}
+	genlmsg_end(skb, reply);
 
 	rc = 0;
 	down_read(&listeners->sem);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e6e0372bc3cd..ef389374c5bc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -633,7 +633,8 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	if (fdb->vlan_id && nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index fed61c971b17..409608960899 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -190,7 +190,8 @@ static int nlmsg_populate_mdb_fill(struct sk_buff *skb,
 
 	nla_nest_end(skb, nest2);
 	nla_nest_end(skb, nest);
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 end:
 	nla_nest_end(skb, nest);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 66ece91ee165..07d88a6f1003 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -263,7 +263,8 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	}
 
 done:
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/can/gw.c b/net/can/gw.c
index 295f62e62eb3..a6f448e18ea8 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -575,7 +575,8 @@ static int cgw_put_job(struct sk_buff *skb, struct cgw_job *gwj, int type,
 			goto cancel;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 cancel:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 185c341fafbd..44706e81b2e0 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -609,7 +609,8 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	if (ops->fill(rule, skb, frh) < 0)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8d614c93f86a..d36d564f149f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1884,7 +1884,8 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 		goto nla_put_failure;
 
 	read_unlock_bh(&tbl->lock);
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	read_unlock_bh(&tbl->lock);
@@ -1917,7 +1918,8 @@ static int neightbl_fill_param_info(struct sk_buff *skb,
 		goto errout;
 
 	read_unlock_bh(&tbl->lock);
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 errout:
 	read_unlock_bh(&tbl->lock);
 	nlmsg_cancel(skb, nlh);
@@ -2202,7 +2204,8 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	    nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -2232,7 +2235,8 @@ static int pneigh_fill_info(struct sk_buff *skb, struct pneigh_entry *pn,
 	if (nla_put(skb, NDA_DST, tbl->key_len, pn->key))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6a6cdade1676..a852bded8edf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1199,7 +1199,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	nla_nest_end(skb, af_spec);
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -2326,7 +2327,8 @@ static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -2809,7 +2811,8 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 
 	nla_nest_end(skb, protinfo);
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 4400da7739da..b2c26b081134 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -702,7 +702,8 @@ static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
 	     nla_put_u32(skb, IFA_FLAGS, ifa_flags))
 		goto nla_put_failure;
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index daccc4a36d80..812e5e6e88fb 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1616,7 +1616,8 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	    nla_put_u32(skb, RTA_IIF, rt->fld.flowidn_iif) < 0)
 		goto errout;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 errout:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 3f19fcbf126d..1540b506e3e0 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -367,7 +367,8 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		nla_nest_end(skb, mp_head);
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 errout:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index fa1464762d0d..c8133c07ceee 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -63,13 +63,9 @@ int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 	struct nlmsghdr *nlh = nlmsg_hdr(msg);
 	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
-	if (genlmsg_end(msg, hdr) < 0)
-		goto out;
+	genlmsg_end(msg, hdr);
 
 	return genlmsg_multicast(&nl802154_family, msg, 0, group, GFP_ATOMIC);
-out:
-	nlmsg_free(msg);
-	return -ENOBUFS;
 }
 
 struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
@@ -96,13 +92,9 @@ int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
 	struct nlmsghdr *nlh = nlmsg_hdr(msg);
 	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
-	if (genlmsg_end(msg, hdr) < 0)
-		goto out;
+	genlmsg_end(msg, hdr);
 
 	return genlmsg_reply(msg, info);
-out:
-	nlmsg_free(msg);
-	return -ENOBUFS;
 }
 
 static const struct genl_ops ieee8021154_ops[] = {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 3c902e9516fb..9105265920fe 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -136,7 +136,8 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	}
 
 	wpan_phy_put(phy);
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	wpan_phy_put(phy);
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 7baf98b14611..1b9d25f6e898 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -65,7 +65,8 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 		goto nla_put_failure;
 	mutex_unlock(&phy->pib_lock);
 	kfree(buf);
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	mutex_unlock(&phy->pib_lock);
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index a25b9bbd077b..a4daf91b8d0a 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -306,7 +306,8 @@ static int nl802154_send_wpan_phy(struct cfg802154_registered_device *rdev,
 		goto nla_put_failure;
 
 finish:
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -489,7 +490,8 @@ nl802154_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 	if (nla_put_u8(msg, NL802154_ATTR_LBT_MODE, wpan_dev->lbt))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 214882e7d6de..5f344eb3fc25 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1522,7 +1522,8 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 			  preferred, valid))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -1566,7 +1567,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				if (inet_fill_ifaddr(skb, ifa,
 					     NETLINK_CB(cb->skb).portid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
+					     RTM_NEWADDR, NLM_F_MULTI) < 0) {
 					rcu_read_unlock();
 					goto done;
 				}
@@ -1749,7 +1750,8 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 			IPV4_DEVCONF(*devconf, PROXY_ARP)) < 0)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d2b7b5521b1b..265cb72b7c1b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1091,7 +1091,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		nla_nest_end(skb, mp);
 	}
 #endif
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e34dccbc4d70..81751f12645f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -203,7 +203,8 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		icsk->icsk_ca_ops->get_info(sk, ext, skb);
 
 out:
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 errout:
 	nlmsg_cancel(skb, nlh);
@@ -271,7 +272,8 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	}
 #endif
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
@@ -758,7 +760,8 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	}
 #endif
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c8034587859d..9d78427652d2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2290,7 +2290,8 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	if (err < 0 && err != -ENOENT)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ce112d0f2698..f6e43ca5e641 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2390,7 +2390,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index ed9c9a91851c..e5f41bd5ec1b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -886,7 +886,8 @@ static int tcp_metrics_dump_info(struct sk_buff *skb,
 	if (tcp_metrics_fill_info(skb, tm) < 0)
 		goto nla_put_failure;
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbeb27b7..8975d9501d50 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -489,7 +489,8 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH, devconf->proxy_ndp) < 0)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -619,7 +620,7 @@ static int inet6_netconf_dump_devconf(struct sk_buff *skb,
 						       cb->nlh->nlmsg_seq,
 						       RTM_NEWNETCONF,
 						       NLM_F_MULTI,
-						       -1) <= 0) {
+						       -1) < 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -635,7 +636,7 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) <= 0)
+					       -1) < 0)
 			goto done;
 		else
 			h++;
@@ -646,7 +647,7 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) <= 0)
+					       -1) < 0)
 			goto done;
 		else
 			h++;
@@ -4047,7 +4048,8 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	if (nla_put_u32(skb, IFA_FLAGS, ifa->flags) < 0)
 		goto error;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 error:
 	nlmsg_cancel(skb, nlh);
@@ -4076,7 +4078,8 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 		return -EMSGSIZE;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
@@ -4101,7 +4104,8 @@ static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 		return -EMSGSIZE;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 enum addr_type_t {
@@ -4134,7 +4138,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 						cb->nlh->nlmsg_seq,
 						RTM_NEWADDR,
 						NLM_F_MULTI);
-			if (err <= 0)
+			if (err < 0)
 				break;
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 		}
@@ -4151,7 +4155,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 						  cb->nlh->nlmsg_seq,
 						  RTM_GETMULTICAST,
 						  NLM_F_MULTI);
-			if (err <= 0)
+			if (err < 0)
 				break;
 		}
 		break;
@@ -4166,7 +4170,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 						  cb->nlh->nlmsg_seq,
 						  RTM_GETANYCAST,
 						  NLM_F_MULTI);
-			if (err <= 0)
+			if (err < 0)
 				break;
 		}
 		break;
@@ -4638,7 +4642,8 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 		goto nla_put_failure;
 
 	nla_nest_end(skb, protoinfo);
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -4670,7 +4675,7 @@ static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			if (inet6_fill_ifinfo(skb, idev,
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
-					      RTM_NEWLINK, NLM_F_MULTI) <= 0)
+					      RTM_NEWLINK, NLM_F_MULTI) < 0)
 				goto out;
 cont:
 			idx++;
@@ -4747,7 +4752,8 @@ static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
 	ci.valid_time = ntohl(pinfo->valid);
 	if (nla_put(skb, PREFIX_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index fd0dc47f471d..e43e79d0a612 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -490,7 +490,8 @@ static int ip6addrlbl_fill(struct sk_buff *skb,
 		return -EMSGSIZE;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
@@ -510,7 +511,7 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWADDRLABEL,
 					      NLM_F_MULTI);
-			if (err <= 0)
+			if (err < 0)
 				break;
 		}
 		idx++;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 03c520a4ebeb..53775ee7d376 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -277,7 +277,6 @@ static int fib6_dump_node(struct fib6_walker *w)
 			w->leaf = rt;
 			return 1;
 		}
-		WARN_ON(res == 0);
 	}
 	w->leaf = NULL;
 	return 0;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 722669754bbf..34b682617f50 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2388,7 +2388,8 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (err < 0 && err != -ENOENT)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 34dcbb59df75..c60f15775c53 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2725,7 +2725,8 @@ static int rt6_fill_node(struct net *net,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 6b16598f31d5..b4e923f77954 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -390,7 +390,8 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 	}
 
 out:
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
@@ -451,7 +452,7 @@ static int l2tp_nl_cmd_tunnel_dump(struct sk_buff *skb, struct netlink_callback
 
 		if (l2tp_nl_tunnel_send(skb, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					tunnel, L2TP_CMD_TUNNEL_GET) <= 0)
+					tunnel, L2TP_CMD_TUNNEL_GET) < 0)
 			goto out;
 
 		ti++;
@@ -752,7 +753,8 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int fl
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(skb, hdr);
@@ -816,7 +818,7 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback
 
 		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					 session, L2TP_CMD_SESSION_GET) <= 0)
+					 session, L2TP_CMD_SESSION_GET) < 0)
 			break;
 
 		si++;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8295a430a56..e55759056361 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2887,7 +2887,8 @@ static int ip_vs_genl_dump_service(struct sk_buff *skb,
 	if (ip_vs_genl_fill_service(skb, svc) < 0)
 		goto nla_put_failure;
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
@@ -3079,7 +3080,8 @@ static int ip_vs_genl_dump_dest(struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (ip_vs_genl_fill_dest(skb, dest) < 0)
 		goto nla_put_failure;
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
@@ -3215,7 +3217,8 @@ static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
 	if (ip_vs_genl_fill_daemon(skb, state, mcast_ifn, syncid))
 		goto nla_put_failure;
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3b3ddb4fb9ee..70f697827b9b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -427,7 +427,8 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
 	    nla_put_be32(skb, NFTA_TABLE_USE, htonl(table->use)))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
@@ -971,7 +972,8 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 	if (nla_put_be32(skb, NFTA_CHAIN_USE, htonl(chain->use)))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
@@ -1707,7 +1709,8 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 	    nla_put(skb, NFTA_RULE_USERDATA, rule->ulen, nft_userdata(rule)))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
@@ -2361,7 +2364,8 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 		goto nla_put_failure;
 	nla_nest_end(skb, desc);
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
@@ -3035,7 +3039,8 @@ static int nf_tables_fill_setelem_info(struct sk_buff *skb,
 
 	nla_nest_end(skb, nest);
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
@@ -3324,7 +3329,8 @@ static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 	if (nla_put_be32(skb, NFTA_GEN_ID, htonl(net->nft.base_seq)))
 		goto nla_put_failure;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, nlh);
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index c2f2a53a4879..179625353cac 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -641,7 +641,8 @@ static int netlbl_cipsov4_listall_cb(struct cipso_v4_doi *doi_def, void *arg)
 	if (ret_val != 0)
 		goto listall_cb_failure;
 
-	return genlmsg_end(cb_arg->skb, data);
+	genlmsg_end(cb_arg->skb, data);
+	return 0;
 
 listall_cb_failure:
 	genlmsg_cancel(cb_arg->skb, data);
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index e66e977ef2fa..8b3b789c43c2 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -456,7 +456,8 @@ static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
 		goto listall_cb_failure;
 
 	cb_arg->seq++;
-	return genlmsg_end(cb_arg->skb, data);
+	genlmsg_end(cb_arg->skb, data);
+	return 0;
 
 listall_cb_failure:
 	genlmsg_cancel(cb_arg->skb, data);
@@ -620,7 +621,8 @@ static int netlbl_mgmt_protocols_cb(struct sk_buff *skb,
 	if (ret_val != 0)
 		goto protocols_cb_failure;
 
-	return genlmsg_end(skb, data);
+	genlmsg_end(skb, data);
+	return 0;
 
 protocols_cb_failure:
 	genlmsg_cancel(skb, data);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 78a63c18779e..aec7994f78cf 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1163,7 +1163,8 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 		goto list_cb_failure;
 
 	cb_arg->seq++;
-	return genlmsg_end(cb_arg->skb, data);
+	genlmsg_end(cb_arg->skb, data);
+	return 0;
 
 list_cb_failure:
 	genlmsg_cancel(cb_arg->skb, data);
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index bb59a7ed0859..3ee63a3cff30 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -91,7 +91,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	    sk_diag_put_rings_cfg(sk, skb))
 		goto out_nlmsg_trim;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 out_nlmsg_trim:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2e11061ef885..f52a7d5734cd 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -756,7 +756,8 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 		nla_nest_end(skb, nla_grps);
 	}
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
@@ -796,7 +797,8 @@ static int ctrl_fill_mcgrp_info(struct genl_family *family,
 	nla_nest_end(skb, nest);
 	nla_nest_end(skb, nla_grps);
 
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, hdr);
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 44989fc8cddf..be387e6219a0 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -102,7 +102,8 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 			goto nla_put_failure;
 	}
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -518,7 +519,8 @@ static int nfc_genl_send_device(struct sk_buff *msg, struct nfc_dev *dev,
 	    nla_put_u8(msg, NFC_ATTR_RF_MODE, dev->rf_mode))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -908,7 +910,8 @@ static int nfc_genl_send_params(struct sk_buff *msg,
 	    nla_put_u16(msg, NFC_ATTR_LLC_PARAM_MIUX, be16_to_cpu(local->miux)))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 
@@ -1247,8 +1250,7 @@ static int nfc_genl_send_se(struct sk_buff *msg, struct nfc_dev *dev,
 		    nla_put_u8(msg, NFC_ATTR_SE_TYPE, se->type))
 			goto nla_put_failure;
 
-		if (genlmsg_end(msg, hdr) < 0)
-			goto nla_put_failure;
+		genlmsg_end(msg, hdr);
 	}
 
 	return 0;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8bda3cc12344..f45f1bf4422c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -799,7 +799,8 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 	if (err)
 		goto error;
 
-	return genlmsg_end(skb, ovs_header);
+	genlmsg_end(skb, ovs_header);
+	return 0;
 
 error:
 	genlmsg_cancel(skb, ovs_header);
@@ -1349,7 +1350,8 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 	if (nla_put_u32(skb, OVS_DP_ATTR_USER_FEATURES, dp->user_features))
 		goto nla_put_failure;
 
-	return genlmsg_end(skb, ovs_header);
+	genlmsg_end(skb, ovs_header);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(skb, ovs_header);
@@ -1723,7 +1725,8 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 	if (err == -EMSGSIZE)
 		goto error;
 
-	return genlmsg_end(skb, ovs_header);
+	genlmsg_end(skb, ovs_header);
+	return 0;
 
 nla_put_failure:
 	err = -EMSGSIZE;
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 92f2c7107eec..0ed68f0238bf 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -177,7 +177,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 				     PACKET_DIAG_FILTER))
 		goto out_nlmsg_trim;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 out_nlmsg_trim:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index b64151ade6b3..54d766842c2b 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -121,7 +121,8 @@ static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
 	ifm->ifa_index = dev->ifindex;
 	if (nla_put_u8(skb, IFA_LOCAL, addr))
 		goto nla_put_failure;
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -190,7 +191,8 @@ static int fill_route(struct sk_buff *skb, struct net_device *dev, u8 dst,
 	if (nla_put_u8(skb, RTA_DST, dst) ||
 	    nla_put_u32(skb, RTA_OIF, dev->ifindex))
 		goto nla_put_failure;
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
@@ -282,9 +284,13 @@ static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (addr_idx++ < addr_start_idx)
 			continue;
-		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, RTM_NEWROUTE))
-			goto out;
+		fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
+			   cb->nlh->nlmsg_seq, RTM_NEWROUTE);
+		/* fill_route() used to return > 0 (or negative errors) but
+		 * never 0 - ignore the return value and just go out to
+		 * call dumpit again from outside to preserve the behavior
+		 */
+		goto out;
 	}
 
 out:
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 86fa0f3b2caf..ef542fbca9fe 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -155,7 +155,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	if (nla_put_u8(skb, UNIX_DIAG_SHUTDOWN, sk->sk_shutdown))
 		goto out_nlmsg_trim;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 out_nlmsg_trim:
 	nlmsg_cancel(skb, nlh);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 380784378df8..4ed9039bd5f9 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1721,7 +1721,8 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		break;
 	}
  finish:
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -2404,7 +2405,8 @@ static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flag
 			goto nla_put_failure;
 	}
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -3825,7 +3827,8 @@ static int nl80211_send_station(struct sk_buff *msg, u32 cmd, u32 portid,
 		    sinfo->assoc_req_ies))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -4555,7 +4558,8 @@ static int nl80211_send_mpath(struct sk_buff *msg, u32 portid, u32 seq,
 
 	nla_nest_end(msg, pinfoattr);
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -5507,7 +5511,8 @@ static int nl80211_send_regdom(struct sk_buff *msg, struct netlink_callback *cb,
 	    nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -6577,7 +6582,8 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 
 	nla_nest_end(msg, bss);
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  fail_unlock_rcu:
 	rcu_read_unlock();
@@ -6686,7 +6692,8 @@ static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 
 	nla_nest_end(msg, infoattr);
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -11025,7 +11032,8 @@ static int nl80211_send_scan_msg(struct sk_buff *msg,
 	/* ignore errors and send incomplete event anyway */
 	nl80211_add_scan_req(msg, rdev);
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -11048,7 +11056,8 @@ nl80211_send_sched_scan_msg(struct sk_buff *msg,
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex))
 		goto nla_put_failure;
 
-	return genlmsg_end(msg, hdr);
+	genlmsg_end(msg, hdr);
+	return 0;
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8128594ab379..7de2ed9ec46d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1019,7 +1019,8 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 		return err;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -1121,7 +1122,8 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 		return err;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -1842,7 +1844,8 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	if (err)
 		goto out_cancel;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 out_cancel:
 	nlmsg_cancel(skb, nlh);
@@ -2282,7 +2285,8 @@ static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 			goto out_cancel;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 
 out_cancel:
 	nlmsg_cancel(skb, nlh);
@@ -2490,7 +2494,8 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 	if (err)
 		return err;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
@@ -2712,7 +2717,8 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 		return err;
 	}
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
@@ -2827,7 +2833,8 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 	}
 	upe->hard = !!hard;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
@@ -2986,7 +2993,8 @@ static int build_report(struct sk_buff *skb, u8 proto,
 			return err;
 		}
 	}
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_send_report(struct net *net, u8 proto,
@@ -3031,7 +3039,8 @@ static int build_mapping(struct sk_buff *skb, struct xfrm_state *x,
 	um->old_sport = x->encap->encap_sport;
 	um->reqid = x->props.reqid;
 
-	return nlmsg_end(skb, nlh);
+	nlmsg_end(skb, nlh);
+	return 0;
 }
 
 static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
-- 
2.1.4
