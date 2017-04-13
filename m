From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 22:08:28 -0400 (EDT)
Message-ID: <20170412.220828.661268690055956936.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <0861d2c9-a5ec-f40e-b849-f6421938b357@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755271AbdDMCIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 22:08:30 -0400
In-Reply-To: <0861d2c9-a5ec-f40e-b849-f6421938b357@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 12 Apr 2017 13:54:20 -0600

> packet passed to xdp seems to be messed up

Ok, the problem is that skb->mac_len isn't set properly at this point.
That doesn't happen until __netif_receive_skb_core().

I'm also not setting xdp.data_hard_start properly.

It should work better with this small diff:

diff --git a/net/core/dev.c b/net/core/dev.c
index 9ed4569..d36ae8f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4289,6 +4289,7 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	u32 act = XDP_DROP;
 	void *orig_data;
 	int hlen, off;
+	u32 mac_len;
 
 	if (skb_linearize(skb))
 		goto do_drop;
@@ -4296,10 +4297,11 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	/* The XDP program wants to see the packet starting at the MAC
 	 * header.
 	 */
-	hlen = skb_headlen(skb) + skb->mac_len;
-	xdp.data = skb->data - skb->mac_len;
+	mac_len = skb->data - skb_mac_header(skb);
+	hlen = skb_headlen(skb) + mac_len;
+	xdp.data = skb->data - mac_len;
 	xdp.data_end = xdp.data + hlen;
-	xdp.data_hard_start = xdp.data - skb_headroom(skb);
+	xdp.data_hard_start = skb->data - skb_headroom(skb);
 	orig_data = xdp.data;
 
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
