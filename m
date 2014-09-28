From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: [PATCH] Fix getsockopt(SO_PEERNAME) buffer size against potential
 future buffer overflow
Date: Sun, 28 Sep 2014 15:55:45 +0200
Message-ID: <20140928135545.GA23220@type.youpi.perso.aquilenet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In net/core/sock.c's sock_getsockopt, the address buffer size is
hardcoded to 128. It happens that sizeof(struct sockaddr_storage) is
indeed 128, but that is just luck and would probably not get updated
whenever sockaddr_storage would grow. This patch makes it simply use
sockaddr_storage instead.

Signed-off-by:  Samuel Thibault <samuel.thibault@ens-lyon.org>

--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1155,13 +1155,13 @@ int sock_getsockopt(struct socket *sock,
 
 	case SO_PEERNAME:
 	{
-		char address[128];
+		struct sockaddr_storage address;
 
-		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
+		if (sock->ops->getname(sock, (struct sockaddr *)&address, &lv, 2))
 			return -ENOTCONN;
 		if (lv < len)
 			return -EINVAL;
-		if (copy_to_user(optval, address, len))
+		if (copy_to_user(optval, &address, len))
 			return -EFAULT;
 		goto lenout;
 	}
