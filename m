From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Fri, 25 Feb 2011 11:51:30 -0800
Message-ID: <4D680842.6050309@chelsio.com>
References: <4D5D30CA020000780003263A@vpn.id2.novell.com> <20110222.101457.39195901.davem@davemloft.net> <4D64E5720200007800033420@vpn.id2.novell.com> <20110223.122709.193705956.davem@davemloft.net> <4D661E2702000078000336B5@vpn.id2.novell.com> <4D66B45B.2050604@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, divy@chelsio.com,
	linux-kbuild@vger.kernel.org, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@novell.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <4D66B45B.2050604@chelsio.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dimitris Michailidis wrote:
> Jan Beulich wrote:
> 
>> As to that INET vs NET dependency - is it possible that the
>> network drivers really just need NET, but the iSCSI ones need
>> INET? In which case the only common dependency would be
>> PCI - certainly not worth a custom helper option.
> 
> Reading the commit message that introduced CHELSIO_T3_DEPENDS, it talks 
> of hidden dependencies that select does not see.  I am not sure which 
> exactly but since it's been a few years since that commit I'll try to 
> see what the situation is today without the *_DEPENDS symbols and let 
> you know.

I looked into this and found that with the current Kconfig the iSCSI driver 
does not appear in the SCSI menu until one first enables NETDEVICES and 
NETDEV_10000 in the network driver menu.  It appears that the *_DEPENDS 
symbols were added to capture dependencies on such symbols within the 
network driver Kconfig, besides the dependencies the driver's entry listed 
explicitly.

The patch below removes *T4*_DEPENDS and the network drivers' unnecessary 
dependency on INET, and updates the iSCSI driver's entry so it is visible 
without requiring any net driver options to be enabled first and has 
adequate selects to be able to build the net driver (this part is adapted 
from bnx2i's Kconfig entry).  I still need to do the T3 part of this and 
check that there isn't a conflict with the current scsi tree.  Just for 
review at this time.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..0d314d5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2619,14 +2619,9 @@ config CHELSIO_T3
  	  To compile this driver as a module, choose M here: the module
  	  will be called cxgb3.

-config CHELSIO_T4_DEPENDS
-	tristate
-	depends on PCI && INET
-	default y
-
  config CHELSIO_T4
  	tristate "Chelsio Communications T4 Ethernet support"
-	depends on CHELSIO_T4_DEPENDS
+	depends on PCI
  	select FW_LOADER
  	select MDIO
  	help
@@ -2644,14 +2639,9 @@ config CHELSIO_T4
  	  To compile this driver as a module choose M here; the module
  	  will be called cxgb4.

-config CHELSIO_T4VF_DEPENDS
-	tristate
-	depends on PCI && INET
-	default y
-
  config CHELSIO_T4VF
  	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
-	depends on CHELSIO_T4VF_DEPENDS
+	depends on PCI
  	help
  	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
  	  adapters with PCI-E SR-IOV Virtual Functions.
diff --git a/drivers/scsi/cxgbi/cxgb4i/Kconfig 
b/drivers/scsi/cxgbi/cxgb4i/Kconfig
index bb94b39..d5302c2 100644
--- a/drivers/scsi/cxgbi/cxgb4i/Kconfig
+++ b/drivers/scsi/cxgbi/cxgb4i/Kconfig
@@ -1,6 +1,8 @@
  config SCSI_CXGB4_ISCSI
  	tristate "Chelsio T4 iSCSI support"
-	depends on CHELSIO_T4_DEPENDS
+	depends on PCI && INET
+	select NETDEVICES
+	select NETDEV_10000
  	select CHELSIO_T4
  	select SCSI_ISCSI_ATTRS
  	---help---
