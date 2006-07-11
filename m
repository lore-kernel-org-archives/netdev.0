From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NETROM] lockdep: fix false positive
Date: Tue, 11 Jul 2006 23:11:42 +0100
Message-ID: <20060711221142.GA5721@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:53442 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751045AbWGLJUq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 05:20:46 -0400
Received: from localhost.localdomain ([127.0.0.1]:28641 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3561309AbWGLJUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 10:20:44 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Molnar Ingo <mingo@elte.hu>,
	Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NETROM network devices are virtual network devices encapsulating NETROM
frames into AX.25 which will be sent through an AX.25 device, so form a
special "super class" of normal net devices; split their locks off into a
separate class since they always nest.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/netrom/af_netrom.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c	2006-07-10 20:40:51.000000000 +0100
+++ linux-net/net/netrom/af_netrom.c	2006-07-11 22:04:04.000000000 +0100
@@ -66,6 +66,14 @@ static DEFINE_SPINLOCK(nr_list_lock);
 static const struct proto_ops nr_proto_ops;
 
 /*
+ * NETROM network devices are virtual network devices encapsulating NETROM
+ * frames into AX.25 which will be sent through an AX.25 device, so form a
+ * special "super class" of normal net devices; split their locks off into a
+ * separate class since they always nest.
+ */
+static struct lock_class_key nr_netdev_xmit_lock_key;
+
+/*
  *	Socket removal during an interrupt is now safe.
  */
 static void nr_remove_socket(struct sock *sk)
@@ -1405,6 +1413,7 @@ static int __init nr_proto_init(void)
 			free_netdev(dev);
 			goto fail;
 		}
+		lockdep_set_class(&dev->_xmit_lock, &nr_netdev_xmit_lock_key);
 		dev_nr[i] = dev;
 	}
 
