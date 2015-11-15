From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] batman-adv: Less checks in batadv_tvlv_unicast_send()
Date: Sun, 15 Nov 2015 09:45:51 +0100
Message-ID: <5648463F.3070403@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <56484502.8000206@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:65468 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbbKOIqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Nov 2015 03:46:10 -0500
In-Reply-To: <56484502.8000206@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 15 Nov 2015 09:00:42 +0100

* Let us return directly if a call of the batadv_orig_hash_find() function
  returned a null pointer.

* Omit the initialisation for the variable "skb" at the beginning.

* Replace an assignment by a call of the kfree_skb() function
  and delete the affected variable "ret" then.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/batman-adv/main.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 9e9b8f6..4eaa09a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1143,15 +1143,14 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
 	struct batadv_tvlv_hdr *tvlv_hdr;
 	struct batadv_orig_node *orig_node;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	unsigned char *tvlv_buff;
 	unsigned int tvlv_len;
 	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
-	bool ret = false;
 
 	orig_node = batadv_orig_hash_find(bat_priv, dst);
 	if (!orig_node)
-		goto out;
+		return;
 
 	tvlv_len = sizeof(*tvlv_hdr) + tvlv_value_len;
 
@@ -1180,14 +1179,10 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	tvlv_buff += sizeof(*tvlv_hdr);
 	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
-		ret = true;
-
-out:
-	if (!ret)
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
 		kfree_skb(skb);
-	if (orig_node)
-		batadv_orig_node_free_ref(orig_node);
+out:
+	batadv_orig_node_free_ref(orig_node);
 }
 
 /**
-- 
2.6.2
