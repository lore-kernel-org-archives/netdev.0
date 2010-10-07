From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: speedup neigh_resolve_output()
Date: Thu, 07 Oct 2010 22:44:07 +0200
Message-ID: <1286484247.3745.91.camel@edumazet-laptop>
References: <1286456008.2912.171.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52559 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab0JGUoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 16:44:13 -0400
Received: by wwj40 with SMTP id 40so360077wwj.1
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 13:44:11 -0700 (PDT)
In-Reply-To: <1286456008.2912.171.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 14:53 +0200, Eric Dumazet a =C3=A9crit =
:

> Further improvements would need to use a seqlock instead of an rwlock=
 to
> protect neigh->ha[], to not dirty neigh too often and remove two atom=
ic
> ops.
>=20

I implemented this idea in following patch, on top on previous one.

[PATCH net-next] neigh: speedup neigh_resolve_output()

Add a seqlock in struct neighbour to protect neigh->ha[], and avoid
dirtying neighbour in stress situation (many different flows / dsts)

Dirtying takes place because of read_lock(&n->lock) and n->used writes.

Switching to a seqlock, and writing n->used only on jiffies changes
permits less dirtying.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |   16 ++++++++++++
 net/core/neighbour.c    |   47 ++++++++++++++++++++++++--------------
 net/ipv4/arp.c          |    6 +---
 net/sched/sch_teql.c    |    8 +++---
 4 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index a4538d5..f04e7a2 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -105,6 +105,7 @@ struct neighbour {
 	atomic_t		refcnt;
 	atomic_t		probes;
 	rwlock_t		lock;
+	seqlock_t		ha_lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;
 	int			(*output)(struct sk_buff *skb);
@@ -302,7 +303,10 @@ static inline void neigh_confirm(struct neighbour =
*neigh)
=20
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_=
buff *skb)
 {
-	neigh->used =3D jiffies;
+	unsigned long now =3D ACCESS_ONCE(jiffies);
+=09
+	if (neigh->used !=3D now)
+		neigh->used =3D now;
 	if (!(neigh->nud_state&(NUD_CONNECTED|NUD_DELAY|NUD_PROBE)))
 		return __neigh_event_send(neigh, skb);
 	return 0;
@@ -373,4 +377,14 @@ struct neighbour_cb {
=20
 #define NEIGH_CB(skb)	((struct neighbour_cb *)(skb)->cb)
=20
+static inline void neigh_ha_snapshot(char *dst, const struct neighbour=
 *n,
+				     const struct net_device *dev)
+{
+	unsigned int seq;
+
+	do {
+		seq =3D read_seqbegin(&n->ha_lock);
+		memcpy(dst, n->ha, dev->addr_len);
+	} while (read_seqretry(&n->ha_lock, seq));
+}
 #endif
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 53cc548..54aef9c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -294,6 +294,7 @@ static struct neighbour *neigh_alloc(struct neigh_t=
able *tbl)
=20
 	skb_queue_head_init(&n->arp_queue);
 	rwlock_init(&n->lock);
+	seqlock_init(&n->ha_lock);
 	n->updated	  =3D n->used =3D now;
 	n->nud_state	  =3D NUD_NONE;
 	n->output	  =3D neigh_blackhole;
@@ -1015,7 +1016,7 @@ out_unlock_bh:
 }
 EXPORT_SYMBOL(__neigh_event_send);
=20
-static void neigh_update_hhs(struct neighbour *neigh)
+static void neigh_update_hhs(const struct neighbour *neigh)
 {
 	struct hh_cache *hh;
 	void (*update)(struct hh_cache*, const struct net_device*, const unsi=
gned char *)
@@ -1151,7 +1152,9 @@ int neigh_update(struct neighbour *neigh, const u=
8 *lladdr, u8 new,
 	}
=20
 	if (lladdr !=3D neigh->ha) {
+		write_seqlock(&neigh->ha_lock);
 		memcpy(&neigh->ha, lladdr, dev->addr_len);
+		write_sequnlock(&neigh->ha_lock);
 		neigh_update_hhs(neigh);
 		if (!(new & NUD_CONNECTED))
 			neigh->confirmed =3D jiffies -
@@ -1214,6 +1217,7 @@ static inline bool neigh_hh_lookup(struct neighbo=
ur *n, struct dst_entry *dst,
 {
 	struct hh_cache *hh;
=20
+	smp_rmb(); /* paired with smp_wmb() in neigh_hh_init() */
 	for (hh =3D n->hh; hh; hh =3D hh->hh_next) {
 		if (hh->hh_type =3D=3D protocol) {
 			atomic_inc(&hh->hh_refcnt);
@@ -1248,8 +1252,8 @@ static void neigh_hh_init(struct neighbour *n, st=
ruct dst_entry *dst,
 		kfree(hh);
 		return;
 	}
-	read_unlock(&n->lock);
-	write_lock(&n->lock);
+
+	write_lock_bh(&n->lock);
 =09
 	/* must check if another thread already did the insert */
 	if (neigh_hh_lookup(n, dst, protocol)) {
@@ -1263,13 +1267,13 @@ static void neigh_hh_init(struct neighbour *n, =
struct dst_entry *dst,
 		hh->hh_output =3D n->ops->output;
=20
 	hh->hh_next =3D n->hh;
+	smp_wmb(); /* paired with smp_rmb() in neigh_hh_lookup() */
 	n->hh	    =3D hh;
=20
 	if (unlikely(cmpxchg(&dst->hh, NULL, hh) !=3D NULL))
 		hh_cache_put(hh);
 end:
-	write_unlock(&n->lock);
-	read_lock(&n->lock);
+	write_unlock_bh(&n->lock);
 }
=20
 /* This function can be used in contexts, where only old dev_queue_xmi=
t
@@ -1308,16 +1312,18 @@ int neigh_resolve_output(struct sk_buff *skb)
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev =3D neigh->dev;
+		unsigned int seq;
=20
-		read_lock_bh(&neigh->lock);
 		if (dev->header_ops->cache &&
 		    !dst->hh &&
 		    !(dst->flags & DST_NOCACHE))
 			neigh_hh_init(neigh, dst, dst->ops->protocol);
=20
-		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
-				      neigh->ha, NULL, skb->len);
-		read_unlock_bh(&neigh->lock);
+		do {
+			seq =3D read_seqbegin(&neigh->ha_lock);
+			err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
+					      neigh->ha, NULL, skb->len);
+		} while (read_seqretry(&neigh->ha_lock, seq));
=20
 		if (err >=3D 0)
 			rc =3D neigh->ops->queue_xmit(skb);
@@ -1344,13 +1350,16 @@ int neigh_connected_output(struct sk_buff *skb)
 	struct dst_entry *dst =3D skb_dst(skb);
 	struct neighbour *neigh =3D dst->neighbour;
 	struct net_device *dev =3D neigh->dev;
+	unsigned int seq;
=20
 	__skb_pull(skb, skb_network_offset(skb));
=20
-	read_lock_bh(&neigh->lock);
-	err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
-			      neigh->ha, NULL, skb->len);
-	read_unlock_bh(&neigh->lock);
+	do {
+		seq =3D read_seqbegin(&neigh->ha_lock);
+		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      neigh->ha, NULL, skb->len);
+	} while (read_seqretry(&neigh->ha_lock, seq));
+
 	if (err >=3D 0)
 		err =3D neigh->ops->queue_xmit(skb);
 	else {
@@ -2148,10 +2157,14 @@ static int neigh_fill_info(struct sk_buff *skb,=
 struct neighbour *neigh,
=20
 	read_lock_bh(&neigh->lock);
 	ndm->ndm_state	 =3D neigh->nud_state;
-	if ((neigh->nud_state & NUD_VALID) &&
-	    nla_put(skb, NDA_LLADDR, neigh->dev->addr_len, neigh->ha) < 0) {
-		read_unlock_bh(&neigh->lock);
-		goto nla_put_failure;
+	if (neigh->nud_state & NUD_VALID) {
+		char haddr[MAX_ADDR_LEN];
+
+		neigh_ha_snapshot(haddr, neigh, neigh->dev);
+		if (nla_put(skb, NDA_LLADDR, neigh->dev->addr_len, haddr) < 0) {
+			read_unlock_bh(&neigh->lock);
+			goto nla_put_failure;
+		}
 	}
=20
 	ci.ndm_used	 =3D jiffies_to_clock_t(now - neigh->used);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f353095..d8e540c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -502,10 +502,8 @@ int arp_find(unsigned char *haddr, struct sk_buff =
*skb)
=20
 	if (n) {
 		n->used =3D jiffies;
-		if (n->nud_state&NUD_VALID || neigh_event_send(n, skb) =3D=3D 0) {
-			read_lock_bh(&n->lock);
-			memcpy(haddr, n->ha, dev->addr_len);
-			read_unlock_bh(&n->lock);
+		if (n->nud_state & NUD_VALID || neigh_event_send(n, skb) =3D=3D 0) {
+			neigh_ha_snapshot(haddr, n, dev);
 			neigh_release(n);
 			return 0;
 		}
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index feaabc1..401af95 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -241,11 +241,11 @@ __teql_resolve(struct sk_buff *skb, struct sk_buf=
f *skb_res, struct net_device *
 	}
 	if (neigh_event_send(n, skb_res) =3D=3D 0) {
 		int err;
+		char haddr[MAX_ADDR_LEN];
=20
-		read_lock(&n->lock);
-		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
-				      n->ha, NULL, skb->len);
-		read_unlock(&n->lock);
+		neigh_ha_snapshot(haddr, n, dev);
+		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol), haddr,
+				      NULL, skb->len);
=20
 		if (err < 0) {
 			neigh_release(n);


