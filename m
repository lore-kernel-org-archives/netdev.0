From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 4/7] openvswitch: Ensure flow is valid before executing ct
Date: Tue, 29 Sep 2015 15:39:37 -0700
Message-ID: <1443566380-22640-5-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35556 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbbI2WkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:40:03 -0400
Received: by pacfv12 with SMTP id fv12so18821166pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:03 -0700 (PDT)
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ct action uses parts of the flow key, so we need to ensure that it
is valid before executing that action.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/actions.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e1afbd1..9a88f15 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1104,6 +1104,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_CT:
+			if (!is_flow_key_valid(key)) {
+				err = ovs_flow_key_update(skb, key);
+				if (err)
+					return err;
+			}
+
 			err = ovs_ct_execute(ovs_dp_get_net(dp), skb, key,
 					     nla_data(a));
 
-- 
2.1.4
