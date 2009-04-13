From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Normalise skb before bypassing GRO on netpoll VLAN path
Date: Mon, 13 Apr 2009 22:41:01 +0800
Message-ID: <20090413144101.GA17575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58418 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751567AbZDMOlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 10:41:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Normalise skb before bypassing GRO on netpoll VLAN path

When we detect netpoll RX on the GRO VLAN path we bail out and
call the normal VLAN receive handler.  However, the packet needs
to be normalised by calling eth_type_trans since that's what the
normal path expects (normally the GRO path does the fixup).

This patch adds the necessary call to vlan_gro_frags.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 654e45f..c67fe6f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -121,8 +121,10 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb)
 		return NET_RX_DROP;
 
-	if (netpoll_rx_on(skb))
+	if (netpoll_rx_on(skb)) {
+		skb->protocol = eth_type_trans(skb, skb->dev);
 		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
+	}
 
 	return napi_frags_finish(napi, skb,
 				 vlan_gro_common(napi, grp, vlan_tci, skb));

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
