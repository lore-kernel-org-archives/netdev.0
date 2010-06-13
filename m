From: Marin Mitov <mitov@issp.bas.bg>
Subject: [REGRESSION]linux-2.6.35-rc3 in net/core/dev.c
Date: Sun, 13 Jun 2010 16:25:54 +0300
Message-ID: <201006131625.55481.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am using ssh with port redirection to log on host_at_work:

ssh -L20110:mail:110 host_at_work

With linux-2.6.35-rc3, when I telnet to localhost I get:

telnet localhost 20110
Trying 127.0.0.1...
telnet: connect to address 127.0.0.1: Connection timed out

but the connection at host_at_work stays ESTABLISHED

With older kernels at home (linux-2.6.33.4) when I telnet I have:

telnet localhost 20110
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
+OK
quit
+OK
Connection closed by foreign host.

I have seen the posting on LKML:

http://lkml.org/lkml/2010/6/13/11

and decided to revert the patch mentioned their (see bellow).
The revert solves the problem for me.

Regards

Marin Mitov

===========================================================
--- a/net/core/dev.c	2010-06-13 13:21:36.000000000 +0300
+++ b/net/core/dev.c	2010-06-13 12:39:31.000000000 +0300
@@ -2810,13 +2810,24 @@
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
 
+	/*
+	 * bonding note: skbs received on inactive slaves should only
+	 * be delivered to pkt handlers that are exact matches.  Also
+	 * the deliver_no_wcard flag will be set.  If packet handlers
+	 * are sensitive to duplicate packets these skbs will need to
+	 * be dropped at the handler.  The vlan accel path may have
+	 * already set the deliver_no_wcard flag.
+	 */
 	null_or_orig = NULL;
 	orig_dev = skb->dev;
 	master = ACCESS_ONCE(orig_dev->master);
-	if (master) {
-		if (skb_bond_should_drop(skb, master))
+	if (skb->deliver_no_wcard)
+		null_or_orig = orig_dev;
+	else if (master) {
+		if (skb_bond_should_drop(skb, master)) {
+			skb->deliver_no_wcard = 1;
 			null_or_orig = orig_dev; /* deliver only exact match */
-		else
+		} else
 			skb->dev = master;
 	}
 
