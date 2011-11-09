From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] neigh: replace unres_qlen by unres_qlen_bytes
Date: Wed, 09 Nov 2011 01:14:16 +0100
Message-ID: <1320797656.26025.43.camel@edumazet-laptop>
References: <1320783085.2588.17.camel@edumazet-laptop>
	 <20111108.172448.2101648110512252549.davem@davemloft.net>
	 <1320792301.26025.21.camel@edumazet-laptop>
	 <20111108.174820.558780148839093199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:65345 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab1KIAOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 19:14:21 -0500
Received: by wwf22 with SMTP id 22so7132695wwf.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 16:14:20 -0800 (PST)
In-Reply-To: <20111108.174820.558780148839093199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 17:48 -0500, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 08 Nov 2011 23:45:01 +0100
>=20
> > Maybe we can do the same for unres_qlen, and setup a byte limit ins=
tead
> > of 3 packets limit (say 64Kbytes of truesize per destination)
>=20
> That makes sense because what typically gets blocked are initial TCP =
SYNs,
> small UDP requests, and ICMPs.

OK, here the V2 of the patch doing this.

One point not addressed yet is the removal of /proc/sys/.../unres_qlen

Not sure if we want a fallback [ I did one for the netlink part ].

[PATCH V2 net-next] neigh: replace unres_qlen by unres_qlen_bytes

unres_qlen is the number of frames we are able to queue per unresolved
neighbour. Its default value (3) was never changed and is responsible
for strange drops, especially if IP fragments are used, or multiple
sessions start in parallel. TCP initial congestion window is now bigger
than 3.

$ arp -d 192.168.20.108 ; ping -c 2 -s 8000 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 8000(8028) bytes of data.
8008 bytes from 192.168.20.108: icmp_seq=3D2 ttl=3D64 time=3D0.322 ms

--- 192.168.20.108 ping statistics ---
2 packets transmitted, 1 received, 50% packet loss, time 1001ms
rtt min/avg/max/mdev =3D 0.322/0.322/0.322/0.000 ms

Increasing unres_qlen can be dangerous, since an attacker might try to
fill many queues with many packets and consume all memory.

Switch to a bytes limit (limiting queued skbs truesize), and allow a
default limit of 64Kbytes per unresolved neighbour. This new limit seem=
s
big, but as a packet can consume 64Kbytes, it reduces the memory window
offered to attackers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    5 ++++
 include/linux/neighbour.h              |    1=20
 include/net/neighbour.h                |    3 +-
 net/atm/clip.c                         |    2 -
 net/core/neighbour.c                   |   27 +++++++++++++++++------
 net/decnet/dn_neigh.c                  |    2 -
 net/ipv4/arp.c                         |    2 -
 net/ipv6/ndisc.c                       |    2 -
 8 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index f049a1c..34b8728 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -31,6 +31,11 @@ neigh/default/gc_thresh3 - INTEGER
 	when using large numbers of interfaces and when communicating
 	with large numbers of directly-connected peers.
