From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Tue, 26 Oct 2004 01:37:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026053724.GA29080@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Still pushing pending stuff... this time, the "e1000", "janitor", and "mi=
sc" piles.

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 Documentation/networking/e100.txt  |  137 +++++++++++++++++++++--
 Documentation/networking/e1000.txt |  218 ++++++++++++++++++++++++++----=
-------
 Documentation/networking/ixgb.txt  |   36 ++----
 drivers/net/3c59x.c                |    2=20
 drivers/net/Kconfig                |  120 +++-----------------
 drivers/net/dummy.c                |    4=20
 drivers/net/e1000/e1000.h          |    2=20
 drivers/net/e1000/e1000_ethtool.c  |   13 +-
 drivers/net/e1000/e1000_hw.c       |  128 ++++++++++++++++++---
 drivers/net/e1000/e1000_main.c     |   43 ++-----
 drivers/net/e1000/e1000_osdep.h    |    6 +
 drivers/net/e1000/e1000_param.c    |  167 +++++++++++++++++-----------
 drivers/net/eql.c                  |   26 ++--
 drivers/net/hamradio/hdlcdrv.c     |    2=20
 drivers/net/ixgb/ixgb_main.c       |   10 +
 drivers/net/mac8390.c              |    4=20
 drivers/net/ne2k-pci.c             |   31 +++++
 drivers/net/ns83820.c              |  121 ++++++++++++++++++--
 drivers/net/pcnet32.c              |    6 -
 drivers/net/sis900.c               |   18 +--
 drivers/net/skfp/hwmtm.c           |    3=20
 drivers/net/slip.c                 |   39 +++---
 drivers/net/tokenring/olympic.c    |    1=20
 drivers/net/tulip/de2104x.c        |    3=20
 drivers/net/tulip/de4x5.c          |    2=20
 drivers/net/tulip/tulip_core.c     |   21 ++-
 drivers/net/tulip/xircom_cb.c      |   14 ++
 include/linux/netdevice.h          |    2=20
 net/Kconfig                        |   18 ---
 net/core/dev.c                     |   93 ---------------
 net/irda/irlan/irlan_client.c      |    2=20
 31 files changed, 791 insertions(+), 501 deletions(-)

through these ChangeSets:

<arjan:infradead.org>:
  o remove NET_HW_FLOWCONTROL

<pekon:fi.muni.cz>:
  o netpoll with xircom_cb

<sfeldma:pobox.com>:
  o janitor: net/tulip: pci_find_device to pci_dev_present
  o janitor: net/sis900: pci_find_device to pci_get_device

Adrian Bunk:
  o net/tokenring/olympic.c: remove unused variable

Andrew Morton:
  o e1000 module_param build fix
  o ne2k-pci pci build fix
  o e1000 sparc64 dma_mapping build fix
  o igxb speedup
  o de4x5 warning fix

Fran=E7ois Romieu:
  o via-velocity: wrong module name in Kconfig documentation

Ganesh Venkatesan:
  o ixgb: Configuration and user guide update
  o e100: Configuration and user guide update
  o e1000: Configuration and user guide update
  o e1000: white space corrections
  o e1000: driver version update
  o e1000: fix set ringparam for ethtool returning error code on bad inpu=
t
  o e1000: remove unused function e1000_enable_mng_pass_thru
  o e1000:  modified ethtool_set_pauseparam to use e1000_setup_link for f=
low control settings for fiber serdes link
  o e1000 update -- fix MODULE_PARM, module_param, module_param_array
  o e1000 - Ethtool -- 82545 do not support WoL
  o e1000 - Polarity reversal workaround for 10F/10H links
  o e1000 - Fix VLAN filter setup errors (while running on PPC)
  o e1000 Check value returned by from pci_enable_device
  o e1000 - Removed support for advanced TCO features
  o e1000 - use pci_device_name for syslog messages till registering netd=
evice.

Jeff Garzik:
  o Cset exclude: elf@buici.com|ChangeSet|20040920183610|08290

Jesse Brandeburg:
  o ixgb: fix endianness issue for tx cleanup

John W. Linville:
  o 3c59x: style change in vortex_ethtool_ops declaration

Kenji Kaneshige:
  o add missing pci_disable_device for e1000

Marc Singer:
  o adding smc91x ethernet to lpd7a40x

