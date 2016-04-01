From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] vlan: pull on __vlan_insert_tag error path and fix csum correction
Date: Fri,  1 Apr 2016 11:41:03 +0200
Message-ID: <244f8d5684800cc98545932aa6851bf73f7326e2.1459503053.git.daniel@iogearbox.net>
Cc: jiri@resnulli.us, alexei.starovoitov@gmail.com, jesse@kernel.org,
	tom@herbertland.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37595 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbcDAJlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:41:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When __vlan_insert_tag() fails from skb_vlan_push() path due to the
skb_cow_head(), we need to undo the __skb_push() in the error path
as well that was done earlier to move skb->data pointer to mac header.

Moreover, I noticed that when in the non-error path the __skb_pull()
is done and the original offset to mac header was non-zero, we fixup
from a wrong skb->data offset in the checksum complete processing.

So the skb_postpush_rcsum() really needs to be done before __skb_pull()
where skb->data still points to the mac header start.

Fixes: 93515d53b133 ("net: move vlan pop/push functions into common code")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/skbuff.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d04c2d1..e561f9f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4502,13 +4502,16 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 		__skb_push(skb, offset);
 		err = __vlan_insert_tag(skb, skb->vlan_proto,
 					skb_vlan_tag_get(skb));
-		if (err)
+		if (err) {
+			__skb_pull(skb, offset);
 			return err;
+		}
+
 		skb->protocol = skb->vlan_proto;
 		skb->mac_len += VLAN_HLEN;
-		__skb_pull(skb, offset);
 
 		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
+		__skb_pull(skb, offset);
 	}
 	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
 	return 0;
-- 
1.9.3
