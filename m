From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] unix_diag: fix incorrect sign extension in unix_lookup_by_ino
Date: Fri, 19 Feb 2016 04:27:48 +0300
Message-ID: <20160219012748.GA17251@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegasus3.altlinux.org ([194.107.17.103]:54429 "EHLO
	pegasus3.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947436AbcBSB1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 20:27:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The value passed by unix_diag_get_exact to unix_lookup_by_ino has type
__u32, but unix_lookup_by_ino's argument ino has type int, which is not
a problem yet.
However, when ino is compared with sock_i_ino return value of type
unsigned long, ino is sign extended to signed long, and this results
to incorrect comparison on 64-bit architectures for inode numbers
greater than INT_MAX.

This bug was found by strace test suite.

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Cc: <stable@vger.kernel.org>
---
 net/unix/diag.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index c512f64..4d96797 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -220,23 +220,23 @@ done:
 	return skb->len;
 }
 
-static struct sock *unix_lookup_by_ino(int ino)
+static struct sock *unix_lookup_by_ino(unsigned int ino)
 {
 	int i;
 	struct sock *sk;
 
 	spin_lock(&unix_table_lock);
 	for (i = 0; i < ARRAY_SIZE(unix_socket_table); i++) {
 		sk_for_each(sk, &unix_socket_table[i])
 			if (ino == sock_i_ino(sk)) {
 				sock_hold(sk);
 				spin_unlock(&unix_table_lock);
 
 				return sk;
 			}
 	}
 
 	spin_unlock(&unix_table_lock);
 	return NULL;
 }
 
-- 
ldv
