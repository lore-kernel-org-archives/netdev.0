From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 5/8] fs/file: __alloc_fd takes extra argument: newfile
Date: Mon,  9 Mar 2015 14:20:00 -0700
Message-ID: <1425936003-24544-5-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34489 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbbCIVU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:26 -0400
Received: by igal13 with SMTP id l13so23267793iga.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:25 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 drivers/android/binder.c |  2 +-
 fs/file.c                | 10 ++++++----
 include/linux/fdtable.h  |  3 ++-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 33b09b6568a4..75ad6b604f2a 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -389,7 +389,7 @@ static int task_get_unused_fd_flags(struct binder_p=
roc *proc, int flags)
 	rlim_cur =3D task_rlimit(proc->tsk, RLIMIT_NOFILE);
 	unlock_task_sighand(proc->tsk, &irqs);
=20
-	return __alloc_fd(files, 0, rlim_cur, flags);
+	return __alloc_fd(files, 0, rlim_cur, flags, NULL);
 }
=20
 /*
diff --git a/fs/file.c b/fs/file.c
index ee738ea028fa..01b1e171ce0a 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -443,7 +443,8 @@ struct files_struct init_files =3D {
  * allocate a file descriptor, mark it busy.
  */
 int __alloc_fd(struct files_struct *files,
-	       unsigned start, unsigned end, unsigned flags)
+	       unsigned start, unsigned end, unsigned flags,
+	       struct file *newfile)
 {
 	unsigned int fd;
 	int error;
@@ -491,9 +492,9 @@ repeat:
 	/* Sanity check */
 	if (rcu_access_pointer(fdt->fd[fd]) !=3D NULL) {
 		printk(KERN_WARNING "alloc_fd: slot %d not NULL!\n", fd);
-		rcu_assign_pointer(fdt->fd[fd], NULL);
 	}
 #endif
+	rcu_assign_pointer(fdt->fd[fd], newfile);
=20
 out:
 	spin_unlock(&files->file_lock);
@@ -502,12 +503,13 @@ out:
=20
 static int alloc_fd(unsigned start, unsigned flags)
 {
-	return __alloc_fd(current->files, start, rlimit(RLIMIT_NOFILE), flags=
);
+	return __alloc_fd(current->files, start, rlimit(RLIMIT_NOFILE), flags=
,
+			  NULL);
 }
=20
 int get_unused_fd_flags(unsigned flags)
 {
-	return __alloc_fd(current->files, 0, rlimit(RLIMIT_NOFILE), flags);
+	return __alloc_fd(current->files, 0, rlimit(RLIMIT_NOFILE), flags, NU=
LL);
 }
 EXPORT_SYMBOL(get_unused_fd_flags);
=20
diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index 230f87bdf5ad..a4e0a98750c3 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -107,7 +107,8 @@ int iterate_fd(struct files_struct *, unsigned,
 		const void *);
=20
 extern int __alloc_fd(struct files_struct *files,
-		      unsigned start, unsigned end, unsigned flags);
+		      unsigned start, unsigned end, unsigned flags,
+		      struct file *newfile);
 extern void __fd_install(struct files_struct *files,
 		      unsigned int fd, struct file *file);
 extern int __close_fd(struct files_struct *files,
--=20
2.2.0.rc0.207.ga3a616c
