From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] Correct accept(2) recovery after sock_attach_fd()
Date: Mon, 26 Mar 2007 19:34:31 +0400
Message-ID: <20070326153431.GA6805@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:24615 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbXCZP0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 11:26:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* d_alloc() in sock_attach_fd() fails leaving ->f_dentry of new file NULL
* bail out to out_fd label, doing fput()/__fput() on new file
* but __fput() assumes valid ->f_dentry and dereferences it

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/socket.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/net/socket.c
+++ b/net/socket.c
@@ -1381,7 +1381,7 @@ asmlinkage long sys_accept(int fd, struc
 
 	err = sock_attach_fd(newsock, newfile);
 	if (err < 0)
-		goto out_fd;
+		goto out_fd_simple;
 
 	err = security_socket_accept(sock, newsock);
 	if (err)
@@ -1414,6 +1414,11 @@ out_put:
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
+out_fd_simple:
+	sock_release(newsock);
+	put_filp(newfile);
+	put_unused_fd(newfd);
+	goto out_put;
 out_fd:
 	fput(newfile);
 	put_unused_fd(newfd);

