From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH V2] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Sun, 29 Jan 2012 18:25:08 +0100
Message-ID: <20120129172508.GA14897@hell>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	Brendan Cully <brendan@cs.ubc.ca>
To: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:36740 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753162Ab2A2RZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 12:25:15 -0500
Content-Disposition: inline
In-Reply-To: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Shriram Rajagopalan | 2012-01-28 23:53:39 [-0800]:

>diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
>new file mode 100644
>index 0000000..d194cd2
>--- /dev/null
>+++ b/net/sched/sch_plug.c
>@@ -0,0 +1,161 @@
>+/*
>+ * sch_plug.c Queue traffic until an explicit release command
>+ *
>+ *             This program is free software; you can redistribute it and/or
>+ *             modify it under the terms of the GNU General Public License
>+ *             as published by the Free Software Foundation; either version
>+ *             2 of the License, or (at your option) any later version.
>+ *
>+ * The operation of the buffer is as follows:
>+ * When a checkpoint begins, a plug is inserted into the
>+ *   network queue by a netlink request (it operates by storing
>+ *   a pointer to the next packet which arrives and blocking dequeue
>+ *   when that packet is at the head of the queue).
>+ * When a checkpoint completes (the backup acknowledges receipt),
>+ *   currently-queued packets are released.
>+ * So it supports two operations, plug and unplug.
>+ */
>+
>+#include <linux/module.h>
>+#include <linux/types.h>
>+#include <linux/kernel.h>
>+#include <linux/errno.h>
>+#include <linux/netdevice.h>
>+#include <linux/skbuff.h>
>+#include <net/pkt_sched.h>
>+
>+struct plug_sched_data {
>+	u32 limit;
>+	/*
>+	 * stop points to the first packet which should not be
>+	 * delivered.  If it is NULL, plug_enqueue will set it to the
>+	 * next packet it sees.
>+	 *
>+	 * release is the last packet in the fifo that can be
>+	 * released.
>+	 */
>+	struct sk_buff *stop, *release;
>+};
>+
>+static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>+{
>+	struct plug_sched_data *q = qdisc_priv(sch);
>+
>+	if (likely(sch->qstats.backlog + skb->len <= q->limit)) {
>+		if (!q->stop)
>+			q->stop = skb;
>+		return qdisc_enqueue_tail(skb, sch);
>+	}
>+	printk(KERN_WARNING "queue reported full: %u,%u (limit=%u)\n",
>+	       sch->qstats.backlog, skb->len, q->limit);

This is not required, tc -s show will print overflows. KERN_WARNING will flood
the log.

>+	return qdisc_reshape_fail(skb, sch);
>+}
>+
>+/* dequeue doesn't actually dequeue until the release command is
>+ * received. */
>+static struct sk_buff *plug_dequeue(struct Qdisc *sch)
>+{
>+	struct plug_sched_data *q = qdisc_priv(sch);
>+	struct sk_buff *peek;
>+
>+	if (qdisc_is_throttled(sch))
>+		return NULL;
>+
>+	peek = (struct sk_buff *)((sch->q).next);
>+
>+	if (peek == q->release) {
>+		/*
>+		 * This is the tail of the last round. Release it and
>+		 * block the queue
>+		 */
>+		qdisc_throttled(sch);
>+		return NULL;
>+	}
>+
>+	return qdisc_dequeue_head(sch);
>+}
>+
>+static int plug_init(struct Qdisc *sch, struct nlattr *opt)
>+{
>+	struct plug_sched_data *q = qdisc_priv(sch);
>+
>+	if (opt == NULL) {
>+		u32 pkt_limit = qdisc_dev(sch)->tx_queue_len ? : 1;

1? A little bit small default value?

>+		q->limit = pkt_limit * psched_mtu(qdisc_dev(sch));
>+	} else {
>+		struct tc_plug_qopt *ctl = nla_data(opt);
>+
>+		if (nla_len(opt) < sizeof(*ctl))
>+			return -EINVAL;
>+
>+		q->limit = ctl->limit;
>+	}
>+
>+	printk(KERN_DEBUG "sch_plug queue loaded with limit %u\n", q->limit);
>+	qdisc_throttled(sch);
>+	return 0;
>+}
>+
>+/* Receives 3 types of messages:
>+ * TCQ_PLUG_BUFFER: Inset a plug into the queue and
>+ *  buffer any incoming packets
>+ * TCQ_PLUG_RELEASE: Dequeue packets from queue head
>+ *   to beginning of the next plug.
>+ * TCQ_PLUG_LIMIT: Increase/decrease queue size

Why not an additional, unlimited state? TCQ_PLUG_RELEASE dequeue packets until
stop pointer, but why not a complete message driven mode without the stop (e.g.
send until TCQ_PLUG_BUFFER message is received?

This would make the qdisc more generic and useable for other users.

Hagen
