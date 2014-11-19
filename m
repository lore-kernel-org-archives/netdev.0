From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 1/9] openvswitch: actions: use skb_postpull_rcsum when possible
Date: Wed, 19 Nov 2014 14:04:55 +0100
Message-ID: <1416402303-25341-2-git-send-email-jiri@resnulli.us>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59485 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbaKSNFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:05:08 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so792961wgh.3
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 05:05:07 -0800 (PST)
In-Reply-To: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace duplicated code by calling skb_postpull_rcsum

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 394efa6..749a301 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -175,10 +175,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	if (unlikely(err))
 		return err;
 
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_sub(skb->csum,
-				     csum_partial(skb_mpls_header(skb),
-						  MPLS_HLEN, 0));
+	skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
 
 	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
 		skb->mac_len);
@@ -230,9 +227,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 	if (unlikely(err))
 		return err;
 
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
-					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
+	skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
 
 	vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
 	*current_tci = vhdr->h_vlan_TCI;
-- 
1.9.3
