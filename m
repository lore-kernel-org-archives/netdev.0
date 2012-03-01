From: "Christoph J. Thompson" <cjsthompson@gmail.com>
Subject: [PATCH 3/4] iproute2 - Split up manual page installation. Generate
 manual pages based on where the config files are installed. Add missing
 manual pages for utilities which are links to other binaries. Make
 tc-pfifo.8 a real file that points to tc-bfifo.8 instead of symlink which
 causes problems with compressing manual pages.
Date: Thu, 1 Mar 2012 17:45:45 +0100
Message-ID: <20120301164541.GA24289@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39450 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757734Ab2CAQpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 11:45:40 -0500
Received: by mail-wi0-f174.google.com with SMTP id hm2so53632wib.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 08:45:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	modified:   Makefile
	new file:   man/Makefile
	new file:   man/man3/Makefile
	new file:   man/man8/Makefile
	new file:   man/man8/ctstat.8
	new file:   man/man8/ip-address.8.in
	new file:   man/man8/ip-link.8.in
	new file:   man/man8/ip-route.8.in
	new file:   man/man8/nstat.8
	new file:   man/man8/routef.8
	new file:   man/man8/rtstat.8
	typechange: man/man8/tc-pfifo.8

Signed-off-by: Christoph J. Thompson <cjsthompson@gmail.com>
---
 Makefile                 |   13 +-
 man/Makefile             |   20 ++
 man/man3/Makefile        |   13 +
 man/man8/Makefile        |   29 ++
 man/man8/ctstat.8        |    1 +
 man/man8/ip-address.8.in |  240 +++++++++++++++
 man/man8/ip-link.8.in    |  374 +++++++++++++++++++++++
 man/man8/ip-route.8.in   |  744 ++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/nstat.8         |    1 +
 man/man8/routef.8        |    1 +
 man/man8/rtstat.8        |    1 +
 man/man8/tc-pfifo.8      |    2 +-
 12 files changed, 1426 insertions(+), 13 deletions(-)
 create mode 100644 man/Makefile
 create mode 100644 man/man3/Makefile
 create mode 100644 man/man8/Makefile
 create mode 100644 man/man8/ctstat.8
 create mode 100644 man/man8/ip-address.8.in
 create mode 100644 man/man8/ip-link.8.in
 create mode 100644 man/man8/ip-route.8.in
 create mode 100644 man/man8/nstat.8
 create mode 100644 man/man8/routef.8
 create mode 100644 man/man8/rtstat.8
 mode change 120000 => 100644 man/man8/tc-pfifo.8

diff --git a/Makefile b/Makefile
index 014d497..fb5f5d3 100644
--- a/Makefile
+++ b/Makefile
@@ -35,7 +35,7 @@ WFLAGS = -Wall -Wstrict-prototypes
 CFLAGS = $(WFLAGS) $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc misc netem genl
+SUBDIRS=lib ip tc misc netem genl man
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
@@ -60,17 +60,6 @@ install: all
 		$(DESTDIR)$(DOCDIR)/examples/diffserv
 	@for i in $(SUBDIRS) doc; do $(MAKE) -C $$i install; done
 	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
