From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 04/14] user_ns: convert fs/attr.c to targeted capabilities
Date: Tue, 26 Jul 2011 18:58:27 +0000
Message-ID: <1311706717-7398-5-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/attr.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 538e279..e0cf46a 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -29,6 +29,7 @@
 int inode_change_ok(const struct inode *inode, struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
+	struct user_namespace *ns;
 
 	/*
 	 * First check size constraints.  These can't be overriden using
@@ -44,26 +45,28 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
 	if (ia_valid & ATTR_FORCE)
 		return 0;
 
+	ns = inode_userns(inode);
 	/* Make sure a caller can chown. */
 	if ((ia_valid & ATTR_UID) &&
-	    (current_fsuid() != inode->i_uid ||
-	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
+	    (ns != current_user_ns() || current_fsuid() != inode->i_uid ||
+	     attr->ia_uid != inode->i_uid) && !ns_capable(ns, CAP_CHOWN))
 		return -EPERM;
 
 	/* Make sure caller can chgrp. */
 	if ((ia_valid & ATTR_GID) &&
-	    (current_fsuid() != inode->i_uid ||
+	    (ns != current_user_ns() || current_fsuid() != inode->i_uid ||
 	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
-	    !capable(CAP_CHOWN))
+	    !ns_capable(ns, CAP_CHOWN))
 		return -EPERM;
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
+		gid_t gid = (ia_valid & ATTR_GID) ? attr->ia_gid : inode->i_gid;
 		if (!inode_owner_or_capable(inode))
 			return -EPERM;
 		/* Also check the setgid bit! */
-		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
-				inode->i_gid) && !capable(CAP_FSETID))
+		if ((ns != current_user_ns() || !in_group_p(gid)) &&
+		    !ns_capable(ns, CAP_FSETID))
 			attr->ia_mode &= ~S_ISGID;
 	}
 
@@ -154,9 +157,12 @@ void setattr_copy(struct inode *inode, const struct iattr *attr)
 						inode->i_sb->s_time_gran);
 	if (ia_valid & ATTR_MODE) {
 		umode_t mode = attr->ia_mode;
+		struct user_namespace *ns = inode_userns(inode);
 
-		if (!in_group_p(inode->i_gid) && !capable(CAP_FSETID))
+		if ((ns != current_user_ns() || !in_group_p(inode->i_gid)) &&
+		    !ns_capable(ns, CAP_FSETID))
 			mode &= ~S_ISGID;
+
 		inode->i_mode = mode;
 	}
 }
-- 
1.7.4.1
