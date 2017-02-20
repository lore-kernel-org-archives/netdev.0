From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix linux/if.h userspace compilation errors
Date: Mon, 20 Feb 2017 14:58:41 +0300
Message-ID: <20170220115841.GA6846@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:59466 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751402AbdBTL6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 06:58:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include <sys/socket.h> (guarded by ifndef __KERNEL__) to fix
the following linux/if.h userspace compilation errors:

/usr/include/linux/if.h:234:19: error: field 'ifru_addr' has incomplete type
   struct sockaddr ifru_addr;
/usr/include/linux/if.h:235:19: error: field 'ifru_dstaddr' has incomplete type
   struct sockaddr ifru_dstaddr;
/usr/include/linux/if.h:236:19: error: field 'ifru_broadaddr' has incomplete type
   struct sockaddr ifru_broadaddr;
/usr/include/linux/if.h:237:19: error: field 'ifru_netmask' has incomplete type
   struct sockaddr ifru_netmask;
/usr/include/linux/if.h:238:20: error: field 'ifru_hwaddr' has incomplete type
   struct  sockaddr ifru_hwaddr;

This also fixes userspace compilation of the following uapi headers:
  linux/atmbr2684.h
  linux/gsmmux.h
  linux/if_arp.h
  linux/if_bonding.h
  linux/if_frad.h
  linux/if_pppox.h
  linux/if_tunnel.h
  linux/netdevice.h
  linux/route.h
  linux/wireless.h

As no uapi header provides a definition of struct sockaddr, inclusion
of <sys/socket.h> seems to be the most conservative and the only safe
fix available.

All current users of <linux/if.h> are very likely to be including
<sys/socket.h> already because the latter is the sole provider
of struct sockaddr definition in libc, so adding a uapi header
with a definition of struct sockaddr would create a potential
conflict with <sys/socket.h>.

Replacing struct sockaddr in the definition of struct ifreq with
a different type would create a potential incompatibility with current
users of struct ifreq who might rely on ifru_addr et al members being
of type struct sockaddr.

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/if.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1158a04..259617a 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -24,6 +24,10 @@
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/compiler.h>		/* for "__user" et al           */
 
+#ifndef __KERNEL__
+#include <sys/socket.h>			/* for struct sockaddr.		*/
+#endif
+
 #if __UAPI_DEF_IF_IFNAMSIZ
 #define	IFNAMSIZ	16
 #endif /* __UAPI_DEF_IF_IFNAMSIZ */
-- 
ldv
