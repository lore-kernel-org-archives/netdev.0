From: roy.qing.li@gmail.com
Subject: [PATCH] 8021q: fix a potential memory leak
Date: Wed, 18 Jun 2014 13:46:02 +0800
Message-ID: <1403070362-29664-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:55621 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbaFRFpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 01:45:52 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so361057pbc.20
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 22:45:52 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ir10sm1292908pbc.59.2014.06.17.22.45.49
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 22:45:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

skb_cow called in vlan_reorder_header does not free the skb when it failed,
and vlan_reorder_header returns NULL to reset original skb when it is called
in vlan_untag, lead to a memory leak.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/8021q/vlan_core.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 9012b1c..75d4277 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -114,8 +114,11 @@ EXPORT_SYMBOL(vlan_dev_vlan_proto);
 
 static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
-	if (skb_cow(skb, skb_headroom(skb)) < 0)
+	if (skb_cow(skb, skb_headroom(skb)) < 0) {
+		kfree_skb(skb);
 		return NULL;
+	}
+
 	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
 	skb->mac_header += VLAN_HLEN;
 	return skb;
-- 
1.7.10.4
