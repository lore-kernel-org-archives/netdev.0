From: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH 1/3] splice: don't assume regular pages in splice_to_pipe()
Date: Tue, 12 Jun 2007 09:03:58 +0200
Message-ID: <11816318402355-git-send-email-jens.axboe@oracle.com>
References: <1181631840469-git-send-email-jens.axboe@oracle.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:17202 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759461AbXFLHGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 03:06:16 -0400
In-Reply-To: <1181631840469-git-send-email-jens.axboe@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow caller to pass in a release function, there might be
other resources that need releasing as well. Needed for
network receive.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 fs/splice.c            |    9 ++++++++-
 include/linux/splice.h |    1 +
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index f24e367..25ec9c8 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -247,11 +247,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 	}
 
 	while (page_nr < spd->nr_pages)
-		page_cache_release(spd->pages[page_nr++]);
+		spd->spd_release(spd, page_nr++);
 
 	return ret;
 }
 
+static void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
+{
+	page_cache_release(spd->pages[i]);
+}
+
 static int
 __generic_file_splice_read(struct file *in, loff_t *ppos,
 			   struct pipe_inode_info *pipe, size_t len,
@@ -270,6 +275,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		.partial = partial,
 		.flags = flags,
 		.ops = &page_cache_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
@@ -1442,6 +1448,7 @@ static long vmsplice_to_pipe(struct file *file, const struct iovec __user *iov,
 		.partial = partial,
 		.flags = flags,
 		.ops = &user_page_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	pipe = pipe_info(file->f_path.dentry->d_inode);
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 1a1182b..04c1068 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -53,6 +53,7 @@ struct splice_pipe_desc {
 	int nr_pages;			/* number of pages in map */
 	unsigned int flags;		/* splice flags */
 	const struct pipe_buf_operations *ops;/* ops associated with output pipe */
+	void (*spd_release)(struct splice_pipe_desc *, unsigned int);
 };
 
 typedef int (splice_actor)(struct pipe_inode_info *, struct pipe_buffer *,
-- 
1.5.2.1.174.gcd03