=20
+neigh/default/unres_qlen_bytes - INTEGER
+	The maximum number of bytes which may be used by packets
+	queued for each	unresolved address by other network layers.
+	(added in linux 3.3)
+
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
=20
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index a7003b7..b188f68 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -116,6 +116,7 @@ enum {
 	NDTPA_PROXY_DELAY,		/* u64, msecs */
 	NDTPA_PROXY_QLEN,		/* u32 */
 	NDTPA_LOCKTIME,			/* u64, msecs */
+	NDTPA_QUEUE_LENBYTES,		/* u32 */
 	__NDTPA_MAX
 };
 #define NDTPA_MAX (__NDTPA_MAX - 1)
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 2720884..7ae5acf 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -59,7 +59,7 @@ struct neigh_parms {
 	int	reachable_time;
 	int	delay_probe_time;
=20
-	int	queue_len;
+	int	queue_len_bytes;
 	int	ucast_probes;
 	int	app_probes;
 	int	mcast_probes;
@@ -99,6 +99,7 @@ struct neighbour {
 	rwlock_t		lock;
 	atomic_t		refcnt;
 	struct sk_buff_head	arp_queue;
+	unsigned int		arp_queue_len_bytes;
 	struct timer_list	timer;
 	unsigned long		used;
 	atomic_t		probes;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8523940..50ebab6 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -329,7 +329,7 @@ static struct neigh_table clip_tbl =3D {
 		.gc_staletime 		=3D 60 * HZ,
 		.reachable_time 	=3D 30 * HZ,
 		.delay_probe_time 	=3D 5 * HZ,
-		.queue_len 		=3D 3,
+		.queue_len_bytes 	=3D 64*1024,
 		.ucast_probes 		=3D 3,
 		.mcast_probes 		=3D 3,
 		.anycast_delay 		=3D 1 * HZ,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 039d51e..9a47b0a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -238,6 +238,7 @@ static void neigh_flush_dev(struct neigh_table *tbl=
, struct net_device *dev)
 				   it to safe state.
 				 */
 				skb_queue_purge(&n->arp_queue);
+				n->arp_queue_len_bytes =3D 0;
 				n->output =3D neigh_blackhole;
 				if (n->nud_state & NUD_VALID)
 					n->nud_state =3D NUD_NOARP;
@@ -702,6 +703,7 @@ void neigh_destroy(struct neighbour *neigh)
 		printk(KERN_WARNING "Impossible event.\n");
=20
 	skb_queue_purge(&neigh->arp_queue);
+	neigh->arp_queue_len_bytes =3D 0;
=20
 	dev_put(neigh->dev);
 	neigh_parms_put(neigh->parms);
@@ -842,6 +844,7 @@ static void neigh_invalidate(struct neighbour *neig=
h)
 		write_lock(&neigh->lock);
 	}
 	skb_queue_purge(&neigh->arp_queue);
+	neigh->arp_queue_len_bytes =3D 0;
 }
=20
 static void neigh_probe(struct neighbour *neigh)
@@ -980,15 +983,20 @@ int __neigh_event_send(struct neighbour *neigh, s=
truct sk_buff *skb)
=20
 	if (neigh->nud_state =3D=3D NUD_INCOMPLETE) {
 		if (skb) {
-			if (skb_queue_len(&neigh->arp_queue) >=3D
-			    neigh->parms->queue_len) {
+			while (neigh->arp_queue_len_bytes + skb->truesize >
+			       neigh->parms->queue_len_bytes) {
 				struct sk_buff *buff;
+
 				buff =3D __skb_dequeue(&neigh->arp_queue);
+				if (!buff)
+					break;
+				neigh->arp_queue_len_bytes -=3D buff->truesize;
 				kfree_skb(buff);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
 			skb_dst_force(skb);
 			__skb_queue_tail(&neigh->arp_queue, skb);
+			neigh->arp_queue_len_bytes +=3D skb->truesize;
 		}
 		rc =3D 1;
 	}
@@ -1175,6 +1183,7 @@ int neigh_update(struct neighbour *neigh, const u=
8 *lladdr, u8 new,
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
+		neigh->arp_queue_len_bytes =3D 0;
 	}
 out:
 	if (update_isrouter) {
@@ -1747,7 +1756,9 @@ static int neightbl_fill_parms(struct sk_buff *sk=
b, struct neigh_parms *parms)
 		NLA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
=20
 	NLA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
-	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len);
+	NLA_PUT_U32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes);
+	/* approximative value for deprecated QUEUE_LEN (in packets) */
+	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len_bytes / SKB_TRUESI=
ZE(ETH_FRAME_LEN));
 	NLA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
 	NLA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
 	NLA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
@@ -1974,7 +1985,11 @@ static int neightbl_set(struct sk_buff *skb, str=
uct nlmsghdr *nlh, void *arg)
=20
 			switch (i) {
 			case NDTPA_QUEUE_LEN:
-				p->queue_len =3D nla_get_u32(tbp[i]);
+				p->queue_len_bytes =3D nla_get_u32(tbp[i]) *
+						     SKB_TRUESIZE(ETH_FRAME_LEN);
+				break;
+			case NDTPA_QUEUE_LENBYTES:
+				p->queue_len_bytes =3D nla_get_u32(tbp[i]);
 				break;
 			case NDTPA_PROXY_QLEN:
 				p->proxy_qlen =3D nla_get_u32(tbp[i]);
@@ -2686,7 +2701,7 @@ static struct neigh_sysctl_table {
 			.proc_handler	=3D proc_dointvec_jiffies,
 		},
 		{
-			.procname	=3D "unres_qlen",
+			.procname	=3D "unres_qlen_bytes",
 			.maxlen		=3D sizeof(int),
 			.mode		=3D 0644,
 			.proc_handler	=3D proc_dointvec,
@@ -2785,7 +2800,7 @@ int neigh_sysctl_register(struct net_device *dev,=
 struct neigh_parms *p,
 	t->neigh_vars[4].data  =3D &p->base_reachable_time;
 	t->neigh_vars[5].data  =3D &p->delay_probe_time;
 	t->neigh_vars[6].data  =3D &p->gc_staletime;
-	t->neigh_vars[7].data  =3D &p->queue_len;
+	t->neigh_vars[7].data  =3D &p->queue_len_bytes;
 	t->neigh_vars[8].data  =3D &p->proxy_qlen;
 	t->neigh_vars[9].data  =3D &p->anycast_delay;
 	t->neigh_vars[10].data =3D &p->proxy_delay;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7f0eb08..fb8b096 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -107,7 +107,7 @@ struct neigh_table dn_neigh_table =3D {
 		.gc_staletime =3D	60 * HZ,
 		.reachable_time =3D		30 * HZ,
 		.delay_probe_time =3D	5 * HZ,
-		.queue_len =3D		3,
+		.queue_len =3D		64*1024,
 		.ucast_probes =3D	0,
 		.app_probes =3D		0,
 		.mcast_probes =3D	0,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..d732827 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -177,7 +177,7 @@ struct neigh_table arp_tbl =3D {
 		.gc_staletime		=3D 60 * HZ,
 		.reachable_time		=3D 30 * HZ,
 		.delay_probe_time	=3D 5 * HZ,
-		.queue_len		=3D 3,
+		.queue_len_bytes	=3D 64*1024,
 		.ucast_probes		=3D 3,
 		.mcast_probes		=3D 3,
 		.anycast_delay		=3D 1 * HZ,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 44e5b7f..4a20982 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -141,7 +141,7 @@ struct neigh_table nd_tbl =3D {
 		.gc_staletime		=3D 60 * HZ,
 		.reachable_time		=3D ND_REACHABLE_TIME,
 		.delay_probe_time	=3D 5 * HZ,
-		.queue_len		=3D 3,
+		.queue_len_bytes	=3D 64*1024,
 		.ucast_probes		=3D 3,
 		.mcast_probes		=3D 3,
 		.anycast_delay		=3D 1 * HZ,
