From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 73891] New: Slow Transfer Speeds though openconnect,
 Juniper SSL vpns
Date: Tue, 15 Apr 2014 00:05:15 -0400 (EDT)
Message-ID: <20140415.000515.1038932319921556258.davem@davemloft.net>
References: <20140414081824.39014bf5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaDOEFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 00:05:16 -0400
In-Reply-To: <20140414081824.39014bf5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 14 Apr 2014 08:18:24 -0700

> There was also a discussion about this on the mailing list 
> https://lkml.org/lkml/2014/4/2/317
> 
> I had time to bisect.
> # first bad commit: [53d6471cef17262d3ad1c7ce8982a234244f68ec] net: Account for
> all vlan headers in skb_mac_gso_segment

Vlad posted a fix for this today and it's in the net tree.

====================
>From 1e785f48d29a09b6cf96db7b49b6320dada332e1 Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 14 Apr 2014 17:37:26 -0400
Subject: [PATCH] net: Start with correct mac_len in skb_network_protocol

Sometimes, when the packet arrives at skb_mac_gso_segment()
its skb->mac_len already accounts for some of the mac lenght
headers in the packet.  This seems to happen when forwarding
through and OpenSSL tunnel.

When we start looking for any vlan headers in skb_network_protocol()
we seem to ignore any of the already known mac headers and start
with an ETH_HLEN.  This results in an incorrect offset, dropped
TSO frames and general slowness of the connection.

We can start counting from the known skb->mac_len
and return at least that much if all mac level headers
are known and accounted for.

Fixes: 53d6471cef17262d3ad1c7ce8982a234244f68ec (net: Account for all vlan headers in skb_mac_gso_segment)
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Daniel Borkman <dborkman@redhat.com>
Tested-by: Martin Filip <nexus+kernel@smoula.net>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 14dac06..5b3042e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2284,7 +2284,7 @@ EXPORT_SYMBOL(skb_checksum_help);
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-	int vlan_depth = ETH_HLEN;
+	int vlan_depth = skb->mac_len;
 
 	/* Tunnel gso handlers can set protocol to ethernet. */
 	if (type == htons(ETH_P_TEB)) {
-- 
1.9.0
