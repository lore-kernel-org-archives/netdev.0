From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Bug#708995: iptables firewall is dropping GRO'd packets
Date: Tue, 21 May 2013 14:55:02 +0200
Message-ID: <20130521125502.GA7374@minipsycho.brq.redhat.com>
References: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
 <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
 <1369097605.3301.203.camel@edumazet-glaptop>
 <1369101790.3301.206.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>, 708995@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:41320 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3EUMzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 08:55:07 -0400
Received: by mail-wg0-f48.google.com with SMTP id f11so324834wgh.3
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 05:55:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1369101790.3301.206.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 21, 2013 at 04:03:10AM CEST, eric.dumazet@gmail.com wrote:
>On Mon, 2013-05-20 at 17:53 -0700, Eric Dumazet wrote:
>> On Tue, 2013-05-21 at 01:28 +0100, Ben Hutchings wrote:
>> > I'm seeing packet loss when forwarding from a LAN to PPP, whenever GRO
>> > kicks in on the LAN interface.
>> > 
>> > On Mon, 2013-05-20 at 05:48 +0100, Ben Hutchings wrote:
>> > [...]
>> > > The Windows system is connected to the LAN interface (int0).  Turning
>> > > off GRO on this interface works around the problem.  But since GRO is
>> > > on by default, it clearly ought to work properly with iptables.
>> > > 
>> > > I'll try to work out where the drops are occurring, but the
>> > > perf net_dropmonitor script is also broken...
>> > [...]
>> > 
>> > I've fixed that script and now I can see that it's not iptables but
>> > tbf_enqueue() that is dropping the GRO'd packets.  I do traffic-shaping
>> > on the PPP link like this:
>> > 
>> > tc qdisc replace dev ppp0 root tbf rate 420kbit latency 50ms burst 1540
>> > 
>> > The local TCP will never generate an skb larger than the burst size
>> > because it knows the PPP interface can't do GSO or TSO.  And the wifi
>> > network doesn't seem to be fast enough for GRO to have much of an
>> > effect.  But a peer on the wired network can trigger GRO and this
>> > produces an skb that exceeds the burst size.
>> > 
>> > Is this a bug in sch_tbf, or should I accept it as a limitation?  It
>> > seems like it should do GSO on entry to the queue if necessary.
>> > 
>> 
>> This has been discussed on netdev this year.
>> 
>> Jiri Pirko was working on this. 
>> 
>> (thread :  tbf: take into account gso skbs)
>
>I have tested the following (net-next) patch

This is looking good to me. On my test machine it makes tbf work correctly
with gso packets.
I worked on similar patch (enqueue path) myself some time ago but I got
distracted by other tasks.

Do you plan to submit this patch?


>
>diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>index c8388f3..a132620 100644
>--- a/net/sched/sch_tbf.c
>+++ b/net/sched/sch_tbf.c
>@@ -116,14 +116,50 @@ struct tbf_sched_data {
> 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
> };
> 
>+
>+static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch, struct Qdisc *child)
>+{
>+	struct sk_buff *segs, *nskb;
>+	netdev_features_t features = netif_skb_features(skb);
>+	int ret, nb;
>+
>+	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
>+
>+	if (IS_ERR_OR_NULL(segs))
>+		return qdisc_reshape_fail(skb, sch);
>+
>+	nb = 0;
>+	while (segs) {
>+		nskb = segs->next;
>+		segs->next = NULL;
>+		qdisc_skb_cb(segs)->pkt_len = segs->len;
>+
>+		ret = qdisc_enqueue(segs, child);
>+		if (ret != NET_XMIT_SUCCESS) {
>+			if (net_xmit_drop_count(ret))
>+				sch->qstats.drops++;
>+		} else {
>+			nb++;
>+		}
>+		segs = nskb;
>+	}
>+	sch->q.qlen += nb;
>+	if (nb > 1)
>+		qdisc_tree_decrease_qlen(sch, 1 - nb);
>+	consume_skb(skb);
>+	return nb > 0 ? NET_XMIT_SUCCESS : NET_XMIT_DROP;
>+}
>+
> static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> {
> 	struct tbf_sched_data *q = qdisc_priv(sch);
> 	int ret;
> 
>-	if (qdisc_pkt_len(skb) > q->max_size)
>+	if (qdisc_pkt_len(skb) > q->max_size) {
>+		if (skb_is_gso(skb))
>+			return tbf_segment(skb, sch, q->qdisc);
> 		return qdisc_reshape_fail(skb, sch);
>-
>+	}
> 	ret = qdisc_enqueue(skb, q->qdisc);
> 	if (ret != NET_XMIT_SUCCESS) {
> 		if (net_xmit_drop_count(ret))
>
>
>
