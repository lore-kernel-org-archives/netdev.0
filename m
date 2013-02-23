From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3] datapath: Increase maximum allocation size of action list.
Date: Fri, 22 Feb 2013 17:03:30 -0800
Message-ID: <1361581410-2311-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:59317 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751125Ab3BWBCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:02:10 -0500
Received: by mail-qe0-f72.google.com with SMTP id a11so2280852qen.3
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 17:02:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch to flow based tunneling increased the size of each output
action in the flow action list.  In extreme cases, this can result
in the action list exceeding the maximum buffer size.

This doubles the maximum buffer size to compensate for the increase
in action size.  In the common case, most allocations will be
less than a page and those uses kmalloc.  Therefore, for the majority
of situations, this will have no impact.

Bug #15203
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Fixed according to commnets from Jesse.
v2-v3:
 - Use size for buf_size.
 - Fixed size check in ovs_flow_actions_free().

v1-v2: 
Fixes some issues noticed in earlier patch.
---
 datapath/datapath.c |    8 ++++----
 datapath/flow.c     |   19 +++++++++++++++++--
 datapath/flow.h     |    5 ++++-
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/datapath/datapath.c b/datapath/datapath.c
index fc5d2de..bd2d57b 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -434,10 +434,10 @@ static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa, int attr_le
 	int next_offset = offsetof(struct sw_flow_actions, actions) +
 					(*sfa)->actions_len;
 
-	if (req_size <= (ksize(*sfa) - next_offset))
+	if (req_size <= ((*sfa)->buf_size - next_offset))
 		goto out;
 
-	new_acts_size = ksize(*sfa) * 2;
+	new_acts_size = (*sfa)->buf_size * 2;
 
 	if (new_acts_size > MAX_ACTIONS_BUFSIZE) {
 		if ((MAX_ACTIONS_BUFSIZE - next_offset) < req_size)
@@ -451,7 +451,7 @@ static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa, int attr_le
 
 	memcpy(acts->actions, (*sfa)->actions, (*sfa)->actions_len);
 	acts->actions_len = (*sfa)->actions_len;
-	kfree(*sfa);
+	ovs_flow_actions_free(*sfa);
 	*sfa = acts;
 
 out:
@@ -1292,7 +1292,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 
 err_kfree:
-	kfree(acts);
+	ovs_flow_actions_free(acts);
 error:
 	return error;
 }
diff --git a/datapath/flow.c b/datapath/flow.c
index b14229f..b6bb7a7 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -207,14 +207,29 @@ struct sw_flow_actions *ovs_flow_actions_alloc(int size)
 	if (size > MAX_ACTIONS_BUFSIZE)
 		return ERR_PTR(-EINVAL);
 
-	sfa = kmalloc(sizeof(*sfa) + size, GFP_KERNEL);
+	size += sizeof(*sfa);
+	if (size <= MAX_ACTIONS_BUFSIZE_KMALLOC)
+		sfa = kmalloc(size, GFP_KERNEL);
+	else
+		sfa = vmalloc(size);
+
 	if (!sfa)
 		return ERR_PTR(-ENOMEM);
 
 	sfa->actions_len = 0;
+	sfa->buf_size = size;
+
 	return sfa;
 }
 
+void ovs_flow_actions_free(struct sw_flow_actions *sfa)
+{
+	if (sfa->buf_size <= MAX_ACTIONS_BUFSIZE_KMALLOC)
+		kfree(sfa);
+	else
+		vfree(sfa);
+}
+
 struct sw_flow *ovs_flow_alloc(void)
 {
 	struct sw_flow *flow;
@@ -437,7 +452,7 @@ static void rcu_free_acts_callback(struct rcu_head *rcu)
 {
 	struct sw_flow_actions *sf_acts = container_of(rcu,
 			struct sw_flow_actions, rcu);
-	kfree(sf_acts);
+	ovs_flow_actions_free(sf_acts);
 }
 
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
diff --git a/datapath/flow.h b/datapath/flow.h
index 6949640..3b08ea6 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -37,6 +37,7 @@ struct sk_buff;
 struct sw_flow_actions {
 	struct rcu_head rcu;
 	u32 actions_len;
+	int buf_size;
 	struct nlattr actions[];
 };
 
@@ -151,6 +152,7 @@ void ovs_flow_deferred_free(struct sw_flow *);
 void ovs_flow_free(struct sw_flow *);
 
 struct sw_flow_actions *ovs_flow_actions_alloc(int actions_len);
+void ovs_flow_actions_free(struct sw_flow_actions *sfa);
 void ovs_flow_deferred_free_acts(struct sw_flow_actions *);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *,
@@ -194,7 +196,8 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
 				   const struct nlattr *attr);
 
-#define MAX_ACTIONS_BUFSIZE	(16 * 1024)
+#define MAX_ACTIONS_BUFSIZE		(32 * 1024)
+#define MAX_ACTIONS_BUFSIZE_KMALLOC	PAGE_SIZE
 #define TBL_MIN_BUCKETS		1024
 
 struct flow_table {
-- 
1.7.1
