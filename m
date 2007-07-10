From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 7/9] netconsole: Use netif_running() in write_msg()
Date: Tue, 10 Jul 2007 14:49:56 +0530
Message-ID: <20070710091956.23907.61655.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56127 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762436AbXGJI5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:41 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[7/9] netconsole: Use netif_running() in write_msg()

Avoid unnecessarily disabling interrupts and calling netpoll_send_udp()
if the corresponding local interface is not up.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-10 07:26:47.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-10 07:45:51.000000000 +0530
@@ -113,16 +113,16 @@ static void write_msg(struct console *co
 	unsigned long flags;
 	struct netconsole_target *nt = &default_target;
 
-	local_irq_save(flags);
-
-	for (left = len; left;) {
-		frag = min(left, MAX_PRINT_CHUNK);
-		netpoll_send_udp(&nt->np, msg, frag);
-		msg += frag;
-		left -= frag;
+	if (netif_running(nt->np.dev)) {
+		local_irq_save(flags);
+		for (left = len; left;) {
+			frag = min(left, MAX_PRINT_CHUNK);
+			netpoll_send_udp(&nt->np, msg, frag);
+			msg += frag;
+			left -= frag;
+		}
+		local_irq_restore(flags);
 	}
-
-	local_irq_restore(flags);
 }
 
 static struct console netconsole = {
