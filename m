From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: fix lockdep issue in __neigh_event_send
Date: Mon, 19 Sep 2011 12:12:58 -0700
Message-ID: <1316459578-23413-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	MuraliRaja Muniraju <muralira@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33215 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756654Ab1ISTNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 15:13:23 -0400
Received: by yxl31 with SMTP id 31so387835yxl.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 12:13:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

skb's should be freed once neigh->lock is no longer held.

Google-Bug-Id: 4561441
Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
CC: MuraliRaja Muniraju <muralira@google.com>
---
 net/core/neighbour.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4002261..53d034a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -949,6 +949,7 @@ int __neigh_event_send(struct neighbour *neigh, str=
uct sk_buff *skb)
 {
 	int rc;
 	bool immediate_probe =3D false;
+	struct sk_buff *buff_to_free =3D NULL;
=20
 	write_lock_bh(&neigh->lock);
=20
@@ -969,10 +970,10 @@ int __neigh_event_send(struct neighbour *neigh, s=
truct sk_buff *skb)
 		} else {
 			neigh->nud_state =3D NUD_FAILED;
 			neigh->updated =3D jiffies;
-			write_unlock_bh(&neigh->lock);
=20
-			kfree_skb(skb);
-			return 1;
+			buff_to_free =3D skb;
+			rc =3D 1;
+			goto out_unlock_bh;
 		}
 	} else if (neigh->nud_state & NUD_STALE) {
 		NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
@@ -986,9 +987,7 @@ int __neigh_event_send(struct neighbour *neigh, str=
uct sk_buff *skb)
 		if (skb) {
 			if (skb_queue_len(&neigh->arp_queue) >=3D
 			    neigh->parms->queue_len) {
-				struct sk_buff *buff;
-				buff =3D __skb_dequeue(&neigh->arp_queue);
-				kfree_skb(buff);
+				buff_to_free =3D __skb_dequeue(&neigh->arp_queue);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
 			skb_dst_force(skb);
@@ -1002,6 +1001,7 @@ out_unlock_bh:
 	else
 		write_unlock(&neigh->lock);
 	local_bh_enable();
+	kfree_skb(buff_to_free);
 	return rc;
 }
 EXPORT_SYMBOL(__neigh_event_send);
--=20
1.7.3.1
