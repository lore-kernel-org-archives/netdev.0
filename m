From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] gigaset: documentation amendments
Date: Sat,  5 Dec 2009 19:54:20 +0100 (CET)
Message-ID: <20091205185420.A191D400DE@xenon.ts.pxnet.com>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:54465 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932874AbZLES4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 13:56:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various additions and improvements to the Gigaset driver's README
file, and added comments to its userspace visible include file.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |  116 +++++++++++++++++++++++++++++--------
 include/linux/gigaset_dev.h       |   22 +++++--
 2 files changed, 106 insertions(+), 32 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index 0fc9831..794941f 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -68,22 +68,38 @@ GigaSet 307x Device Driver
      for troubleshooting or to pass module parameters.
 
      The module ser_gigaset provides a serial line discipline N_GIGASET_M101
-     which drives the device through the regular serial line driver. It must
-     be attached to the serial line to which the M101 is connected with the
-     ldattach(8) command (requires util-linux-ng release 2.14 or later), for
-     example:
-	 ldattach GIGASET_M101 /dev/ttyS1
+     which uses the regular serial port driver to access the device, and must
+     therefore be attached to the serial device to which the M101 is connected.
+     The ldattach(8) command (included in util-linux-ng release 2.14 or later)
+     can be used for that purpose, for example:
+	ldattach GIGASET_M101 /dev/ttyS1
      This will open the device file, attach the line discipline to it, and
      then sleep in the background, keeping the device open so that the line
      discipline remains active. To deactivate it, kill the daemon, for example
      with
-	 killall ldattach
+	killall ldattach
      before disconnecting the device. To have this happen automatically at
      system startup/shutdown on an LSB compatible system, create and activate
      an appropriate LSB startup script /etc/init.d/gigaset. (The init name
      'gigaset' is officially assigned to this project by LANANA.)
      Alternatively, just add the 'ldattach' command line to /etc/rc.local.
 
