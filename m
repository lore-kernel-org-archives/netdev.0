From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2.5.69] Bug in sys_accept() module ref counts
Date: Tue, 6 May 2003 12:28:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0305061223090.1348-100000@dyn9-47-18-140.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think there is a bug in the recent changes to sys_accept() to implement 
module ref counts.

module_put() gets called twice on error. Once via the explicit module_put and
the second via sock_release(). Also i think we should do a __module_get() with 
newsock's owner(although same as the original listening sock).

The following patch against 2.5.69 should fix the problem.

Thanks
Sridhar
-------------------------------------------------------------------------------
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Tue May  6 12:14:35 2003
+++ b/net/socket.c	Tue May  6 12:14:35 2003
@@ -1280,26 +1280,26 @@
 	 * We don't need try_module_get here, as the listening socket (sock)
 	 * has the protocol module (sock->ops->owner) held.
 	 */
-	__module_get(sock->ops->owner);
+	__module_get(newsock->ops->owner);
 
 	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
-		goto out_module_put;
+		goto out_release;
 
 	if (upeer_sockaddr) {
 		if(newsock->ops->getname(newsock, (struct sockaddr *)address, &len, 2)<0) {
 			err = -ECONNABORTED;
-			goto out_module_put;
+			goto out_release;
 		}
 		err = move_addr_to_user(address, len, upeer_sockaddr, upeer_addrlen);
 		if (err < 0)
-			goto out_module_put;
+			goto out_release;
 	}
 
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	if ((err = sock_map_fd(newsock)) < 0)
-		goto out_module_put;
+		goto out_release;
 
 	security_socket_post_accept(sock, newsock);
 
@@ -1307,8 +1307,6 @@
 	sockfd_put(sock);
 out:
 	return err;
-out_module_put:
-	module_put(sock->ops->owner);
 out_release:
 	sock_release(newsock);
 	goto out_put;
