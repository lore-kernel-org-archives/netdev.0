From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] ni5010: convert to net_device_ops
Date: Sun, 29 Mar 2009 06:51:23 +0400
Message-ID: <20090329025123.GA26722@orion>
References: <20090329022613.GA30897@orion> <20090328.193604.230866790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:58547 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbZC2Cva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:51:30 -0400
Received: by fxm2 with SMTP id 2so1508460fxm.37
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 19:51:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090328.193604.230866790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2009 at 07:36:04PM -0700, David Miller wrote:
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Sun, 29 Mar 2009 06:26:13 +0400
> 
> > @@ -189,6 +189,14 @@ static void __init trigger_irq(int ioaddr)
> >  		outb(MM_EN_XMT|MM_MUX, IE_MMODE); /* Start transmission */
> >  }
> >  
> > +static const struct net_device_ops ni5010_netdev_ops = {
> > +	.ndo_open		= ni5010_open,
> > +	.ndo_stop		= ni5010_close,
> > +	.ndo_start_xmit		= ni5010_send_packet,
> > +	.ndo_set_multicast_list	= ni5010_set_multicast_list,
> > +	.ndo_tx_timeout		= ni5010_timeout,
> > +};
> 
> Missing:
> 
> 	.ndo_change_mtu		= eth_change_mtu,
> 	.ndo_set_mac_address 	= eth_mac_addr,
> 	.ndo_validate_addr	= eth_validate_addr,
> 
> as would have been initialized to dev->foo by alloc_etherdev().

Ok, thanks.

Subject: [PATCH] ni5010: convert to net_device_ops
From: Alexander Beregalov <a.beregalov@gmail.com>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/ni5010.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 539e18a..2a8da47 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -189,6 +189,17 @@ static void __init trigger_irq(int ioaddr)
 		outb(MM_EN_XMT|MM_MUX, IE_MMODE); /* Start transmission */
 }
 
+static const struct net_device_ops ni5010_netdev_ops = {
+	.ndo_open		= ni5010_open,
+	.ndo_stop		= ni5010_close,
+	.ndo_start_xmit		= ni5010_send_packet,
+	.ndo_set_multicast_list	= ni5010_set_multicast_list,
+	.ndo_tx_timeout		= ni5010_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 /*
  *      This is the real probe routine.  Linux has a history of friendly device
  *      probes on the ISA bus.  A good device probes avoids doing writes, and
@@ -328,13 +339,8 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
         printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
-	memset(netdev_priv(dev), 0, sizeof(struct ni5010_local));
 
-	dev->open		= ni5010_open;
-	dev->stop		= ni5010_close;
-	dev->hard_start_xmit	= ni5010_send_packet;
-	dev->set_multicast_list = ni5010_set_multicast_list;
-	dev->tx_timeout		= ni5010_timeout;
+	dev->netdev_ops		= &ni5010_netdev_ops;
 	dev->watchdog_timeo	= HZ/20;
 
 	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */
