From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH v4 2/7] fs: moved kernel_write to fs/read_write
Date: Tue, 25 Nov 2014 00:01:01 +0100
Message-ID: <1416870079-15254-3-git-send-email-pieter@boesman.nl>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
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
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kernel_write shares infrastructure with the read_write translation unit but not
with the splice translation unit. Grouping kernel_write with the read_write
translation unit is more logical. It also paves the way to compiling out the
splice group of syscalls for embedded systems that do not need them.

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/read_write.c | 16 ++++++++++++++++
 fs/splice.c     | 16 ----------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index d9451ba..f4c8d8b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1191,3 +1191,19 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,
 }
 #endif
 
+ssize_t kernel_write(struct file *file, const char *buf, size_t count,
+			    loff_t pos)
+{
+	mm_segment_t old_fs;
+	ssize_t res;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	/* The cast to a user pointer is valid due to the set_fs() */
+	res = vfs_write(file, (__force const char __user *)buf, count, &pos);
+	set_fs(old_fs);
+
+	return res;
+}
+EXPORT_SYMBOL(kernel_write);
+
diff --git a/fs/splice.c b/fs/splice.c
index c1a2861..44b201b 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -583,22 +583,6 @@ static ssize_t kernel_readv(struct file *file, const struct iovec *vec,
 	return res;
 }
 
-ssize_t kernel_write(struct file *file, const char *buf, size_t count,
-			    loff_t pos)
-{
-	mm_segment_t old_fs;
-	ssize_t res;
-
-	old_fs = get_fs();
-	set_fs(get_ds());
-	/* The cast to a user pointer is valid due to the set_fs() */
-	res = vfs_write(file, (__force const char __user *)buf, count, &pos);
-	set_fs(old_fs);
-
-	return res;
-}
-EXPORT_SYMBOL(kernel_write);
-
 ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 				 struct pipe_inode_info *pipe, size_t len,
 				 unsigned int flags)
-- 
2.1.0
