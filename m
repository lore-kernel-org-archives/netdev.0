From: David Miller <davem@davemloft.net>
Subject: Re: cassini driver and IPv6
Date: Wed, 21 May 2008 17:09:27 -0700 (PDT)
Message-ID: <20080521.170927.54789076.davem@davemloft.net>
References: <4377F74A.8090707@davidmonro.net>
	<20051114.214848.83997631.davem@davemloft.net>
	<47D4C552.5050704@davidmonro.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, asun@darksunrising.com
To: davidm@davidmonro.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52482
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759588AbYEVAJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:09:32 -0400
In-Reply-To: <47D4C552.5050704@davidmonro.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Monro <davidm@davidmonro.net>
Date: Mon, 10 Mar 2008 15:51:22 +1030

> I've spent a while looking at the packet parser stuff but I have only a 
> vague idea what it is doing and am certainly not in a position to debug 
> it. My current solution is simply to only do the checksumming stuff at 
> the bottom of cas_rx_process_pkt if ntohs(skb->protocol) == 0x0800 (ie, 
> IPv4), else set skb->csum to CHECKSUM_NONE, which is kinda dirty. If 
> someone with a non-saturn cassini can confirm that they don't get hw 
> csum errors with ipv6, then I'd have to assume a saturn-only hardware 
> bug and could wrap it with (cp->cas_flags & CAS_FLAG_SATURN) as well.
> 
> Does this seem reasonable?

Sorry for letting this sit for so long.

It's better to get this working using your suggested workaround
for the time being, so I'll push the following fix upstream.

BTW, the cassini chips (as well as several other pices of
sun hardware) are fully documented at:

	http://wikis.sun.com/display/FOSSdocs

Thanks.

cassini: Only use chip checksum for ipv4 packets.

According to David Monro, at least with Natsemi Saturn chips the
cassini driver has some trouble with ipv6 checksums.

Until we have more information about what's going on here, only
use the chip checksums for ipv4.

This workaround was suggested and tested by David.

Update version and release date.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 93e1363..83768df 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -142,8 +142,8 @@
 
 #define DRV_MODULE_NAME		"cassini"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5"
-#define DRV_MODULE_RELDATE	"4 Jan 2008"
+#define DRV_MODULE_VERSION	"1.6"
+#define DRV_MODULE_RELDATE	"21 May 2008"
 
 #define CAS_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -2136,9 +2136,12 @@ end_copy_pkt:
 		if (addr)
 			cas_page_unmap(addr);
 	}
-	skb->csum = csum_unfold(~csum);
-	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->protocol = eth_type_trans(skb, cp->dev);
+	if (skb->protocol == htons(ETH_P_IP)) {
+		skb->csum = csum_unfold(~csum);
+		skb->ip_summed = CHECKSUM_COMPLETE;
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
 	return len;
 }
 
-- 
1.5.5.1.308.g1fbb5

