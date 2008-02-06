From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Wed, 6 Feb 2008 09:14:13 +0000
Message-ID: <20080206091413.GE4496@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local> <20080206081509.GD4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Jann Traschewski <jann@gmx.de>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:23811 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760748AbYBFJHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:07:10 -0500
Received: by nf-out-0910.google.com with SMTP id g13so672713nfb.21
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2008 01:07:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206081509.GD4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 08:15:09AM +0000, Jarek Poplawski wrote:
> On Wed, Feb 06, 2008 at 07:45:29AM +0000, Jarek Poplawski wrote:
> ...
> > From: Jann Traschewski <jann@gmx.de>
> > Subject: SMP with AX.25
...


[AX25] ax25_ds_timer: use mod_timer instead of add_timer

This patch changes current use of: init_timer(), add_timer()
and del_timer() to setup_timer() with mod_timer(), which
should be safer anyway.


Reported-by: Jann Traschewski <jann@gmx.de>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/ax25.h       |    1 +
 net/ax25/ax25_dev.c      |    2 +-
 net/ax25/ax25_ds_timer.c |   12 ++++--------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 3f0236f..717e219 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -324,6 +324,7 @@ extern void ax25_dama_on(ax25_cb *);
 extern void ax25_dama_off(ax25_cb *);
 
 /* ax25_ds_timer.c */
+extern void ax25_ds_setup_timer(ax25_dev *);
 extern void ax25_ds_set_timer(ax25_dev *);
 extern void ax25_ds_del_timer(ax25_dev *);
 extern void ax25_ds_timer(ax25_cb *);
diff --git a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
index 528c874..a7a0e0c 100644
--- a/net/ax25/ax25_dev.c
+++ b/net/ax25/ax25_dev.c
@@ -82,7 +82,7 @@ void ax25_dev_device_up(struct net_device *dev)
 	ax25_dev->values[AX25_VALUES_DS_TIMEOUT]= AX25_DEF_DS_TIMEOUT;
 
 #if defined(CONFIG_AX25_DAMA_SLAVE) || defined(CONFIG_AX25_DAMA_MASTER)
-	init_timer(&ax25_dev->dama.slave_timer);
+	ax25_ds_setup_timer(ax25_dev);
 #endif
 
 	spin_lock_bh(&ax25_dev_lock);
diff --git a/net/ax25/ax25_ds_timer.c b/net/ax25/ax25_ds_timer.c
index c4e3b02..2ce79df 100644
--- a/net/ax25/ax25_ds_timer.c
+++ b/net/ax25/ax25_ds_timer.c
@@ -40,13 +40,10 @@ static void ax25_ds_timeout(unsigned long);
  *	1/10th of a second.
  */
 
-static void ax25_ds_add_timer(ax25_dev *ax25_dev)
+void ax25_ds_setup_timer(ax25_dev *ax25_dev)
 {
-	struct timer_list *t = &ax25_dev->dama.slave_timer;
-	t->data		= (unsigned long) ax25_dev;
-	t->function	= &ax25_ds_timeout;
-	t->expires	= jiffies + HZ;
-	add_timer(t);
+	setup_timer(&ax25_dev->dama.slave_timer, ax25_ds_timeout,
+		    (unsigned long)ax25_dev);
 }
 
 void ax25_ds_del_timer(ax25_dev *ax25_dev)
@@ -60,10 +57,9 @@ void ax25_ds_set_timer(ax25_dev *ax25_dev)
 	if (ax25_dev == NULL)		/* paranoia */
 		return;
 
-	del_timer(&ax25_dev->dama.slave_timer);
 	ax25_dev->dama.slave_timeout =
 		msecs_to_jiffies(ax25_dev->values[AX25_VALUES_DS_TIMEOUT]) / 10;
-	ax25_ds_add_timer(ax25_dev);
+	mod_timer(&ax25_dev->dama.slave_timer, jiffies + HZ);
 }
 
 /*