Mika Kukkonen:
  o sparse: fix warnings in net/irda/*

Neil Horman:
  o ns83820: add vlan tag hardware acceleration support

Nishanth Aravamudan:
  o net/de2104x: replace schedule_timeout() with msleep()

Olaf Hering:
  o remove old version check from mac8390

Pavel Machek:
  o swsuspend for ne2k-pci cards

Ralf B=E4chle:
  o Stop queue on close in hdlcdrv

Randy Dunlap:
  o skfp: remove assignment expression in conditional (sparse)(v2)
  o pcnet32: use unsigned 1-bit fields

Stephen Hemminger:
  o slip: use netdev_priv
  o slip: use module_param
  o dummy: use netdev_priv
  o eql: use netdev_priv
  o ns83820: use module_param

diff -Nru a/Documentation/networking/e100.txt b/Documentation/networking/=
e100.txt
--- a/Documentation/networking/e100.txt	2004-10-26 01:30:56 -04:00
+++ b/Documentation/networking/e100.txt	2004-10-26 01:30:56 -04:00
@@ -1,14 +1,16 @@
 Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-March 15, 2004
+September 13, 2004
=20
=20
 Contents
 =3D=3D=3D=3D=3D=3D=3D=3D
=20
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
+- Driver Configuration Parameters
+- Additional Configurations
 - Support
=20
=20
@@ -16,26 +18,140 @@
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 This file describes the Linux* Base Driver for the Intel(R) PRO/100 Fami=
ly of
-Adapters, version 3.x.x.  This driver includes support for Itanium(TM)-b=
ased=20
-systems.
+Adapters, version 3.2.x.  This driver includes support for Itanium(TM)2 =
and
+EM64T systems.
=20
=20
-Supported Adapters
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
-
-To verify that your adapter is supported, find the board ID number on th=
e=20
-adapter. Look for a label that has a barcode and a number in the format=20
-A12345-001. Match this to the list of numbers above.
+Identifying Your Adapter
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 For more information on how to identify your adapter, go to the Adapter =
&=20
 Driver ID Guide at:
=20
   http://support.intel.com/support/network/adapter/pro100/21397.htm
=20
-For the latest Intel PRO/100 network driver for Linux, see:
+For the latest Intel network drivers for Linux, refer to the following=20
+website. In the search field, enter your adapter name or type, or use th=
e=20
+networking link on the left to search for your adapter:
=20
   http://downloadfinder.intel.com/scripts-df/support_intel.asp
=20
+Driver Configuration Parameters
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
+
+The default value for each parameter is generally the recommended settin=
g,
+unless otherwise noted.
+
+Rx Descriptors: Number of receive descriptors. A receive descriptor is a=
 data=20
+   structure that describes a receive buffer and its attributes to the n=
etwork=20
+   controller. The data in the descriptor is used by the controller to w=
rite=20
+   data from the controller to host memory. In the 3.0.x driver the vali=
d
+   range for this parameter is 64-256. The default value is 64. This par=
ameter=20
+   can be changed using the command=20
+=20
+   ethtool -G eth? rx n, where n is the number of desired rx descriptors.
+
+Tx Descriptors: Number of transmit descriptors. A transmit descriptor is=
 a
+   data structure that describes a transmit buffer and its attributes to=
 the
+   network controller. The data in the descriptor is used by the control=
ler to=20
+   read data from the host memory to the controller. In the 3.0.x driver=
 the=20
+   valid range for this parameter is 64-256. The default value is 64. Th=
is=20
+   parameter can be changed using the command=20
+
+   ethtool -G eth? tx n, where n is the number of desired tx descriptors.
+
+Speed/Duplex: The driver auto-negotiates the link speed and duplex setti=
ngs by=20
+   default. Ethtool can be used as follows to force speed/duplex.=20
+
+   ethtool -s eth?  autoneg off speed {10|100} duplex {full|half}
+
+   NOTE: setting the speed/duplex to incorrect values will cause the lin=
k to
+   fail.
+
+Event Log Message Level:  The driver uses the message level flag to log =
events=20
+   to syslog. The message level can be set at driver load time. It can a=
lso be=20
+   set using the command
+
+   ethtool -s eth? msglvl n
+
+Additional Configurations
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
+
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+
+  Configuring a network driver to load properly when the system is start=
ed is=20
+  distribution dependent. Typically, the configuration process involves =
adding=20
+  an alias line to /etc/modules.conf as well as editing other system sta=
rtup=20
+  scripts and/or configuration files.  Many popular Linux distributions =
ship=20
+  with tools to make these changes for you. To learn the proper way to=20
+  configure a network device for your system, refer to your distribution=
=20
+  documentation. If during this process you are asked for the driver or =
module=20
+  name, the name for the Linux Base Driver for the Intel PRO/100 Family =
of=20
+  Adapters is e100.
+
+  As an example, if you install the e100 driver for two PRO/100 adapters=
=20
+  (eth0 and eth1), add the following to modules.conf:
+
+       alias eth0 e100
+       alias eth1 e100
+
+  Viewing Link Messages
+  ---------------------
+  In order to see link messages and other Intel driver information on yo=
ur=20
+  console, you must set the dmesg level up to six. This can be done by=20
+  entering the following on the command line before loading the e100 dri=
ver:=20
+
+       dmesg -n 8
+
+  If you wish to see all messages issued by the driver, including debug=20
+  messages, set the dmesg level to eight.
+
+  NOTE: This setting is not saved across reboots.
+
+  Ethtool
+  -------
+
+  The driver utilizes the ethtool interface for driver configuration and
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found at:
+  http://sf.net/projects/gkernel. =20
+
+  After ethtool is installed, ethtool-copy.h must be copied and renamed =
to
+  ethtool.h in your kernel source tree at <linux_kernel_src>/include/lin=
ux. =20
+  Backup the original ethtool.h as needed before copying.  The driver th=
en=20
+  must be recompiled in order to take advantage of the latest ethtool=20
+  features.
+
+  NOTE: This driver uses mii support from the kernel. As a result, when=20
+  there is no link, ethtool will report speed/duplex to be 10/half.
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Supp=
ort=20
+  for a more complete ethtool feature set can be enabled by upgrading=20
+  ethtool to ethtool-1.8.1.=20
+
+  Enabling Wake on LAN* (WoL)
+  ---------------------------
+  WoL is provided through the Ethtool* utility. Ethtool is included with=
 Red=20
+  Hat* 8.0. For other Linux distributions, download and install Ethtool =
from=20
+  the following website: http://sourceforge.net/projects/gkernel.=20
+
+  For instructions on enabling WoL with Ethtool, refer to the Ethtool ma=
n
+  page.
+
+  WoL will be enabled on the system during the next shut down or reboot.=
 For
+  this driver version, in order to enable WoL, the e100 driver must be=20
+  loaded when shutting down or rebooting the system.
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the e100 driver. NAPI is enable=
d
+  or disabled based on the configuration of the kernel.=20
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
=20
 Support
 =3D=3D=3D=3D=3D=3D=3D
diff -Nru a/Documentation/networking/e1000.txt b/Documentation/networking=
/e1000.txt
--- a/Documentation/networking/e1000.txt	2004-10-26 01:30:56 -04:00
+++ b/Documentation/networking/e1000.txt	2004-10-26 01:30:56 -04:00
@@ -1,14 +1,14 @@
 Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-January 8, 2003
+September 13, 2004
=20
=20
 Contents
 =3D=3D=3D=3D=3D=3D=3D=3D
=20
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
 - Command Line Parameters
 - Speed and Duplex Configuration
 - Additional Configurations
@@ -20,63 +20,29 @@
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 This file describes the Linux* Base Driver for the Intel(R) PRO/1000 Fam=
ily
-of Adapters, version 5.0.x.  This driver includes support for=20
-Itanium(TM)-based systems.
+of Adapters, version 5.x.x.  This driver includes support for Itanium(TM=
)2=20
+and EM64T systems.
=20
+For questions related to hardware requirements, refer to the documentati=
on=20
+supplied with your Intel PRO/1000 adapter. All hardware requirements lis=
ted=20
+apply to use with Linux.
=20
 Native VLANs are now available with supported kernels.
=20
-
-Supported Adapters
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
-
-The following Intel network adapters are compatible with the drivers in =
this=20
-release:
-
-   Controller  Adapter Name                         Board IDs
-   ----------  ------------                         ---------
-
-   82542       PRO/1000 Gigabit Server Adapter      700262-xxx, 717037-x=
xx
-
-   82543       PRO/1000 F Server Adapter            738640-xxx, A38888-x=
xx
-
-   82543       PRO/1000 T Server Adapter            A19845-xxx, A33948-x=
xx
-
-   82544       PRO/1000 XT Server Adapter           A51580-xxx
-
-   82544       PRO/1000 XF Server Adapter           A50484-xxx
-
-   82544       PRO/1000 T Desktop Adapter           A62947-xxx
-
-   82540       PRO/1000 MT Desktop Adapter          A78408-xxx
-   82541                                            C91016-xxx
-
-   82545       PRO/1000 MT Server Adapter           A92165-xxx
-
-   82546       PRO/1000 MT Dual Port Server Adapter A92111-xxx
-
-   82545       PRO/1000 MF Server Adapter           A91622-xxx
-
-   82545       PRO/1000 MF Server Adapter(LX)       A91624-xxx
-
-   82546       PRO/1000 MF Dual Port Server Adapter A91620-xxx
-
-
-
-To verify your Intel adapter is supported, find the board ID number on t=
he=20
-adapter. Look for a label that has a barcode and a number in the format =
=20
-A12345-001. Match this to the list of numbers above.
+Identifying Your Adapter
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 For more information on how to identify your adapter, go to the Adapter =
&=20
 Driver ID Guide at:
=20
     http://support.intel.com/support/network/adapter/pro100/21397.htm
=20
-For the latest Intel network drivers for Linux, refer to the following
+For the latest Intel network drivers for Linux, refer to the following=20
+website. In the search field, enter your adapter name or type, or use th=
e=20
+networking link on the left to search for your adapter:
=20
     http://downloadfinder.intel.com/scripts-df/support_intel.asp
=20
-
 Command Line Parameters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
@@ -92,27 +58,39 @@
=20
      insmod e1000 TxDescriptors=3D80,128
=20
-loads the e1000 driver with 80 TX resources for the first adapter and 12=
8 TX=20
-resources for the second adapter.
+loads the e1000 driver with 80 TX descriptors for the first adapter and =
128 TX=20
+descriptors for the second adapter.
=20
 The default value for each parameter is generally the recommended settin=
g,
-unless otherwise noted.
-
-For more information about the AutoNeg, Duplex, and Speed parameters, se=
e the
-"Speed and Duplex Configuration" section in this document.
+unless otherwise noted. Also, if the driver is statically built into the
+kernel, the driver is loaded with the default values for all the paramet=
ers.
+Ethtool can be used to change some of the parameters at runtime.
+
+    NOTES: For more information about the AutoNeg, Duplex, and Speed
+           parameters, see the "Speed and Duplex Configuration" section =
in=20
+           this document.
+
+           For more information about the InterruptThrottleRate, RxIntDe=
lay,=20
+           TxIntDelay, RxAbsIntDelay, and TxAbsIntDelay parameters, see =
the=20
+           application note at:
+           http://www.intel.com/design/network/applnots/ap450.htm
=20
+           A descriptor describes a data buffer and attributes related t=
o the=20
+           data buffer. This information is accessed by the hardware.
=20
 AutoNeg (adapters using copper connections only)
 Valid Range: 0x01-0x0F, 0x20-0x2F
 Default Value: 0x2F
     This parameter is a bit mask that specifies which speed and duplex
     settings the board advertises. When this parameter is used, the Spee=
d and
-    Duplex parameters must not be specified. =20
+    Duplex parameters must not be specified.
+    NOTE: Refer to the Speed and Duplex section of this readme for more=20
+          information on the AutoNeg parameter. =20
=20
 Duplex (adapters using copper connections only)
 Valid Range: 0-2 (0=3Dauto-negotiate, 1=3Dhalf, 2=3Dfull)
 Default Value: 0
-    Defines the direction in which data is allowed to flow. Can by eithe=
r one=20
+    Defines the direction in which data is allowed to flow. Can be eithe=
r one=20
     or two-directional. If both Duplex and the link partner are set to a=
uto-
     negotiate, the board auto-detects the correct duplex. If the link pa=
rtner
     is forced (either full or half), Duplex defaults to half-duplex.
@@ -125,22 +103,46 @@
=20
 InterruptThrottleRate
 Valid Range: 100-100000 (0=3Doff, 1=3Ddynamic)
-Default Value: 1
+Default Value: 8000
     This value represents the maximum number of interrupts per second th=
e=20
     controller generates. InterruptThrottleRate is another setting used =
in=20
     interrupt moderation. Dynamic mode uses a heuristic algorithm to adj=
ust=20
     InterruptThrottleRate based on the current traffic load.
+Un-supported Adapters: InterruptThrottleRate is NOT supported by 82542, =
82543
+    or 82544-based adapters.
=20
     NOTE: InterruptThrottleRate takes precedence over the TxAbsIntDelay =
and=20
           RxAbsIntDelay parameters. In other words, minimizing the recei=
ve=20
           and/or transmit absolute delays does not force the controller =
to=20
           generate more interrupts than what the Interrupt Throttle Rate=
=20
           allows.
+    CAUTION: If you are using the Intel PRO/1000 CT Network Connection=20
+             (controller 82547), setting InterruptThrottleRate to a valu=
e=20
+             greater than 75,000, may hang (stop transmitting) adapters =
under=20
+             certain network conditions. If this occurs a NETDEV WATCHDO=
G=20
+             message is logged in the system event log. In addition, the=
=20
+             controller is automatically reset, restoring the network=20
+             connection. To eliminate the potential for the hang, ensure=
=20
+             that InterruptThrottleRate is set no greater than 75,000 an=
d is=20
+             not set to 0.
+    NOTE: When e1000 is loaded with default settings and multiple adapte=
rs are=20
+          in use simultaneously, the CPU utilization may increase non-li=
nearly.=20
+          In order to limit the CPU utilization without impacting the ov=
erall=20
+          throughput, we recommend that you load the driver as follows:
+
+              insmod e1000.o InterruptThrottleRate=3D3000,3000,3000
+
+          This sets the InterruptThrottleRate to 3000 interrupts/sec for=
 the=20
+          first, second, and third instances of the driver. The range of=
 2000 to=20
+          3000 interrupts per second works on a majority of systems and =
is a=20
+          good starting point, but the optimal value will be platform-sp=
ecific.=20
+          If CPU utilization is not a concern, use RX_POLLING (NAPI) and=
 default=20
+          driver settings.
=20
 RxDescriptors
 Valid Range: 80-256 for 82542 and 82543-based adapters
-             80-4096 for 82540, 82544, 82545, and 82546-based adapters
-Default Value: 80
+             80-4096 for all other supported adapters
+Default Value: 256
     This value is the number of receive descriptors allocated by the dri=
ver.=20
     Increasing this value allows the driver to buffer more incoming pack=
ets.=20
     Each descriptor is 16 bytes.  A receive buffer is also allocated for=
 each
@@ -149,6 +151,9 @@
=20
     NOTE: MTU designates the frame size. It only needs to be set for Jum=
bo=20
           Frames.
+    NOTE: Depending on the available system resources, the request for a
+    higher number of receive descriptors may be denied.  In this case,
+    use a lower number.
=20
 RxIntDelay
 Valid Range: 0-65535 (0=3Doff)
@@ -168,11 +173,11 @@
              restoring the network connection. To eliminate the potentia=
l for
              the hang ensure that RxIntDelay is set to 0.
=20
-RxAbsIntDelay (82540, 82545, and 82546-based adapters only)
+RxAbsIntDelay (82540, 82545 and later adapters only)
 Valid Range: 0-65535 (0=3Doff)
 Default Value: 128
     This value, in units of 1.024 microseconds, limits the delay in whic=
h a=20
-    transmit interrupt is generated. Useful only if RxIntDelay is non-ze=
ro,=20
+    receive interrupt is generated. Useful only if RxIntDelay is non-zer=
o,=20
     this value ensures that an interrupt is generated after the initial=20
     packet is received within the set amount of time.  Proper tuning,
     along with RxIntDelay, may improve traffic throughput in specific ne=
twork
@@ -188,12 +193,16 @@
=20
 TxDescriptors
 Valid Range: 80-256 for 82542 and 82543-based adapters
-             80-4096 for 82540, 82544, 82545, and 82546-based adapters
+             80-4096 for all other supported adapters
 Default Value: 256
     This value is the number of transmit descriptors allocated by the dr=
iver.
     Increasing this value allows the driver to queue more transmits. Eac=
h=20
     descriptor is 16 bytes.
=20
+    NOTE: Depending on the available system resources, the request for a
+    higher number of transmit descriptors may be denied.  In this case,
+    use a lower number.
+
 TxIntDelay
 Valid Range: 0-65535 (0=3Doff)
 Default Value: 64
@@ -203,7 +212,7 @@
     system is reporting dropped transmits, this value may be set too hig=
h
     causing the driver to run out of available transmit descriptors.
=20
-TxAbsIntDelay (82540, 82545, and 82546-based adapters only)
+TxAbsIntDelay (82540, 82545 and later adapters only)
 Valid Range: 0-65535 (0=3Doff)
 Default Value: 64
     This value, in units of 1.024 microseconds, limits the delay in whic=
h a=20
@@ -219,7 +228,6 @@
     A value of '1' indicates that the driver should enable IP checksum
     offload for received packets (both UDP and TCP) to the adapter hardw=
are.
=20
-
 Speed and Duplex Configuration
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
=20
@@ -251,6 +259,10 @@
 Speed (Mbps)   N/A    N/A    1000    N/A     100    100    10      10
 Duplex                       Full            Full   Half   Full    Half
=20
+For example to limit the negotiated speed/duplex on the interface to 10 =
Mbps=20
+Half or Full duplex, set AutoNeg to 0x02:=20
+    insmod e1000 AutoNeg=3D0x02
+
 Note that setting AutoNeg does not guarantee that the board will link at=
 the=20
 highest specified speed or duplex mode, but the board will link at the=20
 highest possible speed/duplex of the link partner IF the link partner is=
 also
@@ -261,6 +273,38 @@
 Additional Configurations
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
=20
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+
+  Configuring a network driver to load properly when the system is start=
ed is
+  distribution dependent. Typically, the configuration process involves =
adding
+  an alias line to /etc/modules.conf as well as editing other system sta=
rtup=20
+  scripts and/or configuration files. Many popular Linux distributions s=
hip=20
+  with tools to make these changes for you. To learn the proper way to=20
+  configure a network device for your system, refer to your distribution=
=20
+  documentation. If during this process you are asked for the driver or =
module=20
+  name, the name for the Linux Base Driver for the Intel PRO/1000 Family=
 of=20
+  Adapters is e1000.
+
+  As an example, if you install the e1000 driver for two PRO/1000 adapte=
rs=20
+  (eth0 and eth1) and set the speed and duplex to 10full and 100half, ad=
d the=20
+  following to modules.conf:
+
+       alias eth0 e1000
+       alias eth1 e1000
+       options e1000 Speed=3D10,100 Duplex=3D2,1
+
+  Viewing Link Messages
+  ---------------------
+
+  Link messages will not be displayed to the console if the distribution=
 is=20
+  restricting system messages. In order to see network driver link messa=
ges on=20
+  your console, set dmesg to eight by entering the following:
+
+       dmesg -n 8
+
+  NOTE: This setting is not saved across reboots.
+
   Jumbo Frames
   ------------
=20
@@ -278,6 +322,51 @@
   10 or 100 Mbps may result in poor performance or loss of link.
=20
=20
+  NOTE: MTU designates the frame size. To enable Jumbo Frames, increase =
the
+  MTU size on the interface beyond 1500.
+
+  Ethtool
+  -------
+
+  The driver utilizes the ethtool interface for driver configuration and
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found from
+  http://sf.net/projects/gkernel.  After ethtool is installed,
+  ethtool-copy.h must be copied and renamed to ethtool.h in your kernel
+  source tree at <linux_kernel_src>/include/linux.  Backup the original
+  ethtool.h as needed before copying.  The driver then must be recompile=
d
+  in order to take advantage of the latest ethtool features.
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Supp=
ort=20
+  for a more complete ethtool feature set can be enabled by upgrading=20
+  ethtool to ethtool-1.8.1.=20
+
+  Enabling Wake on LAN* (WoL)
+  ---------------------------
+
+  WoL is configured through the Ethtool* utility. Ethtool is included wi=
th
+  all versions of Red Hat after Red Hat 7.2. For other Linux distributio=
ns,=20
+  download and install Ethtool from the following website:=20
+  http://sourceforge.net/projects/gkernel.
+
+  For instructions on enabling WoL with Ethtool, refer to the website li=
sted=20
+  above.
+
+  WoL will be enabled on the system during the next shut down or reboot.=
=20
+  For this driver version, in order to enable WoL, the e1000 driver must=
 be=20
+  loaded when shutting down or rebooting the system.
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the e1000 driver. NAPI is enabl=
ed
+  or disabled based on the configuration of the kernel.=20
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
+
+
 Known Issues
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
@@ -285,9 +374,9 @@
   -------------------------------
=20
   Memory allocation failures have been observed on Linux systems with 64=
 MB=20
-  of RAM or less that are running Jumbo Frames. If you are using Jumbo=20
-  Frames, your system may require more than the advertised minimum=20
-  requirement of 64 MB of system memory.
+  of RAM or less that are running Jumbo Frames. If you are using Jumbo F=
rames,
+  your system may require more than the advertised minimum requirement o=
f 64 MB
+  of system memory.
=20
=20
 Support
diff -Nru a/Documentation/networking/ixgb.txt b/Documentation/networking/=
ixgb.txt
--- a/Documentation/networking/ixgb.txt	2004-10-26 01:30:56 -04:00
+++ b/Documentation/networking/ixgb.txt	2004-10-26 01:30:56 -04:00
@@ -1,14 +1,14 @@
 Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-January 06, 2003
+September 13, 2004
=20
=20
 Contents
 =3D=3D=3D=3D=3D=3D=3D=3D
=20
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
 - Command Line Parameters
 - Improving Performance
 - Support
@@ -18,36 +18,23 @@
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE Fa=
mily=20
-of Adapters, version 1.0.x. This driver is intended for 2.4.x kernels; i=
t is=20
-known to build properly on 2.4.x kernels through 2.4.18. Intel focused=20
-testing on Intel architectures running kernels 2.4.18. This driver inclu=
des=20
-support for Itanium(TM)-based systems.
+of Adapters, version 1.0.x.  This driver includes support for Itanium(TM=
)2 and
+EM64T systems.
=20
 For questions related to hardware requirements, refer to the documentati=
on=20
 supplied with your Intel PRO/10GbE adapter. All hardware requirements li=
sted=20
 apply to use with Linux.
=20
-
-Supported Adapters
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
-
-The following Intel network adapters are compatible with the drivers in =
this=20
-release:
-
-   Controller  Adapter Name                           Board IDs
-   ----------  ------------                           ---------
-
-   82597EX     Intel(R) PRO/10GbE LR Server Adapter   A82505-xxx
-
+Identifying Your Adapter
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 To verify your Intel adapter is supported, find the board ID number on t=
he=20
 adapter. Look for a label that has a barcode and a number in the format =
=20
-A12345-001. Match this to the list of numbers above.
+A12345-001.=20
=20
-For more information on how to identify your adapter, go to the Adapter =
&=20
-Driver ID Guide at:
+Use the above information and the Adapter & Driver ID Guide at:
=20
-    http://support.intel.com/support/network/adapter/pro100/21397.htm
+  http://support.intel.com/support/network/adapter/pro100/21397.htm
=20
 For the latest Intel network drivers for Linux, go to:
=20
@@ -72,8 +59,9 @@
 resources for the second adapter.
=20
 The default value for each parameter is generally the recommended settin=
g,
-unless otherwise noted.
-
+unless otherwise noted. Also, if the driver is statically built into the
+kernel, the driver is loaded with the default values for all the paramet=
ers.
+Ethtool can be used to change some of the parameters at runtime.
=20
 FlowControl
 Valid Range: 0-3 (0=3Dnone, 1=3DRx only, 2=3DTx only, 3=3DRx&Tx)
@@ -124,7 +112,6 @@
     A value of '1' indicates that the driver should enable IP checksum
     offload for transmitted packets (both UDP and TCP) to the adapter=20
     hardware.
-
=20
 Improving Performance
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/3c59x.c	2004-10-26 01:30:56 -04:00
@@ -2887,7 +2887,7 @@
 }
=20
 static struct ethtool_ops vortex_ethtool_ops =3D {
-	.get_drvinfo =3D		vortex_get_drvinfo,
+	.get_drvinfo		=3D vortex_get_drvinfo,
 };
=20
 #ifdef CONFIG_PCI
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/Kconfig	2004-10-26 01:30:56 -04:00
@@ -1413,66 +1413,17 @@
 	depends on NET_PCI && PCI
 	select MII
 	---help---
-	  This driver supports Intel(R) PRO/100 family of adapters, which=20
-	  includes:
-
-	  Controller  Adapter Name                       Board IDs
-	  ----------  ------------                       ---------
-
-	  82558       PRO/100+ PCI Adapter               668081-xxx,=20
-	  689661-xxx
-	  82558       PRO/100+ Management Adapter        691334-xxx,=20
-	  701738-xxx,
-	  721383-xxx
-	  82558       PRO/100+ Dual Port Server Adapter  714303-xxx,=20
-	  711269-xxx,=20
-	  A28276-xxx
-	  82558       PRO/100+ PCI Server Adapter        710550-xxx
-	  82550       PRO/100 S Server Adapter           752438-xxx
-	  82559                                          A56831-xxx,=20
-	  A10563-xxx,
-	  A12171-xxx,=20
-	  A12321-xxx,=20
-	  A12320-xxx,=20
-	  A12170-xxx
-	  748568-xxx
-	  748565-xxx
-	  82550       PRO/100 S Desktop Adapter          751767-xxx
-	  82559                                          748592-xxx,=20
-	  A12167-xxx,=20
-	  A12318-xxx,=20
-	  A12317-xxx,=20
-	  A12165-xxx,
-	  748569-xxx=20
-	  82559       PRO/100+ Server Adapter            729757-xxx
-	  82559       PRO/100 S Management Adapter       748566-xxx,=20
-	  748564-xxx
-	  82550       PRO/100 S Dual Port Server Adapter A56831-xxx
-	  82551       PRO/100 M Desktop Adapter          A80897-xxx
-	  PRO/100 S Advanced Management Adapter=20
-	  747842-xxx,=20
-	  745171-xxx
-	  CNR         PRO/100 VE Desktop Adapter         A10386-xxx,=20
-	  A10725-xxx,=20
-	  A23801-xxx,=20
-	  A19716-xxx
-	  PRO/100 VM Desktop Adapter         A14323-xxx,=20
-	  A19725-xxx,=20
-	  A23801-xxx,=20
-	  A22220-xxx,=20
-	  A23796-xxx
-
-
+	  This driver supports Intel(R) PRO/100 family of adapters.
 	  To verify that your adapter is supported, find the board ID number=20
 	  on the adapter. Look for a label that has a barcode and a number=20
-	  in the format 123456-001 (six digits hyphen three digits). Match=20
-	  this to the list of numbers above.
+	  in the format 123456-001 (six digits hyphen three digits).=20
=20
-	  For more information on how to identify your adapter, go to the=20
-	  Adapter & Driver ID Guide at:
+	  Use the above information and the Adapter & Driver ID Guide at:
=20
 	  http://support.intel.com/support/network/adapter/pro100/21397.htm
=20
+          to identify the adapter.
+
 	  For the latest Intel PRO/100 network driver for Linux, see:
=20
 	  http://appsr.intel.com/scripts-df/support_intel.asp
@@ -1730,7 +1681,7 @@
 	  (e.g. VT8235).
=20
 	  To compile this driver as a module, choose M here. The module
-	  will be called via-rhine.
+	  will be called via-velocity.
=20
 config VIA_RHINE_MMIO
 	bool "Use MMIO instead of PIO"
@@ -1742,18 +1693,6 @@
=20
 	  If unsure, say Y.
=20
-config VIA_VELOCITY
-	tristate "VIA Velocity support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select CRC_CCITT
-	select MII
-	help
-	  If you have a VIA "Velocity" based network card say Y here.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called via-velocity.
-
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support (EXPERIMENTAL)"
 	depends on NET_PCI && EXPERIMENTAL && MIPS
@@ -1933,29 +1872,8 @@
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-	  adapters, which includes:
-
-	  Controller  Adapter Name                         Board IDs
-	  ----------  ------------                         ---------
-	  82542       PRO/1000 Gigabit Server Adapter      700262-xxx,
-	  717037-xxx
-	  82543       PRO/1000 F Server Adapter            738640-xxx,
-	  A38888-xxx
-	  82543       PRO/1000 T Server Adapter            A19845-xxx,
-	  A33948-xxx
-	  82544       PRO/1000 XT Server Adapter           A51580-xxx
-	  82544       PRO/1000 XF Server Adapter           A50484-xxx
-	  82544       PRO/1000 T Desktop Adapter           A62947-xxx
-	  82540       PRO/1000 MT Desktop Adapter          A78408-xxx
-	  82541       PRO/1000 MT Desktop Adapter          C91016-xxx
-	  82545       PRO/1000 MT Server Adapter           A92165-xxx
-	  82546       PRO/1000 MT Dual Port Server Adapter A92111-xxx
-	  82545       PRO/1000 MF Server Adapter           A91622-xxx
-	  82545       PRO/1000 MF Server Adapter(LX)       A91624-xxx
-	  82546       PRO/1000 MF Dual Port Server Adapter A91620-xxx=20
-
-	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide at:
+	  adapters.  For more information on how to identify your adapter, go=20
+	  to the Adapter & Driver ID Guide at:
=20
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
=20
@@ -2140,6 +2058,18 @@
 	  say M here and read Documentation/kbuild/modules.txt. The module will
 	  be called sk98lin. This is recommended.
=20
+config VIA_VELOCITY
+	tristate "VIA Velocity support"
+	depends on NET_PCI && PCI
+	select CRC32
+	select CRC_CCITT
+	select MII
+	help
+	  If you have a VIA "Velocity" based network card say Y here.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called via-velocity.
+
 config TIGON3
 	tristate "Broadcom Tigon3 support"
 	depends on PCI
@@ -2202,14 +2132,8 @@
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/10GbE family of
-	  adapters, which includes:
-
-	  Controller  Adapter Name                           Board IDs
-	  ----------  ------------                           ---------
-	  82597EX     Intel(R) PRO/10GbE LR Server Adapter   A82505-xxx
-
-	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide at:
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
=20
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
=20
diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/dummy.c	2004-10-26 01:30:56 -04:00
@@ -77,7 +77,7 @@
=20
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats =3D dev->priv;
+	struct net_device_stats *stats =3D netdev_priv(dev);
=20
 	stats->tx_packets++;
 	stats->tx_bytes+=3Dskb->len;
@@ -88,7 +88,7 @@
=20
 static struct net_device_stats *dummy_get_stats(struct net_device *dev)
 {
-	return dev->priv;
+	return netdev_priv(dev);
 }
=20
 static struct net_device **dummies;
diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000.h	2004-10-26 01:30:56 -04:00
@@ -64,7 +64,6 @@
 #include <linux/udp.h>
 #include <net/pkt_sched.h>
 #include <linux/list.h>
-#include <linux/rtnetlink.h>
 #include <linux/reboot.h>
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
@@ -73,7 +72,6 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
-#include <linux/moduleparam.h>
=20
 #define BAR_0		0
 #define BAR_1		1
diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_e=
thtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000_ethtool.c	2004-10-26 01:30:56 -04:00
@@ -249,7 +249,8 @@
 			e1000_reset(adapter);
 	}
 	else
-		return e1000_force_mac_fc(hw);
+		return ((hw->media_type =3D=3D e1000_media_type_fiber) ?
+			e1000_setup_link(hw) : e1000_force_mac_fc(hw));
 =09
 	return 0;
 }
@@ -592,6 +593,9 @@
 	tx_old =3D adapter->tx_ring;
 	rx_old =3D adapter->rx_ring;
=20
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))=20
+		return -EINVAL;
+
 	if(netif_running(adapter->netdev))
 		e1000_down(adapter);
=20
@@ -637,7 +641,6 @@
 	return err;
 }
=20
-
 #define REG_PATTERN_TEST(R, M, W)                                       =
       \
 {                                                                       =
       \
 	uint32_t pat, value;                                                   =
\
@@ -1017,8 +1020,8 @@
 		struct e1000_rx_desc *rx_desc =3D E1000_RX_DESC(*rxdr, i);
 		struct sk_buff *skb;
=20
-		if(!(skb =3D alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,
-				     GFP_KERNEL))) {
+		if(!(skb =3D alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,=20
+				GFP_KERNEL))) {
 			ret_val =3D 6;
 			goto err_nomem;
 		}
@@ -1442,6 +1445,8 @@
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
 	case E1000_DEV_ID_82546EB_QUAD_COPPER:
+	case E1000_DEV_ID_82545EM_FIBER:
+	case E1000_DEV_ID_82545EM_COPPER:
 		wol->supported =3D 0;
 		wol->wolopts   =3D 0;
 		return;
diff -Nru a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
--- a/drivers/net/e1000/e1000_hw.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000_hw.c	2004-10-26 01:30:56 -04:00
@@ -65,6 +65,7 @@
 static void e1000_standby_eeprom(struct e1000_hw *hw);
 static int32_t e1000_id_led_init(struct e1000_hw * hw);
 static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
+static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
=20
 /* IGP cable length table */
