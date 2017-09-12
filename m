From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] VSOCK: fix uapi/linux/vm_sockets.h incomplete types
Date: Tue, 12 Sep 2017 17:34:35 +0100
Message-ID: <20170912163435.4049-1-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751054AbdILQei (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 12:34:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following compiler errors when userspace
applications use the vm_sockets.h header:

  include/uapi/linux/vm_sockets.h:148:32: error: invalid application of ‘sizeof’ to incomplete type ‘struct sockaddr’
    unsigned char svm_zero[sizeof(struct sockaddr) -
                                  ^~~~~~
  include/uapi/linux/vm_sockets.h:149:18: error: ‘sa_family_t’ undeclared here (not in a function)
             sizeof(sa_family_t) -
                    ^~~~~~~~~~~

Two issues:
1. In the kernel struct sockaddr comes in via <linux/socket.h> but in
   userspace <sys/socket.h> is required.
2. struct sockaddr_vm has a __kernel_sa_family_t field so let's be
   consistent and use the same type for the sizeof(sa_family_t)
   calculation.

Currently userspace applications work around this broken header by first
including <sys/socket.h>.  In the kernel there is no compiler error
because <linux/socket.h> provides everything.  It's worth fixing the
header file though.

Cc: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/uapi/linux/vm_sockets.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
index b4ed5d895699..4ae5c625ac56 100644
--- a/include/uapi/linux/vm_sockets.h
+++ b/include/uapi/linux/vm_sockets.h
@@ -18,6 +18,10 @@
 
 #include <linux/socket.h>
 
+#ifndef __KERNEL__
+#include <sys/socket.h> /* struct sockaddr */
+#endif
+
 /* Option name for STREAM socket buffer size.  Use as the option name in
  * setsockopt(3) or getsockopt(3) to set or get an unsigned long long that
  * specifies the size of the buffer underlying a vSockets STREAM socket.
@@ -146,7 +150,7 @@ struct sockaddr_vm {
 	unsigned int svm_port;
 	unsigned int svm_cid;
 	unsigned char svm_zero[sizeof(struct sockaddr) -
-			       sizeof(sa_family_t) -
+			       sizeof(__kernel_sa_family_t) -
 			       sizeof(unsigned short) -
 			       sizeof(unsigned int) - sizeof(unsigned int)];
 };
-- 
2.13.5
