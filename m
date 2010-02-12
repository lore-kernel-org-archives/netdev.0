From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-2.6] net: bug fix for vlan + gro issue
Date: Fri, 12 Feb 2010 11:04:53 +0530
Message-ID: <20100212053451.GA23351@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ajit Khaparde <ajitk@serverengines.com>,
	netdev <netdev@vger.kernel.org>
To: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:41092 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab0BLFfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 00:35:06 -0500
Received: by gxk24 with SMTP id 24so2005039gxk.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2010 21:35:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Traffic doesn't start on a vlan interface when gro is enabled.
Even the tcp handshake was not taking place.
This is because, the eth_type_trans() call before the netif_receive_skb()
in napi_frags_finish() resets the skb->dev to napi->dev from the previously
set vlan netdev interface. This causes the ip_route_input() to drop the
incoming packet considering it as a packet coming from a martian source.

I could repro this on 2.6.32.7 (stable) and 2.6.33-rc7.
With this fix, the traffic starts and the test runs fine. Please review.

Alternatively:
Previously the skb->dev was updated by the driver and I don't know
why it has to be set in eth_type_trans. May be removing that from
eth_type_trans() and expecting the caller to set the skb->dev could be
an alternative fix.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 net/core/dev.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index be9924f..16aac06 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2761,7 +2761,10 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:
-		skb->protocol = eth_type_trans(skb, napi->dev);
+		if (skb->vlan_tci)
+			skb->protocol = eth_type_trans(skb, skb->dev);
+		else
+			skb->protocol = eth_type_trans(skb, napi->dev);
 
 		if (ret == GRO_HELD)
 			skb_gro_pull(skb, -ETH_HLEN);
-- 
1.6.3.3

