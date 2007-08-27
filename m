From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/7] qeth: ungrouping a device must not be interruptible
Date: Mon, 27 Aug 2007 19:27:32 +0200
Message-ID: <20070827173059.153822000@linux.vnet.ibm.com>
References: <20070827172731.370533000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:33786 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761534AbXH0RbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 13:31:04 -0400
Content-Disposition: inline; filename=703-qeth-ungroup.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Problem:
A recovery thread must not be active when device is removed.
In qeth_remove_device() an interruptible wait operation is used
to wait until a qeth recovery thread is finished. If a user really
interrupts the ungroup operation of a qeth device while a recovery
is running, cio and qeth are out of sync (device already removed
from cio, but kept in qeth). A following module unload of qeth
results in a kernel OOPS here.

Solution:
Do not allow interruption of ungroup operation to guarantee
finishing of a potentially running qeth recovery thread.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -561,7 +561,7 @@ qeth_set_offline(struct ccwgroup_device 
 }
 
 static int
-qeth_wait_for_threads(struct qeth_card *card, unsigned long threads);
+qeth_threads_running(struct qeth_card *card, unsigned long threads);
 
 
 static void
@@ -576,8 +576,7 @@ qeth_remove_device(struct ccwgroup_devic
 	if (!card)
 		return;
 
-	if (qeth_wait_for_threads(card, 0xffffffff))
-		return;
+	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
 	if (cgdev->state == CCWGROUP_ONLINE){
 		card->use_hard_stop = 1;

-- 
