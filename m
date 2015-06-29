From: Julien Grall <julien.grall@citrix.com>
Subject: Unable to unregister netdevice after "netfilter: bridge: forward
 IPv6 fragmented packets"
Date: Mon, 29 Jun 2015 17:03:41 +0100
Message-ID: <55916C5D.3080602@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<bridge@lists.linux-foundation.org>,
	xen-devel <xen-devel@lists.xenproject.org>,
	David Vrabel <david.vrabel@citrix.com>
To: <bernhard.thaler@wvnet.at>, <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39054 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbbF2QFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 12:05:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried to run the latest Linux tree
(4a10a91756ef381bced7b88cfb9232f660b92d93) as DOM0 Xen.
After destroying a guest using network, I got the following
lines in the DOM0 kernel log:

unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1

The bisector pointed the problem after the commit
efb6de9b4ba0092b2c55f6a52d16294a8a698edd
"netfilter: bridge: forward IPv6 fragmented packets".

This is happening on an xgene board. The bridge is configured
using /etc/network/interfaces:

# The primary network interface
auto xenbr0
iface xenbr0 inet dhcp
        hostname pony
        bridge_ports eth0
        bridge_stp off
        bridge_waitport 0
        bridge_fd 0
        bridge_maxwait 0

Xen tools is creating the interface vif1.0 and adding to the
bridge xenbr0.

Linux log:

device eth0 entered promiscuous mode
xenbr0: port 1(eth0) entered forwarding state
xenbr0: port 1(eth0) entered forwarding state
xenbr0: port 1(eth0) entered disabled state
xgene-enet 17020000.ethernet eth0: Link is Down
random: nonblocking pool is initialized
[....] Configuring network interfaces...
Waiting for a max of 0 seconds for eth0 to become available.
Internet Systems Consortium DHCP Client 4.3.1
Copyright 2004-2014 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

Listening on LPF/xenbr0/00:01:73:02:1a:00
Sending on   LPF/xenbr0/00:01:73:02:1a:00
Sending on   Socket/fallback
DHCPDISCOVER on xenbr0 to 255.255.255.255 port 67 interval 7
xgene-enet 17020000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
xenbr0: port 1(eth0) entered forwarding state
xenbr0: port 1(eth0) entered forwarding state
DHCPDISCOVER on xenbr0 to 255.255.255.255 port 67 interval 13
DHCPREQUEST on xenbr0 to 255.255.255.255 port 67
DHCPOFFER from 10.80.224.1
DHCPACK from 10.80.224.1
bound to 10.80.229.126 -- renewal in 19083 seconds.
done.
[ ok ] Starting rpcbind daemon....
[ ok ] Starting NFS common utilities: statd idmapd.
[ ok ] Cleaning up temporary files....
[info] Setting console screen modes.
setterm: cannot (un)set powersave mode: Inappropriate ioctl for device
[....] Setting up console font and keymap...Couldn't get a file descriptor referring to the console
Couldn't get a file descriptor referring to the console
done.
[ ok ] Setting up X socket directories... /tmp/.X11-unix /tmp/.ICE-unix.
INIT: Entering runlevel: 2
[info] Using makefile-style concurrent boot in runlevel 2.
[ ok ] Starting enhanced syslogd: rsyslogd.
[ ok ] Starting deferred execution scheduler: atd.
[ ok ] Starting periodic command scheduler: cron.
[ ok ] Starting SMP IRQ Balancer: irqbalance.

[ ok ] Starting NTP server: ntpd.
[ ok ] Starting OpenBSD Secure Shell server: sshd.
[ ok ] Starting system message bus: dbus.
Starting /usr/local/sbin/xenstored...
Setting domain 0 name, domid and JSON config...
Done setting up Dom0
Starting xenconsoled...
Starting QEMU as disk backend for dom0

Debian GNU/Linux 8 pony hvc0

pony login: device vif1.0 entered promiscuous mode
IPv6: ADDRCONF(NETDEV_UP): vif1.0: link is not ready
xen-blkback: ring-ref 8, event-channel 3, protocol 1 (arm-abi) persistent grants
vif vif-1-0 vif1.0: Guest Rx ready
IPv6: ADDRCONF(NETDEV_CHANGE): vif1.0: link becomes ready
xenbr0: port 2(vif1.0) entered forwarding state
xenbr0: port 2(vif1.0) entered forwarding state
(XEN) mm.c:1251:d0v2 gnttab_mark_dirty not implemented yet
xenbr0: port 2(vif1.0) entered disabled state
xenbr0: port 2(vif1.0) entered disabled state
device vif1.0 left promiscuous mode
xenbr0: port 2(vif1.0) entered disabled state
INIT: Id "1" respawning too fast: disabled for 5 minutes
INIT: Id "3" respawning too fast: disabled for 5 minutes
INIT: Id "5" respawning too fast: disabled for 5 minutes
INIT: Id "2" respawning too fast: disabled for 5 minutes
INIT: Id "6" respawning too fast: disabled for 5 minutes
INIT: Id "T0" respawning too fast: disabled for 5 minutes
INIT: Id "4" respawning too fast: disabled for 5 minutes
unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1
unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1
unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1

Regards,

-- 
Julien Grall
