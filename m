From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Mon, 07 Mar 2005 12:10:36 -0500
Message-ID: <422C8B0C.60806@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010006070602020702040406"
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010006070602020702040406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------010006070602020702040406
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 Documentation/networking/bonding.txt    | 2101 ++++++++++++++++++++------------
 drivers/net/3c59x.c                     |    2 
 drivers/net/8139too.c                   |   99 -
 drivers/net/Kconfig                     |   15 
 drivers/net/amd8111e.c                  |    2 
 drivers/net/b44.c                       |    2 
 drivers/net/b44.h                       |   14 
 drivers/net/bonding/bond_alb.c          |    8 
 drivers/net/bonding/bond_main.c         |   35 
 drivers/net/e100.c                      |    4 
 drivers/net/eepro100.c                  |    6 
 drivers/net/epic100.c                   |    2 
 drivers/net/ibmlana.c                   |   99 -
 drivers/net/ibmlana.h                   |    1 
 drivers/net/irda/donauboe.c             |    2 
 drivers/net/mii.c                       |   63 
 drivers/net/natsemi.c                   |    2 
 drivers/net/ne2k-pci.c                  |    4 
 drivers/net/s2io.c                      |   53 
 drivers/net/sis900.c                    |    2 
 drivers/net/sk_mca.c                    |  126 -
 drivers/net/sk_mca.h                    |   19 
 drivers/net/smc91x.h                    |   19 
 drivers/net/sundance.c                  |    7 
 drivers/net/sungem.c                    |    2 
 drivers/net/tg3.c                       |    4 
 drivers/net/tg3.h                       |   14 
 drivers/net/tulip/tulip_core.c          |    2 
 drivers/net/typhoon.c                   |   10 
 drivers/net/via-rhine.c                 |    2 
 drivers/net/via-velocity.c              |    4 
 drivers/net/wireless/arlan.h            |    4 
 drivers/net/wireless/atmel.c            |  103 +
 drivers/net/wireless/atmel.h            |   43 
 drivers/net/wireless/atmel_cs.c         |   49 
 drivers/net/wireless/atmel_pci.c        |    6 
 drivers/net/wireless/prism54/isl_38xx.c |   12 
 include/linux/mii.h                     |   20 
 include/linux/netdevice.h               |    2 
 net/core/dev.c                          |   28 
 40 files changed, 1869 insertions(+), 1123 deletions(-)

through these ChangeSets:

<andi:cosy.sbg.ac.at>:
  o sundance: attempt to address high irqs due to TX overflow

<dcbw:redhat.com>:
  o wireless: Make Atmel driver use SET_NETDEV_DEV
  o wireless: WEXT quality cleanups + max rssi
  o wireless: Clean up firmware loading in

<jchapman:katalix.com>:
  o mii: add GigE support

Alexander Viro:
  o ibmlana part 2 (iomem annotations and isa-ectomy)
  o ibmlana part 1 (netdev_priv())
  o sk_mca - iomem and isa-ectomy
  o sk_mca - netdev_priv()

David T. Hollis:
  o Move MII-related constants from b44/tg3 drivers to linux/mii.h

Jay Vosburgh:
  o bonding: Update/rewrite bonding.txt
  o bonding: Update kconfig description
  o bonding: change misleading warning
  o bonding: use wrappers to change mtu and MAC
  o net/core: move set MAC into separate function

Jeff Garzik:
  o [wireless atmel] Add support LG LW2100N WLAN PCMCIA card

Nishanth Aravamudan:
  o net/s2io: replace schedule_timeout() with msleep()

Paul Mundt:
  o net: port smc91x to SH4-202 Microdev

Pavel Machek:
  o Fix u32 vs. pm_message_t in network device drivers

Randy Dunlap:
  o prism54: fix printk format warnings
  o (v2) arlan: remove gcc warning with CONFIG_PROC_FS=n

Rene Herman:
  o 8139too Interframe Gap Time

Stephen Hemminger:
  o 8139too: use netdev_priv

Thomas Gleixner:
  o rtl8139too.c: Fix missing pci_disable_dev
  o rtl8139too.c: Fix missing pci_disable_dev


--------------010006070602020702040406
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	2005-03-07 12:09:08 -05:00
+++ b/Documentation/networking/bonding.txt	2005-03-07 12:09:08 -05:00
@@ -1,5 +1,5 @@
 
-                   Linux Ethernet Bonding Driver mini-howto
+                   Linux Ethernet Bonding Driver HOWTO
 
 Initial release : Thomas Davis <tadavis at lbl.gov>
 Corrections, HA extensions : 2000/10/03-15 :
@@ -9,8 +9,11 @@
   - Janice Girouard <girouard at us dot ibm dot com>
   - Jay Vosburgh <fubar at us dot ibm dot com>
 
+Reorganized and updated Feb 2005 by Jay Vosburgh
+
 Note :
 ------
+	
 The bonding driver originally came from Donald Becker's beowulf patches for
 kernel 2.0. It has changed quite a bit since, and the original tools from
 extreme-linux and beowulf sites will not work with this version of the driver.
@@ -18,218 +21,190 @@
 For new versions of the driver, patches for older kernels and the updated
 userspace tools, please follow the links at the end of this file.
 
-
 Table of Contents
 =================
 
-Installation
-Bond Configuration
-Module Parameters
-Configuring Multiple Bonds
-Switch Configuration
-Verifying Bond Configuration
-Frequently Asked Questions
-High Availability
-Promiscuous Sniffing notes
-8021q VLAN support
-Limitations
-Resources and Links
-
-
-Installation
-============
-
-1) Build kernel with the bonding driver
----------------------------------------
-For the latest version of the bonding driver, use kernel 2.4.12 or above
-(otherwise you will need to apply a patch).
-
-Configure kernel with `make menuconfig/xconfig/config', and select "Bonding
-driver support" in the "Network device support" section. It is recommended
-to configure the driver as module since it is currently the only way to
-pass parameters to the driver and configure more than one bonding device.
-
-Build and install the new kernel and modules.
-
-2) Get and install the userspace tools
---------------------------------------
-This version of the bonding driver requires updated ifenslave program. The
-original one from extreme-linux and beowulf will not work. Kernels 2.4.12
-and above include the updated version of ifenslave.c in
-Documentation/networking directory. For older kernels, please follow the
-links at the end of this file.
-
-IMPORTANT!!!  If you are running on Redhat 7.1 or greater, you need
-to be careful because /usr/include/linux is no longer a symbolic link
-to /usr/src/linux/include/linux.  If you build ifenslave while this is
-true, ifenslave will appear to succeed but your bond won't work.  The purpose
-of the -I option on the ifenslave compile line is to make sure it uses
-/usr/src/linux/include/linux/if_bonding.h instead of the version from
-/usr/include/linux.
-
-To install ifenslave.c, do:
-    # gcc -Wall -Wstrict-prototypes -O -I/usr/src/linux/include ifenslave.c -o ifenslave
-    # cp ifenslave /sbin/ifenslave
+1. Bonding Driver Installation
 
+2. Bonding Driver Options
 
-Bond Configuration
-==================
+3. Configuring Bonding Devices
+3.1	Configuration with sysconfig support
+3.2	Configuration with initscripts support
+3.3	Configuring Bonding Manually
+3.4	Configuring Multiple Bonds
 
-You will need to add at least the following line to /etc/modprobe.conf
-so the bonding driver will automatically load when the bond0 interface is
-configured. Refer to the modprobe.conf manual page for specific modprobe.conf
-syntax details. The Module Parameters section of this document describes each
-bonding driver parameter.
-
-	alias bond0 bonding
-
-Use standard distribution techniques to define the bond0 network interface. For
-example, on modern Red Hat distributions, create an ifcfg-bond0 file in
-the /etc/sysconfig/network-scripts directory that resembles the following:
+5. Querying Bonding Configuration
+5.1	Bonding Configuration
+5.2	Network Configuration
 
-DEVICE=bond0
-IPADDR=192.168.1.1
-NETMASK=255.255.255.0
-NETWORK=192.168.1.0
-BROADCAST=192.168.1.255
-ONBOOT=yes
-BOOTPROTO=none
-USERCTL=no
+6. Switch Configuration
 
-(use appropriate values for your network above)
+7. 802.1q VLAN Support
 
-All interfaces that are part of a bond should have SLAVE and MASTER
-definitions. For example, in the case of Red Hat, if you wish to make eth0 and
-eth1 a part of the bonding interface bond0, their config files (ifcfg-eth0 and
-ifcfg-eth1) should resemble the following:
+8. Link Monitoring
+8.1	ARP Monitor Operation
+8.2	Configuring Multiple ARP Targets
+8.3	MII Monitor Operation
 
-DEVICE=eth0
-USERCTL=no
-ONBOOT=yes
-MASTER=bond0
-SLAVE=yes
-BOOTPROTO=none
+9. Potential Trouble Sources
+9.1	Adventures in Routing
+9.2	Ethernet Device Renaming
+9.3	Painfully Slow Or No Failed Link Detection By Miimon
 
-Use DEVICE=eth1 in the ifcfg-eth1 config file. If you configure a second
-bonding interface (bond1), use MASTER=bond1 in the config file to make the
-network interface be a slave of bond1.
-
-Restart the networking subsystem or just bring up the bonding device if your
-administration tools allow it. Otherwise, reboot. On Red Hat distros you can
-issue `ifup bond0' or `/etc/rc.d/init.d/network restart'.
-
-If the administration tools of your distribution do not support
-master/slave notation in configuring network interfaces, you will need to
-manually configure the bonding device with the following commands:
-
-    # /sbin/ifconfig bond0 192.168.1.1 netmask 255.255.255.0 \
-      broadcast 192.168.1.255 up
-
-    # /sbin/ifenslave bond0 eth0
-    # /sbin/ifenslave bond0 eth1
-
-(use appropriate values for your network above)
-
-You can then create a script containing these commands and place it in the
-appropriate rc directory.
-
-If you specifically need all network drivers loaded before the bonding driver,
-adding the following line to modprobe.conf will cause the network driver for
-eth0 and eth1 to be loaded before the bonding driver.
-
-install bond0 /sbin/modprobe -a eth0 eth1 && /sbin/modprobe bonding
-
-Be careful not to reference bond0 itself at the end of the line, or modprobe
-will die in an endless recursive loop.
-
-If running SNMP agents, the bonding driver should be loaded before any network
-drivers participating in a bond. This requirement is due to the the interface
-index (ipAdEntIfIndex) being associated to the first interface found with a
-given IP address. That is, there is only one ipAdEntIfIndex for each IP
-address. For example, if eth0 and eth1 are slaves of bond0 and the driver for
-eth0 is loaded before the bonding driver, the interface for the IP address
-will be associated with the eth0 interface. This configuration is shown below,
-the IP address 192.168.1.1 has an interface index of 2 which indexes to eth0
-in the ifDescr table (ifDescr.2).
+10. SNMP agents
 
-     interfaces.ifTable.ifEntry.ifDescr.1 = lo
-     interfaces.ifTable.ifEntry.ifDescr.2 = eth0
-     interfaces.ifTable.ifEntry.ifDescr.3 = eth1
-     interfaces.ifTable.ifEntry.ifDescr.4 = eth2
-     interfaces.ifTable.ifEntry.ifDescr.5 = eth3
-     interfaces.ifTable.ifEntry.ifDescr.6 = bond0
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 5
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 4
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1
+11. Promiscuous mode
 
-This problem is avoided by loading the bonding driver before any network
-drivers participating in a bond. Below is an example of loading the bonding
-driver first, the IP address 192.168.1.1 is correctly associated with
-ifDescr.2.
+12. High Availability Information
+12.1	High Availability in a Single Switch Topology
+12.1.1		Bonding Mode Selection for Single Switch Topology
+12.1.2		Link Monitoring for Single Switch Topology
+12.2	High Availability in a Multiple Switch Topology
+12.2.1		Bonding Mode Selection for Multiple Switch Topology
+12.2.2		Link Monitoring for Multiple Switch Topology
+12.3	Switch Behavior Issues for High Availability
 
-     interfaces.ifTable.ifEntry.ifDescr.1 = lo
-     interfaces.ifTable.ifEntry.ifDescr.2 = bond0
-     interfaces.ifTable.ifEntry.ifDescr.3 = eth0
-     interfaces.ifTable.ifEntry.ifDescr.4 = eth1
-     interfaces.ifTable.ifEntry.ifDescr.5 = eth2
-     interfaces.ifTable.ifEntry.ifDescr.6 = eth3
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 6
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 5
-     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1
+13. Hardware Specific Considerations
+13.1	IBM BladeCenter
 
-While some distributions may not report the interface name in ifDescr,
-the association between the IP address and IfIndex remains and SNMP
-functions such as Interface_Scan_Next will report that association.
+14. Frequently Asked Questions
 
+15. Resources and Links
 
-Module Parameters
-=================
 
-Optional parameters for the bonding driver can be supplied as command line
-arguments to the insmod command. Typically, these parameters are specified in
-the file /etc/modprobe.conf (see the manual page for modprobe.conf). The
-available bonding driver parameters are listed below. If a parameter is not
-specified the default value is used. When initially configuring a bond, it
-is recommended "tail -f /var/log/messages" be run in a separate window to
-watch for bonding driver error messages.
-
-It is critical that either the miimon or arp_interval and arp_ip_target
-parameters be specified, otherwise serious network degradation will occur
-during link failures.
+1. Bonding Driver Installation
+==============================
+
+	Most popular distro kernels ship with the bonding driver
+already available as a module and the ifenslave user level control
+program installed and ready for use. If your distro does not, or you
+have need to compile bonding from source (e.g., configuring and
+installing a mainline kernel from kernel.org), you'll need to perform
+the following steps:
+
+1.1 Configure and build the kernel with bonding
+-----------------------------------------------
+
+	The latest version of the bonding driver is available in the
+drivers/net/bonding subdirectory of the most recent kernel source
+(which is available on http://kernel.org).
+
+	Prior to the 2.4.11 kernel, the bonding driver was maintained
+largely outside the kernel tree; patches for some earlier kernels are
+available on the bonding sourceforge site, although those patches are
+still several years out of date.  Most users will want to use either
+the most recent kernel from kernel.org or whatever kernel came with
+their distro.
+
+	Configure kernel with "make menuconfig" (or "make xconfig" or
+"make config"), then select "Bonding driver support" in the "Network
+device support" section.  It is recommended that you configure the
+driver as module since it is currently the only way to pass parameters
+to the driver or configure more than one bonding device.
+
+	Build and install the new kernel and modules, then proceed to
+step 2.
+
+1.2 Install ifenslave Control Utility
+-------------------------------------
+
+	The ifenslave user level control program is included in the
+kernel source tree, in the file Documentation/networking/ifenslave.c.
+It is generally recommended that you use the ifenslave that
+corresponds to the kernel that you are using (either from the same
+source tree or supplied with the distro), however, ifenslave
+executables from older kernels should function (but features newer
+than the ifenslave release are not supported).  Running an ifenslave
+that is newer than the kernel is not supported, and may or may not
+work.
+
+	To install ifenslave, do the following:
+
+# gcc -Wall -O -I/usr/src/linux/include ifenslave.c -o ifenslave
+# cp ifenslave /sbin/ifenslave
+
+	If your kernel source is not in "/usr/src/linux," then replace
+"/usr/src/linux/include" in the above with the location of your kernel
+source include directory.
+
+	You may wish to back up any existing /sbin/ifenslave, or, for
+testing or informal use, tag the ifenslave to the kernel version
+(e.g., name the ifenslave executable /sbin/ifenslave-2.6.10).
+
+IMPORTANT NOTE:
+
+	If you omit the "-I" or specify an incorrect directory, you
+may end up with an ifenslave that is incompatible with the kernel
+you're trying to build it for.  Some distros (e.g., Red Hat from 7.1
+onwards) do not have /usr/include/linux symbolically linked to the
+default kernel source include directory.
+
+
+2. Bonding Driver Options
+=========================
+
+	Options for the bonding driver are supplied as parameters to
+the bonding module at load time.  They may be given as command line
+arguments to the insmod or modprobe command, but are usually specified
+in either the /etc/modprobe.conf configuration file, or in a
+distro-specific configuration file (some of which are detailed in the
+next section).
+
+	The available bonding driver parameters are listed below. If a
+parameter is not specified the default value is used.  When initially
+configuring a bond, it is recommended "tail -f /var/log/messages" be
+run in a separate window to watch for bonding driver error messages.
+
+	It is critical that either the miimon or arp_interval and
+arp_ip_target parameters be specified, otherwise serious network
+degradation will occur during link failures.  Very few devices do not
+support at least miimon, so there is really no reason not to use it.
+
+	Options with textual values will accept either the text name
+	or, for backwards compatibility, the option value.  E.g.,
+	"mode=802.3ad" and "mode=4" set the same mode.
+
+	The parameters are as follows:
 
 arp_interval
 
-        Specifies the ARP monitoring frequency in milli-seconds.
-        If ARP monitoring is used in a load-balancing mode (mode 0 or 2), the
-        switch should be configured in a mode that evenly distributes packets
-        across all links - such as round-robin. If the switch is configured to
-        distribute the packets in an XOR fashion, all replies from the ARP
-        targets will be received on the same link which could cause the other
-        team members to fail. ARP monitoring should not be used in conjunction
-        with miimon. A value of 0 disables ARP monitoring. The default value
-        is 0.
+	Specifies the ARP monitoring frequency in milli-seconds. If
+	ARP monitoring is used in a load-balancing mode (mode 0 or 2),
+	the switch should be configured in a mode that evenly
+	distributes packets across all links - such as round-robin. If
+	the switch is configured to distribute the packets in an XOR
+	fashion, all replies from the ARP targets will be received on
+	the same link which could cause the other team members to
+	fail. ARP monitoring should not be used in conjunction with
+	miimon. A value of 0 disables ARP monitoring. The default
+	value is 0.
 
 arp_ip_target
 
-	Specifies the ip addresses to use when arp_interval is > 0. These
-	are the targets of the ARP request sent to determine the health of
-	the link to the targets. Specify these values in ddd.ddd.ddd.ddd
-	format. Multiple ip adresses must be seperated by a comma. At least
-	one ip address needs to be given for ARP monitoring to work. The
-	maximum number of targets that can be specified is set at 16.
+	Specifies the ip addresses to use when arp_interval is > 0.
+	These are the targets of the ARP request sent to determine the
+	health of the link to the targets.  Specify these values in
+	ddd.ddd.ddd.ddd format.  Multiple ip adresses must be
+	seperated by a comma.  At least one IP address must be given
+	for ARP monitoring to function.  The maximum number of targets
+	that can be specified is 16.  The default value is no IP
+	addresses.
 
 downdelay
 
-        Specifies the delay time in milli-seconds to disable a link after a
-        link failure has been detected. This should be a multiple of miimon
-        value, otherwise the value will be rounded. The default value is 0.
+	Specifies the time, in milliseconds, to wait before disabling
+	a slave after a link failure has been detected.  This option
+	is only valid for the miimon link monitor.  The downdelay
+	value should be a multiple of the miimon value; if not, it
+	will be rounded down to the nearest multiple.  The default
+	value is 0.
 
 lacp_rate
 
-        Option specifying the rate in which we'll ask our link partner to
-	transmit LACPDU packets in 802.3ad mode.  Possible values are:
+	Option specifying the rate in which we'll ask our link partner
+	to transmit LACPDU packets in 802.3ad mode.  Possible values
+	are:
 
 	slow or 0
 		Request partner to transmit LACPDUs every 30 seconds (default)
@@ -246,69 +221,76 @@
 
 miimon
 
-        Specifies the frequency in milli-seconds that MII link monitoring
-        will occur. A value of zero disables MII link monitoring. A value
-        of 100 is a good starting point. See High Availability section for
-        additional information. The default value is 0.
+	Specifies the frequency in milli-seconds that MII link
+	monitoring will occur.  A value of zero disables MII link
+	monitoring.  A value of 100 is a good starting point.  The
+	use_carrier option, below, affects how the link state is
+	determined.  See the High Availability section for additional
+	information.  The default value is 0.
 
 mode
 
 	Specifies one of the bonding policies. The default is
-	round-robin (balance-rr).  Possible values are (you can use
-	either the text or numeric option):
+	balance-rr (round robin).  Possible values are:
 
 	balance-rr or 0
 
-		Round-robin policy: Transmit in a sequential order
-		from the first available slave through the last. This
-		mode provides load balancing and fault tolerance.
+		Round-robin policy: Transmit packets in sequential
+		order from the first available slave through the
+		last.  This mode provides load balancing and fault
+		tolerance.
 
 	active-backup or 1
 
 		Active-backup policy: Only one slave in the bond is
-		active. A different slave becomes active if, and only
-		if, the active slave fails. The bond's MAC address is
+		active.  A different slave becomes active if, and only
+		if, the active slave fails.  The bond's MAC address is
 		externally visible on only one port (network adapter)
 		to avoid confusing the switch.  This mode provides
-		fault tolerance.
+		fault tolerance.  The primary option affects the
+		behavior of this mode.
 
 	balance-xor or 2
 
 		XOR policy: Transmit based on [(source MAC address
-		XOR'd with destination MAC address) modula slave
-		count]. This selects the same slave for each
-		destination MAC address. This mode provides load
+		XOR'd with destination MAC address) modulo slave
+		count].  This selects the same slave for each
+		destination MAC address.  This mode provides load
 		balancing and fault tolerance.
 
 	broadcast or 3
 
 		Broadcast policy: transmits everything on all slave
-		interfaces. This mode provides fault tolerance.
+		interfaces.  This mode provides fault tolerance.
 
 	802.3ad or 4
 
-		IEEE 802.3ad Dynamic link aggregation. Creates aggregation
-		groups that share the same speed and duplex settings.
-		Transmits and receives on all slaves in the active
-		aggregator.
+		IEEE 802.3ad Dynamic link aggregation.  Creates
+		aggregation groups that share the same speed and
+		duplex settings.  Utilizes all slaves in the active
+		aggregator according to the 802.3ad specification.
 
 		Pre-requisites:
 
-		1. Ethtool support in the base drivers for retrieving the
-		speed and duplex of each slave.
+		1. Ethtool support in the base drivers for retrieving
+		the speed and duplex of each slave.
 
 		2. A switch that supports IEEE 802.3ad Dynamic link
 		aggregation.
 
+		Most switches will require some type of configuration
+		to enable 802.3ad mode.
+
 	balance-tlb or 5
 
-		Adaptive transmit load balancing: channel bonding that does
-		not require any special switch support. The outgoing
-		traffic is distributed according to the current load
-		(computed relative to the speed) on each slave. Incoming
-		traffic is received by the current slave. If the receiving
-		slave fails, another slave takes over the MAC address of
-		the failed receiving slave.
+		Adaptive transmit load balancing: channel bonding that
+		does not require any special switch support.  The
+		outgoing traffic is distributed according to the
+		current load (computed relative to the speed) on each
+		slave.  Incoming traffic is received by the current
+		slave.  If the receiving slave fails, another slave
+		takes over the MAC address of the failed receiving
+		slave.
 
 		Prerequisite:
 
