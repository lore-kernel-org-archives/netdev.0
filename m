From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Thu, 2 Oct 2008 18:38:21 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810021835390.8590@tyr.diku.dk>
References: <1222437636.7598.14.camel@localhost.localdomain>
 <48DD0A4F.6020703@trash.net>  <1222456933.2381.3.camel@localhost.localdomain>
 <48DD36D2.90103@trash.net>  <48DD37E3.9090706@trash.net>
 <1222457670.2381.8.camel@localhost.localdomain> <48DD3AD5.80800@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:33323 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753742AbYJBQiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 12:38:23 -0400
In-Reply-To: <48DD3AD5.80800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a quick fix for the bug...
Patrick promised he would do a more clean fix later ;-)

commit 356d09baea53abb7f6a6aabf2264ba104cdb9b5b
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Thu Oct 2 12:24:19 2008 +0200

     Quick fix from Patrick to solve the VLAN promisc mode bug.

      Bisect'ed BUG in VLAN promisc mode

      All other VLAN interfaces stop working, if a vlan is taken down
      (ifconfig eth1.1025 down) _while_ there is a tcpdump running on that
      interface.

      The problem is a result of promisc mode being removed on the
      real-device (eth1), when the vlan interface is taken down.  This
      should not happen as other vlan devices exists that still need
      promisc mode on the real-device (eth1).

      Need promisc mode because VLAN devices uses another ether address.

     Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4bf014e..a79daee 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -551,6 +551,8 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
  {
  	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;

+	if (!netif_running(dev))
+		return;
  	if (change & IFF_ALLMULTI)
  		dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
  	if (change & IFF_PROMISC)
