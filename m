From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [BUILD FAILURE 04] Next April 9 : PPC64 randconfig
	[drivers/net/ibm_newemac/core.c]
Date: Fri, 10 Apr 2009 05:56:14 +0400
Message-ID: <20090410015614.GA5781@orion>
References: <1239285152.5188.66.camel@subratamodak.linux.ibm.com> <BE92FB74-1784-414B-B27F-8329185EB3AE@kernel.crashing.org> <20090409143112.GA7538@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak@kernel.crashing.org>, subrata@linux.vnet.ibm.com,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-net@vger.kernel.org, Greg KH <greg@kroah.com>,
	sachinp <sachinp@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090409143112.GA7538@yoda.jdub.homelinux.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 09, 2009 at 10:31:12AM -0400, Josh Boyer wrote:
> On Thu, Apr 09, 2009 at 09:28:23AM -0500, Kumar Gala wrote:
> >
> > On Apr 9, 2009, at 8:52 AM, Subrata Modak wrote:
> >
> >> Observed the following build error:
> >>
> >> CC      drivers/net/ibm_newemac/core.o
> >> drivers/net/ibm_newemac/core.c: In function ???emac_probe???:
> >> drivers/net/ibm_newemac/core.c:2831: error: ???struct net_device??? has no
> >> member named ???open???
> >> drivers/net/ibm_newemac/core.c:2834: error: ???struct net_device??? has no
> >> member named ???tx_timeout???
> >> drivers/net/ibm_newemac/core.c:2836: error: ???struct net_device??? has no
> >> member named ???stop???
> >> drivers/net/ibm_newemac/core.c:2837: error: ???struct net_device??? has no
> >> member named ???get_stats???
> >> drivers/net/ibm_newemac/core.c:2838: error: ???struct net_device??? has no
> >> member named ???set_multicast_list???
> >> drivers/net/ibm_newemac/core.c:2839: error: ???struct net_device??? has no
> >> member named ???do_ioctl???
> >> drivers/net/ibm_newemac/core.c:2841: error: ???struct net_device??? has no
> >> member named ???hard_start_xmit???
> >> drivers/net/ibm_newemac/core.c:2842: error: ???struct net_device??? has no
> >> member named ???change_mtu???
> >> drivers/net/ibm_newemac/core.c:2845: error: ???struct net_device??? has no
> >> member named ???hard_start_xmit???
> >> make[3]: *** [drivers/net/ibm_newemac/core.o] Error 1
> >> make[2]: *** [drivers/net/ibm_newemac] Error 2
> >> make[1]: *** [drivers/net] Error 2
> >> make: *** [drivers] Error 2
> >>
> >> Regards--
> >> Subrata
> >>
> >> <randconfig4-ppc64-next20090409.txt>
> >
> > This is because CONFIG_COMPAT_NET_DEV_OPS isnt set and needs to be for  
> > this driver to build.  I've asked the netdev guys about either fixing  
> > the driver or adding the proper thing to Kconfig to select  
> > CONFIG_COMPAT_NET_DEV_OPS.
> 
> Thanks!
> 
> If someone has pointers on what needs to be done to fix it, let me know.
> 

From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] ibm_newemac: convert to netdev_ops


Reported-by: Subrata Modak <subrata@linux.vnet.ibm.com>
Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/ibm_newemac/core.c |   41 ++++++++++++++++++++++++++++-----------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 77e4b5b..806533c 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2686,6 +2686,32 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	return 0;
 }
 
+static const struct net_device_ops emac_netdev_ops = {
+	.ndo_open		= emac_open,
+	.ndo_stop		= emac_close,
+	.ndo_get_stats		= emac_stats,
+	.ndo_set_multicast_list	= emac_set_multicast_list,
+	.ndo_do_ioctl		= emac_ioctl,
+	.ndo_tx_timeout		= emac_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_start_xmit		= emac_start_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
+static const struct net_device_ops emac_gige_netdev_ops = {
+	.ndo_open		= emac_open,
+	.ndo_stop		= emac_close,
+	.ndo_get_stats		= emac_stats,
+	.ndo_set_multicast_list	= emac_set_multicast_list,
+	.ndo_do_ioctl		= emac_ioctl,
+	.ndo_tx_timeout		= emac_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_start_xmit		= emac_start_xmit_sg,
+	.ndo_change_mtu		= emac_change_mtu,
+};
+
 static int __devinit emac_probe(struct of_device *ofdev,
 				const struct of_device_id *match)
 {
@@ -2827,23 +2853,14 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	if (err != 0)
 		goto err_detach_tah;
 
-	/* Fill in the driver function table */
-	ndev->open = &emac_open;
 	if (dev->tah_dev)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-	ndev->tx_timeout = &emac_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
-	ndev->stop = &emac_close;
-	ndev->get_stats = &emac_stats;
-	ndev->set_multicast_list = &emac_set_multicast_list;
-	ndev->do_ioctl = &emac_ioctl;
 	if (emac_phy_supports_gige(dev->phy_mode)) {
-		ndev->hard_start_xmit = &emac_start_xmit_sg;
-		ndev->change_mtu = &emac_change_mtu;
+		ndev->netdev_ops = &emac_gige_netdev_ops;
 		dev->commac.ops = &emac_commac_sg_ops;
-	} else {
-		ndev->hard_start_xmit = &emac_start_xmit;
-	}
+	} else
+		ndev->netdev_ops = &emac_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &emac_ethtool_ops);
 
 	netif_carrier_off(ndev);
