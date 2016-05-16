From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fq_codel: fix memory limitation drift
Date: Sun, 15 May 2016 18:16:38 -0700
Message-ID: <1463361398.18194.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
	 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
	 <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
	 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
	 <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
	 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
	 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
	 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
	 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAA93jw4XZ1+LLX1z6wQ6DHsp4vFCS5zmMz-uku_8SBNG_KuUxA@mail.gmail.com>
	 <542135C7-D7CC-4E33-B35B-C2AD259FA5AB@gmx.de>
	 <20160506133323.0b190f47@redhat.com>
	 <D29AB9B2-D514-4D14-9A16-CFB9ECD05B17@gmx.de>
	 <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>,
	netdev <netdev@vger.kernel.org>, moeller0 <moeller0@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36053 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbcEPBQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 21:16:41 -0400
Received: by mail-pf0-f194.google.com with SMTP id g132so14266262pfb.3
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 18:16:41 -0700 (PDT)
In-Reply-To: <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

memory_usage must be decreased in dequeue_func(), not in
fq_codel_dequeue(), otherwise packets dropped by Codel algo
are missing this decrease.

Also we need to clear memory_usage in fq_codel_reset()

Fixes: 95b58430abe7 ("fq_codel: add memory limitation per queue")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq_codel.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index bb8bd9314629..6883a8971562 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -262,6 +262,7 @@ static struct sk_buff *dequeue_func(struct codel_vars *vars, void *ctx)
 	if (flow->head) {
 		skb = dequeue_head(flow);
 		q->backlogs[flow - q->flows] -= qdisc_pkt_len(skb);
+		q->memory_usage -= skb->truesize;
 		sch->q.qlen--;
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
 	}
@@ -318,7 +319,6 @@ begin:
 			list_del_init(&flow->flowchain);
 		goto begin;
 	}
-	q->memory_usage -= skb->truesize;
 	qdisc_bstats_update(sch, skb);
 	flow->deficit -= qdisc_pkt_len(skb);
 	/* We cant call qdisc_tree_reduce_backlog() if our qlen is 0,
@@ -355,6 +355,7 @@ static void fq_codel_reset(struct Qdisc *sch)
 	}
 	memset(q->backlogs, 0, q->flows_cnt * sizeof(u32));
 	sch->q.qlen = 0;
+	q->memory_usage = 0;
 }
 
 static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
