From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 1/3] batman-adv: Calculate extra tail size based on queued fragments
Date: Sat, 20 Dec 2014 13:48:55 +0100
Message-ID: <1419079737-31107-2-git-send-email-sven@narfation.org>
References: <1419079737-31107-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:58306 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbaLTM61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:58:27 -0500
In-Reply-To: <1419079737-31107-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fragmentation code was replaced in 610bfc6bc99bc83680d190ebc69359a0=
5fc7f605
("batman-adv: Receive fragmented packets and merge"). The new code prov=
ided a
mostly unused parameter skb for the merging function. It is used inside=
 the
function to calculate the additionally needed skb tailroom. But instead=
 of
increasing its own tailroom, it is only increasing the tailroom of the =
first
queued skb. This is not correct in some situations because the first qu=
eued
entry can be a different one than the parameter.

An observed problem was:

1. packet with size 104, total_size 1464, fragno 1 was received
   - packet is queued
2. packet with size 1400, total_size 1464, fragno 0 was received
   - packet is queued at the end of the list
3. enough data was received and can be given to the merge function
   (1464 =3D=3D (1400 - 20) + (104 - 20))
   - merge functions gets 1400 byte large packet as skb argument
4. merge function gets first entry in queue (104 byte)
   - stored as skb_out
5. merge function calculates the required extra tail as total_size - sk=
b->len
   - pskb_expand_head tail of skb_out with 64 bytes
6. merge function tries to squeeze the extra 1380 bytes from the second=
 queued
   skb (1400 byte aka skb parameter) in the 64 extra tail bytes of skb_=
out

Instead calculate the extra required tail bytes for skb_out also using =
skb_out
instead of using the parameter skb. The skb parameter is only used to g=
et the
total_size from the last received packet. This is also the total_size u=
sed to
decide that all fragments were received.

Reported-by: Philipp Psurek <philipp.psurek@gmail.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
---
Problem is in the kernel since v3.13 and may be important for the stabl=
e tree.

 net/batman-adv/fragmentation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index fc1835c..8af3461 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -251,7 +251,7 @@ batadv_frag_merge_packets(struct hlist_head *chain,=
 struct sk_buff *skb)
 	kfree(entry);
=20
 	/* Make room for the rest of the fragments. */
-	if (pskb_expand_head(skb_out, 0, size - skb->len, GFP_ATOMIC) < 0) {
+	if (pskb_expand_head(skb_out, 0, size - skb_out->len, GFP_ATOMIC) < 0=
) {
 		kfree_skb(skb_out);
 		skb_out =3D NULL;
 		goto free;
--=20
2.1.4
