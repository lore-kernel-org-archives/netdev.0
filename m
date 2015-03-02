From: Joe Stringer <joestringer@nicira.com>
Subject: [RFCv2 net-next 1/7] openvswitch: Serialize acts with original netlink len
Date: Mon,  2 Mar 2015 13:54:59 -0800
Message-ID: <1425333305-19702-2-git-send-email-joestringer@nicira.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, Justin Pettit <jpettit@nicira.com>,
	azhou@nicira.com, Thomas Graf <tgraf@suug.ch>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:57743 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754139AbbCBVzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:55:37 -0500
Received: by mail-pd0-f170.google.com with SMTP id fl12so11600194pdb.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 13:55:36 -0800 (PST)
In-Reply-To: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, we used the kernel-internal netlink actions length to
calculate the size of messages to serialize back to userspace.
However,the sw_flow_actions may not be formatted exactly the same as the
actions on the wire, so store the original actions length when
de-serializing and re-use the original length when serializing.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/datapath.c     |    2 +-
 net/openvswitch/flow.h         |    1 +
 net/openvswitch/flow_netlink.c |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ae5e77c..c8c60c5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -700,7 +700,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
 
 	/* OVS_FLOW_ATTR_ACTIONS */
 	if (should_fill_actions(ufid_flags))
-		len += nla_total_size(acts->actions_len);
+		len += nla_total_size(acts->orig_len);
 
 	return len
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a076e44..998401a 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -209,6 +209,7 @@ struct sw_flow_id {
 
 struct sw_flow_actions {
 	struct rcu_head rcu;
+	size_t orig_len;	/* From flow_cmd_new netlink actions size */
 	u32 actions_len;
 	struct nlattr actions[];
 };
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 216f20b..d5b01af 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1543,6 +1543,7 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 		return ERR_PTR(-ENOMEM);
 
 	sfa->actions_len = 0;
+	sfa->orig_len = size;
 	return sfa;
 }
 
-- 
1.7.10.4
