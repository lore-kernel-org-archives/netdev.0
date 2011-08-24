From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] slip: Move the SLIP drivers
Date: Tue, 23 Aug 2011 21:39:30 -0700
Message-ID: <1314160774-6980-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2828 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411Ab1HXEjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 00:39:43 -0400
In-Reply-To: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Serial Line Internet Protocol (SLIP) drivers into
drivers/net/slip/ and make the necessary Kconfig and Makefile
changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Alan Cox <alan@linux.intel.com>
---
 drivers/net/Kconfig           |   74 +-------------------------------------
 drivers/net/Makefile          |    3 +-
 drivers/net/slip/Kconfig      |   79 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/slip/Makefile     |    6 +++
 drivers/net/{ => slip}/slhc.c |    0
 drivers/net/{ => slip}/slip.c |    0
 drivers/net/{ => slip}/slip.h |    0
 7 files changed, 88 insertions(+), 74 deletions(-)
 create mode 100644 drivers/net/slip/Kconfig
 create mode 100644 drivers/net/slip/Makefile
 rename drivers/net/{ => slip}/slhc.c (100%)
 rename drivers/net/{ => slip}/slip.c (100%)
 rename drivers/net/{ => slip}/slip.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3f72686..b3206c9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -199,6 +199,8 @@ source "drivers/net/fddi/Kconfig"
 
 source "drivers/net/plip/Kconfig"
 
+source "drivers/net/slip/Kconfig"
+
 source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
@@ -274,78 +276,6 @@ config RIONET_RX_SIZE
 	depends on RIONET
 	default "128"
 
