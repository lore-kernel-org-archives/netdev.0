From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Tue, 28 Jan 2014 21:42:25 +0100
Message-ID: <52E81631.50607@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:51097 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790AbaA1Um2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 15:42:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 376c7311bdb6 (net: add a temporary sanity check in skb_orphan())
leads to a BUG in can_put_echo_skb() when skb_orphan() is executed.
When skbuffs created automatically in bcm_can_tx() in softirq (netrx, timer)
and userspace context the precise timing has to be met. A sock wmem accouting
is pointless for this use case.

This patch introduces an empty skb destructor like in commit 072017b41e49
(net: sctp: Add rudimentary infrastructure to account for control chunks)
to make the cyclic transmission of CAN frames work again on real CAN
netdevices. Virtual CAN interfaces do not need skb_orphan().

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 3fc737b..82af1a5 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -237,6 +237,11 @@ static const struct file_operations bcm_proc_fops = {
 	.release	= single_release,
 };
 
+static void bcm_skb_destructor(struct sk_buff *skb)
+{
+	/* no accounting needed for bcm_can_tx() */
+}
+
 /*
  * bcm_can_tx - send the (next) CAN frame to the appropriate CAN interface
  *              of the given bcm tx op
@@ -267,6 +272,7 @@ static void bcm_can_tx(struct bcm_op *op)
 	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
 
 	/* send with loopback */
+	skb->destructor = bcm_skb_destructor;
 	skb->dev = dev;
 	skb->sk = op->sk;
 	can_send(skb, 1);
