From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 1/9] openvswitch: Serialize acts with original netlink len
Date: Tue,  4 Aug 2015 21:49:51 -0700
Message-ID: <1438750199-9061-2-git-send-email-joestringer@nicira.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, we used the kernel-internal netlink actions length to
calculate the size of messages to serialize back to userspace.
However,the sw_flow_actions may not be formatted exactly the same as the
actions on the wire, so store the original actions length when
de-serializing and re-use the original length when serializing.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c     | 2 +-
 net/openvswitch/flow.h         | 1 +
 net/openvswitch/flow_netlink.c | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ffe984f..d5b5473 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -713,7 +713,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
 
 	/* OVS_FLOW_ATTR_ACTIONS */
 	if (should_fill_actions(ufid_flags))
-		len += nla_total_size(acts->actions_len);
+		len += nla_total_size(acts->orig_len);
 
 	return len
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b62cdb3..082a87b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -144,6 +144,7 @@ struct sw_flow_id {
 
 struct sw_flow_actions {
 	struct rcu_head rcu;
+	size_t orig_len;	/* From flow_cmd_new netlink actions size */
 	u32 actions_len;
 	struct nlattr actions[];
 };
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index a6eb77a..d536fb7 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1545,6 +1545,7 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 		return ERR_PTR(-ENOMEM);
 
 	sfa->actions_len = 0;
+	sfa->orig_len = size;
 	return sfa;
 }
 
-- 
2.1.4
