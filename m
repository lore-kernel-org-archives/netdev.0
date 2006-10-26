From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 26 Oct 2006 03:21:10 +0200
Message-ID: <45400D86.70406@trash.net>
References: <20061025220406.GA5413@devicescape.com> <453FF357.6060007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42738 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965251AbWJZBVP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 21:21:15 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <453FF357.6060007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> David Kimdon wrote:
> 
>>wme.c needs a generic fifo qdisc for each hardware queue.  Switch 
>>wme.c to use the generic fifo qdisc in net/sched/sch_fifo.c.  This allows
>>removal of net/d80211/fifo_qdisc.c which isn't particularily tied to
>>IEEE 802.11 in any way.
>>
>>-#define CHILD_QDISC_OPS pfifo_qdisc_ops
>>-
>> static inline int WLAN_FC_IS_QOS_DATA(u16 fc)
>> {
>> 	return (fc & 0x8C) == 0x88;
>>@@ -433,7 +431,7 @@ static int wme_qdiscop_init(struct Qdisc
>> 	/* create child queues */
>> 	for (i = 0; i < queues; i++) {
>> 		skb_queue_head_init(&q->requeued[i]);
>>-		q->queues[i] = qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS);
>>+		q->queues[i] = qdisc_create_dflt(qd->dev, &pfifo_qdisc_ops);
>> 		if (q->queues[i] == 0) {
>> 			q->queues[i] = &noop_qdisc;
>> 			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
>>Index: wireless-dev/net/d80211/Kconfig
>>===================================================================
>>--- wireless-dev.orig/net/d80211/Kconfig
>>+++ wireless-dev/net/d80211/Kconfig
>>@@ -3,6 +3,7 @@ config D80211
>> 	select CRYPTO
>> 	select CRYPTO_ARC4
>> 	select CRYPTO_AES
>>+	select NET_SCHED
> 
> 
> 
> pfifo_fast is available even without CONFIG_NET_SCHED, maybe
> thats a better choice to avoid unnecessary bloat.

BTW, I noticed a few bugs while looking at the qdisc handling in
wireless-dev:

- wme_qdiscop_enqueue doesn't increment q.qlen for packets queued
  to q->requeued[], which might cause upper layer code to stop
  dequeueing if q.qlen reaches zero.

- classify_1d doesn't care about tc_classify return values.
  tc_classify may decide to steal packets, drop them, etc. In case
  of stolen packets this causes use-after-free, otherwise just
  malfunctions.

- classify_1d returns res.class if it is != -1, which can never happen
  (except with an empty classifier list because of the explicit
  initialization, but you should check the return code) since ->get()
  and ->bind_tcf() both return 0 for invalid classes and the classid
  otherwise. There's also an off-by-one, classids start at one, so it
  should return res.class - 1 (or better res.classid - 1, which is
  meant to be a numerical identifier).

- wme_discop_destroy leaks classifier module references and memory
  when destroying classifiers, it should use tcf_destroy()

Considering that it is possibly and may be desirable to attach a
different qdisc than the built-in multiband qdisc, it might also
make sense to split the 80211 specific classification in a seperate
classifier module to allow simple classification of management traffic
with other qdiscs.

