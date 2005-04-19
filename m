From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Fix deadlock in netconsole with no carrier
Date: Tue, 19 Apr 2005 15:53:50 +0200
Message-ID: <20050419135350.GH7715@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, mpm@selenic.com, davem@redhat.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I got a deadlock at boot with netconsole when the netword card
did not have a cable connected. This patch fixes this by limiting
the number of retries. 

Also when we run into the device spinlock dont poll all the time,
just spin.

Signed-off-by: Andi Kleen <ak@suse.de>


diff -u net/core/netpoll.c-o net/core/netpoll.c
--- net/core/netpoll.c-o	2005-03-02 08:38:32.000000000 +0100
+++ net/core/netpoll.c	2005-04-19 15:50:42.959142733 +0200
@@ -190,9 +190,10 @@
 static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
 	int status;
+	int try = 5; 
 
 repeat:
-	if(!np || !np->dev || !netif_running(np->dev)) {
+	if(try-- == 0 || !np || !np->dev || !netif_running(np->dev)) {
 		__kfree_skb(skb);
 		return;
 	}
@@ -218,6 +219,10 @@
 
 	/* transmit busy */
 	if(status) {
+		if (status == NETDEV_TX_LOCKED) {
+			try++;
+			goto repeat;
+		}
 		netpoll_poll(np);
 		goto repeat;
 	}
