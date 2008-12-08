From: Jan Sembera <jsembera@suse.cz>
Subject: [PATCH] ipv6: silence log messages for locally generated multicast
Date: Mon, 8 Dec 2008 13:25:57 +0100
Message-ID: <20081208122557.GB4498@alaris.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57573 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751581AbYLHMZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 07:25:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes minor annoyance during transmission of unsolicited
neighbor advertisements from userspace to multicast addresses (as
far as I can see in RFC, this is allowed and the similar functionality
for IPv4 has been in arping for a long time).

Outgoing multicast packets get reinserted into local processing as if they
are received from the network. The machine thus sees its own NA and fills
the logs with error messages. This patch removes the message if NA has been
generated locally.

Signed-off-by: Jan Sembera <jsembera@suse.cz>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1724383..d0f54d1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -912,8 +912,13 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		   is invalid, but ndisc specs say nothing
 		   about it. It could be misconfiguration, or
 		   an smart proxy agent tries to help us :-)
+
+		   We should not print the error if NA has been
+		   received from loopback - it is just our own
+		   unsolicited advertisement.
 		 */
-		ND_PRINTK1(KERN_WARNING
+		if (skb->pkt_type != PACKET_LOOPBACK)
+			ND_PRINTK1(KERN_WARNING
 			   "ICMPv6 NA: someone advertises our address on %s!\n",
 			   ifp->idev->dev->name);
 		in6_ifa_put(ifp);
