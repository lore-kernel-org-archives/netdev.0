From: Ashwini Kulkarni <ashwini.kulkarni@intel.com>
Subject: [RFC 6/6] Move i_size_read part from do_splice_to() to __generic_file_splice_read() in splice.c
Date: Wed, 20 Sep 2006 14:08:22 -0700
Message-ID: <20060920210822.17480.18566.stgit@gitlost.site>
References: <20060920210711.17480.92354.stgit@gitlost.site>
Cc: christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:61965 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751066AbWITU7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 16:59:25 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20060920210711.17480.92354.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


---

 fs/splice.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 3a4202d..2f8f42a 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -271,7 +271,7 @@ __generic_file_splice_read(struct file *
 	struct partial_page partial[PIPE_BUFFERS];
 	struct page *page;
 	pgoff_t index, end_index;
-	loff_t isize;
+	loff_t isize, left;
 	size_t total_len;
 	int error, page_nr;
 	struct splice_pipe_desc spd = {
@@ -421,6 +421,13 @@ __generic_file_splice_read(struct file *
 			 * i_size must be checked after ->readpage().
 			 */
 			isize = i_size_read(mapping->host);
+			if (unlikely(*ppos >= isize))
+				return 0;
+
+			left = isize - *ppos;
+			if (unlikely(left < len))
+			len = left;
+
 			end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
 			if (unlikely(!isize || index > end_index))
 				break;
@@ -903,7 +910,6 @@ static long do_splice_to(struct file *in
 			 struct pipe_inode_info *pipe, size_t len,
 			 unsigned int flags)
 {
-	loff_t isize, left;
 	int ret;
 
 	if (unlikely(!in->f_op || !in->f_op->splice_read))
@@ -916,14 +922,6 @@ static long do_splice_to(struct file *in
 	if (unlikely(ret < 0))
 		return ret;
 
-	isize = i_size_read(in->f_mapping->host);
-	if (unlikely(*ppos >= isize))
-		return 0;
-	
-	left = isize - *ppos;
-	if (unlikely(left < len))
-		len = left;
-
 	return in->f_op->splice_read(in, ppos, pipe, len, flags);
 }
 

