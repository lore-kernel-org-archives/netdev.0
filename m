From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_tbf: handle too small burst
Date: Sat, 23 Nov 2013 12:59:20 -0800
Message-ID: <1385240360.10637.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com>
	 <1385131801.10637.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5290628F.6080604@huawei.com>
	 <1385229367.10637.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, jpirko@redhat.com,
	jhs@mojatatu.com
To: Yang Yingliang <yangyingliang@huawei.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:38015 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab3KWU7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 15:59:21 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so3188843pbb.0
        for <netdev@vger.kernel.org>; Sat, 23 Nov 2013 12:59:21 -0800 (PST)
In-Reply-To: <1385229367.10637.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a too small burst is inadvertently set on TBF, we might trigger
a bug in tbf_segment(), as 'skb' instead of 'segs' was used in a
qdisc_reshape_fail() call.

tc qdisc add dev eth0 root handle 1: tbf latency 50ms burst 1KB rate
50mbit

Fix the bug, and add a warning, as such configuration is not
going to work anyway for non GSO packets.

(For some reason, one has to use a burst >= 1520 to get a working
configuration, even with old kernels. This is a probable iproute2/tc
bug)

Based on a report and initial patch from Yang Yingliang

Fixes: e43ac79a4bc6 ("sch_tbf: segment too big GSO packets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yang Yingliang <yangyingliang@huawei.com>
---
Note : I prepared a self contained patch for the ease of stable
       submissions. We might later move skb_gso_seglen() in an
       include file.

 net/sched/sch_tbf.c |   32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 68f9859..a609005 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -21,6 +21,7 @@
 #include <net/netlink.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
+#include <net/tcp.h>
 
 
 /*	Simple Token Bucket Filter.
@@ -117,6 +118,22 @@ struct tbf_sched_data {
 };
 
 
+/*
+ * Return length of individual segments of a gso packet,
+ * including all headers (MAC, IP, TCP/UDP)
+ */
+static unsigned int skb_gso_seglen(const struct sk_buff *skb)
+{
+	unsigned int hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+		hdr_len += tcp_hdrlen(skb);
+	else
+		hdr_len += sizeof(struct udphdr);
+	return hdr_len + shinfo->gso_size;
+}
+
 /* GSO packet is too big, segment it so that tbf can transmit
  * each segment in time
  */
@@ -136,12 +153,8 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 	while (segs) {
 		nskb = segs->next;
 		segs->next = NULL;
-		if (likely(segs->len <= q->max_size)) {
-			qdisc_skb_cb(segs)->pkt_len = segs->len;
-			ret = qdisc_enqueue(segs, q->qdisc);
-		} else {
-			ret = qdisc_reshape_fail(skb, sch);
-		}
+		qdisc_skb_cb(segs)->pkt_len = segs->len;
+		ret = qdisc_enqueue(segs, q->qdisc);
 		if (ret != NET_XMIT_SUCCESS) {
 			if (net_xmit_drop_count(ret))
 				sch->qstats.drops++;
@@ -163,7 +176,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
-		if (skb_is_gso(skb))
+		if (skb_is_gso(skb) && skb_gso_seglen(skb) <= q->max_size)
 			return tbf_segment(skb, sch);
 		return qdisc_reshape_fail(skb, sch);
 	}
@@ -319,6 +332,11 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	if (max_size < 0)
 		goto done;
 
+	if (max_size < psched_mtu(qdisc_dev(sch)))
+		pr_warn_ratelimited("sch_tbf: burst %u is lower than device %s mtu (%u) !\n",
+				    max_size, qdisc_dev(sch)->name,
+				    psched_mtu(qdisc_dev(sch)));
+
 	if (q->qdisc != &noop_qdisc) {
 		err = fifo_set_limit(q->qdisc, qopt->limit);
 		if (err)
