From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] fix up sysctl_tcp_mem initialization
Date: Tue, 14 Nov 2006 15:02:05 -0500
Message-ID: <455A20BD.6010508@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070007040809060904040209"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:37614 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S965257AbWKNUCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 15:02:08 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070007040809060904040209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The initial values of sysctl_tcp_mem are sometimes greater than the 
total memory in the system (particularly on SMP systems).  This patch 
ensures that tcp_mem[2] is always <= 3/4 nr_kernel_pages.

However, I wonder if we want to set this differently than the way this 
patch does it.  Depending on how far off the memory size is from a power 
of two (exactly equal to a power of two is the worst case), and if total 
memory <128M, it can be substantially less than 3/4.

   -John

--------------070007040809060904040209
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="tcp_mem_init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_mem_init.patch"

Fix up tcp_mem initiail settings to take into account the size of the
hash entries (different on SMP and non-SMP systems).

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit d4ef8c8245c0a033622ce9ba9e25d379475254f6
tree 5377b8af0bac3b92161188e7369a84e472b5acb2
parent ea55b7c31b47edf90132baea9a088da3bbe2bb5c
author John Heffner <jheffner@psc.edu> Tue, 14 Nov 2006 14:53:27 -0500
committer John Heffner <jheffner@psc.edu> Tue, 14 Nov 2006 14:53:27 -0500

 net/ipv4/tcp.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4322318..c05e8ed 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2316,9 +2316,10 @@ void __init tcp_init(void)
 		sysctl_max_syn_backlog = 128;
 	}
 
-	sysctl_tcp_mem[0] =  768 << order;
-	sysctl_tcp_mem[1] = 1024 << order;
-	sysctl_tcp_mem[2] = 1536 << order;
+	/* Allow no more than 3/4 kernel memory (usually less) allocated to TCP */
+	sysctl_tcp_mem[0] = (1536 / sizeof (struct inet_bind_hashbucket)) << order;
+	sysctl_tcp_mem[1] = sysctl_tcp_mem[0] * 4 / 3;
+	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
 
 	limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);

--------------070007040809060904040209--
