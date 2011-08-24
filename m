From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ppp: Move the PPP drivers
Date: Wed, 24 Aug 2011 02:02:43 -0700
Message-ID: <1314176570-20298-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Paul Mackerras <paulus@samba.org>,
	Frank Cusack <fcusack@fcusack.com>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Dmitry Kozlov <xeb@mail.ru>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46584 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756836Ab1HXJC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 05:02:56 -0400
In-Reply-To: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the PPP drivers into drivers/net/ppp/ and make the
necessary Kconfig and Makefile changes.

CC: Paul Mackerras <paulus@samba.org>
CC: Frank Cusack <fcusack@fcusack.com>
CC: Michal Ostrowski <mostrows@speakeasy.net>
CC: Michal Ostrowski <mostrows@earthlink.net>
CC: Dmitry Kozlov <xeb@mail.ru>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                         |    8 +-
 drivers/net/Kconfig                 |  170 +---------------------------------
 drivers/net/Makefile                |   10 +--
 drivers/net/ppp/Kconfig             |  176 +++++++++++++++++++++++++++++++++++
 drivers/net/ppp/Makefile            |   13 +++
 drivers/net/{ => ppp}/bsd_comp.c    |    0
 drivers/net/{ => ppp}/ppp_async.c   |    0
 drivers/net/{ => ppp}/ppp_deflate.c |    0
 drivers/net/{ => ppp}/ppp_generic.c |    0
 drivers/net/{ => ppp}/ppp_mppe.c    |    0
 drivers/net/{ => ppp}/ppp_mppe.h    |    0
 drivers/net/{ => ppp}/ppp_synctty.c |    0
 drivers/net/{ => ppp}/pppoe.c       |    0
 drivers/net/{ => ppp}/pppox.c       |    0
 drivers/net/{ => ppp}/pptp.c        |    0
 15 files changed, 196 insertions(+), 181 deletions(-)
 create mode 100644 drivers/net/ppp/Kconfig
 create mode 100644 drivers/net/ppp/Makefile
 rename drivers/net/{ => ppp}/bsd_comp.c (100%)
 rename drivers/net/{ => ppp}/ppp_async.c (100%)
 rename drivers/net/{ => ppp}/ppp_deflate.c (100%)
 rename drivers/net/{ => ppp}/ppp_generic.c (100%)
 rename drivers/net/{ => ppp}/ppp_mppe.c (100%)
 rename drivers/net/{ => ppp}/ppp_mppe.h (100%)
 rename drivers/net/{ => ppp}/ppp_synctty.c (100%)
 rename drivers/net/{ => ppp}/pppoe.c (100%)
 rename drivers/net/{ => ppp}/pppox.c (100%)
 rename drivers/net/{ => ppp}/pptp.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2777088..c5ec925 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5066,7 +5066,7 @@ PPP PROTOCOL DRIVERS AND COMPRESSORS
 M:	Paul Mackerras <paulus@samba.org>
 L:	linux-ppp@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ppp_*
+F:	drivers/net/ppp/ppp_*
 
 PPP OVER ATM (RFC 2364)
 M:	Mitchell Blank Jr <mitch@sfgoth.com>
@@ -5077,8 +5077,8 @@ F:	include/linux/atmppp.h
 PPP OVER ETHERNET
 M:	Michal Ostrowski <mostrows@earthlink.net>
 S:	Maintained
-F:	drivers/net/pppoe.c
-F:	drivers/net/pppox.c
+F:	drivers/net/ppp/pppoe.c
+F:	drivers/net/ppp/pppox.c
 
 PPP OVER L2TP
 M:	James Chapman <jchapman@katalix.com>
@@ -5099,7 +5099,7 @@ PPTP DRIVER
 M:	Dmitry Kozlov <xeb@mail.ru>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/pptp.c
+F:	drivers/net/ppp/pptp.c
 W:	http://sourceforge.net/projects/accel-pptp
 
 PREEMPTIBLE KERNEL
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7bdc22b..c5e2a38 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -207,6 +207,8 @@ source "drivers/net/usb/Kconfig"
 
 source "drivers/net/pcmcia/Kconfig"
 
+source "drivers/net/ppp/Kconfig"
+
 source "drivers/net/wan/Kconfig"
 
 source "drivers/atm/Kconfig"
@@ -337,174 +339,6 @@ config PLIP
 	  will be called plip. If unsure, say Y or M, in case you buy
 	  a laptop later.
 
