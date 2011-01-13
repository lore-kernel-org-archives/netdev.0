From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Even Batman should not dereference NULL pointers
Date: Thu, 13 Jan 2011 21:53:38 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101132146400.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Sven Eckelmann <sven@narfation.org>,
	"David S. Miller" <davem@davemloft.net>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:26077 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083Ab1AMUxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 15:53:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a problem in net/batman-adv/unicast.c::frag_send_skb().
dev_alloc_skb() allocates memory and may fail, thus returning NULL. If 
this happens we'll pass a NULL pointer on to skb_split() which in turn 
hands it to skb_split_inside_header() from where it gets passed to 
skb_put() that lets skb_tail_pointer() play with it and that function 
dereferences it. And thus the bat dies.

While I was at it I also moved the call to dev_alloc_skb() above the 
assignment to 'unicast_packet' since there's no reason to do that 
assignment if the memory allocation fails.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 unicast.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index dc2e28b..ee41fef 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -229,10 +229,12 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	if (!bat_priv->primary_if)
 		goto dropped;
 
-	unicast_packet = (struct unicast_packet *) skb->data;
+	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
+	if (!frag_skb)
+		goto dropped;
 
+	unicast_packet = (struct unicast_packet *) skb->data;
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
-	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
 	skb_split(skb, frag_skb, data_len / 2);
 
 	if (my_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

