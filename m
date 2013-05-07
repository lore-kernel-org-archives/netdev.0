From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 08/48] Audit: make audit_nlk_portid per user namesapce
Date: Tue, 7 May 2013 10:20:29 +0800
Message-ID: <1367893269-9308-9-git-send-email-gaofeng@cn.fujitsu.com>
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

After this patch, audit_nlk_port is per user namespace.
Just like prev patch does,use audit_nlk_portid of init
user namespace in kauditd_send_skb.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 | 11 ++---------
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index a6c6174..769a12b 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -22,6 +22,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 struct audit_ctrl {
 	struct sock		*sock;
 	int			pid;
+	int			portid;
 	struct sk_buff_head	queue;
 	struct sk_buff_head	hold_queue;
 	struct task_struct	*kauditd_task;
diff --git a/kernel/audit.c b/kernel/audit.c
index 2ce7a21..b946b29 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -87,13 +87,6 @@ static int	audit_default;
 /* If auditing cannot proceed, audit_failure selects what happens. */
 static int	audit_failure = AUDIT_FAIL_PRINTK;
 
-/*
- * If audit records are to be written to the netlink socket, audit_pid
- * contains the pid of the auditd process and audit_nlk_portid contains
- * the portid to use to send netlink messages to that process.
- */
-static int	audit_nlk_portid;
-
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
  * to that number per second.  This prevents DoS attacks, but results in
  * audit records being dropped. */
@@ -400,7 +393,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
 	err = netlink_unicast(init_user_ns.audit.sock, skb,
-			      audit_nlk_portid, 0);
+			      init_user_ns.audit.portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
 		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n",
@@ -717,7 +710,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 							sessionid, sid, 1);
 
 			ns->audit.pid = new_pid;
-			audit_nlk_portid = NETLINK_CB(skb).portid;
+			ns->audit.portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
 			err = audit_set_rate_limit(status_get->rate_limit,
-- 
1.8.1.4
