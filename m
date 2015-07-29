From: Kirill Tkhai <ktkhai@odin.com>
Subject: [PATCH] net_sched: restore "mpu xxx" handling
Date: Wed, 29 Jul 2015 14:24:55 +0300
Message-ID: <55B8B807.4030102@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, <tkhai@ya.ru>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:51355 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbbG2LZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 07:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 56b765b79 ("htb: improved accuracy at high rates")
broke the "mpu xxx" handling.

This patch restores the "mpu xxx" handling for htb:

# tc class add dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 0
# ping -f -c 1000 10.30.22.52
rtt min/avg/max/mdev = 0.156/1.881/2.454/0.175 ms, ipg/ewma 1.908/1.925 ms

# tc class change dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 1000
# ping -f -c 1000 10.30.22.52
rtt min/avg/max/mdev = 15.352/22.229/38.646/2.212 ms, pipe 3, ipg/ewma 15.999/22.609 ms

Signed-off-by: Kirill Tkhai <ktkhai@odin.com>
CC: Jesper Dangaard Brouer <brouer@redhat.com>
CC: Eric Dumazet <edumazet@google.com>
CC: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    1 +
 net/sched/sch_htb.c       |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2eab08c..0add26a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -756,6 +756,7 @@ struct psched_ratecfg {
 	u16	overhead;
 	u8	linklayer;
 	u8	shift;
+	u32	mpu;
 };
 
 static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f1acb0f..7b9f283 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -608,6 +608,9 @@ static inline void htb_accnt_tokens(struct htb_class *cl, int bytes, s64 diff)
 {
 	s64 toks = diff + cl->tokens;
 
+	if (bytes < cl->rate.mpu)
+		bytes = cl->rate.mpu;
+
 	if (toks > cl->buffer)
 		toks = cl->buffer;
 	toks -= (s64) psched_l2t_ns(&cl->rate, bytes);
@@ -621,6 +624,9 @@ static inline void htb_accnt_ctokens(struct htb_class *cl, int bytes, s64 diff)
 {
 	s64 toks = diff + cl->ctokens;
 
+	if (bytes < cl->ceil.mpu)
+		bytes = cl->ceil.mpu;
+
 	if (toks > cl->cbuffer)
 		toks = cl->cbuffer;
 	toks -= (s64) psched_l2t_ns(&cl->ceil, bytes);
@@ -1112,8 +1118,10 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	memset(&opt, 0, sizeof(opt));
 
 	psched_ratecfg_getrate(&opt.rate, &cl->rate);
+	opt.rate.mpu = cl->rate.mpu;
 	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
 	psched_ratecfg_getrate(&opt.ceil, &cl->ceil);
+	opt.ceil.mpu = cl->ceil.mpu;
 	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
@@ -1484,6 +1492,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 	psched_ratecfg_precompute(&cl->rate, &hopt->rate, rate64);
 	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, ceil64);
+	cl->rate.mpu = hopt->rate.mpu;
+	cl->ceil.mpu = hopt->ceil.mpu;
 
 	/* it used to be a nasty bug here, we have to check that node
 	 * is really leaf before changing cl->un.leaf !
