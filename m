From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined reference to `pch_ch_control_write'
Date: Sat, 6 Oct 2012 13:31:26 +0200
Message-ID: <20121006113126.GA17783@electric-eye.fr.zoreil.com>
References: <20121006075954.GA29618@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Haicheng Li <haicheng.li@linux.intel.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37787 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab2JFLvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 07:51:22 -0400
Content-Disposition: inline
In-Reply-To: <20121006075954.GA29618@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang Wu <fengguang.wu@intel.com> :
[...]
> FYI, kernel build failed on
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> head:   c0b8b99287235626a5850ef7e5bfc842d1ebcecd
> commit: da1586461e53a4dd045738cce309ab488970f0ef [1/9] pch_gbe: Fix PTP dependencies.
> config: x86_64-randconfig-s052 (attached as .config)

7c236c43b838221e17220bcb39e8e8d8c7123713 does something like the patch
below for the sfc driver. It would be worth checking if gianfar and
intel get it right too.

/me must leave.

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 9730241..1dd9e33 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -21,15 +21,12 @@ config PCH_GBE
 	  ML7223/ML7831 is companion chip for Intel Atom E6xx series.
 	  ML7223/ML7831 is completely compatible for Intel EG20T PCH.
 
-if PCH_GBE
-
 config PCH_PTP
 	bool "PCH PTP clock support"
 	default n
+	depends on GBE && PTP_1588_CLOCK && !(GBE=y && PTP_1588_CLOCK=m)
 	select PTP_1588_CLOCK_PCH
 	---help---
 	  Say Y here if you want to use Precision Time Protocol (PTP) in the
 	  driver. PTP is a method to precisely synchronize distributed clocks
 	  over Ethernet networks.
-
-endif # PCH_GBE
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b2a94d0..351a585 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -262,6 +262,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case HWTSTAMP_FILTER_NONE:
 		adapter->hwts_rx_en = 0;
 		break;
+#ifdef CONFIG_PCH_PTP
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		adapter->hwts_rx_en = 0;
 		pch_ch_control_write(pdev, SLAVE_MODE | CAP_MODE0);
@@ -282,6 +283,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		strcpy(station, PTP_L2_MULTICAST_SA);
 		pch_set_station_address(station, pdev);
 		break;
+#endif
 	default:
 		return -ERANGE;
 	}
