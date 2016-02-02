From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2] openvswitch: allow management from inside user namespaces
Date: Tue,  2 Feb 2016 11:31:13 +1100
Message-ID: <1454373073-12530-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
To: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Operations with the GENL_ADMIN_PERM flag fail permissions checks because
this flag means we call netlink_capable, which uses the init user ns.

Instead, let's introduce a new flag, GENL_UNS_ADMIN_PERM for operations
which should be allowed inside a user namespace.

The motivation for this is to be able to run openvswitch in unprivileged
containers. I've tested this and it seems to work, but I really have no
idea about the security consequences of this patch, so thoughts would be
much appreciated.

v2: use the GENL_UNS_ADMIN_PERM flag instead of a check in each function

Reported-by: James Page <james.page-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
CC: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/uapi/linux/genetlink.h |  1 +
 net/netlink/genetlink.c        |  6 ++++--
 net/openvswitch/datapath.c     | 20 ++++++++++----------
 3 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index c3363ba..5512c90 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -21,6 +21,7 @@ struct genlmsghdr {
 #define GENL_CMD_CAP_DO		0x02
 #define GENL_CMD_CAP_DUMP	0x04
 #define GENL_CMD_CAP_HASPOL	0x08
+#define GENL_UNS_ADMIN_PERM	0x10
 
 /*
  * List of reserved static generic netlink identifiers:
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f830326..6bbb3eb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -576,8 +576,10 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	if (ops == NULL)
 		return -EOPNOTSUPP;
 
-	if ((ops->flags & GENL_ADMIN_PERM) &&
-	    !netlink_capable(skb, CAP_NET_ADMIN))
+	if (((ops->flags & GENL_ADMIN_PERM) &&
+	    !netlink_capable(skb, CAP_NET_ADMIN)) ||
+	    ((ops->flags & GENL_UNS_ADMIN_PERM) &&
+	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN)))
 		return -EPERM;
 
 	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index deadfda..d6f7fe9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -654,7 +654,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
 
 static const struct genl_ops dp_packet_genl_ops[] = {
 	{ .cmd = OVS_PACKET_CMD_EXECUTE,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = packet_policy,
 	  .doit = ovs_packet_cmd_execute
 	}
@@ -1391,12 +1391,12 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
 
 static const struct genl_ops dp_flow_genl_ops[] = {
 	{ .cmd = OVS_FLOW_CMD_NEW,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = flow_policy,
 	  .doit = ovs_flow_cmd_new
 	},
 	{ .cmd = OVS_FLOW_CMD_DEL,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = flow_policy,
 	  .doit = ovs_flow_cmd_del
 	},
@@ -1407,7 +1407,7 @@ static const struct genl_ops dp_flow_genl_ops[] = {
 	  .dumpit = ovs_flow_cmd_dump
 	},
 	{ .cmd = OVS_FLOW_CMD_SET,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = flow_policy,
 	  .doit = ovs_flow_cmd_set,
 	},
@@ -1777,12 +1777,12 @@ static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
 
 static const struct genl_ops dp_datapath_genl_ops[] = {
 	{ .cmd = OVS_DP_CMD_NEW,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = datapath_policy,
 	  .doit = ovs_dp_cmd_new
 	},
 	{ .cmd = OVS_DP_CMD_DEL,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = datapath_policy,
 	  .doit = ovs_dp_cmd_del
 	},
@@ -1793,7 +1793,7 @@ static const struct genl_ops dp_datapath_genl_ops[] = {
 	  .dumpit = ovs_dp_cmd_dump
 	},
 	{ .cmd = OVS_DP_CMD_SET,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = datapath_policy,
 	  .doit = ovs_dp_cmd_set,
 	},
@@ -2158,12 +2158,12 @@ static const struct nla_policy vport_policy[OVS_VPORT_ATTR_MAX + 1] = {
 
 static const struct genl_ops dp_vport_genl_ops[] = {
 	{ .cmd = OVS_VPORT_CMD_NEW,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = vport_policy,
 	  .doit = ovs_vport_cmd_new
 	},
 	{ .cmd = OVS_VPORT_CMD_DEL,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = vport_policy,
 	  .doit = ovs_vport_cmd_del
 	},
@@ -2174,7 +2174,7 @@ static const struct genl_ops dp_vport_genl_ops[] = {
 	  .dumpit = ovs_vport_cmd_dump
 	},
 	{ .cmd = OVS_VPORT_CMD_SET,
-	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .flags = GENL_UNS_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = vport_policy,
 	  .doit = ovs_vport_cmd_set,
 	},
-- 
2.5.0
