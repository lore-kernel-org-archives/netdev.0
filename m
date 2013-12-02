From: Yann Droneaud <ydroneaud@opteya.com>
Subject: [PATCH] net: use a proper error path in socketpair()
Date: Mon,  2 Dec 2013 10:36:59 +0100
Message-ID: <1385977019-12282-1-git-send-email-ydroneaud@opteya.com>
Cc: Yann Droneaud <ydroneaud@opteya.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

socketpair() use overly complicated and redundant error paths.

This patch makes socketpair() use a single error path,
which do not rely on heavy-weight call to sys_close():
it's better to try to push the file descriptor to userspace
before installing the socket file to the file descriptor,
so that errors are catched earlier and being easier to handle.

Cc: David S. Miller <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
---
 net/socket.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 0b18693f2be6..bcc1cbd2087f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1445,48 +1445,51 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 		err = fd1;
 		goto out_release_both;
 	}
+
 	fd2 = get_unused_fd_flags(flags);
 	if (unlikely(fd2 < 0)) {
 		err = fd2;
-		put_unused_fd(fd1);
-		goto out_release_both;
+		goto out_put_unused_1;
 	}
 
 	newfile1 = sock_alloc_file(sock1, flags, NULL);
 	if (unlikely(IS_ERR(newfile1))) {
 		err = PTR_ERR(newfile1);
-		put_unused_fd(fd1);
-		put_unused_fd(fd2);
-		goto out_release_both;
+		goto out_put_unused_both;
 	}
 
 	newfile2 = sock_alloc_file(sock2, flags, NULL);
 	if (IS_ERR(newfile2)) {
 		err = PTR_ERR(newfile2);
-		fput(newfile1);
-		put_unused_fd(fd1);
-		put_unused_fd(fd2);
-		sock_release(sock2);
-		goto out;
+		goto out_fput_1;
 	}
 
+	err = put_user(fd1, &usockvec[0]);
+	if (err)
+		goto out_fput_both;
+
+	err = put_user(fd2, &usockvec[1]);
+	if (err)
+		goto out_fput_both;
+
 	audit_fd_pair(fd1, fd2);
+
 	fd_install(fd1, newfile1);
 	fd_install(fd2, newfile2);
 	/* fd1 and fd2 may be already another descriptors.
 	 * Not kernel problem.
 	 */
 
-	err = put_user(fd1, &usockvec[0]);
-	if (!err)
-		err = put_user(fd2, &usockvec[1]);
-	if (!err)
-		return 0;
-
-	sys_close(fd2);
-	sys_close(fd1);
-	return err;
+	return 0;
 
+out_fput_both:
+	fput(newfile2);
+out_fput_1:
+	fput(newfile1);
+out_put_unused_both:
+	put_unused_fd(fd2);
+out_put_unused_1:
+	put_unused_fd(fd1);
 out_release_both:
 	sock_release(sock2);
 out_release_1:
-- 
1.8.4.2
