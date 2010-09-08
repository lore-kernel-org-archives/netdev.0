From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 1/2] net/core: remove address space warnings on verify_iovec()
Date: Wed,  8 Sep 2010 22:48:47 +0900
Message-ID: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:52357 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab0IHNtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 09:49:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move_addr_to_kernel() and copy_from_user() requires their argument
as __user pointer but were missing proper markups. Add it.
This removes following warnings from sparse.

 net/core/iovec.c:44:52: warning: incorrect type in argument 1 (different address spaces)
 net/core/iovec.c:44:52:    expected void [noderef] <asn:1>*uaddr
 net/core/iovec.c:44:52:    got void *msg_name
 net/core/iovec.c:55:34: warning: incorrect type in argument 2 (different address spaces)
 net/core/iovec.c:55:34:    expected void const [noderef] <asn:1>*from
 net/core/iovec.c:55:34:    got struct iovec *msg_iov

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 net/core/iovec.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/iovec.c b/net/core/iovec.c
index 1cd98df..f4657c2 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -41,7 +41,9 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address,
 
 	if (m->msg_namelen) {
 		if (mode == VERIFY_READ) {
-			err = move_addr_to_kernel(m->msg_name, m->msg_namelen,
+			void __user *namep;
+			namep = (void __user __force *) m->msg_name;
+			err = move_addr_to_kernel(namep, m->msg_namelen,
 						  address);
 			if (err < 0)
 				return err;
@@ -52,7 +54,7 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address,
 	}
 
 	size = m->msg_iovlen * sizeof(struct iovec);
-	if (copy_from_user(iov, m->msg_iov, size))
+	if (copy_from_user(iov, (void __user __force *) m->msg_iov, size))
 		return -EFAULT;
 
 	m->msg_iov = iov;
-- 
1.7.2.2

