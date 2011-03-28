From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] cxgb3: Apply interrupt coalescing settings to all queues
Date: Mon, 28 Mar 2011 13:50:41 +1100
Message-ID: <20110328135041.57cec646@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39124 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753271Ab1C1Cup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Mar 2011 22:50:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While testing the performance of different receive interrupt
coalescing settings on a single stream TCP benchmark, I noticed two
very different results. With rx-usecs=50, most of the time a
connection would hit 8280 Mbps but once in a while it would hit
9330 Mbps.

It turns out we are only applying the interrupt coalescing settings
to the first queue and whenever the rx hash would direct us onto 
that queue we ran faster.

With this patch applied and rx-usecs=50, I get 9330 Mbps
consistently.

Signed-off-by: Anton Blanchard <anton@samba.org> 
---

Index: powerpc.git/drivers/net/cxgb3/cxgb3_main.c
===================================================================
--- powerpc.git.orig/drivers/net/cxgb3/cxgb3_main.c	2011-03-28 12:36:41.775206214 +1100
+++ powerpc.git/drivers/net/cxgb3/cxgb3_main.c	2011-03-28 12:41:29.892189120 +1100
@@ -1983,14 +1983,20 @@ static int set_coalesce(struct net_devic
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	struct qset_params *qsp = &adapter->params.sge.qset[0];
-	struct sge_qset *qs = &adapter->sge.qs[0];
+	struct qset_params *qsp;
+	struct sge_qset *qs;
+	int i;
 
 	if (c->rx_coalesce_usecs * 10 > M_NEWTIMER)
 		return -EINVAL;
 
-	qsp->coalesce_usecs = c->rx_coalesce_usecs;
-	t3_update_qset_coalesce(qs, qsp);
+	for (i = 0; i < pi->nqsets; i++) {
+		qsp = &adapter->params.sge.qset[i];
+		qs = &adapter->sge.qs[i];
+		qsp->coalesce_usecs = c->rx_coalesce_usecs;
+		t3_update_qset_coalesce(qs, qsp);
+	}
+
 	return 0;
 }
 
