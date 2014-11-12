From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/4] openvswitch: actions: use skb_postpull_rcsum when possible
Date: Wed, 12 Nov 2014 15:52:27 +0100
Message-ID: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35355 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbaKLOwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 09:52:38 -0500
Received: by mail-wi0-f171.google.com with SMTP id r20so5148921wiv.10
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 06:52:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace duplicated code by calling skb_postpull_rcsum

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
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
