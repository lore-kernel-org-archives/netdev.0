From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH][NET_SCHED] Make HTB scheduler work with TSO.
Date: Tue, 12 Jun 2007 16:53:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.63.0706121647280.4120@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: ranjitm@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:57866 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbXFLXxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 19:53:44 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l5CNrcDj008833
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 16:53:38 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the HTB scheduler does not correctly account for TSO packets 
which causes large inaccuracies in the bandwidth control when using TSO.
This patch allows the HTB scheduler to work with TSO enabled devices.

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 035788c..e872724 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -153,15 +153,12 @@ #endif
  				/* of un.leaf originals should be done. */
  };

-/* TODO: maybe compute rate when size is too large .. or drop ? */
  static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
  			   int size)
  {
  	int slot = size >> rate->rate.cell_log;
-	if (slot > 255) {
-		cl->xstats.giants++;
-		slot = 255;
-	}
+	if (slot > 255)
+		return (rate->data[255]*(slot >> 8) + rate->data[slot & 0xFF]);
  	return rate->data[slot];
  }

@@ -634,13 +631,14 @@ #endif
  		cl->qstats.drops++;
  		return NET_XMIT_DROP;
  	} else {
-		cl->bstats.packets++;
+		cl->bstats.packets +=
+			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
  		cl->bstats.bytes += skb->len;
  		htb_activate(q, cl);
  	}

  	sch->q.qlen++;
-	sch->bstats.packets++;
+	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
  	sch->bstats.bytes += skb->len;
  	return NET_XMIT_SUCCESS;
  }
@@ -717,8 +715,9 @@ #endif
   * In such case we remove class from event queue first.
   */
  static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
-			     int level, int bytes)
+			     int level, struct sk_buff *skb)
  {
+	int bytes = skb->len;
  	long toks, diff;
  	enum htb_cmode old_mode;

@@ -753,13 +752,15 @@ #define HTB_ACCNT(T,B,R) toks = diff + c
  #ifdef HTB_RATECM
  		/* update rate counters */
  		cl->sum_bytes += bytes;
-		cl->sum_packets++;
+		cl->sum_packets += skb_is_gso(skb)?
+				skb_shinfo(skb)->gso_segs:1;
  #endif

  		/* update byte stats except for leaves which are already updated */
  		if (cl->level) {
  			cl->bstats.bytes += bytes;
-			cl->bstats.packets++;
+			cl->bstats.packets += skb_is_gso(skb)?
+					skb_shinfo(skb)->gso_segs:1;
  		}
  		cl = cl->parent;
  	}
@@ -943,7 +944,7 @@ next:
  		   gives us slightly better performance */
  		if (!cl->un.leaf.q->q.qlen)
  			htb_deactivate(q, cl);
-		htb_charge_class(q, cl, level, skb->len);
+		htb_charge_class(q, cl, level, skb);
  	}
  	return skb;
  }

