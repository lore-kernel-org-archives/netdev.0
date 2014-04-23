From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 4/6][v2] audit: add netlink audit protocol bind to check capabilities on multicast join
Date: Tue, 22 Apr 2014 21:31:56 -0400
Message-ID: <98fb27d9bb1bdeca41d53cccd8a8b65c1e58cc80.1398215388.git.rgb@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	jamal@mojatatu.com, eparis@redhat.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140422.161904.1187535812839850973.davem@davemloft.net>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
References: <cover.1398215388.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register a netlink per-protocol bind fuction for audit to check userspace
process capabilities before allowing a multicast group connection.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 include/uapi/linux/capability.h     |    7 ++++++-
 kernel/audit.c                      |   10 ++++++++++
 security/selinux/include/classmap.h |    2 +-
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/capability.h b/include/uapi/linux/capability.h
index 154dd6d..12c37a1 100644
--- a/include/uapi/linux/capability.h
+++ b/include/uapi/linux/capability.h
@@ -347,7 +347,12 @@ struct vfs_cap_data {
 
 #define CAP_BLOCK_SUSPEND    36
 
-#define CAP_LAST_CAP         CAP_BLOCK_SUSPEND
+/* Allow reading the audit log via multicast netlink socket */
+
+#define CAP_AUDIT_READ		37
+
+
+#define CAP_LAST_CAP         CAP_AUDIT_READ
 
 #define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 7c28936..223cb74 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1076,10 +1076,20 @@ static void audit_receive(struct sk_buff  *skb)
 	mutex_unlock(&audit_cmd_mutex);
 }
 
+/* Run custom bind function on netlink socket group connect or bind requests. */
+static int audit_bind(int group)
+{
+	if (!capable(CAP_AUDIT_READ))
+		return -EPERM;
+
+	return 0;
+}
+
 static int __net_init audit_net_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input	= audit_receive,
+		.bind	= audit_bind,
 	};
 
 	struct audit_net *aunet = net_generic(net, audit_net_id);
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index 14d04e6..be491a7 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -147,7 +147,7 @@ struct security_class_mapping secclass_map[] = {
 	{ "peer", { "recv", NULL } },
 	{ "capability2",
 	  { "mac_override", "mac_admin", "syslog", "wake_alarm", "block_suspend",
-	    NULL } },
+	    "audit_read", NULL } },
 	{ "kernel_service", { "use_as_override", "create_files_as", NULL } },
 	{ "tun_socket",
 	  { COMMON_SOCK_PERMS, "attach_queue", NULL } },
-- 
1.7.1
