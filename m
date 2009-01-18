From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 18 Jan 2009 09:52:31 -0600
Message-ID: <20090118095231.2c73c448@osprey.hogchain.net>
References: <gkt97e$ti0$1@ger.gmane.org>
	<20090117194045.649f55a0@osprey.hogchain.net>
	<767752.95325.qm@web110601.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f21.google.com ([209.85.217.21]:37426 "EHLO
	mail-gx0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933064AbZARPwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 10:52:36 -0500
In-Reply-To: <767752.95325.qm@web110601.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Jan 2009 02:18:33 -0800 (PST)
Sitsofe Wheeler <sitsofe@yahoo.com> wrote:

> Hi,
> 
> 
> > From: Jay Cliburn <jcliburn@gmail.com>
> > 
> > On Sat, 17 Jan 2009 18:49:18 +0000 (UTC)
> > Sitsofe Wheeler wrote:
> > 
> > > On an ever so slightly modified 2.6.28. I think this only happens
> > > when the upstream router/switch goes out to lunch and packets are
> > > being sent. It is reproducible but only appears on a home
> > > network...
> > > 
> > > [  204.704065] ------------[ cut here ]------------
> > > [  204.704074] WARNING: at net/sched/sch_generic.c:226
> > > dev_watchdog +0x22b/0x240()
> > > [  204.704080] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
> > 
> > Please provide your complete dmesg output.
> 
> Unfortunately I only saved that snippet of the log (I can provide you
> a full dmesg but it won't be from a run where this problem occured).

I'd like to see the full dmesg that includes the warning, if you can
obtain it next time it occurs.  Meanwhile, please see if this patch
helps.

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 8571e8c..376226c 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -555,14 +555,18 @@ static void atl2_check_for_link(struct atl2_adapter *adapter)
 	atl2_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
 	spin_unlock(&adapter->stats_lock);
 
-	/* notify upper layer link down ASAP */
 	if (!(phy_data & BMSR_LSTATUS)) { /* Link Down */
-		if (netif_carrier_ok(netdev)) { /* old link state: Up */
-		printk(KERN_INFO "%s: %s NIC Link is Down\n",
-			atl2_driver_name, netdev->name);
-		adapter->link_speed = SPEED_0;
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
+		if (netif_carrier_ok(netdev)) {
+			/*
+			 * Notify the upper layer and restart the netdev
+			 * watchdog timer while we try to recover the link.
+			 */
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+			netdev->trans_start = jiffies;
+			printk(KERN_INFO "%s: %s NIC Link is Down\n",
+				atl2_driver_name, netdev->name);
+			adapter->link_speed = SPEED_0;
 		}
 	}
 	schedule_work(&adapter->link_chg_task);
