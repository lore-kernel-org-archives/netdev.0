From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] tcp_mem initialization
Date: Wed, 14 Mar 2007 17:25:22 -0400
Message-ID: <45F86842.8040305@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070501040803020901050209"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:61707 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbXCNVZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 17:25:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070501040803020901050209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The current tcp_mem initialization gives values that are really too 
small for systems with ~256-768 MB of memory, and also for systems with 
larger page sizes (ia64).  This patch gives an alternate method of 
initialization that doesn't depend on the cache allocation functions, 
but I think should still provide a nice curve that gives a smaller 
fraction of total memory with small-memory systems, while maintaining 
the same upper bound (pressure at 1/2, max as 3/4) on larger memory systems.

   -John


--------------070501040803020901050209
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="tcp_mem_init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_mem_init.patch"

Change tcp_mem initialization function.  The fraction of total memory is now
a continuous function of memory size, and independent of page size.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit a4461a36efb376bf01399cfd6f1ad15dc89a8794
tree 23b2fb9da52b45de8008fc7ea6bb8c10e3a3724b
parent 8b9909ded6922c33c221b105b26917780cfa497d
author John Heffner <jheffner@psc.edu> Wed, 14 Mar 2007 17:15:06 -0400
committer John Heffner <jheffner@psc.edu> Wed, 14 Mar 2007 17:15:06 -0400

 net/ipv4/tcp.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 74c4d10..3834b10 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2458,11 +2458,18 @@ void __init tcp_init(void)
 		sysctl_max_syn_backlog = 128;
 	}
 
-	/* Allow no more than 3/4 kernel memory (usually less) allocated to TCP */
-	sysctl_tcp_mem[0] = (1536 / sizeof (struct inet_bind_hashbucket)) << order;
-	sysctl_tcp_mem[1] = sysctl_tcp_mem[0] * 4 / 3;
+	/* Set the pressure threshold to be a fraction of global memory that
+	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
+	 * memory, with a floor of 128 pages.
+	 */
+	limit = min(nr_all_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = max(limit, 128UL);
+	sysctl_tcp_mem[0] = limit / 4 * 3;
+	sysctl_tcp_mem[1] = limit;
 	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
 
+	/* Set per-socket limits to no more than 1/128 the pressure threshold */
 	limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);
 

--------------070501040803020901050209--
