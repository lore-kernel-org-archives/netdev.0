From: Patrick McHardy <kaber@trash.net>
Subject: Re: Tc filtering: broken 802_3 classifier?
Date: Thu, 26 Jul 2007 01:58:54 +0200
Message-ID: <46A7E3BE.8090301@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329034BFCD2@orsmsx414.amr.corp.intel.com> <46A7DF75.5090609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070105020802010809020401"
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbXGYX76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 19:59:58 -0400
In-Reply-To: <46A7DF75.5090609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070105020802010809020401
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
> 
>>This is my setup.  8 bands with prio, with a priomap that is nice and
>>simple:
>>
>># tc qdisc add dev eth0 root handle 1: prio bands 8 priomap 0 0 1 1 2 2
>>3 3 4 4 5 5 6 6 7 7
>>
>>With this configuration, ICMP will default to flowid 1:1 (band 0), and
>>ssh will default to flowid 1:4 (band 3) based on TOS.  I add this filter
>>(802_3) and all traffic starts flowing into flowid 1:1 (including ssh),
>>even though it should never match:
>>
>># tc filter add dev eth0 protocol 802_3 parent 1: prio 2 u32 match u32
>>0x00000800 0x0000ffff at 12 flowid 1:6
>>
>>As soon as I remove the filter:
>>
>># tc filter del dev eth0 protocol 802_3 prio 2
>>
>>ssh flows back into flowid 1:4.  No filters of protocol ip were added,
>>only the 802.3 filter.
>>
>>I hope this is more clear as to what I'm seeing.
>
> 
> It is .. now let me think about the good explanation, it doesn't
> make sense at first :)


First of all - good catch :) This really is a bug, and one that
has existed for quite some time. Whats happening is that
tc_classify returns -1 because no filter matches, but this
is not caught in the switch statement and the !q->filter_list
condition is false. So band is set to the uninitialized value
of res.classid, and the band >= q->bands checks catches this
as invalid and uses 0. The sad thing is that this is one of
the typical constructs gcc falsely warns about for primitive
types, in this case it doesn't care. Anyway, what should
really be happening in this case is that skb->priority is
used, as without any filters.

This patch should fix it, but other qdiscs might need similar
fixes I believe. I'll look into that tommorrow.


--------------070105020802010809020401
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2d8c084..f37dd8c 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -38,22 +38,21 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
+	int err;
 
 	*qerr = NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
+		err = tc_classify(skb, q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
-		switch (tc_classify(skb, q->filter_list, &res)) {
+		switch (err) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
-
-		if (!q->filter_list ) {
-#else
-		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
 #endif
+		if (!q->filter_list || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
 			band = q->prio2band[band&TC_PRIO_MAX];

--------------070105020802010809020401--
