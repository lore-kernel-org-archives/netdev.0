From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] atm: clip timer race
Date: Wed, 12 Apr 2006 15:42:14 -0700
Message-ID: <20060412154214.1dd4117d@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<E1FTjlM-00050V-00@gondolin.me.apana.org.au>
	<20060412124533.14e0c4ff@localhost.localdomain>
	<20060412200015.GA19878@gondor.apana.org.au>
	<20060412131527.71f42d58@localhost.localdomain>
	<20060412202551.GA20085@gondor.apana.org.au>
	<20060412145254.4dd21be6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50386 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932374AbWDLWmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 18:42:44 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060412145254.4dd21be6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By inspection, the clip idle timer code is racy on SMP.
Here is a safe version of timer management.
Untested, I don't have ATM hardware.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- clip.orig/net/atm/clip.c	2006-04-12 14:24:10.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-12 14:40:01.000000000 -0700
@@ -54,8 +54,6 @@
 static struct atm_vcc *atmarpd;
 static struct neigh_table clip_tbl;
 static struct timer_list idle_timer;
-static int start_timer = 1;
-
 
 static int to_atmarpd(enum atmarp_ctrl_type type,int itf,unsigned long ip)
 {
@@ -725,13 +723,8 @@
 		return -EADDRINUSE;
 	}
 
-	if (start_timer) {
-		start_timer = 0;
-		init_timer(&idle_timer);
-		idle_timer.expires = jiffies+CLIP_CHECK_INTERVAL*HZ;
-		idle_timer.function = idle_timer_check;
-		add_timer(&idle_timer);
-	}
+	mod_timer(&idle_timer, jiffies+CLIP_CHECK_INTERVAL*HZ);
+
 	atmarpd = vcc;
 	set_bit(ATM_VF_META,&vcc->flags);
 	set_bit(ATM_VF_READY,&vcc->flags);
@@ -1002,6 +995,8 @@
 	register_netdevice_notifier(&clip_dev_notifier);
 	register_inetaddr_notifier(&clip_inet_notifier);
 
+	setup_timer(&idle_timer, idle_timer_check, 0);
+
 #ifdef CONFIG_PROC_FS
 {
 	struct proc_dir_entry *p;
@@ -1029,8 +1024,7 @@
 	/* First, stop the idle timer, so it stops banging
 	 * on the table.
 	 */
-	if (start_timer == 0)
-		del_timer(&idle_timer);
+	del_timer_sync(&idle_timer);
 
 	/* Next, purge the table, so that the device
 	 * unregister loop below does not hang due to
