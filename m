From: Harry Coin <hcoin@n4comm.com>
Subject: e100.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 11:43:34 -0600
Message-ID: <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <1168876836.8922.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14e.g14.rapidsite.net ([128.121.64.102]:17368 "HELO
	mail14e.g14.rapidsite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751332AbXAORnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 12:43:47 -0500
Received: from mx29.mlpsca01.us.mxservers.net (128.121.64.142)
	by mail14e.g14.rapidsite.net (RS ver 1.0.95vs) with SMTP id 0-0118403025
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 12:43:46 -0500 (EST)
To: netdev@vger.kernel.org
In-Reply-To: <1168876836.8922.1.camel@localhost.localdomain>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello from Iowa.

Below please find a fix to the Wake On Lan function in the e100.c (intel 
10/100) driver.   With the original driver distributed in kernel 2.6.18 in 
debian etch, wake on lan did not work.   This was tested on 14 dell 
optiplexes with built-in ethernet chips in a totally diskless environment 
(initramfs / pxelinux).  All operations were normal save wake on lan.

When WOL has been enabled with ethtools, the old driver assumes wrongly 
that e100_configure will be called at least once with !netif_running.  Only 
in that instance will it set the chip to notice 'magic' wol packets if the 
ethtools -s wol g has been called prior.

The old e100_down routine never does call e100_configure so that the driver 
never does  turn off the 'disable WOL magic packet' bit.
Neither does the .shutdown routine.   This fix tries to only enable the WOL 
recognition only when e100_down is called for the last time
before module unload or system shutdown, while leaving ifconfig down 
untouched.    (testing for being run in the context of dev->stop).

Notice that the hw_reset routine is called in the old e100_down, and that 
silently causes WOL to be reset.  In some attempt to avoid this debian (and 
I don't know which other sysvinit tools) added a NETDOWN define to the 
/etc/init.d/halt script, which when changed from the default=yes to 'no' 
avoids the -i option to 'halt' leaving the e100 configured.

With the below fix the default in /etc/init.d/halt is required, the define 
change is not necessary, in fact it is important that halt call down for 
wol to work.  (In the case of the old e100 driver it didn't matter either 
way, as e100_configure was never called once the driver was stopped).

Notice that the binary /sbin/halt in debain etch has a bug and in fact 
never does call ifdown, whether -i is or isn't specified.   Compiling from 
the source by hand does work.  I have submitted a bug report for this.

A further e100 fix I didn't add was for .shutdown to check whether the 
driver was down and to call e100_down if it was still up.   That added fix 
would make sure WOL would work no matter if the halt script did or didn't 
down the driver before system shutdown.    I'm not sure what the 
implications of my fix are in the context of sleep /resume.

I have also submitted the above to the e1000 group at intel privately as 
they are the 'maintainers', but this appears to be the only apropos open 
group I thought to note he here as well.

Thanks


Harry Coin
N4 Communications
Bettendorf, Iowa
Signed-off-by: Harry Coin hcoin@n4comm.com



--- drivers-orig/e100.c 2007-01-15 00:01:48.000000000 -0600
+++ drivers-fixed/e100.c        2007-01-14 23:32:08.000000000 -0600
@@ -2088,10 +2088,26 @@
  static void e100_down(struct nic *nic)
  {
-       /* wait here for poll to complete */
-       netif_poll_disable(nic->netdev);
-       netif_stop_queue(nic->netdev);
-       e100_hw_reset(nic);
+    if ((!netif_running(nic->netdev)) && (nic->flags & wol_magic)) {
+      /* if this is a device close, and not an ifdown, and wol is enabled, */
+      /* then turn off the bit disabling wol magic packet recognition on */
+      /* the chip.  Previously, WOL magic packet recognition was never */
+      /* enabled as e100_down never called e100_configure when */
+      /* nif_running was false.   So: */
+      /* This makes the e100 not only work with WOL, but */
+      /* also avoids having to edit the default NETDOWN variable */
+      /* in /etc/init.d/halt from the default 'yes' to 'no'. */
+      e100_exec_cb(nic, NULL, e100_configure);
+         /* wait here for poll to complete */
+         netif_poll_disable(nic->netdev);
+         netif_stop_queue(nic->netdev);
+      e100_disable_irq(nic);
+    } else {
+         /* wait here for poll to complete */
+         netif_poll_disable(nic->netdev);
+         netif_stop_queue(nic->netdev);
+         e100_hw_reset(nic);
+   }
         free_irq(nic->pdev->irq, nic->netdev);
         del_timer_sync(&nic->watchdog);
         netif_carrier_off(nic->netdev);
@@ -2099,6 +2115,7 @@
         e100_rx_clean_list(nic);
  }
+
  static void e100_tx_timeout(struct net_device *netdev)
  {
         struct nic *nic = netdev_priv(netdev);


