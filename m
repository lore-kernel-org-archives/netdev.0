From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/8] percpu: add __percpu sparse annotations to fs
Date: Tue, 26 Jan 2010 00:22:09 +0900
Message-ID: <1264432935-10453-3-git-send-email-tj@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42939 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848Ab0AYPTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:02 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to fs.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Alex Elder <aelder@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/ext4/ext4.h            |    2 +-
 fs/nfs/iostat.h           |    4 ++--
 fs/xfs/xfs_mount.h        |    2 +-
 include/linux/mount.h     |    2 +-
 include/linux/nfs_fs_sb.h |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index af7b626..eeb1e36 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1017,7 +1017,7 @@ struct ext4_sb_info {
 	atomic_t s_lock_busy;
 
 	/* locality groups */
-	struct ext4_locality_group *s_locality_groups;
+	struct ext4_locality_group __percpu *s_locality_groups;
 
 	/* for write statistics */
 	unsigned long s_sectors_written_start;
diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index 46d779a..1d8d5c8 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -57,12 +57,12 @@ static inline void nfs_add_fscache_stats(struct inode *inode,
 }
 #endif
 
-static inline struct nfs_iostats *nfs_alloc_iostats(void)
+static inline struct nfs_iostats __percpu *nfs_alloc_iostats(void)
 {
 	return alloc_percpu(struct nfs_iostats);
 }
 
-static inline void nfs_free_iostats(struct nfs_iostats *stats)
+static inline void nfs_free_iostats(struct nfs_iostats __percpu *stats)
 {
 	if (stats != NULL)
 		free_percpu(stats);
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 1df7e45..24c8887 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -243,7 +243,7 @@ typedef struct xfs_mount {
 	struct xfs_qmops	*m_qm_ops;	/* vector of XQM ops */
 	atomic_t		m_active_trans;	/* number trans frozen */
 #ifdef HAVE_PERCPU_SB
-	xfs_icsb_cnts_t		*m_sb_cnts;	/* per-cpu superblock counters */
+	xfs_icsb_cnts_t __percpu *m_sb_cnts;	/* per-cpu superblock counters */
 	unsigned long		m_icsb_counters; /* disabled per-cpu counters */
 	struct notifier_block	m_icsb_notifier; /* hotplug cpu notifier */
 	struct mutex		m_icsb_mutex;	/* balancer sync lock */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 5d52753..b5f43a3 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -66,7 +66,7 @@ struct vfsmount {
 	int mnt_pinned;
 	int mnt_ghosts;
 #ifdef CONFIG_SMP
-	int *mnt_writers;
+	int __percpu *mnt_writers;
 #else
 	int mnt_writers;
 #endif
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34fc6be..6a2e44f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -105,7 +105,7 @@ struct nfs_server {
 	struct rpc_clnt *	client;		/* RPC client handle */
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
 	struct nlm_host		*nlm_host;	/* NLM client handle */
-	struct nfs_iostats *	io_stats;	/* I/O statistics */
+	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
 	int			flags;		/* various flags */
-- 
1.6.4.2

