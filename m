From: akpm@linux-foundation.org
Subject: [patch 21/28] netconsole: Use netif_running() in write_msg()
Date: Fri, 10 Aug 2007 14:12:04 -0700
Message-ID: <200708102112.l7ALC4RO009442@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56440 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761923AbXHJVQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

Avoid unnecessarily disabling interrupts and calling netpoll_send_udp() if the
corresponding local interface is not up.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff -puN drivers/net/netconsole.c~netconsole-use-netif_running-in-write_msg drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-use-netif_running-in-write_msg
+++ a/drivers/net/netconsole.c
@@ -75,16 +75,16 @@ static void write_msg(struct console *co
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
_