@@ -317,205 +299,452 @@
 
 	balance-alb or 6
 
-		Adaptive load balancing: includes balance-tlb + receive
-		load balancing (rlb) for IPV4 traffic and does not require
-		any special switch support. The receive load balancing is
-		achieved by ARP negotiation. The bonding driver intercepts
-		the ARP Replies sent by the server on their way out and
-		overwrites the src hw address with the unique hw address of
-		one of the slaves in the bond such that different clients
-		use different hw addresses for the server.
-
-		Receive traffic from connections created by the server is
-		also balanced. When the server sends an ARP Request the
-		bonding driver copies and saves the client's IP information
-		from the ARP. When the ARP Reply arrives from the client,
-		its hw address is retrieved and the bonding driver
-		initiates an ARP reply to this client assigning it to one
-		of the slaves in the bond. A problematic outcome of using
-		ARP negotiation for balancing is that each time that an ARP
-		request is broadcasted it uses the hw address of the
-		bond. Hence, clients learn the hw address of the bond and
-		the balancing of receive traffic collapses to the current
-		salve. This is handled by sending updates (ARP Replies) to
-		all the clients with their assigned hw address such that
-		the traffic is redistributed. Receive traffic is also
-		redistributed when a new slave is added to the bond and
-		when an inactive slave is re-activated. The receive load is
-		distributed sequentially (round robin) among the group of
-		highest speed slaves in the bond.
-
-		When a link is reconnected or a new slave joins the bond
-		the receive traffic is redistributed among all active
-		slaves in the bond by intiating ARP Replies with the
-		selected mac address to each of the clients. The updelay
-		modeprobe parameter must be set to a value equal or greater
-		than the switch's forwarding delay so that the ARP Replies
-		sent to the clients will not be blocked by the switch.
+		Adaptive load balancing: includes balance-tlb plus
+		receive load balancing (rlb) for IPV4 traffic, and
+		does not require any special switch support.  The
+		receive load balancing is achieved by ARP negotiation.
+		The bonding driver intercepts the ARP Replies sent by
+		the local system on their way out and overwrites the
+		source hardware address with the unique hardware
+		address of one of the slaves in the bond such that
+		different peers use different hardware addresses for
+		the server.
+
+		Receive traffic from connections created by the server
+		is also balanced.  When the local system sends an ARP
+		Request the bonding driver copies and saves the peer's
+		IP information from the ARP packet.  When the ARP
+		Reply arrives from the peer, its hardware address is
+		retrieved and the bonding driver initiates an ARP
+		reply to this peer assigning it to one of the slaves
+		in the bond.  A problematic outcome of using ARP
+		negotiation for balancing is that each time that an
+		ARP request is broadcast it uses the hardware address
+		of the bond.  Hence, peers learn the hardware address
+		of the bond and the balancing of receive traffic
+		collapses to the current slave.  This is handled by
+		sending updates (ARP Replies) to all the peers with
+		their individually assigned hardware address such that
+		the traffic is redistributed.  Receive traffic is also
+		redistributed when a new slave is added to the bond
+		and when an inactive slave is re-activated.  The
+		receive load is distributed sequentially (round robin)
+		among the group of highest speed slaves in the bond.
+
+		When a link is reconnected or a new slave joins the
+		bond the receive traffic is redistributed among all
+		active slaves in the bond by intiating ARP Replies
+		with the selected mac address to each of the
+		clients. The updelay parameter (detailed below) must
+		be set to a value equal or greater than the switch's
+		forwarding delay so that the ARP Replies sent to the
+		peers will not be blocked by the switch.
 
 		Prerequisites:
 
-		1. Ethtool support in the base drivers for retrieving the
-		speed of each slave.
+		1. Ethtool support in the base drivers for retrieving
+		the speed of each slave.
 
-		2. Base driver support for setting the hw address of a
-		device also when it is open. This is required so that there
-		will always be one slave in the team using the bond hw
-		address (the curr_active_slave) while having a unique hw
-		address for each slave in the bond. If the curr_active_slave
-		fails it's hw address is swapped with the new curr_active_slave
-		that was chosen.
+		2. Base driver support for setting the hardware
+		address of a device while it is open.  This is
+		required so that there will always be one slave in the
+		team using the bond hardware address (the
+		curr_active_slave) while having a unique hardware
+		address for each slave in the bond.  If the
+		curr_active_slave fails its hardware address is
+		swapped with the new curr_active_slave that was
+		chosen.
 
 primary
 
-        A string (eth0, eth2, etc) to equate to a primary device. If this
-        value is entered, and the device is on-line, it will be used first
-        as the output media. Only when this device is off-line, will
-        alternate devices be used. Otherwise, once a failover is detected
-        and a new default output is chosen, it will remain the output media
-        until it too fails. This is useful when one slave was preferred
-        over another, i.e. when one slave is 1000Mbps and another is
-        100Mbps. If the 1000Mbps slave fails and is later restored, it may
-        be preferred the faster slave gracefully become the active slave -
-        without deliberately failing the 100Mbps slave. Specifying a
-        primary is only valid in active-backup mode.
+	A string (eth0, eth2, etc) specifying which slave is the
+	primary device.  The specified device will always be the
+	active slave while it is available.  Only when the primary is
+	off-line will alternate devices be used.  This is useful when
+	one slave is preferred over another, e.g., when one slave has
+	higher throughput than another.
+
+	The primary option is only valid for active-backup mode.
 
 updelay
 
-        Specifies the delay time in milli-seconds to enable a link after a
-        link up status has been detected. This should be a multiple of miimon
-        value, otherwise the value will be rounded. The default value is 0.
+	Specifies the time, in milliseconds, to wait before enabling a
+	slave after a link recovery has been detected.  This option is
+	only valid for the miimon link monitor.  The updelay value
+	should be a multiple of the miimon value; if not, it will be
+	rounded down to the nearest multiple.  The default value is 0.
 
 use_carrier
 
-        Specifies whether or not miimon should use MII or ETHTOOL
-        ioctls vs. netif_carrier_ok() to determine the link status.
-        The MII or ETHTOOL ioctls are less efficient and utilize a
-        deprecated calling sequence within the kernel.  The
-        netif_carrier_ok() relies on the device driver to maintain its
-        state with netif_carrier_on/off; at this writing, most, but
-        not all, device drivers support this facility.
-
-        If bonding insists that the link is up when it should not be,
-        it may be that your network device driver does not support
-        netif_carrier_on/off.  This is because the default state for
-        netif_carrier is "carrier on." In this case, disabling
-        use_carrier will cause bonding to revert to the MII / ETHTOOL
-        ioctl method to determine the link state.
-
-        A value of 1 enables the use of netif_carrier_ok(), a value of
-        0 will use the deprecated MII / ETHTOOL ioctls.  The default
-        value is 1.
-
-
-Configuring Multiple Bonds
-==========================
-
-If several bonding interfaces are required, either specify the max_bonds
-parameter (described above), or load the driver multiple times.  Using
-the max_bonds parameter is less complicated, but has the limitation that
-all bonding instances created will have the same options.  Loading the
-driver multiple times allows each instance of the driver to have differing
-options.
-
-For example, to configure two bonding interfaces, one with mii link
-monitoring performed every 100 milliseconds, and one with ARP link
-monitoring performed every 200 milliseconds, the /etc/conf.modules should
-resemble the following:
+	Specifies whether or not miimon should use MII or ETHTOOL
+	ioctls vs. netif_carrier_ok() to determine the link
+	status. The MII or ETHTOOL ioctls are less efficient and
+	utilize a deprecated calling sequence within the kernel.  The
+	netif_carrier_ok() relies on the device driver to maintain its
+	state with netif_carrier_on/off; at this writing, most, but
+	not all, device drivers support this facility.
+
+	If bonding insists that the link is up when it should not be,
+	it may be that your network device driver does not support
+	netif_carrier_on/off.  The default state for netif_carrier is
+	"carrier on," so if a driver does not support netif_carrier,
+	it will appear as if the link is always up.  In this case,
+	setting use_carrier to 0 will cause bonding to revert to the
+	MII / ETHTOOL ioctl method to determine the link state.
+
+	A value of 1 enables the use of netif_carrier_ok(), a value of
+	0 will use the deprecated MII / ETHTOOL ioctls.  The default
+	value is 1.
+
+
+
+3. Configuring Bonding Devices
+==============================
+
+	There are, essentially, two methods for configuring bonding:
+with support from the distro's network initialization scripts, and
+without.  Distros generally use one of two packages for the network
+initialization scripts: initscripts or sysconfig.  Recent versions of
+these packages have support for bonding, while older versions do not.
+
+	We will first describe the options for configuring bonding for
+distros using versions of initscripts and sysconfig with full or
+partial support for bonding, then provide information on enabling
+bonding without support from the network initialization scripts (i.e.,
+older versions of initscripts or sysconfig).
+
+	If you're unsure whether your distro uses sysconfig or
+initscripts, or don't know if it's new enough, have no fear.
+Determining this is fairly straightforward.
+
+	First, issue the command:
+
+$ rpm -qf /sbin/ifup
+
+	It will respond with a line of text starting with either
+"initscripts" or "sysconfig," followed by some numbers.  This is the
+package that provides your network initialization scripts.
+
+	Next, to determine if your installation supports bonding,
+issue the command:
+
+$ grep ifenslave /sbin/ifup
+
+	If this returns any matches, then your initscripts or
+sysconfig has support for bonding.
+
+3.1 Configuration with sysconfig support
+----------------------------------------
+
+	This section applies to distros using a version of sysconfig
+with bonding support, for example, SuSE Linux Enterprise Server 9.
+
+	SuSE SLES 9's networking configuration system does support
+bonding, however, at this writing, the YaST system configuration
+frontend does not provide any means to work with bonding devices.
+Bonding devices can be managed by hand, however, as follows.
+
+	First, if they have not already been configured, configure the
+slave devices.  On SLES 9, this is most easily done by running the
+yast2 sysconfig configuration utility.  The goal is for to create an
+ifcfg-id file for each slave device.  The simplest way to accomplish
+this is to configure the devices for DHCP.  The name of the
+configuration file for each device will be of the form:
+
+ifcfg-id-xx:xx:xx:xx:xx:xx
+
+	Where the "xx" portion will be replaced with the digits from
+the device's permanent MAC address.
+
+	Once the set of ifcfg-id-xx:xx:xx:xx:xx:xx files has been
+created, it is necessary to edit the configuration files for the slave
+devices (the MAC addresses correspond to those of the slave devices).
+Before editing, the file will contain muliple lines, and will look
+something like this:
+
+BOOTPROTO='dhcp'
+STARTMODE='on'
+USERCTL='no'
+UNIQUE='XNzu.WeZGOGF+4wE'
+_nm_name='bus-pci-0001:61:01.0'
+
+	Change the BOOTPROTO and STARTMODE lines to the following:
+
+BOOTPROTO='none'
+STARTMODE='off'
+
+	Do not alter the UNIQUE or _nm_name lines.  Remove any other
+lines (USERCTL, etc).
+
+	Once the ifcfg-id-xx:xx:xx:xx:xx:xx files have been modified,
+it's time to create the configuration file for the bonding device
+itself.  This file is named ifcfg-bondX, where X is the number of the
+bonding device to create, starting at 0.  The first such file is
+ifcfg-bond0, the second is ifcfg-bond1, and so on.  The sysconfig
+network configuration system will correctly start multiple instances
+of bonding.
+
+	The contents of the ifcfg-bondX file is as follows:
+
+BOOTPROTO="static"
+BROADCAST="10.0.2.255"
+IPADDR="10.0.2.10"
+NETMASK="255.255.0.0"
+NETWORK="10.0.2.0"
+REMOTE_IPADDR=""
+STARTMODE="onboot"
+BONDING_MASTER="yes"
+BONDING_MODULE_OPTS="mode=active-backup miimon=100"
+BONDING_SLAVE0="eth0"
+BONDING_SLAVE1="eth1"
+
+	Replace the sample BROADCAST, IPADDR, NETMASK and NETWORK
+values with the appropriate values for your network.
+
+	Note that configuring the bonding device with BOOTPROTO='dhcp'
+does not work; the scripts attempt to obtain the device address from
+DHCP prior to adding any of the slave devices.  Without active slaves,
+the DHCP requests are not sent to the network.
+
+	The STARTMODE specifies when the device is brought online.
+The possible values are:
+
+	onboot:	 The device is started at boot time.  If you're not
+		 sure, this is probably what you want.
+
+	manual:	 The device is started only when ifup is called
+		 manually.  Bonding devices may be configured this
+		 way if you do not wish them to start automatically
+		 at boot for some reason.
+
+	hotplug: The device is started by a hotplug event.  This is not
+		 a valid choice for a bonding device.
+
+	off or ignore: The device configuration is ignored.
+
+	The line BONDING_MASTER='yes' indicates that the device is a
+bonding master device.  The only useful value is "yes."
+
+	The contents of BONDING_MODULE_OPTS are supplied to the
+instance of the bonding module for this device.  Specify the options
+for the bonding mode, link monitoring, and so on here.  Do not include
+the max_bonds bonding parameter; this will confuse the configuration
+system if you have multiple bonding devices.
+
+	Finally, supply one BONDING_SLAVEn="ethX" for each slave,
+where "n" is an increasing value, one for each slave, and "ethX" is
+the name of the slave device (eth0, eth1, etc).
+
+	When all configuration files have been modified or created,
+networking must be restarted for the configuration changes to take
+effect.  This can be accomplished via the following:
+
+# /etc/init.d/network restart
+
+	Note that the network control script (/sbin/ifdown) will
+remove the bonding module as part of the network shutdown processing,
+so it is not necessary to remove the module by hand if, e.g., the
+module paramters have changed.
+
+	Also, at this writing, YaST/YaST2 will not manage bonding
+devices (they do not show bonding interfaces on its list of network
+devices).  It is necessary to edit the configuration file by hand to
+change the bonding configuration.
+
+	Additional general options and details of the ifcfg file
+format can be found in an example ifcfg template file:
+
+/etc/sysconfig/network/ifcfg.template
+
+	Note that the template does not document the various BONDING_
+settings described above, but does describe many of the other options.
+
+3.2 Configuration with initscripts support
+------------------------------------------
+
+	This section applies to distros using a version of initscripts
+with bonding support, for example, Red Hat Linux 9 or Red Hat
+Enterprise Linux version 3.  On these systems, the network
+initialization scripts have some knowledge of bonding, and can be
+configured to control bonding devices.
+
+	These distros will not automatically load the network adapter
+driver unless the ethX device is configured with an IP address.
+Because of this constraint, users must manually configure a
+network-script file for all physical adapters that will be members of
+a bondX link.  Network script files are located in the directory:
+
+/etc/sysconfig/network-scripts
+
+	The file name must be prefixed with "ifcfg-eth" and suffixed
+with the adapter's physical adapter number.  For example, the script
+for eth0 would be named /etc/sysconfig/network-scripts/ifcfg-eth0.
+Place the following text in the file:
 
-alias bond0 bonding
-alias bond1 bonding
+DEVICE=eth0
+USERCTL=no
+ONBOOT=yes
+MASTER=bond0
+SLAVE=yes
+BOOTPROTO=none
 
-options bond0 miimon=100
-options bond1 -o bonding1 arp_interval=200 arp_ip_target=10.0.0.1
+	The DEVICE= line will be different for every ethX device and
+must correspond with the name of the file, i.e., ifcfg-eth1 must have
+a device line of DEVICE=eth1.  The setting of the MASTER= line will
+also depend on the final bonding interface name chosen for your bond.
+As with other network devices, these typically start at 0, and go up
+one for each device, i.e., the first bonding instance is bond0, the
+second is bond1, and so on.
+
+	Next, create a bond network script.  The file name for this
+script will be /etc/sysconfig/network-scripts/ifcfg-bondX where X is
+the number of the bond.  For bond0 the file is named "ifcfg-bond0",
+for bond1 it is named "ifcfg-bond1", and so on.  Within that file,
+place the following text:
 
-Configuring Multiple ARP Targets
-================================
+DEVICE=bond0
+IPADDR=192.168.1.1
+NETMASK=255.255.255.0
+NETWORK=192.168.1.0
+BROADCAST=192.168.1.255
+ONBOOT=yes
+BOOTPROTO=none
+USERCTL=no
 
-While ARP monitoring can be done with just one target, it can be useful
-in a High Availability setup to have several targets to monitor. In the
-case of just one target,  the target itself may go down or have a problem
-making it unresponsive to ARP requests. Having an additional target (or
-several) increases the reliability of the ARP monitoring.
+	Be sure to change the networking specific lines (IPADDR,
+NETMASK, NETWORK and BROADCAST) to match your network configuration.
 
-Multiple ARP targets must be seperated by commas as follows:
+	Finally, it is necessary to edit /etc/modules.conf to load the
+bonding module when the bond0 interface is brought up.  The following
+sample lines in /etc/modules.conf will load the bonding module, and
+select its options:
 
-# example options for ARP monitoring with three targets
 alias bond0 bonding
-options bond0 arp_interval=60 arp_ip_target=192.168.0.1,192.168.0.3,192.168.0.9
+options bond0 mode=balance-alb miimon=100
 
-For just a single target the options would resemble:
+	Replace the sample parameters with the appropriate set of
+options for your configuration.
 
-# example options for ARP monitoring with one target
+	Finally run "/etc/rc.d/init.d/network restart" as root.  This
+will restart the networking subsystem and your bond link should be now
+up and running.
+
+
+3.3 Configuring Bonding Manually
+--------------------------------
+
+	This section applies to distros whose network initialization
+scripts (the sysconfig or initscripts package) do not have specific
+knowledge of bonding.  One such distro is SuSE Linux Enterprise Server
+version 8.
+
+	The general methodology for these systems is to place the
+bonding module parameters into /etc/modprobe.conf, then add modprobe
+and/or ifenslave commands to the system's global init script.  The
+name of the global init script differs; for sysconfig, it is
+/etc/init.d/boot.local and for initscripts it is /etc/rc.d/rc.local.
+
+	For example, if you wanted to make a simple bond of two e100
+devices (presumed to be eth0 and eth1), and have it persist across
+reboots, edit the appropriate file (/etc/init.d/boot.local or
+/etc/rc.d/rc.local), and add the following:
+
+modprobe bonding -obond0 mode=balance-alb miimon=100
+modprobe e100
+ifconfig bond0 192.168.1.1 netmask 255.255.255.0 up
+ifenslave bond0 eth0
+ifenslave bond0 eth1
+
+	Replace the example bonding module parameters and bond0
+network configuration (IP address, netmask, etc) with the appropriate
+values for your configuration.  The above example loads the bonding
+module with the name "bond0," this simplifies the naming if multiple
+bonding modules are loaded (each successive instance of the module is
+given a different name, and the module instance names match the
+bonding interface names).
+
+	Unfortunately, this method will not provide support for the
+ifup and ifdown scripts on the bond devices.  To reload the bonding
+configuration, it is necessary to run the initialization script, e.g.,
+
+# /etc/init.d/boot.local
+
+	or
+
+# /etc/rc.d/rc.local
+
+	It may be desirable in such a case to create a separate script
+which only initializes the bonding configuration, then call that
+separate script from within boot.local.  This allows for bonding to be
+enabled without re-running the entire global init script.
+
+	To shut down the bonding devices, it is necessary to first
+mark the bonding device itself as being down, then remove the
+appropriate device driver modules.  For our example above, you can do
+the following:
+
+# ifconfig bond0 down
+# rmmod bond0
+# rmmod e100
+
+	Again, for convenience, it may be desirable to create a script
+with these commands.
+
+
+3.4 Configuring Multiple Bonds
+------------------------------
+
+	This section contains information on configuring multiple
+bonding devices with differing options.  If you require multiple
+bonding devices, but all with the same options, see the "max_bonds"
+module paramter, documented above.
+
+	To create multiple bonding devices with differing options, it
+is necessary to load the bonding driver multiple times.  Note that
+current versions of the sysconfig network initialization scripts
+handle this automatically; if your distro uses these scripts, no
+special action is needed.  See the section Configuring Bonding
+Devices, above, if you're not sure about your network initialization
+scripts.
+
+	To load multiple instances of the module, it is necessary to
+specify a different name for each instance (the module loading system
+requires that every loaded module, even multiple instances of the same
+module, have a unique name).  This is accomplished by supplying
+multiple sets of bonding options in /etc/modprobe.conf, for example:
+	
 alias bond0 bonding
-options bond0 arp_interval=60 arp_ip_target=192.168.0.100
-
-Potential Problems When Using ARP Monitor
-=========================================
+options bond0 -o bond0 mode=balance-rr miimon=100
 
-1. Driver support
-
-The ARP monitor relies on the network device driver to maintain two
-statistics: the last receive time (dev->last_rx), and the last
-transmit time (dev->trans_start).  If the network device driver does
-not update one or both of these, then the typical result will be that,
-upon startup, all links in the bond will immediately be declared down,
-and remain that way.  A network monitoring tool (tcpdump, e.g.) will
-show ARP requests and replies being sent and received on the bonding
-device.
-
-The possible resolutions for this are to (a) fix the device driver, or
-(b) discontinue the ARP monitor (using miimon as an alternative, for
-example).
-
-2. Adventures in Routing
-
-When bonding is set up with the ARP monitor, it is important that the
-slave devices not have routes that supercede routes of the master (or,
-generally, not have routes at all).  For example, suppose the bonding
-device bond0 has two slaves, eth0 and eth1, and the routing table is
-as follows:
-
-Kernel IP routing table
-Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
-10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 eth0
-10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 eth1
-10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 bond0
-127.0.0.0       0.0.0.0         255.0.0.0       U        40 0          0 lo
+alias bond1 bonding
+options bond1 -o bond1 mode=balance-alb miimon=50
 
-In this case, the ARP monitor (and ARP itself) may become confused,
-because ARP requests will be sent on one interface (bond0), but the
-corresponding reply will arrive on a different interface (eth0).  This
-reply looks to ARP as an unsolicited ARP reply (because ARP matches
-replies on an interface basis), and is discarded.  This will likely
-still update the receive/transmit times in the driver, but will lose
-packets.
-
-The resolution here is simply to insure that slaves do not have routes
-of their own, and if for some reason they must, those routes do not
-supercede routes of their master.  This should generally be the case,
-but unusual configurations or errant manual or automatic static route
-additions may cause trouble.
+	will load the bonding module two times.  The first instance is
+named "bond0" and creates the bond0 device in balance-rr mode with an
+miimon of 100.  The second instance is named "bond1" and creates the
+bond1 device in balance-alb mode with an miimon of 50.
 
-Switch Configuration
-====================
+	This may be repeated any number of times, specifying a new and
+unique name in place of bond0 or bond1 for each instance.
 
-While the switch does not need to be configured when the active-backup,
-balance-tlb or balance-alb policies (mode=1,5,6) are used, it does need to
-be configured for the round-robin, XOR, broadcast, or 802.3ad policies
-(mode=0,2,3,4).
+	When the appropriate module paramters are in place, then
+configure bonding according to the instructions for your distro.
 