@@ -1594,6 +1595,15 @@
         ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_=
data);
         if(ret_val)
             return ret_val;
+
+        if((hw->mac_type =3D=3D e1000_82544 || hw->mac_type =3D=3D e1000=
_82543) &&
+           (!hw->autoneg) &&
+           (hw->forced_speed_duplex =3D=3D e1000_10_full ||
+            hw->forced_speed_duplex =3D=3D e1000_10_half)) {
+            ret_val =3D e1000_polarity_reversal_workaround(hw);
+            if(ret_val)
+                return ret_val;
+        }
     }
     return E1000_SUCCESS;
 }
@@ -1983,6 +1993,7 @@
     uint32_t ctrl;
     uint32_t status;
     uint32_t rctl;
+    uint32_t icr;
     uint32_t signal =3D 0;
     int32_t ret_val;
     uint16_t phy_data;
@@ -2032,6 +2043,25 @@
              * link-up */
             e1000_check_downshift(hw);
=20
+            /* If we are on 82544 or 82543 silicon and speed/duplex
+             * are forced to 10H or 10F, then we will implement the pola=
rity
+             * reversal workaround.  We disable interrupts first, and up=
on
+             * returning, place the devices interrupt state to its previ=
ous
+             * value except for the link status change interrupt which w=
ill
+             * happen due to the execution of this workaround.
+             */
+
+            if((hw->mac_type =3D=3D e1000_82544 || hw->mac_type =3D=3D e=
1000_82543) &&
+               (!hw->autoneg) &&
+               (hw->forced_speed_duplex =3D=3D e1000_10_full ||
+                hw->forced_speed_duplex =3D=3D e1000_10_half)) {
+                E1000_WRITE_REG(hw, IMC, 0xffffffff);
+                ret_val =3D e1000_polarity_reversal_workaround(hw);
+                icr =3D E1000_READ_REG(hw, ICR);
+                E1000_WRITE_REG(hw, ICS, (icr & ~E1000_ICS_LSC));
+                E1000_WRITE_REG(hw, IMS, IMS_ENABLE_MASK);
+            }
+
         } else {
             /* No link detected */
             e1000_config_dsp_after_link_change(hw, FALSE);
@@ -5191,28 +5221,88 @@
     return E1000_SUCCESS;
 }
