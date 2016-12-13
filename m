From: Richard Guy Briggs <rgb@redhat.com>
Subject: [RFC PATCH v3] audit: use proper refcount locking on audit_sock
Date: Tue, 13 Dec 2016 10:03:01 -0500
Message-ID: <61c37ca790bc11bc023aea8f9b70ab3098aa30f5.1481626466.git.rgb@redhat.com>
References: <20161212100215.GA1305@madcap2.tricolour.ca>
Cc: Richard Guy Briggs <rgb@redhat.com>, <dvyukov@google.com>,
        <xiyou.wangcong@gmail.com>, <edumazet@google.com>,
        <eparis@redhat.com>, <pmoore@redhat.com>, <sgrubb@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43302 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932993AbcLMPDg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 10:03:36 -0500
In-Reply-To: <20161212100215.GA1305@madcap2.tricolour.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resetting audit_sock appears to be racy.

audit_sock was being copied and dereferenced without using a refcount on
the source sock.

Bump the refcount on the underlying sock when we store a refrence in
audit_sock and release it when we reset audit_sock.  audit_sock
modification needs the audit_cmd_mutex.

See: https://lkml.org/lkml/2016/11/26/232

Thanks to Eric Dumazet <edumazet@google.com> and Cong Wang
<xiyou.wangcong@gmail.com> on ideas how to fix it.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
There has been a lot of change in the audit code that is about to go
upstream to address audit queue issues.  This patch is based on the
source tree: git://git.infradead.org/users/pcmoore/audit#next
---
 kernel/audit.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index f20eee0..3bb4126 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -446,14 +446,19 @@ static void kauditd_retry_skb(struct sk_buff *skb)
  * Description:
  * Break the auditd/kauditd connection and move all the records in the retry
  * queue into the hold queue in case auditd reconnects.
+ * The audit_cmd_mutex must be held when calling this function.
  */
 static void auditd_reset(void)
 {
 	struct sk_buff *skb;
 
 	/* break the connection */
+	if (audit_sock) {
+		sock_put(audit_sock);
+		audit_sock = NULL;
+	}
 	audit_pid = 0;
-	audit_sock = NULL;
+	audit_nlk_portid = 0;
 
 	/* flush all of the retry queue to the hold queue */
 	while ((skb = skb_dequeue(&audit_retry_queue)))
@@ -579,7 +584,9 @@ static int kauditd_thread(void *dummy)
 
 				auditd = 0;
 				if (AUDITD_BAD(rc, reschedule)) {
+					mutex_lock(&audit_cmd_mutex);
 					auditd_reset();
+					mutex_unlock(&audit_cmd_mutex);
 					reschedule = 0;
 				}
 			} else
@@ -594,7 +601,9 @@ static int kauditd_thread(void *dummy)
 				auditd = 0;
 				if (AUDITD_BAD(rc, reschedule)) {
 					kauditd_hold_skb(skb);
+					mutex_lock(&audit_cmd_mutex);
 					auditd_reset();
+					mutex_unlock(&audit_cmd_mutex);
 					reschedule = 0;
 				} else
 					/* temporary problem (we hope), queue
@@ -623,7 +632,9 @@ quick_loop:
 				if (rc) {
 					auditd = 0;
 					if (AUDITD_BAD(rc, reschedule)) {
+						mutex_lock(&audit_cmd_mutex);
 						auditd_reset();
+						mutex_unlock(&audit_cmd_mutex);
 						reschedule = 0;
 					}
 
@@ -1010,11 +1021,16 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			}
 			if (audit_enabled != AUDIT_OFF)
 				audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
-			audit_pid = new_pid;
-			audit_nlk_portid = NETLINK_CB(skb).portid;
-			audit_sock = skb->sk;
-			if (!new_pid)
+			if (new_pid) {
+				if (audit_sock)
+					sock_put(audit_sock);
+				audit_pid = new_pid;
+				audit_nlk_portid = NETLINK_CB(skb).portid;
+				sock_hold(skb->sk);
+				audit_sock = skb->sk;
+			} else {
 				auditd_reset();
+			}
 			wake_up_interruptible(&kauditd_wait);
 		}
 		if (s.mask & AUDIT_STATUS_RATE_LIMIT) {
@@ -1283,8 +1299,10 @@ static void __net_exit audit_net_exit(struct net *net)
 {
 	struct audit_net *aunet = net_generic(net, audit_net_id);
 	struct sock *sock = aunet->nlsk;
+	mutex_lock(&audit_cmd_mutex);
 	if (sock == audit_sock)
 		auditd_reset();
+	mutex_unlock(&audit_cmd_mutex);
 
 	RCU_INIT_POINTER(aunet->nlsk, NULL);
 	synchronize_net();
-- 
1.7.1
