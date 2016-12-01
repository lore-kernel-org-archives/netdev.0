From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 4/8] net/sched: act_mirred: Add new tc_action_ops get_dev()
Date: Thu,  1 Dec 2016 14:06:36 +0200
Message-ID: <1480594000-8428-5-git-send-email-hadarh@mellanox.com>
References: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45344 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758535AbcLANCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:02:31 -0500
In-Reply-To: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support to a new tc_action_ops.
get_dev is a general option which allows to get the underline
device when trying to offload a tc rule.

In case of mirred action the returned device is the mirred (egress)
device.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h  |  2 ++
 net/sched/act_mirred.c | 12 ++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index d8eae87..9dddf77 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -119,6 +119,8 @@ struct tc_action_ops {
 	int     (*walk)(struct net *, struct sk_buff *,
 			struct netlink_callback *, int, const struct tc_action_ops *);
 	void	(*stats_update)(struct tc_action *, u64, u32, u64);
+	int	(*get_dev)(const struct tc_action *a, struct net *net,
+			   struct net_device **mirred_dev);
 };
 
 struct tc_action_net {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1af7baa..bb09ba3 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -315,6 +315,17 @@ static int mirred_device_event(struct notifier_block *unused,
 	.notifier_call = mirred_device_event,
 };
 
+static int tcf_mirred_device(const struct tc_action *a, struct net *net,
+			     struct net_device **mirred_dev)
+{
+	int ifindex = tcf_mirred_ifindex(a);
+
+	*mirred_dev = __dev_get_by_index(net, ifindex);
+	if (!mirred_dev)
+		return -EINVAL;
+	return 0;
+}
+
 static struct tc_action_ops act_mirred_ops = {
 	.kind		=	"mirred",
 	.type		=	TCA_ACT_MIRRED,
@@ -327,6 +338,7 @@ static int mirred_device_event(struct notifier_block *unused,
 	.walk		=	tcf_mirred_walker,
 	.lookup		=	tcf_mirred_search,
 	.size		=	sizeof(struct tcf_mirred),
+	.get_dev	=	tcf_mirred_device,
 };
 
 static __net_init int mirred_init_net(struct net *net)
-- 
1.8.3.1
