From: peter enderborg <peter.enderborg@sonymobile.com>
Subject: [PATCH] net: sock: Add option for memory optimized hints.
Date: Fri, 20 May 2016 15:36:53 +0200
Message-ID: <573F12F5.7050704@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seldsegrel01.sonyericsson.com ([37.139.156.29]:16078 "EHLO
	SELDSEGREL01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668AbcETNq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 09:46:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Enderborg <peter.enderborg@sonymobile.com>

When sending data the socket allocates memory for
payload on a cache or a page alloc. The page alloc
then might trigger compation that takes long time.
This can be avoided with smaller chunks. But
userspace can not know what is the right size for
the smaller sends. For this we add a SIZEHINT
getsocketopt where the userspace can get the size
for send that will fit into one page (order 0) or
the max for a slab cache allocation.

Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
---
  include/uapi/asm-generic/socket.h |  2 ++
  include/uapi/linux/socket.h       |  9 +++++++++
  net/core/sock.c                   | 17 +++++++++++++++++
  3 files changed, 28 insertions(+)

diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 67d632f..f6a4921 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -92,4 +92,6 @@

  #define SO_CNX_ADVICE          53

+#define SO_SIZEHINT            54
+
  #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/uapi/linux/socket.h b/include/uapi/linux/socket.h
index 76ab0c6..16db7e8 100644
--- a/include/uapi/linux/socket.h
+++ b/include/uapi/linux/socket.h
@@ -1,6 +1,8 @@
  #ifndef _UAPI_LINUX_SOCKET_H
  #define _UAPI_LINUX_SOCKET_H

+#include <linux/types.h>
+
  /*
   * Desired design of maximum size and alignment (see RFC2553)
   */
@@ -18,4 +20,11 @@ struct __kernel_sockaddr_storage {
                                 /* _SS_MAXSIZE value minus size of ss_family */
  } __attribute__ ((aligned(_K_SS_ALIGNSIZE)));  /* force desired alignment */

+struct sock_sizehint {
+       __u32   order_zero_size;
+               /* max payload size that can fit into one page in kernel */
+       __u32   cache_size;
+               /* max payload size that can fit in socket slab cache */
+};
+
  #endif /* _UAPI_LINUX_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 7e73c26..4c9cd92 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1254,6 +1254,23 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
                 v.val = sk->sk_incoming_cpu;
                 break;

+       case SO_SIZEHINT:
+       {
+               struct sock_sizehint hint;
+
+               if (len > sizeof(hint))
+                       len = sizeof(hint);
+
+               hint.order_zero_size = PAGE_SIZE -
+                       SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+               hint.cache_size =  KMALLOC_MAX_CACHE_SIZE -
+                       SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+               if (copy_to_user(optval, &hint, len))
+                       return -EFAULT;
+               goto lenout;
+       }
+
         default:
                 /* We implement the SO_SNDLOWAT etc to not be settable
                  * (1003.1g 7).
-- 
2.4.2
