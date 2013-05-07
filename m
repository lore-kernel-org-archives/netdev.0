From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 30/48] Audit: reply audit filter list request to proper
	user namespace
Date: Tue, 7 May 2013 10:20:51 +0800
Message-ID: <1367893269-9308-31-git-send-email-gaofeng@cn.fujitsu.com>
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

We should reply the audit filter list request to the proper
user namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c       | 3 ++-
 kernel/audit.h       | 1 +
 kernel/auditfilter.c | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 1ca1714..f723fe2 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -474,8 +474,9 @@ int audit_send_list(void *_dest)
 	mutex_unlock(&audit_cmd_mutex);
 
 	while ((skb = __skb_dequeue(&dest->q)) != NULL)
-		netlink_unicast(init_user_ns.audit.sock, skb, pid, 0);
+		netlink_unicast(dest->user_ns->audit.sock, skb, pid, 0);
 
+	put_user_ns(dest->user_ns);
 	kfree(dest);
 
 	return 0;
diff --git a/kernel/audit.h b/kernel/audit.h
index a509796..7934598 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -85,6 +85,7 @@ extern void		    audit_panic(const char *message);
 struct audit_netlink_list {
 	int pid;
 	struct sk_buff_head q;
+	struct user_namespace *user_ns;
 };
 
 int audit_send_list(void *);
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index cf7fe98..f2afe9b 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1180,6 +1180,7 @@ int audit_receive_filter(int type, int pid, int seq, void *data,
 			return -ENOMEM;
 		dest->pid = pid;
 		skb_queue_head_init(&dest->q);
+		dest->user_ns = get_user_ns(ns);
 
 		mutex_lock(&audit_filter_mutex);
 		if (type == AUDIT_LIST)
-- 
1.8.1.4
