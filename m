From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 5/5] bonding: Update/rewrite bonding.txt
Date: Fri, 11 Feb 2005 01:18:41 -0800
Message-ID: <200502110918.j1B9If7r003696@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	This is a complete overhaul of the bonding.txt documentation.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

--- linux-2611-rc3/Documentation/networking/bonding.txt	2004-04-05 11:55:06.000000000 -0700
+++ linux-2611-rc3-docupdate/Documentation/networking/bonding.txt	2005-02-11 01:44:37.000000000 -0800
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
