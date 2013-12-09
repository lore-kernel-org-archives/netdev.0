From: Yann Droneaud <ydroneaud@opteya.com>
Subject: [PATCH v3] net: handle error more gracefully in socketpair()
Date: Mon,  9 Dec 2013 22:42:20 +0100
Message-ID: <1386625340-8490-1-git-send-email-ydroneaud@opteya.com>
References: <1386285331.18074.47.camel@localhost.localdomain> <20131205.194355.1677309681391704143.davem@davemloft.net> <1386324655.18074.75.camel@localhost.localdomain> <20131206104805.GM10323@ZenIV.linux.org.uk> <20131206.121411.2205219888474731457.davem@davemloft.net>
Cc: Yann Droneaud <ydroneaud@opteya.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131206.121411.2205219888474731457.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes socketpair() use error paths which do not
rely on heavy-weight call to sys_close(): it's better to try
to push the file descriptor to userspace before installing
the socket file to the file descriptor, so that errors are
catched earlier and being easier to handle.

Using sys_close() seems to be the exception, while writing the
file descriptor before installing it look like it's more or less
the norm: eg. except for code used in init/, error handling
involve fput() and put_unused_fd(), but not sys_close().

This make socketpair() usage of sys_close() quite unusual.
So it deserves to be replaced by the common pattern relying on
fput() and put_unused_fd() just like, for example, the one used
in pipe(2) or recvmsg(2).

Three distinct error paths are still needed since calling
fput() on file structure returned by sock_alloc_file() will
implicitly call sock_release() on the associated socket
structure.

Cc: David S. Miller <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
Link: http://marc.info/?i=1385979146-13825-1-git-send-email-ydroneaud@opteya.com
---

Hi David,

Please find a patch which was discussed last week.

I've rework a bit the commit message to sum up our discussion
about the pattern to use when dealing with file descriptor when
it has to be copied to userspace.

Regards.

Changes from v2 [1]:

- rework a bit commit message

Changes from v1 [2]:

- use three different error path to handle file allocated through
  sock_alloc_file().

Regards.

[1] http://mid.gmane.org/1385979146-13825-1-git-send-email-ydroneaud@opteya.com

[2] http://mid.gmane.org/1385977019-12282-1-git-send-email-ydroneaud@opteya.com

 net/socket.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index cd38a785f7d2..879933aaed4c 100644
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
