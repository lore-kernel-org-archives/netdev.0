From: Ralf Baechle <ralf@linux-mips.org>
Subject: [ROSE] lockdep: fix false positive
Date: Tue, 11 Jul 2006 23:13:57 +0100
Message-ID: <20060711221357.GA5813@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:53442 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751042AbWGLJUp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 05:20:45 -0400
Received: from localhost.localdomain ([127.0.0.1]:28129 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3561304AbWGLJUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 10:20:43 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Molnar Ingo <mingo@elte.hu>,
	Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ROSE network devices are virtual network devices encapsulating ROSE
frames into AX.25 which will be sent through an AX.25 device, so form a
special "super class" of normal net devices; split their locks off into
a separate class since they always nest.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/rose/af_rose.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c	2006-07-10 01:35:09.000000000 +0100
+++ linux-net/net/rose/af_rose.c	2006-07-11 22:01:37.000000000 +0100
@@ -67,6 +67,14 @@ static struct proto_ops rose_proto_ops;
 ax25_address rose_callsign;
 
 /*
+ * ROSE network devices are virtual network devices encapsulating ROSE
+ * frames into AX.25 which will be sent through an AX.25 device, so form a
+ * special "super class" of normal net devices; split their locks off into a
+ * separate class since they always nest.
+ */
+static struct lock_class_key rose_netdev_xmit_lock_key;
+
+/*
  *	Convert a ROSE address into text.
  */
 const char *rose2asc(const rose_address *addr)
@@ -1515,6 +1523,7 @@ static int __init rose_proto_init(void)
 			free_netdev(dev);
 			goto fail;
 		}
+		lockdep_set_class(&dev->_xmit_lock, &rose_netdev_xmit_lock_key);
 		dev_rose[i] = dev;
 	}
 
