From: "Tarr, Stephen F" <Stephen.Tarr@xerox.com>
Subject: IPv6 and link state transitions
Date: Fri, 14 Nov 2008 14:59:27 -0800
Message-ID: <78EAC2D97114034EB62AAA10FCC2510608047D83@USA7061MS01.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wbmler5.mail.xerox.com ([13.13.138.230]:51079 "EHLO
	wbmler5.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbYKNXOE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 18:14:04 -0500
Received: from wbmlir2.mail.xerox.com (wbmlir2.mail.xerox.com [13.131.8.222])
	by wbmler5.mail.xerox.com (8.14.2/8.13.8) with ESMTP id mAEMxWF3027871
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 17:59:32 -0500
Received: from wbmlir2.mail.xerox.com (localhost [127.0.0.1])
	by wbmlir2.mail.xerox.com (8.14.2/8.13.6) with ESMTP id mAEMxThF000824
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 17:59:29 -0500
Received: from USA7061GW002.na.xerox.net (usa7061gw002.na.xerox.net [13.151.210.15])
	by wbmlir2.mail.xerox.com (8.14.2/8.13.6) with ESMTP id mAEMxSm8000819
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 17:59:29 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using 2.6.27.4 on a powerpc with the gianfar Ethernet driver
and an MII PHY.  If I boot the system with the Ethernet cable
disconnected, wait 30 seconds or so, then plug in the cable, the
interface comes up but I don't see the expected IPv6 DAD probe
for the link-local address.

Adding some printfs in addrconf.c shows a NETDEV_UP when the
interface is initialized but no NETDEV_CHANGE when the link comes
up.  The transition is detected by the phy driver but filtered out
by the test-and-clear in netif_carrier_on because
(dev->state & NOCARRIER) is already clear.

With Brian Haley's patch to force a link state transition at
startup, the behavior gets even more interesting.  In that case,
I see the initial NETDEV_UP and an immediate NETDEV_CHANGE/link
down.  When the cable's connected, I see a NETDEV_CHANGE/link up
followed by an immediate MLDv2 announcement and a DAD probe.
(These were apparently queued up by the NETDEV_UP event, but
held off by the Ethernet driver.)  After the initialization
timeout, I see the expected DAD probe, router solicitation and
so on.

This patch to the gianfar driver fixes the problem, but only for
that driver.  A better approach might be to set the initial link
state in the phy driver, but I'd appreciate some suggestions for
how and where to do that.

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3bc19b7..46566ba 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -533,6 +533,9 @@ static int init_phy(struct net_device *dev)
        char phy_id[BUS_ID_SIZE];
        phy_interface_t interface;

+       // assume link down until phy reports otherwise
+       set_bit(__LINK_STATE_NOCARRIER, &dev->state);
+
        priv->oldlink = 0;
        priv->oldspeed = 0;
        priv->oldduplex = -1;


There's a related problem if the cable is disconnected and
reconnected (perhaps to a different network).  In that case,
addrconf assumes that the previously autoconfigured addresses
are still valid, at least until it receives a router advertisement
on the new network.  The following patch against 2.6.27.4 is an
attempt to fix that problem, pick up the logic of Brian's patch,
and streamline the handling of NETDEV_UP and NETDEV_CHANGE.  The
significant logic change is the call to addrconf_ifdown when the
link goes away.  Again, I'd appreciate suggestions for a better
way to do this:

--- a/net/ipv6/addrconf.c       2008-11-13 23:38:16.178646603 -0800
+++ b/net/ipv6/addrconf.c       2008-11-13 23:38:40.986501970 -0800
@@ -2468,46 +2468,36 @@
        case NETDEV_UP:
        case NETDEV_CHANGE:
                if (dev->flags & IFF_SLAVE)
                        break;

-               if (event == NETDEV_UP) {
-                       if (!addrconf_qdisc_ok(dev)) {
-                               /* device is not ready yet. */
-                               printk(KERN_INFO
-                                       "ADDRCONF(NETDEV_UP): %s: "
-                                       "link is not ready\n",
-                                       dev->name);
-                               break;
-                       }
-
-                       if (!idev && dev->mtu >= IPV6_MIN_MTU)
-                               idev = ipv6_add_dev(dev);
-
-                       if (idev)
-                               idev->if_flags |= IF_READY;
-               } else {
-                       if (!addrconf_qdisc_ok(dev)) {
-                               /* device is still not ready. */
-                               break;
-                       }
-
-                       if (idev) {
-                               if (idev->if_flags & IF_READY) {
-                                       /* device is already configured.
*/
-                                       break;
-                               }
-                               idev->if_flags |= IF_READY;
-                       }
-
-                       printk(KERN_INFO
-                                       "ADDRCONF(NETDEV_CHANGE): %s: "
-                                       "link becomes ready\n",
-                                       dev->name);
-
-                       run_pending = 1;
-               }
+               if (!addrconf_qdisc_ok(dev)) {
+                       /* device is not ready. */
+                       printk(KERN_INFO
+                               "ADDRCONF(%s): %s: link is down\n",
+                               (event == NETDEV_UP)
+                                       ? "NETDEV_UP" : "NETDEV_CHANGE",
+                               dev->name);
+                       if (event == NETDEV_CHANGE) {
+                           addrconf_ifdown(dev, 1);
+                       }
+                       break;
+               }
+
+               printk(KERN_INFO
+                       "ADDRCONF(%s): %s: link is up\n",
+                       (event == NETDEV_UP)
+                               ? "NETDEV_UP" : "NETDEV_CHANGE",
+                       dev->name);
+
+               if (!idev && dev->mtu >= IPV6_MIN_MTU)
+                       idev = ipv6_add_dev(dev);
+
+               if (idev && !(idev->if_flags & IF_READY)) {
+                       idev->if_flags |= IF_READY;
+                       run_pending = 1;
+               }

                switch(dev->type) {
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
                case ARPHRD_SIT:
                        addrconf_sit_config(dev);



-Steve Tarr
