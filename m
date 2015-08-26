From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv6 net-next 01/10] openvswitch: Serialize acts with original netlink len
Date: Wed, 26 Aug 2015 11:31:44 -0700
Message-ID: <1440613913-10141-2-git-send-email-joestringer@nicira.com>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36847 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbbHZScB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:32:01 -0400
Received: by padfo6 with SMTP id fo6so162786pad.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:32:00 -0700 (PDT)
In-Reply-To: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, we used the kernel-internal netlink actions length to
calculate the size of messages to serialize back to userspace.
However,the sw_flow_actions may not be formatted exactly the same as the
actions on the wire, so store the original actions length when
de-serializing and re-use the original length when serializing.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
v2: No change.
v3: Preserve original length across buffer resize.
v4: Add ack.
v5: No change.
v6: Add ack.
---
 net/openvswitch/datapath.c     | 2 +-
 net/openvswitch/flow.h         | 1 +
 net/openvswitch/flow_netlink.c | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

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
index 4e7a3f7..c182b28 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1619,6 +1619,7 @@ static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
 
 	memcpy(acts->actions, (*sfa)->actions, (*sfa)->actions_len);
 	acts->actions_len = (*sfa)->actions_len;
+	acts->orig_len = (*sfa)->orig_len;
 	kfree(*sfa);
 	*sfa = acts;
 
@@ -2223,6 +2224,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	if (IS_ERR(*sfa))
 		return PTR_ERR(*sfa);
 
+	(*sfa)->orig_len = nla_len(attr);
 	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
 				     key->eth.tci, log);
 	if (err)
-- 
2.1.4
