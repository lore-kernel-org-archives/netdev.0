From: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Subject: [PATCH 1/6] fs: move sendfile syscall into fs/splice
Date: Sun, 23 Nov 2014 15:20:45 +0100
Message-ID: <1416752468-1626-2-git-send-email-pieter@boesman.nl>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	Catalina Mocanu <catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org (open list:FUSE: FILESYSTEM...),
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Iulia Manda <iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:ABI/API),
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel
To: pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416752468-1626-1-git-send-email-pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

sendfile functionally forms part of the splice group of syscalls (splice,
vmsplice and tee). Grouping sendfile with splice paves the way to compiling out
the splice group of syscalls for embedded systems that do not need these.

add/remove: 0/0 grow/shrink: 7/2 up/down: 86/-61 (25)
function                                     old     new   delta
file_start_write                              34      68     +34
file_end_write                                29      58     +29
sys_pwritev                                  115     122      +7
sys_preadv                                   115     122      +7
fdput_pos                                     29      36      +7
sys_pwrite64                                 115     116      +1
sys_pread64                                  115     116      +1
sys_tee                                      497     491      -6
sys_splice                                  1075    1020     -55

Signed-off-by: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
---
 fs/read_write.c | 175 -------------------------------------------------------
 fs/splice.c     | 178 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 178 insertions(+), 175 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 7d9318c..d9451ba 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1191,178 +1191,3 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,
 }
 #endif
 
-static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
-		  	   size_t count, loff_t max)
-{
-	struct fd in, out;
-	struct inode *in_inode, *out_inode;
-	loff_t pos;
-	loff_t out_pos;
-	ssize_t retval;
-	int fl;
-
-	/*
-	 * Get input file, and verify that it is ok..
-	 */
-	retval = -EBADF;
-	in = fdget(in_fd);
-	if (!in.file)
-		goto out;
-	if (!(in.file->f_mode & FMODE_READ))
-		goto fput_in;
-	retval = -ESPIPE;
-	if (!ppos) {
-		pos = in.file->f_pos;
-	} else {
-		pos = *ppos;
-		if (!(in.file->f_mode & FMODE_PREAD))
-			goto fput_in;
-	}
-	retval = rw_verify_area(READ, in.file, &pos, count);
-	if (retval < 0)
-		goto fput_in;
-	count = retval;
-
-	/*
-	 * Get output file, and verify that it is ok..
-	 */
-	retval = -EBADF;
-	out = fdget(out_fd);
-	if (!out.file)
-		goto fput_in;
-	if (!(out.file->f_mode & FMODE_WRITE))
-		goto fput_out;
-	retval = -EINVAL;
-	in_inode = file_inode(in.file);
-	out_inode = file_inode(out.file);
-	out_pos = out.file->f_pos;
-	retval = rw_verify_area(WRITE, out.file, &out_pos, count);
-	if (retval < 0)
-		goto fput_out;
-	count = retval;
-
-	if (!max)
-		max = min(in_inode->i_sb->s_maxbytes, out_inode->i_sb->s_maxbytes);
-
-	if (unlikely(pos + count > max)) {
-		retval = -EOVERFLOW;
-		if (pos >= max)
-			goto fput_out;
-		count = max - pos;
-	}
-
-	fl = 0;
-#if 0
-	/*
-	 * We need to debate whether we can enable this or not. The
-	 * man page documents EAGAIN return for the output at least,
-	 * and the application is arguably buggy if it doesn't expect
-	 * EAGAIN on a non-blocking file descriptor.
-	 */
-	if (in.file->f_flags & O_NONBLOCK)
-		fl = SPLICE_F_NONBLOCK;
-#endif
-	file_start_write(out.file);
-	retval = do_splice_direct(in.file, &pos, out.file, &out_pos, count, fl);
-	file_end_write(out.file);
-
-	if (retval > 0) {
-		add_rchar(current, retval);
-		add_wchar(current, retval);
-		fsnotify_access(in.file);
-		fsnotify_modify(out.file);
-		out.file->f_pos = out_pos;
-		if (ppos)
-			*ppos = pos;
-		else
-			in.file->f_pos = pos;
-	}
-
-	inc_syscr(current);
-	inc_syscw(current);
-	if (pos > max)
-		retval = -EOVERFLOW;
-
-fput_out:
-	fdput(out);
-fput_in:
-	fdput(in);
-out:
-	return retval;
-}
-
-SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd, off_t __user *, offset, size_t, count)
-{
-	loff_t pos;
-	off_t off;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(get_user(off, offset)))
-			return -EFAULT;
-		pos = off;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd, loff_t __user *, offset, size_t, count)
-{
-	loff_t pos;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
-			return -EFAULT;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-#ifdef CONFIG_COMPAT
-COMPAT_SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd,
-		compat_off_t __user *, offset, compat_size_t, count)
-{
-	loff_t pos;
-	off_t off;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(get_user(off, offset)))
-			return -EFAULT;
-		pos = off;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
-		compat_loff_t __user *, offset, compat_size_t, count)
-{
-	loff_t pos;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
-			return -EFAULT;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-#endif
diff --git a/fs/splice.c b/fs/splice.c
index f5cb9ba..c1a2861 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -28,6 +28,7 @@
 #include <linux/export.h>
 #include <linux/syscalls.h>
 #include <linux/uio.h>
+#include <linux/fsnotify.h>
 #include <linux/security.h>
 #include <linux/gfp.h>
 #include <linux/socket.h>
@@ -2039,3 +2040,180 @@ SYSCALL_DEFINE4(tee, int, fdin, int, fdout, size_t, len, unsigned int, flags)
 
 	return error;
 }