=20
-/***********************************************************************=
*******
- * Verifies the hardware needs to allow ARPs to be processed by the host
- *
- * hw - Struct containing variables accessed by shared code
- *
- * returns: - TRUE/FALSE
- *
- ***********************************************************************=
******/
-uint32_t
-e1000_enable_mng_pass_thru(struct e1000_hw *hw)
+static int32_t
+e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
-    uint32_t manc;
+    int32_t ret_val;
+    uint16_t mii_status_reg;
+    uint16_t i;
=20
-    if (hw->asf_firmware_present) {
-        manc =3D E1000_READ_REG(hw, MANC);
+    /* Polarity reversal workaround for forced 10F/10H links. */
+
+    /* Disable the transmitter on the PHY */
+
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0019=
);
+    if(ret_val)
+        return ret_val;
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFFFF=
);
+    if(ret_val)
+        return ret_val;
+
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0000=
);
+    if(ret_val)
+        return ret_val;
+
+    /* This loop will early-out if the NO link condition has been met. *=
/
+    for(i =3D PHY_FORCE_TIME; i > 0; i--) {
+        /* Read the MII Status Register and wait for Link Status bit
+         * to be clear.
+         */
+
+        ret_val =3D e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        ret_val =3D e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        if((mii_status_reg & ~MII_SR_LINK_STATUS) =3D=3D 0) break;
+        msec_delay_irq(100);
+    }
+
+    /* Recommended delay time after link has been lost */
+    msec_delay_irq(1000);
+
+    /* Now we will re-enable th transmitter on the PHY */
+
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0019=
);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFFF0=
);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFF00=
);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0x0000=
);
+    if(ret_val)
+        return ret_val;
=20
-        if (!(manc & E1000_MANC_RCV_TCO_EN) ||
-            !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
-            return FALSE;
-        if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
-            return TRUE;
+    ret_val =3D e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0000=
);
+    if(ret_val)
+        return ret_val;
+
+    /* This loop will early-out if the link condition has been met. */
+    for(i =3D PHY_FORCE_TIME; i > 0; i--) {
+        /* Read the MII Status Register and wait for Link Status bit
+         * to be set.
+         */
+
+        ret_val =3D e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        ret_val =3D e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        if(mii_status_reg & MII_SR_LINK_STATUS) break;
+        msec_delay_irq(100);
     }
-    return FALSE;
+    return E1000_SUCCESS;
 }
=20
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main=
.c
--- a/drivers/net/e1000/e1000_main.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000_main.c	2004-10-26 01:30:56 -04:00
@@ -48,7 +48,7 @@
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] =3D "5.3.19-k2"DRIVERNAPI;
+char e1000_driver_version[] =3D "5.5.4-k2"DRIVERNAPI;
 char e1000_copyright[] =3D "Copyright (c) 1999-2004 Intel Corporation.";
=20
 /* e1000_pci_tbl - PCI Device ID Table
@@ -311,7 +311,8 @@
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba, manc;
+	uint32_t pba;
+
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
@@ -354,12 +355,6 @@
=20
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
-
-	if(adapter->en_mng_pt) {
-		manc =3D E1000_READ_REG(&adapter->hw, MANC);
-		manc |=3D (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
-	}
 }
=20
 /**
@@ -422,11 +417,6 @@
 	adapter->hw.back =3D adapter;
 	adapter->msg_enable =3D (1 << debug) - 1;
=20
-	rtnl_lock();
-	/* we need to set the name early for the DPRINTK macro */
-	if(dev_alloc_name(netdev, netdev->name) < 0)
-		goto err_free_unlock;
-
 	mmio_start =3D pci_resource_start(pdev, BAR_0);
 	mmio_len =3D pci_resource_len(pdev, BAR_0);
=20
@@ -466,6 +456,7 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller =3D e1000_netpoll;
 #endif
+	strcpy(netdev->name, pci_name(pdev));
=20
 	netdev->mem_start =3D mmio_start;
 	netdev->mem_end =3D mmio_start + mmio_len;
@@ -502,8 +493,6 @@
  	/* hard_start_xmit is safe against parallel locking */
  	netdev->features |=3D NETIF_F_LLTX;=20
 =20
-	adapter->en_mng_pt =3D e1000_enable_mng_pass_thru(&adapter->hw);
-
 	/* before reading the EEPROM, reset the controller to=20
 	 * put the device in a known good starting state */
 =09
@@ -553,7 +542,6 @@
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
=20
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
 	e1000_check_options(adapter);
=20
 	/* Initial Wake on LAN setting
@@ -586,12 +574,13 @@
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
=20
-	/* We're already holding the rtnl lock; call the no-lock version */
-	if((err =3D register_netdevice(netdev)))
+	strcpy(netdev->name, "eth%d");
+	if((err =3D register_netdev(netdev)))
 		goto err_register;
=20
+	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
+
 	cards_found++;
-	rtnl_unlock();
 	return 0;
=20
 err_register:
@@ -599,8 +588,6 @@
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
-err_free_unlock:
-	rtnl_unlock();
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
@@ -641,6 +628,8 @@
 	pci_release_regions(pdev);
=20
 	free_netdev(netdev);
+
+	pci_disable_device(pdev);
 }
=20
 /**
@@ -2335,8 +2324,8 @@
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->special &
-						 E1000_RXD_SPC_VLAN_MASK));
+					le16_to_cpu(rx_desc->special) &
+					E1000_RXD_SPC_VLAN_MASK);
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -2344,8 +2333,8 @@
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->special &
-					E1000_RXD_SPC_VLAN_MASK));
+					le16_to_cpu(rx_desc->special) &
+					E1000_RXD_SPC_VLAN_MASK);
 		} else {
 			netif_rx(skb);
 		}
@@ -2894,9 +2883,9 @@
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter =3D netdev->priv;
-	uint32_t manc;
+	uint32_t manc, ret;
=20
-	pci_enable_device(pdev);
+	ret =3D pci_enable_device(pdev);
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
=20
diff -Nru a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osd=
ep.h
--- a/drivers/net/e1000/e1000_osdep.h	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000_osdep.h	2004-10-26 01:30:56 -04:00
@@ -49,6 +49,12 @@
 				set_current_state(TASK_UNINTERRUPTIBLE); \
 				schedule_timeout((x * HZ)/1000 + 2); \
 			} } while(0)
+/* Some workarounds require millisecond delays and are run during interr=
upt
+ * context.  Most notably, when establishing link, the phy may need twea=
king
+ * but cannot process phy register reads/writes faster than millisecond
+ * intervals...and we establish link due to a "link status change" inter=
rupt.
+ */
+#define msec_delay_irq(x) mdelay(x)
 #endif
=20
 #define PCI_COMMAND_REGISTER   PCI_COMMAND
