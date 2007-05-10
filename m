From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Fix dev->qdisc race for NETDEV_TX_LOCKED case
Date: Thu, 10 May 2007 11:42:28 +0200
Message-ID: <20070510094228.GG521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49102 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbXEJJmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 05:42:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When transmit fails with NETDEV_TX_LOCKED the skb is requeued
to dev->qdisc again. The dev->qdisc pointer is protected by
the queue lock which needs to be dropped when attempting to
transmit and acquired again before requeing. The problem is
that qdisc_restart() fetches the dev->qdisc pointer once and
stores it in the `q' variable which is invalidated when
dropping the queue_lock, therefore the variable needs to be
refreshed before requeueing.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/sched/sch_generic.c
===================================================================
--- net-2.6.orig/net/sched/sch_generic.c	2007-05-10 11:32:18.000000000 +0200
+++ net-2.6/net/sched/sch_generic.c	2007-05-10 11:34:37.000000000 +0200
@@ -139,6 +139,7 @@ static inline int qdisc_restart(struct n
 				}
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
+					q = dev->qdisc;
 					goto collision;
 				}
 			}