+
+static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
+			   size_t count, loff_t max)
+{
+	struct fd in, out;
+	struct inode *in_inode, *out_inode;
+	loff_t pos;
+	loff_t out_pos;
+	ssize_t retval;
+	int fl;
+
+	/*
+	 * Get input file, and verify that it is ok..
+	 */
+	retval = -EBADF;
+	in = fdget(in_fd);
+	if (!in.file)
+		goto out;
+	if (!(in.file->f_mode & FMODE_READ))
+		goto fput_in;
+	retval = -ESPIPE;
+	if (!ppos) {
+		pos = in.file->f_pos;
+	} else {
+		pos = *ppos;
+		if (!(in.file->f_mode & FMODE_PREAD))
+			goto fput_in;
+	}
+	retval = rw_verify_area(READ, in.file, &pos, count);
+	if (retval < 0)
+		goto fput_in;
+	count = retval;
+
+	/*
+	 * Get output file, and verify that it is ok..
+	 */
+	retval = -EBADF;
+	out = fdget(out_fd);
+	if (!out.file)
+		goto fput_in;
+	if (!(out.file->f_mode & FMODE_WRITE))
+		goto fput_out;
+	retval = -EINVAL;
+	in_inode = file_inode(in.file);
+	out_inode = file_inode(out.file);
+	out_pos = out.file->f_pos;
+	retval = rw_verify_area(WRITE, out.file, &out_pos, count);
+	if (retval < 0)
+		goto fput_out;
+	count = retval;
+
+	if (!max)
+		max = min(in_inode->i_sb->s_maxbytes, out_inode->i_sb->s_maxbytes);
+
+	if (unlikely(pos + count > max)) {
+		retval = -EOVERFLOW;
+		if (pos >= max)
+			goto fput_out;
+		count = max - pos;
+	}
+
+	fl = 0;
+#if 0
+	/*
+	 * We need to debate whether we can enable this or not. The
+	 * man page documents EAGAIN return for the output at least,
+	 * and the application is arguably buggy if it doesn't expect
+	 * EAGAIN on a non-blocking file descriptor.
+	 */
+	if (in.file->f_flags & O_NONBLOCK)
+		fl = SPLICE_F_NONBLOCK;
+#endif
+	file_start_write(out.file);
+	retval = do_splice_direct(in.file, &pos, out.file, &out_pos, count, fl);
+	file_end_write(out.file);
+
+	if (retval > 0) {
+		add_rchar(current, retval);
+		add_wchar(current, retval);
+		fsnotify_access(in.file);
+		fsnotify_modify(out.file);
+		out.file->f_pos = out_pos;
+		if (ppos)
+			*ppos = pos;
+		else
+			in.file->f_pos = pos;
+	}
+
+	inc_syscr(current);
+	inc_syscw(current);
+	if (pos > max)
+		retval = -EOVERFLOW;
+
+fput_out:
+	fdput(out);
+fput_in:
+	fdput(in);
+out:
+	return retval;
+}
+
+SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd, off_t __user *, offset, size_t, count)
+{
+	loff_t pos;
+	off_t off;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(get_user(off, offset)))
+			return -EFAULT;
+		pos = off;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd, loff_t __user *, offset, size_t, count)
+{
+	loff_t pos;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
+			return -EFAULT;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+#ifdef CONFIG_COMPAT
+COMPAT_SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd,
+		compat_off_t __user *, offset, compat_size_t, count)
+{
+	loff_t pos;
+	off_t off;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(get_user(off, offset)))
+			return -EFAULT;
+		pos = off;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
+		compat_loff_t __user *, offset, compat_size_t, count)
+{
+	loff_t pos;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
+			return -EFAULT;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+#endif
+
-- 
2.1.0