+     The modules accept the following parameters:
+
+	Module	 	Parameter  Meaning
+
+	gigaset	 	debug	   debug level (see section 3.2.)
+
+			startmode  initial operation mode (see section 2.5.):
+	bas_gigaset )		   1=ISDN4linux/CAPI (default), 0=Unimodem
+	ser_gigaset )
+	usb_gigaset )	cidmode    initial Call-ID mode setting (see section
+				   2.5.): 1=on (default), 0=off
+
+     Depending on your distribution you may want to create a separate module
+     configuration file /etc/modprobe.d/gigaset for these, or add them to a
+     custom file like /etc/modprobe.conf.local.
+
 2.2. Device nodes for user space programs
      ------------------------------------
      The device can be accessed from user space (eg. by the user space tools
@@ -93,11 +109,48 @@ GigaSet 307x Device Driver
      - /dev/ttyGU0 for M105 (USB data boxes)
      - /dev/ttyGB0 for the base driver (direct USB connection)
 
-     You can also select a "default device" which is used by the frontends when
+     If you connect more than one device of a type, they will get consecutive
+     device nodes, eg. /dev/ttyGU1 for a second M105.
+
+     You can also set a "default device" for the user space tools to use when
      no device node is given as parameter, by creating a symlink /dev/ttyG to
      one of them, eg.:
 
-        ln -s /dev/ttyGB0 /dev/ttyG
+	ln -s /dev/ttyGB0 /dev/ttyG
+
+     The devices accept the following device specific ioctl calls
+     (defined in gigaset_dev.h):
+
+     ioctl(int fd, GIGASET_REDIR, int *cmd);
+     If cmd==1, the device is set to be controlled exclusively through the
+     character device node; access from the ISDN subsystem is blocked.
+     If cmd==0, the device is set to be used from the ISDN subsystem and does
+     not communicate through the character device node.
+
+     ioctl(int fd, GIGASET_CONFIG, int *cmd);
+     (ser_gigaset and usb_gigaset only)
+     If cmd==1, the device is set to adapter configuration mode where commands
+     are interpreted by the M10x DECT adapter itself instead of being
+     forwarded to the base station. In this mode, the device accepts the
+     commands described in Siemens document "AT-Kommando Alignment M10x Data"
+     for setting the operation mode, associating with a base station and
+     querying parameters like field strengh and signal quality.
+     Note that there is no ioctl command for leaving adapter configuration
+     mode and returning to regular operation. In order to leave adapter
+     configuration mode, write the command ATO to the device.
+
+     ioctl(int fd, GIGASET_BRKCHARS, unsigned char brkchars[6]);
+     (usb_gigaset only)
+     Set the break characters on an M105's internal serial adapter to the six
+     bytes stored in brkchars[]. Unused bytes should be set to zero.
+
+     ioctl(int fd, GIGASET_VERSION, unsigned version[4]);
+     Retrieve version information from the driver. version[0] must be set to
+     one of:
+     - GIGVER_DRIVER: retrieve driver version
+     - GIGVER_COMPAT: retrieve interface compatibility version
+     - GIGVER_FWBASE: retrieve the firmware version of the base
+     Upon return, version[] is filled with the requested version information.
 
 2.3. ISDN4linux
      ----------
@@ -113,15 +166,24 @@ GigaSet 307x Device Driver
          Connection State: 0, Response: -1
          gigaset_process_response: resp_code -1 in ConState 0 !
          Timeout occurred
-     you might need to use unimodem mode. (see section 2.5.)
+     you probably need to use unimodem mode. (see section 2.5.)
 
 2.4. CAPI
      ----
      If the driver is compiled with CAPI support (kernel configuration option
      GIGASET_CAPI, experimental) it can also be used with CAPI 2.0 kernel and
-     user space applications.  ISDN4Linux is supported in this configuration
+     user space applications. For user space access, the module capi.ko must
+     be loaded. The capiinit command (included in the capi4k-utils package)
+     does this for you.
+
+     The CAPI variant of the driver supports legacy ISDN4Linux applications
      via the capidrv compatibility driver. The kernel module capidrv.ko must
-     be loaded explicitly ("modprobe capidrv") if needed.
+     be loaded explicitly with the command
+        modprobe capidrv
+     if needed, and cannot be unloaded again without unloading the driver
+     first. (These are limitations of capidrv.)
+
+     The note about unimodem mode in the preceding section applies here, too.
 
 2.5. Unimodem mode
      -------------
@@ -134,9 +196,14 @@ GigaSet 307x Device Driver
      You can switch back using
          gigacontr --mode isdn
 
-     You can also load the driver using e.g.
-         modprobe usb_gigaset startmode=0
-     to prevent the driver from starting in "isdn4linux mode".
+     You can also put the driver directly into Unimodem mode when it's loaded,
+     by passing the module parameter startmode=0 to the hardware specific
+     module, e.g.
+	modprobe usb_gigaset startmode=0
+     or by adding a line like
+	options usb_gigaset startmode=0
+     to an appropriate module configuration file, like /etc/modprobe.d/gigaset
+     or /etc/modprobe.conf.local.
 
      In this mode the device works like a modem connected to a serial port
      (the /dev/ttyGU0, ... mentioned above) which understands the commands
@@ -164,9 +231,8 @@ GigaSet 307x Device Driver
 
         options ppp_async flag_time=0
 
-     to /etc/modprobe.conf. If your distribution has some local module
-     configuration file like /etc/modprobe.conf.local,
-     using that should be preferred.
+     to an appropriate module configuration file, like /etc/modprobe.d/gigaset
+     or /etc/modprobe.conf.local.
 
 2.6. Call-ID (CID) mode
      ------------------
@@ -189,12 +255,13 @@ GigaSet 307x Device Driver
        settings (CID mode).
      - If you have several DECT data devices (M10x) which you want to use
        in turn, select Unimodem mode by passing the parameter "cidmode=0" to
-       the driver ("modprobe usb_gigaset cidmode=0" or modprobe.conf).
+       the appropriate driver module (ser_gigaset or usb_gigaset).
 
      If you want both of these at once, you are out of luck.
 
-     You can also use /sys/class/tty/ttyGxy/cidmode for changing the CID mode
-     setting (ttyGxy is ttyGU0 or ttyGB0).
+     You can also use the tty class parameter "cidmode" of the device to
+     change its CID mode while the driver is loaded, eg.
+        echo 0 > /sys/class/tty/ttyGU0/cidmode
 
 2.7. Unregistered Wireless Devices (M101/M105)
      -----------------------------------------
@@ -208,7 +275,7 @@ GigaSet 307x Device Driver
      driver. In that situation, a restricted set of functions is available
      which includes, in particular, those necessary for registering the device
      to a base or for switching it between Fixed Part and Portable Part
-     modes.
+     modes. See the gigacontr(8) manpage for details.
 
 3.   Troubleshooting
      ---------------
@@ -222,9 +289,7 @@ GigaSet 307x Device Driver
 
            options isdn dialtimeout=15
 
-        to /etc/modprobe.conf. If your distribution has some local module
-        configuration file like /etc/modprobe.conf.local,
-        using that should be preferred.
+        to /etc/modprobe.d/gigaset, /etc/modprobe.conf.local or a similar file.
 
      Problem:
         Your isdn script aborts with a message about isdnlog.
@@ -264,7 +329,8 @@ GigaSet 307x Device Driver
      The initial value can be set using the debug parameter when loading the
      module "gigaset", e.g. by adding a line
         options gigaset debug=0
-     to /etc/modprobe.conf, ...
+     to your module configuration file, eg. /etc/modprobe.d/gigaset or
+     /etc/modprobe.conf.local.
 
      Generated debugging information can be found
      - as output of the command
diff --git a/include/linux/gigaset_dev.h b/include/linux/gigaset_dev.h
index 5dc4a31..258ba82 100644
--- a/include/linux/gigaset_dev.h
+++ b/include/linux/gigaset_dev.h
@@ -16,15 +16,23 @@
 
 #include <linux/ioctl.h>
 
+/* The magic IOCTL value for this interface. */
 #define GIGASET_IOCTL 0x47
 
-#define GIGVER_DRIVER 0
-#define GIGVER_COMPAT 1
-#define GIGVER_FWBASE 2
+/* enable/disable device control via character device (lock out ISDN subsys) */
+#define GIGASET_REDIR    _IOWR(GIGASET_IOCTL, 0, int)
 
-#define GIGASET_REDIR    _IOWR (GIGASET_IOCTL, 0, int)
-#define GIGASET_CONFIG   _IOWR (GIGASET_IOCTL, 1, int)
-#define GIGASET_BRKCHARS _IOW  (GIGASET_IOCTL, 2, unsigned char[6]) //FIXME [6] okay?
-#define GIGASET_VERSION  _IOWR (GIGASET_IOCTL, 3, unsigned[4])
+/* enable adapter configuration mode (M10x only) */
+#define GIGASET_CONFIG   _IOWR(GIGASET_IOCTL, 1, int)
+
+/* set break characters (M105 only) */
+#define GIGASET_BRKCHARS _IOW(GIGASET_IOCTL, 2, unsigned char[6])
+
+/* get version information selected by arg[0] */
+#define GIGASET_VERSION  _IOWR(GIGASET_IOCTL, 3, unsigned[4])
+/* values for GIGASET_VERSION arg[0] */
+#define GIGVER_DRIVER 0		/* get driver version */
+#define GIGVER_COMPAT 1		/* get interface compatibility version */
+#define GIGVER_FWBASE 2		/* get base station firmware version */
 
 #endif
-- 
1.6.5.3.298.g39add

