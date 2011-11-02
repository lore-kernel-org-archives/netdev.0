From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] macvlan: receive multicast with local address
Date: Wed, 2 Nov 2011 15:11:53 -0700
Message-ID: <20111102151153.028e222f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab1KBWL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 18:11:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When implementing VRRP v2 using macvlan several problems were
discovered.  VRRP is weird in that all routers participating
in a redundant group use the same virtual MAC address.
Macvlan is a natural driver to use for this but it doesn't
work.  The problem is that packets with a macvlan device's
source address are not received.

The problem is actually a regression that date back almost 2 years now.
The original problems started with:

commit 618e1b7482f7a8a4c6c6e8ccbe140e4c331df4e9
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Thu Nov 26 06:07:10 2009 +0000

    macvlan: implement bridge, VEPA and private mode
    
This patches restores the original 2.6.32 behavior. Allowing multicast
packets received with the VRRP source address to be received.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This should go to -net, and -stable (since it is a regression).

P.s: The VEPA patch also introduced another regression, it changed
the default mode from private to VEPA which also breaks application
assumptions. But changing it back after 2 years also risks also breaking
things.

--- a/drivers/net/macvlan.c	2011-11-02 13:12:52.186069720 -0700
+++ b/drivers/net/macvlan.c	2011-11-02 14:50:54.476670346 -0700
@@ -192,6 +192,13 @@ static rx_handler_result_t macvlan_handl
 			 */
 			macvlan_broadcast(skb, port, src->dev,
 					  MACVLAN_MODE_VEPA);
+		else {
+			/* forward to original port. */
+			vlan = src;
+			ret = macvlan_broadcast_one(skb, vlan, eth, 0);
+			goto out;
+		}
+
 		return RX_HANDLER_PASS;
 	}
 
