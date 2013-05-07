From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 25/48] Audit: send reply message to the auditd in proper
	user namespace
Date: Tue, 7 May 2013 10:20:46 +0800
Message-ID: <1367893269-9308-26-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

We can send the audit reply message to userspace auditd
process which running in the same user namespace with the
process which send the audit request message to kernel.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index cac4b21..ca9e046 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -144,6 +144,7 @@ struct audit_buffer {
 struct audit_reply {
 	int pid;
 	struct sk_buff *skb;
+	struct user_namespace *ns;
 };
 
 static void audit_set_pid(struct audit_buffer *ab, pid_t pid)
@@ -517,8 +518,9 @@ static int audit_send_reply_thread(void *arg)
 
 	/* Ignore failure. It'll only happen if the sender goes away,
 	   because our timeout is set to infinite. */
-	netlink_unicast(init_user_ns.audit.sock, reply->skb,
+	netlink_unicast(reply->ns->audit.sock, reply->skb,
 			reply->pid, 0);
+	put_user_ns(reply->ns);
 	kfree(reply);
 	return 0;
 }
@@ -552,11 +554,13 @@ static void audit_send_reply(int pid, int seq, int type, int done, int multi,
 
 	reply->pid = pid;
 	reply->skb = skb;
+	reply->ns = get_user_ns(current_user_ns());
 
 	tsk = kthread_run(audit_send_reply_thread, reply, "audit_send_reply");
 	if (!IS_ERR(tsk))
 		return;
 	kfree_skb(skb);
+	put_user_ns(reply->ns);
 out:
 	kfree(reply);
 }
@@ -859,7 +863,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				security_release_secctx(ctx, len);
 			return -ENOMEM;
 		}
-		sig_data->uid = from_kuid(&init_user_ns, audit_sig_uid);
+		sig_data->uid = from_kuid(ns, audit_sig_uid);
 		sig_data->pid = audit_sig_pid;
 		if (audit_sig_sid) {
 			memcpy(sig_data->ctx, ctx, len);
-- 
1.8.1.4
