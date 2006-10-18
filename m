From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] bridge: call eth_type_trans() in br_pass_frame_up()
Date: Wed, 18 Oct 2006 11:14:45 +0200
Message-ID: <20061018091445.GB18850@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbillman@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:40124 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932142AbWJRJOr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 05:14:47 -0400
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've been seeing a failure to reply to incoming ARP packets on a bridge
interface until after the first few packets have been transmitted over
that interface, and the patch below seems to fix the issue, the 'issue'
being that the incoming ARP packets are marked with PACKET_OTHERHOST,
and there not being anything to set that back to PACKET_HOST even if
the destination MAC address matches the bridge interface's MAC address.

If this looks good, I'll prepare a proper commit message.


cheers,
Lennert

Signed-off-by: Tom Billman <tbillman@gmail.com>
Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

--- linux-2.6.19-rc2.orig/net/bridge/br_input.c	2006-10-18 11:11:08.000000000 +0200
+++ linux-2.6.19-rc2/net/bridge/br_input.c	2006-10-18 11:10:08.000000000 +0200
@@ -32,6 +32,9 @@
 	indev = skb->dev;
 	skb->dev = br->dev;
 
+	skb_push(skb, ETH_HLEN);
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		netif_receive_skb);
 }