diff -Nru a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_par=
am.c
--- a/drivers/net/e1000/e1000_param.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/e1000/e1000_param.c	2004-10-26 01:30:56 -04:00
@@ -34,31 +34,21 @@
=20
 #define E1000_MAX_NIC 32
=20
-#define OPTION_UNSET    -1
+#define OPTION_UNSET   -1
 #define OPTION_DISABLED 0
 #define OPTION_ENABLED  1
=20
-/* Module Parameters are always initialized to -1, so that the driver
- * can tell the difference between no user specified value or the
- * user asking for the default value.
- * The true default values are loaded in when e1000_check_options is cal=
led.
- *
- * This is a GCC extension to ANSI C.
- * See the item "Labeled Elements in Initializers" in the section
- * "Extensions to the C Language Family" of the GCC documentation.
- */
-
-#define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] =3D OPTION_UNSET }
-
 /* All parameters are treated the same, as an integer array of values.
  * This macro just reduces the need to repeat the same declaration code
  * over and over (plus this helps to avoid typo bugs).
  */
=20
-#define E1000_PARAM(X, S) \
-static const int __devinitdata X[E1000_MAX_NIC + 1] =3D E1000_PARAM_INIT=
; \
-MODULE_PARM(X, "1-" __MODULE_STRING(E1000_MAX_NIC) "i"); \
-MODULE_PARM_DESC(X, S);
+#define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] =3D OPTION_UNSET }
+#define E1000_PARAM(X, desc) \
+	static int __devinitdata X[E1000_MAX_NIC+1] =3D E1000_PARAM_INIT; \
+	static int num_##X =3D 0; \
+	module_param_array(X, int, &num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
=20
 /* Transmit Descriptor Count
  *
@@ -305,7 +295,6 @@
 		DPRINTK(PROBE, NOTICE,
 		       "Warning: no configuration for board #%i\n", bd);
 		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
-		bd =3D E1000_MAX_NIC;
 	}
=20
 	{ /* Transmit Descriptor Count */
@@ -322,9 +311,14 @@
 		opt.arg.r.max =3D mac_type < e1000_82544 ?
 			E1000_MAX_TXD : E1000_MAX_82544_TXD;
=20
-		tx_ring->count =3D TxDescriptors[bd];
-		e1000_validate_option(&tx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
+		if (num_TxDescriptors > bd) {
+			tx_ring->count =3D TxDescriptors[bd];
+			e1000_validate_option(&tx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(tx_ring->count,=20
+						REQ_TX_DESCRIPTOR_MULTIPLE);
+		} else {
+			tx_ring->count =3D opt.def;
+		}
 	}
 	{ /* Receive Descriptor Count */
 		struct e1000_option opt =3D {
@@ -340,9 +334,14 @@
 		opt.arg.r.max =3D mac_type < e1000_82544 ? E1000_MAX_RXD :
 			E1000_MAX_82544_RXD;
=20
-		rx_ring->count =3D RxDescriptors[bd];
-		e1000_validate_option(&rx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
+		if (num_RxDescriptors > bd) {
+			rx_ring->count =3D RxDescriptors[bd];
+			e1000_validate_option(&rx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(rx_ring->count,=20
+						REQ_RX_DESCRIPTOR_MULTIPLE);
+		} else {
+			rx_ring->count =3D opt.def;
+		}
 	}
 	{ /* Checksum Offload Enable/Disable */
 		struct e1000_option opt =3D {
@@ -352,9 +351,13 @@
 			.def  =3D OPTION_ENABLED
 		};
=20
-		int rx_csum =3D XsumRX[bd];
-		e1000_validate_option(&rx_csum, &opt, adapter);
-		adapter->rx_csum =3D rx_csum;
+		if (num_XsumRX > bd) {
+			int rx_csum =3D XsumRX[bd];
+			e1000_validate_option(&rx_csum, &opt, adapter);
+			adapter->rx_csum =3D rx_csum;
+		} else {
+			adapter->rx_csum =3D opt.def;
+		}
 	}
 	{ /* Flow Control */
=20
@@ -374,9 +377,13 @@
 					 .p =3D fc_list }}
 		};
=20
-		int fc =3D FlowControl[bd];
-		e1000_validate_option(&fc, &opt, adapter);
-		adapter->hw.fc =3D adapter->hw.original_fc =3D fc;
+		if (num_FlowControl > bd) {
+			int fc =3D FlowControl[bd];
+			e1000_validate_option(&fc, &opt, adapter);
+			adapter->hw.fc =3D adapter->hw.original_fc =3D fc;
+		} else {
+			adapter->hw.fc =3D opt.def;
+		}
 	}
 	{ /* Transmit Interrupt Delay */
 		struct e1000_option opt =3D {
@@ -388,8 +395,13 @@
 					 .max =3D MAX_TXDELAY }}
 		};
=20
-		adapter->tx_int_delay =3D TxIntDelay[bd];
-		e1000_validate_option(&adapter->tx_int_delay, &opt, adapter);
+		if (num_TxIntDelay > bd) {
+			adapter->tx_int_delay =3D TxIntDelay[bd];
+			e1000_validate_option(&adapter->tx_int_delay, &opt,=20
+								adapter);
+		} else {
+			adapter->tx_int_delay =3D opt.def;
+		}
 	}
 	{ /* Transmit Absolute Interrupt Delay */
 		struct e1000_option opt =3D {
@@ -401,8 +413,13 @@
 					 .max =3D MAX_TXABSDELAY }}
 		};
=20
-		adapter->tx_abs_int_delay =3D TxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->tx_abs_int_delay, &opt, adapter);
+		if (num_TxAbsIntDelay > bd) {
+			adapter->tx_abs_int_delay =3D TxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->tx_abs_int_delay, &opt,=20
+								adapter);
+		} else {
+			adapter->tx_abs_int_delay =3D opt.def;
+		}
 	}
 	{ /* Receive Interrupt Delay */
 		struct e1000_option opt =3D {
@@ -414,8 +431,13 @@
 					 .max =3D MAX_RXDELAY }}
 		};
=20
-		adapter->rx_int_delay =3D RxIntDelay[bd];
-		e1000_validate_option(&adapter->rx_int_delay, &opt, adapter);
+		if (num_RxIntDelay > bd) {
+			adapter->rx_int_delay =3D RxIntDelay[bd];
+			e1000_validate_option(&adapter->rx_int_delay, &opt,=20
+								adapter);
+		} else {
+			adapter->rx_int_delay =3D opt.def;
+		}
 	}
 	{ /* Receive Absolute Interrupt Delay */
 		struct e1000_option opt =3D {
@@ -427,8 +449,13 @@
 					 .max =3D MAX_RXABSDELAY }}
 		};
=20
-		adapter->rx_abs_int_delay =3D RxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->rx_abs_int_delay, &opt, adapter);
+		if (num_RxAbsIntDelay > bd) {
+			adapter->rx_abs_int_delay =3D RxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->rx_abs_int_delay, &opt,=20
+								adapter);
+		} else {
+			adapter->rx_abs_int_delay =3D opt.def;
+		}
 	}
 	{ /* Interrupt Throttling Rate */
 		struct e1000_option opt =3D {
@@ -440,20 +467,27 @@
 					 .max =3D MAX_ITR }}
 		};
=20
-		adapter->itr =3D InterruptThrottleRate[bd];
-		switch(adapter->itr) {
-		case -1:
+		if (num_InterruptThrottleRate > bd) {
+			adapter->itr =3D InterruptThrottleRate[bd];
+			switch(adapter->itr) {
+			case -1:
+				adapter->itr =3D 1;
+				break;
+			case 0:
+				DPRINTK(PROBE, INFO, "%s turned off\n",=20
+					opt.name);
+				break;
+			case 1:
+				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",=20
+					opt.name);
+				break;
+			default:
+				e1000_validate_option(&adapter->itr, &opt,=20
+					adapter);
+				break;
+			}
+		} else {
 			adapter->itr =3D 1;
-			break;
-		case 0:
-			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
-			break;
-		case 1:
-			DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", opt.name);
-			break;
-		default:
-			e1000_validate_option(&adapter->itr, &opt, adapter);
-			break;
 		}
 	}
=20
@@ -481,17 +515,17 @@
 e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd =3D adapter->bd_number;
