From: "Edison" <hswong3i@edin.no-ip.com>
Subject: [PATCH 1/2] tcp-lp: bug fix for oops in 2.6.18-rc6
Date: Wed, 6 Sep 2006 04:47:36 +0800
Message-ID: <000501c6d12c$880d0a40$145da8c0@edinws01>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [218.191.238.119] ([218.191.238.119]:38814 "EHLO
	edin-dc.edin.no-ip.com") by vger.kernel.org with ESMTP
	id S1422630AbWIEUrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 16:47:46 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry that the patch submited yesterday still contain a small bug.
This version have already been test for hours with BT connections. The
oops is now difficult to reproduce.

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.18-rc6/net/ipv4/tcp_lp.c linux/net/ipv4/tcp_lp.c
--- linux-2.6.18-rc6/net/ipv4/tcp_lp.c  2006-09-06 04:12:00.000000000 +0800
+++ linux/net/ipv4/tcp_lp.c     2006-09-06 04:24:07.000000000 +0800
@@ -3,13 +3,8 @@
 *
 * TCP Low Priority is a distributed algorithm whose goal is to utilize only
 *   the excess network bandwidth as compared to the ``fair share`` of
- *   bandwidth as targeted by TCP. Available from:
- *     http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
+ *   bandwidth as targeted by TCP.
 *
- * Original Author:
- *   Aleksandar Kuzmanovic <akuzma@northwestern.edu>
- *
- * See http://www-ece.rice.edu/networks/TCP-LP/ for their implementation.
 * As of 2.6.13, Linux supports pluggable congestion control algorithms.
 * Due to the limitation of the API, we take the following changes from
 * the original TCP-LP implementation:
@@ -24,11 +19,20 @@
 *   o OWD is handled in relative format, where local time stamp will in
 *     tcp_time_stamp format.
 *
- * Port from 2.4.19 to 2.6.16 as module by:
- *   Wong Hoi Sing Edison <hswong3i@gmail.com>
- *   Hung Hing Lun <hlhung3i@gmail.com>
+ * Original Author:
+ *   Aleksandar Kuzmanovic <akuzma@northwestern.edu>
+ * Available from:
+ *   http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
+ * Original implementation for 2.4.19:
+ *   http://www-ece.rice.edu/networks/TCP-LP/
+ *
+ * 2.6.x module Authors:
+ *   Wong Hoi Sing, Edison <hswong3i@gmail.com>
+ *   Hung Hing Lun, Mike <hlhung3i@gmail.com>
+ * SourceForge project page:
+ *   http://tcp-lp-mod.sourceforge.net/
 *
- * Version: $Id: tcp_lp.c,v 1.22 2006-05-02 18:18:19 hswong3i Exp $
+ * Version: $Id: tcp_lp.c,v 1.24 2006/09/05 20:22:53 hswong3i Exp $
 */

 #include <linux/config.h>
@@ -153,16 +157,19 @@ static u32 tcp_lp_remote_hz_estimator(st
       if (m < 0)
               m = -m;

-       if (rhz != 0) {
+       if (rhz > 0) {
               m -= rhz >> 6;  /* m is now error in remote HZ est */
               rhz += m;       /* 63/64 old + 1/64 new */
       } else
               rhz = m << 6;

+ out:
       /* record time for successful remote HZ calc */
-       lp->flag |= LP_VALID_RHZ;
+       if (rhz > 0)
+               lp->flag |= LP_VALID_RHZ;
+       else
+               lp->flag &= ~LP_VALID_RHZ;

- out:
       /* record reference time stamp */
       lp->remote_ref_time = tp->rx_opt.rcv_tsval;
       lp->local_ref_time = tp->rx_opt.rcv_tsecr;
@@ -333,6 +340,6 @@ static void __exit tcp_lp_unregister(voi
 module_init(tcp_lp_register);
 module_exit(tcp_lp_unregister);

-MODULE_AUTHOR("Wong Hoi Sing Edison, Hung Hing Lun");
+MODULE_AUTHOR("Wong Hoi Sing Edison, Hung Hing Lun Mike");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("TCP Low Priority");

