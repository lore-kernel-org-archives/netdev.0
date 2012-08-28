From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] userns: Add basic quota support v3
Date: Tue, 28 Aug 2012 10:36:31 -0700
Message-ID: <874nnm7wbk.fsf_-_@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87harqecvk.fsf@xmission.com>
	<20120827085034.GA8998@quack.suse.cz> <87wr0j7u3j.fsf_-_@xmission.com>
	<20120828090544.GC5146@quack.suse.cz> <87a9xe7wfn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>,
	Alex Elder <elder@kernel.org>,
	Dmitry Monakhov <dmonakhov@openvz.org>,
	Abhijith Das <adas@redhat.com>
To: Jan Kara <jack@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:53742 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab2H1SGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 14:06:01 -0400
In-Reply-To: <87a9xe7wfn.fsf@xmission.com> (Eric W. Biederman's message of
	"Tue, 28 Aug 2012 10:34:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add the data type struct qown which holds the owning identifier of a
quota.  struct qown is a replacement for the implicit union of uid,
gid and project stored in an unsigned int and the quota type field
that is was used in the quota data structures.  Making the data type
explicit allows the kuid_t and kgid_t type safety to propogate more
thoroughly through the code, revealing more places where uid/gid
conversions need be made.

Along with the data type struct qown comes the helper functions
qown_eq, qown_lt, from_qown, from_qown_munged, qown_valid, make_qown,
make_qown_invalid, make_qown_uid, make_qown_gid.

Replace struct dquot dq_id and dq_type with dq_own a struct qown.

Update the signature of dqget, quota_send_warning, dquot_get_dqblk,
and dquot_set_dqblk to use struct qown.

Make minimal changes to ext3, ext4, gfs2, ocfs2, and xfs to deal with
the change in quota structures and signatures.  The ocfs2 changes are
larger than most because of the extensive tracing throughout the ocfs2
quota code that prints out dq_id.

v3:
  - Add missing negation on qown_valid
v2:
  - Renamed qown_t struct qown
  - Added the quota type to struct qown.
  - Removed enum quota_type (In this patch it was just noise)
  - Added qown_lt, make_qown_invalid, make_qown_uid, make_qown_gid
  - Taught qown to handle xfs project ids (but only in init_user_ns).
    Q_XGETQUOTA calls .get_quotblk with project ids.

Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <jlbec@evilplan.org>
Cc: Ben Myers <bpm@sgi.com>
Cc: Alex Elder <elder@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Dmitry Monakhov <dmonakhov@openvz.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/ext3/super.c          |    2 +-
 fs/ext4/super.c          |    2 +-
 fs/gfs2/quota.c          |   52 +++++++++------
 fs/ocfs2/file.c          |    6 +-
 fs/ocfs2/quota_global.c  |   43 +++++++-----
 fs/ocfs2/quota_local.c   |   15 +++--
 fs/quota/dquot.c         |  118 +++++++++++++++++-----------------
 fs/quota/netlink.c       |   10 ++-
 fs/quota/quota.c         |   28 ++++++--
 fs/quota/quota_tree.c    |   35 ++++++----
 fs/quota/quota_v1.c      |   12 ++--
 fs/quota/quota_v2.c      |   26 ++++---
 fs/xfs/xfs_quotaops.c    |   14 ++--
 fs/xfs/xfs_trans_dquot.c |    8 ++-
 include/linux/quota.h    |  162 ++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/quotaops.h |    6 +-
 init/Kconfig             |    2 -
 17 files changed, 371 insertions(+), 170 deletions(-)

diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index ff9bcdc..c5879f1 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -2814,7 +2814,7 @@ static int ext3_statfs (struct dentry * dentry, struct kstatfs * buf)
 
 static inline struct inode *dquot_to_inode(struct dquot *dquot)
 {
-	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_type];
+	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_own.type];
 }
 
 static int ext3_write_dquot(struct dquot *dquot)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d76ec82..f60b48f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4796,7 +4796,7 @@ static int ext4_statfs(struct dentry *dentry, struct kstatfs *buf)
 
 static inline struct inode *dquot_to_inode(struct dquot *dquot)
 {
-	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_type];
+	return sb_dqopt(dquot->dq_sb)->files[dquot->dq_own.type];
 }
 
 static int ext4_write_dquot(struct dquot *dquot)
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index a3bde91..f0310f9 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1057,6 +1057,8 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
                 return 0;
 
 	for (x = 0; x < ip->i_res->rs_qa_qd_num; x++) {
+		int qtype;
+		struct qown qown;
 		qd = ip->i_res->rs_qa_qd[x];
 
 		if (!((qd->qd_id == uid && test_bit(QDF_USER, &qd->qd_flags)) ||
@@ -1068,11 +1070,12 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
 		value += qd->qd_change;
 		spin_unlock(&qd_lru_lock);
 
+		qtype = test_bit(QDF_USER, &qd->qd_flags) ? USRQUOTA : GRPQUOTA;
+		qown = make_qown(&init_user_ns, qtype, qd->qd_id);
 		if (be64_to_cpu(qd->qd_qb.qb_limit) && (s64)be64_to_cpu(qd->qd_qb.qb_limit) < value) {
 			print_message(qd, "exceeded");
-			quota_send_warning(test_bit(QDF_USER, &qd->qd_flags) ?
-					   USRQUOTA : GRPQUOTA, qd->qd_id,
-					   sdp->sd_vfs->s_dev, QUOTA_NL_BHARDWARN);
+			quota_send_warning(qown, sdp->sd_vfs->s_dev,
+					   QUOTA_NL_BHARDWARN);
 
 			error = -EDQUOT;
 			break;
@@ -1081,9 +1084,8 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
 			   time_after_eq(jiffies, qd->qd_last_warn +
 					 gfs2_tune_get(sdp,
 						gt_quota_warn_period) * HZ)) {
-			quota_send_warning(test_bit(QDF_USER, &qd->qd_flags) ?
-					   USRQUOTA : GRPQUOTA, qd->qd_id,
-					   sdp->sd_vfs->s_dev, QUOTA_NL_BSOFTWARN);
+			quota_send_warning(qown, sdp->sd_vfs->s_dev,
+					   QUOTA_NL_BSOFTWARN);
 			error = print_message(qd, "warning");
 			qd->qd_last_warn = jiffies;
 		}
@@ -1469,7 +1471,7 @@ static int gfs2_quota_get_xstate(struct super_block *sb,
 	return 0;
 }
 
-static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
+static int gfs2_get_dqblk(struct super_block *sb, struct qown qown,
 			  struct fs_disk_quota *fdq)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
@@ -1477,20 +1479,24 @@ static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
 	struct gfs2_quota_data *qd;
 	struct gfs2_holder q_gh;
 	int error;
+	int user;
+	u32 gfs_id;
 
 	memset(fdq, 0, sizeof(struct fs_disk_quota));
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	if (type == USRQUOTA)
-		type = QUOTA_USER;
-	else if (type == GRPQUOTA)
-		type = QUOTA_GROUP;
+	gfs_id = from_qown(&init_user_ns, qown);
+
+	if (qown.type == USRQUOTA)
+		user = QUOTA_USER;
+	else if (qown.type == GRPQUOTA)
+		user = QUOTA_GROUP;
 	else
 		return -EINVAL;
 
-	error = qd_get(sdp, type, id, &qd);
+	error = qd_get(sdp, user, gfs_id, &qd);
 	if (error)
 		return error;
 	error = do_glock(qd, FORCE, &q_gh);
@@ -1499,8 +1505,8 @@ static int gfs2_get_dqblk(struct super_block *sb, int type, qid_t id,
 
 	qlvb = (struct gfs2_quota_lvb *)qd->qd_gl->gl_lvb;
 	fdq->d_version = FS_DQUOT_VERSION;
-	fdq->d_flags = (type == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
-	fdq->d_id = id;
+	fdq->d_flags = (user == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
+	fdq->d_id = gfs_id;
 	fdq->d_blk_hardlimit = be64_to_cpu(qlvb->qb_limit) << sdp->sd_fsb2bb_shift;
 	fdq->d_blk_softlimit = be64_to_cpu(qlvb->qb_warn) << sdp->sd_fsb2bb_shift;
 	fdq->d_bcount = be64_to_cpu(qlvb->qb_value) << sdp->sd_fsb2bb_shift;
@@ -1514,8 +1520,8 @@ out:
 /* GFS2 only supports a subset of the XFS fields */
 #define GFS2_FIELDMASK (FS_DQ_BSOFT|FS_DQ_BHARD|FS_DQ_BCOUNT)
 
-static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
-			  struct fs_disk_quota *fdq)
+static int gfs2_set_dqblk(struct super_block *sb,
+			  struct qown qown, struct fs_disk_quota *fdq)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
 	struct gfs2_inode *ip = GFS2_I(sdp->sd_quota_inode);
@@ -1526,18 +1532,22 @@ static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
 	int alloc_required;
 	loff_t offset;
 	int error;
+	int user;
+	u32 gfs_id;
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	switch(type) {
+	gfs_id = from_qown(&init_user_ns, qown);
+
+	switch(qown.type) {
 	case USRQUOTA:
-		type = QUOTA_USER;
+		user = QUOTA_USER;
 		if (fdq->d_flags != FS_USER_QUOTA)
 			return -EINVAL;
 		break;
 	case GRPQUOTA:
-		type = QUOTA_GROUP;
+		user = QUOTA_GROUP;
 		if (fdq->d_flags != FS_GROUP_QUOTA)
 			return -EINVAL;
 		break;
@@ -1547,10 +1557,10 @@ static int gfs2_set_dqblk(struct super_block *sb, int type, qid_t id,
 
 	if (fdq->d_fieldmask & ~GFS2_FIELDMASK)
 		return -EINVAL;
-	if (fdq->d_id != id)
+	if (fdq->d_id != gfs_id)
 		return -EINVAL;
 
-	error = qd_get(sdp, type, id, &qd);
+	error = qd_get(sdp, user, gfs_id, &qd);
 	if (error)
 		return error;
 
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 46a1f6d..3879186 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -1184,8 +1184,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 		if (attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_USRQUOTA)) {
-			transfer_to[USRQUOTA] = dqget(sb, attr->ia_uid,
-						      USRQUOTA);
+			transfer_to[USRQUOTA] = dqget(sb, make_qown_uid(attr->ia_uid));
 			if (!transfer_to[USRQUOTA]) {
 				status = -ESRCH;
 				goto bail_unlock;
@@ -1194,8 +1193,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 		if (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_GRPQUOTA)) {
-			transfer_to[GRPQUOTA] = dqget(sb, attr->ia_gid,
-						      GRPQUOTA);
+			transfer_to[GRPQUOTA] = dqget(sb, make_qown_gid(attr->ia_gid));
 			if (!transfer_to[GRPQUOTA]) {
 				status = -ESRCH;
 				goto bail_unlock;
diff --git a/fs/ocfs2/quota_global.c b/fs/ocfs2/quota_global.c
index 0a86e30..dcee469 100644
--- a/fs/ocfs2/quota_global.c
+++ b/fs/ocfs2/quota_global.c
@@ -95,7 +95,7 @@ static void ocfs2_global_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct ocfs2_global_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_qown(&init_user_ns, dquot->dq_own));
 	d->dqb_use_count = cpu_to_le32(OCFS2_DQUOT(dquot)->dq_use_count);
 	d->dqb_ihardlimit = cpu_to_le64(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le64(m->dqb_isoftlimit);
@@ -112,11 +112,14 @@ static int ocfs2_global_is_id(void *dp, struct dquot *dquot)
 {
 	struct ocfs2_global_disk_dqblk *d = dp;
 	struct ocfs2_mem_dqinfo *oinfo =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
+	struct qown qown;
 
 	if (qtree_entry_unused(&oinfo->dqi_gi, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+
+	qown = make_qown(&init_user_ns, dquot->dq_own.type, le32_to_cpu(d->dqb_id));
+	return qown_eq(qown, dquot->dq_own);
 }
 
 struct qtree_fmt_operations ocfs2_global_ops = {
@@ -475,7 +478,7 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 {
 	int err, err2;
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct ocfs2_mem_dqinfo *info = sb_dqinfo(sb, type)->dqi_priv;
 	struct ocfs2_global_disk_dqblk dqblk;
 	s64 spacechange, inodechange;
@@ -504,7 +507,8 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 	olditime = dquot->dq_dqb.dqb_itime;
 	oldbtime = dquot->dq_dqb.dqb_btime;
 	ocfs2_global_disk2memdqb(dquot, &dqblk);
-	trace_ocfs2_sync_dquot(dquot->dq_id, dquot->dq_dqb.dqb_curspace,
+	trace_ocfs2_sync_dquot(from_qown(&init_user_ns, dquot->dq_own),
+			       dquot->dq_dqb.dqb_curspace,
 			       (long long)spacechange,
 			       dquot->dq_dqb.dqb_curinodes,
 			       (long long)inodechange);
@@ -555,8 +559,8 @@ int __ocfs2_sync_dquot(struct dquot *dquot, int freeing)
 	err = ocfs2_qinfo_lock(info, freeing);
 	if (err < 0) {
 		mlog(ML_ERROR, "Failed to lock quota info, losing quota write"
-			       " (type=%d, id=%u)\n", dquot->dq_type,
-			       (unsigned)dquot->dq_id);
+			       " (type=%d, id=%u)\n", dquot->dq_own.type,
+			       (unsigned)from_qown(&init_user_ns, dquot->dq_own));
 		goto out;
 	}
 	if (freeing)
@@ -591,9 +595,10 @@ static int ocfs2_sync_dquot_helper(struct dquot *dquot, unsigned long type)
 	struct ocfs2_super *osb = OCFS2_SB(sb);
 	int status = 0;
 
-	trace_ocfs2_sync_dquot_helper(dquot->dq_id, dquot->dq_type,
+	trace_ocfs2_sync_dquot_helper(from_qown(&init_user_ns, dquot->dq_own),
+				      dquot->dq_own.type,
 				      type, sb->s_id);
-	if (type != dquot->dq_type)
+	if (type != dquot->dq_own.type)
 		goto out;
 	status = ocfs2_lock_global_qf(oinfo, 1);
 	if (status < 0)
@@ -643,7 +648,8 @@ static int ocfs2_write_dquot(struct dquot *dquot)
 	struct ocfs2_super *osb = OCFS2_SB(dquot->dq_sb);
 	int status = 0;
 
-	trace_ocfs2_write_dquot(dquot->dq_id, dquot->dq_type);
+	trace_ocfs2_write_dquot(from_qown(&init_user_ns, dquot->dq_own),
+				dquot->dq_own.type);
 
 	handle = ocfs2_start_trans(osb, OCFS2_QWRITE_CREDITS);
 	if (IS_ERR(handle)) {
@@ -677,11 +683,12 @@ static int ocfs2_release_dquot(struct dquot *dquot)
 {
 	handle_t *handle;
 	struct ocfs2_mem_dqinfo *oinfo =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
 	struct ocfs2_super *osb = OCFS2_SB(dquot->dq_sb);
 	int status = 0;
 
-	trace_ocfs2_release_dquot(dquot->dq_id, dquot->dq_type);
+	trace_ocfs2_release_dquot(from_qown(&init_user_ns, dquot->dq_own),
+				  dquot->dq_own.type);
 
 	mutex_lock(&dquot->dq_lock);
 	/* Check whether we are not racing with some other dqget() */
@@ -691,7 +698,7 @@ static int ocfs2_release_dquot(struct dquot *dquot)
 	if (status < 0)
 		goto out;
 	handle = ocfs2_start_trans(osb,
-		ocfs2_calc_qdel_credits(dquot->dq_sb, dquot->dq_type));
+		ocfs2_calc_qdel_credits(dquot->dq_sb, dquot->dq_own.type));
 	if (IS_ERR(handle)) {
 		status = PTR_ERR(handle);
 		mlog_errno(status);
@@ -733,13 +740,14 @@ static int ocfs2_acquire_dquot(struct dquot *dquot)
 	int ex = 0;
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_super *osb = OCFS2_SB(sb);
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct ocfs2_mem_dqinfo *info = sb_dqinfo(sb, type)->dqi_priv;
 	struct inode *gqinode = info->dqi_gqinode;
 	int need_alloc = ocfs2_global_qinit_alloc(sb, type);
 	handle_t *handle;
 
-	trace_ocfs2_acquire_dquot(dquot->dq_id, type);
+	trace_ocfs2_acquire_dquot(from_qown(&init_user_ns, dquot->dq_own),
+				  type);
 	mutex_lock(&dquot->dq_lock);
 	/*
 	 * We need an exclusive lock, because we're going to update use count
@@ -821,12 +829,13 @@ static int ocfs2_mark_dquot_dirty(struct dquot *dquot)
 	int sync = 0;
 	int status;
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct ocfs2_mem_dqinfo *oinfo = sb_dqinfo(sb, type)->dqi_priv;
 	handle_t *handle;
 	struct ocfs2_super *osb = OCFS2_SB(sb);
 
-	trace_ocfs2_mark_dquot_dirty(dquot->dq_id, type);
+	trace_ocfs2_mark_dquot_dirty(from_qown(&init_user_ns, dquot->dq_own),
+				     type);
 
 	/* In case user set some limits, sync dquot immediately to global
 	 * quota file so that information propagates quicker */
diff --git a/fs/ocfs2/quota_local.c b/fs/ocfs2/quota_local.c
index f100bf7..3aec405 100644
--- a/fs/ocfs2/quota_local.c
+++ b/fs/ocfs2/quota_local.c
@@ -501,7 +501,9 @@ static int ocfs2_recover_local_quota_file(struct inode *lqinode,
 			}
 			dqblk = (struct ocfs2_local_disk_dqblk *)(qbh->b_data +
 				ol_dqblk_block_off(sb, chunk, bit));
-			dquot = dqget(sb, le64_to_cpu(dqblk->dqb_id), type);
+			dquot = dqget(sb,
+				      make_qown(&init_user_ns, type,
+						le64_to_cpu(dqblk->dqb_id)));
 			if (!dquot) {
 				status = -EIO;
 				mlog(ML_ERROR, "Failed to get quota structure "
@@ -881,7 +883,8 @@ static void olq_set_dquot(struct buffer_head *bh, void *private)
 	dqblk = (struct ocfs2_local_disk_dqblk *)(bh->b_data
 		+ ol_dqblk_block_offset(sb, od->dq_local_off));
 
-	dqblk->dqb_id = cpu_to_le64(od->dq_dquot.dq_id);
+	dqblk->dqb_id = cpu_to_le64(from_qown(&init_user_ns,
+					      od->dq_dquot.dq_own));
 	spin_lock(&dq_data_lock);
 	dqblk->dqb_spacemod = cpu_to_le64(od->dq_dquot.dq_dqb.dqb_curspace -
 					  od->dq_origspace);
@@ -891,7 +894,7 @@ static void olq_set_dquot(struct buffer_head *bh, void *private)
 	trace_olq_set_dquot(
 		(unsigned long long)le64_to_cpu(dqblk->dqb_spacemod),
 		(unsigned long long)le64_to_cpu(dqblk->dqb_inodemod),
-		od->dq_dquot.dq_id);
+		from_qown(&init_user_ns, od->dq_dquot.dq_own));
 }
 
 /* Write dquot to local quota file */
@@ -900,7 +903,7 @@ int ocfs2_local_write_dquot(struct dquot *dquot)
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
 	struct buffer_head *bh;
-	struct inode *lqinode = sb_dqopt(sb)->files[dquot->dq_type];
+	struct inode *lqinode = sb_dqopt(sb)->files[dquot->dq_own.type];
 	int status;
 
 	status = ocfs2_read_quota_phys_block(lqinode, od->dq_local_phys_blk,
@@ -1221,7 +1224,7 @@ static void olq_alloc_dquot(struct buffer_head *bh, void *private)
 int ocfs2_create_local_dquot(struct dquot *dquot)
 {
 	struct super_block *sb = dquot->dq_sb;
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct inode *lqinode = sb_dqopt(sb)->files[type];
 	struct ocfs2_quota_chunk *chunk;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
@@ -1275,7 +1278,7 @@ out:
 int ocfs2_local_release_dquot(handle_t *handle, struct dquot *dquot)
 {
 	int status;
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct ocfs2_dquot *od = OCFS2_DQUOT(dquot);
 	struct super_block *sb = dquot->dq_sb;
 	struct ocfs2_local_disk_chunk *dchunk;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 36a29b7..766ab61 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -253,11 +253,13 @@ static qsize_t inode_get_rsv_space(struct inode *inode);
 static void __dquot_initialize(struct inode *inode, int type);
 
 static inline unsigned int
-hashfn(const struct super_block *sb, unsigned int id, int type)
+hashfn(const struct super_block *sb, struct qown qown)
 {
+	unsigned int id;
 	unsigned long tmp;
 
-	tmp = (((unsigned long)sb>>L1_CACHE_SHIFT) ^ id) * (MAXQUOTAS - type);
+	id = from_qown(&init_user_ns, qown);
+	tmp = (((unsigned long)sb>>L1_CACHE_SHIFT) ^ id) * (MAXQUOTAS - qown.type);
 	return (tmp + (tmp >> dq_hash_bits)) & dq_hash_mask;
 }
 
@@ -267,7 +269,7 @@ hashfn(const struct super_block *sb, unsigned int id, int type)
 static inline void insert_dquot_hash(struct dquot *dquot)
 {
 	struct hlist_head *head;
-	head = dquot_hash + hashfn(dquot->dq_sb, dquot->dq_id, dquot->dq_type);
+	head = dquot_hash + hashfn(dquot->dq_sb, dquot->dq_own);
 	hlist_add_head(&dquot->dq_hash, head);
 }
 
@@ -277,15 +279,14 @@ static inline void remove_dquot_hash(struct dquot *dquot)
 }
 
 static struct dquot *find_dquot(unsigned int hashent, struct super_block *sb,
-				unsigned int id, int type)
+				struct qown own)
 {
 	struct hlist_node *node;
 	struct dquot *dquot;
 
 	hlist_for_each (node, dquot_hash+hashent) {
 		dquot = hlist_entry(node, struct dquot, dq_hash);
-		if (dquot->dq_sb == sb && dquot->dq_id == id &&
-		    dquot->dq_type == type)
+		if (dquot->dq_sb == sb && qown_eq(dquot->dq_own, own))
 			return dquot;
 	}
 	return NULL;
@@ -351,7 +352,7 @@ int dquot_mark_dquot_dirty(struct dquot *dquot)
 	spin_lock(&dq_list_lock);
 	if (!test_and_set_bit(DQ_MOD_B, &dquot->dq_flags)) {
 		list_add(&dquot->dq_dirty, &sb_dqopt(dquot->dq_sb)->
-				info[dquot->dq_type].dqi_dirty_list);
+				info[dquot->dq_own.type].dqi_dirty_list);
 		ret = 0;
 	}
 	spin_unlock(&dq_list_lock);
@@ -410,17 +411,17 @@ int dquot_acquire(struct dquot *dquot)
 	mutex_lock(&dquot->dq_lock);
 	mutex_lock(&dqopt->dqio_mutex);
 	if (!test_bit(DQ_READ_B, &dquot->dq_flags))
-		ret = dqopt->ops[dquot->dq_type]->read_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_own.type]->read_dqblk(dquot);
 	if (ret < 0)
 		goto out_iolock;
 	set_bit(DQ_READ_B, &dquot->dq_flags);
 	/* Instantiate dquot if needed */
 	if (!test_bit(DQ_ACTIVE_B, &dquot->dq_flags) && !dquot->dq_off) {
-		ret = dqopt->ops[dquot->dq_type]->commit_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_own.type]->commit_dqblk(dquot);
 		/* Write the info if needed */
-		if (info_dirty(&dqopt->info[dquot->dq_type])) {
-			ret2 = dqopt->ops[dquot->dq_type]->write_file_info(
-						dquot->dq_sb, dquot->dq_type);
+		if (info_dirty(&dqopt->info[dquot->dq_own.type])) {
+			ret2 = dqopt->ops[dquot->dq_own.type]->write_file_info(
+					dquot->dq_sb, dquot->dq_own.type);
 		}
 		if (ret < 0)
 			goto out_iolock;
@@ -455,7 +456,7 @@ int dquot_commit(struct dquot *dquot)
 	/* Inactive dquot can be only if there was error during read/init
 	 * => we have better not writing it */
 	if (test_bit(DQ_ACTIVE_B, &dquot->dq_flags))
-		ret = dqopt->ops[dquot->dq_type]->commit_dqblk(dquot);
+		ret = dqopt->ops[dquot->dq_own.type]->commit_dqblk(dquot);
 	else
 		ret = -EIO;
 out_sem:
@@ -477,12 +478,12 @@ int dquot_release(struct dquot *dquot)
 	if (atomic_read(&dquot->dq_count) > 1)
 		goto out_dqlock;
 	mutex_lock(&dqopt->dqio_mutex);
-	if (dqopt->ops[dquot->dq_type]->release_dqblk) {
-		ret = dqopt->ops[dquot->dq_type]->release_dqblk(dquot);
+	if (dqopt->ops[dquot->dq_own.type]->release_dqblk) {
+		ret = dqopt->ops[dquot->dq_own.type]->release_dqblk(dquot);
 		/* Write the info */
-		if (info_dirty(&dqopt->info[dquot->dq_type])) {
-			ret2 = dqopt->ops[dquot->dq_type]->write_file_info(
-						dquot->dq_sb, dquot->dq_type);
+		if (info_dirty(&dqopt->info[dquot->dq_own.type])) {
+			ret2 = dqopt->ops[dquot->dq_own.type]->write_file_info(
+						dquot->dq_sb, dquot->dq_own.type);
 		}
 		if (ret >= 0)
 			ret = ret2;
@@ -521,7 +522,7 @@ restart:
 	list_for_each_entry_safe(dquot, tmp, &inuse_list, dq_inuse) {
 		if (dquot->dq_sb != sb)
 			continue;
-		if (dquot->dq_type != type)
+		if (dquot->dq_own.type != type)
 			continue;
 		/* Wait for dquot users */
 		if (atomic_read(&dquot->dq_count)) {
@@ -741,7 +742,8 @@ void dqput(struct dquot *dquot)
 #ifdef CONFIG_QUOTA_DEBUG
 	if (!atomic_read(&dquot->dq_count)) {
 		quota_error(dquot->dq_sb, "trying to free free dquot of %s %d",
-			    quotatypes[dquot->dq_type], dquot->dq_id);
+			    quotatypes[dquot->dq_own.type],
+			    from_qown(&init_user_ns, dquot->dq_own));
 		BUG();
 	}
 #endif
@@ -752,7 +754,7 @@ we_slept:
 		/* We have more than one user... nothing to do */
 		atomic_dec(&dquot->dq_count);
 		/* Releasing dquot during quotaoff phase? */
-		if (!sb_has_quota_active(dquot->dq_sb, dquot->dq_type) &&
+		if (!sb_has_quota_active(dquot->dq_sb, dquot->dq_own.type) &&
 		    atomic_read(&dquot->dq_count) == 1)
 			wake_up(&dquot->dq_wait_unused);
 		spin_unlock(&dq_list_lock);
@@ -815,7 +817,7 @@ static struct dquot *get_empty_dquot(struct super_block *sb, int type)
 	INIT_LIST_HEAD(&dquot->dq_dirty);
 	init_waitqueue_head(&dquot->dq_wait_unused);
 	dquot->dq_sb = sb;
-	dquot->dq_type = type;
+	dquot->dq_own = make_qown_invalid(type);
 	atomic_set(&dquot->dq_count, 1);
 
 	return dquot;
@@ -829,35 +831,35 @@ static struct dquot *get_empty_dquot(struct super_block *sb, int type)
  *   a) checking for quota flags under dq_list_lock and
  *   b) getting a reference to dquot before we release dq_list_lock
  */
-struct dquot *dqget(struct super_block *sb, unsigned int id, int type)
+struct dquot *dqget(struct super_block *sb, struct qown qown)
 {
-	unsigned int hashent = hashfn(sb, id, type);
+	unsigned int hashent = hashfn(sb, qown);
 	struct dquot *dquot = NULL, *empty = NULL;
 
-        if (!sb_has_quota_active(sb, type))
+        if (!sb_has_quota_active(sb, qown.type))
 		return NULL;
 we_slept:
 	spin_lock(&dq_list_lock);
 	spin_lock(&dq_state_lock);
-	if (!sb_has_quota_active(sb, type)) {
+	if (!sb_has_quota_active(sb, qown.type)) {
 		spin_unlock(&dq_state_lock);
 		spin_unlock(&dq_list_lock);
 		goto out;
 	}
 	spin_unlock(&dq_state_lock);
 
-	dquot = find_dquot(hashent, sb, id, type);
+	dquot = find_dquot(hashent, sb, qown);
 	if (!dquot) {
 		if (!empty) {
 			spin_unlock(&dq_list_lock);
-			empty = get_empty_dquot(sb, type);
+			empty = get_empty_dquot(sb, qown.type);
 			if (!empty)
 				schedule();	/* Try to wait for a moment... */
 			goto we_slept;
 		}
 		dquot = empty;
 		empty = NULL;
-		dquot->dq_id = id;
+		dquot->dq_own = qown;
 		/* all dquots go on the inuse_list */
 		put_inuse(dquot);
 		/* hash it first so it can be found */
@@ -1129,8 +1131,7 @@ static void dquot_decr_space(struct dquot *dquot, qsize_t number)
 
 struct dquot_warn {
 	struct super_block *w_sb;
-	qid_t w_dq_id;
-	short w_dq_type;
+	struct qown w_dq_own;
 	short w_type;
 };
 
@@ -1154,11 +1155,11 @@ static int need_print_warning(struct dquot_warn *warn)
 	if (!flag_print_warnings)
 		return 0;
 
-	switch (warn->w_dq_type) {
+	switch (warn->w_dq_own.type) {
 		case USRQUOTA:
-			return current_fsuid() == warn->w_dq_id;
+			return uid_eq(current_fsuid(), warn->w_dq_own.uid);
 		case GRPQUOTA:
-			return in_group_p(warn->w_dq_id);
+			return in_group_p(warn->w_dq_own.gid);
 	}
 	return 0;
 }
@@ -1184,7 +1185,7 @@ static void print_warning(struct dquot_warn *warn)
 		tty_write_message(tty, ": warning, ");
 	else
 		tty_write_message(tty, ": write failed, ");
-	tty_write_message(tty, quotatypes[warn->w_dq_type]);
+	tty_write_message(tty, quotatypes[warn->w_dq_own.type]);
 	switch (warntype) {
 		case QUOTA_NL_IHARDWARN:
 			msg = " file limit reached.\r\n";
@@ -1217,8 +1218,7 @@ static void prepare_warning(struct dquot_warn *warn, struct dquot *dquot,
 		return;
 	warn->w_type = warntype;
 	warn->w_sb = dquot->dq_sb;
-	warn->w_dq_id = dquot->dq_id;
-	warn->w_dq_type = dquot->dq_type;
+	warn->w_dq_own = dquot->dq_own;
 }
 
 /*
@@ -1236,14 +1236,14 @@ static void flush_warnings(struct dquot_warn *warn)
 #ifdef CONFIG_PRINT_QUOTA_WARNING
 		print_warning(&warn[i]);
 #endif
-		quota_send_warning(warn[i].w_dq_type, warn[i].w_dq_id,
+		quota_send_warning(warn[i].w_dq_own,
 				   warn[i].w_sb->s_dev, warn[i].w_type);
 	}
 }
 
 static int ignore_hardlimit(struct dquot *dquot)
 {
-	struct mem_dqinfo *info = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_type];
+	struct mem_dqinfo *info = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_own.type];
 
 	return capable(CAP_SYS_RESOURCE) &&
 	       (info->dqi_format->qf_fmt_id != QFMT_VFS_OLD ||
@@ -1256,7 +1256,7 @@ static int check_idq(struct dquot *dquot, qsize_t inodes,
 {
 	qsize_t newinodes = dquot->dq_dqb.dqb_curinodes + inodes;
 
-	if (!sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_type) ||
+	if (!sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_own.type) ||
 	    test_bit(DQ_FAKE_B, &dquot->dq_flags))
 		return 0;
 
@@ -1281,7 +1281,7 @@ static int check_idq(struct dquot *dquot, qsize_t inodes,
 	    dquot->dq_dqb.dqb_itime == 0) {
 		prepare_warning(warn, dquot, QUOTA_NL_ISOFTWARN);
 		dquot->dq_dqb.dqb_itime = get_seconds() +
-		    sb_dqopt(dquot->dq_sb)->info[dquot->dq_type].dqi_igrace;
+		    sb_dqopt(dquot->dq_sb)->info[dquot->dq_own.type].dqi_igrace;
 	}
 
 	return 0;
@@ -1294,7 +1294,7 @@ static int check_bdq(struct dquot *dquot, qsize_t space, int prealloc,
 	qsize_t tspace;
 	struct super_block *sb = dquot->dq_sb;
 
-	if (!sb_has_quota_limits_enabled(sb, dquot->dq_type) ||
+	if (!sb_has_quota_limits_enabled(sb, dquot->dq_own.type) ||
 	    test_bit(DQ_FAKE_B, &dquot->dq_flags))
 		return 0;
 
@@ -1325,7 +1325,7 @@ static int check_bdq(struct dquot *dquot, qsize_t space, int prealloc,
 		if (!prealloc) {
 			prepare_warning(warn, dquot, QUOTA_NL_BSOFTWARN);
 			dquot->dq_dqb.dqb_btime = get_seconds() +
-			    sb_dqopt(sb)->info[dquot->dq_type].dqi_bgrace;
+			    sb_dqopt(sb)->info[dquot->dq_own.type].dqi_bgrace;
 		}
 		else
 			/*
@@ -1344,7 +1344,7 @@ static int info_idq_free(struct dquot *dquot, qsize_t inodes)
 
 	if (test_bit(DQ_FAKE_B, &dquot->dq_flags) ||
 	    dquot->dq_dqb.dqb_curinodes <= dquot->dq_dqb.dqb_isoftlimit ||
-	    !sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_type))
+	    !sb_has_quota_limits_enabled(dquot->dq_sb, dquot->dq_own.type))
 		return QUOTA_NL_NOWARN;
 
 	newinodes = dquot->dq_dqb.dqb_curinodes - inodes;
@@ -1390,7 +1390,6 @@ static int dquot_active(const struct inode *inode)
  */
 static void __dquot_initialize(struct inode *inode, int type)
 {
-	unsigned int id = 0;
 	int cnt;
 	struct dquot *got[MAXQUOTAS];
 	struct super_block *sb = inode->i_sb;
@@ -1403,18 +1402,19 @@ static void __dquot_initialize(struct inode *inode, int type)
 
 	/* First get references to structures we might need. */
 	for (cnt = 0; cnt < MAXQUOTAS; cnt++) {
+		struct qown qown;
 		got[cnt] = NULL;
 		if (type != -1 && cnt != type)
 			continue;
 		switch (cnt) {
 		case USRQUOTA:
-			id = inode->i_uid;
+			qown = make_qown_uid(inode->i_uid);
 			break;
 		case GRPQUOTA:
-			id = inode->i_gid;
+			qown = make_qown_gid(inode->i_gid);
 			break;
 		}
-		got[cnt] = dqget(sb, id, cnt);
+		got[cnt] = dqget(sb, qown);
 	}
 
 	down_write(&sb_dqopt(sb)->dqptr_sem);
@@ -1897,10 +1897,10 @@ int dquot_transfer(struct inode *inode, struct iattr *iattr)
 	if (!dquot_active(inode))
 		return 0;
 
-	if (iattr->ia_valid & ATTR_UID && iattr->ia_uid != inode->i_uid)
-		transfer_to[USRQUOTA] = dqget(sb, iattr->ia_uid, USRQUOTA);
-	if (iattr->ia_valid & ATTR_GID && iattr->ia_gid != inode->i_gid)
-		transfer_to[GRPQUOTA] = dqget(sb, iattr->ia_gid, GRPQUOTA);
+	if (iattr->ia_valid & ATTR_UID && !uid_eq(iattr->ia_uid, inode->i_uid))
+		transfer_to[USRQUOTA] = dqget(sb, make_qown_uid(iattr->ia_uid));
+	if (iattr->ia_valid & ATTR_GID && !gid_eq(iattr->ia_gid, inode->i_gid))
+		transfer_to[GRPQUOTA] = dqget(sb, make_qown_gid(iattr->ia_gid));
 
 	ret = __dquot_transfer(inode, transfer_to);
 	dqput_all(transfer_to);
@@ -2360,9 +2360,9 @@ static void do_get_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 
 	memset(di, 0, sizeof(*di));
 	di->d_version = FS_DQUOT_VERSION;
-	di->d_flags = dquot->dq_type == USRQUOTA ?
+	di->d_flags = dquot->dq_own.type == USRQUOTA ?
 			FS_USER_QUOTA : FS_GROUP_QUOTA;
-	di->d_id = dquot->dq_id;
+	di->d_id = from_qown_munged(current_user_ns(), dquot->dq_own);
 
 	spin_lock(&dq_data_lock);
 	di->d_blk_hardlimit = stoqb(dm->dqb_bhardlimit);
@@ -2376,12 +2376,12 @@ static void do_get_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 	spin_unlock(&dq_data_lock);
 }
 
-int dquot_get_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_get_dqblk(struct super_block *sb, struct qown qown,
 		    struct fs_disk_quota *di)
 {
 	struct dquot *dquot;
 
-	dquot = dqget(sb, id, type);
+	dquot = dqget(sb, qown);
 	if (!dquot)
 		return -ESRCH;
 	do_get_dqblk(dquot, di);
@@ -2401,7 +2401,7 @@ static int do_set_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 {
 	struct mem_dqblk *dm = &dquot->dq_dqb;
 	int check_blim = 0, check_ilim = 0;
-	struct mem_dqinfo *dqi = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_type];
+	struct mem_dqinfo *dqi = &sb_dqopt(dquot->dq_sb)->info[dquot->dq_own.type];
 
 	if (di->d_fieldmask & ~VFS_FS_DQ_MASK)
 		return -EINVAL;
@@ -2488,13 +2488,13 @@ static int do_set_dqblk(struct dquot *dquot, struct fs_disk_quota *di)
 	return 0;
 }
 
-int dquot_set_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_set_dqblk(struct super_block *sb, struct qown qown,
 		  struct fs_disk_quota *di)
 {
 	struct dquot *dquot;
 	int rc;
 
-	dquot = dqget(sb, id, type);
+	dquot = dqget(sb, qown);
 	if (!dquot) {
 		rc = -ESRCH;
 		goto out;
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index d67908b..82e99d7 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -30,7 +30,7 @@ static struct genl_family quota_genl_family = {
  *
  */
 
-void quota_send_warning(short type, unsigned int id, dev_t dev,
+void quota_send_warning(struct qown qown, dev_t dev,
 			const char warntype)
 {
 	static atomic_t seq;
@@ -56,10 +56,11 @@ void quota_send_warning(short type, unsigned int id, dev_t dev,
 		  "VFS: Cannot store netlink header in quota warning.\n");
 		goto err_out;
 	}
-	ret = nla_put_u32(skb, QUOTA_NL_A_QTYPE, type);
+	ret = nla_put_u32(skb, QUOTA_NL_A_QTYPE, qown.type);
 	if (ret)
 		goto attr_err_out;
-	ret = nla_put_u64(skb, QUOTA_NL_A_EXCESS_ID, id);
+	ret = nla_put_u64(skb, QUOTA_NL_A_EXCESS_ID,
+			  from_qown_munged(&init_user_ns, qown));
 	if (ret)
 		goto attr_err_out;
 	ret = nla_put_u32(skb, QUOTA_NL_A_WARNING, warntype);
@@ -71,7 +72,8 @@ void quota_send_warning(short type, unsigned int id, dev_t dev,
 	ret = nla_put_u32(skb, QUOTA_NL_A_DEV_MINOR, MINOR(dev));
 	if (ret)
 		goto attr_err_out;
-	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID, current_uid());
+	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID,
+			  from_kuid_munged(&init_user_ns, current_uid()));
 	if (ret)
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index 6f15578..a31dc42 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -32,8 +32,8 @@ static int check_quotactl_permission(struct super_block *sb, int type, int cmd,
 	/* allow to query information for dquots we "own" */
 	case Q_GETQUOTA:
 	case Q_XGETQUOTA:
-		if ((type == USRQUOTA && current_euid() == id) ||
-		    (type == GRPQUOTA && in_egroup_p(id)))
+		if ((type == USRQUOTA && uid_eq(current_euid(), make_kuid(current_user_ns(), id))) ||
+		    (type == GRPQUOTA && in_egroup_p(make_kgid(current_user_ns(), id))))
 			break;
 		/*FALLTHROUGH*/
 	default:
@@ -130,13 +130,17 @@ static void copy_to_if_dqblk(struct if_dqblk *dst, struct fs_disk_quota *src)
 static int quota_getquota(struct super_block *sb, int type, qid_t id,
 			  void __user *addr)
 {
+	struct qown qown;
 	struct fs_disk_quota fdq;
 	struct if_dqblk idq;
 	int ret;
 
 	if (!sb->s_qcop->get_dqblk)
 		return -ENOSYS;
-	ret = sb->s_qcop->get_dqblk(sb, type, id, &fdq);
+	qown = make_qown(current_user_ns(), type, id);
+	if (!qown_valid(qown))
+		return -EINVAL;
+	ret = sb->s_qcop->get_dqblk(sb, qown, &fdq);
 	if (ret)
 		return ret;
 	copy_to_if_dqblk(&idq, &fdq);
@@ -176,13 +180,17 @@ static int quota_setquota(struct super_block *sb, int type, qid_t id,
 {
 	struct fs_disk_quota fdq;
 	struct if_dqblk idq;
+	struct qown qown;
 
 	if (copy_from_user(&idq, addr, sizeof(idq)))
 		return -EFAULT;
 	if (!sb->s_qcop->set_dqblk)
 		return -ENOSYS;
+	qown = make_qown(current_user_ns(), type, id);
+	if (!qown_valid(qown))
+		return -EINVAL;
 	copy_from_if_dqblk(&fdq, &idq);
-	return sb->s_qcop->set_dqblk(sb, type, id, &fdq);
+	return sb->s_qcop->set_dqblk(sb, qown, &fdq);
 }
 
 static int quota_setxstate(struct super_block *sb, int cmd, void __user *addr)
@@ -213,23 +221,31 @@ static int quota_setxquota(struct super_block *sb, int type, qid_t id,
 			   void __user *addr)
 {
 	struct fs_disk_quota fdq;
+	struct qown qown;
 
 	if (copy_from_user(&fdq, addr, sizeof(fdq)))
 		return -EFAULT;
 	if (!sb->s_qcop->set_dqblk)
 		return -ENOSYS;
-	return sb->s_qcop->set_dqblk(sb, type, id, &fdq);
+	qown = make_qown(current_user_ns(), type, id);
+	if (!qown_valid(qown))
+		return -EINVAL;
+	return sb->s_qcop->set_dqblk(sb, qown, &fdq);
 }
 
 static int quota_getxquota(struct super_block *sb, int type, qid_t id,
 			   void __user *addr)
 {
 	struct fs_disk_quota fdq;
+	struct qown qown;
 	int ret;
 
 	if (!sb->s_qcop->get_dqblk)
 		return -ENOSYS;
-	ret = sb->s_qcop->get_dqblk(sb, type, id, &fdq);
+	qown = make_qown(current_user_ns(), type, id);
+	if (!qown_valid(qown))
+		return -EINVAL;
+	ret = sb->s_qcop->get_dqblk(sb, qown, &fdq);
 	if (!ret && copy_to_user(addr, &fdq, sizeof(fdq)))
 		return -EFAULT;
 	return ret;
diff --git a/fs/quota/quota_tree.c b/fs/quota/quota_tree.c
index e41c1becf..fa48156 100644
--- a/fs/quota/quota_tree.c
+++ b/fs/quota/quota_tree.c
@@ -22,10 +22,12 @@ MODULE_LICENSE("GPL");
 
 #define __QUOTA_QT_PARANOIA
 
-static int get_index(struct qtree_mem_dqinfo *info, qid_t id, int depth)
+static int get_index(struct qtree_mem_dqinfo *info, struct qown qown, int depth)
 {
 	unsigned int epb = info->dqi_usable_bs >> 2;
+	qid_t id;
 
+	id = from_qown(&init_user_ns, qown);
 	depth = info->dqi_qtree_depth - depth - 1;
 	while (depth--)
 		id /= epb;
@@ -244,7 +246,7 @@ static uint find_free_dqentry(struct qtree_mem_dqinfo *info,
 		/* This is enough as the block is already zeroed and the entry
 		 * list is empty... */
 		info->dqi_free_entry = blk;
-		mark_info_dirty(dquot->dq_sb, dquot->dq_type);
+		mark_info_dirty(dquot->dq_sb, dquot->dq_own.type);
 	}
 	/* Block will be full? */
 	if (le16_to_cpu(dh->dqdh_entries) + 1 >= qtree_dqstr_in_blk(info)) {
@@ -313,7 +315,7 @@ static int do_insert_tree(struct qtree_mem_dqinfo *info, struct dquot *dquot,
 		}
 	}
 	ref = (__le32 *)buf;
-	newblk = le32_to_cpu(ref[get_index(info, dquot->dq_id, depth)]);
+	newblk = le32_to_cpu(ref[get_index(info, dquot->dq_own, depth)]);
 	if (!newblk)
 		newson = 1;
 	if (depth == info->dqi_qtree_depth - 1) {
@@ -322,7 +324,7 @@ static int do_insert_tree(struct qtree_mem_dqinfo *info, struct dquot *dquot,
 			quota_error(dquot->dq_sb, "Inserting already present "
 				    "quota entry (block %u)",
 				    le32_to_cpu(ref[get_index(info,
-						dquot->dq_id, depth)]));
+						dquot->dq_own, depth)]));
 			ret = -EIO;
 			goto out_buf;
 		}
@@ -332,7 +334,7 @@ static int do_insert_tree(struct qtree_mem_dqinfo *info, struct dquot *dquot,
 		ret = do_insert_tree(info, dquot, &newblk, depth+1);
 	}
 	if (newson && ret >= 0) {
-		ref[get_index(info, dquot->dq_id, depth)] =
+		ref[get_index(info, dquot->dq_own, depth)] =
 							cpu_to_le32(newblk);
 		ret = write_blk(info, *treeblk, buf);
 	} else if (newact && ret < 0) {
@@ -357,7 +359,7 @@ static inline int dq_insert_tree(struct qtree_mem_dqinfo *info,
  */
 int qtree_write_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct super_block *sb = dquot->dq_sb;
 	ssize_t ret;
 	char *ddquot = getdqbuf(info->dqi_entry_size);
@@ -472,7 +474,7 @@ static int remove_tree(struct qtree_mem_dqinfo *info, struct dquot *dquot,
 			    *blk);
 		goto out_buf;
 	}
-	newblk = le32_to_cpu(ref[get_index(info, dquot->dq_id, depth)]);
+	newblk = le32_to_cpu(ref[get_index(info, dquot->dq_own, depth)]);
 	if (depth == info->dqi_qtree_depth - 1) {
 		ret = free_dqentry(info, dquot, newblk);
 		newblk = 0;
@@ -481,7 +483,7 @@ static int remove_tree(struct qtree_mem_dqinfo *info, struct dquot *dquot,
 	}
 	if (ret >= 0 && !newblk) {
 		int i;
-		ref[get_index(info, dquot->dq_id, depth)] = cpu_to_le32(0);
+		ref[get_index(info, dquot->dq_own, depth)] = cpu_to_le32(0);
 		/* Block got empty? */
 		for (i = 0; i < (info->dqi_usable_bs >> 2) && !ref[i]; i++)
 			;
@@ -538,8 +540,9 @@ static loff_t find_block_dqentry(struct qtree_mem_dqinfo *info,
 		ddquot += info->dqi_entry_size;
 	}
 	if (i == qtree_dqstr_in_blk(info)) {
-		quota_error(dquot->dq_sb, "Quota for id %u referenced "
-			    "but not present", dquot->dq_id);
+		quota_error(dquot->dq_sb,
+			    "Quota for id %u referenced but not present",
+			    from_qown(&init_user_ns, dquot->dq_own));
 		ret = -EIO;
 		goto out_buf;
 	} else {
@@ -568,7 +571,7 @@ static loff_t find_tree_dqentry(struct qtree_mem_dqinfo *info,
 		goto out_buf;
 	}
 	ret = 0;
-	blk = le32_to_cpu(ref[get_index(info, dquot->dq_id, depth)]);
+	blk = le32_to_cpu(ref[get_index(info, dquot->dq_own, depth)]);
 	if (!blk)	/* No reference? */
 		goto out_buf;
 	if (depth < info->dqi_qtree_depth - 1)
@@ -589,7 +592,7 @@ static inline loff_t find_dqentry(struct qtree_mem_dqinfo *info,
 
 int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct super_block *sb = dquot->dq_sb;
 	loff_t offset;
 	char *ddquot;
@@ -607,8 +610,10 @@ int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 		offset = find_dqentry(info, dquot);
 		if (offset <= 0) {	/* Entry not present? */
 			if (offset < 0)
-				quota_error(sb, "Can't read quota structure "
-					    "for id %u", dquot->dq_id);
+				quota_error(sb,"Can't read quota structure "
+					    "for id %u",
+					    from_qown(&init_user_ns,
+						      dquot->dq_own));
 			dquot->dq_off = 0;
 			set_bit(DQ_FAKE_B, &dquot->dq_flags);
 			memset(&dquot->dq_dqb, 0, sizeof(struct mem_dqblk));
@@ -626,7 +631,7 @@ int qtree_read_dquot(struct qtree_mem_dqinfo *info, struct dquot *dquot)
 		if (ret >= 0)
 			ret = -EIO;
 		quota_error(sb, "Error while reading quota structure for id %u",
-			    dquot->dq_id);
+			    from_qown(&init_user_ns, dquot->dq_own));
 		set_bit(DQ_FAKE_B, &dquot->dq_flags);
 		memset(&dquot->dq_dqb, 0, sizeof(struct mem_dqblk));
 		kfree(ddquot);
diff --git a/fs/quota/quota_v1.c b/fs/quota/quota_v1.c
index 34b37a6..ec37d70 100644
--- a/fs/quota/quota_v1.c
+++ b/fs/quota/quota_v1.c
@@ -54,7 +54,7 @@ static void v1_mem2disk_dqblk(struct v1_disk_dqblk *d, struct mem_dqblk *m)
 
 static int v1_read_dqblk(struct dquot *dquot)
 {
-	int type = dquot->dq_type;
+	int type = dquot->dq_own.type;
 	struct v1_disk_dqblk dqblk;
 
 	if (!sb_dqopt(dquot->dq_sb)->files[type])
@@ -63,7 +63,8 @@ static int v1_read_dqblk(struct dquot *dquot)
 	/* Set structure to 0s in case read fails/is after end of file */
 	memset(&dqblk, 0, sizeof(struct v1_disk_dqblk));
 	dquot->dq_sb->s_op->quota_read(dquot->dq_sb, type, (char *)&dqblk,
-			sizeof(struct v1_disk_dqblk), v1_dqoff(dquot->dq_id));
+			sizeof(struct v1_disk_dqblk),
+			v1_dqoff(from_qown(&init_user_ns, dquot->dq_own)));
 
 	v1_disk2mem_dqblk(&dquot->dq_dqb, &dqblk);
 	if (dquot->dq_dqb.dqb_bhardlimit == 0 &&
@@ -78,12 +79,13 @@ static int v1_read_dqblk(struct dquot *dquot)
 
 static int v1_commit_dqblk(struct dquot *dquot)
 {
-	short type = dquot->dq_type;
+	short type = dquot->dq_own.type;
 	ssize_t ret;
 	struct v1_disk_dqblk dqblk;
 
 	v1_mem2disk_dqblk(&dqblk, &dquot->dq_dqb);
-	if (dquot->dq_id == 0) {
+	if (((type == USRQUOTA) && uid_eq(dquot->dq_own.uid, GLOBAL_ROOT_UID)) ||
+	    ((type == GRPQUOTA) && gid_eq(dquot->dq_own.gid, GLOBAL_ROOT_GID))) {
 		dqblk.dqb_btime =
 			sb_dqopt(dquot->dq_sb)->info[type].dqi_bgrace;
 		dqblk.dqb_itime =
@@ -93,7 +95,7 @@ static int v1_commit_dqblk(struct dquot *dquot)
 	if (sb_dqopt(dquot->dq_sb)->files[type])
 		ret = dquot->dq_sb->s_op->quota_write(dquot->dq_sb, type,
 			(char *)&dqblk, sizeof(struct v1_disk_dqblk),
-			v1_dqoff(dquot->dq_id));
+			v1_dqoff(from_qown(&init_user_ns, dquot->dq_own)));
 	if (ret != sizeof(struct v1_disk_dqblk)) {
 		quota_error(dquot->dq_sb, "dquota write failed");
 		if (ret >= 0)
diff --git a/fs/quota/quota_v2.c b/fs/quota/quota_v2.c
index f1ab360..1c26279 100644
--- a/fs/quota/quota_v2.c
+++ b/fs/quota/quota_v2.c
@@ -196,7 +196,7 @@ static void v2r0_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct v2r0_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
 
 	d->dqb_ihardlimit = cpu_to_le32(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le32(m->dqb_isoftlimit);
@@ -206,7 +206,7 @@ static void v2r0_mem2diskdqb(void *dp, struct dquot *dquot)
 	d->dqb_bsoftlimit = cpu_to_le32(v2_stoqb(m->dqb_bsoftlimit));
 	d->dqb_curspace = cpu_to_le64(m->dqb_curspace);
 	d->dqb_btime = cpu_to_le64(m->dqb_btime);
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_qown(&init_user_ns, dquot->dq_own));
 	if (qtree_entry_unused(info, dp))
 		d->dqb_itime = cpu_to_le64(1);
 }
@@ -215,11 +215,13 @@ static int v2r0_is_id(void *dp, struct dquot *dquot)
 {
 	struct v2r0_disk_dqblk *d = dp;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
+	struct qown qown;
 
 	if (qtree_entry_unused(info, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+	qown = make_qown(&init_user_ns, dquot->dq_own.type, le32_to_cpu(d->dqb_id));
+	return qown_eq(qown, dquot->dq_own);
 }
 
 static void v2r1_disk2memdqb(struct dquot *dquot, void *dp)
@@ -247,7 +249,7 @@ static void v2r1_mem2diskdqb(void *dp, struct dquot *dquot)
 	struct v2r1_disk_dqblk *d = dp;
 	struct mem_dqblk *m = &dquot->dq_dqb;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
 
 	d->dqb_ihardlimit = cpu_to_le64(m->dqb_ihardlimit);
 	d->dqb_isoftlimit = cpu_to_le64(m->dqb_isoftlimit);
@@ -257,7 +259,7 @@ static void v2r1_mem2diskdqb(void *dp, struct dquot *dquot)
 	d->dqb_bsoftlimit = cpu_to_le64(v2_stoqb(m->dqb_bsoftlimit));
 	d->dqb_curspace = cpu_to_le64(m->dqb_curspace);
 	d->dqb_btime = cpu_to_le64(m->dqb_btime);
-	d->dqb_id = cpu_to_le32(dquot->dq_id);
+	d->dqb_id = cpu_to_le32(from_qown(&init_user_ns, dquot->dq_own));
 	if (qtree_entry_unused(info, dp))
 		d->dqb_itime = cpu_to_le64(1);
 }
@@ -266,26 +268,28 @@ static int v2r1_is_id(void *dp, struct dquot *dquot)
 {
 	struct v2r1_disk_dqblk *d = dp;
 	struct qtree_mem_dqinfo *info =
-			sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv;
+			sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv;
+	struct qown qown;
 
 	if (qtree_entry_unused(info, dp))
 		return 0;
-	return le32_to_cpu(d->dqb_id) == dquot->dq_id;
+	qown = make_qown(&init_user_ns, dquot->dq_own.type, le32_to_cpu(d->dqb_id));
+	return qown_eq(qown, dquot->dq_own);
 }
 
 static int v2_read_dquot(struct dquot *dquot)
 {
-	return qtree_read_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_read_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv, dquot);
 }
 
 static int v2_write_dquot(struct dquot *dquot)
 {
-	return qtree_write_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_write_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv, dquot);
 }
 
 static int v2_release_dquot(struct dquot *dquot)
 {
-	return qtree_release_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_type)->dqi_priv, dquot);
+	return qtree_release_dquot(sb_dqinfo(dquot->dq_sb, dquot->dq_own.type)->dqi_priv, dquot);
 }
 
 static int v2_free_file_info(struct super_block *sb, int type)
diff --git a/fs/xfs/xfs_quotaops.c b/fs/xfs/xfs_quotaops.c
index fed504f..589e9c7 100644
--- a/fs/xfs/xfs_quotaops.c
+++ b/fs/xfs/xfs_quotaops.c
@@ -97,28 +97,29 @@ xfs_fs_set_xstate(
 STATIC int
 xfs_fs_get_dqblk(
 	struct super_block	*sb,
-	int			type,
-	qid_t			id,
+	struct qown		qown,
 	struct fs_disk_quota	*fdq)
 {
 	struct xfs_mount	*mp = XFS_M(sb);
+	xfs_dqid_t		xfs_id;
 
 	if (!XFS_IS_QUOTA_RUNNING(mp))
 		return -ENOSYS;
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_getquota(mp, id, xfs_quota_type(type), fdq);
+	xfs_id = from_qown(&init_user_ns, qown);
+	return -xfs_qm_scall_getquota(mp, xfs_id, xfs_quota_type(qown.type), fdq);
 }
 
 STATIC int
 xfs_fs_set_dqblk(
 	struct super_block	*sb,
-	int			type,
-	qid_t			id,
+	struct qown		qown,
 	struct fs_disk_quota	*fdq)
 {
 	struct xfs_mount	*mp = XFS_M(sb);
+	xfs_dqid_t		xfs_id;
 
 	if (sb->s_flags & MS_RDONLY)
 		return -EROFS;
@@ -127,7 +128,8 @@ xfs_fs_set_dqblk(
 	if (!XFS_IS_QUOTA_ON(mp))
 		return -ESRCH;
 
-	return -xfs_qm_scall_setqlim(mp, id, xfs_quota_type(type), fdq);
+	xfs_id = from_qown(&init_user_ns, qown);
+	return -xfs_qm_scall_setqlim(mp, xfs_id, xfs_quota_type(qown.type), fdq);
 }
 
 const struct quotactl_ops xfs_quotactl_operations = {
diff --git a/fs/xfs/xfs_trans_dquot.c b/fs/xfs/xfs_trans_dquot.c
index bcb6054..3e9fbb8 100644
--- a/fs/xfs/xfs_trans_dquot.c
+++ b/fs/xfs/xfs_trans_dquot.c
@@ -575,12 +575,14 @@ xfs_quota_warn(
 	struct xfs_dquot	*dqp,
 	int			type)
 {
+	int qtype;
+	struct qown qown;
 	/* no warnings for project quotas - we just return ENOSPC later */
 	if (dqp->dq_flags & XFS_DQ_PROJ)
 		return;
-	quota_send_warning((dqp->dq_flags & XFS_DQ_USER) ? USRQUOTA : GRPQUOTA,
-			   be32_to_cpu(dqp->q_core.d_id), mp->m_super->s_dev,
-			   type);
+	qtype = (dqp->dq_flags & XFS_DQ_USER) ? USRQUOTA : GRPQUOTA;
+	qown = make_qown(&init_user_ns, qtype, be32_to_cpu(dqp->q_core.d_id));
+	quota_send_warning(qown, mp->m_super->s_dev, type);
 }
 
 /*
diff --git a/include/linux/quota.h b/include/linux/quota.h
index 524ede8..6ebb782 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -181,10 +181,161 @@ enum {
 #include <linux/dqblk_v2.h>
 
 #include <linux/atomic.h>
+#include <linux/uidgid.h>
 
 typedef __kernel_uid32_t qid_t; /* Type in which we store ids in memory */
 typedef long long qsize_t;	/* Type in which we store sizes */
 
+struct qown {			/* Type in which we store the quota owner */
+	union {
+		kuid_t uid;
+		kgid_t gid;
+		unsigned int prj;
+	};
+	int type; /* USRQUOTA (uid) or GRPQUOTA (gid) or XQM_PRJQUOTA (prj) */
+};
+
+static inline bool qown_eq(struct qown left, struct qown right)
+{
+	if (left.type != right.type)
+		return false;
+	switch(left.type) {
+	case USRQUOTA:
+		return uid_eq(left.uid, right.uid);
+	case GRPQUOTA:
+		return gid_eq(left.gid, right.gid);
+	case XQM_PRJQUOTA:
+		return left.prj == right.prj;
+	default:
+		BUG();
+	}
+}
+
+static inline bool qown_lt(struct qown left, struct qown right)
+{
+	if (left.type < right.type)
+		return true;
+	if (left.type > right.type)
+		return false;
+	switch (left.type) {
+	case USRQUOTA:
+		return uid_lt(left.uid, right.uid);
+	case GRPQUOTA:
+		return gid_lt(left.gid, right.gid);
+	case XQM_PRJQUOTA:
+		return left.prj < right.prj;
+	default:
+		BUG();
+	}
+}
+
+static inline u32 from_qown(struct user_namespace *user_ns, struct qown qown)
+{
+	switch (qown.type) {
+	case USRQUOTA:
+		return from_kuid(user_ns, qown.uid);
+	case GRPQUOTA:
+		return from_kgid(user_ns, qown.gid);
+	case XQM_PRJQUOTA:
+		return (user_ns == &init_user_ns) ? qown.prj : -1;
+	default:
+		BUG();
+	}
+}
+
+static inline u32 from_qown_munged(struct user_namespace *user_ns,
+				   struct qown qown)
+{
+	switch (qown.type) {
+	case USRQUOTA:
+		return from_kuid_munged(user_ns, qown.uid);
+	case GRPQUOTA:
+		return from_kgid_munged(user_ns, qown.gid);
+	case XQM_PRJQUOTA:
+		return (user_ns == &init_user_ns) ? qown.prj : -1;
+	default:
+		BUG();
+	}
+}
+
+static inline struct qown make_qown(struct user_namespace *user_ns,
+				    int type, qid_t id)
+{
+	struct qown qown;
+
+	qown.type = type;
+	switch (type) {
+	case USRQUOTA:
+		qown.uid = make_kuid(user_ns, id);
+		break;
+	case GRPQUOTA:
+		qown.gid = make_kgid(user_ns, id);
+		break;
+	case XQM_PRJQUOTA:
+		if (user_ns == &init_user_ns)
+			qown.prj = id;
+		else
+			qown.prj = -1;
+		break;
+	default:
+		BUG();
+	}
+	return qown;
+}
+
+static inline struct qown make_qown_invalid(int type)
+{
+	struct qown qown;
+
+	qown.type = type;
+	switch (type) {
+	case USRQUOTA:
+		qown.uid = INVALID_UID;
+		break;
+	case GRPQUOTA:
+		qown.gid = INVALID_GID;
+		break;
+	case XQM_PRJQUOTA:
+		qown.prj = -1;
+		break;
+	default:
+		BUG();
+	}
+	return qown;
+}
+
+static inline struct qown make_qown_uid(kuid_t uid)
+{
+	struct qown qown = {
+		.type = USRQUOTA,
+		.uid  = uid,
+	};
+	return qown;
+}
+
+static inline struct qown make_qown_gid(kgid_t gid)
+{
+	struct qown qown = {
+		.type = GRPQUOTA,
+		.gid  = gid,
+	};
+	return qown;
+}
+
+static inline bool qown_valid(struct qown qown)
+{
+	switch (qown.type) {
+	case USRQUOTA:
+		return uid_valid(qown.uid);
+	case GRPQUOTA:
+		return gid_valid(qown.gid);
+	case XQM_PRJQUOTA:
+		return qown.prj != (unsigned int)-1;
+	default:
+		BUG();
+	}
+}
+
 extern spinlock_t dq_data_lock;
 
 /* Maximal numbers of writes for quota operation (insert/delete/update)
@@ -294,10 +445,9 @@ struct dquot {
 	atomic_t dq_count;		/* Use count */
 	wait_queue_head_t dq_wait_unused;	/* Wait queue for dquot to become unused */
 	struct super_block *dq_sb;	/* superblock this applies to */
-	unsigned int dq_id;		/* ID this applies to (uid, gid) */
+	struct qown dq_own;		/* ID this applies to (uid, gid) */
 	loff_t dq_off;			/* Offset of dquot on disk */
 	unsigned long dq_flags;		/* See DQ_* */
-	short dq_type;			/* Type of quota */
 	struct mem_dqblk dq_dqb;	/* Diskquota usage */
 };
 
@@ -336,8 +486,8 @@ struct quotactl_ops {
 	int (*quota_sync)(struct super_block *, int);
 	int (*get_info)(struct super_block *, int, struct if_dqinfo *);
 	int (*set_info)(struct super_block *, int, struct if_dqinfo *);
-	int (*get_dqblk)(struct super_block *, int, qid_t, struct fs_disk_quota *);
-	int (*set_dqblk)(struct super_block *, int, qid_t, struct fs_disk_quota *);
+	int (*get_dqblk)(struct super_block *, struct qown, struct fs_disk_quota *);
+	int (*set_dqblk)(struct super_block *, struct qown, struct fs_disk_quota *);
 	int (*get_xstate)(struct super_block *, struct fs_quota_stat *);
 	int (*set_xstate)(struct super_block *, unsigned int, int);
 };
@@ -386,10 +536,10 @@ static inline unsigned int dquot_generic_flag(unsigned int flags, int type)
 }
 
 #ifdef CONFIG_QUOTA_NETLINK_INTERFACE
-extern void quota_send_warning(short type, unsigned int id, dev_t dev,
+extern void quota_send_warning(struct qown qown, dev_t dev,
 			       const char warntype);
 #else
-static inline void quota_send_warning(short type, unsigned int id, dev_t dev,
+static inline void quota_send_warning(struct qown qown, dev_t dev,
 				      const char warntype)
 {
 	return;
diff --git a/include/linux/quotaops.h b/include/linux/quotaops.h
index ec6b65f..ed9a5e4 100644
--- a/include/linux/quotaops.h
+++ b/include/linux/quotaops.h
@@ -44,7 +44,7 @@ void inode_sub_rsv_space(struct inode *inode, qsize_t number);
 
 void dquot_initialize(struct inode *inode);
 void dquot_drop(struct inode *inode);
-struct dquot *dqget(struct super_block *sb, unsigned int id, int type);
+struct dquot *dqget(struct super_block *sb, struct qown qown);
 void dqput(struct dquot *dquot);
 int dquot_scan_active(struct super_block *sb,
 		      int (*fn)(struct dquot *dquot, unsigned long priv),
@@ -87,9 +87,9 @@ int dquot_writeback_dquots(struct super_block *sb, int type);
 int dquot_quota_sync(struct super_block *sb, int type);
 int dquot_get_dqinfo(struct super_block *sb, int type, struct if_dqinfo *ii);
 int dquot_set_dqinfo(struct super_block *sb, int type, struct if_dqinfo *ii);
-int dquot_get_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_get_dqblk(struct super_block *sb, struct qown id,
 		struct fs_disk_quota *di);
-int dquot_set_dqblk(struct super_block *sb, int type, qid_t id,
+int dquot_set_dqblk(struct super_block *sb, struct qown id,
 		struct fs_disk_quota *di);
 
 int __dquot_transfer(struct inode *inode, struct dquot **transfer_to);
diff --git a/init/Kconfig b/init/Kconfig
index 2a388e5..a0bccce 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -928,8 +928,6 @@ config UIDGID_CONVERTED
 	depends on IMA = n
 	depends on EVM = n
 	depends on FS_POSIX_ACL = n
-	depends on QUOTA = n
-	depends on QUOTACTL = n
 
 	# Networking
 	depends on NET_9P = n
-- 
1.7.5.4
