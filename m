From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Thu, 21 Apr 2011 20:47:48 +0200
Message-ID: <20110421184748.GD23756@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Benjamin Poirier <benjamin.poirier@polymtl.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60170 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779Ab1DUSrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 14:47:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.3ad bonding inside a bridge is broken again. Originally fixed by
43aa1920117801fe9ae3d1fad886b62511e09bee, the bug was re-introduced by
1e253c3b8a1aeed51eef6fc366812f219b97de65.

LACP frames must not have their skb->dev changed by the bridging hook.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1514,6 +1514,11 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
 	}
 
+	/* prevent bridging code from mangling and forwarding LACP frames */
+	if (bond->params.mode == BOND_MODE_8023AD &&
+	    skb->protocol == htons(ETH_P_SLOW))
+		return RX_HANDLER_PASS;
+
 	return RX_HANDLER_ANOTHER;
 }
 
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

