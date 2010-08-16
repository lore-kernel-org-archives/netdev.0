From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v5 0/5] ptp: IEEE 1588 clock support
Date: Mon, 16 Aug 2010 13:17:05 +0200
Message-ID: <cover.1281956490.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Now and again there has been talk on the netdev list of adding PTP
support into Linux. One part of the picture is already in place, the
SO_TIMESTAMPING API for hardware time stamping. This patch set offers
the missing second part needed for complete IEEE 1588 support.

* Why all the CCs?

  1. IMHO, the patches should go through netdev.
  2. A reviewer on netdev said, this should appear on lkml.
  3. One driver is for PowerPC, and adds device tree stuff.
  4. One driver is for the ARM Xscale IXP465.

* Open Issues:

** DP83640
   In order to make this work, one line must be added into the MAC
   driver. If you have the DP83640 and want to try the driver, you
   need to add this one line to your MAC driver: In the
   .ndo_start_xmit function, add skb_tx_timestamp(skb).

** IXP465
   I do not know how to correctly choose the timestamp "channel" based
   on the port identifier:

+#define PORT2CHANNEL(p)		1
+/*
+ * PHYSICAL_ID(p->id) ?
+ * TODO - Figure out correct mapping.
+ */

   Krzysztof, can you help?

* PTP Patch ChangeLog
** v5
*** general
   - Added a hook into the PPS subsystem
   - Corrected max_adj in all drivers
   - Removed unnecessary sysfs stuff
   - Replaced spinlock with mutex in class driver
*** gianfar
   - Added PPS support
   - Changed underscore to minus in device tree bindings
   - Use of_iomap instead of ioremap
*** ixp465
   - Added an external trigger event
   - Corrected in_progress logic
*** phyter
   - Added an external trigger event
   - Added support for phy status frames

** v4
*** general
   - Added a clock driver for the National Semiconductor PHYTER.
   - Added a clock driver for the Intel IXP465.
   - Made more stylish according to checkstyle.pl.
*** gianfar
   - Replace device_type and model with compatible string ("fsl,etsec-ptp")
   - Register only one interrupt, since others are superfluous.
   - Combine ptp clock instance with private variable structure.
   - ISR now returns NONE or HANDLED properly.
   - Print error message if something is missing from the device nodes.

** v3
*** general
   - Added documentation on writing clock drivers.
   - Added the ioctls for the ancillary clock features.
   - Changed wrong subsys_initcall() to module_init() in clock drivers.
   - Removed the (too coarse) character device mutex.
   - Setting the clock now requires CAP_SYS_TIME.
*** gianfar
   - Added alarm feature.
   - Added device tree node binding description.
   - Added fine grain locking of the clock registers.
   - Added the external time stamp feature.
   - Added white space for better style.
   - Coverted base+offset to structure pointers for register access.
   - When removing the driver, we now disable all PTP functions.

** v2
   - Changed clock list from a static array into a dynamic list. Also,
     use a bitmap to manage the clock's minor numbers.
   - Replaced character device semaphore with a mutex.
   - Drop .ko from module names in Kbuild help.
   - Replace deprecated unifdef-y with header-y for user space header file.
   - Added links to both of the ptpd patches on sourceforge.
   - Gianfar driver now gets parameters from device tree.
   - Added API documentation to Documentation/ptp/ptp.txt


Richard Cochran (5):
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the Linux system time.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
  ptp: Added a clock driver for the IXP46x.
  ptp: Added a clock driver for the National Semiconductor PHYTER.

 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   57 ++
 Documentation/ptp/ptp.txt                       |   95 +++
 Documentation/ptp/testptp.c                     |  306 ++++++++
 Documentation/ptp/testptp.mk                    |   33 +
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h   |   78 ++
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   14 +
 arch/powerpc/boot/dts/mpc8572ds.dts             |   14 +
 arch/powerpc/boot/dts/p2020ds.dts               |   14 +
 arch/powerpc/boot/dts/p2020rdb.dts              |   14 +
 drivers/Kconfig                                 |    2 +
 drivers/Makefile                                |    1 +
 drivers/net/Makefile                            |    1 +
 drivers/net/arm/ixp4xx_eth.c                    |  191 +++++
 drivers/net/gianfar_ptp.c                       |  527 +++++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++
 drivers/net/phy/Kconfig                         |   29 +
 drivers/net/phy/Makefile                        |    1 +
 drivers/net/phy/dp83640.c                       |  904 +++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h                   |  261 +++++++
 drivers/ptp/Kconfig                             |   65 ++
 drivers/ptp/Makefile                            |    7 +
 drivers/ptp/ptp_clock.c                         |  514 +++++++++++++
 drivers/ptp/ptp_ixp46x.c                        |  359 +++++++++
 drivers/ptp/ptp_linux.c                         |  136 ++++
 include/linux/Kbuild                            |    1 +
 include/linux/ptp_clock.h                       |   79 ++
 include/linux/ptp_clock_kernel.h                |  137 ++++
 kernel/time/ntp.c                               |    2 +
 28 files changed, 3955 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_ixp46x.c
 create mode 100644 drivers/ptp/ptp_linux.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h
