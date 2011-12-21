From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/4] vfs: Export some file manipulation functions
Date: Wed, 21 Dec 2011 09:39:48 -0500
Message-ID: <1324478390-22036-3-git-send-email-nhorman@tuxdriver.com>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34865 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab1LUOk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:40:28 -0500
In-Reply-To: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the networking cgroups can use the fd table of a task to make adjustments to the
sockets that they own, helping us set owners for various resources. Export
get_files_struct, put_files_struct and sock_from_file, so we can walk a tasks
fdarray easily.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/linux/fdtable.h |    4 ++--
 include/linux/net.h     |    1 +
 kernel/exit.c           |    2 ++
 net/socket.c            |    3 ++-
 4 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index 82163c4..1d06352 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -97,8 +97,8 @@ static inline struct file * fcheck_files(struct files_struct *files, unsigned in
 
 struct task_struct;
 
-struct files_struct *get_files_struct(struct task_struct *);
-void put_files_struct(struct files_struct *fs);
+extern struct files_struct *get_files_struct(struct task_struct *);
+extern void put_files_struct(struct files_struct *fs);
 void reset_files_struct(struct files_struct *);
 int unshare_files(struct files_struct **);
 struct files_struct *dup_fd(struct files_struct *, int *);
diff --git a/include/linux/net.h b/include/linux/net.h
index b299230..eea9912 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -245,6 +245,7 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
 extern int 	     sock_map_fd(struct socket *sock, int flags);
+extern struct socket *sock_from_file(struct file *file, int *err);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
diff --git a/kernel/exit.c b/kernel/exit.c
index d0b7d98..2f48b95 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -499,6 +499,7 @@ struct files_struct *get_files_struct(struct task_struct *task)
 
 	return files;
 }
+EXPORT_SYMBOL(get_files_struct);
 
 void put_files_struct(struct files_struct *files)
 {
@@ -520,6 +521,7 @@ void put_files_struct(struct files_struct *files)
 		rcu_read_unlock();
 	}
 }
+EXPORT_SYMBOL(put_files_struct);
 
 void reset_files_struct(struct files_struct *files)
 {
diff --git a/net/socket.c b/net/socket.c
index e62b4f0..eab8db1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -398,7 +398,7 @@ int sock_map_fd(struct socket *sock, int flags)
 }
 EXPORT_SYMBOL(sock_map_fd);
 
-static struct socket *sock_from_file(struct file *file, int *err)
+struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
 		return file->private_data;	/* set in sock_map_fd */
@@ -406,6 +406,7 @@ static struct socket *sock_from_file(struct file *file, int *err)
 	*err = -ENOTSOCK;
 	return NULL;
 }
+EXPORT_SYMBOL(sock_from_file);
 
 /**
  *	sockfd_lookup - Go from a file number to its socket slot
-- 
1.7.6.4