-config PPP
-	tristate "PPP (point-to-point protocol) support"
-	select SLHC
-	---help---
-	  PPP (Point to Point Protocol) is a newer and better SLIP.  It serves
-	  the same purpose: sending Internet traffic over telephone (and other
-	  serial) lines.  Ask your access provider if they support it, because
-	  otherwise you can't use it; most Internet access providers these
-	  days support PPP rather than SLIP.
-
-	  To use PPP, you need an additional program called pppd as described
-	  in the PPP-HOWTO, available at
-	  <http://www.tldp.org/docs.html#howto>.  Make sure that you have
-	  the version of pppd recommended in <file:Documentation/Changes>.
-	  The PPP option enlarges your kernel by about 16 KB.
-
-	  There are actually two versions of PPP: the traditional PPP for
-	  asynchronous lines, such as regular analog phone lines, and
-	  synchronous PPP which can be used over digital ISDN lines for
-	  example.  If you want to use PPP over phone lines or other
-	  asynchronous serial lines, you need to say Y (or M) here and also to
-	  the next option, "PPP support for async serial ports".  For PPP over
-	  synchronous lines, you should say Y (or M) here and to "Support
-	  synchronous PPP", below.
-
-	  If you said Y to "Version information on all symbols" above, then
-	  you cannot compile the PPP driver into the kernel; you can then only
-	  compile it as a module. To compile this driver as a module, choose M
-	  here. The module will be called ppp_generic.
-
-config PPP_MULTILINK
-	bool "PPP multilink support (EXPERIMENTAL)"
-	depends on PPP && EXPERIMENTAL
-	help
-	  PPP multilink is a protocol (defined in RFC 1990) which allows you
-	  to combine several (logical or physical) lines into one logical PPP
-	  connection, so that you can utilize your full bandwidth.
-
-	  This has to be supported at the other end as well and you need a
-	  version of the pppd daemon which understands the multilink protocol.
-
-	  If unsure, say N.
-
-config PPP_FILTER
-	bool "PPP filtering"
-	depends on PPP
-	help
-	  Say Y here if you want to be able to filter the packets passing over
-	  PPP interfaces.  This allows you to control which packets count as
-	  activity (i.e. which packets will reset the idle timer or bring up
-	  a demand-dialed link) and which packets are to be dropped entirely.
-	  You need to say Y here if you wish to use the pass-filter and
-	  active-filter options to pppd.
-
-	  If unsure, say N.
-
-config PPP_ASYNC
-	tristate "PPP support for async serial ports"
-	depends on PPP
-	select CRC_CCITT
-	---help---
-	  Say Y (or M) here if you want to be able to use PPP over standard
-	  asynchronous serial ports, such as COM1 or COM2 on a PC.  If you use
-	  a modem (not a synchronous or ISDN modem) to contact your ISP, you
-	  need this option.
-
-	  To compile this driver as a module, choose M here.
-
-	  If unsure, say Y.
-
-config PPP_SYNC_TTY
-	tristate "PPP support for sync tty ports"
-	depends on PPP
-	help
-	  Say Y (or M) here if you want to be able to use PPP over synchronous
-	  (HDLC) tty devices, such as the SyncLink adapter. These devices
-	  are often used for high-speed leased lines like T1/E1.
-
-	  To compile this driver as a module, choose M here.
-
-config PPP_DEFLATE
-	tristate "PPP Deflate compression"
-	depends on PPP
-	select ZLIB_INFLATE
-	select ZLIB_DEFLATE
-	---help---
-	  Support for the Deflate compression method for PPP, which uses the
-	  Deflate algorithm (the same algorithm that gzip uses) to compress
-	  each PPP packet before it is sent over the wire.  The machine at the
-	  other end of the PPP link (usually your ISP) has to support the
-	  Deflate compression method as well for this to be useful.  Even if
-	  they don't support it, it is safe to say Y here.
-
-	  To compile this driver as a module, choose M here.
-
-config PPP_BSDCOMP
-	tristate "PPP BSD-Compress compression"
-	depends on PPP
-	---help---
-	  Support for the BSD-Compress compression method for PPP, which uses
-	  the LZW compression method to compress each PPP packet before it is
-	  sent over the wire. The machine at the other end of the PPP link
-	  (usually your ISP) has to support the BSD-Compress compression
-	  method as well for this to be useful. Even if they don't support it,
-	  it is safe to say Y here.
-
-	  The PPP Deflate compression method ("PPP Deflate compression",
-	  above) is preferable to BSD-Compress, because it compresses better
-	  and is patent-free.
-
-	  Note that the BSD compression code will always be compiled as a
-	  module; it is called bsd_comp and will show up in the directory
-	  modules once you have said "make modules". If unsure, say N.
-
-config PPP_MPPE
-	tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
-	depends on PPP && EXPERIMENTAL
-	select CRYPTO
-	select CRYPTO_SHA1
-	select CRYPTO_ARC4
-	select CRYPTO_ECB
-	---help---
-	  Support for the MPPE Encryption protocol, as employed by the
-	  Microsoft Point-to-Point Tunneling Protocol.
-
-	  See http://pptpclient.sourceforge.net/ for information on
-	  configuring PPTP clients and servers to utilize this method.
-
-config PPPOE
-	tristate "PPP over Ethernet (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && PPP
-	help
-	  Support for PPP over Ethernet.
-
-	  This driver requires the latest version of pppd from the CVS
-	  repository at cvs.samba.org.  Alternatively, see the 
-	  RoaringPenguin package (<http://www.roaringpenguin.com/pppoe>)
-	  which contains instruction on how to use this driver (under 
-	  the heading "Kernel mode PPPoE").
-
-config PPTP
-	tristate "PPP over IPv4 (PPTP) (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && PPP && NET_IPGRE_DEMUX
-	help
-	  Support for PPP over IPv4.(Point-to-Point Tunneling Protocol)
-
-	  This driver requires pppd plugin to work in client mode or
-	  modified pptpd (poptop) to work in server mode.
-	  See http://accel-pptp.sourceforge.net/ for information how to
-	  utilize this module.
-
-config PPPOATM
-	tristate "PPP over ATM"
-	depends on ATM && PPP
-	help
-	  Support PPP (Point to Point Protocol) encapsulated in ATM frames.
-	  This implementation does not yet comply with section 8 of RFC2364,
-	  which can lead to bad results if the ATM peer loses state and
-	  changes its encapsulation unilaterally.
-
-config PPPOL2TP
-	tristate "PPP over L2TP (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && L2TP && PPP
-	help
-	  Support for PPP-over-L2TP socket family. L2TP is a protocol
-	  used by ISPs and enterprises to tunnel PPP traffic over UDP
-	  tunnels. L2TP is replacing PPTP for VPN uses.
-
 config SLIP
 	tristate "SLIP (serial line) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3087b27..9ce7c70 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -22,15 +22,6 @@ obj-$(CONFIG_RIONET) += rionet.o
 
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_PPP) += ppp_generic.o
-obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
-obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
-obj-$(CONFIG_PPP_DEFLATE) += ppp_deflate.o
-obj-$(CONFIG_PPP_BSDCOMP) += bsd_comp.o
-obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
-obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
-obj-$(CONFIG_PPPOL2TP) += pppox.o
-obj-$(CONFIG_PPTP) += pppox.o pptp.o
 obj-$(CONFIG_SLIP) += slip.o
 obj-$(CONFIG_SLHC) += slhc.o
 