+5. Querying Bonding Configuration 
+=================================
 
-Verifying Bond Configuration
-============================
+5.1 Bonding Configuration
+-------------------------
 
-1) Bonding information files
-----------------------------
-The bonding driver information files reside in the /proc/net/bonding directory.
+	Each bonding device has a read-only file residing in the
+/proc/net/bonding directory.  The file contents include information
+about the bonding configuration, options and state of each slave.
 
-Sample contents of /proc/net/bonding/bond0 after the driver is loaded with
-parameters of mode=0 and miimon=1000 is shown below.
+	For example, the contents of /proc/net/bonding/bond0 after the
+driver is loaded with parameters of mode=0 and miimon=1000 is
+generally as follows:
 
+	Ethernet Channel Bonding Driver: 2.6.1 (October 29, 2004)
         Bonding Mode: load balancing (round-robin)
         Currently Active Slave: eth0
         MII Status: up
@@ -531,15 +760,23 @@
         MII Status: up
         Link Failure Count: 1
 
-2) Network verification
------------------------
-The network configuration can be verified using the ifconfig command. In
-the example below, the bond0 interface is the master (MASTER) while eth0 and
-eth1 are slaves (SLAVE). Notice all slaves of bond0 have the same MAC address
-(HWaddr) as bond0 for all modes except TLB and ALB that require a unique MAC
-address for each slave.
+	The precise format and contents will change depending upon the
+bonding configuration, state, and version of the bonding driver.
+
+5.2 Network configuration
+-------------------------
+
+	The network configuration can be inspected using the ifconfig
+command.  Bonding devices will have the MASTER flag set; Bonding slave
+devices will have the SLAVE flag set.  The ifconfig output does not
+contain information on which slaves are associated with which masters.
+
+	In the example below, the bond0 interface is the master
+(MASTER) while eth0 and eth1 are slaves (SLAVE). Notice all slaves of
+bond0 have the same MAC address (HWaddr) as bond0 for all modes except
+TLB and ALB that require a unique MAC address for each slave.
 
-[root]# /sbin/ifconfig
+# /sbin/ifconfig
 bond0     Link encap:Ethernet  HWaddr 00:C0:F0:1F:37:B4
           inet addr:XXX.XXX.XXX.YYY  Bcast:XXX.XXX.XXX.255  Mask:255.255.252.0
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
@@ -563,430 +800,819 @@
           collisions:0 txqueuelen:100
           Interrupt:9 Base address:0x1400
 
+6. Switch Configuration
+=======================
 
-Frequently Asked Questions
-==========================
+	For this section, "switch" refers to whatever system the
+bonded devices are directly connected to (i.e., where the other end of
+the cable plugs into).  This may be an actual dedicated switch device,
+or it may be another regular system (e.g., another computer running
+Linux),
+
+	The active-backup, balance-tlb and balance-alb modes do not
+require any specific configuration of the switch.
+
+	The 802.3ad mode requires that the switch have the appropriate
+ports configured as an 802.3ad aggregation.  The precise method used
+to configure this varies from switch to switch, but, for example, a
+Cisco 3550 series switch requires that the appropriate ports first be
+grouped together in a single etherchannel instance, then that
+etherchannel is set to mode "lacp" to enable 802.3ad (instead of
+standard EtherChannel).
+
+	The balance-rr, balance-xor and broadcast modes generally
+require that the switch have the appropriate ports grouped together.
+The nomenclature for such a group differs between switches, it may be
+called an "etherchannel" (as in the Cisco example, above), a "trunk
+group" or some other similar variation.  For these modes, each switch
+will also have its own configuration options for the switch's transmit
+policy to the bond.  Typical choices include XOR of either the MAC or
+IP addresses.  The transmit policy of the two peers does not need to
+match.  For these three modes, the bonding mode really selects a
+transmit policy for an EtherChannel group; all three will interoperate
+with another EtherChannel group.
+
+
+7. 802.1q VLAN Support
+======================
+
+	It is possible to configure VLAN devices over a bond interface
+using the 8021q driver.  However, only packets coming from the 8021q
+driver and passing through bonding will be tagged by default.  Self
+generated packets, for example, bonding's learning packets or ARP
+packets generated by either ALB mode or the ARP monitor mechanism, are
+tagged internally by bonding itself.  As a result, bonding must
+"learn" the VLAN IDs configured above it, and use those IDs to tag
+self generated packets.
+
+	For reasons of simplicity, and to support the use of adapters
+that can do VLAN hardware acceleration offloding, the bonding
+interface declares itself as fully hardware offloaing capable, it gets
+the add_vid/kill_vid notifications to gather the necessary
+information, and it propagates those actions to the slaves.  In case
+of mixed adapter types, hardware accelerated tagged packets that
+should go through an adapter that is not offloading capable are
+"un-accelerated" by the bonding driver so the VLAN tag sits in the
+regular location.
+
+	VLAN interfaces *must* be added on top of a bonding interface
+only after enslaving at least one slave.  The bonding interface has a
+hardware address of 00:00:00:00:00:00 until the first slave is added.
+If the VLAN interface is created prior to the first enslavement, it
+would pick up the all-zeroes hardware address.  Once the first slave
+is attached to the bond, the bond device itself will pick up the
+slave's hardware address, which is then available for the VLAN device.
+
+	Also, be aware that a similar problem can occur if all slaves
+are released from a bond that still has one or more VLAN interfaces on
+top of it.  When a new slave is added, the bonding interface will
+obtain its hardware address from the first slave, which might not
+match the hardware address of the VLAN interfaces (which was
+ultimately copied from an earlier slave).
+
+	There are two methods to insure that the VLAN device operates
+with the correct hardware address if all slaves are removed from a
+bond interface:
+
+	1. Remove all VLAN interfaces then recreate them
+
+	2. Set the bonding interface's hardware address so that it
+matches the hardware address of the VLAN interfaces.
+
+	Note that changing a VLAN interface's HW address would set the
+underlying device -- i.e. the bonding interface -- to promiscouos
+mode, which might not be what you want.
 
-1.  Is it SMP safe?
-
-	Yes. The old 2.0.xx channel bonding patch was not SMP safe.
-	The new driver was designed to be SMP safe from the start.
 
-2.  What type of cards will work with it?
-
-	Any Ethernet type cards (you can even mix cards - a Intel
-	EtherExpress PRO/100 and a 3com 3c905b, for example).
-	You can even bond together Gigabit Ethernet cards!
+8. Link Monitoring
+==================
 
-3.  How many bonding devices can I have?
+	The bonding driver at present supports two schemes for
+monitoring a slave device's link state: the ARP monitor and the MII
+monitor.
+
+	At the present time, due to implementation restrictions in the
+bonding driver itself, it is not possible to enable both ARP and MII
+monitoring simultaneously.
+
+8.1 ARP Monitor Operation
+-------------------------
+
+	The ARP monitor operates as its name suggests: it sends ARP
+queries to one or more designated peer systems on the network, and
+uses the response as an indication that the link is operating.  This
+gives some assurance that traffic is actually flowing to and from one
+or more peers on the local network.
+
+	The ARP monitor relies on the device driver itself to verify
+that traffic is flowing.  In particular, the driver must keep up to
+date the last receive time, dev->last_rx, and transmit start time,
+dev->trans_start.  If these are not updated by the driver, then the
+ARP monitor will immediately fail any slaves using that driver, and
+those slaves will stay down.  If networking monitoring (tcpdump, etc)
+shows the ARP requests and replies on the network, then it may be that
+your device driver is not updating last_rx and trans_start.
 
-	There is no limit.
+8.2 Configuring Multiple ARP Targets
+------------------------------------
 
-4.  How many slaves can a bonding device have?
+	While ARP monitoring can be done with just one target, it can
+be useful in a High Availability setup to have several targets to
+monitor.  In the case of just one target, the target itself may go
+down or have a problem making it unresponsive to ARP requests.  Having
+an additional target (or several) increases the reliability of the ARP
+monitoring.
 
-	Limited by the number of network interfaces Linux supports and/or the
-	number of network cards you can place in your system.
+	Multiple ARP targets must be seperated by commas as follows:
 
-5.  What happens when a slave link dies?
+# example options for ARP monitoring with three targets
+alias bond0 bonding
+options bond0 arp_interval=60 arp_ip_target=192.168.0.1,192.168.0.3,192.168.0.9
 
-	If your ethernet cards support MII or ETHTOOL link status monitoring
-        and the MII monitoring has been enabled in the driver (see description
-        of module parameters), there will be no adverse consequences. This
-        release of the bonding driver knows how to get the MII information and
-	enables or disables its slaves according to their link status.
-	See section on High Availability for additional information.
-
-	For ethernet cards not supporting MII status, the arp_interval and
-        arp_ip_target parameters must be specified for bonding to work
-        correctly. If packets have not been sent or received during the
-        specified arp_interval duration, an ARP request is sent to the
-        targets to generate send and receive traffic. If after this
-        interval, either the successful send and/or receive count has not
-        incremented, the next slave in the sequence will become the active
-        slave.
-
-	If neither mii_monitor and arp_interval is configured, the bonding
-	driver will not handle this situation very well. The driver will
-	continue to send packets but some packets will be lost. Retransmits
-	will cause serious degradation of performance (in the case when one
-	of two slave links fails, 50% packets will be lost, which is a serious
-	problem for both TCP and UDP).
+	For just a single target the options would resemble:
 
-6.  Can bonding be used for High Availability?
+# example options for ARP monitoring with one target
+alias bond0 bonding
+options bond0 arp_interval=60 arp_ip_target=192.168.0.100
 
-        Yes, if you use MII monitoring and ALL your cards support MII link
-        status reporting. See section on High Availability for more
-        information.
 
-7.  Which switches/systems does it work with?
+8.3 MII Monitor Operation
+-------------------------
 
-	In round-robin and XOR mode, it works with systems that support
-	trunking:
+	The MII monitor monitors only the carrier state of the local
+network interface.  It accomplishes this in one of three ways: by
+depending upon the device driver to maintain its carrier state, by
+querying the device's MII registers, or by making an ethtool query to
+the device.
+
+	If the use_carrier module parameter is 1 (the default value),
+then the MII monitor will rely on the driver for carrier state
+information (via the netif_carrier subsystem).  As explained in the
+use_carrier parameter information, above, if the MII monitor fails to
+detect carrier loss on the device (e.g., when the cable is physically
+disconnected), it may be that the driver does not support
+netif_carrier.
+
+	If use_carrier is 0, then the MII monitor will first query the
+device's (via ioctl) MII registers and check the link state.  If that
+request fails (not just that it returns carrier down), then the MII
+monitor will make an ethtool ETHOOL_GLINK request to attempt to obtain
+the same information.  If both methods fail (i.e., the driver either
+does not support or had some error in processing both the MII register
+and ethtool requests), then the MII monitor will assume the link is
+up.
 
-	* Many Cisco switches and routers (look for EtherChannel support).
-	* SunTrunking software.
-	* Alteon AceDirector switches / WebOS (use Trunks).
-	* BayStack Switches (trunks must be explicitly configured). Stackable
-	  models (450) can define trunks between ports on different physical
-	  units.
-	* Linux bonding, of course !
-
-	In 802.3ad mode, it works with with systems that support IEEE 802.3ad
-	Dynamic Link Aggregation:
-
-	* Extreme networks Summit 7i (look for link-aggregation).
-	* Many Cisco switches and routers (look for LACP support; this may
-	  require an upgrade to your IOS software; LACP support was added
-	  by Cisco in late 2002).
-	* Foundry Big Iron 4000
+9. Potential Sources of Trouble
+===============================
 
-        In active-backup, balance-tlb and balance-alb modes, it should work
-        with any Layer-II switch.
+9.1 Adventures in Routing
+-------------------------
 
+	When bonding is configured, it is important that the slave
+devices not have routes that supercede routes of the master (or,
+generally, not have routes at all).  For example, suppose the bonding
+device bond0 has two slaves, eth0 and eth1, and the routing table is
+as follows:
 
-8.  Where does a bonding device get its MAC address from?
+Kernel IP routing table
+Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
+10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 eth0
+10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 eth1
+10.0.0.0        0.0.0.0         255.255.0.0     U        40 0          0 bond0
+127.0.0.0       0.0.0.0         255.0.0.0       U        40 0          0 lo
 
-	If not explicitly configured with ifconfig, the MAC address of the
-	bonding device is taken from its first slave device. This MAC address
-	is then passed to all following slaves and remains persistent (even if
-	the the first slave is removed) until the bonding device is brought
-	down or reconfigured.
+	This routing configuration will likely still update the
+receive/transmit times in the driver (needed by the ARP monitor), but
+may bypass the bonding driver (because outgoing traffic to, in this
+case, another host on network 10 would use eth0 or eth1 before bond0).
+
+	The ARP monitor (and ARP itself) may become confused by this
+configuration, because ARP requests (generated by the ARP monitor)
+will be sent on one interface (bond0), but the corresponding reply
+will arrive on a different interface (eth0).  This reply looks to ARP
+as an unsolicited ARP reply (because ARP matches replies on an
+interface basis), and is discarded.  The MII monitor is not affected
+by the state of the routing table.
+
+	The solution here is simply to insure that slaves do not have
+routes of their own, and if for some reason they must, those routes do
+not supercede routes of their master.  This should generally be the
+case, but unusual configurations or errant manual or automatic static
+route additions may cause trouble.
 
-	If you wish to change the MAC address, you can set it with ifconfig:
+9.2 Ethernet Device Renaming
+----------------------------
 
-	  # ifconfig bond0 hw ether 00:11:22:33:44:55
+	On systems with network configuration scripts that do not
+associate physical devices directly with network interface names (so
+that the same physical device always has the same "ethX" name), it may
+be necessary to add some special logic to either /etc/modules.conf or
+/etc/modprobe.conf (depending upon which is installed on the system).
 
-	The MAC address can be also changed by bringing down/up the device
-	and then changing its slaves (or their order):
+	For example, given a modules.conf containing the following:
 
-	  # ifconfig bond0 down ; modprobe -r bonding
-	  # ifconfig bond0 .... up
-	  # ifenslave bond0 eth...
+alias bond0 bonding
+options bond0 mode=some-mode miimon=50
+alias eth0 tg3
+alias eth1 tg3
+alias eth2 e1000
+alias eth3 e1000
+
+	If neither eth0 and eth1 are slaves to bond0, then when the
+bond0 interface comes up, the devices may end up reordered.  This
+happens because bonding is loaded first, then its slave device's
+drivers are loaded next.  Since no other drivers have been loaded,
+when the e1000 driver loads, it will receive eth0 and eth1 for its
+devices, but the bonding configuration tries to enslave eth2 and eth3
+(which may later be assigned to the tg3 devices).
+
+	Adding the following:
+
+add above bonding e1000 tg3
+
+	causes modprobe to load e1000 then tg3, in that order, when
+bonding is loaded.  This command is fully documented in the
+modules.conf manual page.
+
+	On systems utilizing modprobe.conf (or modprobe.conf.local),
+an equivalent problem can occur.  In this case, the following can be
+added to modprobe.conf (or modprobe.conf.local, as appropriate), as
+follows (all on one line; it has been split here for clarity):
+
+install bonding /sbin/modprobe tg3; /sbin/modprobe e1000;
+	/sbin/modprobe --ignore-install bonding
+
+	This will, when loading the bonding module, rather than
+performing the normal action, instead execute the provided command.
+This command loads the device drivers in the order needed, then calls
+modprobe with --ingore-install to cause the normal action to then take
+place.  Full documentation on this can be found in the modprobe.conf
+and modprobe manual pages.
+
+9.3. Painfully Slow Or No Failed Link Detection By Miimon
+---------------------------------------------------------
+
+	By default, bonding enables the use_carrier option, which
+instructs bonding to trust the driver to maintain carrier state.
+
+	As discussed in the options section, above, some drivers do
+not support the netif_carrier_on/_off link state tracking system.
+With use_carrier enabled, bonding will always see these links as up,
+regardless of their actual state.
+
+	Additionally, other drivers do support netif_carrier, but do
+not maintain it in real time, e.g., only polling the link state at
+some fixed interval.  In this case, miimon will detect failures, but
+only after some long period of time has expired.  If it appears that
+miimon is very slow in detecting link failures, try specifying
+use_carrier=0 to see if that improves the failure detection time.  If
+it does, then it may be that the driver checks the carrier state at a
+fixed interval, but does not cache the MII register values (so the
+use_carrier=0 method of querying the registers directly works).  If
+use_carrier=0 does not improve the failover, then the driver may cache
+the registers, or the problem may be elsewhere.
+
+	Also, remember that miimon only checks for the device's
+carrier state.  It has no way to determine the state of devices on or
+beyond other ports of a switch, or if a switch is refusing to pass
+traffic while still maintaining carrier on.
+
+10. SNMP agents
+===============
+
+	If running SNMP agents, the bonding driver should be loaded
+before any network drivers participating in a bond.  This requirement
+is due to the the interface index (ipAdEntIfIndex) being associated to
+the first interface found with a given IP address.  That is, there is
+only one ipAdEntIfIndex for each IP address.  For example, if eth0 and
+eth1 are slaves of bond0 and the driver for eth0 is loaded before the
+bonding driver, the interface for the IP address will be associated
+with the eth0 interface.  This configuration is shown below, the IP
+address 192.168.1.1 has an interface index of 2 which indexes to eth0
+in the ifDescr table (ifDescr.2).
 
-	This method will automatically take the address from the next slave
-	that will be added.
+     interfaces.ifTable.ifEntry.ifDescr.1 = lo
+     interfaces.ifTable.ifEntry.ifDescr.2 = eth0
+     interfaces.ifTable.ifEntry.ifDescr.3 = eth1
+     interfaces.ifTable.ifEntry.ifDescr.4 = eth2
+     interfaces.ifTable.ifEntry.ifDescr.5 = eth3
+     interfaces.ifTable.ifEntry.ifDescr.6 = bond0
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 5
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 4
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1
 
