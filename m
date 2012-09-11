From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net-sched: sch_cbq: avoid infinite loop
Date: Wed, 12 Sep 2012 01:11:12 +0200
Message-ID: <1347405072.13103.675.camel@edumazet-glaptop>
References: <ceeee25e4588b250ce7b363afe97a489@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41722 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab2IKXLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 19:11:16 -0400
Received: by wgbdr13 with SMTP id dr13so905159wgb.1
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 16:11:14 -0700 (PDT)
In-Reply-To: <ceeee25e4588b250ce7b363afe97a489@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Its possible to setup a bad cbq configuration leading to
an infinite loop in cbq_classify()

DEV_OUT=eth0
ICMP="match ip protocol 1 0xff"
U32="protocol ip u32"
DST="match ip dst"
tc qdisc add dev $DEV_OUT root handle 1: cbq avpkt 1000 \
	bandwidth 100mbit
tc class add dev $DEV_OUT parent 1: classid 1:1 cbq \
	rate 512kbit allot 1500 prio 5 bounded isolated
tc filter add dev $DEV_OUT parent 1: prio 3 $U32 \
	$ICMP $DST 192.168.3.234 flowid 1:

Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
Tested-by: Denys Fedoryschenko <denys@visp.net.lb>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_cbq.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 6aabd77..564b9fc 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -250,10 +250,11 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			else if ((cl = defmap[res.classid & TC_PRIO_MAX]) == NULL)
 				cl = defmap[TC_PRIO_BESTEFFORT];
 
-			if (cl == NULL || cl->level >= head->level)
+			if (cl == NULL)
 				goto fallback;
 		}
-
+		if (cl->level >= head->level)
+			goto fallback;
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