@@ -48,6 +39,7 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
+onj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/net/ppp/Kconfig b/drivers/net/ppp/Kconfig
new file mode 100644
index 0000000..bc60a40
--- /dev/null
+++ b/drivers/net/ppp/Kconfig
@@ -0,0 +1,176 @@
+#
+# PPP network device configuration
+#
+
+config PPP
+	tristate "PPP (point-to-point protocol) support"
+	depends on PCI || EISA || TC
+	select SLHC
+	---help---
+	  PPP (Point to Point Protocol) is a newer and better SLIP.  It serves
+	  the same purpose: sending Internet traffic over telephone (and other
+	  serial) lines.  Ask your access provider if they support it, because
+	  otherwise you can't use it; most Internet access providers these
+	  days support PPP rather than SLIP.
+
+	  To use PPP, you need an additional program called pppd as described
+	  in the PPP-HOWTO, available at
+	  <http://www.tldp.org/docs.html#howto>.  Make sure that you have
+	  the version of pppd recommended in <file:Documentation/Changes>.
+	  The PPP option enlarges your kernel by about 16 KB.
+
+	  There are actually two versions of PPP: the traditional PPP for
+	  asynchronous lines, such as regular analog phone lines, and
+	  synchronous PPP which can be used over digital ISDN lines for
+	  example.  If you want to use PPP over phone lines or other
+	  asynchronous serial lines, you need to say Y (or M) here and also to
+	  the next option, "PPP support for async serial ports".  For PPP over
+	  synchronous lines, you should say Y (or M) here and to "Support
+	  synchronous PPP", below.
+
+	  If you said Y to "Version information on all symbols" above, then
+	  you cannot compile the PPP driver into the kernel; you can then only
+	  compile it as a module. To compile this driver as a module, choose M
+	  here. The module will be called ppp_generic.
+
+if PPP
+
+config PPP_BSDCOMP
+	tristate "PPP BSD-Compress compression"
+	depends on PPP
+	---help---
+	  Support for the BSD-Compress compression method for PPP, which uses
+	  the LZW compression method to compress each PPP packet before it is
+	  sent over the wire. The machine at the other end of the PPP link
+	  (usually your ISP) has to support the BSD-Compress compression
+	  method as well for this to be useful. Even if they don't support it,
+	  it is safe to say Y here.
+
+	  The PPP Deflate compression method ("PPP Deflate compression",
+	  above) is preferable to BSD-Compress, because it compresses better
+	  and is patent-free.
+
+	  Note that the BSD compression code will always be compiled as a
+	  module; it is called bsd_comp and will show up in the directory
+	  modules once you have said "make modules". If unsure, say N.
+
+config PPP_DEFLATE
+	tristate "PPP Deflate compression"
+	depends on PPP
+	select ZLIB_INFLATE
+	select ZLIB_DEFLATE
+	---help---
+	  Support for the Deflate compression method for PPP, which uses the
+	  Deflate algorithm (the same algorithm that gzip uses) to compress
+	  each PPP packet before it is sent over the wire.  The machine at the
+	  other end of the PPP link (usually your ISP) has to support the
+	  Deflate compression method as well for this to be useful.  Even if
+	  they don't support it, it is safe to say Y here.
+
+	  To compile this driver as a module, choose M here.
+
+config PPP_FILTER
+	bool "PPP filtering"
+	depends on PPP
+	---help---
+	  Say Y here if you want to be able to filter the packets passing over
+	  PPP interfaces.  This allows you to control which packets count as
+	  activity (i.e. which packets will reset the idle timer or bring up
+	  a demand-dialed link) and which packets are to be dropped entirely.
+	  You need to say Y here if you wish to use the pass-filter and
+	  active-filter options to pppd.
+
+	  If unsure, say N.
+
+config PPP_MPPE
+	tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
+	depends on PPP && EXPERIMENTAL
+	select CRYPTO
+	select CRYPTO_SHA1
+	select CRYPTO_ARC4
+	select CRYPTO_ECB
+	---help---
+	  Support for the MPPE Encryption protocol, as employed by the
+	  Microsoft Point-to-Point Tunneling Protocol.
+
+	  See http://pptpclient.sourceforge.net/ for information on
+	  configuring PPTP clients and servers to utilize this method.
+
+config PPP_MULTILINK
+	bool "PPP multilink support (EXPERIMENTAL)"
+	depends on PPP && EXPERIMENTAL
+	---help---
+	  PPP multilink is a protocol (defined in RFC 1990) which allows you
+	  to combine several (logical or physical) lines into one logical PPP
+	  connection, so that you can utilize your full bandwidth.
+
+	  This has to be supported at the other end as well and you need a
+	  version of the pppd daemon which understands the multilink protocol.
+
+	  If unsure, say N.
+
+config PPPOATM
+	tristate "PPP over ATM"
+	depends on ATM && PPP
+	---help---
+	  Support PPP (Point to Point Protocol) encapsulated in ATM frames.
+	  This implementation does not yet comply with section 8 of RFC2364,
+	  which can lead to bad results if the ATM peer loses state and
+	  changes its encapsulation unilaterally.
+
+config PPPOE
+	tristate "PPP over Ethernet (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && PPP
+	---help---
+	  Support for PPP over Ethernet.
+
+	  This driver requires the latest version of pppd from the CVS
+	  repository at cvs.samba.org.  Alternatively, see the
+	  RoaringPenguin package (<http://www.roaringpenguin.com/pppoe>)
+	  which contains instruction on how to use this driver (under
+	  the heading "Kernel mode PPPoE").
+
+config PPTP
+	tristate "PPP over IPv4 (PPTP) (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && PPP && NET_IPGRE_DEMUX
+	---help---
+	  Support for PPP over IPv4.(Point-to-Point Tunneling Protocol)
+
+	  This driver requires pppd plugin to work in client mode or
+	  modified pptpd (poptop) to work in server mode.
+	  See http://accel-pptp.sourceforge.net/ for information how to
+	  utilize this module.
+
+config PPPOL2TP
+	tristate "PPP over L2TP (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && L2TP && PPP
+	---help---
+	  Support for PPP-over-L2TP socket family. L2TP is a protocol
+	  used by ISPs and enterprises to tunnel PPP traffic over UDP
+	  tunnels. L2TP is replacing PPTP for VPN uses.
+
+config PPP_ASYNC
+	tristate "PPP support for async serial ports"
+	depends on PPP
+	select CRC_CCITT
+	---help---
+	  Say Y (or M) here if you want to be able to use PPP over standard
+	  asynchronous serial ports, such as COM1 or COM2 on a PC.  If you use
+	  a modem (not a synchronous or ISDN modem) to contact your ISP, you
+	  need this option.
+
+	  To compile this driver as a module, choose M here.
+
+	  If unsure, say Y.
+
+config PPP_SYNC_TTY
+	tristate "PPP support for sync tty ports"
+	depends on PPP
+	---help---
+	  Say Y (or M) here if you want to be able to use PPP over synchronous
+	  (HDLC) tty devices, such as the SyncLink adapter. These devices
+	  are often used for high-speed leased lines like T1/E1.
+
+	  To compile this driver as a module, choose M here.
+
+endif # PPP
diff --git a/drivers/net/ppp/Makefile b/drivers/net/ppp/Makefile
new file mode 100644
index 0000000..a6b6297
--- /dev/null
+++ b/drivers/net/ppp/Makefile
@@ -0,0 +1,13 @@
+#
+# Makefile for the Linux PPP network device drivers.
+#
+
+obj-$(CONFIG_PPP) += ppp_generic.o
+obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
+obj-$(CONFIG_PPP_BSDCOMP) += bsd_comp.o
+obj-$(CONFIG_PPP_DEFLATE) += ppp_deflate.o
+obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
+obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
+obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
+obj-$(CONFIG_PPPOL2TP) += pppox.o
+obj-$(CONFIG_PPTP) += pppox.o pptp.o
diff --git a/drivers/net/bsd_comp.c b/drivers/net/ppp/bsd_comp.c
similarity index 100%
rename from drivers/net/bsd_comp.c
rename to drivers/net/ppp/bsd_comp.c
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp/ppp_async.c
similarity index 100%
rename from drivers/net/ppp_async.c
rename to drivers/net/ppp/ppp_async.c
diff --git a/drivers/net/ppp_deflate.c b/drivers/net/ppp/ppp_deflate.c
similarity index 100%
rename from drivers/net/ppp_deflate.c
rename to drivers/net/ppp/ppp_deflate.c
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
similarity index 100%
rename from drivers/net/ppp_generic.c
rename to drivers/net/ppp/ppp_generic.c
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
similarity index 100%
rename from drivers/net/ppp_mppe.c
rename to drivers/net/ppp/ppp_mppe.c
diff --git a/drivers/net/ppp_mppe.h b/drivers/net/ppp/ppp_mppe.h
similarity index 100%
rename from drivers/net/ppp_mppe.h
rename to drivers/net/ppp/ppp_mppe.h
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
similarity index 100%
rename from drivers/net/ppp_synctty.c
rename to drivers/net/ppp/ppp_synctty.c
diff --git a/drivers/net/pppoe.c b/drivers/net/ppp/pppoe.c
similarity index 100%
rename from drivers/net/pppoe.c
rename to drivers/net/ppp/pppoe.c
diff --git a/drivers/net/pppox.c b/drivers/net/ppp/pppox.c
similarity index 100%
rename from drivers/net/pppox.c
rename to drivers/net/ppp/pppox.c
diff --git a/drivers/net/pptp.c b/drivers/net/ppp/pptp.c
similarity index 100%
rename from drivers/net/pptp.c
rename to drivers/net/ppp/pptp.c
-- 
1.7.6
