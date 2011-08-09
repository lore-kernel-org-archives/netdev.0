From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] neigh: reduce arp latency
Date: Tue, 09 Aug 2011 20:15:58 +0200
Message-ID: <1312913758.2547.8.camel@edumazet-laptop>
References: <1312904434.2371.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.LFD.2.00.1108091959250.1527@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33453 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab1HISQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 14:16:03 -0400
Received: by wwf5 with SMTP id 5so251607wwf.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 11:16:02 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1108091959250.1527@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 20:06 +0300, Julian Anastasov a =C3=A9=
crit :

> 	To be correct with old NUD_INCOMPLETE logic may be we can use=20
> max(neigh->parms->retrans_time, HZ/2) here instead of HZ?
>=20

Thanks Julian a lot for reviewing, here is v2 adressing this point.

[PATCH v2 net-next] neigh: reduce arp latency

Remove the artificial HZ latency on arp resolution.

Instead of firing a timer in one jiffy (up to 10 ms if HZ=3D100), lets
send the ARP message immediately.

Before patch :

# arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
64 bytes from 192.168.20.108: icmp_seq=3D1 ttl=3D64 time=3D9.91 ms
64 bytes from 192.168.20.108: icmp_seq=3D2 ttl=3D64 time=3D0.065 ms
64 bytes from 192.168.20.108: icmp_seq=3D3 ttl=3D64 time=3D0.061 ms

After patch :

$ arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
64 bytes from 192.168.20.108: icmp_seq=3D1 ttl=3D64 time=3D0.152 ms
64 bytes from 192.168.20.108: icmp_seq=3D2 ttl=3D64 time=3D0.064 ms
64 bytes from 192.168.20.108: icmp_seq=3D3 ttl=3D64 time=3D0.074 ms

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |   40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8fab9b0..4002261 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -844,6 +844,19 @@ static void neigh_invalidate(struct neighbour *nei=
gh)
 	skb_queue_purge(&neigh->arp_queue);
 }
=20
+static void neigh_probe(struct neighbour *neigh)
+	__releases(neigh->lock)
+{
+	struct sk_buff *skb =3D skb_peek(&neigh->arp_queue);
+	/* keep skb alive even if arp_queue overflows */
+	if (skb)
+		skb =3D skb_copy(skb, GFP_ATOMIC);
+	write_unlock(&neigh->lock);
+	neigh->ops->solicit(neigh, skb);
+	atomic_inc(&neigh->probes);
+	kfree_skb(skb);
+}
+
 /* Called when a timer expires for a neighbour entry. */
=20
 static void neigh_timer_handler(unsigned long arg)
@@ -920,14 +933,7 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh_hold(neigh);
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
-		struct sk_buff *skb =3D skb_peek(&neigh->arp_queue);
-		/* keep skb alive even if arp_queue overflows */
-		if (skb)
-			skb =3D skb_copy(skb, GFP_ATOMIC);
-		write_unlock(&neigh->lock);
-		neigh->ops->solicit(neigh, skb);
-		atomic_inc(&neigh->probes);
-		kfree_skb(skb);
+		neigh_probe(neigh);
 	} else {
 out:
 		write_unlock(&neigh->lock);
@@ -942,7 +948,7 @@ out:
 int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
 	int rc;
-	unsigned long now;
+	bool immediate_probe =3D false;
=20
 	write_lock_bh(&neigh->lock);
=20
@@ -950,14 +956,16 @@ int __neigh_event_send(struct neighbour *neigh, s=
truct sk_buff *skb)
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
 		goto out_unlock_bh;
=20
-	now =3D jiffies;
-
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
 		if (neigh->parms->mcast_probes + neigh->parms->app_probes) {
+			unsigned long next, now =3D jiffies;
+
 			atomic_set(&neigh->probes, neigh->parms->ucast_probes);
 			neigh->nud_state     =3D NUD_INCOMPLETE;
-			neigh->updated =3D jiffies;
-			neigh_add_timer(neigh, now + 1);
+			neigh->updated =3D now;
+			next =3D now + max(neigh->parms->retrans_time, HZ/2);
+			neigh_add_timer(neigh, next);
+			immediate_probe =3D true;
 		} else {
 			neigh->nud_state =3D NUD_FAILED;
 			neigh->updated =3D jiffies;
@@ -989,7 +997,11 @@ int __neigh_event_send(struct neighbour *neigh, st=
ruct sk_buff *skb)
 		rc =3D 1;
 	}
 out_unlock_bh:
-	write_unlock_bh(&neigh->lock);
+	if (immediate_probe)
+		neigh_probe(neigh);
+	else
+		write_unlock(&neigh->lock);
+	local_bh_enable();
 	return rc;
 }
 EXPORT_SYMBOL(__neigh_event_send);


