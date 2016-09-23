From: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
Subject: [PATCH 1/3] fq.h: Port memory limit mechanism from fq_codel
Date: Fri, 23 Sep 2016 21:59:09 +0200
Message-ID: <20160923195911.4572-2-toke@toke.dk>
References: <20160923195911.4572-1-toke@toke.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
To: make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160923195911.4572-1-toke-LJ9M9ZcSy1A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The reusable fairness queueing implementation (fq.h) lacks the memory
usage limit that the fq_codel qdisc has. This means that small
devices (e.g. WiFi routers) can run out of memory when flooded with a
large number of packets. This ports the memory limit feature from
fq_codel to fq.h.

Signed-off-by: Toke H=C3=B8iland-J=C3=B8rgensen <toke-LJ9M9ZcSy1A@public.gmane.org>
---
 include/net/fq.h      | 3 +++
 include/net/fq_impl.h | 7 ++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/net/fq.h b/include/net/fq.h
index 268b490..6d8521a 100644
--- a/include/net/fq.h
+++ b/include/net/fq.h
@@ -72,9 +72,12 @@ struct fq {
 	u32 flows_cnt;
 	u32 perturbation;
 	u32 limit;
+	u32 memory_limit;
+	u32 memory_usage;
 	u32 quantum;
 	u32 backlog;
 	u32 overlimit;
+	u32 overmemory;
 	u32 collisions;
 };
=20
diff --git a/include/net/fq_impl.h b/include/net/fq_impl.h
index 163f3ed..4e6131c 100644
--- a/include/net/fq_impl.h
+++ b/include/net/fq_impl.h
@@ -29,6 +29,7 @@ static struct sk_buff *fq_flow_dequeue(struct fq *fq,
 	tin->backlog_packets--;
 	flow->backlog -=3D skb->len;
 	fq->backlog--;
+	fq->memory_usage -=3D skb->truesize;
=20
 	if (flow->backlog =3D=3D 0) {
 		list_del_init(&flow->backlogchain);
@@ -154,6 +155,7 @@ static void fq_tin_enqueue(struct fq *fq,
 	flow->backlog +=3D skb->len;
 	tin->backlog_bytes +=3D skb->len;
 	tin->backlog_packets++;
+	fq->memory_usage +=3D skb->truesize;
 	fq->backlog++;
=20
 	fq_recalc_backlog(fq, tin, flow);
@@ -166,7 +168,7 @@ static void fq_tin_enqueue(struct fq *fq,
=20
 	__skb_queue_tail(&flow->queue, skb);
=20
-	if (fq->backlog > fq->limit) {
+	if (fq->backlog > fq->limit || fq->memory_usage > fq->memory_limit) {
 		flow =3D list_first_entry_or_null(&fq->backlogs,
 						struct fq_flow,
 						backlogchain);
@@ -181,6 +183,8 @@ static void fq_tin_enqueue(struct fq *fq,
=20
 		flow->tin->overlimit++;
 		fq->overlimit++;
+		if (fq->memory_usage > fq->memory_limit)
+			fq->overmemory++;
 	}
 }
=20
@@ -251,6 +255,7 @@ static int fq_init(struct fq *fq, int flows_cnt)
 	fq->perturbation =3D prandom_u32();
 	fq->quantum =3D 300;
 	fq->limit =3D 8192;
+	fq->memory_limit =3D 16 << 20; /* 16 MBytes */
=20
 	fq->flows =3D kcalloc(fq->flows_cnt, sizeof(fq->flows[0]), GFP_KERNEL);
 	if (!fq->flows)
--=20
2.9.3
