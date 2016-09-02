From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 2 Sep 2016 09:52:41 +0200
Message-ID: <20160902075241.GA1814@nanopsycho>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35961 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbcIBHwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 03:52:45 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so1738377wmf.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 00:52:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 02, 2016 at 07:18:34AM CEST, mahesh@bandewar.net wrote:
>From: Mahesh Bandewar <maheshb@google.com>
>
>Following few steps will crash kernel -
>
>  (a) Create bonding master
>      > modprobe bonding miimon=50
>  (b) Create macvlan bridge on eth2
>      > ip link add link eth2 dev mvl0 address aa:0:0:0:0:01 \
>	   type macvlan
>  (c) Now try adding eth2 into the bond
>      > echo +eth2 > /sys/class/net/bond0/bonding/slaves
>      <crash>
>
>Bonding does lots of things before checking if the device enslaved is
>busy or not.
>
>In this case when the notifier call-chain sends notifications, the
>bond_netdev_event() assumes that the rx_handler /rx_handler_data is
>registered while the bond_enslave() hasn't progressed far enough to
>register rx_handler for the new slave.
>
>This patch adds a rx_handler check that can be performed right at the
>beginning of the enslave code to avoid getting into this situation.
>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>---
> drivers/net/bonding/bond_main.c |  7 ++++---
> include/linux/netdevice.h       |  1 +
> net/core/dev.c                  | 16 ++++++++++++++++
> 3 files changed, 21 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 217e8da0628c..9599ed6f1213 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1341,9 +1341,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 			    slave_dev->name);
> 	}
> 
>-	/* already enslaved */
>-	if (slave_dev->flags & IFF_SLAVE) {
>-		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
>+	/* already in-use? */
>+	if (netdev_is_rx_handler_busy(slave_dev)) {
>+		netdev_err(bond_dev,
>+			   "Error: Device is in use and cannot be enslaved\n");
> 		return -EBUSY;
> 	}
> 
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index d122be9345c7..99ba59a7b114 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -3266,6 +3266,7 @@ static inline void napi_free_frags(struct napi_struct *napi)
> 	napi->skb = NULL;
> }
> 
>+bool netdev_is_rx_handler_busy(struct net_device *dev);
> int netdev_rx_handler_register(struct net_device *dev,
> 			       rx_handler_func_t *rx_handler,
> 			       void *rx_handler_data);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 34b5322bc081..81e6f7298122 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3965,6 +3965,22 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
> }
> 
> /**
>+ *	netdev_is_rx_handler_busy - check if receive handler is registered
>+ *	@dev: device to check
>+ *
>+ *	Check if a receive handler is already registered for a given device.
>+ *	Return true if there one.
>+ *
>+ *	The caller must hold the rtnl_mutex.
>+ */
>+bool netdev_is_rx_handler_busy(struct net_device *dev)
>+{
>+	ASSERT_RTNL();
>+	return dev && rtnl_dereference(dev->rx_handler);
>+}
>+EXPORT_SYMBOL_GPL(netdev_is_rx_handler_busy);

No, please, don't make bonding a spacial citizen introducing this.
Please handle the issue inside the bonding code, like we do for the rest
of master devices (and how it was once done for bonding). Thanks.
