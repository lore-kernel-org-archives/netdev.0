From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] fs,net: Add MS_NOIPCCONNECT to block existing FIFOs and sockets
Date: Thu,  1 May 2014 16:28:22 -0700
Message-ID: <c4006d98a202e5a9db57e24dd7922704d78ae60f.1398986696.git.luto@amacapital.net>
Cc: Andy Lutomirski <luto@amacapital.net>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An MS_RDONLY mount disallows binding unix sockets and creating
FIFOs, but it does not prevent opening existing FIFOs and connecting
to unix sockets.  Containers and other sandbox-like applications may
want to block IPC to the outside world.  Network namespaces can
control access to abstract namespace unix sockets, but there is
currently no way to control access to FIFOs and sockets with paths
other than relying on DAC or MAC rules.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 fs/namei.c              |  2 ++
 fs/namespace.c          |  4 +++-
 fs/proc_namespace.c     |  1 +
 include/linux/mount.h   | 15 ++++++++-------
 include/uapi/linux/fs.h |  1 +
 net/unix/af_unix.c      |  6 ++++++
 6 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index c6157c8..e082c60 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2546,6 +2546,8 @@ static int may_open(struct path *path, int acc_mode, int flag)
 		/*FALLTHRU*/
 	case S_IFIFO:
 	case S_IFSOCK:
+		if (path->mnt->mnt_flags & MNT_NOIPCCONNECT)
+			return -EACCES;
 		flag &= ~O_TRUNC;
 		break;
 	}
diff --git a/fs/namespace.c b/fs/namespace.c
index 182bc41..49f9b1b 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2435,10 +2435,12 @@ long do_mount(const char *dev_name, const char *dir_name,
 		mnt_flags &= ~(MNT_RELATIME | MNT_NOATIME);
 	if (flags & MS_RDONLY)
 		mnt_flags |= MNT_READONLY;
+	if (flags & MS_NOIPCCONNECT)
+		mnt_flags |= MNT_NOIPCCONNECT;
 
 	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_BORN |
 		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT |
-		   MS_STRICTATIME);
+		   MS_STRICTATIME | MS_NOIPCCONNECT);
 
 	if (flags & MS_REMOUNT)
 		retval = do_remount(&path, flags & ~MS_REMOUNT, mnt_flags,
diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
index 1a81373..2aaf478 100644
--- a/fs/proc_namespace.c
+++ b/fs/proc_namespace.c
@@ -65,6 +65,7 @@ static void show_mnt_opts(struct seq_file *m, struct vfsmount *mnt)
 		{ MNT_NOATIME, ",noatime" },
 		{ MNT_NODIRATIME, ",nodiratime" },
 		{ MNT_RELATIME, ",relatime" },
+		{ MNT_NOIPCCONNECT, ",noipcconnect" },
 		{ 0, NULL }
 	};
 	const struct proc_fs_info *fs_infop;
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 839bac2..78007eb 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -21,13 +21,14 @@ struct vfsmount;
 struct dentry;
 struct mnt_namespace;
 
-#define MNT_NOSUID	0x01
-#define MNT_NODEV	0x02
-#define MNT_NOEXEC	0x04
-#define MNT_NOATIME	0x08
-#define MNT_NODIRATIME	0x10
-#define MNT_RELATIME	0x20
-#define MNT_READONLY	0x40	/* does the user want this to be r/o? */
+#define MNT_NOSUID		0x01
+#define MNT_NODEV		0x02
+#define MNT_NOEXEC		0x04
+#define MNT_NOATIME		0x08
+#define MNT_NODIRATIME		0x10
+#define MNT_RELATIME		0x20
+#define MNT_READONLY		0x40	/* does the user want this to be r/o? */
+#define MNT_NOIPCCONNECT	0x80
 
 #define MNT_SHRINKABLE	0x100
 #define MNT_WRITE_HOLD	0x200
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index ca1a11b..c4502cc 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -89,6 +89,7 @@ struct inodes_stat_t {
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
+#define MS_NOIPCCONNECT	(1<<25) /* Disallow connecting to pipes and sockets */
 
 /* These sb flags are internal to the kernel */
 #define MS_NOSEC	(1<<28)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index bb7e8ba..e24b682 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -783,6 +783,12 @@ static struct sock *unix_find_other(struct net *net,
 		err = kern_path(sunname->sun_path, LOOKUP_FOLLOW, &path);
 		if (err)
 			goto fail;
+
+		if (path.mnt->mnt_flags & MNT_NOIPCCONNECT) {
+			err = -EACCES;
+			goto put_fail;
+		}
+
 		inode = path.dentry->d_inode;
 		err = inode_permission(inode, MAY_WRITE);
 		if (err)
-- 
1.9.0