-	To restore your slaves' MAC addresses, you need to detach them
-	from the bond (`ifenslave -d bond0 eth0'). The bonding driver will then
-	restore the MAC addresses that the slaves had before they were enslaved.
+	This problem is avoided by loading the bonding driver before
+any network drivers participating in a bond.  Below is an example of
+loading the bonding driver first, the IP address 192.168.1.1 is
+correctly associated with ifDescr.2.
 
-9.  Which transmit polices can be used?
+     interfaces.ifTable.ifEntry.ifDescr.1 = lo
+     interfaces.ifTable.ifEntry.ifDescr.2 = bond0
+     interfaces.ifTable.ifEntry.ifDescr.3 = eth0
+     interfaces.ifTable.ifEntry.ifDescr.4 = eth1
+     interfaces.ifTable.ifEntry.ifDescr.5 = eth2
+     interfaces.ifTable.ifEntry.ifDescr.6 = eth3
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 6
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 5
+     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1
 
-	Round-robin, based on the order of enslaving, the output device
-	is selected base on the next available slave. Regardless of
-	the source and/or destination of the packet.
+	While some distributions may not report the interface name in
+ifDescr, the association between the IP address and IfIndex remains
+and SNMP functions such as Interface_Scan_Next will report that
+association.
 
-	Active-backup policy that ensures that one and only one device will
-	transmit at any given moment. Active-backup policy is useful for
-	implementing high availability solutions using two hubs (see
-	section on High Availability).
+11. Promiscuous mode
+====================
 
-	XOR, based on (src hw addr XOR dst hw addr) % slave count. This
-	policy selects the same slave for each destination hw address.
+	When running network monitoring tools, e.g., tcpdump, it is
+common to enable promiscuous mode on the device, so that all traffic
+is seen (instead of seeing only traffic destined for the local host).
+The bonding driver handles promiscuous mode changes to the bonding
+master device (e.g., bond0), and propogates the setting to the slave
+devices.
+
+	For the balance-rr, balance-xor, broadcast, and 802.3ad modes,
+the promiscuous mode setting is propogated to all slaves.
+
+	For the active-backup, balance-tlb and balance-alb modes, the
+promiscuous mode setting is propogated only to the active slave.
+
+	For balance-tlb mode, the active slave is the slave currently
+receiving inbound traffic.
+
+	For balance-alb mode, the active slave is the slave used as a
+"primary."  This slave is used for mode-specific control traffic, for
+sending to peers that are unassigned or if the load is unbalanced.
+
+	For the active-backup, balance-tlb and balance-alb modes, when
+the active slave changes (e.g., due to a link failure), the
+promiscuous setting will be propogated to the new active slave.
+
+12. High Availability Information
+=================================
+
+	High Availability refers to configurations that provide
+maximum network availability by having redundant or backup devices,
+links and switches between the host and the rest of the world.
+
+	There are currently two basic methods for configuring to
+maximize availability. They are dependent on the network topology and
+the primary goal of the configuration, but in general, a configuration
+can be optimized for maximum available bandwidth, or for maximum
+network availability.
+
+12.1 High Availability in a Single Switch Topology
+--------------------------------------------------
+
+	If two hosts (or a host and a switch) are directly connected
+via multiple physical links, then there is no network availability
+penalty for optimizing for maximum bandwidth: there is only one switch
+(or peer), so if it fails, you have no alternative access to fail over
+to.
 
-	Broadcast policy transmits everything on all slave interfaces.
+Example 1 : host to switch (or other host)
 
-	802.3ad, based on XOR but distributes traffic among all interfaces
-	in the active aggregator.
+          +----------+                          +----------+
+          |          |eth0                  eth0|  switch  |
+          | Host A   +--------------------------+    or    |
+          |          +--------------------------+  other   |
+          |          |eth1                  eth1|  host    |
+          +----------+                          +----------+
 
-	Transmit load balancing (balance-tlb) balances the traffic
-	according to the current load on each slave. The balancing is
-	clients based and the least loaded slave is selected for each new
-	client. The load of each slave is calculated relative to its speed
-	and enables load balancing in mixed speed teams.
 
-	Adaptive load balancing (balance-alb) uses the Transmit load
-	balancing for the transmit load. The receive load is balanced only
-	among the group of highest speed active slaves in the bond. The
-	load is distributed with round-robin i.e. next available slave in
-	the high speed group of active slaves.
+12.1.1 Bonding Mode Selection for single switch topology
+--------------------------------------------------------
 
-High Availability
-=================
+	This configuration is the easiest to set up and to understand,
+although you will have to decide which bonding mode best suits your
+needs.  The tradeoffs for each mode are detailed below:
+
+balance-rr: This mode is the only mode that will permit a single
+	TCP/IP connection to stripe traffic across multiple
+	interfaces. It is therefore the only mode that will allow a
+	single TCP/IP stream to utilize more than one interface's
+	worth of throughput.  This comes at a cost, however: the
+	striping often results in peer systems receiving packets out
+	of order, causing TCP/IP's congestion control system to kick
+	in, often by retransmitting segments.
+
+	It is possible to adjust TCP/IP's congestion limits by
+	altering the net.ipv4.tcp_reordering sysctl parameter.  The
+	usual default value is 3, and the maximum useful value is 127.
+	For a four interface balance-rr bond, expect that a single
+	TCP/IP stream will utilize no more than approximately 2.3
+	interface's worth of throughput, even after adjusting
+	tcp_reordering.
+
+	If you are utilizing protocols other than TCP/IP, UDP for
+	example, and your application can tolerate out of order
+	delivery, then this mode can allow for single stream datagram
+	performance that scales near linearly as interfaces are added
+	to the bond.
+
+	This mode requires the switch to have the appropriate ports
+	configured for "etherchannel" or "trunking."
+
+active-backup: There is not much advantage in this network topology to
+	the active-backup mode, as the inactive backup devices are all
+	connected to the same peer as the primary.  In this case, a
+	load balancing mode (with link monitoring) will provide the
+	same level of network availability, but with increased
+	available bandwidth.  On the plus side, it does not require
+	any configuration of the switch.
+
+balance-xor: This mode will limit traffic such that packets destined
+	for specific peers will always be sent over the same
+	interface.  Since the destination is determined by the MAC
+	addresses involved, this may be desirable if you have a large
+	network with many hosts.  It is likely to be suboptimal if all
+	your traffic is passed through a single router, however.  As
+	with balance-rr, the switch ports need to be configured for
+	"etherchannel" or "trunking."
+
+broadcast: Like active-backup, there is not much advantage to this
+	mode in this type of network topology.
+
+802.3ad: This mode can be a good choice for this type of network
+	topology.  The 802.3ad mode is an IEEE standard, so all peers
+	that implement 802.3ad should interoperate well.  The 802.3ad
+	protocol includes automatic configuration of the aggregates,
+	so minimal manual configuration of the switch is needed
+	(typically only to designate that some set of devices is
+	usable for 802.3ad).  The 802.3ad standard also mandates that
+	frames be delivered in order (within certain limits), so in
+	general single connections will not see misordering of
+	packets.  The 802.3ad mode does have some drawbacks: the
+	standard mandates that all devices in the aggregate operate at
+	the same speed and duplex.  Also, as with all bonding load
+	balance modes other than balance-rr, no single connection will
+	be able to utilize more than a single interface's worth of
+	bandwidth.  Additionally, the linux bonding 802.3ad
+	implementation distributes traffic by peer (using an XOR of
+	MAC addresses), so in general all traffic to a particular
+	destination will use the same interface.  Finally, the 802.3ad
+	mode mandates the use of the MII monitor, therefore, the ARP
+	monitor is not available in this mode.
+
+balance-tlb: This mode is also a good choice for this type of
+	topology.  It has no special switch configuration
+	requirements, and balances outgoing traffic by peer, in a
+	vaguely intelligent manner (not a simple XOR as in balance-xor
+	or 802.3ad mode), so that unlucky MAC addresses will not all
+	"bunch up" on a single interface.  Interfaces may be of
+	differing speeds.  On the down side, in this mode all incoming
+	traffic arrives over a single interface, this mode requires
+	certain ethtool support in the network device driver of the
+	slave interfaces, and the ARP monitor is not available.
+
+balance-alb: This mode is everything that balance-tlb is, and more. It
+	has all of the features (and restrictions) of balance-tlb, and
+	will also balance incoming traffic from peers (as described in
+	the Bonding Module Options section, above).  The only extra
+	down side to this mode is that the network device driver must
+	support changing the hardware address while the device is
+	open.
+
+12.1.2 Link Monitoring for Single Switch Topology
+-------------------------------------------------
+
+	The choice of link monitoring may largely depend upon which
+mode you choose to use.  The more advanced load balancing modes do not
+support the use of the ARP monitor, and are thus restricted to using
+the MII monitor (which does not provide as high a level of assurance
+as the ARP monitor).
+
+
+12.2 High Availability in a Multiple Switch Topology
+----------------------------------------------------
+
+	With multiple switches, the configuration of bonding and the
+network changes dramatically.  In multiple switch topologies, there is
+a tradeoff between network availability and usable bandwidth.
 
-To implement high availability using the bonding driver, the driver needs to be
-compiled as a module, because currently it is the only way to pass parameters
-to the driver. This may change in the future.
-
-High availability is achieved by using MII or ETHTOOL status reporting. You
-need to verify that all your interfaces support MII or ETHTOOL link status
-reporting.  On Linux kernel 2.2.17, all the 100 Mbps capable drivers and
-yellowfin gigabit driver support MII. To determine if ETHTOOL link reporting
-is available for interface eth0, type "ethtool eth0" and the "Link detected:"
-line should contain the correct link status. If your system has an interface
-that does not support MII or ETHTOOL status reporting, a failure of its link
-will not be detected! A message indicating MII and ETHTOOL is not supported by
-a network driver is logged when the bonding driver is loaded with a non-zero
-miimon value.
-
-The bonding driver can regularly check all its slaves links using the ETHTOOL
-IOCTL (ETHTOOL_GLINK command) or by checking the MII status registers. The
-check interval is specified by the module argument "miimon" (MII monitoring).
-It takes an integer that represents the checking time in milliseconds. It
-should not come to close to (1000/HZ) (10 milli-seconds on i386) because it
-may then reduce the system interactivity. A value of 100 seems to be a good
-starting point. It means that a dead link will be detected at most 100
-milli-seconds after it goes down.
-
-Example:
-
-   # modprobe bonding miimon=100
-
-Or, put the following line in /etc/modprobe.conf:
-
-   options bond0 miimon=100
-
-There are currently two policies for high availability. They are dependent on
-whether:
-
-   a) hosts are connected to a single host or switch that support trunking
-
-   b) hosts are connected to several different switches or a single switch that
-      does not support trunking
-
-
-1) High Availability on a single switch or host - load balancing
-----------------------------------------------------------------
-It is the easiest to set up and to understand. Simply configure the
-remote equipment (host or switch) to aggregate traffic over several
-ports (Trunk, EtherChannel, etc.) and configure the bonding interfaces.
-If the module has been loaded with the proper MII option, it will work
-automatically. You can then try to remove and restore different links
-and see in your logs what the driver detects. When testing, you may
-encounter problems on some buggy switches that disable the trunk for a
-long time if all ports in a trunk go down. This is not Linux, but really
-the switch (reboot it to ensure).
+	Below is a sample network, configured to maximize the
+availability of the network:
 
-Example 1 : host to host at twice the speed
+                |                                     |
+                |port3                           port3|
+          +-----+----+                          +-----+----+
+          |          |port2       ISL      port2|          |
+          | switch A +--------------------------+ switch B |
+          |          |                          |          |
+          +-----+----+                          +-----++---+
+                |port1                           port1|
+                |             +-------+               |
+                +-------------+ host1 +---------------+
+                         eth0 +-------+ eth1
 
-          +----------+                          +----------+
-          |          |eth0                  eth0|          |
-          | Host A   +--------------------------+  Host B  |
-          |          +--------------------------+          |
-          |          |eth1                  eth1|          |
-          +----------+                          +----------+
+	In this configuration, there is a link between the two
+switches (ISL, or inter switch link), and multiple ports connecting to
+the outside world ("port3" on each switch).  There is no technical
+reason that this could not be extended to a third switch.
+
+12.2.1 Bonding Mode Selection for Multiple Switch Topology
+----------------------------------------------------------
+
+	In a topology such as this, the active-backup and broadcast
+modes are the only useful bonding modes; the other modes require all
+links to terminate on the same peer for them to behave rationally.
+
+active-backup: This is generally the preferred mode, particularly if
+	the switches have an ISL and play together well.  If the
+	network configuration is such that one switch is specifically
+	a backup switch (e.g., has lower capacity, higher cost, etc),
+	then the primary option can be used to insure that the
+	preferred link is always used when it is available.
+
+broadcast: This mode is really a special purpose mode, and is suitable
+	only for very specific needs.  For example, if the two
+	switches are not connected (no ISL), and the networks beyond
+	them are totally independant.  In this case, if it is
+	necessary for some specific one-way traffic to reach both
+	independent networks, then the broadcast mode may be suitable.
+
+12.2.2 Link Monitoring Selection for Multiple Switch Topology
+-------------------------------------------------------------
+
+	The choice of link monitoring ultimately depends upon your
+switch.  If the switch can reliably fail ports in response to other
+failures, then either the MII or ARP monitors should work.  For
+example, in the above example, if the "port3" link fails at the remote
+end, the MII monitor has no direct means to detect this.  The ARP
+monitor could be configured with a target at the remote end of port3,
+thus detecting that failure without switch support.
+
+	In general, however, in a multiple switch topology, the ARP
+monitor can provide a higher level of reliability in detecting link
+failures.  Additionally, it should be configured with multiple targets
+(at least one for each switch in the network).  This will insure that,
+regardless of which switch is active, the ARP monitor has a suitable
+target to query.
+
+
+12.3 Switch Behavior Issues for High Availability
+-------------------------------------------------
+
+	You may encounter issues with the timing of link up and down
+reporting by the switch.
+
+	First, when a link comes up, some switches may indicate that
+the link is up (carrier available), but not pass traffic over the
+interface for some period of time.  This delay is typically due to
+some type of autonegotiation or routing protocol, but may also occur
+during switch initialization (e.g., during recovery after a switch
+failure).  If you find this to be a problem, specify an appropriate
+value to the updelay bonding module option to delay the use of the
+relevant interface(s).
+
+	Second, some switches may "bounce" the link state one or more
+times while a link is changing state.  This occurs most commonly while
+the switch is initializing.  Again, an appropriate updelay value may
+help, but note that if all links are down, then updelay is ignored
+when any link becomes active (the slave closest to completing its
+updelay is chosen).
+
+	Note that when a bonding interface has no active links, the
+driver will immediately reuse the first link that goes up, even if
+updelay parameter was specified.  If there are slave interfaces
+waiting for the updelay timeout to expire, the interface that first
+went into that state will be immediately reused.  This reduces down
+time of the network if the value of updelay has been overestimated.
+
+	In addition to the concerns about switch timings, if your
+switches take a long time to go into backup mode, it may be desirable
+to not activate a backup interface immediately after a link goes down.
+Failover may be delayed via the downdelay bonding module option.
+
+13. Hardware Specific Considerations
+====================================
+
+	This section contains additional information for configuring
+bonding on specific hardware platforms, or for interfacing bonding
+with particular switches or other devices.
+
+13.1 IBM BladeCenter
+--------------------
+
+	This applies to the JS20 and similar systems.
+
+	On the JS20 blades, the bonding driver supports only
+balance-rr, active-backup, balance-tlb and balance-alb modes.  This is
+largely due to the network topology inside the BladeCenter, detailed
+below.
+
+JS20 network adapter information
+--------------------------------
+
+	All JS20s come with two Broadcom Gigabit Ethernet ports
+integrated on the planar.  In the BladeCenter chassis, the eth0 port
+of all JS20 blades is hard wired to I/O Module #1; similarly, all eth1
+ports are wired to I/O Module #2.  An add-on Broadcom daughter card
+can be installed on a JS20 to provide two more Gigabit Ethernet ports.
+These ports, eth2 and eth3, are wired to I/O Modules 3 and 4,
+respectively.
+
+	Each I/O Module may contain either a switch or a passthrough
+module (which allows ports to be directly connected to an external
+switch).  Some bonding modes require a specific BladeCenter internal
+network topology in order to function; these are detailed below.
 
-  On each host :
-     # modprobe bonding miimon=100
-     # ifconfig bond0 addr
-     # ifenslave bond0 eth0 eth1
+	Additional BladeCenter-specific networking information can be
+found in two IBM Redbooks (www.ibm.com/redbooks):
 
-Example 2 : host to switch at twice the speed
+"IBM eServer BladeCenter Networking Options"
+"IBM eServer BladeCenter Layer 2-7 Network Switching"
 
-          +----------+                          +----------+
-          |          |eth0                 port1|          |
-          | Host A   +--------------------------+  switch  |
-          |          +--------------------------+          |
-          |          |eth1                 port2|          |
-          +----------+                          +----------+
+BladeCenter networking configuration
+------------------------------------
 
-  On host A :                             On the switch :
-     # modprobe bonding miimon=100           # set up a trunk on port1
-     # ifconfig bond0 addr                     and port2
-     # ifenslave bond0 eth0 eth1
+	Because a BladeCenter can be configured in a very large number
+of ways, this discussion will be confined to describing basic
+configurations.
+
+	Normally, Ethernet Switch Modules (ESM) are used in I/O
+modules 1 and 2.  In this configuration, the eth0 and eth1 ports of a
+JS20 will be connected to different internal switches (in the
+respective I/O modules).
+
+	An optical passthru module (OPM) connects the I/O module
+directly to an external switch.  By using OPMs in I/O module #1 and
+#2, the eth0 and eth1 interfaces of a JS20 can be redirected to the
+outside world and connected to a common external switch.
+
+	Depending upon the mix of ESM and OPM modules, the network
+will appear to bonding as either a single switch topology (all OPM
+modules) or as a multiple switch topology (one or more ESM modules,
+zero or more OPM modules).  It is also possible to connect ESM modules
+together, resulting in a configuration much like the example in "High
+Availability in a multiple switch topology."
+
+Requirements for specifc modes
+------------------------------
+
+	The balance-rr mode requires the use of OPM modules for
+devices in the bond, all connected to an common external switch.  That
+switch must be configured for "etherchannel" or "trunking" on the
+appropriate ports, as is usual for balance-rr.
+
+	The balance-alb and balance-tlb modes will function with
+either switch modules or passthrough modules (or a mix).  The only
+specific requirement for these modes is that all network interfaces
+must be able to reach all destinations for traffic sent over the
+bonding device (i.e., the network must converge at some point outside
+the BladeCenter).
+
+	The active-backup mode has no additional requirements.
+
+Link monitoring issues
+----------------------
+
+	When an Ethernet Switch Module is in place, only the ARP
+monitor will reliably detect link loss to an external switch.  This is
+nothing unusual, but examination of the BladeCenter cabinet would
+suggest that the "external" network ports are the ethernet ports for
+the system, when it fact there is a switch between these "external"
+ports and the devices on the JS20 system itself.  The MII monitor is
+only able to detect link failures between the ESM and the JS20 system.
+
+	When a passthrough module is in place, the MII monitor does
+detect failures to the "external" port, which is then directly
+connected to the JS20 system.
+
+Other concerns
+--------------
+
+	The Serial Over LAN link is established over the primary
+ethernet (eth0) only, therefore, any loss of link to eth0 will result
+in losing your SoL connection.  It will not fail over with other
+network traffic.
+
+	It may be desirable to disable spanning tree on the switch
+(either the internal Ethernet Switch Module, or an external switch) to
+avoid fail-over delays issues when using bonding.
+
+	
+14. Frequently Asked Questions
+==============================
 
+1.  Is it SMP safe?
 
-2) High Availability on two or more switches (or a single switch without
-   trunking support)
----------------------------------------------------------------------------
-This mode is more problematic because it relies on the fact that there
-are multiple ports and the host's MAC address should be visible on one
-port only to avoid confusing the switches.
+	Yes. The old 2.0.xx channel bonding patch was not SMP safe.
+The new driver was designed to be SMP safe from the start.
 
-If you need to know which interface is the active one, and which ones are
-backup, use ifconfig. All backup interfaces have the NOARP flag set.
+2.  What type of cards will work with it?
 
-To use this mode, pass "mode=1" to the module at load time :
+	Any Ethernet type cards (you can even mix cards - a Intel
+EtherExpress PRO/100 and a 3com 3c905b, for example).  They need not
+be of the same speed.
 
-    # modprobe bonding miimon=100 mode=active-backup
+3.  How many bonding devices can I have?
 
-	or:
+	There is no limit.
 
-    # modprobe bonding miimon=100 mode=1
+4.  How many slaves can a bonding device have?
 
-Or, put in your /etc/modprobe.conf :
+	This is limited only by the number of network interfaces Linux
+supports and/or the number of network cards you can place in your
+system.
 
-    options bond0 miimon=100 mode=active-backup
+5.  What happens when a slave link dies?
 
-Example 1: Using multiple host and multiple switches to build a "no single
-point of failure" solution.
+	If link monitoring is enabled, then the failing device will be
+disabled.  The active-backup mode will fail over to a backup link, and
+other modes will ignore the failed link.  The link will continue to be
+monitored, and should it recover, it will rejoin the bond (in whatever
+manner is appropriate for the mode). See the section on High
+Availability for additional information.
+	
+	Link monitoring can be enabled via either the miimon or
+arp_interval paramters (described in the module paramters section,
+above).  In general, miimon monitors the carrier state as sensed by
+the underlying network device, and the arp monitor (arp_interval)
+monitors connectivity to another host on the local network.
+
+	If no link monitoring is configured, the bonding driver will
+be unable to detect link failures, and will assume that all links are
+always available.  This will likely result in lost packets, and a
+resulting degredation of performance.  The precise performance loss
+depends upon the bonding mode and network configuration.
 
+6.  Can bonding be used for High Availability?
 
-                |                                     |
-                |port3                           port3|
-          +-----+----+                          +-----+----+
-          |          |port7       ISL      port7|          |
-          | switch A +--------------------------+ switch B |
-          |          +--------------------------+          |
-          |          |port8                port8|          |
-          +----++----+                          +-----++---+
-          port2||port1                           port1||port2
-               ||             +-------+               ||
-               |+-------------+ host1 +---------------+|
-               |         eth0 +-------+ eth1           |
-               |                                       |
-               |              +-------+                |
-               +--------------+ host2 +----------------+
-                         eth0 +-------+ eth1
+	Yes.  See the section on High Availability for details.
 
-In this configuration, there is an ISL - Inter Switch Link (could be a trunk),
-several servers (host1, host2 ...) attached to both switches each, and one or
-more ports to the outside world (port3...). One and only one slave on each host
-is active at a time, while all links are still monitored (the system can
-detect a failure of active and backup links).
-
-Each time a host changes its active interface, it sticks to the new one until
-it goes down. In this example, the hosts are negligibly affected by the
-expiration time of the switches' forwarding tables.
-
-If host1 and host2 have the same functionality and are used in load balancing
-by another external mechanism, it is good to have host1's active interface
-connected to one switch and host2's to the other. Such system will survive
-a failure of a single host, cable, or switch. The worst thing that may happen
-in the case of a switch failure is that half of the hosts will be temporarily
-unreachable until the other switch expires its tables.
+7.  Which switches/systems does it work with?
 
-Example 2: Using multiple ethernet cards connected to a switch to configure
-           NIC failover (switch is not required to support trunking).
+	The full answer to this depends upon the desired mode.
 
+	In the basic balance modes (balance-rr and balance-xor), it
+works with any system that supports etherchannel (also called
+trunking).  Most managed switches currently available have such
+support, and many unmananged switches as well.
+
+	The advanced balance modes (balance-tlb and balance-alb) do
+not have special switch requirements, but do need device drivers that
+support specific features (described in the appropriate section under
+module paramters, above).
+
+	In 802.3ad mode, it works with with systems that support IEEE
+802.3ad Dynamic Link Aggregation.  Most managed and many unmanaged
+switches currently available support 802.3ad.
 
-          +----------+                          +----------+
-          |          |eth0                 port1|          |
-          | Host A   +--------------------------+  switch  |
-          |          +--------------------------+          |
-          |          |eth1                 port2|          |
-          +----------+                          +----------+
+        The active-backup mode should work with any Layer-II switch.
 
-  On host A :                                 On the switch :
-     # modprobe bonding miimon=100 mode=1     # (optional) minimize the time
-     # ifconfig bond0 addr                    # for table expiration
-     # ifenslave bond0 eth0 eth1
+8.  Where does a bonding device get its MAC address from?
 
-Each time the host changes its active interface, it sticks to the new one until
-it goes down. In this example, the host is strongly affected by the expiration
-time of the switch forwarding table.
+	If not explicitly configured with ifconfig, the MAC address of
+the bonding device is taken from its first slave device. This MAC
+address is then passed to all following slaves and remains persistent
+(even if the the first slave is removed) until the bonding device is
+brought down or reconfigured.
+
+	If you wish to change the MAC address, you can set it with
+ifconfig:
+
+# ifconfig bond0 hw ether 00:11:22:33:44:55
+
+	The MAC address can be also changed by bringing down/up the
+device and then changing its slaves (or their order):
+
+# ifconfig bond0 down ; modprobe -r bonding
+# ifconfig bond0 .... up
+# ifenslave bond0 eth...
 
+	This method will automatically take the address from the next
+slave that is added.
 
-3) Adapting to your switches' timing
-------------------------------------
-If your switches take a long time to go into backup mode, it may be
-desirable not to activate a backup interface immediately after a link goes
-down. It is possible to delay the moment at which a link will be
-completely disabled by passing the module parameter "downdelay" (in
-milliseconds, must be a multiple of miimon).
-
-When a switch reboots, it is possible that its ports report "link up" status
-before they become usable. This could fool a bond device by causing it to
-use some ports that are not ready yet. It is possible to delay the moment at
-which an active link will be reused by passing the module parameter "updelay"
-(in milliseconds, must be a multiple of miimon).
-
-A similar situation can occur when a host re-negotiates a lost link with the
-switch (a case of cable replacement).
-
-A special case is when a bonding interface has lost all slave links. Then the
-driver will immediately reuse the first link that goes up, even if updelay
-parameter was specified. (If there are slave interfaces in the "updelay" state,
-the interface that first went into that state will be immediately reused.) This
-allows to reduce down-time if the value of updelay has been overestimated.
-
-Examples :
-
-    # modprobe bonding miimon=100 mode=1 downdelay=2000 updelay=5000
-    # modprobe bonding miimon=100 mode=balance-rr downdelay=0 updelay=5000
-
-
-Promiscuous Sniffing notes
-==========================
-
-If you wish to bond channels together for a network sniffing
-application --- you wish to run tcpdump, or ethereal, or an IDS like
-snort, with its input aggregated from multiple interfaces using the
-bonding driver --- then you need to handle the Promiscuous interface
-setting by hand. Specifically, when you "ifconfing bond0 up" you
-must add the promisc flag there; it will be propagated down to the
-slave interfaces at ifenslave time; a full example might look like:
-
-   ifconfig bond0 promisc up
-   for if in eth1 eth2 ...;do
-       ifconfig $if up
-       ifenslave bond0 $if
-   done
-   snort ... -i bond0 ...
-
-Ifenslave also wants to propagate addresses from interface to
-interface, appropriately for its design functions in HA and channel
-capacity aggregating; but it works fine for unnumbered interfaces;
-just ignore all the warnings it emits.
+	To restore your slaves' MAC addresses, you need to detach them
+from the bond (`ifenslave -d bond0 eth0'). The bonding driver will
+then restore the MAC addresses that the slaves had before they were
+enslaved.
 
+15. Resources and Links
+=======================
 
-8021q VLAN support
-==================
+The latest version of the bonding driver can be found in the latest
+version of the linux kernel, found on http://kernel.org
 
-It is possible to configure VLAN devices over a bond interface using the 8021q
-driver. However, only packets coming from the 8021q driver and passing through
-bonding will be tagged by default. Self generated packets, like bonding's
-learning packets or ARP packets generated by either ALB mode or the ARP
-monitor mechanism, are tagged internally by bonding itself. As a result,
-bonding has to "learn" what VLAN IDs are configured on top of it, and it uses
-those IDs to tag self generated packets.
-
-For simplicity reasons, and to support the use of adapters that can do VLAN
-hardware acceleration offloding, the bonding interface declares itself as
-fully hardware offloaing capable, it gets the add_vid/kill_vid notifications
-to gather the necessary information, and it propagates those actions to the
-slaves.
-In case of mixed adapter types, hardware accelerated tagged packets that should
-go through an adapter that is not offloading capable are "un-accelerated" by the
-bonding driver so the VLAN tag sits in the regular location.
-
-VLAN interfaces *must* be added on top of a bonding interface only after
-enslaving at least one slave. This is because until the first slave is added the
-bonding interface has a HW address of 00:00:00:00:00:00, which will be copied by
-the VLAN interface when it is created.
-
-Notice that a problem would occur if all slaves are released from a bond that
-still has VLAN interfaces on top of it. When later coming to add new slaves, the
-bonding interface would get a HW address from the first slave, which might not
-match that of the VLAN interfaces. It is recommended that either all VLANs are
-removed and then re-added, or to manually set the bonding interface's HW
-address so it matches the VLAN's. (Note: changing a VLAN interface's HW address
-would set the underlying device -- i.e. the bonding interface -- to promiscouos
-mode, which might not be what you want).
-
-
-Limitations
-===========
-The main limitations are :
-  - only the link status is monitored. If the switch on the other side is
-    partially down (e.g. doesn't forward anymore, but the link is OK), the link
-    won't be disabled. Another way to check for a dead link could be to count
-    incoming frames on a heavily loaded host. This is not applicable to small
-    servers, but may be useful when the front switches send multicast
-    information on their links (e.g. VRRP), or even health-check the servers.
-    Use the arp_interval/arp_ip_target parameters to count incoming/outgoing
-    frames.
+Discussions regarding the bonding driver take place primarily on the
+bonding-devel mailing list, hosted at sourceforge.net.  If you have
+questions or problems, post them to the list.
 
+bonding-devel@lists.sourceforge.net
 
+https://lists.sourceforge.net/lists/listinfo/bonding-devel
 
-Resources and Links
-===================
+There is also a project site on sourceforge.
 
-Current development on this driver is posted to:
- - http://www.sourceforge.net/projects/bonding/
+http://www.sourceforge.net/projects/bonding
 
 Donald Becker's Ethernet Drivers and diag programs may be found at :
  - http://www.scyld.com/network/
 
-You will also find a lot of information regarding Ethernet, NWay, MII, etc. at
-www.scyld.com.
-
-Patches for 2.2 kernels are at Willy Tarreau's site :
- - http://wtarreau.free.fr/pub/bonding/
- - http://www-miaif.lip6.fr/~tarreau/pub/bonding/
-
-To get latest informations about Linux Kernel development, please consult
-the Linux Kernel Mailing List Archives at :
-   http://www.ussg.iu.edu/hypermail/linux/kernel/
+You will also find a lot of information regarding Ethernet, NWay, MII,
+etc. at www.scyld.com.
 
 -- END --
diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/3c59x.c	2005-03-07 12:09:08 -05:00
@@ -964,7 +964,7 @@
 
 #ifdef CONFIG_PM
 
-static int vortex_suspend (struct pci_dev *pdev, u32 state)
+static int vortex_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/8139too.c	2005-03-07 12:09:08 -05:00
@@ -389,8 +389,14 @@
 
 /* Bits in TxConfig. */
 enum tx_config_bits {
-	TxIFG1 = (1 << 25),	/* Interframe Gap Time */
-	TxIFG0 = (1 << 24),	/* Enabling these bits violates IEEE 802.3 */
+
+        /* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.3 */
+        TxIFGShift = 24,
+        TxIFG84 = (0 << TxIFGShift),    /* 8.4us / 840ns (10 / 100Mbps) */
+        TxIFG88 = (1 << TxIFGShift),    /* 8.8us / 880ns (10 / 100Mbps) */
+        TxIFG92 = (2 << TxIFGShift),    /* 9.2us / 920ns (10 / 100Mbps) */
+        TxIFG96 = (3 << TxIFGShift),    /* 9.6us / 960ns (10 / 100Mbps) */
+
 	TxLoopBack = (1 << 18) | (1 << 17), /* enable loopback test mode */
 	TxCRC = (1 << 16),	/* DISABLE appending CRC to end of Tx packets */
 	TxClearAbt = (1 << 0),	/* Clear abort (WO) */
@@ -723,17 +729,14 @@
 #endif
 
 static const unsigned int rtl8139_tx_config =
-	(TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);
+	TxIFG96 | (TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);
 
 static void __rtl8139_cleanup_dev (struct net_device *dev)
 {
-	struct rtl8139_private *tp;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev;
 
 	assert (dev != NULL);
-	assert (dev->priv != NULL);
-
-	tp = dev->priv;
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
@@ -746,7 +749,7 @@
 	pci_release_regions (pdev);
 
 	free_netdev(dev);
-
+	pci_disable_device(pdev);
 	pci_set_drvdata (pdev, NULL);
 }
 
@@ -785,7 +788,7 @@
 
 	*dev_out = NULL;
 
-	/* dev and dev->priv zeroed in alloc_etherdev */
+	/* dev and priv zeroed in alloc_etherdev */
 	dev = alloc_etherdev (sizeof (*tp));
 	if (dev == NULL) {
 		printk (KERN_ERR PFX "%s: Unable to alloc new net device\n", pci_name(pdev));
@@ -794,7 +797,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->pci_dev = pdev;
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -976,8 +979,8 @@
 		return i;
 
 	assert (dev != NULL);
-	tp = dev->priv;
-	assert (tp != NULL);
+	tp = netdev_priv(dev);
+
 	ioaddr = tp->mmio_addr;
 	assert (ioaddr != NULL);
 
@@ -1010,8 +1013,8 @@
 
 	dev->irq = pdev->irq;
 
-	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	/* tp zeroed and aligned in alloc_etherdev */
+	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in rtl8139_init_board */
 	tp->drv_flags = board_info[ent->driver_data].hw_flags;
@@ -1116,11 +1119,8 @@
 static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *np;
 
 	assert (dev != NULL);
-	np = dev->priv;
-	assert (np != NULL);
 
 	unregister_netdev (dev);
 
@@ -1234,7 +1234,7 @@
 
 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval = 0;
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
@@ -1276,7 +1276,7 @@
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1319,7 +1319,7 @@
 
 static int rtl8139_open (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval;
 	void *ioaddr = tp->mmio_addr;
 
@@ -1367,7 +1367,7 @@
 
 static void rtl_check_media (struct net_device *dev, unsigned int init_media)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	if (tp->phys[0] >= 0) {
 		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
@@ -1377,7 +1377,7 @@
 /* Start the hardware at open or resume. */
 static void rtl8139_hw_start (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 	u8 tmp;
@@ -1399,8 +1399,6 @@
 
 	tp->rx_config = rtl8139_rx_config | AcceptBroadcast | AcceptMyPhys;
 	RTL_W32 (RxConfig, tp->rx_config);
-
-	/* Check this value: the documentation for IFG contradicts ifself. */
 	RTL_W32 (TxConfig, rtl8139_tx_config);
 
 	tp->cur_rx = 0;
@@ -1446,7 +1444,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void rtl8139_init_ring (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int i;
 
 	tp->cur_rx = 0;
@@ -1613,7 +1611,7 @@
 static int rtl8139_thread (void *data)
 {
 	struct net_device *dev = data;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	unsigned long timeout;
 
 	daemonize("%s", dev->name);
@@ -1645,7 +1643,7 @@
 
 static void rtl8139_start_thread(struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	tp->thr_pid = -1;
 	tp->twistie = 0;
@@ -1673,7 +1671,7 @@
 
 static void rtl8139_tx_timeout (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1718,7 +1716,7 @@
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned int entry;
 	unsigned int len = skb->len;
@@ -1766,7 +1764,6 @@
 	unsigned long dirty_tx, tx_left;
 
 	assert (dev != NULL);
-	assert (tp != NULL);
 	assert (ioaddr != NULL);
 
 	dirty_tx = tp->dirty_tx;
@@ -2125,7 +2122,7 @@
 
 static int rtl8139_poll(struct net_device *dev, int *budget)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int orig_budget = min(*budget, dev->quota);
 	int done = 1;
@@ -2163,7 +2160,7 @@
 			       struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u16 status, ackstat;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
@@ -2239,7 +2236,7 @@
 
 static int rtl8139_close (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int ret = 0;
 	unsigned long flags;
@@ -2302,7 +2299,7 @@
    other threads or interrupts aren't messing with the 8139.  */
 static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 
 	spin_lock_irq(&np->lock);
@@ -2336,7 +2333,7 @@
    aren't messing with the 8139.  */
 static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 	u32 support;
 	u8 cfg3, cfg5;
@@ -2376,7 +2373,7 @@
 
 static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(np->pci_dev));
@@ -2385,7 +2382,7 @@
 
 static int rtl8139_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
 	mii_ethtool_gset(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
@@ -2394,7 +2391,7 @@
 
 static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&np->lock);
 	rc = mii_ethtool_sset(&np->mii, cmd);
@@ -2404,25 +2401,25 @@
 
 static int rtl8139_nway_reset(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii);
 }
 
 static u32 rtl8139_get_link(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii);
 }
 
 static u32 rtl8139_get_msglevel(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return np->msg_enable;
 }
 
 static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	np->msg_enable = datum;
 }
 
@@ -2433,13 +2430,13 @@
 #else
 static int rtl8139_get_regs_len(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return np->regs_len;
 }
 
 static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 
 	regs->version = RTL_REGS_VER;
 
@@ -2456,7 +2453,7 @@
 
 static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 
 	data[0] = np->xstats.early_rx;
 	data[1] = np->xstats.tx_buf_mapped;
@@ -2488,7 +2485,7 @@
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -2504,7 +2501,7 @@
 
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -2523,7 +2520,7 @@
 
 static void __set_rx_mode (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -2572,7 +2569,7 @@
 static void rtl8139_set_rx_mode (struct net_device *dev)
 {
 	unsigned long flags;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	spin_lock_irqsave (&tp->lock, flags);
 	__set_rx_mode(dev);
@@ -2581,10 +2578,10 @@
 
 #ifdef CONFIG_PM
 
-static int rtl8139_suspend (struct pci_dev *pdev, u32 state)
+static int rtl8139_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/Kconfig	2005-03-07 12:09:08 -05:00
@@ -47,16 +47,13 @@
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
-	  'Trunking' by Sun, and 'Bonding' in Linux.
+	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.
 
-	  If you have two Ethernet connections to some other computer, you can
-	  make them behave like one double speed connection using this driver.
-	  Naturally, this has to be supported at the other end as well, either
-	  with a similar Bonding Linux driver, a Cisco 5500 switch or a
-	  SunTrunking SunSoft driver.
+	  The driver supports multiple bonding modes to allow for both high
+	  perfomance and high availability operation.
 
-	  This is similar to the EQL driver, but it merges Ethernet segments
-	  instead of serial lines.
+	  Refer to <file:Documentation/networking/bonding.txt> for more
+	  information.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called bonding.
@@ -819,7 +816,7 @@
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on NET_ETHERNET && (ARM || REDWOOD_5 || REDWOOD_6 || M32R)
+	depends on NET_ETHERNET && (ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH)
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
diff -Nru a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
--- a/drivers/net/amd8111e.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/amd8111e.c	2005-03-07 12:09:08 -05:00
@@ -1799,7 +1799,7 @@
 	if(!err)
 		netif_wake_queue(dev);
 }
-static int amd8111e_suspend(struct pci_dev *pci_dev, u32 state)
+static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {	
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct amd8111e_priv *lp = netdev_priv(dev);
diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/b44.c	2005-03-07 12:09:08 -05:00
@@ -1903,7 +1903,7 @@
 	}
 }
 
-static int b44_suspend(struct pci_dev *pdev, u32 state)
+static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct b44 *bp = netdev_priv(dev);
diff -Nru a/drivers/net/b44.h b/drivers/net/b44.h
--- a/drivers/net/b44.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/b44.h	2005-03-07 12:09:08 -05:00
@@ -302,20 +302,6 @@
 #define B44_MII_TLEDCTRL	27	/* Traffic Meter LED */
 #define  MII_TLEDCTRL_ENABLE	0x0040
 
-/* XXX Add this to mii.h */
-#ifndef ADVERTISE_PAUSE
-#define ADVERTISE_PAUSE_CAP		0x0400
-#endif
-#ifndef ADVERTISE_PAUSE_ASYM
-#define ADVERTISE_PAUSE_ASYM		0x0800
-#endif
-#ifndef LPA_PAUSE
-#define LPA_PAUSE_CAP			0x0400
-#endif
-#ifndef LPA_PAUSE_ASYM
-#define LPA_PAUSE_ASYM			0x0800
-#endif
-
 struct dma_desc {
 	u32	ctrl;
 	u32	addr;
diff -Nru a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/bonding/bond_alb.c	2005-03-07 12:09:08 -05:00
@@ -954,9 +954,9 @@
 	/* each slave will receive packets destined to a different mac */
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
-	if (dev->set_mac_address(dev, &s_addr)) {
+	if (dev_set_mac_address(dev, &s_addr)) {
 		printk(KERN_ERR DRV_NAME
-		       ": Error: dev->set_mac_address of dev %s failed! ALB "
+		       ": Error: dev_set_mac_address of dev %s failed! ALB "
 		       "mode requires that the base driver support setting "
 		       "the hw address also when the network device's "
 		       "interface is open\n",
@@ -1209,7 +1209,7 @@
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
-		res = slave->dev->set_mac_address(slave->dev, addr);
+		res = dev_set_mac_address(slave->dev, addr);
 
 		/* restore net_device's hw address */
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
@@ -1229,7 +1229,7 @@
 	stop_at = slave;
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
-		slave->dev->set_mac_address(slave->dev, &sa);
+		dev_set_mac_address(slave->dev, &sa);
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
 	}
 
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/bonding/bond_main.c	2005-03-07 12:09:08 -05:00
@@ -1719,7 +1719,7 @@
 		 */
 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
 		addr.sa_family = slave_dev->type;
-		res = slave_dev->set_mac_address(slave_dev, &addr);
+		res = dev_set_mac_address(slave_dev, &addr);
 		if (res) {
 			dprintk("Error %d calling set_mac_address\n", res);
 			goto err_free;
@@ -1849,8 +1849,8 @@
 	if (bond_update_speed_duplex(new_slave) &&
 	    (new_slave->link != BOND_LINK_DOWN)) {
 		printk(KERN_WARNING DRV_NAME
-		       ": Warning: failed to get speed/duplex from %s, speed "
-		       "forced to 100Mbps, duplex forced to Full.\n",
+		       ": Warning: failed to get speed and duplex from %s, "
+		       "assumed to be 100Mb/sec and Full.\n",
 		       new_slave->dev->name);
 
 		if (bond->params.mode == BOND_MODE_8023AD) {
@@ -1991,7 +1991,7 @@
 err_restore_mac:
 	memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
 	addr.sa_family = slave_dev->type;
-	slave_dev->set_mac_address(slave_dev, &addr);
+	dev_set_mac_address(slave_dev, &addr);
 
 err_free:
 	kfree(new_slave);
@@ -2171,7 +2171,7 @@
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
-		slave_dev->set_mac_address(slave_dev, &addr);
+		dev_set_mac_address(slave_dev, &addr);
 	}
 
 	/* restore the original state of the
@@ -2262,7 +2262,7 @@
 			/* restore original ("permanent") mac address*/
 			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 			addr.sa_family = slave_dev->type;
-			slave_dev->set_mac_address(slave_dev, &addr);
+			dev_set_mac_address(slave_dev, &addr);
 		}
 
 		/* restore the original state of the IFF_NOARP flag that might have
@@ -3898,12 +3898,7 @@
 	bond_for_each_slave(bond, slave, i) {
 		dprintk("s %p s->p %p c_m %p\n", slave,
 			slave->prev, slave->dev->change_mtu);
-		if (slave->dev->change_mtu) {
-			res = slave->dev->change_mtu(slave->dev, new_mtu);
-		} else {
-			slave->dev->mtu = new_mtu;
-			res = 0;
-		}
+		res = dev_set_mtu(slave->dev, new_mtu);
 
 		if (res) {
 			/* If we failed to set the slave's mtu to the new value
@@ -3929,14 +3924,10 @@
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		int tmp_res;
 
-		if (slave->dev->change_mtu) {
-			tmp_res = slave->dev->change_mtu(slave->dev, bond_dev->mtu);
-			if (tmp_res) {
-				dprintk("unwind err %d dev %s\n", tmp_res,
-					slave->dev->name);
-			}
-		} else {
-			slave->dev->mtu = bond_dev->mtu;
+		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
+		if (tmp_res) {
+			dprintk("unwind err %d dev %s\n", tmp_res,
+				slave->dev->name);
 		}
 	}
 
@@ -3988,7 +3979,7 @@
 			goto unwind;
 		}
 
-		res = slave->dev->set_mac_address(slave->dev, addr);
+		res = dev_set_mac_address(slave->dev, addr);
 		if (res) {
 			/* TODO: consider downing the slave
 			 * and retry ?
@@ -4014,7 +4005,7 @@
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
 		int tmp_res;
 
-		tmp_res = slave->dev->set_mac_address(slave->dev, &tmp_sa);
+		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
 		if (tmp_res) {
 			dprintk("unwind err %d dev %s\n", tmp_res,
 				slave->dev->name);
diff -Nru a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/e100.c	2005-03-07 12:09:08 -05:00
@@ -2310,7 +2310,7 @@
 }
 
 #ifdef CONFIG_PM
-static int e100_suspend(struct pci_dev *pdev, u32 state)
+static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
@@ -2321,7 +2321,7 @@
 	netif_device_detach(netdev);
 
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, state, nic->flags & (wol_magic | e100_asf(nic)));
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), nic->flags & (wol_magic | e100_asf(nic)));
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/eepro100.c	2005-03-07 12:09:08 -05:00
@@ -2281,7 +2281,7 @@
 }
 
 #ifdef CONFIG_PM
-static int eepro100_suspend(struct pci_dev *pdev, u32 state)
+static int eepro100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct speedo_private *sp = netdev_priv(dev);
@@ -2299,7 +2299,7 @@
 	
 	/* XXX call pci_set_power_state ()? */
 	pci_disable_device(pdev);
-	pci_set_power_state (pdev, 3);
+	pci_set_power_state (pdev, PCI_D3hot);
 	return 0;
 }
 
@@ -2309,7 +2309,7 @@
 	struct speedo_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->regs;
 
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	pci_enable_device(pdev);
 	pci_set_master(pdev);
diff -Nru a/drivers/net/epic100.c b/drivers/net/epic100.c
--- a/drivers/net/epic100.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/epic100.c	2005-03-07 12:09:08 -05:00
@@ -1624,7 +1624,7 @@
 
 #ifdef CONFIG_PM
 
-static int epic_suspend (struct pci_dev *pdev, u32 state)
+static int epic_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	long ioaddr = dev->base_addr;
diff -Nru a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
--- a/drivers/net/ibmlana.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/ibmlana.c	2005-03-07 12:09:08 -05:00
@@ -133,13 +133,14 @@
 
 static void dumpmem(struct net_device *dev, u32 start, u32 len)
 {
+	ibmlana_priv *priv = netdev_priv(dev);
 	int z;
 
 	printk("Address %04x:\n", start);
 	for (z = 0; z < len; z++) {
 		if ((z & 15) == 0)
 			printk("%04x:", z);
-		printk(" %02x", isa_readb(dev->mem_start + start + z));
+		printk(" %02x", readb(priv->base + start + z));
 		if ((z & 15) == 15)
 			printk("\n");
 	}
@@ -231,7 +232,7 @@
 
 static void InitDscrs(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	u32 addr, baddr, raddr;
 	int z;
 	tda_t tda;
@@ -240,8 +241,8 @@
 
 	/* initialize RAM */
 
-	isa_memset_io(dev->mem_start, 0xaa,
-		      dev->mem_start - dev->mem_start);
+	memset_io(priv->base, 0xaa,
+		      dev->mem_start - dev->mem_start);	/* XXX: typo? */
 
 	/* setup n TX descriptors - independent of RAM size */
 
@@ -260,7 +261,7 @@
 		else
 			tda.link = addr + sizeof(tda_t);
 		tda.link |= 1;
-		isa_memcpy_toio(dev->mem_start + addr, &tda, sizeof(tda_t));
+		memcpy_toio(priv->base + addr, &tda, sizeof(tda_t));
 		addr += sizeof(tda_t);
 		baddr += PKTSIZE;
 	}
@@ -280,7 +281,7 @@
 		rra.starthi = 0;
 		rra.cntlo = PKTSIZE >> 1;
 		rra.cnthi = 0;
-		isa_memcpy_toio(dev->mem_start + raddr, &rra, sizeof(rra_t));
+		memcpy_toio(priv->base + raddr, &rra, sizeof(rra_t));
 
 		rda.status = 0;
 		rda.length = 0;
@@ -292,7 +293,7 @@
 		else
 			rda.link = 1;
 		rda.inuse = 1;
-		isa_memcpy_toio(dev->mem_start + addr, &rda, sizeof(rda_t));
+		memcpy_toio(priv->base + addr, &rda, sizeof(rda_t));
 
 		baddr += PKTSIZE;
 		raddr += sizeof(rra_t);
@@ -313,7 +314,7 @@
 
 static int InitSONIC(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 
 	/* set up start & end of resource area */
 
@@ -379,6 +380,7 @@
 
 static void InitBoard(struct net_device *dev)
 {
+	ibmlana_priv *priv = netdev_priv(dev);
 	int camcnt;
 	camentry_t cams[16];
 	u32 cammask;
@@ -429,8 +431,8 @@
 
 	/* feed CDA into SONIC, initialize RCR value (always get broadcasts) */
 
-	isa_memcpy_toio(dev->mem_start, cams, sizeof(camentry_t) * camcnt);
-	isa_memcpy_toio(dev->mem_start + (sizeof(camentry_t) * camcnt), &cammask, sizeof(cammask));
+	memcpy_toio(priv->base, cams, sizeof(camentry_t) * camcnt);
+	memcpy_toio(priv->base + (sizeof(camentry_t) * camcnt), &cammask, sizeof(cammask));
 
 #ifdef DEBUG
 	printk("CAM setup:\n");
@@ -520,7 +522,7 @@
 
 static void StartTx(struct net_device *dev, int descr)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	int addr;
 
 	addr = priv->tdastart + (descr * sizeof(tda_t));
@@ -543,7 +545,7 @@
 
 static void irqrbe_handler(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 
 	/* point the SONIC back to the RRA start */
 
@@ -555,7 +557,7 @@
 
 static void irqrx_handler(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	rda_t rda;
 	u32 rdaaddr, lrdaaddr;
 
@@ -566,7 +568,7 @@
 
 		rdaaddr = priv->rdastart + (priv->nextrxdescr * sizeof(rda_t));
 		lrdaaddr = priv->rdastart + (priv->lastrxdescr * sizeof(rda_t));
-		isa_memcpy_fromio(&rda, dev->mem_start + rdaaddr, sizeof(rda_t));
+		memcpy_fromio(&rda, priv->base + rdaaddr, sizeof(rda_t));
 
 		/* iron out upper word halves of fields we use - SONIC will duplicate 
 		   bits 0..15 to 16..31 */
@@ -593,8 +595,8 @@
 			else {
 				/* copy out data */
 
-				isa_memcpy_fromio(skb_put(skb, rda.length),
-					       dev->mem_start +
+				memcpy_fromio(skb_put(skb, rda.length),
+					       priv->base +
 					       rda.startlo, rda.length);
 
 				/* set up skb fields */
@@ -627,14 +629,14 @@
 
 		rda.link = 1;
 		rda.inuse = 1;
-		isa_memcpy_toio(dev->mem_start + rdaaddr, &rda,
+		memcpy_toio(priv->base + rdaaddr, &rda,
 			     sizeof(rda_t));
 
 		/* set up link and EOL = 0 in currently last descriptor. Only write
 		   the link field since the SONIC may currently already access the
 		   other fields. */
 
-		isa_memcpy_toio(dev->mem_start + lrdaaddr + 20, &rdaaddr, 4);
+		memcpy_toio(priv->base + lrdaaddr + 20, &rdaaddr, 4);
 
 		/* advance indices */
 
@@ -648,11 +650,11 @@
 
 static void irqtx_handler(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	tda_t tda;
 
 	/* fetch descriptor (we forgot the size ;-) */
-	isa_memcpy_fromio(&tda, dev->mem_start + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
+	memcpy_fromio(&tda, priv->base + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
 
 	/* update statistics */
 	priv->stat.tx_packets++;
@@ -672,11 +674,11 @@
 
 static void irqtxerr_handler(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	tda_t tda;
 
 	/* fetch descriptor to check status */
-	isa_memcpy_fromio(&tda, dev->mem_start + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
+	memcpy_fromio(&tda, priv->base + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
 
 	/* update statistics */
 	priv->stat.tx_errors++;
@@ -753,9 +755,7 @@
 
 	if (dev == NULL)
 		return len;
-	if (dev->priv == NULL)
-		return len;
-	priv = (ibmlana_priv *) dev->priv;
+	priv = netdev_priv(dev);
 
 	/* print info */
 
@@ -778,7 +778,7 @@
 static int ibmlana_open(struct net_device *dev)
 {
 	int result;
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 
 	/* register resources - only necessary for IRQ */
 
@@ -814,7 +814,7 @@
 
 static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	int retval = 0, tmplen, addr;
 	unsigned long flags;
 	tda_t tda;
@@ -834,7 +834,7 @@
 	if (tmplen < 60)
 		tmplen = 60;
 	baddr = priv->txbufstart + (priv->nexttxdescr * PKTSIZE);
-	isa_memcpy_toio(dev->mem_start + baddr, skb->data, skb->len);
+	memcpy_toio(priv->base + baddr, skb->data, skb->len);
 
 	/* copy filler into RAM - in case we're filling up... 
 	   we're filling a bit more than necessary, but that doesn't harm
@@ -846,16 +846,16 @@
 		unsigned int destoffs = skb->len, l = strlen(fill);
 
 		while (destoffs < tmplen) {
-			isa_memcpy_toio(dev->mem_start + baddr + destoffs, fill, l);
+			memcpy_toio(priv->base + baddr + destoffs, fill, l);
 			destoffs += l;
 		}
 	}
 
 	/* set up the new frame descriptor */
 	addr = priv->tdastart + (priv->nexttxdescr * sizeof(tda_t));
-	isa_memcpy_fromio(&tda, dev->mem_start + addr, sizeof(tda_t));
+	memcpy_fromio(&tda, priv->base + addr, sizeof(tda_t));
 	tda.length = tda.fraglength = tmplen;
-	isa_memcpy_toio(dev->mem_start + addr, &tda, sizeof(tda_t));
+	memcpy_toio(priv->base + addr, &tda, sizeof(tda_t));
 
 	/* if there were no active descriptors, trigger the SONIC */
 	spin_lock_irqsave(&priv->lock, flags);
@@ -881,7 +881,7 @@
 
 static struct net_device_stats *ibmlana_stats(struct net_device *dev)
 {
-	ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+	ibmlana_priv *priv = netdev_priv(dev);
 	return &priv->stat;
 }
 
@@ -903,7 +903,6 @@
 
 static int ibmlana_probe(struct net_device *dev)
 {
-	int force_detect = 0;
 	int slot, z;
 	int base = 0, irq = 0, iobase = 0, memlen = 0;
 	ibmlana_priv *priv;
@@ -915,10 +914,6 @@
 	if (MCA_bus == 0)
 		return -ENODEV;
 
-	/* start address of 1 --> forced detection */
-	if (dev->mem_start == 1)
-		force_detect = 1;
-
 	base = dev->mem_start;
 	irq = dev->irq;
 
@@ -952,18 +947,12 @@
 		return -EBUSY;
 	}
 
-	/* make procfs entries */
-	mca_set_adapter_name(slot, "IBM LAN Adapter/A");
-	mca_set_adapter_procfn(slot, (MCA_ProcFn) ibmlana_getinfo, dev);
-
-	mca_mark_as_used(slot);
-
-	/* allocate structure */
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 	priv->slot = slot;
 	priv->realirq = irq;
 	priv->medium = medium;
 	spin_lock_init(&priv->lock);
+		
 
 	/* set base + irq for this device (irq not allocated so far) */
 
@@ -972,6 +961,20 @@
 	dev->mem_end = base + memlen;
 	dev->base_addr = iobase;
 
+	priv->base = ioremap(base, memlen);
+	if (!priv->base) {
+		printk(KERN_ERR "%s: cannot remap memory!\n", DRV_NAME);
+		startslot = slot + 1;
+		release_region(iobase, IBM_LANA_IORANGE);
+		return -EBUSY;
+	}
+
+	/* make procfs entries */
+	mca_set_adapter_name(slot, "IBM LAN Adapter/A");
+	mca_set_adapter_procfn(slot, (MCA_ProcFn) ibmlana_getinfo, dev);
+
+	mca_mark_as_used(slot);
+
 	/* set methods */
 
 	dev->open = ibmlana_open;
@@ -1042,11 +1045,12 @@
 			break;
 		}
 		if (register_netdev(dev)) {
-			ibmlana_priv *priv = dev->priv;
+			ibmlana_priv *priv = netdev_priv(dev);
 			release_region(dev->base_addr, IBM_LANA_IORANGE);
 			mca_mark_as_unused(priv->slot);
 			mca_set_adapter_name(priv->slot, "");
 			mca_set_adapter_procfn(priv->slot, NULL, NULL);
+			iounmap(priv->base);
 			free_netdev(dev);
 			break;
 		}
@@ -1061,13 +1065,14 @@
 	for (z = 0; z < DEVMAX; z++) {
 		struct net_device *dev = moddevs[z];
 		if (dev) {
-			ibmlana_priv *priv = (ibmlana_priv *) dev->priv;
+			ibmlana_priv *priv = netdev_priv(dev);
 			unregister_netdev(dev);
 			/*DeinitBoard(dev); */
 			release_region(dev->base_addr, IBM_LANA_IORANGE);
 			mca_mark_as_unused(priv->slot);
 			mca_set_adapter_name(priv->slot, "");
 			mca_set_adapter_procfn(priv->slot, NULL, NULL);
+			iounmap(priv->base);
 			free_netdev(dev);
 		}
 	}
diff -Nru a/drivers/net/ibmlana.h b/drivers/net/ibmlana.h
--- a/drivers/net/ibmlana.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/ibmlana.h	2005-03-07 12:09:08 -05:00
@@ -37,6 +37,7 @@
 		nexttxdescr,		/* last tx descriptor to be used    */
 		currtxdescr,		/* tx descriptor currently tx'ed    */
 		txused[TXBUFCNT];	/* busy flags                       */
+	void __iomem *base;
 	spinlock_t lock;
 } ibmlana_priv;
 
diff -Nru a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/irda/donauboe.c	2005-03-07 12:09:08 -05:00
@@ -1712,7 +1712,7 @@
 }
 
 static int
-toshoboe_gotosleep (struct pci_dev *pci_dev, u32 crap)
+toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
 {
   struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
   unsigned long flags;
diff -Nru a/drivers/net/mii.c b/drivers/net/mii.c
--- a/drivers/net/mii.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/mii.c	2005-03-07 12:09:08 -05:00
@@ -37,6 +37,7 @@
 {
 	struct net_device *dev = mii->dev;
 	u32 advert, bmcr, lpa, nego;
+	u32 advert2 = 0, bmcr2 = 0, lpa2 = 0;
 
 	ecmd->supported =
 	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -54,6 +55,9 @@
 
 	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
 	advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
+	if (mii->supports_gmii)
+		advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+
 	if (advert & ADVERTISE_10HALF)
 		ecmd->advertising |= ADVERTISED_10baseT_Half;
 	if (advert & ADVERTISE_10FULL)
@@ -62,19 +66,31 @@
 		ecmd->advertising |= ADVERTISED_100baseT_Half;
 	if (advert & ADVERTISE_100FULL)
 		ecmd->advertising |= ADVERTISED_100baseT_Full;
+	if (advert2 & ADVERTISE_1000HALF)
+		ecmd->advertising |= ADVERTISED_1000baseT_Half;
+	if (advert2 & ADVERTISE_1000FULL)
+		ecmd->advertising |= ADVERTISED_1000baseT_Full;
 
 	bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
 	lpa = mii->mdio_read(dev, mii->phy_id, MII_LPA);
+	if (mii->supports_gmii) {
+		bmcr2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+		lpa2 = mii->mdio_read(dev, mii->phy_id, MII_STAT1000);
+	}
 	if (bmcr & BMCR_ANENABLE) {
 		ecmd->advertising |= ADVERTISED_Autoneg;
 		ecmd->autoneg = AUTONEG_ENABLE;
 		
 		nego = mii_nway_result(advert & lpa);
-		if (nego == LPA_100FULL || nego == LPA_100HALF)
+		if ((bmcr2 & (ADVERTISE_1000HALF | ADVERTISE_1000FULL)) & 
+		    (lpa2 >> 2))
+			ecmd->speed = SPEED_1000;
+		else if (nego == LPA_100FULL || nego == LPA_100HALF)
 			ecmd->speed = SPEED_100;
 		else
 			ecmd->speed = SPEED_10;
-		if (nego == LPA_100FULL || nego == LPA_10FULL) {
+		if ((lpa2 & LPA_1000FULL) || nego == LPA_100FULL ||
+		    nego == LPA_10FULL) {
 			ecmd->duplex = DUPLEX_FULL;
 			mii->full_duplex = 1;
 		} else {
@@ -84,7 +100,9 @@
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
 
-		ecmd->speed = (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10;
+		ecmd->speed = ((bmcr2 & BMCR_SPEED1000 && 
+				(bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
+			       (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10);
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
@@ -97,7 +115,9 @@
 {
 	struct net_device *dev = mii->dev;
 
-	if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
+	if (ecmd->speed != SPEED_10 && 
+	    ecmd->speed != SPEED_100 && 
+	    ecmd->speed != SPEED_1000)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
@@ -109,21 +129,30 @@
 		return -EINVAL;
 	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
+	if ((ecmd->speed == SPEED_1000) && (!mii->supports_gmii))
+		return -EINVAL;
 				  
 	/* ignore supported, maxtxpkt, maxrxpkt */
 	
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		u32 bmcr, advert, tmp;
+		u32 advert2 = 0, tmp2 = 0;
 
 		if ((ecmd->advertising & (ADVERTISED_10baseT_Half |
 					  ADVERTISED_10baseT_Full |
 					  ADVERTISED_100baseT_Half |
-					  ADVERTISED_100baseT_Full)) == 0)
+					  ADVERTISED_100baseT_Full |
+					  ADVERTISED_1000baseT_Half |
+					  ADVERTISED_1000baseT_Full)) == 0)
 			return -EINVAL;
 
 		/* advertise only what has been requested */
 		advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
 		tmp = advert & ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+		if (mii->supports_gmii) {
+			advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+			tmp2 = advert2 & ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+		}
 		if (ecmd->advertising & ADVERTISED_10baseT_Half)
 			tmp |= ADVERTISE_10HALF;
 		if (ecmd->advertising & ADVERTISED_10baseT_Full)
@@ -132,10 +161,18 @@
 			tmp |= ADVERTISE_100HALF;
 		if (ecmd->advertising & ADVERTISED_100baseT_Full)
 			tmp |= ADVERTISE_100FULL;
+		if (mii->supports_gmii) {
+			if (ecmd->advertising & ADVERTISED_1000baseT_Half)
+				advert2 |= ADVERTISE_1000HALF;
+			if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+				advert2 |= ADVERTISE_1000FULL;
+		}
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
 			mii->advertising = tmp;
 		}
+		if ((mii->supports_gmii) && (advert2 != tmp2))
+			mii->mdio_write(dev, mii->phy_id, MII_CTRL1000, tmp2);
 		
 		/* turn on autonegotiation, and force a renegotiate */
 		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
@@ -148,8 +185,11 @@
 
 		/* turn off auto negotiation, set speed and duplexity */
 		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
-		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 | BMCR_FULLDPLX);
-		if (ecmd->speed == SPEED_100)
+		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 | 
+			       BMCR_SPEED1000 | BMCR_FULLDPLX);
+		if (ecmd->speed == SPEED_1000)
+			tmp |= BMCR_SPEED1000;
+		else if (ecmd->speed == SPEED_100)
 			tmp |= BMCR_SPEED100;
 		if (ecmd->duplex == DUPLEX_FULL) {
 			tmp |= BMCR_FULLDPLX;
@@ -207,6 +247,7 @@
 {
 	unsigned int old_carrier, new_carrier;
 	int advertise, lpa, media, duplex;
+	int lpa2 = 0;
 
 	/* if forced media, go no further */
 	if (mii->force_media)
@@ -243,16 +284,20 @@
 		mii->advertising = advertise;
 	}
 	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
+	if (mii->supports_gmii)
+		lpa2 = mii->mdio_read(mii->dev, mii->phy_id, MII_STAT1000);
 
 	/* figure out media and duplex from advertise and LPA values */
 	media = mii_nway_result(lpa & advertise);
 	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
+	if (lpa2 & LPA_1000FULL)
+		duplex = 1;
 
 	if (ok_to_print)
 		printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 0x%04X\n",
 		       mii->dev->name,
-		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ?
-		       		"100" : "10",
+		       lpa2 & (LPA_1000FULL | LPA_1000HALF) ? "1000" :
+		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ? "100" : "10",
 		       duplex ? "full" : "half",
 		       lpa);
 
diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/natsemi.c	2005-03-07 12:09:08 -05:00
@@ -3162,7 +3162,7 @@
  * Interrupts must be disabled, otherwise hands_off can cause irq storms.
  */
 
-static int natsemi_suspend (struct pci_dev *pdev, u32 state)
+static int natsemi_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct netdev_private *np = netdev_priv(dev);
diff -Nru a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/ne2k-pci.c	2005-03-07 12:09:08 -05:00
@@ -654,13 +654,13 @@
 }
 
 #ifdef CONFIG_PM
-static int ne2k_pci_suspend (struct pci_dev *pdev, u32 state)
+static int ne2k_pci_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 
 	netif_device_detach(dev);
 	pci_save_state(pdev);
-	pci_set_power_state(pdev, state);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/s2io.c	2005-03-07 12:09:08 -05:00
@@ -699,8 +699,7 @@
 	val64 = 0;
 	writeq(val64, &bar0->sw_reset);
 	val64 = readq(&bar0->sw_reset);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 2);
+	msleep(500);
 
 	/*  Enable Receiving broadcasts */
 	add = &bar0->mac_cfg;
@@ -953,8 +952,7 @@
 				  dev->name);
 			return -1;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		time++;
 	}
 
@@ -992,8 +990,7 @@
 			return -1;
 		}
 		time++;
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 	}
 
 	/* 
@@ -1422,8 +1419,7 @@
 	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);
 	val64 = readq(&bar0->mc_rldram_mrs);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 10);	/* Delay by around 100 ms. */
+	msleep(100);			/* Delay by around 100 ms. */
 
 	/* Enabling ECC Protection. */
 	val64 = readq(&bar0->adapter_control);
@@ -2438,8 +2434,7 @@
 			ret = SUCCESS;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		if (cnt++ > 10)
 			break;
 	}
@@ -2478,15 +2473,13 @@
 	 * As of now I'am just giving a 250ms delay and hoping that the
 	 * PCI write to sw_reset register is done by this time.
 	 */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 4);
+	msleep(250);
 
 	/* Restore the PCI state saved during initializarion. */
 	pci_restore_state(sp->pdev);
 	s2io_init_pci(sp);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 4);
+	msleep(250);
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -3304,11 +3297,10 @@
 		sp->id_timer.data = (unsigned long) sp;
 	}
 	mod_timer(&sp->id_timer, jiffies);
-	set_current_state(TASK_INTERRUPTIBLE);
 	if (data)
-		schedule_timeout(data * HZ);
+		msleep(data * 1000);
 	else
-		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
+		msleep(0xFFFFFFFF);
 	del_timer_sync(&sp->id_timer);
 
 	if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
@@ -3411,8 +3403,7 @@
 			ret = 0;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		exit_cnt++;
 	}
 
@@ -3452,8 +3443,7 @@
 				ret = 0;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		exit_cnt++;
 	}
 
@@ -3709,8 +3699,7 @@
 			ret = 0;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 10);
+		msleep(100);
 		cnt++;
 	}
 
@@ -3811,8 +3800,7 @@
 			val64 = readq(&bar0->mc_rldram_test_ctrl);
 			if (val64 & MC_RLDRAM_TEST_DONE)
 				break;
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ / 5);
+			msleep(200);
 		}
 
 		if (cnt == 5)
@@ -3828,8 +3816,7 @@
 			val64 = readq(&bar0->mc_rldram_test_ctrl);
 			if (val64 & MC_RLDRAM_TEST_DONE)
 				break;
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ / 2);
+			msleep(500);
 		}
 
 		if (cnt == 5)
@@ -4189,8 +4176,7 @@
 	 * Allow a small delay for the NICs self initiated 
 	 * cleanup to complete.
 	 */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 10);
+	msleep(100);
 
 	val64 = readq(&bar0->adapter_status);
 	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {
@@ -4244,10 +4230,8 @@
 	register u64 val64 = 0;
 
 	/* If s2io_set_link task is executing, wait till it completes. */
-	while (test_and_set_bit(0, &(sp->link_state))) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
-	}
+	while (test_and_set_bit(0, &(sp->link_state)))
+		msleep(50);
 	atomic_set(&sp->card_state, CARD_DOWN);
 
 	/* disable Tx and Rx traffic on the NIC */
@@ -4263,8 +4247,7 @@
 			break;
 		}
 
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		cnt++;
 		if (cnt == 10) {
 			DBG_PRINT(ERR_DBG,
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/sis900.c	2005-03-07 12:09:08 -05:00
@@ -2226,7 +2226,7 @@
 
 #ifdef CONFIG_PM
 
-static int sis900_suspend(struct pci_dev *pci_dev, u32 state)
+static int sis900_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	long ioaddr = net_dev->base_addr;
diff -Nru a/drivers/net/sk_mca.c b/drivers/net/sk_mca.c
--- a/drivers/net/sk_mca.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/sk_mca.c	2005-03-07 12:09:08 -05:00
@@ -127,12 +127,13 @@
 #ifdef DEBUG
 static void dumpmem(struct net_device *dev, u32 start, u32 len)
 {
+	skmca_priv *priv = netdev_priv(dev);
 	int z;
 
 	for (z = 0; z < len; z++) {
 		if ((z & 15) == 0)
 			printk("%04x:", z);
-		printk(" %02x", SKMCA_READB(dev->mem_start + start + z));
+		printk(" %02x", readb(priv->base + start + z));
 		if ((z & 15) == 15)
 			printk("\n");
 	}
@@ -220,21 +221,21 @@
 
 static void ResetBoard(struct net_device *dev)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 
-	SKMCA_WRITEB(CTRL_RESET_ON, priv->ctrladdr);
+	writeb(CTRL_RESET_ON, priv->ctrladdr);
 	udelay(10);
-	SKMCA_WRITEB(CTRL_RESET_OFF, priv->ctrladdr);
+	writeb(CTRL_RESET_OFF, priv->ctrladdr);
 }
 
 /* wait for LANCE interface to become not busy */
 
 static int WaitLANCE(struct net_device *dev)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	int t = 0;
 
-	while ((SKMCA_READB(priv->ctrladdr) & STAT_IO_BUSY) ==
+	while ((readb(priv->ctrladdr) & STAT_IO_BUSY) ==
 	       STAT_IO_BUSY) {
 		udelay(1);
 		if (++t > 1000) {
@@ -250,7 +251,7 @@
 
 static void SetLANCE(struct net_device *dev, u16 addr, u16 value)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	/* disable interrupts */
@@ -263,19 +264,17 @@
 
 	/* transfer register address to RAP */
 
-	SKMCA_WRITEB(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_RAP,
-		     priv->ctrladdr);
-	SKMCA_WRITEW(addr, priv->ioregaddr);
-	SKMCA_WRITEB(IOCMD_GO, priv->cmdaddr);
+	writeb(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_RAP, priv->ctrladdr);
+	writew(addr, priv->ioregaddr);
+	writeb(IOCMD_GO, priv->cmdaddr);
 	udelay(1);
 	WaitLANCE(dev);
 
 	/* transfer data to register */
 
-	SKMCA_WRITEB(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_DATA,
-		     priv->ctrladdr);
-	SKMCA_WRITEW(value, priv->ioregaddr);
-	SKMCA_WRITEB(IOCMD_GO, priv->cmdaddr);
+	writeb(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_DATA, priv->ctrladdr);
+	writew(value, priv->ioregaddr);
+	writeb(IOCMD_GO, priv->cmdaddr);
 	udelay(1);
 	WaitLANCE(dev);
 
@@ -288,7 +287,7 @@
 
 static u16 GetLANCE(struct net_device *dev, u16 addr)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int res;
 
@@ -302,21 +301,19 @@
 
 	/* transfer register address to RAP */
 
-	SKMCA_WRITEB(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_RAP,
-		     priv->ctrladdr);
-	SKMCA_WRITEW(addr, priv->ioregaddr);
-	SKMCA_WRITEB(IOCMD_GO, priv->cmdaddr);
+	writeb(CTRL_RESET_OFF | CTRL_RW_WRITE | CTRL_ADR_RAP, priv->ctrladdr);
+	writew(addr, priv->ioregaddr);
+	writeb(IOCMD_GO, priv->cmdaddr);
 	udelay(1);
 	WaitLANCE(dev);
 
 	/* transfer data from register */
 
-	SKMCA_WRITEB(CTRL_RESET_OFF | CTRL_RW_READ | CTRL_ADR_DATA,
-		     priv->ctrladdr);
-	SKMCA_WRITEB(IOCMD_GO, priv->cmdaddr);
+	writeb(CTRL_RESET_OFF | CTRL_RW_READ | CTRL_ADR_DATA, priv->ctrladdr);
+	writeb(IOCMD_GO, priv->cmdaddr);
 	udelay(1);
 	WaitLANCE(dev);
-	res = SKMCA_READW(priv->ioregaddr);
+	res = readw(priv->ioregaddr);
 
 	/* reenable interrupts */
 
@@ -329,6 +326,7 @@
 
 static void InitDscrs(struct net_device *dev)
 {
+	skmca_priv *priv = netdev_priv(dev);
 	u32 bufaddr;
 
 	/* Set up Tx descriptors. The board has only 16K RAM so bits 16..23
@@ -344,11 +342,10 @@
 			descr.Flags = 0;
 			descr.Len = 0xf000;
 			descr.Status = 0;
-			SKMCA_TOIO(dev->mem_start + RAM_TXBASE +
+			memcpy_toio(priv->base + RAM_TXBASE +
 				   (z * sizeof(LANCE_TxDescr)), &descr,
 				   sizeof(LANCE_TxDescr));
-			SKMCA_SETIO(dev->mem_start + bufaddr, 0,
-				    RAM_BUFSIZE);
+			memset_io(priv->base + bufaddr, 0, RAM_BUFSIZE);
 			bufaddr += RAM_BUFSIZE;
 		}
 	}
@@ -364,11 +361,10 @@
 			descr.Flags = RXDSCR_FLAGS_OWN;
 			descr.MaxLen = -RAM_BUFSIZE;
 			descr.Len = 0;
-			SKMCA_TOIO(dev->mem_start + RAM_RXBASE +
+			memcpy_toio(priv->base + RAM_RXBASE +
 				   (z * sizeof(LANCE_RxDescr)), &descr,
 				   sizeof(LANCE_RxDescr));
-			SKMCA_SETIO(dev->mem_start + bufaddr, 0,
-				    RAM_BUFSIZE);
+			memset_io(priv->base + bufaddr, 0, RAM_BUFSIZE);
 			bufaddr += RAM_BUFSIZE;
 		}
 	}
@@ -425,7 +421,7 @@
 
 static void InitLANCE(struct net_device *dev)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 
 	/* build up descriptors. */
 
@@ -478,6 +474,7 @@
 
 static void InitBoard(struct net_device *dev)
 {
+	skmca_priv *priv = netdev_priv(dev);
 	LANCE_InitBlock block;
 
 	/* Lay out the shared RAM - first we create the init block for the LANCE.
@@ -492,7 +489,7 @@
 	block.RdrP = (RAM_RXBASE & 0xffffff) | (LRXCOUNT << 29);
 	block.TdrP = (RAM_TXBASE & 0xffffff) | (LTXCOUNT << 29);
 
-	SKMCA_TOIO(dev->mem_start + RAM_INITBASE, &block, sizeof(block));
+	memcpy_toio(priv->base + RAM_INITBASE, &block, sizeof(block));
 
 	/* initialize LANCE. Implicitly sets up other structures in RAM. */
 
@@ -572,7 +569,7 @@
 
 static u16 irqmiss_handler(struct net_device *dev, u16 oldcsr0)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 
 	/* update statistics */
 
@@ -588,7 +585,7 @@
 
 static u16 irqrx_handler(struct net_device *dev, u16 oldcsr0)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	LANCE_RxDescr descr;
 	unsigned int descraddr;
 
@@ -597,7 +594,7 @@
 	descraddr = RAM_RXBASE + (priv->nextrx * sizeof(LANCE_RxDescr));
 	while (1) {
 		/* read descriptor */
-		SKMCA_FROMIO(&descr, dev->mem_start + descraddr,
+		memcpy_fromio(&descr, priv->base + descraddr,
 			     sizeof(LANCE_RxDescr));
 
 		/* if we reach a descriptor we do not own, we're done */
@@ -629,8 +626,8 @@
 			if (skb == NULL)
 				priv->stat.rx_dropped++;
 			else {
-				SKMCA_FROMIO(skb_put(skb, descr.Len),
-					     dev->mem_start +
+				memcpy_fromio(skb_put(skb, descr.Len),
+					     priv->base +
 					     descr.LowAddr, descr.Len);
 				skb->dev = dev;
 				skb->protocol = eth_type_trans(skb, dev);
@@ -647,7 +644,7 @@
 		descr.Flags |= RXDSCR_FLAGS_OWN;
 
 		/* update descriptor in shared RAM */
-		SKMCA_TOIO(dev->mem_start + descraddr, &descr,
+		memcpy_toio(priv->base + descraddr, &descr,
 			   sizeof(LANCE_RxDescr));
 
 		/* go to next descriptor */
@@ -669,7 +666,7 @@
 
 static u16 irqtx_handler(struct net_device *dev, u16 oldcsr0)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	LANCE_TxDescr descr;
 	unsigned int descraddr;
 
@@ -679,7 +676,7 @@
 	    RAM_TXBASE + (priv->nexttxdone * sizeof(LANCE_TxDescr));
 	while (priv->txbusy > 0) {
 		/* read descriptor */
-		SKMCA_FROMIO(&descr, dev->mem_start + descraddr,
+		memcpy_fromio(&descr, priv->base + descraddr,
 			     sizeof(LANCE_TxDescr));
 
 		/* if the LANCE still owns this one, we've worked out all sent packets */
@@ -798,9 +795,7 @@
 
 	if (dev == NULL)
 		return len;
-	if (dev->priv == NULL)
-		return len;
-	priv = (skmca_priv *) dev->priv;
+	priv = netdev_priv(dev);
 
 	/* print info */
 
@@ -825,7 +820,7 @@
 static int skmca_open(struct net_device *dev)
 {
 	int result;
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 
 	/* register resources - only necessary for IRQ */
 	result =
@@ -868,7 +863,7 @@
 
 static int skmca_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	LANCE_TxDescr descr;
 	unsigned int address;
 	int tmplen, retval = 0;
@@ -894,8 +889,7 @@
 
 	/* get TX descriptor */
 	address = RAM_TXBASE + (priv->nexttxput * sizeof(LANCE_TxDescr));
-	SKMCA_FROMIO(&descr, dev->mem_start + address,
-		     sizeof(LANCE_TxDescr));
+	memcpy_fromio(&descr, priv->base + address, sizeof(LANCE_TxDescr));
 
 	/* enter packet length as 2s complement - assure minimum length */
 	tmplen = skb->len;
@@ -911,14 +905,14 @@
 		unsigned int destoffs = 0, l = strlen(fill);
 
 		while (destoffs < tmplen) {
-			SKMCA_TOIO(dev->mem_start + descr.LowAddr +
+			memcpy_toio(priv->base + descr.LowAddr +
 				   destoffs, fill, l);
 			destoffs += l;
 		}
 	}
 
 	/* do the real data copying */
-	SKMCA_TOIO(dev->mem_start + descr.LowAddr, skb->data, skb->len);
+	memcpy_toio(priv->base + descr.LowAddr, skb->data, skb->len);
 
 	/* hand descriptor over to LANCE - this is the first and last chunk */
 	descr.Flags =
@@ -945,8 +939,7 @@
 		netif_stop_queue(dev);
 
 	/* write descriptor back to RAM */
-	SKMCA_TOIO(dev->mem_start + address, &descr,
-		   sizeof(LANCE_TxDescr));
+	memcpy_toio(priv->base + address, &descr, sizeof(LANCE_TxDescr));
 
 	/* if no descriptors were active, give the LANCE a hint to read it
 	   immediately */
@@ -967,7 +960,7 @@
 
 static struct net_device_stats *skmca_stats(struct net_device *dev)
 {
-	skmca_priv *priv = (skmca_priv *) dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 
 	return &(priv->stat);
 }
@@ -977,13 +970,14 @@
 
 static void skmca_set_multicast_list(struct net_device *dev)
 {
+	skmca_priv *priv = netdev_priv(dev);
 	LANCE_InitBlock block;
 
 	/* first stop the LANCE... */
 	StopLANCE(dev);
 
 	/* ...then modify the initialization block... */
-	SKMCA_FROMIO(&block, dev->mem_start + RAM_INITBASE, sizeof(block));
+	memcpy_fromio(&block, priv->base + RAM_INITBASE, sizeof(block));
 	if (dev->flags & IFF_PROMISC)
 		block.Mode |= LANCE_INIT_PROM;
 	else
@@ -1003,7 +997,7 @@
 		}
 	}
 
-	SKMCA_TOIO(dev->mem_start + RAM_INITBASE, &block, sizeof(block));
+	memcpy_toio(priv->base + RAM_INITBASE, &block, sizeof(block));
 
 	/* ...then reinit LANCE with the correct flags */
 	InitLANCE(dev);
@@ -1017,10 +1011,11 @@
 
 static void cleanup_card(struct net_device *dev)
 {
-	skmca_priv *priv = dev->priv;
+	skmca_priv *priv = netdev_priv(dev);
 	DeinitBoard(dev);
 	if (dev->irq != 0)
 		free_irq(dev->irq, dev);
+	iounmap(priv->base);
 	mca_mark_as_unused(priv->slot);
 	mca_set_adapter_procfn(priv->slot, NULL, NULL);
 }
@@ -1104,13 +1099,20 @@
 	printk("%s: SKNet %s adapter found in slot %d\n", dev->name,
 	       junior ? "Junior MC2" : "MC2+", slot + 1);
 
-	/* allocate structure */
-	priv = dev->priv;
+	priv = netdev_priv(dev);
+	priv->base = ioremap(base, 0x4000);
+	if (!priv->base) {
+		mca_set_adapter_procfn(slot, NULL, NULL);
+		mca_mark_as_unused(slot);
+		free_netdev(dev);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	priv->slot = slot;
-	priv->macbase = base + 0x3fc0;
-	priv->ioregaddr = base + 0x3ff0;
-	priv->ctrladdr = base + 0x3ff2;
-	priv->cmdaddr = base + 0x3ff3;
+	priv->macbase = priv->base + 0x3fc0;
+	priv->ioregaddr = priv->base + 0x3ff0;
+	priv->ctrladdr = priv->base + 0x3ff2;
+	priv->cmdaddr = priv->base + 0x3ff3;
 	priv->medium = medium;
 	memset(&priv->stat, 0, sizeof(struct net_device_stats));
 	spin_lock_init(&priv->lock);
@@ -1147,7 +1149,7 @@
 
 	/* copy out MAC address */
 	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = SKMCA_READB(priv->macbase + (i << 1));
+		dev->dev_addr[i] = readb(priv->macbase + (i << 1));
 
 	/* print config */
 	printk("%s: IRQ %d, memory %#lx-%#lx, "
diff -Nru a/drivers/net/sk_mca.h b/drivers/net/sk_mca.h
--- a/drivers/net/sk_mca.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/sk_mca.h	2005-03-07 12:09:08 -05:00
@@ -5,16 +5,6 @@
 
 #ifdef _SK_MCA_DRIVER_
 
-/* version-dependent functions/structures */
-
-#define SKMCA_READB(addr) isa_readb(addr)
-#define SKMCA_READW(addr) isa_readw(addr)
-#define SKMCA_WRITEB(data, addr) isa_writeb(data, addr)
-#define SKMCA_WRITEW(data, addr) isa_writew(data, addr)
-#define SKMCA_TOIO(dest, src, len) isa_memcpy_toio(dest, src, len)
-#define SKMCA_FROMIO(dest, src, len) isa_memcpy_fromio(dest, src, len)
-#define SKMCA_SETIO(dest, val, len) isa_memset_io(dest, val, len)
-
 /* Adapter ID's */
 #define SKNET_MCA_ID 0x6afd
 #define SKNET_JUNIOR_MCA_ID 0x6be9
@@ -29,10 +19,11 @@
 /* private structure */
 typedef struct {
 	unsigned int slot;	/* MCA-Slot-#                       */
-	unsigned int macbase;	/* base address of MAC address PROM */
-	unsigned int ioregaddr;	/* address of I/O-register (Lo)     */
-	unsigned int ctrladdr;	/* address of control/stat register */
-	unsigned int cmdaddr;	/* address of I/O-command register  */
+	void __iomem *base;
+	void __iomem *macbase;	/* base address of MAC address PROM */
+	void __iomem *ioregaddr;/* address of I/O-register (Lo)     */
+	void __iomem *ctrladdr;	/* address of control/stat register */
+	void __iomem *cmdaddr;	/* address of I/O-command register  */
 	int nextrx;		/* index of next RX descriptor to
 				   be read                          */
 	int nexttxput;		/* index of next free TX descriptor */
diff -Nru a/drivers/net/smc91x.h b/drivers/net/smc91x.h
--- a/drivers/net/smc91x.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/smc91x.h	2005-03-07 12:09:08 -05:00
@@ -182,6 +182,25 @@
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 
+#elif	defined(CONFIG_SH_SH4202_MICRODEV)
+
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+
+#define SMC_inb(a, r)		inb((a) + (r) - 0xa0000000)
+#define SMC_inw(a, r)		inw((a) + (r) - 0xa0000000)
+#define SMC_inl(a, r)		inl((a) + (r) - 0xa0000000)
+#define SMC_outb(v, a, r)	outb(v, (a) + (r) - 0xa0000000)
+#define SMC_outw(v, a, r)	outw(v, (a) + (r) - 0xa0000000)
+#define SMC_outl(v, a, r)	outl(v, (a) + (r) - 0xa0000000)
+#define SMC_insl(a, r, p, l)	insl((a) + (r) - 0xa0000000, p, l)
+#define SMC_outsl(a, r, p, l)	outsl((a) + (r) - 0xa0000000, p, l)
+#define SMC_insw(a, r, p, l)	insw((a) + (r) - 0xa0000000, p, l)
+#define SMC_outsw(a, r, p, l)	outsw((a) + (r) - 0xa0000000, p, l)
+
+#define set_irq_type(irq, type)	do {} while(0)
+
 #elif	defined(CONFIG_ISA)
 
 #define SMC_CAN_USE_8BIT	1
diff -Nru a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/sundance.c	2005-03-07 12:09:08 -05:00
@@ -1210,9 +1210,11 @@
 				}
 				/* Yup, this is a documentation bug.  It cost me *hours*. */
 				iowrite16 (0, ioaddr + TxStatus);
-				tx_status = ioread16 (ioaddr + TxStatus);
-				if (tx_cnt < 0)
+				if (tx_cnt < 0) {
+					iowrite32(5000, ioaddr + DownCounter);
 					break;
+				}
+				tx_status = ioread16 (ioaddr + TxStatus);
 			}
 			hw_frame_id = (tx_status >> 8) & 0xff;
 		} else 	{
@@ -1278,7 +1280,6 @@
 	if (netif_msg_intr(np))
 		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
 			   dev->name, ioread16(ioaddr + IntrStatus));
-	iowrite32(5000, ioaddr + DownCounter);
 	return IRQ_RETVAL(handled);
 }
 
diff -Nru a/drivers/net/sungem.c b/drivers/net/sungem.c
--- a/drivers/net/sungem.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/sungem.c	2005-03-07 12:09:08 -05:00
@@ -2356,7 +2356,7 @@
 }
 
 #ifdef CONFIG_PM
-static int gem_suspend(struct pci_dev *pdev, u32 state)
+static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/tg3.c	2005-03-07 12:09:08 -05:00
@@ -8948,7 +8948,7 @@
 	}
 }
 
-static int tg3_suspend(struct pci_dev *pdev, u32 state)
+static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = netdev_priv(dev);
@@ -8975,7 +8975,7 @@
 	spin_unlock(&tp->tx_lock);
 	spin_unlock_irq(&tp->lock);
 
-	err = tg3_set_power_state(tp, state);
+	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
 	if (err) {
 		spin_lock_irq(&tp->lock);
 		spin_lock(&tp->tx_lock);
diff -Nru a/drivers/net/tg3.h b/drivers/net/tg3.h
--- a/drivers/net/tg3.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/tg3.h	2005-03-07 12:09:08 -05:00
@@ -1548,20 +1548,6 @@
 #define MII_TG3_INT_DUPLEXCHG		0x0008
 #define MII_TG3_INT_ANEG_PAGE_RX	0x0400
 
-/* XXX Add this to mii.h */
-#ifndef ADVERTISE_PAUSE
-#define ADVERTISE_PAUSE_CAP		0x0400
-#endif
-#ifndef ADVERTISE_PAUSE_ASYM
-#define ADVERTISE_PAUSE_ASYM		0x0800
-#endif
-#ifndef LPA_PAUSE
-#define LPA_PAUSE_CAP			0x0400
-#endif
-#ifndef LPA_PAUSE_ASYM
-#define LPA_PAUSE_ASYM			0x0800
-#endif
-
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they
  * exist only in the cards on-chip SRAM.  All 16 send bds are under
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/tulip/tulip_core.c	2005-03-07 12:09:08 -05:00
@@ -1749,7 +1749,7 @@
 
 #ifdef CONFIG_PM
 
-static int tulip_suspend (struct pci_dev *pdev, u32 state)
+static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/typhoon.c	2005-03-07 12:09:08 -05:00
@@ -1874,7 +1874,7 @@
 }
 
 static int
-typhoon_sleep(struct typhoon *tp, int state, u16 events)
+typhoon_sleep(struct typhoon *tp, pci_power_t state, u16 events)
 {
 	struct pci_dev *pdev = tp->pdev;
 	void __iomem *ioaddr = tp->ioaddr;
@@ -2155,7 +2155,7 @@
 		goto out;
 	}
 
-	if(typhoon_sleep(tp, 3, 0) < 0) 
+	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) 
 		printk(KERN_ERR "%s: unable to go back to sleep\n", dev->name);
 
 out:
@@ -2182,7 +2182,7 @@
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0)
 		printk(KERN_ERR "%s: unable to boot sleep image\n", dev->name);
 
-	if(typhoon_sleep(tp, 3, 0) < 0)
+	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0)
 		printk(KERN_ERR "%s: unable to put card to sleep\n", dev->name);
 
 	return 0;
@@ -2222,7 +2222,7 @@
 }
 
 static int
-typhoon_suspend(struct pci_dev *pdev, u32 state)
+typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct typhoon *tp = netdev_priv(dev);
@@ -2532,7 +2532,7 @@
 	if(xp_resp[0].numDesc != 0)
 		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
 
-	if(typhoon_sleep(tp, 3, 0) < 0) {
+	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
 		printk(ERR_PFX "%s: cannot put adapter to sleep\n",
 		       pci_name(pdev));
 		err = -EIO;
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/via-rhine.c	2005-03-07 12:09:08 -05:00
@@ -1937,7 +1937,7 @@
 }
 
 #ifdef CONFIG_PM
-static int rhine_suspend(struct pci_dev *pdev, u32 state)
+static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/via-velocity.c	2005-03-07 12:09:08 -05:00
@@ -263,7 +263,7 @@
 
 #ifdef CONFIG_PM
 
-static int velocity_suspend(struct pci_dev *pdev, u32 state);
+static int velocity_suspend(struct pci_dev *pdev, pm_message_t state);
 static int velocity_resume(struct pci_dev *pdev);
 
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr);
@@ -3210,7 +3210,7 @@
 	return 0;
 }
 
-static int velocity_suspend(struct pci_dev *pdev, u32 state)
+static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct velocity_info *vptr = pci_get_drvdata(pdev);
 	unsigned long flags;
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/wireless/arlan.h	2005-03-07 12:09:08 -05:00
@@ -43,8 +43,8 @@
 extern int init_arlan_proc(void);
 extern void cleanup_arlan_proc(void);
 #else
-#define init_arlan_proc()	(0)
-#define cleanup_arlan_proc()	do { } while (0);
+#define init_arlan_proc()	({ 0; })
+#define cleanup_arlan_proc()	do { } while (0)
 #endif
 
 extern struct net_device *arlan_device[MAX_ARLANS];
diff -Nru a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
--- a/drivers/net/wireless/atmel.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/wireless/atmel.c	2005-03-07 12:09:08 -05:00
@@ -69,6 +69,7 @@
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
 #include "ieee802_11.h"
+#include "atmel.h"
 
 #define DRIVER_MAJOR 0
 #define DRIVER_MINOR 96
@@ -83,6 +84,23 @@
 static char *firmware = NULL;
 module_param(firmware, charp, 0);
 
+/* table of firmware file names */
+static struct { 
+	AtmelFWType fw_type;
+	const char *fw_file;
+	const char *fw_file_ext;
+} fw_table[] = {
+	{ ATMEL_FW_TYPE_502,      "atmel_at76c502",      "bin" },
+	{ ATMEL_FW_TYPE_502D,     "atmel_at76c502d",     "bin" },
+	{ ATMEL_FW_TYPE_502E,     "atmel_at76c502e",     "bin" },
+	{ ATMEL_FW_TYPE_502_3COM, "atmel_at76c502_3com", "bin" },
+	{ ATMEL_FW_TYPE_504,      "atmel_at76c504",      "bin" },
+	{ ATMEL_FW_TYPE_504_2958, "atmel_at76c504_2958", "bin" },
+	{ ATMEL_FW_TYPE_504A_2958,"atmel_at76c504a_2958","bin" },
+	{ ATMEL_FW_TYPE_506,      "atmel_at76c506",      "bin" },
+	{ ATMEL_FW_TYPE_NONE,      NULL,                  NULL }
+};
+
 #define MAX_SSID_LENGTH 32
 #define MGMT_JIFFIES (256 * HZ / 100)
 
@@ -458,8 +476,8 @@
 	void *card; /* Bus dependent stucture varies for PCcard */
 	int (*present_callback)(void *); /* And callback which uses it */
 	char firmware_id[32];
-	char firmware_template[32];
-	unsigned char *firmware;
+	AtmelFWType firmware_type;
+	u8 *firmware;
 	int firmware_length;
 	struct timer_list management_timer;
 	struct net_device *dev;
@@ -1293,17 +1311,21 @@
 	if (priv->operating_mode == IW_MODE_INFRA) {
 		if (priv->station_state != STATION_STATE_READY) {
 			priv->wstats.qual.qual = 0;
-			priv->wstats.qual.level	= 0;
+			priv->wstats.qual.level = 0;
+			priv->wstats.qual.updated = (IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID);
 		}
 		priv->wstats.qual.noise = 0;
-		priv->wstats.qual.updated = 7;
+		priv->wstats.qual.updated |= IW_QUAL_NOISE_INVALID;
 	} else {
 		/* Quality levels cannot be determined in ad-hoc mode,
 		   because we can 'hear' more that one remote station. */
 		priv->wstats.qual.qual = 0;
 		priv->wstats.qual.level	= 0;
 		priv->wstats.qual.noise	= 0;
-		priv->wstats.qual.updated = 0;
+		priv->wstats.qual.updated = IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID
+					| IW_QUAL_NOISE_INVALID;
 		priv->wstats.miss.beacon = 0;
 	}
 	
@@ -1482,7 +1504,7 @@
         return len;
 }
 
-struct net_device *init_atmel_card( unsigned short irq, int port, char *firmware_id,  
+struct net_device *init_atmel_card( unsigned short irq, int port, const AtmelFWType fw_type,  
 				    struct device *sys_dev, int (*card_present)(void *), void *card)
 {
 	struct net_device *dev;
@@ -1507,11 +1529,9 @@
 	priv->card = card;
 	priv->firmware = NULL;
 	priv->firmware_id[0] = '\0';
-	priv->firmware_template[0] = '\0';
+	priv->firmware_type = fw_type;
 	if (firmware) /* module parameter */
 		strcpy(priv->firmware_id, firmware);
-	else if (firmware_id) /* from PCMCIA card-matching or PCI */
-		strcpy(priv->firmware_template, firmware_id);
 	priv->bus_type = card_present ? BUS_TYPE_PCCARD : BUS_TYPE_PCI;
 	priv->station_state = STATION_STATE_DOWN;
 	priv->do_rx_crc = 0;
@@ -1579,6 +1599,8 @@
 	dev->irq = irq;
 	dev->base_addr = port;
 	
+	SET_NETDEV_DEV(dev, sys_dev);
+	
 	if ((rc = request_irq(dev->irq, service_interrupt, SA_SHIRQ, dev->name, dev))) {
 		printk(KERN_ERR "%s: register interrupt %d failed, rc %d\n", dev->name, irq, rc );
 		goto err_out_free;
@@ -2218,6 +2240,13 @@
 	range->max_qual.qual = 100;
 	range->max_qual.level = 100;
 	range->max_qual.noise = 0;
+	range->max_qual.updated = IW_QUAL_NOISE_INVALID;
+
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 50;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_NOISE_INVALID;
+
 	range->sensitivity = 0;
 
 	range->bitrate[0] =  1000000;
@@ -2247,9 +2276,6 @@
 	range->r_time_flags = 0;
 	range->min_retry = 1;
 	range->max_retry = 65535;
-	range->avg_qual.qual = 50;
-	range->avg_qual.level = 50;
-	range->avg_qual.noise = 0;
 
 	return 0;
 }
@@ -3025,16 +3051,23 @@
 static void smooth_rssi(struct atmel_private *priv, u8 rssi)
 {
 	u8 old = priv->wstats.qual.level;
+	u8 max_rssi = 42; /* 502-rmfd-revd max by experiment, default for now */
 
-	/* 502-rmfd-revd gives max signal level as 42, by experiment.
-	   This is going to break for other hardware variants. */
+	switch (priv->firmware_type) {
+		case ATMEL_FW_TYPE_502E:
+			max_rssi = 63; /* 502-rmfd-reve max by experiment */
+			break;
+		default:
+			break;
+	}
 
-	rssi = rssi * 100 / 42;
+	rssi = rssi * 100 / max_rssi;
 	if((rssi + old) % 2)
 		priv->wstats.qual.level =  ((rssi + old)/2) + 1;
 	else
 		priv->wstats.qual.level =  ((rssi + old)/2);		
-	
+	priv->wstats.qual.updated |= IW_QUAL_LEVEL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_LEVEL_INVALID;
 }
 
 static void atmel_smooth_qual(struct atmel_private *priv)
@@ -3047,8 +3080,10 @@
 			priv->beacons_this_sec * priv->beacon_period * (priv->wstats.qual.level + 100) / 4000;
 		priv->beacons_this_sec = 0;
 	}
+	priv->wstats.qual.updated |= IW_QUAL_QUAL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_QUAL_INVALID;
 }
-	
+
 /* deals with incoming managment frames. */
 static void atmel_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header, 
 		      u16 frame_len, u8 rssi)
@@ -3611,8 +3646,8 @@
 		const struct firmware *fw_entry = NULL;
 		unsigned char *fw;
 		int len = priv->firmware_length;
-		if (!(fw = priv->firmware)) { 
-			if (strlen(priv->firmware_template) == 0) {	
+		if (!(fw = priv->firmware)) {
+			if (priv->firmware_type == ATMEL_FW_TYPE_NONE) {
 				if (strlen(priv->firmware_id) == 0) {
 					printk(KERN_INFO
 					       "%s: card type is unknown: assuming at76c502 firmware is OK.\n",
@@ -3627,24 +3662,36 @@
 					       "%s: firmware %s is missing, cannot continue.\n", 
 					       dev->name, priv->firmware_id);
 					return 0;
-					
-				} 
+				}
 			} else {
-				int i;
+				int fw_index = 0;
+				int success = 0;
+
+				/* get firmware filename entry based on firmware type ID */
+				while (fw_table[fw_index].fw_type != priv->firmware_type
+						&& fw_table[fw_index].fw_type != ATMEL_FW_TYPE_NONE)
+					fw_index++;
 				
-				for (i = 0; firmware_modifier[i]; i++) {
-					sprintf(priv->firmware_id, priv->firmware_template, firmware_modifier[i]);
-					if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) == 0) 
-						break;
+				/* construct the actual firmware file name */
+				if (fw_table[fw_index].fw_type != ATMEL_FW_TYPE_NONE) {
+					int i;
+					for (i = 0; firmware_modifier[i]; i++) {
+						snprintf(priv->firmware_id, 32, "%s%s.%s", fw_table[fw_index].fw_file,
+							firmware_modifier[i], fw_table[fw_index].fw_file_ext);
+						priv->firmware_id[31] = '\0';
+						if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) == 0) {
+							success = 1;
+							break;
+						}
+					}
 				}
-				if (!firmware_modifier[i]) {
+				if (!success) {
 					printk(KERN_ALERT 
 					       "%s: firmware %s is missing, cannot start.\n", 
 					       dev->name, priv->firmware_id);
 					priv->firmware_id[0] = '\0';
 					return 0;	
 				}
-				priv->firmware_template[0] = '\0';	
 			}
 			
 			fw = fw_entry->data;
diff -Nru a/drivers/net/wireless/atmel.h b/drivers/net/wireless/atmel.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/wireless/atmel.h	2005-03-07 12:09:08 -05:00
@@ -0,0 +1,43 @@
+/*** -*- linux-c -*- **********************************************************
+
+     Driver for Atmel at76c502 at76c504 and at76c506 wireless cards.
+
+         Copyright 2005 Dan Williams and Red Hat, Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This software is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with Atmel wireless lan drivers; if not, write to the Free Software
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+******************************************************************************/
+
+#ifndef _ATMEL_H
+#define _ATMEL_H
+
+typedef enum {
+	ATMEL_FW_TYPE_NONE = 0,
+	ATMEL_FW_TYPE_502,
+	ATMEL_FW_TYPE_502D,
+	ATMEL_FW_TYPE_502E,
+	ATMEL_FW_TYPE_502_3COM,
+	ATMEL_FW_TYPE_504,
+	ATMEL_FW_TYPE_504_2958,
+	ATMEL_FW_TYPE_504A_2958,
+	ATMEL_FW_TYPE_506
+} AtmelFWType;
+
+struct net_device *init_atmel_card(unsigned short, int, const AtmelFWType, struct device *, 
+				    int (*present_func)(void *), void * );
+void stop_atmel_card( struct net_device *, int );
+int atmel_open( struct net_device * );
+
+#endif
diff -Nru a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
--- a/drivers/net/wireless/atmel_cs.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/wireless/atmel_cs.c	2005-03-07 12:09:08 -05:00
@@ -55,6 +55,7 @@
 #include <asm/system.h>
 #include <linux/wireless.h>
 
+#include "atmel.h"
 
 /*
    All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
@@ -90,11 +91,6 @@
    event handler. 
 */
 
-struct net_device *init_atmel_card(int, int, char *, struct device *, 
-				    int (*present_func)(void *), void * );
-void stop_atmel_card( struct net_device *, int );
-int atmel_open( struct net_device * );
-
 static void atmel_config(dev_link_t *link);
 static void atmel_release(dev_link_t *link);
 static int atmel_event(event_t event, int priority,
@@ -307,28 +303,29 @@
 static struct { 
 	int manf, card;
 	char *ver1;
-	char *firmware;
+	AtmelFWType firmware;
 	char *name;
 } card_table[] = {
-	{ 0, 0, "WLAN/802.11b PC CARD", "atmel_at76c502d%s.bin", "Actiontec 802CAT1" },  
-	{ 0, 0, "ATMEL/AT76C502AR", "atmel_at76c502%s.bin", "NoName-RFMD" }, 
-	{ 0, 0, "ATMEL/AT76C502AR_D", "atmel_at76c502d%s.bin", "NoName-revD" }, 
-	{ 0, 0, "ATMEL/AT76C502AR_E", "atmel_at76c502e%s.bin", "NoName-revE" },
-	{ 0, 0, "ATMEL/AT76C504", "atmel_at76c504%s.bin", "NoName-504" },
-	{ 0, 0, "ATMEL/AT76C504A", "atmel_at76c504a_2958%s.bin", "NoName-504a-2958" },
-	{ 0, 0, "ATMEL/AT76C504_R", "atmel_at76c504_2958%s.bin", "NoName-504-2958" },
-	{ MANFID_3COM, 0x0620, NULL, "atmel_at76c502_3com%s.bin", "3com 3CRWE62092B" }, 
-	{ MANFID_3COM, 0x0696, NULL, "atmel_at76c502_3com%s.bin", "3com 3CRSHPW196" }, 
-	{ 0, 0, "SMC/2632W-V2", "atmel_at76c502%s.bin", "SMC 2632W-V2" },
-        { 0, 0, "SMC/2632W", "atmel_at76c502d%s.bin", "SMC 2632W-V3" },
-	{ 0xd601, 0x0007, NULL, "atmel_at76c502%s.bin", "Sitecom WLAN-011" }, 
-	{ 0x01bf, 0x3302, NULL, "atmel_at76c502e%s.bin", "Belkin F5D6020-V2" }, 
-	{ 0, 0, "BT/Voyager 1020 Laptop Adapter", "atmel_at76c502%s.bin", "BT Voyager 1020" },
-        { 0, 0, "IEEE 802.11b/Wireless LAN PC Card", "atmel_at76c502%s.bin", "Siemens Gigaset PC Card II" },
-	{ 0, 0, "CNet/CNWLC 11Mbps Wireless PC Card V-5", "atmel_at76c502e%s.bin", "CNet CNWLC-811ARL" },
-	{ 0, 0, "Wireless/PC_CARD", "atmel_at76c502d%s.bin", "Planet WL-3552" },
-	{ 0, 0, "OEM/11Mbps Wireless LAN PC Card V-3", "atmel_at76c502%s.bin", "OEM 11Mbps WLAN PCMCIA Card" },
-	{ 0, 0, "11WAVE/11WP611AL-E", "atmel_at76c502e%s.bin", "11WAVE WaveBuddy" } 
+	{ 0, 0, "WLAN/802.11b PC CARD", ATMEL_FW_TYPE_502D, "Actiontec 802CAT1" },  
+	{ 0, 0, "ATMEL/AT76C502AR", ATMEL_FW_TYPE_502, "NoName-RFMD" }, 
+	{ 0, 0, "ATMEL/AT76C502AR_D", ATMEL_FW_TYPE_502D, "NoName-revD" }, 
+	{ 0, 0, "ATMEL/AT76C502AR_E", ATMEL_FW_TYPE_502E, "NoName-revE" },
+	{ 0, 0, "ATMEL/AT76C504", ATMEL_FW_TYPE_504, "NoName-504" },
+	{ 0, 0, "ATMEL/AT76C504A", ATMEL_FW_TYPE_504A_2958, "NoName-504a-2958" },
+	{ 0, 0, "ATMEL/AT76C504_R", ATMEL_FW_TYPE_504_2958, "NoName-504-2958" },
+	{ MANFID_3COM, 0x0620, NULL, ATMEL_FW_TYPE_502_3COM, "3com 3CRWE62092B" }, 
+	{ MANFID_3COM, 0x0696, NULL, ATMEL_FW_TYPE_502_3COM, "3com 3CRSHPW196" }, 
+	{ 0, 0, "SMC/2632W-V2", ATMEL_FW_TYPE_502, "SMC 2632W-V2" },
+	{ 0, 0, "SMC/2632W", ATMEL_FW_TYPE_502D, "SMC 2632W-V3" },
+	{ 0xd601, 0x0007, NULL, ATMEL_FW_TYPE_502, "Sitecom WLAN-011" }, 
+	{ 0x01bf, 0x3302, NULL, ATMEL_FW_TYPE_502E, "Belkin F5D6020-V2" }, 
+	{ 0, 0, "BT/Voyager 1020 Laptop Adapter", ATMEL_FW_TYPE_502, "BT Voyager 1020" },
+	{ 0, 0, "IEEE 802.11b/Wireless LAN PC Card", ATMEL_FW_TYPE_502, "Siemens Gigaset PC Card II" },
+	{ 0, 0, "CNet/CNWLC 11Mbps Wireless PC Card V-5", ATMEL_FW_TYPE_502E, "CNet CNWLC-811ARL" },
+	{ 0, 0, "Wireless/PC_CARD", ATMEL_FW_TYPE_502D, "Planet WL-3552" },
+	{ 0, 0, "OEM/11Mbps Wireless LAN PC Card V-3", ATMEL_FW_TYPE_502, "OEM 11Mbps WLAN PCMCIA Card" },
+	{ 0, 0, "11WAVE/11WP611AL-E", ATMEL_FW_TYPE_502E, "11WAVE WaveBuddy" },
+	{ 0, 0, "LG/LW2100N", ATMEL_FW_TYPE_502E, "LG LW2100N 11Mbps WLAN PCMCIA Card" },
 };
 
 static void atmel_config(dev_link_t *link)
@@ -520,7 +517,7 @@
 	((local_info_t*)link->priv)->eth_dev = 
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
-				card_index == -1 ? NULL :  card_table[card_index].firmware,
+				card_index == -1 ? ATMEL_FW_TYPE_NONE :  card_table[card_index].firmware,
 				&handle_to_dev(handle),
 				card_present, 
 				link);
diff -Nru a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
--- a/drivers/net/wireless/atmel_pci.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/wireless/atmel_pci.c	2005-03-07 12:09:08 -05:00
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
+#include "atmel.h"
 
 MODULE_AUTHOR("Simon Kelley");
 MODULE_DESCRIPTION("Support for Atmel at76c50x 802.11 wireless ethernet cards.");
@@ -40,9 +41,6 @@
 
 static int atmel_pci_probe(struct pci_dev *, const struct pci_device_id *);
 static void atmel_pci_remove(struct pci_dev *);
-struct net_device *init_atmel_card(int, int, char *, struct device *, 
-				   int (*present_func)(void *), void * );
-void stop_atmel_card( struct net_device *, int );
 
 static struct pci_driver atmel_driver = {
 	.name     = "atmel",
@@ -63,7 +61,7 @@
 	pci_set_master(pdev);
 	
 	dev = init_atmel_card(pdev->irq, pdev->resource[1].start, 
-			      "atmel_at76c506%s.bin",
+			      ATMEL_FW_TYPE_506,
 			      &pdev->dev, NULL, NULL);
 	if (!dev)
 		return -ENODEV;
diff -Nru a/drivers/net/wireless/prism54/isl_38xx.c b/drivers/net/wireless/prism54/isl_38xx.c
--- a/drivers/net/wireless/prism54/isl_38xx.c	2005-03-07 12:09:08 -05:00
+++ b/drivers/net/wireless/prism54/isl_38xx.c	2005-03-07 12:09:08 -05:00
@@ -125,11 +125,11 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		do_gettimeofday(&current_time);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
-		      current_time.tv_sec, current_time.tv_usec);
+		      current_time.tv_sec, (long)current_time.tv_usec);
 #endif
 
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, current_time.tv_usec,
+		      current_time.tv_sec, (long)current_time.tv_usec,
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
 
@@ -139,7 +139,7 @@
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register abadface\n",
-			      current_time.tv_sec, current_time.tv_usec);
+			      current_time.tv_sec, (long)current_time.tv_usec);
 #endif
 			/* read the Device Status Register until Sleepmode bit is set */
 			while (reg = readl(device_base + ISL38XX_CTRL_STAT_REG),
@@ -150,7 +150,7 @@
 
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register read %08x\n",
-			      current_time.tv_sec, current_time.tv_usec,
+			      current_time.tv_sec, (long)current_time.tv_usec,
 			      readl(device_base + ISL38XX_CTRL_STAT_REG));
 			udelay(ISL38XX_WRITEIO_DELAY);
 
@@ -158,7 +158,7 @@
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device asleep counter %i\n",
-			      current_time.tv_sec, current_time.tv_usec,
+			      current_time.tv_sec, (long)current_time.tv_usec,
 			      counter);
 #endif
 		}
@@ -174,7 +174,7 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		do_gettimeofday(&current_time);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, current_time.tv_usec, reg);
+		      current_time.tv_sec, (long)current_time.tv_usec, reg);
 #endif
 	} else {
 		/* device is (still) awake  */
diff -Nru a/include/linux/mii.h b/include/linux/mii.h
--- a/include/linux/mii.h	2005-03-07 12:09:08 -05:00
+++ b/include/linux/mii.h	2005-03-07 12:09:08 -05:00
@@ -20,6 +20,8 @@
 #define MII_ADVERTISE       0x04        /* Advertisement control reg   */
 #define MII_LPA             0x05        /* Link partner ability reg    */
 #define MII_EXPANSION       0x06        /* Expansion register          */
+#define MII_CTRL1000        0x09        /* 1000BASE-T control          */
+#define MII_STAT1000        0x0a        /* 1000BASE-T status           */
 #define MII_DCOUNTER        0x12        /* Disconnect counter          */
 #define MII_FCSCOUNTER      0x13        /* False carrier counter       */
 #define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
@@ -67,7 +69,9 @@
 #define ADVERTISE_100HALF       0x0080  /* Try for 100mbps half-duplex */
 #define ADVERTISE_100FULL       0x0100  /* Try for 100mbps full-duplex */
 #define ADVERTISE_100BASE4      0x0200  /* Try for 100mbps 4k packets  */
-#define ADVERTISE_RESV          0x1c00  /* Unused...                   */
+#define ADVERTISE_PAUSE_CAP     0x0400  /* Try for pause               */
+#define ADVERTISE_PAUSE_ASYM    0x0800  /* Try for asymetric pause     */
+#define ADVERTISE_RESV          0x1000  /* Unused...                   */
 #define ADVERTISE_RFAULT        0x2000  /* Say we can detect faults    */
 #define ADVERTISE_LPACK         0x4000  /* Ack link partners response  */
 #define ADVERTISE_NPAGE         0x8000  /* Next page bit               */
@@ -84,7 +88,9 @@
 #define LPA_100HALF             0x0080  /* Can do 100mbps half-duplex  */
 #define LPA_100FULL             0x0100  /* Can do 100mbps full-duplex  */
 #define LPA_100BASE4            0x0200  /* Can do 100mbps 4k packets   */
-#define LPA_RESV                0x1c00  /* Unused...                   */
+#define LPA_PAUSE_CAP           0x0400  /* Can pause                   */
+#define LPA_PAUSE_ASYM          0x0800  /* Can pause asymetrically     */
+#define LPA_RESV                0x1000  /* Unused...                   */
 #define LPA_RFAULT              0x2000  /* Link partner faulted        */
 #define LPA_LPACK               0x4000  /* Link partner acked us       */
 #define LPA_NPAGE               0x8000  /* Next page bit               */
@@ -105,6 +111,15 @@
 #define NWAYTEST_LOOPBACK       0x0100  /* Enable loopback for N-way   */
 #define NWAYTEST_RESV2          0xfe00  /* Unused...                   */
 
+/* 1000BASE-T Control register */
+#define ADVERTISE_1000FULL      0x0200  /* Advertise 1000BASE-T full duplex */
+#define ADVERTISE_1000HALF      0x0100  /* Advertise 1000BASE-T half duplex */
+
+/* 1000BASE-T Status register */
+#define LPA_1000LOCALRXOK       0x2000  /* Link partner local receiver status */
+#define LPA_1000REMRXOK         0x1000  /* Link partner remote receiver status */
+#define LPA_1000FULL            0x0800  /* Link partner 1000BASE-T full duplex */
+#define LPA_1000HALF            0x0400  /* Link partner 1000BASE-T half duplex */
 
 struct mii_if_info {
 	int phy_id;
@@ -114,6 +129,7 @@
 
 	unsigned int full_duplex : 1;	/* is full duplex? */
 	unsigned int force_media : 1;	/* is autoneg. disabled? */
+	unsigned int supports_gmii : 1; /* are GMII registers supported? */
 
 	struct net_device *dev;
 	int (*mdio_read) (struct net_device *dev, int phy_id, int location);
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2005-03-07 12:09:08 -05:00
+++ b/include/linux/netdevice.h	2005-03-07 12:09:08 -05:00
@@ -678,6 +678,8 @@
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, char *);
 extern int		dev_set_mtu(struct net_device *, int);
+extern int		dev_set_mac_address(struct net_device *,
+					    struct sockaddr *);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern void		dev_init(void);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2005-03-07 12:09:08 -05:00
+++ b/net/core/dev.c	2005-03-07 12:09:08 -05:00
@@ -2300,6 +2300,21 @@
 	return err;
 }
 
