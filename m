From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : cleanup sock_from_file()
Date: Wed, 07 Feb 2007 00:03:25 +0100
Message-ID: <45C9093D.1030605@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com>
 <20070206.144106.39659974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_kw20IDvE4XsjJ5w9g2njhA)"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:47268 "EHLO smtp.Neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030511AbXBFXDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 18:03:32 -0500
Received: from [192.168.30.11] ([88.139.66.191]) by sp604005mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JD2005UUDDUKLH0@sp604005mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Wed, 07 Feb 2007 00:03:30 +0100 (CET)
In-reply-to: <20070206.144106.39659974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_kw20IDvE4XsjJ5w9g2njhA)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

I believe dead code from sock_from_file() can be cleaned up.

All sockets are now built using sock_attach_fd(), that puts the 'sock' pointer 
into file->private_data and &socket_file_ops into file->f_op

I could not find a place where file->private_data could be set to NULL, 
keeping opened the file.

So to get 'sock' from a 'file' pointer, either :

- This is a socket file (f_op == &socket_file_ops), and we can directly get 
'sock' from private_data.
- This is not a socket, we return -ENOTSOCK and dont even try to find a socket 
via dentry/inode :)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary_(ID_kw20IDvE4XsjJ5w9g2njhA)
Content-type: text/plain; name=sock_from_file.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=sock_from_file.patch

--- linux/net/socket.c	2007-02-07 00:37:44.000000000 +0100
+++ linux-ed/net/socket.c	2007-02-07 00:43:36.000000000 +0100
@@ -407,24 +407,11 @@ int sock_map_fd(struct socket *sock)
 
 static struct socket *sock_from_file(struct file *file, int *err)
 {
-	struct inode *inode;
-	struct socket *sock;
-
 	if (file->f_op == &socket_file_ops)
 		return file->private_data;	/* set in sock_map_fd */
 
-	inode = file->f_path.dentry->d_inode;
-	if (!S_ISSOCK(inode->i_mode)) {
-		*err = -ENOTSOCK;
-		return NULL;
-	}
-
-	sock = SOCKET_I(inode);
-	if (sock->file != file) {
-		printk(KERN_ERR "socki_lookup: socket file changed!\n");
-		sock->file = file;
-	}
-	return sock;
+	*err = -ENOTSOCK;
+	return NULL;
 }
 
 /**

--Boundary_(ID_kw20IDvE4XsjJ5w9g2njhA)--