-	install -m 0755 -d $(DESTDIR)$(MANDIR)/man8
-	install -m 0644 $(shell find man/man8 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man8
-	install -m 0755 -d $(DESTDIR)$(MANDIR)/man7
-	install -m 0644 $(shell find man/man7 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man7
-	ln -sf tc-bfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
-	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/rtstat.8
-	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/ctstat.8
-	ln -sf rtacct.8  $(DESTDIR)$(MANDIR)/man8/nstat.8
-	ln -sf routel.8  $(DESTDIR)$(MANDIR)/man8/routef.8
-	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
-	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
 
 snapshot:
 	echo "static const char SNAPSHOT[] = \""`date +%y%m%d`"\";" \
diff --git a/man/Makefile b/man/Makefile
new file mode 100644
index 0000000..67fea05
--- /dev/null
+++ b/man/Makefile
@@ -0,0 +1,20 @@
+INSTALL=install
+INSTALLDIR=install -m 0755 -d
+INSTALLMAN=install -m 0644
+
+SUBDIRS = man3 man8
+
+all:
+	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir; done
+
+distclean: clean
+
+clean:
+	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir clean; done
+
+install:
+	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir install; done
+
+.PHONY: install clean distclean
+
+.EXPORT_ALL_VARIABLES:
diff --git a/man/man3/Makefile b/man/man3/Makefile
new file mode 100644
index 0000000..bf55658
--- /dev/null
+++ b/man/man3/Makefile
@@ -0,0 +1,13 @@
+MAN3PAGES=libnetlink.3
+
+all:
+
+distclean: clean
+
+clean:
+
+install:
+	$(INSTALLDIR) $(DESTDIR)$(MANDIR)/man3
+	$(INSTALLMAN) $(MAN3PAGES) $(DESTDIR)$(MANDIR)/man3
+
+.PHONY: install clean distclean
diff --git a/man/man8/Makefile b/man/man8/Makefile
new file mode 100644
index 0000000..ade1d17
--- /dev/null
+++ b/man/man8/Makefile
@@ -0,0 +1,29 @@
+TARGETS = ip-address.8 ip-link.8 ip-route.8
+
+MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
+	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
+	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
+	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8
+
+all: $(TARGETS)
+
+ip-address.8: ip-address.8.in
+	sed "s|@SYSCONFDIR@|$(CONFDIR)|g" $< > $@
+
+ip-link.8: ip-link.8.in
+	sed "s|@SYSCONFDIR@|$(CONFDIR)|g" $< > $@
+
+ip-route.8: ip-route.8.in
+	sed "s|@SYSCONFDIR@|$(CONFDIR)|g" $< > $@
+
+distclean: clean
+
+clean:
+	@rm -f $(TARGETS)
+
+install:
+	$(INSTALLDIR) $(DESTDIR)$(MANDIR)/man8
+	$(INSTALLMAN) $(MAN8PAGES) $(DESTDIR)$(MANDIR)/man8
+
+.PHONY: install clean distclean
+
diff --git a/man/man8/ctstat.8 b/man/man8/ctstat.8
new file mode 100644
index 0000000..080e2b2
--- /dev/null
+++ b/man/man8/ctstat.8
@@ -0,0 +1 @@
+.so man8/lnstat.8
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
new file mode 100644
index 0000000..63bf9cb
--- /dev/null
+++ b/man/man8/ip-address.8.in
@@ -0,0 +1,240 @@
+.TH "IP\-ADDRESS" 8 "20 Dec 2011" "iproute2" "Linux"
+.SH "NAME"
+ip-address \- protocol address management
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.RI "[ " OPTIONS " ]"
+.B address
+.RI " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.BR "ip address" " { " add " | " del " } "
+.IB IFADDR " dev " STRING
+
+.ti -8
+.BR "ip address" " { " show " | " flush " } [ " dev
+.IR STRING " ] [ "
+.B  scope
+.IR SCOPE-ID " ] [ "
+.B  to
+.IR PREFIX " ] [ " FLAG-LIST " ] [ "
+.B  label
+.IR PATTERN " ]"
+
+.ti -8
+.IR IFADDR " := " PREFIX " | " ADDR
+.B  peer
+.IR PREFIX " [ "
+.B  broadcast
+.IR ADDR " ] [ "
+.B  anycast
+.IR ADDR " ] [ "
+.B  label
+.IR STRING " ] [ "
+.B  scope
+.IR SCOPE-ID " ]"
+
+.ti -8
+.IR SCOPE-ID " := "
+.RB "[ " host " | " link " | " global " | "
+.IR NUMBER " ]"
+
+.ti -8
+.IR FLAG-LIST " := [ "  FLAG-LIST " ] " FLAG
+
+.ti -8
+.IR FLAG " := "
+.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
+tentative " | " deprecated " | " dadfailed " | " temporary " ]"
+
+.SH "DESCRIPTION"
+The
+.B address
+is a protocol (IP or IPv6) address attached
+to a network device.  Each device must have at least one address
+to use the corresponding protocol.  It is possible to have several
+different addresses attached to one device.  These addresses are not
+discriminated, so that the term
+.B alias
+is not quite appropriate for them and we do not use it in this document.
+.sp
+The
+.B ip address
+command displays addresses and their properties, adds new addresses
+and deletes old ones.
+
+.SS ip address add - add new protocol address.
+
+.TP
+.BI dev " NAME"
+the name of the device to add the address to.
+
+.TP
+.BI local " ADDRESS " (default)
+the address of the interface. The format of the address depends
+on the protocol. It is a dotted quad for IP and a sequence of
+hexadecimal halfwords separated by colons for IPv6.  The
+.I ADDRESS
+may be followed by a slash and a decimal number which encodes
+the network prefix length.
+
+.TP
+.BI peer " ADDRESS"
+the address of the remote endpoint for pointopoint interfaces.
+Again, the
+.I ADDRESS
+may be followed by a slash and a decimal number, encoding the network
+prefix length.  If a peer address is specified, the local address
+cannot have a prefix length.  The network prefix is associated
+with the peer rather than with the local address.
+
+.TP
+.BI broadcast " ADDRESS"
+the broadcast address on the interface.
+.sp
+It is possible to use the special symbols
+.B '+'
+and
+.B '-'
+instead of the broadcast address.  In this case, the broadcast address
+is derived by setting/resetting the host bits of the interface prefix.
+
+.TP
+.BI label " NAME"
+Each address may be tagged with a label string.
+In order to preserve compatibility with Linux-2.0 net aliases,
+this string must coincide with the name of the device or must be prefixed
+with the device name followed by colon.
+
+.TP
+.BI scope " SCOPE_VALUE"
+the scope of the area where this address is valid.
+The available scopes are listed in file
+.BR "@SYSCONFDIR@/rt_scopes" .
+Predefined scope values are:
+
+.in +8
+.B global
+- the address is globally valid.
+.sp
+.B site
+- (IPv6 only) the address is site local, i.e. it is
+valid inside this site.
+.sp
+.B link
+- the address is link local, i.e. it is valid only on this device.
+.sp
+.B host
+- the address is valid only inside this host.
+.in -8
+
+.SS ip address delete - delete protocol address
+.B Arguments:
+coincide with the arguments of
+.B ip addr add.
+The device name is a required argument.  The rest are optional.
+If no arguments are given, the first address is deleted.
+
+.SS ip address show - look at protocol addresses
+
+.TP
+.BI dev " NAME " (default)
+name of device.
+
+.TP
+.BI scope " SCOPE_VAL"
+only list addresses with this scope.
+
+.TP
+.BI to " PREFIX"
+only list addresses matching this prefix.
+
+.TP
+.BI label " PATTERN"
+only list addresses with labels matching the
+.IR "PATTERN" .
+.I PATTERN
+is a usual shell style pattern.
+
+.TP
+.BR dynamic " and " permanent
+(IPv6 only) only list addresses installed due to stateless
+address configuration or only list permanent (not dynamic)
+addresses.
+
+.TP
+.B tentative
+(IPv6 only) only list addresses which have not yet passed duplicate
+address detection.
+
+.TP
+.B deprecated
+(IPv6 only) only list deprecated addresses.
+
+.TP
+.B dadfailed
+(IPv6 only) only list addresses which have failed duplicate
+address detection.
+
+.TP
+.B temporary
+(IPv6 only) only list temporary addresses.
+
+.TP
+.BR primary " and " secondary
+only list primary (or secondary) addresses.
+
+.SS ip address flush - flush protocol addresses
+This command flushes the protocol addresses selected by some criteria.
+
+.PP
+This command has the same arguments as
+.B show.
+The difference is that it does not run when no arguments are given.
+
+.PP
+.B Warning:
+This command (and other
+.B flush
+commands described below) is pretty dangerous.  If you make a mistake,
+it will not forgive it, but will cruelly purge all the addresses.
+
+.PP
+With the
+.B -statistics
+option, the command becomes verbose. It prints out the number of deleted
+addresses and the number of rounds made to flush the address list.  If
+this option is given twice,
+.B ip address flush
+also dumps all the deleted addresses in the format described in the
+previous subsection.
+
+.SH "EXAMPLES"
+.PP
+ip address show dev eth0
+.RS 4
+Shows the addresses assigned to network interface eth0
+.RE
+.PP
+ip addr add 2001:0db8:85a3::0370:7334/64 dev eth1
+.RS 4
+Adds an IPv6 address to network interface eth1
+.RE
+.PP
+ip addr flush dev eth4
+.RS 4
+Removes all addresses from device eth4
+.RE
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Original Manpage by Michail Litvak <mci@owl.openwall.com>
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
new file mode 100644
index 0000000..3e21e42
--- /dev/null
+++ b/man/man8/ip-link.8.in
@@ -0,0 +1,374 @@
+.TH IP\-LINK 8 "20 Dec 2011" "iproute2" "Linux"
+.SH "NAME"
+ip-link \- network device configuration
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.RI "[ " OPTIONS " ]"
+.B link
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+\fB\-s\fR[\fItatistics\fR] |
+\fB\-r\fR[\fIesolve\fR] |
+\fB\-f\fR[\fIamily\fR] {
+.BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
+\fB\-o\fR[\fIneline\fR] }
+
+.ti -8
+.BI "ip link add link " DEVICE
+.RB "[ " name " ]"
+.I NAME
+.br
+.RB "[ " txqueuelen 
+.IR PACKETS " ]"
+.br
+.RB "[ " address
+.IR LLADDR " ]"
+.RB "[ " broadcast
+.IR LLADDR " ]"
+.br
+.RB "[ " mtu
+.IR MTU " ]"
+.br
+.BR type " TYPE"
+.RI "[ " ARGS " ]"
+
+.ti -8
+.IR TYPE " := [ "
+.BR vlan " | " veth " | " vcan " | " dummy " | " ifb " | " macvlan " | " can " | " bridge " ]"
+
+.ti -8
+.BI "ip link delete " DEVICE
+.BI type " TYPE"
+.RI "[ " ARGS " ]"
+
+.ti -8
+.BR "ip link set " {
+.IR DEVICE " | "
+.BI "group " GROUP
+.RB "} { " up " | " down " | " arp " { " on " | " off " } |"
+.br
+.BR promisc " { " on " | " off " } |"
+.br
+.BR allmulticast " { " on " | " off " } |"
+.br
+.BR dynamic " { " on " | " off " } |"
+.br
+.BR multicast " { " on " | " off " } |"
+.br
+.B  txqueuelen
+.IR PACKETS " |"
+.br
+.B  name
+.IR NEWNAME " |"
+.br
+.B  address
+.IR LLADDR " |"
+.B  broadcast
+.IR LLADDR " |"
+.br
+.B  mtu
+.IR MTU " |"
+.br
+.B  netns
+.IR PID " |"
+.br
+.B  netns
+.IR NETNSNAME " |"
+.br
+.B alias
+.IR NAME  " |"
+.br
+.B vf
+.IR NUM " ["
+.B  mac
+.IR LLADDR " ] ["
+.B vlan
+.IR VLANID " [ "
+.B qos
+.IR VLAN-QOS " ] ] ["
+.B rate
+.IR TXRATE " ] ["
+.B spoofchk { on | off }
+] |
+.br
+.B master
+.IR DEVICE
+.br
+.B nomaster
+.BR " }"
+
+
+.ti -8
+.B ip link show
+.RI "[ " DEVICE " | "
+.B group
+.IR GROUP " ]"
+
+.SH "DESCRIPTION"
+.SS ip link add - add virtual link
+
+.TP
+.BI link " DEVICE "
+specifies the physical device to act operate on.
+
+.I NAME
+specifies the name of the new virtual device.
+
+.I TYPE
+specifies the type of the new device.
+.sp
+Link types:
+
+.in +8
+.B vlan
+- 802.1q tagged virtual LAN interface
+.sp
+.B veth
+- Virtual ethernet interface
+.sp
+.B vcan
+- Virtual Local CAN interface
+.sp
+.B dummy
+- Dummy network interface
+.sp
+.B ifb
+- Intermediate Functional Block device
+.sp
+.B macvlan
+- virtual interface base on link layer address (MAC)
+.sp
+.B can
+- Controller Area Network interface
+.sp
+.B bridge
+- Ethernet Bridge device
+.in -8
+
+.SS ip link delete - delete virtual link
+.I DEVICE
+specifies the virtual  device to act operate on.
+.I TYPE
+specifies the type of the device.
+
+
+.TP
+.BI dev " DEVICE "
+specifies the physical device to act operate on.
+
+.SS ip link set - change device attributes
+
+.TP
+.BI dev " DEVICE "
+.I DEVICE
+specifies network device to operate on. When configuring SR-IOV Virtual Fuction
+(VF) devices, this keyword should specify the associated Physical Function (PF)
+device.
+
+.TP
+.BI group " GROUP "
+.I GROUP
+has a dual role: If both group and dev are present, then move the device to the
+specified group.  If only a group is specified, then the command operates on
+all devices in that group.
+
+.TP
+.BR up " and " down
+change the state of the device to
+.B UP
+or
+.BR "DOWN" .
+
+.TP
+.BR "arp on " or " arp off"
+change the
+.B NOARP
+flag on the device.
+
+.TP
+.BR "multicast on " or " multicast off"
+change the
+.B MULTICAST
+flag on the device.
+
+.TP
+.BR "dynamic on " or " dynamic off"
+change the
+.B DYNAMIC
+flag on the device.
+
+.TP
+.BI name " NAME"
+change the name of the device.  This operation is not
+recommended if the device is running or has some addresses
+already configured.
+
+.TP
+.BI txqueuelen " NUMBER"
+.TP
+.BI txqlen " NUMBER"
+change the transmit queue length of the device.
+
+.TP
+.BI mtu " NUMBER"
+change the
+.I MTU
+of the device.
+
+.TP
+.BI address " LLADDRESS"
+change the station address of the interface.
+
+.TP
+.BI broadcast " LLADDRESS"
+.TP
+.BI brd " LLADDRESS"
+.TP
+.BI peer " LLADDRESS"
+change the link layer broadcast address or the peer address when
+the interface is
+.IR "POINTOPOINT" .
+
+.TP
+.BI netns " PID"
+move the device to the network namespace associated with the process
+.IR "PID".
+
+.TP
+.BI netns " NETNSNAME"
+move the device to the network namespace associated with name
+.IR "NETNSNAME".
+
+.TP
+.BI alias " NAME"
+give the device a symbolic name for easy reference.
+
+.TP
+.BI group " GROUP"
+specify the group the device belongs to.
+The available groups are listed in file
+.BR "@SYSCONFDIR@/group" .
+
+.TP
+.BI vf " NUM"
+specify a Virtual Function device to be configured. The associated PF device
+must be specified using the
+.B dev
+parameter.
+
+.in +8
+.BI mac " LLADDRESS"
+- change the station address for the specified VF. The
+.B vf
+parameter must be specified.
+
+.sp
+.BI vlan " VLANID"
+- change the assigned VLAN for the specified VF. When specified, all traffic
+sent from the VF will be tagged with the specified VLAN ID. Incoming traffic
+will be filtered for the specified VLAN ID, and will have all VLAN tags
+stripped before being passed to the VF. Setting this parameter to 0 disables
+VLAN tagging and filtering. The
+.B vf
+parameter must be specified.
+
+.sp
+.BI qos " VLAN-QOS"
+- assign VLAN QOS (priority) bits for the VLAN tag. When specified, all VLAN
+tags transmitted by the VF will include the specified priority bits in the
+VLAN tag. If not specified, the value is assumed to be 0. Both the
+.B vf
+and
+.B vlan
+parameters must be specified. Setting both
+.B vlan
+and
+.B qos
+as 0 disables VLAN tagging and filtering for the VF.
+
+.sp
+.BI rate " TXRATE"
+- change the allowed transmit bandwidth, in Mbps, for the specified VF.
+Setting this parameter to 0 disables rate limiting. The
+.B vf
+parameter must be specified.
+
+.sp
+.BI spoofchk " on|off"
+- turn packet spoof checking on or off for the specified VF.
+.in -8
+
+.TP
+.BI master " DEVICE"
+set master device of the device (enslave device).
+
+.TP
+.BI nomaster
+unset master device of the device (release device).
+
+.PP
+.B Warning:
+If multiple parameter changes are requested,
+.B ip
+aborts immediately after any of the changes have failed.
+This is the only case when
+.B ip
+can move the system to an unpredictable state.  The solution
+is to avoid changing several parameters with one
+.B ip link set
+call.
+
+.SS  ip link show - display device attributes
+
+.TP
+.BI dev " NAME " (default)
+.I NAME
+specifies the network device to show.
+If this argument is omitted all devices in the default group are listed.
+
+.TP
+.BI group " GROUP "
+.I GROUP
+specifies what group of devices to show.
+
+.TP
+.B up
+only display running interfaces.
+
+.SH "EXAMPLES"
+.PP
+ip link show
+.RS 4
+Shows the state of all network interfaces on the system.
+.RE
+.PP
+ip link set dev ppp0 mtu 1400
+.RS 4
+Change the MTU the ppp0 device.
+.RE
+.PP
+ip link add link eth0 name eth0.10 type vlan id 10
+.RS 4
+Creates a new vlan device eth0.10 on device eth0.
+.RE
+.PP
+ip link delete dev eth0.10
+.RS 4
+Removes vlan device.
+.RE
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Original Manpage by Michail Litvak <mci@owl.openwall.com>
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
new file mode 100644
index 0000000..8960e4d
--- /dev/null
+++ b/man/man8/ip-route.8.in
@@ -0,0 +1,744 @@
+.TH IP\-ROUTE 8 "20 Dec 2011" "iproute2" "Linux"
+.SH "NAME"
+ip-route \- routing table management
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.RI "[ " OPTIONS " ]" 
+.B route 
+.RI " { " COMMAND " | "
+.BR help " }"
+.sp
+.ti -8
+
+.ti -8
+.BR "ip route" " { "
+.BR list " | " flush " } "
+.I  SELECTOR
+
+.ti -8
+.BR "ip route save"
+.I SELECTOR
+
+.ti -8
+.BR "ip route restore"
+
+.ti -8
+.B  ip route get
+.IR ADDRESS " [ "
+.BI from " ADDRESS " iif " STRING"
+.RB " ] [ " oif
+.IR STRING " ] [ "
+.B  tos
+.IR TOS " ]"
+
+.ti -8
+.BR "ip route" " { " add " | " del " | " change " | " append " | "\
+replace " } "
+.I  ROUTE
+
+.ti -8
+.IR SELECTOR " := "
+.RB "[ " root
+.IR PREFIX " ] [ "
+.B  match
+.IR PREFIX " ] [ "
+.B  exact
+.IR PREFIX " ] [ "
+.B  table
+.IR TABLE_ID " ] [ "
+.B  proto
+.IR RTPROTO " ] [ "
+.B  type
+.IR TYPE " ] [ "
+.B  scope
+.IR SCOPE " ]"
+
+.ti -8
+.IR ROUTE " := " NODE_SPEC " [ " INFO_SPEC " ]"
+
+.ti -8
+.IR NODE_SPEC " := [ " TYPE " ] " PREFIX " ["
+.B  tos
+.IR TOS " ] [ "
+.B  table
+.IR TABLE_ID " ] [ "
+.B  proto
+.IR RTPROTO " ] [ "
+.B  scope
+.IR SCOPE " ] [ "
+.B  metric
+.IR METRIC " ]"
+
+.ti -8
+.IR INFO_SPEC " := " "NH OPTIONS FLAGS" " ["
+.B  nexthop
+.IR NH " ] ..."
+
+.ti -8
+.IR NH " := [ "
+.B  via
+.IR ADDRESS " ] [ "
+.B  dev
+.IR STRING " ] [ "
+.B  weight
+.IR NUMBER " ] " NHFLAGS
+
+.ti -8
+.IR OPTIONS " := " FLAGS " [ "
+.B  mtu
+.IR NUMBER " ] [ "
+.B  advmss
+.IR NUMBER " ] [ "
+.B  rtt
+.IR TIME " ] [ "
+.B  rttvar
+.IR TIME " ] [ "
+.B  window
+.IR NUMBER " ] [ "
+.B  cwnd
+.IR NUMBER " ] [ "
+.B  ssthresh
+.IR REALM " ] [ "
+.B  realms
+.IR REALM " ] [ "
+.B  rto_min
+.IR TIME " ] [ "
+.B  initcwnd
+.IR NUMBER " ] [ "
+.B  initrwnd
+.IR NUMBER " ]"
+
+.ti -8
+.IR TYPE " := [ "
+.BR unicast " | " local " | " broadcast " | " multicast " | "\
+throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
+
+.ti -8
+.IR TABLE_ID " := [ "
+.BR local "| " main " | " default " | " all " |"
+.IR NUMBER " ]"
+
+.ti -8
+.IR SCOPE " := [ "
+.BR host " | " link " | " global " |"
+.IR NUMBER " ]"
+
+.ti -8
+.IR NHFLAGS " := [ "
+.BR onlink " | " pervasive " ]"
+
+.ti -8
+.IR RTPROTO " := [ "
+.BR kernel " | " boot " | " static " |"
+.IR NUMBER " ]"
+
+
+.SH DESCRIPTION
+.B ip route
+is used to manipulate entries in the kernel routing tables.
+.sp
+.B Route types:
+
+.in +8
+.B unicast
+- the route entry describes real paths to the destinations covered
+by the route prefix.
+
+.sp
+.B unreachable
+- these destinations are unreachable.  Packets are discarded and the
+ICMP message
+.I host unreachable
+is generated.
+The local senders get an
+.I EHOSTUNREACH
+error.
+
+.sp
+.B blackhole
+- these destinations are unreachable.  Packets are discarded silently.
+The local senders get an
+.I EINVAL
+error.
+
+.sp
+.B prohibit
+- these destinations are unreachable.  Packets are discarded and the
+ICMP message
+.I communication administratively prohibited
+is generated.  The local senders get an
+.I EACCES
+error.
+
+.sp
+.B local
+- the destinations are assigned to this host.  The packets are looped
+back and delivered locally.
+
+.sp
+.B broadcast
+- the destinations are broadcast addresses.  The packets are sent as
+link broadcasts.
+
+.sp
+.B throw
+- a special control route used together with policy rules. If such a
+route is selected, lookup in this table is terminated pretending that
+no route was found.  Without policy routing it is equivalent to the
+absence of the route in the routing table.  The packets are dropped
+and the ICMP message
+.I net unreachable
+is generated.  The local senders get an
+.I ENETUNREACH
+error.
+
+.sp
+.B nat
+- a special NAT route.  Destinations covered by the prefix
+are considered to be dummy (or external) addresses which require translation
+to real (or internal) ones before forwarding.  The addresses to translate to
+are selected with the attribute
+.B Warning:
+Route NAT is no longer supported in Linux 2.6.
+
+
+.BR "via" .
+.sp
+.B anycast
+.RI "- " "not implemented"
+the destinations are
+.I anycast
+addresses assigned to this host.  They are mainly equivalent
+to
+.B local
+with one difference: such addresses are invalid when used
+as the source address of any packet.
+
+.sp
+.B multicast
+- a special type used for multicast routing.  It is not present in
+normal routing tables.
+.in -8
+
+.P
+.B Route tables:
+Linux-2.x can pack routes into several routing tables identified 
+by a number in the range from 1 to 2^31 or by name from the file
+.B @SYSCONFDIR@/rt_tables
+By default all normal routes are inserted into the
+.B main
+table (ID 254) and the kernel only uses this table when calculating routes.
+Values (0, 253, 254, and 255) are reserved for built-in use.
+
+.sp
+Actually, one other table always exists, which is invisible but
+even more important.  It is the
+.B local
+table (ID 255).  This table
+consists of routes for local and broadcast addresses.  The kernel maintains
+this table automatically and the administrator usually need not modify it
+or even look at it.
+
+The multiple routing tables enter the game when
+.I policy routing
+is used.
+
+.SS ip route add - add new route
+.SS ip route change - change route
+.SS ip route replace - change or add new one
+
+.TP
+.BI to " TYPE PREFIX " (default)
+the destination prefix of the route.  If
+.I TYPE
+is omitted,
+.B ip
+assumes type
+.BR "unicast" .
+Other values of
+.I TYPE
+are listed above.
+.I PREFIX
+is an IP or IPv6 address optionally followed by a slash and the
+prefix length.  If the length of the prefix is missing,
+.B ip
+assumes a full-length host route.  There is also a special
+.I PREFIX
+.B default
+- which is equivalent to IP
+.B 0/0
+or to IPv6
+.BR "::/0" .
+
+.TP
+.BI tos " TOS"
+.TP
+.BI dsfield " TOS"
+the Type Of Service (TOS) key.  This key has no associated mask and
+the longest match is understood as: First, compare the TOS
+of the route and of the packet.  If they are not equal, then the packet
+may still match a route with a zero TOS.
+.I TOS
+is either an 8 bit hexadecimal number or an identifier
+from
+.BR "@SYSCONFDIR@/rt_dsfield" .
+
+.TP
+.BI metric " NUMBER"
+.TP
+.BI preference " NUMBER"
+the preference value of the route.
+.I NUMBER
+is an arbitrary 32bit number.
+
+.TP
+.BI table " TABLEID"
+the table to add this route to.
+.I TABLEID
+may be a number or a string from the file
+.BR "@SYSCONFDIR@/rt_tables" .
+If this parameter is omitted,
+.B ip
+assumes the
+.B main
+table, with the exception of
+.BR local " , " broadcast " and " nat
+routes, which are put into the
+.B local
+table by default.
+
+.TP
+.BI dev " NAME"
+the output device name.
+
+.TP
+.BI via " ADDRESS"
+the address of the nexthop router.  Actually, the sense of this field
+depends on the route type.  For normal
+.B unicast
+routes it is either the true next hop router or, if it is a direct
+route installed in BSD compatibility mode, it can be a local address
+of the interface.  For NAT routes it is the first address of the block
+of translated IP destinations.
+
+.TP
+.BI src " ADDRESS"
+the source address to prefer when sending to the destinations
+covered by the route prefix.
+
+.TP
+.BI realm " REALMID"
+the realm to which this route is assigned.
+.I REALMID
+may be a number or a string from the file
+.BR "@SYSCONFDIR@/rt_realms" .
+
+.TP
+.BI mtu " MTU"
+.TP
+.BI "mtu lock" " MTU"
+the MTU along the path to the destination.  If the modifier
+.B lock
+is not used, the MTU may be updated by the kernel due to
+Path MTU Discovery.  If the modifier
+.B lock
+is used, no path MTU discovery will be tried, all packets
+will be sent without the DF bit in IPv4 case or fragmented
+to MTU for IPv6.
+
+.TP
+.BI window " NUMBER"
+the maximal window for TCP to advertise to these destinations,
+measured in bytes.  It limits maximal data bursts that our TCP
+peers are allowed to send to us.
+
+.TP
+.BI rtt " TIME"
+the initial RTT ('Round Trip Time') estimate. If no suffix is
+specified the units are raw values passed directly to the
+routing code to maintain compatibility with previous releases.
+Otherwise if a suffix of s, sec or secs is used to specify
+seconds and ms, msec or msecs to specify milliseconds.
+
+
+.TP
+.BI rttvar " TIME " "(2.3.15+ only)"
+the initial RTT variance estimate. Values are specified as with
+.BI rtt
+above.
+
+.TP
+.BI rto_min " TIME " "(2.6.23+ only)"
+the minimum TCP Retransmission TimeOut to use when communicating with this
+destination.  Values are specified as with
+.BI rtt
+above.
+
+.TP
+.BI ssthresh " NUMBER " "(2.3.15+ only)"
+an estimate for the initial slow start threshold.
+
+.TP
+.BI cwnd " NUMBER " "(2.3.15+ only)"
+the clamp for congestion window.  It is ignored if the
+.B lock
+flag is not used.
+
+.TP
+.BI initcwnd " NUMBER " "(2.5.70+ only)"
+the initial congestion window size for connections to this destination.
+Actual window size is this value multiplied by the MSS
+(``Maximal Segment Size'') for same connection. The default is
+zero, meaning to use the values specified in RFC2414.
+
+.TP
+.BI initrwnd " NUMBER " "(2.6.33+ only)"
+the initial receive window size for connections to this destination.
+Actual window size is this value multiplied by the MSS of the connection.
+The default value is zero, meaning to use Slow Start value.
+
+.TP
+.BI advmss " NUMBER " "(2.3.15+ only)"
+the MSS ('Maximal Segment Size') to advertise to these
+destinations when establishing TCP connections.  If it is not given,
+Linux uses a default value calculated from the first hop device MTU.
+(If the path to these destination is asymmetric, this guess may be wrong.)
+
+.TP
+.BI reordering " NUMBER " "(2.3.15+ only)"
+Maximal reordering on the path to this destination.
+If it is not given, Linux uses the value selected with
+.B sysctl
+variable
+.BR "net/ipv4/tcp_reordering" .
+
+.TP
+.BI nexthop " NEXTHOP"
+the nexthop of a multipath route.
+.I NEXTHOP
+is a complex value with its own syntax similar to the top level
+argument lists:
+
+.in +8
+.BI via " ADDRESS"
+- is the nexthop router.
+.sp
+
+.BI dev " NAME"
+- is the output device.
+.sp
+
+.BI weight " NUMBER"
+- is a weight for this element of a multipath
+route reflecting its relative bandwidth or quality.
+.in -8
+
+.TP
+.BI scope " SCOPE_VAL"
+the scope of the destinations covered by the route prefix.
+.I SCOPE_VAL
+may be a number or a string from the file
+.BR "@SYSCONFDIR@/rt_scopes" .
+If this parameter is omitted,
+.B ip
+assumes scope
+.B global
+for all gatewayed
+.B unicast
+routes, scope
+.B link
+for direct
+.BR unicast " and " broadcast
+routes and scope
+.BR host " for " local
+routes.
+
+.TP
+.BI protocol " RTPROTO"
+the routing protocol identifier of this route.
+.I RTPROTO
+may be a number or a string from the file
+.BR "@SYSCONFDIR@/rt_protos" .
+If the routing protocol ID is not given,
+.B ip assumes protocol
+.B boot
+(i.e. it assumes the route was added by someone who doesn't
+understand what they are doing).  Several protocol values have
+a fixed interpretation.
+Namely:
+
+.in +8
+.B redirect
+- the route was installed due to an ICMP redirect.
+.sp
+
+.B kernel
+- the route was installed by the kernel during autoconfiguration.
+.sp
+
+.B boot
+- the route was installed during the bootup sequence.
+If a routing daemon starts, it will purge all of them.
+.sp
+
+.B static
+- the route was installed by the administrator
+to override dynamic routing. Routing daemon will respect them
+and, probably, even advertise them to its peers.
+.sp
+
+.B ra
+- the route was installed by Router Discovery protocol.
+.in -8
+
+.sp
+The rest of the values are not reserved and the administrator is free
+to assign (or not to assign) protocol tags.
+
+.TP
+.B onlink
+pretend that the nexthop is directly attached to this link,
+even if it does not match any interface prefix.
+
+.SS ip route delete - delete route
+
+.B ip route del
+has the same arguments as
+.BR "ip route add" ,
+but their semantics are a bit different.
+
+Key values
+.RB "(" to ", " tos ", " preference " and " table ")"
+select the route to delete.  If optional attributes are present,
+.B ip
+verifies that they coincide with the attributes of the route to delete.
+If no route with the given key and attributes was found,
+.B ip route del
+fails.
+
+.SS ip route show - list routes
+the command displays the contents of the routing tables or the route(s)
+selected by some criteria.
+
+.TP
+.BI to " SELECTOR " (default)
+only select routes from the given range of destinations.
+.I SELECTOR
+consists of an optional modifier
+.RB "(" root ", " match " or " exact ")"
+and a prefix.
+.BI root " PREFIX"
+selects routes with prefixes not shorter than
+.IR PREFIX "."
+F.e.
+.BI root " 0/0"
+selects the entire routing table.
+.BI match " PREFIX"
+selects routes with prefixes not longer than
+.IR PREFIX "."
+F.e.
+.BI match " 10.0/16"
+selects
+.IR 10.0/16 ","
+.IR 10/8 " and " 0/0 ,
+but it does not select
+.IR 10.1/16 " and " 10.0.0/24 .
+And
+.BI exact " PREFIX"
+(or just
+.IR PREFIX ")"
+selects routes with this exact prefix. If neither of these options
+are present,
+.B ip
+assumes
+.BI root " 0/0"
+i.e. it lists the entire table.
+
+.TP
+.BI tos " TOS"
+.BI dsfield " TOS"
+only select routes with the given TOS.
+
+.TP
+.BI table " TABLEID"
+show the routes from this table(s).  The default setting is to show
+.BR table main "."
+.I TABLEID
+may either be the ID of a real table or one of the special values:
+.sp
+.in +8
+.B all
+- list all of the tables.
+.sp
+.B cache
+- dump the routing cache.
+.in -8
+
+.TP
+.B cloned
+.TP
+.B cached
+list cloned routes i.e. routes which were dynamically forked from
+other routes because some route attribute (f.e. MTU) was updated.
+Actually, it is equivalent to
+.BR "table cache" "."
+
+.TP
+.BI from " SELECTOR"
+the same syntax as for
+.BR to ","
+but it binds the source address range rather than destinations.
+Note that the
+.B from
+option only works with cloned routes.
+
+.TP
+.BI protocol " RTPROTO"
+only list routes of this protocol.
+
+.TP
+.BI scope " SCOPE_VAL"
+only list routes with this scope.
+
+.TP
+.BI type " TYPE"
+only list routes of this type.
+
+.TP
+.BI dev " NAME"
+only list routes going via this device.
+
+.TP
+.BI via " PREFIX"
+only list routes going via the nexthop routers selected by
+.IR PREFIX "."
+
+.TP
+.BI src " PREFIX"
+only list routes with preferred source addresses selected
+by
+.IR PREFIX "."
+
+.TP
+.BI realm " REALMID"
+.TP
+.BI realms " FROMREALM/TOREALM"
+only list routes with these realms.
+
+.SS ip route flush - flush routing tables
+this command flushes routes selected by some criteria.
+
+.sp
+The arguments have the same syntax and semantics as the arguments of
+.BR "ip route show" ,
+but routing tables are not listed but purged.  The only difference is
+the default action:
+.B show
+dumps all the IP main routing table but
+.B flush
+prints the helper page.
+
+.sp
+With the
+.B -statistics
+option, the command becomes verbose. It prints out the number of
+deleted routes and the number of rounds made to flush the routing
+table. If the option is given
+twice,
+.B ip route flush
+also dumps all the deleted routes in the format described in the
+previous subsection.
+
+.SS ip route get - get a single route
+this command gets a single route to a destination and prints its
+contents exactly as the kernel sees it.
+
+.TP
+.BI to " ADDRESS " (default)
+the destination address.
+
+.TP
+.BI from " ADDRESS"
+the source address.
+
+.TP
+.BI tos " TOS"
+.TP
+.BI dsfield " TOS"
+the Type Of Service.
+
+.TP
+.BI iif " NAME"
+the device from which this packet is expected to arrive.
+
+.TP
+.BI oif " NAME"
+force the output device on which this packet will be routed.
+
+.TP
+.B connected
+if no source address
+.RB "(option " from ")"
+was given, relookup the route with the source set to the preferred
+address received from the first lookup.
+If policy routing is used, it may be a different route.
+
+.P
+Note that this operation is not equivalent to
+.BR "ip route show" .
+.B show
+shows existing routes.
+.B get
+resolves them and creates new clones if necessary.  Essentially,
+.B get
+is equivalent to sending a packet along this path.
+If the
+.B iif
+argument is not given, the kernel creates a route
+to output packets towards the requested destination.
+This is equivalent to pinging the destination
+with a subsequent
+.BR "ip route ls cache" ,
+however, no packets are actually sent.  With the
+.B iif
+argument, the kernel pretends that a packet arrived from this interface
+and searches for a path to forward the packet.
+
+.SS ip route save - save routing table information to stdout
+this command behaves like
+.BR "ip route show"
+except that the output is raw data suitable for passing to
+.BR "ip route restore" .
+
+.SS ip route restore - restore routing table information from stdin
+this command expects to read a data stream as returned from
+.BR "ip route save" .
+It will attempt to restore the routing table information exactly as
+it was at the time of the save, so any translation of information
+in the stream (such as device indexes) must be done first.  Any existing
+routes are left unchanged.  Any routes specified in the data stream that
+already exist in the table will be ignored.
+
+.SH EXAMPLES
+.PP
+ip ro
+.RS 4
+Show all route entries in the kernel.
+.RE
+.PP
+ip route add default via 192.168.1.1 dev eth0
+.RS 4
+Adds a default route (for all addresses) via the local gateway 192.168.1.1 that can
+be reached on device eth0.
+.RE
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Original Manpage by Michail Litvak <mci@owl.openwall.com>
diff --git a/man/man8/nstat.8 b/man/man8/nstat.8
new file mode 100644
index 0000000..c703cc8
--- /dev/null
+++ b/man/man8/nstat.8
@@ -0,0 +1 @@
+.so man8/rtacct.8
diff --git a/man/man8/routef.8 b/man/man8/routef.8
new file mode 100644
index 0000000..c2a7059
--- /dev/null
+++ b/man/man8/routef.8
@@ -0,0 +1 @@
+.so man8/routel.8
diff --git a/man/man8/rtstat.8 b/man/man8/rtstat.8
new file mode 100644
index 0000000..080e2b2
--- /dev/null
+++ b/man/man8/rtstat.8
@@ -0,0 +1 @@
+.so man8/lnstat.8
diff --git a/man/man8/tc-pfifo.8 b/man/man8/tc-pfifo.8
deleted file mode 120000
index 70a54af..0000000
--- a/man/man8/tc-pfifo.8
+++ /dev/null
@@ -1 +0,0 @@
-tc-bfifo.8
\ No newline at end of file
diff --git a/man/man8/tc-pfifo.8 b/man/man8/tc-pfifo.8
new file mode 100644
index 0000000..ed23850
--- /dev/null
+++ b/man/man8/tc-pfifo.8
@@ -0,0 +1 @@
+.so man8/tc-bfifo.8
-- 
1.7.4.4


-- 
Jabber: heimdal@jabber.org