-config SLIP
-	tristate "SLIP (serial line) support"
-	---help---
-	  Say Y if you intend to use SLIP or CSLIP (compressed SLIP) to
-	  connect to your Internet service provider or to connect to some
-	  other local Unix box or if you want to configure your Linux box as a
-	  Slip/CSlip server for other people to dial in. SLIP (Serial Line
-	  Internet Protocol) is a protocol used to send Internet traffic over
-	  serial connections such as telephone lines or null modem cables;
-	  nowadays, the protocol PPP is more commonly used for this same
-	  purpose.
-
-	  Normally, your access provider has to support SLIP in order for you
-	  to be able to use it, but there is now a SLIP emulator called SLiRP
-	  around (available from
-	  <ftp://ibiblio.org/pub/Linux/system/network/serial/>) which
-	  allows you to use SLIP over a regular dial up shell connection. If
-	  you plan to use SLiRP, make sure to say Y to CSLIP, below. The
-	  NET-3-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, explains how to
-	  configure SLIP. Note that you don't need this option if you just
-	  want to run term (term is a program which gives you almost full
-	  Internet connectivity if you have a regular dial up shell account on
-	  some Internet connected Unix computer. Read
-	  <http://www.bart.nl/~patrickr/term-howto/Term-HOWTO.html>). SLIP
-	  support will enlarge your kernel by about 4 KB. If unsure, say N.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called slip.
-
-config SLIP_COMPRESSED
-	bool "CSLIP compressed headers"
-	depends on SLIP
-	select SLHC
-	---help---
-	  This protocol is faster than SLIP because it uses compression on the
-	  TCP/IP headers (not on the data itself), but it has to be supported
-	  on both ends. Ask your access provider if you are not sure and
-	  answer Y, just in case. You will still be able to use plain SLIP. If
-	  you plan to use SLiRP, the SLIP emulator (available from
-	  <ftp://ibiblio.org/pub/Linux/system/network/serial/>) which
-	  allows you to use SLIP over a regular dial up shell connection, you
-	  definitely want to say Y here. The NET-3-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, explains how to configure
-	  CSLIP. This won't enlarge your kernel.
-
-config SLHC
-	tristate
-	help
-	  This option enables Van Jacobsen serial line header compression
-	  routines.
-
-config SLIP_SMART
-	bool "Keepalive and linefill"
-	depends on SLIP
-	help
-	  Adds additional capabilities to the SLIP driver to support the
-	  RELCOM line fill and keepalive monitoring. Ideal on poor quality
-	  analogue lines.
-
-config SLIP_MODE_SLIP6
-	bool "Six bit SLIP encapsulation"
-	depends on SLIP
-	help
-	  Just occasionally you may need to run IP over hostile serial
-	  networks that don't pass all control characters or are only seven
-	  bit. Saying Y here adds an extra mode you can use with SLIP:
-	  "slip6". In this mode, SLIP will only send normal ASCII symbols over
-	  the serial device. Naturally, this has to be supported at the other
-	  end of the link as well. It's good enough, for example, to run IP
-	  over the async ports of a Camtec JNT Pad. If unsure, say N.
-
 config NET_FC
 	bool "Fibre Channel driver support"
 	depends on SCSI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7013815..23ea83c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -20,8 +20,6 @@ obj-$(CONFIG_RIONET) += rionet.o
 
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_SLIP) += slip.o
-obj-$(CONFIG_SLHC) += slhc.o
 
 obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
 obj-$(CONFIG_XEN_NETDEV_BACKEND) += xen-netback/
@@ -40,6 +38,7 @@ obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
 obj-$(CONFIG_PLIP) += plip/
 onj-$(CONFIG_PPP) += ppp/
+onj-$(CONFIG_SLIP) += slip/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/net/slip/Kconfig b/drivers/net/slip/Kconfig
new file mode 100644
index 0000000..9997ae0
--- /dev/null
+++ b/drivers/net/slip/Kconfig
@@ -0,0 +1,79 @@
+#
+# SLIP network device configuration
+#
+
+config SLIP
+	tristate "SLIP (serial line) support"
+	---help---
+	  Say Y if you intend to use SLIP or CSLIP (compressed SLIP) to
+	  connect to your Internet service provider or to connect to some
+	  other local Unix box or if you want to configure your Linux box as a
+	  Slip/CSlip server for other people to dial in. SLIP (Serial Line
+	  Internet Protocol) is a protocol used to send Internet traffic over
+	  serial connections such as telephone lines or null modem cables;
+	  nowadays, the protocol PPP is more commonly used for this same
+	  purpose.
+
+	  Normally, your access provider has to support SLIP in order for you
+	  to be able to use it, but there is now a SLIP emulator called SLiRP
+	  around (available from
+	  <ftp://ibiblio.org/pub/Linux/system/network/serial/>) which
+	  allows you to use SLIP over a regular dial up shell connection. If
+	  you plan to use SLiRP, make sure to say Y to CSLIP, below. The
+	  NET-3-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, explains how to
+	  configure SLIP. Note that you don't need this option if you just
+	  want to run term (term is a program which gives you almost full
+	  Internet connectivity if you have a regular dial up shell account on
+	  some Internet connected Unix computer. Read
+	  <http://www.bart.nl/~patrickr/term-howto/Term-HOWTO.html>). SLIP
+	  support will enlarge your kernel by about 4 KB. If unsure, say N.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called slip.
+
+if SLIP
+
+config SLIP_COMPRESSED
+	bool "CSLIP compressed headers"
+	depends on SLIP
+	select SLHC
+	---help---
+	  This protocol is faster than SLIP because it uses compression on the
+	  TCP/IP headers (not on the data itself), but it has to be supported
+	  on both ends. Ask your access provider if you are not sure and
+	  answer Y, just in case. You will still be able to use plain SLIP. If
+	  you plan to use SLiRP, the SLIP emulator (available from
+	  <ftp://ibiblio.org/pub/Linux/system/network/serial/>) which
+	  allows you to use SLIP over a regular dial up shell connection, you
+	  definitely want to say Y here. The NET-3-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, explains how to configure
+	  CSLIP. This won't enlarge your kernel.
+
+config SLHC
+	tristate
+	---help---
+	  This option enables Van Jacobsen serial line header compression
+	  routines.
+
+config SLIP_SMART
+	bool "Keepalive and linefill"
+	depends on SLIP
+	---help---
+	  Adds additional capabilities to the SLIP driver to support the
+	  RELCOM line fill and keepalive monitoring. Ideal on poor quality
+	  analogue lines.
+
+config SLIP_MODE_SLIP6
+	bool "Six bit SLIP encapsulation"
+	depends on SLIP
+	---help---
+	  Just occasionally you may need to run IP over hostile serial
+	  networks that don't pass all control characters or are only seven
+	  bit. Saying Y here adds an extra mode you can use with SLIP:
+	  "slip6". In this mode, SLIP will only send normal ASCII symbols over
+	  the serial device. Naturally, this has to be supported at the other
+	  end of the link as well. It's good enough, for example, to run IP
+	  over the async ports of a Camtec JNT Pad. If unsure, say N.
+
+endif # SLIP
diff --git a/drivers/net/slip/Makefile b/drivers/net/slip/Makefile
new file mode 100644
index 0000000..e3ebc59
--- /dev/null
+++ b/drivers/net/slip/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the SLIP network device drivers.
+#
+
+obj-$(CONFIG_SLIP) += slip.o
+obj-$(CONFIG_SLHC) += slhc.o
diff --git a/drivers/net/slhc.c b/drivers/net/slip/slhc.c
similarity index 100%
rename from drivers/net/slhc.c
rename to drivers/net/slip/slhc.c
diff --git a/drivers/net/slip.c b/drivers/net/slip/slip.c
similarity index 100%
rename from drivers/net/slip.c
rename to drivers/net/slip/slip.c
diff --git a/drivers/net/slip.h b/drivers/net/slip/slip.h
similarity index 100%
rename from drivers/net/slip.h
rename to drivers/net/slip/slip.h
-- 
1.7.6
