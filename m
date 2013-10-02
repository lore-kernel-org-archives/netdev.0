From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Thu, 3 Oct 2013 00:27:20 +0300
Message-ID: <20131002212720.GA30492@elgon.mountain>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, security@kernel.org,
	=?iso-8859-1?Q?J=FCri?= Aedla <juri.aedla@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33775 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab3JBV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:27:30 -0400
Content-Disposition: inline
In-Reply-To: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to cap ->msg_namelen or it leads to a buffer overflow when we
to the memcpy() in __audit_sockaddr().  It requires CAP_AUDIT_CONTROL t=
o
exploit this bug.

The call tree is:
___sys_recvmsg()
  move_addr_to_user()
    audit_sockaddr()
      __audit_sockaddr()

Reported-by: J=FCri Aedla <juri.aedla@gmail.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: The limit check to the compat code was missing as pointed out by
Ben Hutchings.

diff --git a/net/socket.c b/net/socket.c
index ebed4b6..c226ace 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1964,6 +1964,16 @@ struct used_address {
 	unsigned int name_len;
 };
=20
+static int copy_msghdr_from_user(struct msghdr *kmsg,
+				 struct msghdr __user *umsg)
+{
+	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
+		return -EFAULT;
+	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
+		return -EINVAL;
+	return 0;
+}
+
 static int ___sys_sendmsg(struct socket *sock, struct msghdr __user *m=
sg,
 			 struct msghdr *msg_sys, unsigned int flags,
 			 struct used_address *used_address)
@@ -1982,8 +1992,11 @@ static int ___sys_sendmsg(struct socket *sock, s=
truct msghdr __user *msg,
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
-	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
-		return -EFAULT;
+	} else {
+		err =3D copy_msghdr_from_user(msg_sys, msg);
+		if (err)
+			return err;
+	}
=20
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		err =3D -EMSGSIZE;
@@ -2191,8 +2204,11 @@ static int ___sys_recvmsg(struct socket *sock, s=
truct msghdr __user *msg,
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
-	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
-		return -EFAULT;
+	} else {
+		err =3D copy_msghdr_from_user(msg_sys, msg);
+		if (err)
+			return err;
+	}
=20
 	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		err =3D -EMSGSIZE;
diff --git a/net/compat.c b/net/compat.c
index f0a1ba6..8903258 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -71,6 +71,8 @@ int get_compat_msghdr(struct msghdr *kmsg, struct com=
pat_msghdr __user *umsg)
 	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
 	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
 		return -EFAULT;
+	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
+		return -EINVAL;
 	kmsg->msg_name =3D compat_ptr(tmp1);
 	kmsg->msg_iov =3D compat_ptr(tmp2);
 	kmsg->msg_control =3D compat_ptr(tmp3);
