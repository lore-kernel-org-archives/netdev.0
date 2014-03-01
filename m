From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] audit: Simplify by assuming the callers socket buffer is large enough
Date: Fri, 28 Feb 2014 20:50:19 -0800
Message-ID: <87mwhaplo4.fsf_-_@xmission.com>
References: <8738j3vzry.fsf@xmission.com>
	<20140301011142.GK16640@madcap2.tricolour.ca>
	<87fvn2r0yb.fsf@xmission.com> <874n3ir0uw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Paris <eparis@redhat.com>, linux-audit@redhat.com,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58228 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaCAEu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 23:50:29 -0500
In-Reply-To: <874n3ir0uw.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 28 Feb 2014 20:36:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Modify audit_send_reply to directly use a non-blocking send and
to return an error on failure (if anyone cares).

Modify audit_list_rules_send to use audit_send_reply and give up
if we can not send a packet.

Merge audit_list_rules into iaudit_list_rules_send as the code
is now sufficiently simple to not justify to callers.

Kill audit_send_list, audit_send_reply_thread because using
a separate thread for replies is not needed when sending
packets syncrhonously.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

I haven't properly tested and made certain this doesn't break userspace,
but this is much simpler than what audit is currently doing.

I really don't understand why we are using kernel threads to allow us to
exceed the receiving sockets configured buffer limits.  That just seems
insane.  If that is really what we want we should be able to force
the receiving buffer limits up in audit_send_reply.

 include/linux/audit.h |    2 +-
 kernel/audit.c        |   75 ++++++++-----------------------------------------
 kernel/audit.h        |   14 ++-------
 kernel/auditfilter.c  |   64 ++++++++++--------------------------------
 4 files changed, 31 insertions(+), 124 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index ec1464df4c60..cd2f5112822a 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -464,7 +464,7 @@ extern int audit_filter_user(int type);
 extern int audit_filter_type(int type);
 extern int audit_rule_change(int type, __u32 portid, int seq,
 				void *data, size_t datasz);
-extern int audit_list_rules_send(struct sk_buff *request_skb, int seq);
+extern void audit_list_rules_send(struct sk_buff *request_skb, int seq);
 
 extern u32 audit_enabled;
 #else /* CONFIG_AUDIT */
diff --git a/kernel/audit.c b/kernel/audit.c
index 32086bff5564..201808fc86aa 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -180,12 +180,6 @@ struct audit_buffer {
 	gfp_t		     gfp_mask;
 };
 
