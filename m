From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/8] user_ns: Introduce user_nsmap_uid and user_ns_map_gid.
Date: Sun, 13 Jun 2010 06:28:03 -0700
Message-ID: <m17hm3hxjw.fsf_-_@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
	<m1d3vvhxlj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40862 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab0FMN2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:28:08 -0400
In-Reply-To: <m1d3vvhxlj.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:27\:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Define what happens when a we view a uid from one user_namespace
in another user_namepece.

- If the user namespaces are the same no mapping is necessary.

- For most cases of difference use overflowuid and overflowgid,
  the uid and gid currently used for 16bit apis when we have a 32bit uid
  that does fit in 16bits.  Effectively the situation is the same,
  we want to return a uid or gid that is not assigned to any user.

- For the case when we happen to be mapping the uid or gid of the
  creator of the target user namespace use uid 0 and gid as confusing
  that user with root is not a problem.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/user_namespace.h |   14 ++++++++++++
 kernel/user_namespace.c        |   44 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index cc4f453..8178156 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -36,6 +36,9 @@ static inline void put_user_ns(struct user_namespace *ns)
 		kref_put(&ns->kref, free_user_ns);
 }
 
+uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid);
+gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid);
+
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -52,6 +55,17 @@ static inline void put_user_ns(struct user_namespace *ns)
 {
 }
 
+static inline uid_t user_ns_map_uid(struct user_namespace *to,
+	const struct cred *cred, uid_t uid)
+{
+	return uid;
+}
+static inline gid_t user_ns_map_gid(struct user_namespace *to,
+	const struct cred *cred, gid_t gid)
+{
+	return gid;
+}
+
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..825abfb 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/highuid.h>
 #include <linux/cred.h>
 
 /*
@@ -82,3 +83,46 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid)
+{
+	struct user_namespace *tmp;
+
+	if (likely(to == cred->user->user_ns))
+		return uid;
+
+
+	/* Is cred->user the creator of the target user_ns
+	 * or the creator of one of it's parents?
+	 */
+	for ( tmp = to; tmp != &init_user_ns;
+	      tmp = tmp->creator->user_ns ) {
+		if (cred->user == tmp->creator) {
+			return (uid_t)0;
+		}
+	}
+
+	/* No useful relationship so no mapping */
+	return overflowuid;
+}
+
+gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid)
+{
+	struct user_namespace *tmp;
+
+	if (likely(to == cred->user->user_ns))
+		return gid;
+
+	/* Is cred->user the creator of the target user_ns
+	 * or the creator of one of it's parents?
+	 */
+	for ( tmp = to; tmp != &init_user_ns;
+	      tmp = tmp->creator->user_ns ) {
+		if (cred->user == tmp->creator) {
+			return (gid_t)0;
+		}
+	}
+
+	/* No useful relationship so no mapping */
+	return overflowgid;
+}
-- 
1.6.5.2.143.g8cc62

