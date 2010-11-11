From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [e1000e] BUG triggered in blink path
Date: Thu, 11 Nov 2010 11:17:39 +0100
Message-ID: <20101111101738.GA2972@mail.eitzenberger.org>
References: <20101109083954.GB11829@mail.eitzenberger.org> <alpine.WNT.2.00.1011101030130.14720@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:54206 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab0KKKRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 05:17:41 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1011101030130.14720@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jesse,

I've attached the patch against net-next-2.6.  Please check if it's ok
for you.  I checked e1000, igb and ixgbe as well, they don't have that
problem.

 /holger

> > After taking a look I think this may be caused by initializing
> > adapter->led_blink_task several times in e1000_phys_id(), while possibly
> > led_blink_task is running:
> > 
> > 	if ((hw->phy.type == e1000_phy_ife) ||
> > 	    (hw->mac.type == e1000_pchlan) ||
> > 	    (hw->mac.type == e1000_82574)) {
> > 		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
> > 		if (!adapter->blink_timer.function) {
> > 
> > I can't reproduce it after moving it inside the following if block,
> > but I'm not quite sure if this catches all races in there.  Especially
> > the msleep_interruptible() may be too optimistic because it may
> > actually not wait long enough.  Someone with more knowledge of the
> > driver should take a look.
> 
> thanks for your investigation and troubleshooting.  I don't think it is 
> correct at all to be calling INIT_WORK more than once.  In fact the 
> INIT_WORK should just be moved into probe, and then e1000_phys_id should 
> just do schedule_work.
> 
> 

--envbJBWh7q8WU6mo
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: inline; filename="x.diff"

e1000e: fix double initialization in blink path

The kernel goes BUG() at the time 'ethtool -p eth0 3' comes
back, which is due to adapter->led_blink_task initialized
several times.  At the time it is still running this results
in a corrupted task_list of the associated workqueue.

The fix is to move the workqueue initialization to the
probe function instead.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/drivers/net/e1000e/ethtool.c
===================================================================
--- net-next-2.6.orig/drivers/net/e1000e/ethtool.c	2010-11-11 10:57:28.000000000 +0100
+++ net-next-2.6/drivers/net/e1000e/ethtool.c	2010-11-11 11:02:21.000000000 +0100
@@ -1860,7 +1860,7 @@
 /* bit defines for adapter->led_status */
 #define E1000_LED_ON		0
 
-static void e1000e_led_blink_task(struct work_struct *work)
+void e1000e_led_blink_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
 	                                struct e1000_adapter, led_blink_task);
@@ -1892,7 +1892,6 @@
 	    (hw->mac.type == e1000_pch2lan) ||
 	    (hw->mac.type == e1000_82583) ||
 	    (hw->mac.type == e1000_82574)) {
-		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function =
Index: net-next-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- net-next-2.6.orig/drivers/net/e1000e/netdev.c	2010-11-11 10:57:28.000000000 +0100
+++ net-next-2.6/drivers/net/e1000e/netdev.c	2010-11-11 11:01:17.000000000 +0100
@@ -5864,6 +5864,7 @@
 	INIT_WORK(&adapter->downshift_task, e1000e_downshift_workaround);
 	INIT_WORK(&adapter->update_phy_task, e1000e_update_phy_task);
 	INIT_WORK(&adapter->print_hang_task, e1000_print_hw_hang);
+	INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
Index: net-next-2.6/drivers/net/e1000e/e1000.h
===================================================================
--- net-next-2.6.orig/drivers/net/e1000e/e1000.h	2010-11-11 10:57:28.000000000 +0100
+++ net-next-2.6/drivers/net/e1000e/e1000.h	2010-11-11 11:01:57.000000000 +0100
@@ -482,6 +482,7 @@
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
 extern void e1000e_set_ethtool_ops(struct net_device *netdev);
+extern void e1000e_led_blink_task(struct work_struct *work);
 
 extern int e1000e_up(struct e1000_adapter *adapter);
 extern void e1000e_down(struct e1000_adapter *adapter);

--envbJBWh7q8WU6mo--
