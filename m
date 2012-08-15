From: Stephen Hemminger <shemminger@vyatta.com>
Subject: RFC - document network device carrier management
Date: Wed, 15 Aug 2012 08:58:27 -0700
Message-ID: <20120815085827.2b252094@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60222 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681Ab2HOP6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2012 11:58:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since carrier handling is often done incorrectly by new device drivers
be explicit about carrier handling API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This is a meant as starting point for discussion, it's probably wrong as is.
Since this isn't code, it could be applied for 3.6 and doesn't need for net-next.


--- a/Documentation/networking/netdevices.txt	2012-06-22 08:27:46.729168196 -0700
+++ b/Documentation/networking/netdevices.txt	2012-08-15 08:56:31.120429994 -0700
@@ -45,6 +45,36 @@ drop, truncate, or pass up oversize pack
 packets is preferred.
 
 
+CARRIER
+=======
+Most network devices have an operational state that the device
+monitors. The Linux kernel uses the name "carrier" for this flag which
+is a historical reference to old modems. Carrier is reported to
+userspace via the IFF_RUNNING flag from SIOCGIFFLAGS ioctl.
+Carrier is controlled in the device driver
+by the functions netif_carrier_on and netif_carrier_off. These
+functions trigger the necessary netlink and userspace API changes;
+device drivers must not change netdevice->flags directly.
+
+The carrier defaults to ON when the device is created and registered.
+Simple devices (such as dummy) do not need to do anything.
+Ethernet style devices should:
+   * alloc_etherdev in probe routine
+   * call netif_carrier_off
+   * register network device
+   * start auto negotiation with phy in open routine
+   * call netif_carrier_on when link is up
+
+More complex RFC2863 style operational state is also possible
+but not required (see operstates.txt).
+
+The monitoring of link state is the responsibility of the network
+device driver. It can be done by polling, interrupt, or any other
+mechanism. netif_carrier_on/netif_carrier_off are atomic and can
+safely be called by an interrupt routine. Carrier events are
+managed by the linkwatch work queue and limited to one per second
+to avoid overwhelming management applications.
+
 struct net_device synchronization rules
 =======================================
 ndo_open:
