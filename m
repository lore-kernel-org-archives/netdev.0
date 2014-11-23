From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 4/6] fs/fuse: support compiling out splice
Date: Sun, 23 Nov 2014 15:20:48 +0100
Message-ID: <1416752468-1626-5-git-send-email-pieter@boesman.nl>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh@joshtriplett.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bertrand Jacquin <beber@meleeweb.net>,
	Catalina Mocanu <catalina.mocanu@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Fabian Frederick <fabf@skynet.be>,
	fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Hugh Dickins <hughd@google.com>,
	Iulia Manda <iulia.manda21@gmail.com>,
	Jan Beulich <JBeulich@suse.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jeff Layton <jlayton@poochiereds.net>,
	linux-api@vger.kernel.org (open list:ABI/API),
	linux-fsdevel@vger.kernel.org,
	linux-kernel
To: pieter@boesman.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To implement splice support, fs/fuse makes use of nosteal_pipe_buf_ops. This
struct is exported by fs/splice. The goal of the larger patch set is to
completely compile out fs/splice, so uses of the exported struct need to be
compiled out along with fs/splice.

This patch therefore compiles out splice support in fs/fuse when
CONFIG_SYSCALL_SPLICE is undefined.

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/fuse/dev.c      | 4 ++--
 include/linux/fs.h | 6 ++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ca88731..f8f92a4 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1291,7 +1291,7 @@ static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
 	return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
 }
 
-static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
+static ssize_t __maybe_unused fuse_dev_splice_read(struct file *in, loff_t *ppos,
 				    struct pipe_inode_info *pipe,
 				    size_t len, unsigned int flags)
 {
@@ -2144,7 +2144,7 @@ const struct file_operations fuse_dev_operations = {
 	.llseek		= no_llseek,
 	.read		= do_sync_read,
 	.aio_read	= fuse_dev_read,
-	.splice_read	= fuse_dev_splice_read,
+	.splice_read	= __splice_p(fuse_dev_splice_read),
 	.write		= do_sync_write,
 	.aio_write	= fuse_dev_write,
 	.splice_write	= fuse_dev_splice_write,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a957d43..04c0975 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2443,6 +2443,12 @@ extern int blkdev_fsync(struct file *filp, loff_t start, loff_t end,
 			int datasync);
 extern void block_sync_page(struct page *page);
 
+#ifdef CONFIG_SYSCALL_SPLICE
+#define __splice_p(x) x
+#else
+#define __splice_p(x) NULL
+#endif
+
 /* fs/splice.c */
 extern ssize_t generic_file_splice_read(struct file *, loff_t *,
 		struct pipe_inode_info *, size_t, unsigned int);
-- 
2.1.0
