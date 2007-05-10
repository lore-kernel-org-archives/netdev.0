From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AFS: Implement statfs
Date: Thu, 10 May 2007 19:02:59 +0100
Message-ID: <20070510180259.3349.93317.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the statfs() op for AFS.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/afs.h      |   23 ++++
 fs/afs/afs_fs.h   |    3 -
 fs/afs/dir.c      |   18 ++-
 fs/afs/fsclient.c |  298 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/afs/internal.h |    6 +
 fs/afs/super.c    |   41 ++++++-
 fs/afs/vnode.c    |   52 +++++++++
 7 files changed, 426 insertions(+), 15 deletions(-)

diff --git a/fs/afs/afs.h b/fs/afs/afs.h
index 52d0752..2452579 100644
--- a/fs/afs/afs.h
+++ b/fs/afs/afs.h
@@ -16,6 +16,9 @@
 
 #define AFS_MAXCELLNAME	64		/* maximum length of a cell name */
 #define AFS_MAXVOLNAME	64		/* maximum length of a volume name */
+#define AFSNAMEMAX	256		/* maximum length of a filename plus NUL */
+#define AFSPATHMAX	1024		/* maximum length of a pathname plus NUL */
+#define AFSOPAQUEMAX	1024		/* maximum length of an opaque field */
 
 typedef unsigned			afs_volid_t;
 typedef unsigned			afs_vnodeid_t;
@@ -143,4 +146,24 @@ struct afs_volsync {
 	time_t			creation;	/* volume creation time */
 };
 
+/*
+ * AFS volume status record
+ */
+struct afs_volume_status {
+	u32			vid;		/* volume ID */
+	u32			parent_id;	/* parent volume ID */
+	u8			online;		/* true if volume currently online and available */
+	u8			in_service;	/* true if volume currently in service */
+	u8			blessed;	/* same as in_service */
+	u8			needs_salvage;	/* true if consistency checking required */
+	u32			type;		/* volume type (afs_voltype_t) */
+	u32			min_quota;	/* minimum space set aside (blocks) */
+	u32			max_quota;	/* maximum space this volume may occupy (blocks) */
+	u32			blocks_in_use;	/* space this volume currently occupies (blocks) */
+	u32			part_blocks_avail; /* space available in volume's partition */
+	u32			part_max_blocks; /* size of volume's partition */
+};
+
+#define AFS_BLOCK_SIZE	1024
+
 #endif /* AFS_H */
