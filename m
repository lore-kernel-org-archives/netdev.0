From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc to
 tx_queue_len zero device
Date: Thu, 03 Nov 2016 14:56:11 +0100
Message-ID: <20161103135611.28737.39840.stgit@firesoul>
References: <20161103135534.28737.37657.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751944AbcKCN4O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:56:14 -0400
In-Reply-To: <20161103135534.28737.37657.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a clear misconfiguration to attach a qdisc to a device with
tx_queue_len zero, because some qdisc's (namely, pfifo, bfifo, gred,
htb, plug and sfb) inherit/copy this value as their queue length.

Why should the kernel catch such a misconfiguration?  Because prior to
introducing the IFF_NO_QUEUE device flag, userspace found a loophole
in the qdisc config system that allowed them to achieve the equivalent
of IFF_NO_QUEUE, which is to remove the qdisc code path entirely from
a device.  The loophole on older kernels is setting tx_queue_len=0,
*prior* to device qdisc init (the config time is significant, simply
setting tx_queue_len=0 doesn't trigger the loophole).

This loophole is currently used by Docker[1] to get better performance
and scalability out of the veth device.  The Docker developers were
warned[1] that they needed to adjust the tx_queue_len if ever
attaching a qdisc.  The OpenShift project didn't remember this warning
and attached a qdisc, this were caught and fixed in[2].

[1] https://github.com/docker/libcontainer/pull/193
[2] https://github.com/openshift/origin/pull/11126

Instead of fixing every userspace program that used this loophole, and
forgot to reset the tx_queue_len, prior to attaching a qdisc.  Let's
catch the misconfiguration on the kernel side.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/sched/sch_api.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 206dc24add3a..f337f1bdd1d4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -960,6 +960,17 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
 
 	sch->handle = handle;
 
+	/* This exist to keep backward compatible with a userspace
+	 * loophole, what allowed userspace to get IFF_NO_QUEUE
+	 * facility on older kernels by setting tx_queue_len=0 (prior
+	 * to qdisc init), and then forgot to reinit tx_queue_len
+	 * before again attaching a qdisc.
+	 */
+	if ((dev->priv_flags & IFF_NO_QUEUE) && (dev->tx_queue_len == 0)) {
+		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
+		netdev_info(dev, "Caught tx_queue_len zero misconfig\n");
+	}
+
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
 		if (qdisc_is_percpu_stats(sch)) {
 			sch->cpu_bstats =
