From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix qdisc_create on stab error handling
Date: Tue, 15 Sep 2009 20:46:51 +0200
Message-ID: <20090915184651.GA8373@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:56191 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZIOSq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 14:46:58 -0400
Received: by fg-out-1718.google.com with SMTP id 22so961006fge.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 11:47:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If qdisc_get_stab returns error in qdisc_create there is skipped qdisc
ops->destroy, which is necessary because it's after ops->init at the
moment, so memory leaks are quite probable.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_api.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 692d9a4..329be0c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -804,7 +804,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			stab = qdisc_get_stab(tca[TCA_STAB]);
 			if (IS_ERR(stab)) {
 				err = PTR_ERR(stab);
-				goto err_out3;
+				goto err_out4;
 			}
 			sch->stab = stab;
 		}
@@ -833,7 +833,6 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		return sch;
 	}
 err_out3:
-	qdisc_put_stab(sch->stab);
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
 err_out2:
@@ -847,6 +846,7 @@ err_out4:
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
 	 */
+	qdisc_put_stab(sch->stab);
 	if (ops->destroy)
 		ops->destroy(sch);
 	goto err_out3;
