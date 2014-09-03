From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Validate frames going through the direct_xmit path
Date: Tue, 02 Sep 2014 21:23:40 -0700
Message-ID: <1409718220.26422.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
	 <1409700648.26422.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5406810A.9070900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35644 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaICEXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 00:23:42 -0400
Received: by mail-pd0-f180.google.com with SMTP id p10so10212691pdj.39
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 21:23:41 -0700 (PDT)
In-Reply-To: <5406810A.9070900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-02 at 19:46 -0700, Alexander Duyck wrote:

> Actually it looks like there are several issues.  One is the bypass
> problem which is the major issue. Another side effect of the original
> patch is that a bad frame will cause us to exit __qdisc_run prematurely
> even if other frames are still in the qdisc.

Hmm... maybe a the following would fix that ?

Also note we lack counters tracking these kind of events (dropped count)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5b261e91bdbd..e051fdf95783 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -71,9 +71,13 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 			skb = NULL;
 	} else {
 		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
+dequeue:
 			skb = q->dequeue(q);
-			if (skb)
+			if (skb) {
 				skb = validate_xmit_skb(skb, qdisc_dev(q));
+				if (!skb)
+					goto dequeue;
+			}
 		}
 	}
 
