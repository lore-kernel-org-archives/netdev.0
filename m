From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 4/5] openvswitch: Convert dp rcu read operation to locked operations
Date: Fri, 14 Nov 2014 17:38:03 -0800
Message-ID: <1416015483-1638-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:46934 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965580AbaKOBiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:38:06 -0500
Received: by mail-pd0-f174.google.com with SMTP id p10so17660296pdj.19
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:38:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dp read operations depends on ovs_dp_cmd_fill_info(). This API
needs to looup vport to find dp name, but vport lookup can
fail. Therefore to keep vport reference alive we need to
take ovs lock.

Introduced by commit 6093ae9abac1 ("openvswitch: Minimize
dp and vport critical sections").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/datapath.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e6d7255..f9e556b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1265,7 +1265,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 	return msgsize;
 }
 
-/* Called with ovs_mutex or RCU read lock. */
+/* Called with ovs_mutex. */
 static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 				u32 portid, u32 seq, u32 flags, u8 cmd)
 {
@@ -1555,7 +1555,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (!reply)
 		return -ENOMEM;
 
-	rcu_read_lock();
+	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	if (IS_ERR(dp)) {
 		err = PTR_ERR(dp);
@@ -1564,12 +1564,12 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_dp_cmd_fill_info(dp, reply, info->snd_portid,
 				   info->snd_seq, 0, OVS_DP_CMD_NEW);
 	BUG_ON(err < 0);
-	rcu_read_unlock();
+	ovs_unlock();
 
 	return genlmsg_reply(reply, info);
 
 err_unlock_free:
-	rcu_read_unlock();
+	ovs_unlock();
 	kfree_skb(reply);
 	return err;
 }
@@ -1581,8 +1581,8 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int skip = cb->args[0];
 	int i = 0;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(dp, &ovs_net->dps, list_node) {
+	ovs_lock();
+	list_for_each_entry(dp, &ovs_net->dps, list_node) {
 		if (i >= skip &&
 		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
@@ -1590,7 +1590,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 		i++;
 	}
-	rcu_read_unlock();
+	ovs_unlock();
 
 	cb->args[0] = i;
 
-- 
1.9.3
