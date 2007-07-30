From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH v3 -mm 4/9] netconsole: Use netif_running() in write_msg()
Date: Mon, 30 Jul 2007 08:18:21 +0530
Message-ID: <20070730024821.10828.48960.sendpatchset@enigma.security.iitk.ac.in>
References: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43486 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966077AbXG3CgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 22:36:00 -0400
In-Reply-To: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

[4/9] netconsole: Use netif_running() in write_msg()

Avoid unnecessarily disabling interrupts and calling netpoll_send_udp()
if the corresponding local interface is not up.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Matt Mackall <mpm@selenic.com>

---

 drivers/net/netconsole.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index e56aa6c..75cb761 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -75,16 +75,16 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	int frag, left;
 	unsigned long flags;
 
-	local_irq_save(flags);
-
-	for (left = len; left;) {
-		frag = min(left, MAX_PRINT_CHUNK);
-		netpoll_send_udp(&np, msg, frag);
-		msg += frag;
-		left -= frag;
+	if (netif_running(np.dev)) {
+		local_irq_save(flags);
+		for (left = len; left;) {
+			frag = min(left, MAX_PRINT_CHUNK);
+			netpoll_send_udp(&np, msg, frag);
+			msg += frag;
+			left -= frag;
+		}
+		local_irq_restore(flags);
 	}
-
-	local_irq_restore(flags);
 }
 
 static struct console netconsole = {