-	bd =3D bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
-
-	if((Speed[bd] !=3D OPTION_UNSET)) {
+	if(num_Speed > bd) {
 		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
-	if((Duplex[bd] !=3D OPTION_UNSET)) {
+
+	if(num_Duplex > bd) {
 		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
-	if((AutoNeg[bd] !=3D OPTION_UNSET) && (AutoNeg[bd] !=3D 0x20)) {
+
+	if((num_AutoNeg > bd) && (AutoNeg[bd] !=3D 0x20)) {
 		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
 				 "not valid for fiber adapters, "
 				 "parameter ignored\n");
@@ -510,7 +544,6 @@
 {
 	int speed, dplx;
 	int bd =3D adapter->bd_number;
-	bd =3D bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
=20
 	{ /* Speed */
 		struct e1000_opt_list speed_list[] =3D {{          0, "" },
@@ -527,8 +560,12 @@
 					 .p =3D speed_list }}
 		};
=20
-		speed =3D Speed[bd];
-		e1000_validate_option(&speed, &opt, adapter);
+		if (num_Speed > bd) {
+			speed =3D Speed[bd];
+			e1000_validate_option(&speed, &opt, adapter);
+		} else {
+			speed =3D opt.def;
+		}
 	}
 	{ /* Duplex */
 		struct e1000_opt_list dplx_list[] =3D {{           0, "" },
@@ -544,11 +581,15 @@
 					 .p =3D dplx_list }}
 		};
=20
-		dplx =3D Duplex[bd];
-		e1000_validate_option(&dplx, &opt, adapter);
+		if (num_Duplex > bd) {
+			dplx =3D Duplex[bd];
+			e1000_validate_option(&dplx, &opt, adapter);
+		} else {
+			dplx =3D opt.def;
+		}
 	}
=20
-	if(AutoNeg[bd] !=3D OPTION_UNSET && (speed !=3D 0 || dplx !=3D 0)) {
+	if((num_AutoNeg > bd) && (speed !=3D 0 || dplx !=3D 0)) {
 		DPRINTK(PROBE, INFO,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
@@ -605,7 +646,7 @@
 	switch (speed + dplx) {
 	case 0:
 		adapter->hw.autoneg =3D adapter->fc_autoneg =3D 1;
-		if(Speed[bd] !=3D OPTION_UNSET || Duplex[bd] !=3D OPTION_UNSET)
+		if((num_Speed > bd) && (speed !=3D 0 || dplx !=3D 0))
 			DPRINTK(PROBE, INFO,
 			       "Speed and duplex autonegotiation enabled\n");
 		break;
diff -Nru a/drivers/net/eql.c b/drivers/net/eql.c
--- a/drivers/net/eql.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/eql.c	2004-10-26 01:30:56 -04:00
@@ -164,12 +164,12 @@
=20
 static void __init eql_setup(struct net_device *dev)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
=20
 	SET_MODULE_OWNER(dev);
=20
 	init_timer(&eql->timer);
-	eql->timer.data     	=3D (unsigned long) dev->priv;
+	eql->timer.data     	=3D (unsigned long) eql;
 	eql->timer.expires  	=3D jiffies + EQL_DEFAULT_RESCHED_IVAL;
 	eql->timer.function 	=3D eql_timer;
=20
@@ -197,7 +197,7 @@
=20
 static int eql_open(struct net_device *dev)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
=20
 	/* XXX We should force this off automatically for the user. */
 	printk(KERN_INFO "%s: remember to turn off Van-Jacobson compression on =
"
@@ -241,7 +241,7 @@
=20
 static int eql_close(struct net_device *dev)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
=20
 	/*
 	 *	The timer has to be stopped first before we start hacking away
@@ -326,7 +326,7 @@
=20
 static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
 	slave_t *slave;
=20
 	spin_lock(&eql->queue.lock);
@@ -352,7 +352,7 @@
=20
 static struct net_device_stats * eql_get_stats(struct net_device *dev)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
 	return &eql->stats;
 }
=20
@@ -378,7 +378,7 @@
=20
 static inline int eql_is_full(slave_queue_t *queue)
 {
-	equalizer_t *eql =3D queue->master_dev->priv;
+	equalizer_t *eql =3D netdev_priv(queue->master_dev);
=20
 	if (queue->num_slaves >=3D eql->max_slaves)
 		return 1;
@@ -420,7 +420,7 @@
 			if (!eql_is_master(slave_dev) &&
 			    !eql_is_slave(slave_dev)) {
 				slave_t *s =3D kmalloc(sizeof(*s), GFP_KERNEL);
-				equalizer_t *eql =3D master_dev->priv;
+				equalizer_t *eql =3D netdev_priv(master_dev);
 				int ret;
=20
 				if (!s) {
@@ -453,7 +453,7 @@
=20
 static int eql_emancipate(struct net_device *master_dev, slaving_request=
_t __user *srqp)
 {
-	equalizer_t *eql =3D master_dev->priv;
+	equalizer_t *eql =3D netdev_priv(master_dev);
 	struct net_device *slave_dev;
 	slaving_request_t srq;
 	int ret;
@@ -485,7 +485,7 @@
=20
 static int eql_g_slave_cfg(struct net_device *dev, slave_config_t __user=
 *scp)
 {
-	equalizer_t *eql =3D dev->priv;
+	equalizer_t *eql =3D netdev_priv(dev);
 	slave_t *slave;
 	struct net_device *slave_dev;
 	slave_config_t sc;
@@ -539,7 +539,7 @@
 	if (!slave_dev)
 		return ret;
=20
-	eql =3D dev->priv;
+	eql =3D netdev_priv(dev);
 	spin_lock_bh(&eql->queue.lock);
 	if (eql_is_slave(slave_dev)) {
 		slave =3D __eql_find_slave_dev(&eql->queue, slave_dev);
@@ -561,7 +561,7 @@
 	master_config_t mc;
=20
 	if (eql_is_master(dev)) {
-		eql =3D dev->priv;
+		eql =3D netdev_priv(dev);
 		mc.max_slaves =3D eql->max_slaves;
 		mc.min_slaves =3D eql->min_slaves;
 		if (copy_to_user(mcp, &mc, sizeof (master_config_t)))
@@ -580,7 +580,7 @@
 		return -EFAULT;
=20
 	if (eql_is_master(dev)) {
-		eql =3D dev->priv;
+		eql =3D netdev_priv(dev);
 		eql->max_slaves =3D mc.max_slaves;
 		eql->min_slaves =3D mc.min_slaves;
 		return 0;
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv=
.c
--- a/drivers/net/hamradio/hdlcdrv.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2004-10-26 01:30:56 -04:00
@@ -549,6 +549,8 @@
=20
 	netif_stop_queue(dev);
=20
+	netif_stop_queue(dev);
+
 	if (s->ops && s->ops->close)
 		i =3D s->ops->close(dev);
 	if (s->skb)
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/ixgb/ixgb_main.c	2004-10-26 01:30:56 -04:00
@@ -30,7 +30,7 @@
=20
 char ixgb_driver_name[] =3D "ixgb";
 char ixgb_driver_string[] =3D "Intel(R) PRO/10GbE Network Driver";
-char ixgb_driver_version[] =3D "1.0.66";
+char ixgb_driver_version[] =3D "1.0.66-k2";
 char ixgb_copyright[] =3D "Copyright (c) 2001-2004 Intel Corporation.";
=20
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -1614,8 +1614,12 @@
 	}
 #else
 	for (i =3D 0; i < IXGB_MAX_INTR; i++)
-		if (!ixgb_clean_rx_irq(adapter) & !ixgb_clean_tx_irq(adapter))
+		if (ixgb_clean_rx_irq(adapter) =3D=3D FALSE)
 			break;
+	for (i =3D 0; i < IXGB_MAX_INTR; i++)
+		if (ixgb_clean_tx_irq(adapter) =3D=3D FALSE)
+			break;
+
 	/* if RAIDC:EN =3D=3D 1 and ICR:RXDMT0 =3D=3D 1, we need to
 	 * set IMS:RXDMT0 to 1 to restart the RBD timer (POLL)
 	 */
@@ -1676,7 +1680,7 @@
 	eop =3D tx_ring->buffer_info[i].next_to_watch;
 	eop_desc =3D IXGB_TX_DESC(*tx_ring, eop);
=20
-	while (eop_desc->status & cpu_to_le32(IXGB_TX_DESC_STATUS_DD)) {
+	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
=20
 		for (cleaned =3D FALSE; !cleaned;) {
 			tx_desc =3D IXGB_TX_DESC(*tx_ring, i);
diff -Nru a/drivers/net/mac8390.c b/drivers/net/mac8390.c
--- a/drivers/net/mac8390.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/mac8390.c	2004-10-26 01:30:56 -04:00
@@ -42,10 +42,6 @@
=20
 #include "8390.h"
=20
-#if (LINUX_VERSION_CODE < 0x02030e)
-#define net_device device
-#endif
-
 #define WD_START_PG			0x00	/* First page of TX buffer */
 #define CABLETRON_RX_START_PG		0x00    /* First page of RX buffer */
 #define CABLETRON_RX_STOP_PG		0x30    /* Last page +1 of RX ring */
diff -Nru a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/ne2k-pci.c	2004-10-26 01:30:56 -04:00
@@ -653,12 +653,43 @@
 	pci_set_drvdata(pdev, NULL);
 }
=20
+#ifdef CONFIG_PM
+static int ne2k_pci_suspend (struct pci_dev *pdev, u32 state)
+{
+	struct net_device *dev =3D pci_get_drvdata (pdev);
+
+	netif_device_detach(dev);
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, state);
+
+	return 0;
+}
+
+static int ne2k_pci_resume (struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata (pdev);
+
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+	NS8390_init(dev, 1);
+	netif_device_attach(dev);
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+
=20
 static struct pci_driver ne2k_driver =3D {
 	.name		=3D DRV_NAME,
 	.probe		=3D ne2k_pci_init_one,
 	.remove		=3D __devexit_p(ne2k_pci_remove_one),
 	.id_table	=3D ne2k_pci_tbl,
+#ifdef CONFIG_PM
+	.suspend	=3D ne2k_pci_suspend,
+	.resume		=3D ne2k_pci_resume,
+#endif /* CONFIG_PM */
+
 };
=20
=20
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/ns83820.c	2004-10-26 01:30:56 -04:00
@@ -64,6 +64,8 @@
  *				tuning
  *			0.20 -	fix stupid RFEN thinko.  i am such a smurf.
  *
+ *	20040828	0.21 -	add hardware vlan accleration
+ *				by Neil Horman <nhorman@redhat.com>
  * Driver Overview
  * =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
  *
@@ -92,7 +94,9 @@
 //#define dprintk		printk
 #define dprintk(x...)		do { } while (0)
=20
+#include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -108,6 +112,7 @@
 #include <linux/prefetch.h>
 #include <linux/ethtool.h>
 #include <linux/timer.h>
+#include <linux/if_vlan.h>
=20
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -115,7 +120,7 @@
=20
 #define DRV_NAME "ns83820"
=20
-/* Global parameters.  See MODULE_PARM near the bottom. */
+/* Global parameters.  See module_param near the bottom. */
 static int ihr =3D 2;
 static int reset_phy =3D 0;
 static int lnksts =3D 0;		/* CFG_LNKSTS bit polarity */
@@ -138,6 +143,9 @@
=20
 /* tunables */
 #define RX_BUF_SIZE	1500	/* 8192 */
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define NS83820_VLAN_ACCEL_SUPPORT
+#endif
=20
 /* Must not exceed ~65000. */
 #define NR_RX_DESC	64
@@ -262,6 +270,8 @@
 #define EXTSTS_UDPPKT	0x00200000
 #define EXTSTS_TCPPKT	0x00080000
 #define EXTSTS_IPPKT	0x00020000
+#define EXTSTS_VPKT	0x00010000
+#define EXTSTS_VTG_MASK	0x0000ffff
=20
 #define SPDSTS_POLARITY	(CFG_SPDSTS1 | CFG_SPDSTS0 | CFG_DUPSTS | (lnkst=
s ? CFG_LNKSTS : 0))
=20
@@ -403,6 +413,7 @@
 #define CMDSTS_INTR	0x20000000
 #define CMDSTS_ERR	0x10000000
 #define CMDSTS_OK	0x08000000
+#define CMDSTS_RUNT	0x00200000
 #define CMDSTS_LEN_MASK	0x0000ffff
=20
 #define CMDSTS_DEST_MASK	0x01800000
@@ -432,6 +443,10 @@
=20
 	struct pci_dev		*pci_dev;
=20
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+	struct vlan_group	*vlgrp;
+#endif
+
 	struct rx_info		rx_info;
 	struct tasklet_struct	rx_tasklet;
=20
@@ -494,6 +509,33 @@
 	(((NR_TX_DESC-2 + dev->tx_done_idx - dev->tx_free_idx) % NR_TX_DESC) > =
MIN_TX_DESC_FREE)
=20
=20
+#ifdef NS83820_VLAN_ACCEL_SUPPORT=20
+static void ns83820_vlan_rx_register(struct net_device *ndev, struct vla=
n_group *grp)
+{
+	struct ns83820 *dev =3D PRIV(ndev);
+
+	spin_lock_irq(&dev->misc_lock);
+	spin_lock(&dev->tx_lock);
+
+	dev->vlgrp =3D grp;
+
+	spin_unlock(&dev->tx_lock);
+	spin_unlock_irq(&dev->misc_lock);
+}
+
+static void ns83820_vlan_rx_kill_vid(struct net_device *ndev, unsigned s=
hort vid)
+{
+	struct ns83820 *dev =3D PRIV(ndev);
+
+	spin_lock_irq(&dev->misc_lock);
+	spin_lock(&dev->tx_lock);
+	if (dev->vlgrp)
+		dev->vlgrp->vlan_devices[vid] =3D NULL;
+	spin_unlock(&dev->tx_lock);
+	spin_unlock_irq(&dev->misc_lock);
+}
+#endif
+
 /* Packet Receiver
  *
  * The hardware supports linked lists of receive descriptors for
@@ -836,6 +878,7 @@
 	struct ns83820 *dev =3D PRIV(ndev);
 	struct rx_info *info =3D &dev->rx_info;
 	unsigned next_rx;
+	int rx_rc, len;
 	u32 cmdsts, *desc;
 	unsigned long flags;
 	int nr =3D 0;
@@ -876,8 +919,24 @@
=20
 		pci_unmap_single(dev->pci_dev, bufptr,
 				 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		len =3D cmdsts & CMDSTS_LEN_MASK;
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+		/* NH: As was mentioned below, this chip is kinda
+		 * brain dead about vlan tag stripping.  Frames
+		 * that are 64 bytes with a vlan header appended
+		 * like arp frames, or pings, are flagged as Runts
+		 * when the tag is stripped and hardware.  This
+		 * also means that the OK bit in the descriptor=20
+		 * is cleared when the frame comes in so we have
+		 * to do a specific length check here to make sure
+		 * the frame would have been ok, had we not stripped
+		 * the tag.
+		 */=20
+		if (likely((CMDSTS_OK & cmdsts) ||
+			((cmdsts & CMDSTS_RUNT) && len >=3D 56))) {  =20
+#else
 		if (likely(CMDSTS_OK & cmdsts)) {
-			int len =3D cmdsts & 0xffff;
+#endif
 			skb_put(skb, len);
 			if (unlikely(!skb))
 				goto netdev_mangle_me_harder_failed;
@@ -891,7 +950,18 @@
 				skb->ip_summed =3D CHECKSUM_NONE;
 			}
 			skb->protocol =3D eth_type_trans(skb, ndev);
-			if (NET_RX_DROP =3D=3D netif_rx(skb)) {
+#ifdef NS83820_VLAN_ACCEL_SUPPORT=20
+			if(extsts & EXTSTS_VPKT) {
+				unsigned short tag;
+				tag =3D ntohs(extsts & EXTSTS_VTG_MASK);
+				rx_rc =3D vlan_hwaccel_rx(skb,dev->vlgrp,tag);
+			} else {
+				rx_rc =3D netif_rx(skb);
+			}
+#else
+			rx_rc =3D netif_rx(skb);
+#endif
+			if (NET_RX_DROP =3D=3D rx_rc) {
 netdev_mangle_me_harder_failed:
 				dev->stats.rx_dropped ++;
 			}
@@ -1099,6 +1169,17 @@
 			extsts |=3D EXTSTS_UDPPKT;
 	}
=20
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+	if(vlan_tx_tag_present(skb)) {
+		/* fetch the vlan tag info out of the
+		 * ancilliary data if the vlan code
+		 * is using hw vlan acceleration
+		 */
+		short tag =3D vlan_tx_tag_get(skb);
+		extsts |=3D (EXTSTS_VPKT | htons(tag));
+	}
+#endif
+
 	len =3D skb->len;
 	if (nr_frags)
 		len -=3D skb->data_len;
@@ -1854,7 +1935,6 @@
 	SET_ETHTOOL_OPS(ndev, &ops);
 	ndev->tx_timeout =3D ns83820_tx_timeout;
 	ndev->watchdog_timeo =3D 5 * HZ;
-
 	pci_set_drvdata(pci_dev, ndev);
=20
 	ns83820_do_reset(dev, CR_RST);
@@ -1980,11 +2060,25 @@
 	 * a ping with a VLAN header) then the card, strips the 4 byte VLAN
 	 * tag and then checks the packet size, so if RXCFG_ARP is not enabled,
 	 * it discrards it!.  These guys......
+	 * also turn on tag stripping if hardware acceleration is enabled
 	 */
-	writel(VRCR_IPEN | VRCR_VTDEN, dev->base + VRCR);
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+#define VRCR_INIT_VALUE (VRCR_IPEN|VRCR_VTDEN|VRCR_VTREN)=20
+#else
+#define VRCR_INIT_VALUE (VRCR_IPEN|VRCR_VTDEN)
+#endif
+	writel(VRCR_INIT_VALUE, dev->base + VRCR);
=20
-	/* Enable per-packet TCP/UDP/IP checksumming */
-	writel(VTCR_PPCHK, dev->base + VTCR);
+	/* Enable per-packet TCP/UDP/IP checksumming
+	 * and per packet vlan tag insertion if
+	 * vlan hardware acceleration is enabled
+	 */
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+#define VTCR_INIT_VALUE (VTCR_PPCHK|VTCR_VPPTI)
+#else
+#define VTCR_INIT_VALUE VTCR_PPCHK
+#endif
+	writel(VTCR_INIT_VALUE, dev->base + VTCR);
=20
 	/* Ramit : Enable async and sync pause frames */
 	/* writel(0, dev->base + PCR); */
@@ -2001,6 +2095,13 @@
 	ndev->features |=3D NETIF_F_SG;
 	ndev->features |=3D NETIF_F_IP_CSUM;
=20
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+	/* We also support hardware vlan acceleration */
+	ndev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	ndev->vlan_rx_register =3D ns83820_vlan_rx_register;
+	ndev->vlan_rx_kill_vid =3D ns83820_vlan_rx_kill_vid;
+#endif
+
 	if (using_dac) {
 		printk(KERN_INFO "%s: using 64 bit addressing.\n",
 			ndev->name);
@@ -2109,13 +2210,13 @@
=20
 MODULE_DEVICE_TABLE(pci, ns83820_pci_tbl);
=20
-MODULE_PARM(lnksts, "i");
+module_param(lnksts, int, 0);
 MODULE_PARM_DESC(lnksts, "Polarity of LNKSTS bit");
=20
-MODULE_PARM(ihr, "i");
+module_param(ihr, int, 0);
 MODULE_PARM_DESC(ihr, "Time in 100 us increments to delay interrupts (ra=
nge 0-127)");
=20
-MODULE_PARM(reset_phy, "i");
+module_param(reset_phy, int, 0);
 MODULE_PARM_DESC(reset_phy, "Set to 1 to reset the PHY on startup");
=20
 module_init(ns83820_init);
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/pcnet32.c	2004-10-26 01:30:56 -04:00
@@ -359,9 +359,9 @@
     struct net_device_stats stats;
     char		tx_full;
     int			options;
-    int	shared_irq:1,			/* shared irq possible */
-	dxsuflo:1,			/* disable transmit stop on uflo */
-	mii:1;				/* mii port available */
+    unsigned int	shared_irq:1,	/* shared irq possible */
+			dxsuflo:1,	/* disable transmit stop on uflo */
+			mii:1;		/* mii port available */
     struct net_device	*next;
     struct mii_if_info	mii_if;
     struct timer_list	watchdog_timer;
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/sis900.c	2004-10-26 01:30:56 -04:00
@@ -262,13 +262,12 @@
 	u8 reg;
 	int i;
=20
-	isa_bridge =3D pci_find_device(PCI_VENDOR_ID_SI, 0x0008, isa_bridge);
+	isa_bridge =3D pci_get_device(PCI_VENDOR_ID_SI, 0x0008, isa_bridge);
+	if (!isa_bridge)
+		isa_bridge =3D pci_get_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 	if (!isa_bridge) {
-		isa_bridge =3D pci_find_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
-		if (!isa_bridge) {
-			printk("%s: Can not find ISA bridge\n", net_dev->name);
-			return 0;
-		}
+		printk("%s: Can not find ISA bridge\n", net_dev->name);
+		return 0;
 	}
 	pci_read_config_byte(isa_bridge, 0x48, &reg);
 	pci_write_config_byte(isa_bridge, 0x48, reg | 0x40);
@@ -278,6 +277,7 @@
 		((u8 *)(net_dev->dev_addr))[i] =3D inb(0x71);=20
 	}
 	pci_write_config_byte(isa_bridge, 0x48, reg & ~0x40);
+	pci_dev_put(isa_bridge);
=20
 	return 1;
 }
@@ -488,9 +488,11 @@
 	}
=20
 	/* save our host bridge revision */
-	dev =3D pci_find_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
-	if (dev)
+	dev =3D pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
+	if (dev) {
 		pci_read_config_byte(dev, PCI_CLASS_REVISION, &sis_priv->host_bridge_r=
ev);
+		pci_dev_put(dev);
+	}
=20
 	/* print some information about our NIC */
 	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ", net_dev->name,
diff -Nru a/drivers/net/skfp/hwmtm.c b/drivers/net/skfp/hwmtm.c
--- a/drivers/net/skfp/hwmtm.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/skfp/hwmtm.c	2004-10-26 01:30:56 -04:00
@@ -1901,7 +1901,8 @@
 	}
=20
 	if (!smc->hw.mac_ring_is_up || frag_count > queue->tx_free) {
-		if (frame_status &=3D ~LAN_TX) {
+		frame_status &=3D ~LAN_TX;
+		if (frame_status) {
 			DB_TX("Ring is down: terminate LAN_TX",0,0,2) ;
 		}
 		else {
diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/slip.c	2004-10-26 01:30:56 -04:00
@@ -57,6 +57,7 @@
 #define SL_CHECK_TRANSMIT
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
=20
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -85,8 +86,8 @@
=20
 static struct net_device **slip_devs;
=20
-int slip_maxdev =3D SL_NRUNIT;		/* Can be overridden with insmod! */
-MODULE_PARM(slip_maxdev, "i");
+static int slip_maxdev =3D SL_NRUNIT;
+module_param(slip_maxdev, int, 0);
 MODULE_PARM_DESC(slip_maxdev, "Maximum number of slip devices");
=20
 static int slip_esc(unsigned char *p, unsigned char *d, int len);
@@ -458,13 +459,11 @@
=20
 static void sl_tx_timeout(struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	spin_lock(&sl->lock);
=20
 	if (netif_queue_stopped(dev)) {
-		struct slip *sl =3D (struct slip*)(dev->priv);
-
 		if (!netif_running(dev))
 			goto out;
=20
@@ -494,7 +493,7 @@
 static int
 sl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	spin_lock(&sl->lock);
 	if (!netif_running(dev))  {
@@ -528,7 +527,7 @@
 static int
 sl_close(struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	spin_lock_bh(&sl->lock);
 	if (sl->tty) {
@@ -547,7 +546,7 @@
=20
 static int sl_open(struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	if (sl->tty=3D=3DNULL)
 		return -ENODEV;
@@ -561,7 +560,7 @@
=20
 static int sl_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	if (new_mtu < 68 || new_mtu > 65534)
 		return -EINVAL;
@@ -577,7 +576,7 @@
 sl_get_stats(struct net_device *dev)
 {
 	static struct net_device_stats stats;
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
 #ifdef SL_INCLUDE_CSLIP
 	struct slcompress *comp;
 #endif
@@ -612,7 +611,7 @@
=20
 static int sl_init(struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	/*
 	 *	Finish setting up the DEVICE info.=20
@@ -630,7 +629,7 @@
=20
 static void sl_uninit(struct net_device *dev)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
=20
 	sl_free_bufs(sl);
 }
@@ -719,7 +718,7 @@
 		if ((dev =3D slip_devs[i]) =3D=3D NULL)
 			break;
=20
-		sl =3D dev->priv;
+		sl =3D netdev_priv(dev);
 		if (sl->tty || sl->leased)
 			continue;
 		if (dev->flags&IFF_UP)
@@ -746,7 +745,7 @@
 		if (dev =3D=3D NULL)
 			break;
=20
-		sl =3D dev->priv;
+		sl =3D netdev_priv(dev);
 		if (sl->leased) {
 			if (sl->line !=3D line)
 				continue;
@@ -788,7 +787,7 @@
 		i =3D sel;
 		dev =3D slip_devs[i];
 		if (score > 1) {
-			sl =3D dev->priv;
+			sl =3D netdev_priv(dev);
 			sl->flags &=3D (1 << SLF_INUSE);
 			return sl;
 		}
@@ -799,7 +798,7 @@
 		return NULL;
=20
 	if (dev) {
-		sl =3D dev->priv;
+		sl =3D netdev_priv(dev);
 		if (test_bit(SLF_INUSE, &sl->flags)) {
 			unregister_netdevice(dev);
 			dev =3D NULL;
@@ -817,7 +816,7 @@
 		dev->base_addr  =3D i;
 	}
=20
-	sl =3D dev->priv;
+	sl =3D netdev_priv(dev);
=20
 	/* Initialize channel control data */
 	sl->magic       =3D SLIP_MAGIC;
@@ -1260,7 +1259,7 @@
=20
 static int sl_ioctl(struct net_device *dev,struct ifreq *rq,int cmd)
 {
-	struct slip *sl =3D (struct slip*)(dev->priv);
+	struct slip *sl =3D netdev_priv(dev);
 	unsigned long *p =3D (unsigned long *)&rq->ifr_ifru;
=20
 	if (sl =3D=3D NULL)		/* Allocation failed ?? */
@@ -1406,7 +1405,7 @@
 			dev =3D slip_devs[i];
 			if (!dev)
 				continue;
-			sl =3D dev->priv;
+			sl =3D netdev_priv(dev);
 			spin_lock_bh(&sl->lock);
 			if (sl->tty) {
 				busy++;
@@ -1423,7 +1422,7 @@
 			continue;
 		slip_devs[i] =3D NULL;
=20
-		sl =3D dev->priv;
+		sl =3D netdev_priv(dev);
 		if (sl->tty) {
 			printk(KERN_ERR "%s: tty discipline still running\n",
 			       dev->name);
diff -Nru a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olymp=
ic.c
--- a/drivers/net/tokenring/olympic.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/tokenring/olympic.c	2004-10-26 01:30:56 -04:00
@@ -1401,7 +1401,6 @@
 	u16 lan_status =3D 0, lan_status_diff  ; /* Initialize to stop compiler=
 warning */
 	u8 fdx_prot_error ;=20
 	u16 next_ptr;
-	int i ;=20
=20
 	arb_block =3D (olympic_priv->olympic_lap + olympic_priv->arb) ;=20
 	asb_block =3D (olympic_priv->olympic_lap + olympic_priv->asb) ;=20
diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/tulip/de2104x.c	2004-10-26 01:30:56 -04:00
@@ -1208,8 +1208,7 @@
 		pci_write_config_dword(de->pdev, PCIPM, pmctl);
=20
 		/* de4x5.c delays, so we do too */
-		current->state =3D TASK_UNINTERRUPTIBLE;
-		schedule_timeout(msecs_to_jiffies(10));
+		msleep(10);
 	}
 }
=20
diff -Nru a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/tulip/de4x5.c	2004-10-26 01:30:56 -04:00
@@ -5089,7 +5089,7 @@
     lp->useMII =3D TRUE;
=20
     /* Search the MII address space for possible PHY devices */
-    for (n=3D0, lp->mii_cnt=3D0, i=3D1; !((i=3D=3D1) && (n=3D=3D1)); i=3D=
(++i)%DE4X5_MAX_MII) {
+    for (n=3D0, lp->mii_cnt=3D0, i=3D1; !((i=3D=3D1) && (n=3D=3D1)); i=3D=
(i+1)%DE4X5_MAX_MII) {
 	lp->phy[lp->active].addr =3D i;
 	if (i=3D=3D0) n++;                             /* Count cycles */
 	while (de4x5_reset_phy(dev)<0) udelay(100);/* Wait for reset */
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core=
.c
--- a/drivers/net/tulip/tulip_core.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/tulip/tulip_core.c	2004-10-26 01:30:56 -04:00
@@ -1221,6 +1221,11 @@
 	struct tulip_private *tp;
 	/* See note below on the multiport cards. */
 	static unsigned char last_phys_addr[6] =3D {0x00, 'L', 'i', 'n', 'u', '=
x'};
+	static struct pci_device_id early_486_chipsets[] =3D {
+		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82424) },
+		{ PCI_DEVICE(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_496) },
+		{ },
+	};
 	static int last_irq;
 	static int multiport_cnt;	/* For four-port boards w/one EEPROM */
 	u8 chip_rev;
@@ -1274,17 +1279,15 @@
 	 *	without the workarounds being on.
 	 */
=20
-	/* Intel Saturn. Switch to 8 long words burst, 8 long word cache aligne=
d
-	   Aries might need this too. The Saturn errata are not pretty reading =
but
-	   thankfully it's an old 486 chipset.
+	/* 1. Intel Saturn. Switch to 8 long words burst, 8 long word cache
+	      aligned.  Aries might need this too. The Saturn errata are not=20
+	      pretty reading but thankfully it's an old 486 chipset.
+
+	   2. The dreaded SiS496 486 chipset. Same workaround as Intel
+	      Saturn.
 	*/
=20
-	if (pci_find_device(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82424, NUL=
L)) {
-		csr0 =3D MRL | MRM | (8 << BurstLenShift) | (1 << CALShift);
-		force_csr0 =3D 1;
-	}
-	/* The dreaded SiS496 486 chipset. Same workaround as above. */
-	if (pci_find_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_496, NULL)) {
+	if (pci_dev_present(early_486_chipsets)) {
 		csr0 =3D MRL | MRM | (8 << BurstLenShift) | (1 << CALShift);
 		force_csr0 =3D 1;
 	}
diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	2004-10-26 01:30:56 -04:00
+++ b/drivers/net/tulip/xircom_cb.c	2004-10-26 01:30:56 -04:00
@@ -117,6 +117,9 @@
 static int xircom_close(struct net_device *dev);
 static void xircom_up(struct xircom_private *card);
 static struct net_device_stats *xircom_get_stats(struct net_device *dev)=
;
+#if CONFIG_NET_POLL_CONTROLLER
+static void xircom_poll_controller(struct net_device *dev);
+#endif
=20
 static void investigate_read_descriptor(struct net_device *dev,struct xi=
rcom_private *card, int descnr, unsigned int bufferoffset);
 static void investigate_write_descriptor(struct net_device *dev, struct =
xircom_private *card, int descnr, unsigned int bufferoffset);
@@ -269,6 +272,9 @@
 	dev->stop =3D &xircom_close;
 	dev->get_stats =3D &xircom_get_stats;
 	dev->priv =3D private;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D &xircom_poll_controller;
+#endif
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	pci_set_drvdata(pdev, dev);
=20
@@ -500,6 +506,14 @@
 }=20
                                                 =20
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void xircom_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	xircom_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
=20
=20
 static void initialize_card(struct xircom_private *card)
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-10-26 01:30:56 -04:00
+++ b/include/linux/netdevice.h	2004-10-26 01:30:56 -04:00
@@ -930,8 +930,6 @@
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);
-extern int		netdev_register_fc(struct net_device *dev, void (*stimul)(st=
ruct net_device *dev));
-extern void		netdev_unregister_fc(int bit);
 extern int		netdev_max_backlog;
 extern int		weight_p;
 extern unsigned long	netdev_fc_xoff;
diff -Nru a/net/Kconfig b/net/Kconfig
--- a/net/Kconfig	2004-10-26 01:30:56 -04:00
+++ b/net/Kconfig	2004-10-26 01:30:56 -04:00
@@ -564,24 +564,6 @@
=20
 	  If unsure, say N.
=20
-config NET_HW_FLOWCONTROL
-	bool "Forwarding between high speed interfaces"
-	depends on EXPERIMENTAL
-	---help---
-	  This option enables NIC (Network Interface Card) hardware throttling
-	  during periods of extreme congestion. At the moment only a couple
-	  of device drivers support it (really only one -- tulip, a modified
-	  8390 driver can be found at
-	  <ftp://ftp.tux.org/pub/net/ip-routing/fastroute/fastroute-8390.tar.gz=
>).
-
-	  Really, this option is applicable to any machine attached to a fast
-	  enough network, and even a 10 Mb NIC is able to kill a not very slow
-	  box, such as a 120MHz Pentium.
-
-	  However, do not say Y here if you did not experience any serious
-	  problems.
-
-
 menu "QoS and/or fair queueing"
=20
 config NET_SCHED
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-10-26 01:30:56 -04:00
+++ b/net/core/dev.c	2004-10-26 01:30:56 -04:00
@@ -1390,66 +1390,6 @@
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
=20
=20
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-atomic_t netdev_dropping =3D ATOMIC_INIT(0);
-static unsigned long netdev_fc_mask =3D 1;
-unsigned long netdev_fc_xoff;
-spinlock_t netdev_fc_lock =3D SPIN_LOCK_UNLOCKED;
-
-static struct
-{
-	void (*stimul)(struct net_device *);
-	struct net_device *dev;
-} netdev_fc_slots[BITS_PER_LONG];
-
-int netdev_register_fc(struct net_device *dev,
-		       void (*stimul)(struct net_device *dev))
-{
-	int bit =3D 0;
-	unsigned long flags;
-
-	spin_lock_irqsave(&netdev_fc_lock, flags);
-	if (netdev_fc_mask !=3D ~0UL) {
-		bit =3D ffz(netdev_fc_mask);
-		netdev_fc_slots[bit].stimul =3D stimul;
-		netdev_fc_slots[bit].dev =3D dev;
-		set_bit(bit, &netdev_fc_mask);
-		clear_bit(bit, &netdev_fc_xoff);
-	}
-	spin_unlock_irqrestore(&netdev_fc_lock, flags);
-	return bit;
-}
-
-void netdev_unregister_fc(int bit)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&netdev_fc_lock, flags);
-	if (bit > 0) {
-		netdev_fc_slots[bit].stimul =3D NULL;
-		netdev_fc_slots[bit].dev =3D NULL;
-		clear_bit(bit, &netdev_fc_mask);
-		clear_bit(bit, &netdev_fc_xoff);
-	}
-	spin_unlock_irqrestore(&netdev_fc_lock, flags);
-}
-
-static void netdev_wakeup(void)
-{
-	unsigned long xoff;
-
-	spin_lock(&netdev_fc_lock);
-	xoff =3D netdev_fc_xoff;
-	netdev_fc_xoff =3D 0;
-	while (xoff) {
-		int i =3D ffz(~xoff);
-		xoff &=3D ~(1 << i);
-		netdev_fc_slots[i].stimul(netdev_fc_slots[i].dev);
-	}
-	spin_unlock(&netdev_fc_lock);
-}
-#endif
-
 static void get_sample_stats(int cpu)
 {
 #ifdef RAND_LIE
@@ -1559,13 +1499,8 @@
 			return queue->cng_level;
 		}
=20
-		if (queue->throttle) {
+		if (queue->throttle)
 			queue->throttle =3D 0;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-			if (atomic_dec_and_test(&netdev_dropping))
-				netdev_wakeup();
-#endif
-		}
=20
 		netif_rx_schedule(&queue->backlog_dev);
 		goto enqueue;
@@ -1574,9 +1509,6 @@
 	if (!queue->throttle) {
 		queue->throttle =3D 1;
 		__get_cpu_var(netdev_rx_stat).throttled++;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		atomic_inc(&netdev_dropping);
-#endif
 	}
=20
 drop:
@@ -1848,16 +1780,6 @@
 		if (work >=3D quota || jiffies - start_time > 1)
 			break;
=20
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		if (queue->throttle &&
-		    queue->input_pkt_queue.qlen < no_cong_thresh ) {
-			queue->throttle =3D 0;
-			if (atomic_dec_and_test(&netdev_dropping)) {
-				netdev_wakeup();
-				break;
-			}
-		}
-#endif
 	}
=20
 	backlog_dev->quota -=3D work;
@@ -1872,13 +1794,8 @@
 	smp_mb__before_clear_bit();
 	netif_poll_enable(backlog_dev);
=20
-	if (queue->throttle) {
+	if (queue->throttle)
 		queue->throttle =3D 0;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		if (atomic_dec_and_test(&netdev_dropping))
-			netdev_wakeup();
-#endif
-	}
 	local_irq_enable();
 	return 0;
 }
@@ -3364,12 +3281,6 @@
=20
 #ifdef CONFIG_KMOD
 EXPORT_SYMBOL(dev_load);
-#endif
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-EXPORT_SYMBOL(netdev_dropping);
-EXPORT_SYMBOL(netdev_fc_xoff);
-EXPORT_SYMBOL(netdev_register_fc);
-EXPORT_SYMBOL(netdev_unregister_fc);
 #endif
=20
 #ifdef CONFIG_NET_CLS_ACT
diff -Nru a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
--- a/net/irda/irlan/irlan_client.c	2004-10-26 01:30:56 -04:00
+++ b/net/irda/irlan/irlan_client.c	2004-10-26 01:30:56 -04:00
@@ -234,7 +234,7 @@
 	ASSERT(tsap =3D=3D self->client.tsap_ctrl, return;);
=20
        	/* Remove frames queued on the control channel */
-	while ((skb =3D skb_dequeue(&self->client.txq))) {
+	while ((skb =3D skb_dequeue(&self->client.txq)) !=3D NULL) {
 		dev_kfree_skb(skb);
 	}
 	self->client.tx_busy =3D FALSE;
