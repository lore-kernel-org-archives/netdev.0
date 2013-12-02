From: Yann Droneaud <ydroneaud@opteya.com>
Subject: [PATCH v2] net: handle error more gracefully in socketpair()
Date: Mon,  2 Dec 2013 11:12:26 +0100
Message-ID: <1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
References: <1385977019-12282-1-git-send-email-ydroneaud@opteya.com>
Cc: Yann Droneaud <ydroneaud@opteya.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385977019-12282-1-git-send-email-ydroneaud@opteya.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

socketpair() error paths can be simplified to not call
heavy-weight sys_close().

This patch makes socketpair() use of error paths which do not
rely on heavy-weight call to sys_lose(): it's better to try
to push the file descriptor to userspace before installing
the socket file to the file descriptor, so that errors are
catched earlier and being easier to handle.

Three distinct error paths are needed since calling fput()
on file structure returned by sock_alloc_file() will
implicitly call sock_release() on the associated socket
structure.

Cc: David S. Miller <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
Link: http://marc.info/?i=1385977019-12282-1-git-send-email-ydroneaud@opteya.com
---

Hi,

Please discard my previous patch "[PATCH] net: handle error
more gracefully in socketpair()" [1] as I haven't double checked
the underlying reason for the not-so-complicated error paths.

This one is perhaps less appealing. But I think it's still
a good thing to write the file descriptor to userspace before
calling fd_install(): it's making error recovery easier.

Changes from v1 [1]:

- use three different error path to handle file allocated through
  sock_alloc_file().

Regards.

[1] http://mid.gmane.org/1385977019-12282-1-git-send-email-ydroneaud@opteya.com

 net/socket.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 0b18693f2be6..72bf3c41f4f0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1445,48 +1445,61 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
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
+	return 0;
 
-	sys_close(fd2);
-	sys_close(fd1);
-	return err;
+out_fput_both:
+	fput(newfile2);
+	fput(newfile1);
+	put_unused_fd(fd2);
+	put_unused_fd(fd1);
+	goto out;
+
+out_fput_1:
+	fput(newfile1);
+	put_unused_fd(fd2);
+	put_unused_fd(fd1);
+	sock_release(sock2);
+	goto out;
 
+out_put_unused_both:
+	put_unused_fd(fd2);
+out_put_unused_1:
+	put_unused_fd(fd1);
 out_release_both:
 	sock_release(sock2);
 out_release_1:
-- 
1.8.4.2
