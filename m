From: Stefan Rompf <stefan@loplof.de>
Subject: Repost: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 12 Jul 2006 00:15:17 +0200
Message-ID: <200607120015.17735.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <200607071145.09325.stefan@loplof.de> <44AE2FCC.6020207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natklopstock.rzone.de ([81.169.145.174]:55521 "EHLO
	natklopstock.rzone.de") by vger.kernel.org with ESMTP
	id S932192AbWGKWMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 18:12:36 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AE2FCC.6020207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VLAN devices did not get registered as admin up in 2.6.16 and IMHO also
not in 2.6.17. So update patch description.

Ok,

the following patch should fix the problem. Patrick, can you give it a
try? As the bug did not affect me through my testing, I want to be sure it
works now. This is stuff for 2.6.18 and 2.6.17-stable.

Stefan


[VLAN]: Fix link state propagation

When the queue of the underlying device is stopped at initialization time
or the device is marked "not present", the state will be propagated to the
vlan device and never change. Based on an analysis by Patrick McHardy.

Signed-off-by: Stefan Rompf <stefan@loplof.de>

--- linux-2.6.17/net/8021q/vlan.c.orig	2006-07-07 13:00:56.000000000 +0200
+++ linux-2.6.17/net/8021q/vlan.c	2006-07-11 23:20:32.000000000 +0200
@@ -67,10 +67,6 @@ static struct packet_type vlan_packet_ty
 	.func = vlan_skb_recv, /* VLAN receive method */
 };
 
-/* Bits of netdev state that are propagated from real device to virtual */
-#define VLAN_LINK_STATE_MASK \
-	((1<<__LINK_STATE_PRESENT)|(1<<__LINK_STATE_NOCARRIER)|(1<<__LINK_STATE_DORMANT))
-
 /* End of global variables definitions. */
 
 /*
@@ -470,7 +466,9 @@ static struct net_device *register_vlan_
 	new_dev->flags = real_dev->flags;
 	new_dev->flags &= ~IFF_UP;
 
-	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
+	new_dev->state = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
+					     (1<<__LINK_STATE_DORMANT))) |
+			 (1<<__LINK_STATE_PRESENT); 
 
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
