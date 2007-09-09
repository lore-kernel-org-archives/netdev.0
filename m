From: Chris Rankin <rankincj@yahoo.com>
Subject: ne driver crashes when unloaded in 2.6.22.6
Date: Sun, 9 Sep 2007 20:46:14 +0100 (BST)
Message-ID: <311869.99402.qm@web52909.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52909.mail.re2.yahoo.com ([206.190.49.19]:26593 "HELO
	web52909.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751592AbXIITwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 15:52:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

While trying to get my NE2000 ISA card working with NetworkManager and Linux 2.6.22.6, I
discovered that the ne module will cause the kernel to oops when it is unloaded. The problem is
that the module's clean-up function tries to unregister a platform driver unconditionally,
although the platform driver may never have been registered in the first place. I have created a
patch which seems to work OK. The idea behind the patch is to de-initialise the unregistered
ne_driver structure to the point where the unregister function will abort without error:

--- drivers/net/ne.c.orig       2007-07-21 17:00:52.000000000 +0100
+++ drivers/net/ne.c    2007-09-09 20:04:28.000000000 +0100
@@ -272,6 +272,7 @@
                                pnp_device_detach(idev);
                                return -ENXIO;
                        }
+                       SET_NETDEV_DEV(dev, &idev->dev);
                        ei_status.priv = (unsigned long)idev;
                        break;
                }
@@ -827,6 +828,7 @@
                free_netdev(dev);
                return err;
        }
+       SET_NETDEV_DEV(dev, &pdev->dev);
        platform_set_drvdata(pdev, dev);
        return 0;
 }
@@ -909,11 +911,14 @@
 is at boot) and so the probe will get confused by any other 8390 cards.
 ISA device autoprobes on a running machine are not recommended anyway. */
 
int __init init_module(void)
 {
        int this_dev, found = 0;
        int plat_found = !ne_init();
 
+       if ( !plat_found )
+               ne_driver.driver.bus = NULL;
+
        for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
                struct net_device *dev = alloc_ei_netdev();
                if (!dev)

The patch also contains a few SET_NETDEV_DEV() statements, which I am hoping will help these
network cards work with NetworkManager. This isn't a complete solution because it still doesn't
address the non-PnP ISA case. However, I think it's a start... At the moment, my eth device
appears in /sys/class/net but is also completely ignored by lshal.

Cheers,
Chris



      ___________________________________________________________ 
Want ideas for reducing your carbon footprint? Visit Yahoo! For Good  http://uk.promotions.yahoo.com/forgood/environment.html