diff --git a/fs/afs/afs_fs.h b/fs/afs/afs_fs.h
index d963ef4..a18c374 100644
--- a/fs/afs/afs_fs.h
+++ b/fs/afs/afs_fs.h
@@ -28,7 +28,8 @@ enum AFS_FS_Operations {
 	FSMAKEDIR		= 141,	/* AFS Create a directory */
 	FSREMOVEDIR		= 142,	/* AFS Remove a directory */
 	FSGIVEUPCALLBACKS	= 147,	/* AFS Discard callback promises */
-	FSGETVOLUMEINFO		= 148,	/* AFS Get root volume information */
+	FSGETVOLUMEINFO		= 148,	/* AFS Get information about a volume */
+	FSGETVOLUMESTATUS	= 149,	/* AFS Get volume status information */
 	FSGETROOTVOLUME		= 151,	/* AFS Get root volume name */
 	FSLOOKUP		= 161,	/* AFS lookup file in directory */
 	FSFETCHDATA64		= 65537, /* AFS Fetch file data */
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index ac982a8..92b2f1e 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -497,7 +497,7 @@ static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
 
 	ASSERTCMP(dentry->d_inode, ==, NULL);
 
-	if (dentry->d_name.len > 255) {
+	if (dentry->d_name.len >= AFSNAMEMAX) {
 		_leave(" = -ENAMETOOLONG");
 		return ERR_PTR(-ENAMETOOLONG);
 	}
@@ -736,7 +736,7 @@ static int afs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key(dvnode->volume->cell);
@@ -801,7 +801,7 @@ static int afs_rmdir(struct inode *dir, struct dentry *dentry)
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key(dvnode->volume->cell);
@@ -847,7 +847,7 @@ static int afs_unlink(struct inode *dir, struct dentry *dentry)
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key(dvnode->volume->cell);
@@ -921,7 +921,7 @@ static int afs_create(struct inode *dir, struct dentry *dentry, int mode,
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key_nd(dvnode->volume->cell, nd);
@@ -990,7 +990,7 @@ static int afs_link(struct dentry *from, struct inode *dir,
 	       dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key(dvnode->volume->cell);
@@ -1038,11 +1038,11 @@ static int afs_symlink(struct inode *dir, struct dentry *dentry,
 	       content);
 
 	ret = -ENAMETOOLONG;
-	if (dentry->d_name.len > 255)
+	if (dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	ret = -EINVAL;
-	if (strlen(content) > 1023)
+	if (strlen(content) >= AFSPATHMAX)
 		goto error;
 
 	key = afs_request_key(dvnode->volume->cell);
@@ -1112,7 +1112,7 @@ static int afs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	       new_dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
-	if (new_dentry->d_name.len > 255)
+	if (new_dentry->d_name.len >= AFSNAMEMAX)
 		goto error;
 
 	key = afs_request_key(orig_dvnode->volume->cell);
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index aca487c..197449d 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -202,6 +202,29 @@ static void xdr_encode_AFS_StoreStatus(__be32 **_bp, struct iattr *attr)
 }
 
 /*
+ * decode an AFSFetchVolumeStatus block
+ */
+static void xdr_decode_AFSFetchVolumeStatus(const __be32 **_bp,
+					    struct afs_volume_status *vs)
+{
+	const __be32 *bp = *_bp;
+
+	vs->vid			= ntohl(*bp++);
+	vs->parent_id		= ntohl(*bp++);
+	vs->online		= ntohl(*bp++);
+	vs->in_service		= ntohl(*bp++);
+	vs->blessed		= ntohl(*bp++);
+	vs->needs_salvage	= ntohl(*bp++);
+	vs->type		= ntohl(*bp++);
+	vs->min_quota		= ntohl(*bp++);
+	vs->max_quota		= ntohl(*bp++);
+	vs->blocks_in_use	= ntohl(*bp++);
+	vs->part_blocks_avail	= ntohl(*bp++);
+	vs->part_max_blocks	= ntohl(*bp++);
+	*_bp = bp;
+}
+
+/*
  * deliver reply data to an FS.FetchStatus
  */
 static int afs_deliver_fs_fetch_status(struct afs_call *call,
@@ -1450,3 +1473,278 @@ int afs_fs_setattr(struct afs_server *server, struct key *key,
 
 	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
+
+/*
+ * deliver reply data to an FS.GetVolumeStatus
+ */
+static int afs_deliver_fs_get_volume_status(struct afs_call *call,
+					    struct sk_buff *skb, bool last)
+{
+	const __be32 *bp;
+	char *p;
+	int ret;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	switch (call->unmarshall) {
+	case 0:
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the returned status record */
+	case 1:
+		_debug("extract status");
+		ret = afs_extract_data(call, skb, last, call->buffer,
+				       12 * 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		bp = call->buffer;
+		xdr_decode_AFSFetchVolumeStatus(&bp, call->reply2);
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the volume name length */
+	case 2:
+		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->count = ntohl(call->tmp);
+		_debug("volname length: %u", call->count);
+		if (call->count >= AFSNAMEMAX)
+			return -EBADMSG;
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the volume name */
+	case 3:
+		_debug("extract volname");
+		if (call->count > 0) {
+			ret = afs_extract_data(call, skb, last, call->reply3,
+					       call->count);
+			switch (ret) {
+			case 0:		break;
+			case -EAGAIN:	return 0;
+			default:	return ret;
+			}
+		}
+
+		p = call->reply3;
+		p[call->count] = 0;
+		_debug("volname '%s'", p);
+
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the volume name padding */
+		if ((call->count & 3) == 0) {
+			call->unmarshall++;
+			goto no_volname_padding;
+		}
+		call->count = 4 - (call->count & 3);
+
+	case 4:
+		ret = afs_extract_data(call, skb, last, call->buffer,
+				       call->count);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->offset = 0;
+		call->unmarshall++;
+	no_volname_padding:
+
+		/* extract the offline message length */
+	case 5:
+		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->count = ntohl(call->tmp);
+		_debug("offline msg length: %u", call->count);
+		if (call->count >= AFSNAMEMAX)
+			return -EBADMSG;
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the offline message */
+	case 6:
+		_debug("extract offline");
+		if (call->count > 0) {
+			ret = afs_extract_data(call, skb, last, call->reply3,
+					       call->count);
+			switch (ret) {
+			case 0:		break;
+			case -EAGAIN:	return 0;
+			default:	return ret;
+			}
+		}
+
+		p = call->reply3;
+		p[call->count] = 0;
+		_debug("offline '%s'", p);
+
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the offline message padding */
+		if ((call->count & 3) == 0) {
+			call->unmarshall++;
+			goto no_offline_padding;
+		}
+		call->count = 4 - (call->count & 3);
+
+	case 7:
+		ret = afs_extract_data(call, skb, last, call->buffer,
+				       call->count);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->offset = 0;
+		call->unmarshall++;
+	no_offline_padding:
+
+		/* extract the message of the day length */
+	case 8:
+		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->count = ntohl(call->tmp);
+		_debug("motd length: %u", call->count);
+		if (call->count >= AFSNAMEMAX)
+			return -EBADMSG;
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the message of the day */
+	case 9:
+		_debug("extract motd");
+		if (call->count > 0) {
+			ret = afs_extract_data(call, skb, last, call->reply3,
+					       call->count);
+			switch (ret) {
+			case 0:		break;
+			case -EAGAIN:	return 0;
+			default:	return ret;
+			}
+		}
+
+		p = call->reply3;
+		p[call->count] = 0;
+		_debug("motd '%s'", p);
+
+		call->offset = 0;
+		call->unmarshall++;
+
+		/* extract the message of the day padding */
+		if ((call->count & 3) == 0) {
+			call->unmarshall++;
+			goto no_motd_padding;
+		}
+		call->count = 4 - (call->count & 3);
+
+	case 10:
+		ret = afs_extract_data(call, skb, last, call->buffer,
+				       call->count);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->offset = 0;
+		call->unmarshall++;
+	no_motd_padding:
+
+	case 11:
+		_debug("trailer %d", skb->len);
+		if (skb->len != 0)
+			return -EBADMSG;
+		break;
+	}
+
+	if (!last)
+		return 0;
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * destroy an FS.GetVolumeStatus call
+ */
+static void afs_get_volume_status_call_destructor(struct afs_call *call)
+{
+	kfree(call->reply3);
+	call->reply3 = NULL;
+	afs_flat_call_destructor(call);
+}
+
+/*
+ * FS.GetVolumeStatus operation type
+ */
+static const struct afs_call_type afs_RXFSGetVolumeStatus = {
+	.name		= "FS.GetVolumeStatus",
+	.deliver	= afs_deliver_fs_get_volume_status,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_get_volume_status_call_destructor,
+};
+
+/*
+ * fetch the status of a volume
+ */
+int afs_fs_get_volume_status(struct afs_server *server,
+			     struct key *key,
+			     struct afs_vnode *vnode,
+			     struct afs_volume_status *vs,
+			     const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	__be32 *bp;
+	void *tmpbuf;
+
+	_enter("");
+
+	tmpbuf = kmalloc(AFSOPAQUEMAX, GFP_KERNEL);
+	if (!tmpbuf)
+		return -ENOMEM;
+
+	call = afs_alloc_flat_call(&afs_RXFSGetVolumeStatus, 2 * 4, 12 * 4);
+	if (!call) {
+		kfree(tmpbuf);
+		return -ENOMEM;
+	}
+
+	call->key = key;
+	call->reply = vnode;
+	call->reply2 = vs;
+	call->reply3 = tmpbuf;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	bp[0] = htonl(FSGETVOLUMESTATUS);
+	bp[1] = htonl(vnode->fid.vid);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 5545f90..61038da 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -506,6 +506,10 @@ extern int afs_fs_store_data(struct afs_server *, struct afs_writeback *,
 extern int afs_fs_setattr(struct afs_server *, struct key *,
 			  struct afs_vnode *, struct iattr *,
 			  const struct afs_wait_mode *);
+extern int afs_fs_get_volume_status(struct afs_server *, struct key *,
+				    struct afs_vnode *,
+				    struct afs_volume_status *,
+				    const struct afs_wait_mode *);
 
 /*
  * inode.c
@@ -673,6 +677,8 @@ extern int afs_vnode_rename(struct afs_vnode *, struct afs_vnode *,
 extern int afs_vnode_store_data(struct afs_writeback *, pgoff_t, pgoff_t,
 				unsigned, unsigned);
 extern int afs_vnode_setattr(struct afs_vnode *, struct key *, struct iattr *);
+extern int afs_vnode_get_volume_status(struct afs_vnode *, struct key *,
+				       struct afs_volume_status *);
 
 /*
  * volume.c
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 422f532..579af63 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -21,22 +21,20 @@
 #include <linux/fs.h>
 #include <linux/pagemap.h>
 #include <linux/parser.h>
+#include <linux/statfs.h>
 #include "internal.h"
 
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
 
 static void afs_i_init_once(void *foo, struct kmem_cache *cachep,
 			    unsigned long flags);
-
 static int afs_get_sb(struct file_system_type *fs_type,
 		      int flags, const char *dev_name,
 		      void *data, struct vfsmount *mnt);
-
 static struct inode *afs_alloc_inode(struct super_block *sb);
-
 static void afs_put_super(struct super_block *sb);
-
 static void afs_destroy_inode(struct inode *inode);
+static int afs_statfs(struct dentry *dentry, struct kstatfs *buf);
 
 struct file_system_type afs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -47,7 +45,7 @@ struct file_system_type afs_fs_type = {
 };
 
 static const struct super_operations afs_super_ops = {
-	.statfs		= simple_statfs,
+	.statfs		= afs_statfs,
 	.alloc_inode	= afs_alloc_inode,
 	.drop_inode	= generic_delete_inode,
 	.write_inode	= afs_write_inode,
@@ -508,3 +506,36 @@ static void afs_destroy_inode(struct inode *inode)
 	kmem_cache_free(afs_inode_cachep, vnode);
 	atomic_dec(&afs_count_active_inodes);
 }
+
+/*
+ * return information about an AFS volume
+ */
+static int afs_statfs(struct dentry *dentry, struct kstatfs *buf)
+{
+	struct afs_volume_status vs;
+	struct afs_vnode *vnode = AFS_FS_I(dentry->d_inode);
+	struct key *key;
+	int ret;
+
+	key = afs_request_key(vnode->volume->cell);
+	if (IS_ERR(key))
+		return PTR_ERR(key);
+
+	ret = afs_vnode_get_volume_status(vnode, key, &vs);
+	key_put(key);
+	if (ret < 0) {
+		_leave(" = %d", ret);
+		return ret;
+	}
+
+	buf->f_type	= dentry->d_sb->s_magic;
+	buf->f_bsize	= AFS_BLOCK_SIZE;
+	buf->f_namelen	= AFSNAMEMAX - 1;
+
+	if (vs.max_quota == 0)
+		buf->f_blocks = vs.part_max_blocks;
+	else
+		buf->f_blocks = vs.max_quota;
+	buf->f_bavail = buf->f_bfree = buf->f_blocks - vs.blocks_in_use;
+	return 0;
+}
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index bea8bd9..c36c98c 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -869,3 +869,55 @@ no_server:
 	spin_unlock(&vnode->lock);
 	return PTR_ERR(server);
 }
+
+/*
+ * get the status of a volume
+ */
+int afs_vnode_get_volume_status(struct afs_vnode *vnode, struct key *key,
+				struct afs_volume_status *vs)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%x:%u.%u},%x,",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key));
+
+	/* this op will fetch the status */
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_get_volume_status(server, key, vnode, vs, &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		afs_put_server(server);
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	return PTR_ERR(server);
+}

