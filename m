From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Tue, 17 Mar 2009 18:02:03 +0800
Message-ID: <20090317100203.GA23396@gondor.apana.org.au>
References: <20090316132240.GA18413@gondor.apana.org.au> <20090317093724.GA5743@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42635 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753012AbZCQKCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:02:14 -0400
Content-Disposition: inline
In-Reply-To: <20090317093724.GA5743@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2009 at 09:37:24AM +0000, Jarek Poplawski wrote:
>
> Probably I miss something, but you seem to assume here this skb will
> be taken by netpoll later. But if it's not active (trapped) vlan
> packet will be passed as "normal"?

Good point.  I'll see if this stuff can be simplified further,
but for now, let's go for the obvious fix.

gro: Fix vlan/netpoll check again

Jarek Poplawski pointed out that my previous fix is broken for
VLAN+netpoll as if netpoll is enabled we'd end up in the normal
receive path instead of the VLAN receive path.

This patch fixes it by calling the VLAN receive hook.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6227248..654e45f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -79,9 +79,6 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 {
 	struct sk_buff *p;
 
-	if (netpoll_rx_on(skb))
-		return GRO_NORMAL;
-
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
@@ -107,6 +104,9 @@ drop:
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		     unsigned int vlan_tci, struct sk_buff *skb)
 {
+	if (netpoll_rx_on(skb))
+		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
+
 	skb_gro_reset_offset(skb);
 
 	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
@@ -121,6 +121,9 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb)
 		return NET_RX_DROP;
 
+	if (netpoll_rx_on(skb))
+		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
+
 	return napi_frags_finish(napi, skb,
 				 vlan_gro_common(napi, grp, vlan_tci, skb));
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
