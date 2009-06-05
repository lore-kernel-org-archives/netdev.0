From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: tun netns BUG()
Date: Fri, 05 Jun 2009 16:24:29 -0700
Message-ID: <m1ljo61cya.fsf@fess.ebiederm.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
	<m17hzr7a0o.fsf@fess.ebiederm.org>
	<1244191328.3751.111.camel@macbook.infradead.org>
	<1244193463.3751.129.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53132 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbZFEXYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 19:24:30 -0400
In-Reply-To: <1244193463.3751.129.camel@macbook.infradead.org> (David Woodhouse's message of "Fri\, 05 Jun 2009 10\:17\:43 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The patch below fixes the one bug I know of in with just my changes
applied.  I don't think it fixes everything with Herberts changes.

I expect some of this will need to be moved to release to fix the
select problem on 2.6.30-rc8.

Eric


From: Eric W. Biederman <ebiederm@aristanetworks.com>
Subject: [PATCH] tun: Fix unregister race

It is possible for tun_chr_close to race with dellink on the
a tun device.  In which case if __tun_get runs before dellink
but dellink runs before tun_chr_close calls unregister_netdevice
we will attempt to unregister the netdevice after it is already
gone.  

The two cases are already serialized on the rtnl_lock, so I have
gone for the cheap simple fix of moving rtnl_lock to cover __tun_get
in tun_chr_close.  Eliminating the possibility of the tun device
being unregistered between __tun_get and unregister_netdevice in
tun_chr_close.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---

--- linux-2.6.28.x86_64-old/drivers/net/tun.c	2009-05-06 15:01:56.000000000 -0700
+++ linux-2.6.28.x86_64/drivers/net/tun.c	2009-05-06 15:10:09.000000000 -0700
@@ -1194,21 +1194,22 @@
 static int tun_chr_close(struct inode *inode, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun;
 
 
+	rtnl_lock();
+	tun = __tun_get(tfile);
 	if (tun) {
 		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
 
-		rtnl_lock();
 		__tun_detach(tun);
 
 		/* If desireable, unregister the netdevice. */
 		if (!(tun->flags & TUN_PERSIST))
 			unregister_netdevice(tun->dev);
 
-		rtnl_unlock();
 	}
+	rtnl_unlock();
 
 	put_net(tfile->net);
 	kfree(tfile);

