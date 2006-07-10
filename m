From: Ralf Baechle <ralf@linux-mips.org>
Subject: [BPQ] lockdep: fix false positive
Date: Mon, 10 Jul 2006 16:53:34 +0100
Message-ID: <20060710155334.GA16338@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:41141 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1422665AbWGJPxe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 11:53:34 -0400
Received: from localhost.localdomain ([127.0.0.1]:42893 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133867AbWGJPxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 16:53:32 +0100
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Molnar Ingo <mingo@elte.hu>,
	Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bpqether is encapsulating AX.25 frames into ethernet frames.  There is a
virtual bpqether device paired with each ethernet devices, so it's normal
to pass through dev_queue_xmit twice for each frame which triggers the
locking detector.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/net/hamradio/bpqether.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-net/drivers/net/hamradio/bpqether.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/bpqether.c	2006-07-09 02:47:59.000000000 +0100
+++ linux-net/drivers/net/hamradio/bpqether.c	2006-07-10 14:18:48.000000000 +0100
@@ -122,6 +122,12 @@ struct bpqdev {
 
 static LIST_HEAD(bpq_devices);
 
+/*
+ * bpqether network devices are paired with ethernet devices below them, so
+ * form a special "super class" of normal ethernet devices; split their locks
+ * off into a separate class since they always nest.
+ */
+static struct lock_class_key bpq_netdev_xmit_lock_key;
 
 /* ------------------------------------------------------------------------ */
 
@@ -528,6 +534,7 @@ static int bpq_new_device(struct net_dev
 	err = register_netdevice(ndev);
 	if (err)
 		goto error;
+	lockdep_set_class(&ndev->_xmit_lock, &bpq_netdev_xmit_lock_key);
 
 	/* List protected by RTNL */
 	list_add_rcu(&bpq->bpq_list, &bpq_devices);