+int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
+{
+	int err;
+
+	if (!dev->set_mac_address)
+		return -EOPNOTSUPP;
+	if (sa->sa_family != dev->type)
+		return -EINVAL;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+	err = dev->set_mac_address(dev, sa);
+	if (!err)
+		notifier_call_chain(&netdev_chain, NETDEV_CHANGEADDR, dev);
+	return err;
+}
 
 /*
  *	Perform the SIOCxIFxxx calls.
@@ -2346,17 +2361,7 @@
 			return 0;
 
 		case SIOCSIFHWADDR:
-			if (!dev->set_mac_address)
-				return -EOPNOTSUPP;
-			if (ifr->ifr_hwaddr.sa_family != dev->type)
-				return -EINVAL;
-			if (!netif_device_present(dev))
-				return -ENODEV;
-			err = dev->set_mac_address(dev, &ifr->ifr_hwaddr);
-			if (!err)
-				notifier_call_chain(&netdev_chain,
-						    NETDEV_CHANGEADDR, dev);
-			return err;
+			return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
 		case SIOCSIFHWBROADCAST:
 			if (ifr->ifr_hwaddr.sa_family != dev->type)
@@ -3322,6 +3327,7 @@
 EXPORT_SYMBOL(dev_set_promiscuity);
 EXPORT_SYMBOL(dev_change_flags);
 EXPORT_SYMBOL(dev_set_mtu);
+EXPORT_SYMBOL(dev_set_mac_address);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);

--------------010006070602020702040406--
