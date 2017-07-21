From: Yanhu Cao <gmayyyha@gmail.com>
Subject: [PATCH] ceph: kernel client startsync can be removed
Date: Fri, 21 Jul 2017 17:20:10 +0800
Message-ID: <20170721092010.10918-1-gmayyyha@gmail.com>
Cc: zyan@redhat.com, sage@redhat.com, ceph-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, gmayyyha@gmail.com
To: idryomov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34153 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753245AbdGUJUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 05:20:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel client is still sending write,startsync.
that startsync is a no-op (has been for years) and can probably be removed

Link: http://tracker.ceph.com/issues/20604

Signed-off-by: Yanhu Cao <gmayyyha@gmail.com>
---
 fs/ceph/addr.c             | 9 ++-------
 fs/ceph/file.c             | 5 +----
 include/linux/ceph/rados.h | 1 -
 net/ceph/osd_client.c      | 5 -----
 4 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 5083628..f9a1805 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -939,7 +939,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 					break;
 				}
 
-				num_ops = 1 + do_sync;
+				num_ops = 1;
 				strip_unit_end = page->index +
 					((len - 1) >> PAGE_SHIFT);
 
@@ -1045,7 +1045,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 		for (i = 0; i < locked_pages; i++) {
 			u64 cur_offset = page_offset(pages[i]);
 			if (offset + len != cur_offset) {
-				if (op_idx + do_sync + 1 == req->r_num_ops)
+				if (op_idx + 1 == req->r_num_ops)
 					break;
 				osd_req_op_extent_dup_last(req, op_idx,
 							   cur_offset - offset);
@@ -1082,17 +1082,12 @@ static int ceph_writepages_start(struct address_space *mapping,
 						 0, !!pool, false);
 		osd_req_op_extent_update(req, op_idx, len);
 
-		if (do_sync) {
-			op_idx++;
-			osd_req_op_init(req, op_idx, CEPH_OSD_OP_STARTSYNC, 0);
-		}
 		BUG_ON(op_idx + 1 != req->r_num_ops);
 
 		pool = NULL;
 		if (i < locked_pages) {
 			BUG_ON(num_ops <= req->r_num_ops);
 			num_ops -= req->r_num_ops;
-			num_ops += do_sync;
 			locked_pages -= i;
 
 			/* allocate new pages array for next request */
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 3d48c41..405c99b 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -800,7 +800,6 @@ static void ceph_aio_retry_work(struct work_struct *work)
 	}
 
 	req->r_ops[0] = orig_req->r_ops[0];
-	osd_req_op_init(req, 1, CEPH_OSD_OP_STARTSYNC, 0);
 
 	req->r_mtime = aio_req->mtime;
 	req->r_data_offset = req->r_ops[0].extent.offset;
@@ -874,8 +873,7 @@ static void ceph_aio_retry_work(struct work_struct *work)
 		vino = ceph_vino(inode);
 		req = ceph_osdc_new_request(&fsc->client->osdc, &ci->i_layout,
 					    vino, pos, &size, 0,
-					    /*include a 'startsync' command*/
-					    write ? 2 : 1,
+					    1,
 					    write ? CEPH_OSD_OP_WRITE :
 						    CEPH_OSD_OP_READ,
 					    flags, snapc,
@@ -922,7 +920,6 @@ static void ceph_aio_retry_work(struct work_struct *work)
 			truncate_inode_pages_range(inode->i_mapping, pos,
 					(pos+len) | (PAGE_SIZE - 1));
 
-			osd_req_op_init(req, 1, CEPH_OSD_OP_STARTSYNC, 0);
 			req->r_mtime = mtime;
 		}
 
diff --git a/include/linux/ceph/rados.h b/include/linux/ceph/rados.h
index 385db08..ba5adf0 100644
--- a/include/linux/ceph/rados.h
+++ b/include/linux/ceph/rados.h
@@ -226,7 +226,6 @@ struct ceph_eversion {
 									    \
 	/* fancy write */						    \
 	f(APPEND,	__CEPH_OSD_OP(WR, DATA, 6),	"append")	    \
-	f(STARTSYNC,	__CEPH_OSD_OP(WR, DATA, 7),	"startsync")	    \
 	f(SETTRUNC,	__CEPH_OSD_OP(WR, DATA, 8),	"settrunc")	    \
 	f(TRIMTRUNC,	__CEPH_OSD_OP(WR, DATA, 9),	"trimtrunc")	    \
 									    \
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 901bb82..5c9d696 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -863,8 +863,6 @@ static u32 osd_req_encode_op(struct ceph_osd_op *dst,
 		dst->cls.method_len = src->cls.method_len;
 		dst->cls.indata_len = cpu_to_le32(src->cls.indata_len);
 		break;
-	case CEPH_OSD_OP_STARTSYNC:
-		break;
 	case CEPH_OSD_OP_WATCH:
 		dst->watch.cookie = cpu_to_le64(src->watch.cookie);
 		dst->watch.ver = cpu_to_le64(0);
@@ -916,9 +914,6 @@ static u32 osd_req_encode_op(struct ceph_osd_op *dst,
  * if the file was recently truncated, we include information about its
  * old and new size so that the object can be updated appropriately.  (we
  * avoid synchronously deleting truncated objects because it's slow.)
- *
- * if @do_sync, include a 'startsync' command so that the osd will flush
- * data quickly.
  */
 struct ceph_osd_request *ceph_osdc_new_request(struct ceph_osd_client *osdc,
 					       struct ceph_file_layout *layout,
-- 
1.8.3.1
