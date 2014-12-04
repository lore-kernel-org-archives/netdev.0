From: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Subject: [PATCH v6 2/7] fs: moved kernel_write to fs/read_write
Date: Thu,  4 Dec 2014 18:50:50 +0100
Message-ID: <1417715473-24110-3-git-send-email-pieter@boesman.nl>
References: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>,
	Peter Foley <pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Xiao Guangrong <xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5ug@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1417715473-24110-1-git-send-email-pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

kernel_write shares infrastructure with the read_write translation unit but not
with the splice translation unit. Grouping kernel_write with the read_write
translation unit is more logical. It also paves the way to compiling out the
splice group of syscalls for embedded systems that do not need them.

Signed-off-by: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
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


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
