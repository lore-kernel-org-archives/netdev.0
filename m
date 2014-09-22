From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scsi: fix kconfig dependency warnings for SCSI_FC_ATTRS
Date: Mon, 22 Sep 2014 12:11:06 -0400 (EDT)
Message-ID: <20140922.121106.1110168028426156500.davem@davemloft.net>
References: <541CC163.3080709@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	jbottomley@parallels.com, anish@chelsio.com
To: rdunlap@infradead.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <541CC163.3080709@infradead.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Fri, 19 Sep 2014 16:50:59 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kconfig dependency warnings which can lead to build errors:
> 
> warning: (SCSI_BNX2X_FCOE && LIBFCOE && TCM_QLA2XXX) selects LIBFC which has unmet direct dependencies (SCSI_LOWLEVEL && SCSI && SCSI_FC_ATTRS)
> 
> warning: (FCOE && FCOE_FNIC) selects LIBFCOE which has unmet direct dependencies (SCSI_LOWLEVEL && SCSI && SCSI_FC_ATTRS)
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Randy, I think we need to propagate usage of depends into LIBFC and LIBFCOE as well.

I'm playing around with the following patch and will probably use this to resolve
everything.

Thanks.

diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index b745012..bd85fb4 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -592,21 +592,21 @@ config LIBFC
 
 config LIBFCOE
 	tristate "LibFCoE module"
-	select LIBFC
+	depends on LIBFC
 	---help---
 	  Library for Fibre Channel over Ethernet module
 
 config FCOE
 	tristate "FCoE module"
 	depends on PCI
-	select LIBFCOE
+	depends on LIBFCOE
 	---help---
 	  Fibre Channel over Ethernet module
 
 config FCOE_FNIC
 	tristate "Cisco FNIC Driver"
 	depends on PCI && X86
-	select LIBFCOE
+	depends on LIBFCOE
 	help
 	  This is support for the Cisco PCI-Express FCoE HBA.
 
diff --git a/drivers/scsi/bnx2fc/Kconfig b/drivers/scsi/bnx2fc/Kconfig
index 02b0ba8..0978828 100644
--- a/drivers/scsi/bnx2fc/Kconfig
+++ b/drivers/scsi/bnx2fc/Kconfig
@@ -2,11 +2,11 @@ config SCSI_BNX2X_FCOE
 	tristate "QLogic NetXtreme II FCoE support"
 	depends on PCI
 	depends on (IPV6 || IPV6=n)
+	depends on LIBFC
+	depends on LIBFCOE
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_BROADCOM
-	select LIBFC
-	select LIBFCOE
 	select CNIC
 	---help---
 	This driver supports FCoE offload for the QLogic NetXtreme II
diff --git a/drivers/scsi/qla2xxx/Kconfig b/drivers/scsi/qla2xxx/Kconfig
index 7d65776..113e6c9 100644
--- a/drivers/scsi/qla2xxx/Kconfig
+++ b/drivers/scsi/qla2xxx/Kconfig
@@ -31,7 +31,7 @@ config SCSI_QLA_FC
 config TCM_QLA2XXX
 	tristate "TCM_QLA2XXX fabric module for Qlogic 2xxx series target mode HBAs"
 	depends on SCSI_QLA_FC && TARGET_CORE
-	select LIBFC
+	depends on LIBFC
 	select BTREE
 	default n
 	---help---
