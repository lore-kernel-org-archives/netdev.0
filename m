From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 11:38:06 +0200
Message-ID: <20100805093806.GF9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34762 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759509Ab0HEJie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 05:38:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main motivation of this patch changing strcpy() to strlcpy().  
We strcpy() to copy a 48 byte buffers into a 49 byte buffers.  So at
best the last byte has leaked information, or maybe there is an
overflow?  Anyway, this patch closes the information leaks by zeroing
the memory and the calls to strlcpy() prevent overflows. 

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/sc/ioctl.c b/drivers/isdn/sc/ioctl.c
index 1081091..2655e3a 100644
--- a/drivers/isdn/sc/ioctl.c
+++ b/drivers/isdn/sc/ioctl.c
@@ -174,7 +174,7 @@ int sc_ioctl(int card, scs_ioctl *data)
 		pr_debug("%s: SCIOGETSPID: ioctl received\n",
 				sc_adapter[card]->devicename);
 
-		spid = kmalloc(SCIOC_SPIDSIZE, GFP_KERNEL);
+		spid = kzalloc(SCIOC_SPIDSIZE, GFP_KERNEL);
 		if (!spid) {
 			kfree(rcvmsg);
 			return -ENOMEM;
@@ -194,7 +194,7 @@ int sc_ioctl(int card, scs_ioctl *data)
 			kfree(rcvmsg);
 			return status;
 		}
-		strcpy(spid, rcvmsg->msg_data.byte_array);
+		strlcpy(spid, rcvmsg->msg_data.byte_array, SCIOC_SPIDSIZE);
 
 		/*
 		 * Package the switch type and send to user space
@@ -272,12 +272,12 @@ int sc_ioctl(int card, scs_ioctl *data)
 			return status;
 		}
 
-		dn = kmalloc(SCIOC_DNSIZE, GFP_KERNEL);
+		dn = kzalloc(SCIOC_DNSIZE, GFP_KERNEL);
 		if (!dn) {
 			kfree(rcvmsg);
 			return -ENOMEM;
 		}
-		strcpy(dn, rcvmsg->msg_data.byte_array);
+		strlcpy(dn, rcvmsg->msg_data.byte_array, SCIOC_DNSIZE);
 		kfree(rcvmsg);
 
 		/*
@@ -348,7 +348,7 @@ int sc_ioctl(int card, scs_ioctl *data)
 		pr_debug("%s: SCIOSTAT: ioctl received\n",
 				sc_adapter[card]->devicename);
 
-		bi = kmalloc (sizeof(boardInfo), GFP_KERNEL);
+		bi = kzalloc(sizeof(boardInfo), GFP_KERNEL);
 		if (!bi) {
 			kfree(rcvmsg);
 			return -ENOMEM;