-struct audit_reply {
-	__u32 portid;
-	struct net *net;	
-	struct sk_buff *skb;
-};
-
 static void audit_set_portid(struct audit_buffer *ab, __u32 portid)
 {
 	if (ab) {
@@ -496,26 +490,6 @@ static int kauditd_thread(void *dummy)
 	return 0;
 }
 
-int audit_send_list(void *_dest)
-{
-	struct audit_netlink_list *dest = _dest;
-	struct sk_buff *skb;
-	struct net *net = dest->net;
-	struct audit_net *aunet = net_generic(net, audit_net_id);
-
-	/* wait for parent to finish and send an ACK */
-	mutex_lock(&audit_cmd_mutex);
-	mutex_unlock(&audit_cmd_mutex);
-
-	while ((skb = __skb_dequeue(&dest->q)) != NULL)
-		netlink_unicast(aunet->nlsk, skb, dest->portid, 0);
-
-	put_net(net);
-	kfree(dest);
-
-	return 0;
-}
-
 struct sk_buff *audit_make_reply(__u32 portid, int seq, int type, int done,
 				 int multi, const void *payload, int size)
 {
@@ -541,25 +515,9 @@ out_kfree_skb:
 	return NULL;
 }
 
-static int audit_send_reply_thread(void *arg)
-{
-	struct audit_reply *reply = (struct audit_reply *)arg;
-	struct net *net = reply->net;
-	struct audit_net *aunet = net_generic(net, audit_net_id);
-
-	mutex_lock(&audit_cmd_mutex);
-	mutex_unlock(&audit_cmd_mutex);
-
-	/* Ignore failure. It'll only happen if the sender goes away,
-	   because our timeout is set to infinite. */
-	netlink_unicast(aunet->nlsk , reply->skb, reply->portid, 0);
-	put_net(net);
-	kfree(reply);
-	return 0;
-}
 /**
  * audit_send_reply - send an audit reply message via netlink
- * @portid: netlink port to which to send reply
+ * @request_skb: The request skb (used to calculate where to reply)
  * @seq: sequence number
  * @type: audit message type
  * @done: done (last) flag
@@ -570,33 +528,24 @@ static int audit_send_reply_thread(void *arg)
  * Allocates an skb, builds the netlink message, and sends it to the port id.
  * No failure notifications.
  */
-static void audit_send_reply(struct sk_buff *request_skb, int seq, int type, int done,
-			     int multi, const void *payload, int size)
+int audit_send_reply(struct sk_buff *request_skb, int seq, int type, int done,
+		     int multi, const void *payload, int size)
 {
 	u32 portid = NETLINK_CB(request_skb).portid;
 	struct net *net = sock_net(NETLINK_CB(request_skb).sk);
+	struct audit_net *aunet = net_generic(net, audit_net_id);
 	struct sk_buff *skb;
-	struct task_struct *tsk;
-	struct audit_reply *reply = kmalloc(sizeof(struct audit_reply),
-					    GFP_KERNEL);
-
-	if (!reply)
-		return;
 
 	skb = audit_make_reply(portid, seq, type, done, multi, payload, size);
 	if (!skb)
-		goto out;
-
-	reply->net = get_net(net);
-	reply->portid = portid;
-	reply->skb = skb;
+		return -ENOMEM;
 
-	tsk = kthread_run(audit_send_reply_thread, reply, "audit_send_reply");
-	if (!IS_ERR(tsk))
-		return;
-	kfree_skb(skb);
-out:
-	kfree(reply);
+	/*
+	 * audit_send_reply runs in the context of the requesting process
+	 * which means that a blocking send can deadlock.  Peform a
+	 * non-blocking send, and in general ignore errors.
+	 */
+	return netlink_unicast(aunet->nlsk, skb, portid, 1);
 }
 
 /*
@@ -907,7 +856,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 					   seq, data, nlmsg_len(nlh));
 		break;
 	case AUDIT_LIST_RULES:
-		err = audit_list_rules_send(skb, seq);
+		audit_list_rules_send(skb, seq);
 		break;
 	case AUDIT_TRIM:
 		audit_trim_trees();
diff --git a/kernel/audit.h b/kernel/audit.h
index 8df132214606..c7a594890950 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -240,18 +240,10 @@ extern int audit_uid_comparator(kuid_t left, u32 op, kuid_t right);
 extern int audit_gid_comparator(kgid_t left, u32 op, kgid_t right);
 extern int parent_len(const char *path);
 extern int audit_compare_dname_path(const char *dname, const char *path, int plen);
-extern struct sk_buff *audit_make_reply(__u32 portid, int seq, int type,
-					int done, int multi,
-					const void *payload, int size);
-extern void		    audit_panic(const char *message);
-
-struct audit_netlink_list {
-	__u32 portid;
-	struct net *net;
-	struct sk_buff_head q;
-};
+extern int audit_send_reply(struct sk_buff *request_skb, int seq, int type,
+			    int done, int multi, const void *payload, int size);
 
-int audit_send_list(void *);
+extern void		    audit_panic(const char *message);
 
 struct audit_net {
 	struct sock *nlsk;
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index e8d1c7c515d7..5cd05b1f3ec3 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -973,33 +973,39 @@ out:
 	return ret;
 }
 
-/* List rules using struct audit_rule_data. */
-static void audit_list_rules(__u32 portid, int seq, struct sk_buff_head *q)
+/**
+ * audit_list_rules_send - list the audit rules using struct audit_rule_data.
+ * @request_skb: The requesting skb (used to calculate where to reply)
+ * @seq: netlink audit message sequence (serial) number
+ */
+void audit_list_rules_send(struct sk_buff *request_skb, int seq)
 {
-	struct sk_buff *skb;
 	struct audit_krule *r;
 	int i;
 
+	mutex_lock(&audit_filter_mutex);
 	/* This is a blocking read, so use audit_filter_mutex instead of rcu
 	 * iterator to sync with list writers. */
 	for (i=0; i<AUDIT_NR_FILTERS; i++) {
 		list_for_each_entry(r, &audit_rules_list[i], list) {
 			struct audit_rule_data *data;
+			int err;
 
 			data = audit_krule_to_data(r);
 			if (unlikely(!data))
 				break;
-			skb = audit_make_reply(portid, seq, AUDIT_LIST_RULES,
+			err = audit_send_reply(request_skb, seq, AUDIT_LIST_RULES,
 					       0, 1, data,
 					       sizeof(*data) + data->buflen);
-			if (skb)
-				skb_queue_tail(q, skb);
 			kfree(data);
+			if (err < 0)
+				goto done;
 		}
 	}
-	skb = audit_make_reply(portid, seq, AUDIT_LIST_RULES, 1, 1, NULL, 0);
-	if (skb)
-		skb_queue_tail(q, skb);
+	audit_send_reply(request_skb, seq, AUDIT_LIST_RULES, 1, 1, NULL, 0);
+done:
+	mutex_unlock(&audit_filter_mutex);
+	return;
 }
 
 /* Log rule additions and removals */
@@ -1065,46 +1071,6 @@ int audit_rule_change(int type, __u32 portid, int seq, void *data,
 	return err;
 }
 
-/**
- * audit_list_rules_send - list the audit rules
- * @portid: target portid for netlink audit messages
- * @seq: netlink audit message sequence (serial) number
- */
-int audit_list_rules_send(struct sk_buff *request_skb, int seq)
-{
-	u32 portid = NETLINK_CB(request_skb).portid;
-	struct net *net = sock_net(NETLINK_CB(request_skb).sk);
-	struct task_struct *tsk;
-	struct audit_netlink_list *dest;
-	int err = 0;
-
-	/* We can't just spew out the rules here because we might fill
-	 * the available socket buffer space and deadlock waiting for
-	 * auditctl to read from it... which isn't ever going to
-	 * happen if we're actually running in the context of auditctl
-	 * trying to _send_ the stuff */
-
-	dest = kmalloc(sizeof(struct audit_netlink_list), GFP_KERNEL);
-	if (!dest)
-		return -ENOMEM;
-	dest->net = get_net(net);
-	dest->portid = portid;
-	skb_queue_head_init(&dest->q);
-
-	mutex_lock(&audit_filter_mutex);
-	audit_list_rules(portid, seq, &dest->q);
-	mutex_unlock(&audit_filter_mutex);
-
-	tsk = kthread_run(audit_send_list, dest, "audit_send_list");
-	if (IS_ERR(tsk)) {
-		skb_queue_purge(&dest->q);
-		kfree(dest);
-		err = PTR_ERR(tsk);
-	}
-
-	return err;
-}
-
 int audit_comparator(u32 left, u32 op, u32 right)
 {
 	switch (op) {
-- 
1.7.5.4
