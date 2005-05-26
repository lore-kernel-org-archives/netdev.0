From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Thu, 26 May 2005 16:37:38 -0700 (PDT)
Message-ID: <20050526.163738.69020927.davem@davemloft.net>
References: <20050526232006.60E6365005@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <20050526232006.60E6365005@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: ravinandan.arakali@neterion.com
Date: Thu, 26 May 2005 16:20:06 -0700 (PDT)

> Attached below is a kernel patch to provide UDP LSO(Large Send Offload) 
> feature.

Interesting patch, thanks a lot.  Some quick review:

1) I think you can use skb_shinfo(skb)->tso_size, and UDP packet
   with this non-zero will never be sent unless the driver
   indicates the capability.

2) I think NETIF_F_USO is a nicer name and consistent with
   the existing NETIF_F_TSO macro name.  Please change it.

3) Make NETIF_F_USO require both NETIF_F_SG and checksumming
   capability.  Check this at device registry, and ethtool operation
   time, so that you need not verify it during packet send.

For #3, it should be a simple change to net/core/dev.c and
net/core/ethtool.c, for example see this test we have in
net/core/dev.c:register_netdevice()

	/* TSO requires that SG is present as well. */
	if ((dev->features & NETIF_F_TSO) &&
	    !(dev->features & NETIF_F_SG)) {
		printk("%s: Dropping NETIF_F_TSO since no SG feature.\n",
		       dev->name);
		dev->features &= ~NETIF_F_TSO;
	}

Just make the same exact check for NETIF_F_USO.

Similarly, you'll need to add the necessary ethtool machinery
(missing from your patch, but really needed) then do something
similar to net/core/ethtool.c:ethtool_set_tso() for ethtool setting
of NETIF_F_USO.  Probably you'll name this function ethtool_set_uso()
:-)
