From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 0/7] CAN: Add new PF_CAN protocol family, try #3
Date: Fri, 22 Jun 2007 05:44:52 +0200
Message-ID: <20070622034452.28886.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:52973 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbXFVEAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 00:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

this is the third post of the patch series that adds the PF_CAN
protocol family for the Controller Area Network.

Since our last post we have changed the code quite a lot:

* Use sbk->sk and skb->pkt_type instead of skb->cb to pass loopback
  flags and originating socket down to the driver and back to the
  receiving socket.  Thanks to Patrick McHardy for pointing out our
  wrong use of sbk->cb.

* Use skb->iif instead of skb->cb to pass receiving interface from
  raw_rcv() and bcm_rcv() up to raw_recvmsg() and bcm_recvmsg().
  
* Set skb->protocol when sending CAN frames to netdevices.

* Removed struct raw_opt and struct bcm_opt and integrated these
  directly into struct raw_sock and bcm_sock resp., like most other
  proto implementations do.

* We have found and fixed race conditions between raw_bind(),
  raw_{set,get}sockopt() and raw_notifier().  This resulted in
  - complete removal of our own notifier list infrastructure in
    af_can.c.  raw.c and bcm.c now use normal netdevice notifiers.
  - removal of ro->lock spinlock.  We use lock_sock(sk) now.
  - changed deletion of dev_rcv_lists, which are now marked for
    deletion in the netdevice notifier in af_can.c and are actually
    deleted when all entries have been deleted using can_rx_unregister().

* Follow changes in 2.6.22 (e.g. ktime_t timestamps in skb).

* Removed obsolete code from vcan.c, as pointed out by Stephen Hemminger.

This patch series applies against linux-2.6.22-rc5-git5 and is derived from
Subversion revision r390 of http://svn.berlios.de/svnroot/repos/socketcan.
It can be found in the directory
http://svn.berlios.de/svnroot/repos/socketcan/trunk/patch-series/<version>.

This patch doesn't touch anything in the kernel except for the allocation
of a couple of numbers for protocol, arp hw type, and a line discipline.

Please consider this patch series for integration into your tree.

Thanks very much for your work!

Best regards,

Urs Thuermann
Oliver Hartkopp
--
