From: Ian Morgan <imorgan@primordial.ca>
Subject: [PATCH net] ax88179_178a: fix bonding failure
Date: Sun, 19 Oct 2014 08:05:13 -0400 (EDT)
Message-ID: <alpine.LFD.2.11.1410190801050.5282@solo.int.primordial.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:48236 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaJSMFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 08:05:20 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so3872985igc.12
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 05:05:19 -0700 (PDT)
Received: from solo.int.primordial.ca (solo.int.primordial.ca. [2001:470:b117:0:a22b:b8ff:fe46:8fcc])
        by mx.google.com with ESMTPSA id f8sm3114213iof.15.2014.10.19.05.05.18
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 19 Oct 2014 05:05:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch fixes a bug which causes the ax88179_178a driver to be
incapable of being added to a bond.

When I brought up the issue with the bonding maintainers, they indicated
that the real problem was with the NIC driver which must return zero for
success (of setting the MAC address). I see that several other NIC drivers
follow that pattern by either simply always returing zero, or by passing
through a negative (error) result while rewriting any positive return code
to zero. With that same philisophy applied to the ax88179_178a driver, it
allows it to work correctly with the bonding driver.

I believe this is suitable for queuing in -stable, as it's a small, simple,
and obvious fix that corrects a defect with no other known workaround.

This patch is against vanilla 3.17(.0).

Signed-off-by: Ian Morgan <imorgan@primordial.ca>

 drivers/net/usb/ax88179_178a.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- linux-3.17/drivers/net/usb/ax88179_178a.c.orig	2014-10-05 15:23:04.000000000 -0400
+++ linux-3.17/drivers/net/usb/ax88179_178a.c	2014-10-15 09:07:31.217810217 -0400
@@ -937,6 +937,7 @@ static int ax88179_set_mac_addr(struct n
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct sockaddr *addr = p;
+	int ret;
 
 	if (netif_running(net))
 		return -EBUSY;
@@ -946,8 +947,12 @@ static int ax88179_set_mac_addr(struct n
 	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
 
 	/* Set the MAC address */
-	return ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
+	ret = ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
 				 ETH_ALEN, net->dev_addr);
+	if (ret < 0)
+		return ret;
+
+	return 0;
 }
 
 static const struct net_device_ops ax88179_netdev_ops = {



-- 
Ian Morgan
