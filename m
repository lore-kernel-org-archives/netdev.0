From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bug 11754] tlan network driver does not work
Date: Mon, 20 Oct 2008 15:43:13 +0200
Message-ID: <200810201543.13677.manfred.scherer.mhm@t-online.de>
References: <20081014135215.5A024108057@picon.linux-foundation.org> <200810191224.21758.manfred.scherer.mhm@t-online.de> <20081020104143.GB3085@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mostrows@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mostrows@earthlink.net
To: Robert Fitzsimons <robfitz@273k.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout07.t-online.de ([194.25.134.83]:34647 "EHLO
	mailout07.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbYJTVpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 17:45:43 -0400
In-Reply-To: <20081020104143.GB3085@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Robert

before I get DSL connection to the internet I used a analog modem (56kb) and the
eth1 (ThunderLAN) was not connected.
/var/log/messages was full with messages like this:

TLAN:  Giving autonegotiation more time.
TLAN:  Please check that your adapter has
TLAN:  been properly connected to a HUB or Switch.
TLAN:  Trying to establish link in the background...

To avoid this, i did a small patch to tlan.c since kernel 2.6.23:

pc1:/kernel/linux-2.6.27/drivers/net # diff -u tlan.c.ORIG tlan.c.20081013
--- tlan.c.ORIG 2008-10-10 00:13:53.000000000 +0200
+++ tlan.c.20081013     2008-10-12 16:16:05.000000000 +0200
@@ -858,6 +858,8 @@

        priv = netdev_priv(dev);

+        priv->neg_be_verbose = 0;       /* 2007-01-23,2007-10-12 --ms, should start with 0 */
+
        if ( bbuf ) {
                dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
                   * ( sizeof(TLanList) + TLAN_MAX_FRAME_SIZE );
@@ -2783,7 +2785,9 @@
                /* Wait for 8 sec to give the process
                 * more time.  Perhaps we should fail after a while.
                 */
-                if (!priv->neg_be_verbose++) {
+                /* if (!priv->neg_be_verbose++) 2007-01-23,2007-10-12 --ms */
+                if (!priv->neg_be_verbose) {
+                        priv->neg_be_verbose++;        /* 2007-01-23,2007-10-12 we'll see this messages one times --ms */
                         pr_info("TLAN:  Giving autonegotiation more time.\n");
                         pr_info("TLAN:  Please check that your adapter has\n");
                         pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
pc1:/kernel/linux-2.6.27/drivers/net #
_________________


My computer is a 32 bit version too with a AMD Athlon:

pc1:/proc # cat cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 4
model name      : AMD Athlon(tm) processor
stepping        : 2
cpu MHz         : 999.999
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca cmov pat pse36 mmx fxsr syscall mmxext 3dnowext 3dnow
bogomips        : 1999.99
clflush size    : 32
power management:

pc1:/proc #

___________________

The DSL-modem is a:

                          Tecom Tiny Bridge DSL Modem

                 +-------------------------------------------+
                 | Version:      | 2.00B.20-B2pB021h.d19c    |
                 |---------------+---------------------------|
                 | Firmware:     | bcm96338_tinybr_tecom_b.w |
                 |---------------+---------------------------|
                 | MAC address:  | 00:19:15:47:0e:11         |
                 +-------------------------------------------+


______________

Here are some boot information from /var/log/messages:

boot with kernel 2.6.26:

Oct 13 15:04:48 pc1 syslogd 1.4.1: restart.
Oct 13 15:04:49 pc1 SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 15:04:50 pc1 SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 15:04:51 pc1 SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 15:04:51 pc1 ntpd[4486]: ntpd 4.2.0a@1.1190-r Sat Oct  2 01:41:25 UTC 2004 (1)
Oct 13 15:04:51 pc1 ntpd[4486]: precision = 1.000 usec
Oct 13 15:04:51 pc1 ntpd[4486]: Listening on interface wildcard, 0.0.0.0#123
Oct 13 15:04:51 pc1 ntpd[4486]: Listening on interface wildcard, ::#123
Oct 13 15:04:51 pc1 ntpd[4486]: Listening on interface lo, 127.0.0.1#123
Oct 13 15:04:51 pc1 ntpd[4486]: Listening on interface eth0, 192.168.0.99#123
Oct 13 15:04:51 pc1 ntpd[4486]: Listening on interface eth1, 192.168.1.22#123
Oct 13 15:04:51 pc1 ntpd[4486]: kernel time sync status 0040
Oct 13 15:04:51 pc1 ntpd[4486]: frequency initialized 0.000 PPM from /var/lib/ntp/drift/ntp.drift
Oct 13 15:04:52 pc1 smpppd[4501]: smpppd version 1.50 started
Oct 13 15:04:52 pc1 sshd[4526]: Server listening on :: port 22.
Oct 13 15:04:53 pc1 kernel: klogd 1.4.1, log source = /proc/kmsg started.
Oct 13 15:04:53 pc1 kernel: Adding 529912k swap on /dev/md5.  Priority:10 extents:1 across:529912k
Oct 13 15:04:54 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap.  Priority:8 extents:328 across:385804k
Oct 13 15:04:54 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap2.  Priority:6 extents:87 across:302900k
Oct 13 15:04:54 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap3.  Priority:4 extents:76 across:319436k
Oct 13 15:04:54 pc1 kernel: hdb: selected mode 0x42
Oct 13 15:04:54 pc1 kernel: NET: Registered protocol family 10
Oct 13 15:04:54 pc1 kernel: lo: Disabled Privacy Extensions
Oct 13 15:04:54 pc1 kernel: ip6_tables: (C) 2000-2006 Netfilter Core Team
Oct 13 15:04:54 pc1 kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Oct 13 15:04:54 pc1 kernel: Netfilter messages via NETLINK v0.30.
Oct 13 15:04:54 pc1 kernel: nf_conntrack version 0.5.0 (12288 buckets, 49152 max)
Oct 13 15:04:54 pc1 kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Oct 13 15:04:54 pc1 kernel: TLAN: eth1: Starting autonegotiation.
Oct 13 15:04:54 pc1 kernel: TLAN: eth1: Autonegotiation complete.
Oct 13 15:04:54 pc1 kernel: TLAN: eth1: Link active with AutoNegotiation enabled, at 100Mbps Full-Duplex
Oct 13 15:04:54 pc1 kernel: TLAN: Partner capability: 10BaseT-HD 10BaseT-FD 100baseTx-HD 100baseTx-FD<NULL>
Oct 13 15:04:54 pc1 kernel: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Oct 13 15:04:58 pc1 kernel: eth0: no IPv6 routers present
Oct 13 15:05:00 pc1 kernel: lp0: using parport0 (interrupt-driven).
Oct 13 15:05:00 pc1 kernel: eth1: no IPv6 routers present
Oct 13 15:05:00 pc1 kernel: usbcore: registered new interface driver usbserial
Oct 13 15:05:00 pc1 kernel: drivers/usb/serial/usb-serial.c: USB Serial support registered for generic
Oct 13 15:05:00 pc1 kernel: usbcore: registered new interface driver usbserial_generic
Oct 13 15:05:00 pc1 kernel: drivers/usb/serial/usb-serial.c: USB Serial Driver core
Oct 13 15:05:04 pc1 kernel: Non-volatile memory driver v1.2
Oct 13 15:05:04 pc1 kernel: end_request: I/O error, dev fd0, sector 0
Oct 13 15:05:04 pc1 kernel: end_request: I/O error, dev fd0, sector 0
Oct 13 15:05:05 pc1 kernel: BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
Oct 13 15:05:06 pc1 /sbin/hotplug[6083]: /etc/hotplug/firmware.agent: line 37: /sys//firmware/edd/loading: Permission denied
Oct 13 15:05:06 pc1 /sbin/hotplug[6083]: /etc/hotplug/firmware.agent: line 38: /sys//firmware/edd/data: Permission denied
Oct 13 15:05:06 pc1 /sbin/hotplug[6083]: /etc/hotplug/firmware.agent: line 39: /sys//firmware/edd/loading: Permission denied
Oct 13 15:05:06 pc1 dhcpd: Internet Systems Consortium DHCP Server V3.0.1
Oct 13 15:05:06 pc1 dhcpd: Copyright 2004 Internet Systems Consortium.
Oct 13 15:05:06 pc1 dhcpd: All rights reserved.
Oct 13 15:05:06 pc1 dhcpd: For info, please visit http://www.isc.org/sw/dhcp/
Oct 13 15:05:06 pc1 dhcpd: Not searching LDAP since ldap-server, ldap-port and ldap-base-dn were not specified in the config file
Oct 13 15:05:06 pc1 dhcpd: Internet Systems Consortium DHCP Server V3.0.1
Oct 13 15:05:06 pc1 dhcpd: Copyright 2004 Internet Systems Consortium.
Oct 13 15:05:06 pc1 dhcpd: All rights reserved.
Oct 13 15:05:06 pc1 dhcpd: For info, please visit http://www.isc.org/sw/dhcp/
Oct 13 15:05:06 pc1 dhcpd: Not searching LDAP since ldap-server, ldap-port and ldap-base-dn were not specified in the config file
Oct 13 15:05:06 pc1 dhcpd: Wrote 6 leases to leases file.
Oct 13 15:05:06 pc1 dhcpd: Listening on Socket/eth0/192.168.0.0/24
Oct 13 15:05:06 pc1 dhcpd: Sending on   Socket/eth0/192.168.0.0/24
Oct 13 15:05:06 pc1 dhcpd: Sending on   Socket/fallback/fallback-net
Oct 13 15:05:07 pc1 /usr/sbin/cron[6236]: (CRON) STARTUP (V5.0)
Oct 13 15:05:07 pc1 /usr/sbin/gpm[6246]: *** info [startup.c(145)]:
Oct 13 15:05:07 pc1 /usr/sbin/gpm[6246]: Started gpm successfully. Entered daemon mode.
Oct 13 15:05:07 pc1 SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 15:05:08 pc1 SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 15:05:09 pc1 SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 15:05:26 pc1 login[7455]: resmgr: communication failure: Connection refused
Oct 13 15:05:26 pc1 login[7455]: resmgr login failed
Oct 13 15:08:19 pc1 kernel: PCI: Found IRQ 10 for device 0000:00:07.5
Oct 13 15:08:19 pc1 kernel: PCI: Sharing IRQ 10 with 0000:00:0b.0
Oct 13 15:08:19 pc1 kernel: PCI: Setting latency timer of device 0000:00:07.5 to 64
Oct 13 15:09:26 pc1 pppd[8591]: Plugin rp-pppoe.so loaded.
Oct 13 15:09:26 pc1 kernel: PPP generic driver version 2.4.2
Oct 13 15:09:27 pc1 pppd[8591]: RP-PPPoE plugin version 3.3 compiled against pppd 2.4.2
Oct 13 15:09:27 pc1 pppd[8591]: Plugin passwordfd.so loaded.
Oct 13 15:09:27 pc1 kernel: NET: Registered protocol family 17
Oct 13 15:09:27 pc1 pppd[8591]: pppd 2.4.2 started by root, uid 0
Oct 13 15:09:27 pc1 pppd[8591]: PPP session is 407
Oct 13 15:09:27 pc1 kernel: NET: Registered protocol family 24
Oct 13 15:09:27 pc1 kernel: net dsl0: device_rename: sysfs_create_symlink failed (-17)
Oct 13 15:09:27 pc1 pppd[8591]: Renamed interface ppp0 to dsl0
Oct 13 15:09:27 pc1 pppd[8591]: Using interface dsl0
Oct 13 15:09:27 pc1 pppd[8591]: Connect: dsl0 <--> eth1
Oct 13 15:09:27 pc1 pppd[8591]: Couldn't increase MTU to 1500
Oct 13 15:09:27 pc1 pppd[8591]: Couldn't increase MRU to 1500
Oct 13 15:09:27 pc1 pppd[8591]: PAP authentication succeeded
Oct 13 15:09:27 pc1 pppd[8591]: peer from calling number 00:90:1A:A0:BF:67 authorized
Oct 13 15:09:27 pc1 pppd[8591]: local  IP address 87.178.75.220
Oct 13 15:09:27 pc1 pppd[8591]: remote IP address 217.0.117.13
Oct 13 15:09:27 pc1 pppd[8591]: primary   DNS address 217.237.150.51
Oct 13 15:09:27 pc1 pppd[8591]: secondary DNS address 217.237.148.22
Oct 13 15:09:28 pc1 modify_resolvconf: Service pppd modified /etc/resolv.conf. See info block in this file
Oct 13 15:09:28 pc1 ip-up: SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 15:09:28 pc1 SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 15:09:30 pc1 ip-up: SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 15:09:30 pc1 SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 15:09:31 pc1 ip-up: SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 15:09:31 pc1 SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 15:09:31 pc1 pppd[8591]: Script /etc/ppp/ip-up finished (pid 8697), status = 0x0
Oct 13 15:09:39 pc1 poll.tcpip: fetchmail: No mail for Manfred.Scherer.Mhm at pop.t-online.de
Oct 13 15:51:21 pc1 pppd[8591]: Terminating connection due to lack of activity.
Oct 13 15:51:21 pc1 pppd[8591]: Couldn't increase MTU to 1500
Oct 13 15:51:21 pc1 pppd[8591]: Couldn't increase MRU to 1500
Oct 13 15:51:21 pc1 pppd[8591]: Connection terminated.
Oct 13 15:51:21 pc1 pppd[8591]: Connect time 41.9 minutes.


boot with kernel 2.6.27:

Oct 13 14:04:47 pc1 syslogd 1.4.1: restart.
Oct 13 14:04:47 pc1 SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 14:04:49 pc1 SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 14:04:50 pc1 SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 14:04:50 pc1 ntpd[4631]: ntpd 4.2.0a@1.1190-r Sat Oct  2 01:41:25 UTC 2004 (1)
Oct 13 14:04:50 pc1 ntpd[4631]: precision = 1.000 usec
Oct 13 14:04:50 pc1 ntpd[4631]: Listening on interface wildcard, 0.0.0.0#123
Oct 13 14:04:50 pc1 ntpd[4631]: Listening on interface wildcard, ::#123
Oct 13 14:04:50 pc1 ntpd[4631]: Listening on interface lo, 127.0.0.1#123
Oct 13 14:04:50 pc1 ntpd[4631]: Listening on interface eth0, 192.168.0.99#123
Oct 13 14:04:50 pc1 ntpd[4631]: Listening on interface eth1, 192.168.1.22#123
Oct 13 14:04:50 pc1 ntpd[4631]: kernel time sync status 0040
Oct 13 14:04:50 pc1 ntpd[4631]: frequency initialized 0.000 PPM from /var/lib/ntp/drift/ntp.drift
Oct 13 14:04:50 pc1 smpppd[4646]: smpppd version 1.50 started
Oct 13 14:04:51 pc1 sshd[4655]: Server listening on :: port 22.
Oct 13 14:04:52 pc1 kernel: klogd 1.4.1, log source = /proc/kmsg started.
Oct 13 14:04:52 pc1 kernel: Adding 529912k swap on /dev/md5.  Priority:10 extents:1 across:529912k
Oct 13 14:04:52 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap.  Priority:8 extents:328 across:385804k
Oct 13 14:04:52 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap2.  Priority:6 extents:87 across:302900k
Oct 13 14:04:52 pc1 kernel: Adding 299992k swap on /mnt_md6/swap/swap3.  Priority:4 extents:76 across:319436k
Oct 13 14:04:52 pc1 kernel: hdb: UDMA/33 mode selected
Oct 13 14:04:52 pc1 kernel: NET: Registered protocol family 10
Oct 13 14:04:52 pc1 kernel: lo: Disabled Privacy Extensions
Oct 13 14:04:52 pc1 kernel: ip6_tables: (C) 2000-2006 Netfilter Core Team
Oct 13 14:04:52 pc1 kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Oct 13 14:04:52 pc1 kernel: nf_conntrack version 0.5.0 (12288 buckets, 49152 max)
Oct 13 14:04:52 pc1 kernel: CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Plase use
Oct 13 14:04:52 pc1 kernel: nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or
Oct 13 14:04:52 pc1 kernel: sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
Oct 13 14:04:52 pc1 kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Oct 13 14:04:52 pc1 kernel: TLAN: eth1: Starting autonegotiation.
Oct 13 14:04:52 pc1 kernel: TLAN: eth1: Autonegotiation complete.
Oct 13 14:04:52 pc1 kernel: TLAN: eth1: Link active with AutoNegotiation enabled, at 100Mbps Full-Duplex
Oct 13 14:04:52 pc1 kernel: TLAN: Partner capability: 10BaseT-HD 10BaseT-FD 100baseTx-HD 100baseTx-FD<NULL>
Oct 13 14:04:52 pc1 kernel: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Oct 13 14:04:56 pc1 kernel: eth0: no IPv6 routers present
Oct 13 14:04:58 pc1 kernel: lp0: using parport0 (interrupt-driven).
Oct 13 14:04:58 pc1 kernel: eth1: no IPv6 routers present
Oct 13 14:04:59 pc1 kernel: usbcore: registered new interface driver usbserial
Oct 13 14:04:59 pc1 kernel: usbserial: USB Serial support registered for generic
Oct 13 14:04:59 pc1 kernel: usbcore: registered new interface driver usbserial_generic
Oct 13 14:04:59 pc1 kernel: usbserial: USB Serial Driver core
Oct 13 14:05:03 pc1 kernel: Non-volatile memory driver v1.2
Oct 13 14:05:03 pc1 kernel: end_request: I/O error, dev fd0, sector 0
Oct 13 14:05:03 pc1 kernel: end_request: I/O error, dev fd0, sector 0
Oct 13 14:05:03 pc1 kernel: BIOS EDD facility v0.16 2004-Jun-25, 5 devices found
Oct 13 14:05:05 pc1 dhcpd: Internet Systems Consortium DHCP Server V3.0.1
Oct 13 14:05:05 pc1 dhcpd: Copyright 2004 Internet Systems Consortium.
Oct 13 14:05:05 pc1 dhcpd: All rights reserved.
Oct 13 14:05:05 pc1 dhcpd: For info, please visit http://www.isc.org/sw/dhcp/
Oct 13 14:05:05 pc1 dhcpd: Not searching LDAP since ldap-server, ldap-port and ldap-base-dn were not specified in the config file
Oct 13 14:05:05 pc1 dhcpd: Internet Systems Consortium DHCP Server V3.0.1
Oct 13 14:05:05 pc1 dhcpd: Copyright 2004 Internet Systems Consortium.
Oct 13 14:05:05 pc1 dhcpd: All rights reserved.
Oct 13 14:05:05 pc1 dhcpd: For info, please visit http://www.isc.org/sw/dhcp/
Oct 13 14:05:05 pc1 dhcpd: Not searching LDAP since ldap-server, ldap-port and ldap-base-dn were not specified in the config file
Oct 13 14:05:05 pc1 dhcpd: Wrote 6 leases to leases file.
Oct 13 14:05:05 pc1 dhcpd: Listening on Socket/eth0/192.168.0.0/24
Oct 13 14:05:05 pc1 dhcpd: Sending on   Socket/eth0/192.168.0.0/24
Oct 13 14:05:05 pc1 dhcpd: Sending on   Socket/fallback/fallback-net
Oct 13 14:05:06 pc1 /usr/sbin/cron[6442]: (CRON) STARTUP (V5.0)
Oct 13 14:05:06 pc1 /usr/sbin/gpm[6452]: *** info [startup.c(145)]:
Oct 13 14:05:06 pc1 /usr/sbin/gpm[6452]: Started gpm successfully. Entered daemon mode.
Oct 13 14:05:06 pc1 SuSEfirewall2: Warning: ip6tables does not support state matching. Extended IPv6 support disabled.
Oct 13 14:05:09 pc1 SuSEfirewall2: Warning: FW_ALLOW_INCOMING_HIGHPORTS_UDP=DNS no longer supported
Oct 13 14:05:09 pc1 SuSEfirewall2: Firewall rules successfully set from /etc/sysconfig/SuSEfirewall2
Oct 13 14:05:26 pc1 login[7653]: resmgr: communication failure: Connection refused
Oct 13 14:05:26 pc1 login[7653]: resmgr login failed
Oct 13 14:24:47 pc1 -- MARK --
Oct 13 14:26:15 pc1 kernel: VIA 82xx Audio 0000:00:07.5: found PCI INT C -> IRQ 10
Oct 13 14:26:15 pc1 kernel: VIA 82xx Audio 0000:00:07.5: sharing IRQ 10 with 0000:00:0b.0
Oct 13 14:26:15 pc1 kernel: VIA 82xx Audio 0000:00:07.5: setting latency timer to 64
Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.
Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2
Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3 compiled against pppd 2.4.2
Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.
Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17
Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid 0
Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets
Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE Discovery
Oct 13 14:39:41 pc1 pppd[10123]: Exit.
Oct 13 14:40:13 pc1 pppd[10292]: Plugin rp-pppoe.so loaded.
Oct 13 14:40:13 pc1 pppd[10292]: RP-PPPoE plugin version 3.3 compiled against pppd 2.4.2
Oct 13 14:40:13 pc1 pppd[10292]: Plugin passwordfd.so loaded.
Oct 13 14:40:13 pc1 pppd[10292]: pppd 2.4.2 started by root, uid 0
Oct 13 14:40:48 pc1 pppd[10292]: Timeout waiting for PADO packets
Oct 13 14:40:48 pc1 pppd[10292]: Unable to complete PPPoE Discovery
Oct 13 14:40:48 pc1 pppd[10292]: Exit.
Oct 13 14:59:01 pc1 /usr/sbin/cron[11272]: (root) CMD ( rm -f /var/spool/cron/lastrun/cron.hourly)
Oct 13 15:02:37 pc1 init: Switching to runlevel: 6

Manfred
_________________________________________________________________________

Am Montag, 20. Oktober 2008 12:41 schrieb Robert Fitzsimons:
> Hi Manfred
> 
> Is this a 64 bit build?  Can you attach a full boot log?
> 
> I'm using my tlan in a similar way, to connect to the Internet with a
> DSL modem over pppoe.  I'm using a 32 bit Athlon, the distro is
> Debian/Testing with pppd (2.4.4) and pppoe (3.8), the DSL modem is a
> DLink DSL-300T.
> 
> I never ran v2.6.26 on this computer and jumped from an early
> v2.6.26-rc? straight to v2.6.27-rc? and then uncovered the two
> regressions, opps and failure for the interface to come up.
> 
> I've included the latest boot log from my computer
> (2.6.27-rc9-00016-g6984937-dirty with some local DVB patches).  The only
> thing that still seems unusual is this:
> 
> Oct 18 14:25:30 earth kernel: [   48.739246] TLAN: eth0: Starting autonegotiation.
> Oct 18 14:25:30 earth kernel: [   50.794174] TLAN:  Giving autonegotiation more time.
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  Please check that your adapter has
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  been properly connected to a HUB or Switch.
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  Trying to establish link in the background...
> Oct 18 14:25:30 earth kernel: [   59.058195] TLAN: eth0: Autonegotiation complete.
> Oct 18 14:25:30 earth kernel: [   59.215360] TLAN: eth0: Link active
> Oct 18 14:25:30 earth kernel: [   59.216010] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> Oct 18 14:25:30 earth kernel: [   67.965828] ADDRCONF(NETDEV_UP): eth0: link is not ready
> Oct 18 14:25:30 earth kernel: [   68.127259] TLAN: eth0: Starting autonegotiation.
> Oct 18 14:25:30 earth kernel: [   70.182180] TLAN:  Giving autonegotiation more time.
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  Please check that your adapter has
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  been properly connected to a HUB or Switch.
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  Trying to establish link in the background...
> Oct 18 14:25:30 earth kernel: [   70.601415] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> 
> I don't remember the link having to come up twice before v2.6.26, though
> I'd have to check.
> 
> Robert
> 
> 
> 
> Oct 18 14:25:30 earth kernel: klogd 1.5.0#5, log source = /proc/kmsg started.
> Oct 18 14:25:30 earth kernel: 91] bus: 00 index 1 mmio: [0, ffffffff]
> Oct 18 14:25:30 earth kernel: [    2.123618] bus: 01 index 0 io port: [9000, 9fff]
> Oct 18 14:25:30 earth kernel: [    2.180027] bus: 01 index 1 mmio: [e0000000, e1ffffff]
> Oct 18 14:25:30 earth kernel: [    2.241637] bus: 01 index 2 mmio: [d0000000, dfffffff]
> Oct 18 14:25:30 earth kernel: [    2.303250] bus: 01 index 3 mmio: [0, 0]
> Oct 18 14:25:30 earth kernel: [    2.350297] NET: Registered protocol family 2
> Oct 18 14:25:30 earth kernel: [    2.402649] IP route cache hash table entries: 65536 (order: 6, 262144 bytes)
> Oct 18 14:25:30 earth kernel: [    2.488806] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
> Oct 18 14:25:30 earth kernel: [    2.582816] TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
> Oct 18 14:25:30 earth kernel: [    2.662836] TCP: Hash tables configured (established 262144 bind 65536)
> Oct 18 14:25:30 earth kernel: [    2.742133] TCP reno registered
> Oct 18 14:25:30 earth kernel: [    2.779939] NET: Registered protocol family 1
> Oct 18 14:25:30 earth kernel: [    2.832225] Registering sysdev class 'i8259'
> Oct 18 14:25:30 earth kernel: [    2.832369] Registering sys device of class 'i8259'
> Oct 18 14:25:30 earth kernel: [    2.832376] Registering sys device 'i82590'
> Oct 18 14:25:30 earth kernel: [    2.832429] Registering sysdev class 'i8237'
> Oct 18 14:25:30 earth kernel: [    2.832520] Registering sys device of class 'i8237'
> Oct 18 14:25:30 earth kernel: [    2.832526] Registering sys device 'i82370'
> Oct 18 14:25:30 earth kernel: [    2.832939] Registering platform device 'pcspkr'. Parent at platform
> Oct 18 14:25:30 earth kernel: [    2.832944] device: 'pcspkr': device_add
> Oct 18 14:25:30 earth kernel: [    2.832957] bus: 'platform': add device pcspkr
> Oct 18 14:25:30 earth kernel: [    2.833041] Registering sysdev class 'timekeeping'
> Oct 18 14:25:30 earth kernel: [    2.833090] Registering sys device of class 'timekeeping'
> Oct 18 14:25:30 earth kernel: [    2.833096] Registering sys device 'timekeeping0'
> Oct 18 14:25:30 earth kernel: [    2.833163] Registering sysdev class 'clocksource'
> Oct 18 14:25:30 earth kernel: [    2.833210] Registering sys device of class 'clocksource'
> Oct 18 14:25:30 earth kernel: [    2.833216] Registering sys device 'clocksource0'
> Oct 18 14:25:30 earth kernel: [    2.833607] msgmni has been set to 3799
> Oct 18 14:25:30 earth kernel: [    2.879653] io scheduler noop registered
> Oct 18 14:25:30 earth kernel: [    2.926689] io scheduler anticipatory registered (default)
> Oct 18 14:25:30 earth kernel: [    2.992440] PCI: VIA PCI bridge detected.Disabling DAC.
> Oct 18 14:25:30 earth kernel: [    3.055100] pci 0000:00:0d.0: uhci_check_and_reset_hc: legsup = 0x2000
> Oct 18 14:25:30 earth kernel: [    3.055103] pci 0000:00:0d.0: Performing full reset
> Oct 18 14:25:30 earth kernel: [    3.055119] pci 0000:00:0d.1: uhci_check_and_reset_hc: legsup = 0x2000
> Oct 18 14:25:30 earth kernel: [    3.055122] pci 0000:00:0d.1: Performing full reset
> Oct 18 14:25:30 earth kernel: [    3.055163] pci 0000:00:11.2: uhci_check_and_reset_hc: legsup = 0x2000
> Oct 18 14:25:30 earth kernel: [    3.055166] pci 0000:00:11.2: Performing full reset
> Oct 18 14:25:30 earth kernel: [    3.055180] pci 0000:00:11.3: uhci_check_and_reset_hc: legsup = 0x2000
> Oct 18 14:25:30 earth kernel: [    3.055183] pci 0000:00:11.3: Performing full reset
> Oct 18 14:25:30 earth kernel: [    3.055198] pci 0000:00:11.4: uhci_check_and_reset_hc: legsup = 0x2000
> Oct 18 14:25:30 earth kernel: [    3.055201] pci 0000:00:11.4: Performing full reset
> Oct 18 14:25:30 earth kernel: [    3.055217] pci 0000:01:00.0: Boot video device
> Oct 18 14:25:30 earth kernel: [    3.055282] device class 'display': registering
> Oct 18 14:25:30 earth kernel: [    3.055354] bus: 'acpi': add driver fan
> Oct 18 14:25:30 earth kernel: [    3.055395] bus: 'acpi': driver_probe_device: matched device PNP0C0B:00 with driver fan
> Oct 18 14:25:30 earth kernel: [    3.055399] bus: 'acpi': really_probe: probing driver fan with device PNP0C0B:00
> Oct 18 14:25:30 earth kernel: [    3.055456] device: 'cooling_device0': device_add
> Oct 18 14:25:30 earth kernel: [    3.055530] fan PNP0C0B:00: registered as cooling_device0
> Oct 18 14:25:30 earth kernel: [    3.120240] ACPI: Fan [FAN] (on)
> Oct 18 14:25:30 earth kernel: [    3.158951] driver: 'PNP0C0B:00': driver_bound: bound to device 'fan'
> Oct 18 14:25:30 earth kernel: [    3.158954] bus: 'acpi': really_probe: bound device PNP0C0B:00 to driver fan
> Oct 18 14:25:30 earth kernel: [    3.159004] Registering sysdev class 'irqrouter'
> Oct 18 14:25:30 earth kernel: [    3.159043] Registering sys device of class 'irqrouter'
> Oct 18 14:25:30 earth kernel: [    3.159050] Registering sys device 'irqrouter0'
> Oct 18 14:25:30 earth kernel: [    3.159093] bus: 'acpi': add driver processor
> Oct 18 14:25:30 earth kernel: [    3.159101] bus: 'acpi': driver_probe_device: matched device ACPI0007:00 with driver processor
> Oct 18 14:25:30 earth kernel: [    3.159105] bus: 'acpi': really_probe: probing driver processor with device ACPI0007:00
> Oct 18 14:25:30 earth kernel: [    3.159304] device: 'cooling_device1': device_add
> Oct 18 14:25:30 earth kernel: [    3.159367] processor ACPI0007:00: registered as cooling_device1
> Oct 18 14:25:30 earth kernel: [    3.231390] ACPI: Processor [CPU0] (supports 2 throttling states)
> Oct 18 14:25:30 earth kernel: [    3.304854] driver: 'ACPI0007:00': driver_bound: bound to device 'processor'
> Oct 18 14:25:30 earth kernel: [    3.304858] bus: 'acpi': really_probe: bound device ACPI0007:00 to driver processor
> Oct 18 14:25:30 earth kernel: [    3.304918] bus: 'acpi': add driver thermal
> Oct 18 14:25:30 earth kernel: [    3.304932] bus: 'acpi': driver_probe_device: matched device LNXTHERM:00 with driver thermal
> Oct 18 14:25:30 earth kernel: [    3.304935] bus: 'acpi': really_probe: probing driver thermal with device LNXTHERM:00
> Oct 18 14:25:30 earth kernel: [    3.304955] bus: 'acpi': driver_probe_device: matched device LNXTHERM:01 with driver thermal
> Oct 18 14:25:30 earth kernel: [    3.304959] bus: 'acpi': really_probe: probing driver thermal with device LNXTHERM:01
> Oct 18 14:25:30 earth kernel: [    3.305724] device: 'thermal_zone0': device_add
> Oct 18 14:25:30 earth kernel: [    3.305864] thermal LNXTHERM:01: registered as thermal_zone0
> Oct 18 14:25:30 earth kernel: [    3.374621] ACPI: Thermal Zone [THRM] (43 C)
> Oct 18 14:25:30 earth kernel: [    3.425799] driver: 'LNXTHERM:01': driver_bound: bound to device 'thermal'
> Oct 18 14:25:30 earth kernel: [    3.425803] bus: 'acpi': really_probe: bound device LNXTHERM:01 to driver thermal
> Oct 18 14:25:30 earth kernel: [    3.425905] device: 'tty': device_add
> Oct 18 14:25:30 earth kernel: [    3.425969] device: 'console': device_add
> Oct 18 14:25:30 earth kernel: [    3.426067] device: 'ptmx': device_add
> Oct 18 14:25:30 earth kernel: [    3.426124] device: 'tty0': device_add
> Oct 18 14:25:30 earth kernel: [    3.426186] device class 'vc': registering
> Oct 18 14:25:30 earth kernel: [    3.426235] device: 'vcs': device_add
> Oct 18 14:25:30 earth kernel: [    3.426327] device: 'vcsa': device_add
> Oct 18 14:25:30 earth kernel: [    3.426389] device: 'tty1': device_add
> Oct 18 14:25:30 earth kernel: [    3.426449] device: 'tty2': device_add
> Oct 18 14:25:30 earth kernel: [    3.426508] device: 'tty3': device_add
> Oct 18 14:25:30 earth kernel: [    3.426581] device: 'tty4': device_add
> Oct 18 14:25:30 earth kernel: [    3.426636] device: 'tty5': device_add
> Oct 18 14:25:30 earth kernel: [    3.426697] device: 'tty6': device_add
> Oct 18 14:25:30 earth kernel: [    3.426757] device: 'tty7': device_add
> Oct 18 14:25:30 earth kernel: [    3.426847] device: 'tty8': device_add
> Oct 18 14:25:30 earth kernel: [    3.426904] device: 'tty9': device_add
> Oct 18 14:25:30 earth kernel: [    3.426964] device: 'tty10': device_add
> Oct 18 14:25:30 earth kernel: [    3.427025] device: 'tty11': device_add
> Oct 18 14:25:30 earth kernel: [    3.427103] device: 'tty12': device_add
> Oct 18 14:25:30 earth kernel: [    3.427183] device: 'tty13': device_add
> Oct 18 14:25:30 earth kernel: [    3.427240] device: 'tty14': device_add
> Oct 18 14:25:30 earth kernel: [    3.427304] device: 'tty15': device_add
> Oct 18 14:25:30 earth kernel: [    3.427368] device: 'tty16': device_add
> Oct 18 14:25:30 earth kernel: [    3.427456] device: 'tty17': device_add
> Oct 18 14:25:30 earth kernel: [    3.427516] device: 'tty18': device_add
> Oct 18 14:25:30 earth kernel: [    3.427577] device: 'tty19': device_add
> Oct 18 14:25:30 earth kernel: [    3.427642] device: 'tty20': device_add
> Oct 18 14:25:30 earth kernel: [    3.427708] device: 'tty21': device_add
> Oct 18 14:25:30 earth kernel: [    3.427802] device: 'tty22': device_add
> Oct 18 14:25:30 earth kernel: [    3.427861] device: 'tty23': device_add
> Oct 18 14:25:30 earth kernel: [    3.427925] device: 'tty24': device_add
> Oct 18 14:25:30 earth kernel: [    3.427993] device: 'tty25': device_add
> Oct 18 14:25:30 earth kernel: [    3.428086] device: 'tty26': device_add
> Oct 18 14:25:30 earth kernel: [    3.428148] device: 'tty27': device_add
> Oct 18 14:25:30 earth kernel: [    3.428212] device: 'tty28': device_add
> Oct 18 14:25:30 earth kernel: [    3.428276] device: 'tty29': device_add
> Oct 18 14:25:30 earth kernel: [    3.428349] device: 'tty30': device_add
> Oct 18 14:25:30 earth kernel: [    3.428473] device: 'tty31': device_add
> Oct 18 14:25:30 earth kernel: [    3.428534] device: 'tty32': device_add
> Oct 18 14:25:30 earth kernel: [    3.428597] device: 'tty33': device_add
> Oct 18 14:25:30 earth kernel: [    3.428666] device: 'tty34': device_add
> Oct 18 14:25:30 earth kernel: [    3.428762] device: 'tty35': device_add
> Oct 18 14:25:30 earth kernel: [    3.428827] device: 'tty36': device_add
> Oct 18 14:25:30 earth kernel: [    3.428893] device: 'tty37': device_add
> Oct 18 14:25:30 earth kernel: [    3.428959] device: 'tty38': device_add
> Oct 18 14:25:30 earth kernel: [    3.429030] device: 'tty39': device_add
> Oct 18 14:25:30 earth kernel: [    3.429175] device: 'tty40': device_add
> Oct 18 14:25:30 earth kernel: [    3.429238] device: 'tty41': device_add
> Oct 18 14:25:30 earth kernel: [    3.429313] device: 'tty42': device_add
> Oct 18 14:25:30 earth kernel: [    3.429382] device: 'tty43': device_add
> Oct 18 14:25:30 earth kernel: [    3.429477] device: 'tty44': device_add
> Oct 18 14:25:30 earth kernel: [    3.429576] device: 'tty45': device_add
> Oct 18 14:25:30 earth kernel: [    3.429646] device: 'tty46': device_add
> Oct 18 14:25:30 earth kernel: [    3.429714] device: 'tty47': device_add
> Oct 18 14:25:30 earth kernel: [    3.429812] device: 'tty48': device_add
> Oct 18 14:25:30 earth kernel: [    3.429878] device: 'tty49': device_add
> Oct 18 14:25:30 earth kernel: [    3.429948] device: 'tty50': device_add
> Oct 18 14:25:30 earth kernel: [    3.430018] device: 'tty51': device_add
> Oct 18 14:25:30 earth kernel: [    3.430117] device: 'tty52': device_add
> Oct 18 14:25:30 earth kernel: [    3.430210] device: 'tty53': device_add
> Oct 18 14:25:30 earth kernel: [    3.430277] device: 'tty54': device_add
> Oct 18 14:25:30 earth kernel: [    3.430348] device: 'tty55': device_add
> Oct 18 14:25:30 earth kernel: [    3.430420] device: 'tty56': device_add
> Oct 18 14:25:30 earth kernel: [    3.430520] device: 'tty57': device_add
> Oct 18 14:25:30 earth kernel: [    3.430586] device: 'tty58': device_add
> Oct 18 14:25:30 earth kernel: [    3.430651] device: 'tty59': device_add
> Oct 18 14:25:30 earth kernel: [    3.430726] device: 'tty60': device_add
> Oct 18 14:25:30 earth kernel: [    3.430826] device: 'tty61': device_add
> Oct 18 14:25:30 earth kernel: [    3.430900] device: 'tty62': device_add
> Oct 18 14:25:30 earth kernel: [    3.430969] device: 'tty63': device_add
> Oct 18 14:25:30 earth kernel: [    3.431189] Linux agpgart interface v0.103
> Oct 18 14:25:30 earth kernel: [    3.480356] bus: 'pci': add driver agpgart-amdk7
> Oct 18 14:25:30 earth kernel: [    3.480486] device class 'drm': registering
> Oct 18 14:25:30 earth kernel: [    3.480562] [drm] Initialized drm 1.1.0 20060810
> Oct 18 14:25:30 earth kernel: [    3.536220] Serial: 8250/16550 driver4 ports, IRQ sharing enabled
> Oct 18 14:25:30 earth kernel: [    3.609347] Registering platform device 'serial8250'. Parent at platform
> Oct 18 14:25:30 earth kernel: [    3.609351] device: 'serial8250': device_add
> Oct 18 14:25:30 earth kernel: [    3.609360] bus: 'platform': add device serial8250
> Oct 18 14:25:30 earth kernel: [    3.609674] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Oct 18 14:25:30 earth kernel: [    3.681720] device: 'ttyS0': device_add
> Oct 18 14:25:30 earth kernel: [    3.681849] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> Oct 18 14:25:30 earth kernel: [    3.753841] device: 'ttyS1': device_add
> Oct 18 14:25:30 earth kernel: [    3.753918] device: 'ttyS2': device_add
> Oct 18 14:25:30 earth kernel: [    3.754002] device: 'ttyS3': device_add
> Oct 18 14:25:30 earth kernel: [    3.754068] bus: 'platform': add driver serial8250
> Oct 18 14:25:30 earth kernel: [    3.754079] bus: 'platform': driver_probe_device: matched device serial8250 with driver serial8250
> Oct 18 14:25:30 earth kernel: [    3.754084] bus: 'platform': really_probe: probing driver serial8250 with device serial8250
> Oct 18 14:25:30 earth kernel: [    3.754093] driver: 'serial8250': driver_bound: bound to device 'serial8250'
> Oct 18 14:25:30 earth kernel: [    3.754097] bus: 'platform': really_probe: bound device serial8250 to driver serial8250
> Oct 18 14:25:30 earth kernel: [    3.754145] bus: 'pnp': add driver serial
> Oct 18 14:25:30 earth kernel: [    3.754215] bus: 'pnp': driver_probe_device: matched device 00:07 with driver serial
> Oct 18 14:25:30 earth kernel: [    3.754218] bus: 'pnp': really_probe: probing driver serial with device 00:07
> Oct 18 14:25:30 earth kernel: [    3.754253] device: 'ttyS0': device_unregister
> Oct 18 14:25:30 earth kernel: [    3.754320] device: 'ttyS0': device_create_release
> Oct 18 14:25:30 earth kernel: [    3.754382] 00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Oct 18 14:25:30 earth kernel: [    3.821181] device: 'ttyS0': device_add
> Oct 18 14:25:30 earth kernel: [    3.821259] driver: '00:07': driver_bound: bound to device 'serial'
> Oct 18 14:25:30 earth kernel: [    3.821263] bus: 'pnp': really_probe: bound device 00:07 to driver serial
> Oct 18 14:25:30 earth kernel: [    3.821272] bus: 'pnp': driver_probe_device: matched device 00:08 with driver serial
> Oct 18 14:25:30 earth kernel: [    3.821275] bus: 'pnp': really_probe: probing driver serial with device 00:08
> Oct 18 14:25:30 earth kernel: [    3.821293] device: 'ttyS1': device_unregister
> Oct 18 14:25:30 earth kernel: [    3.821358] device: 'ttyS1': device_create_release
> Oct 18 14:25:30 earth kernel: [    3.821419] 00:08: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> Oct 18 14:25:30 earth kernel: [    3.888201] device: 'ttyS1': device_add
> Oct 18 14:25:30 earth kernel: [    3.888277] driver: '00:08': driver_bound: bound to device 'serial'
> Oct 18 14:25:30 earth kernel: [    3.888280] bus: 'pnp': really_probe: bound device 00:08 to driver serial
> Oct 18 14:25:30 earth kernel: [    3.888346] bus: 'pci': add driver serial
> Oct 18 14:25:30 earth kernel: [    3.888442] ThunderLAN driver v1.15
> Oct 18 14:25:30 earth kernel: [    3.930260] bus: 'pci': add driver tlan
> Oct 18 14:25:30 earth kernel: [    3.930271] bus: 'pci': driver_probe_device: matched device 0000:00:0f.0 with driver tlan
> Oct 18 14:25:30 earth kernel: [    3.930275] bus: 'pci': really_probe: probing driver tlan with device 0000:00:0f.0
> Oct 18 14:25:30 earth kernel: [    3.931212] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
> Oct 18 14:25:30 earth kernel: [    4.000082] PCI: setting IRQ 11 as level-triggered
> Oct 18 14:25:30 earth kernel: [    4.000089] tlan 0000:00:0f.0: PCI INT A -> Link[LNKB] -> GSI 11 (level, low) -> IRQ 11
> Oct 18 14:25:30 earth kernel: [    4.098616] device: 'eth0': device_add
> Oct 18 14:25:30 earth kernel: [    4.098811] TLAN: eth0 irq=11, io=dc00, Compaq Netelligent 10/100 TX PCI UTP, Rev. 16
> Oct 18 14:25:30 earth kernel: [    4.192619] driver: '0000:00:0f.0': driver_bound: bound to device 'tlan'
> Oct 18 14:25:30 earth kernel: [    4.192623] bus: 'pci': really_probe: bound device 0000:00:0f.0 to driver tlan
> Oct 18 14:25:30 earth kernel: [    4.192696] TLAN: 1 device installed, PCI: 1  EISA: 0
> Oct 18 14:25:30 earth kernel: [    4.253316] bus: 'pci': add driver 8139cp
> Oct 18 14:25:30 earth kernel: [    4.253327] bus: 'pci': driver_probe_device: matched device 0000:00:10.0 with driver 8139cp
> Oct 18 14:25:30 earth kernel: [    4.253331] bus: 'pci': really_probe: probing driver 8139cp with device 0000:00:10.0
> Oct 18 14:25:30 earth kernel: [    4.253342] 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
> Oct 18 14:25:30 earth kernel: [    4.327393] 8139cp 0000:00:10.0: This (id 10ec:8139 rev 10) is not an 8139C+ compatible chip
> Oct 18 14:25:30 earth kernel: [    4.428551] 8139cp 0000:00:10.0: Try the "8139too" driver instead.
> Oct 18 14:25:30 earth kernel: [    4.502718] bus: 'pci': add driver 8139too
> Oct 18 14:25:30 earth kernel: [    4.502729] bus: 'pci': driver_probe_device: matched device 0000:00:10.0 with driver 8139too
> Oct 18 14:25:30 earth kernel: [    4.502733] bus: 'pci': really_probe: probing driver 8139too with device 0000:00:10.0
> Oct 18 14:25:30 earth kernel: [    4.502740] 8139too Fast Ethernet driver 0.9.28
> Oct 18 14:25:30 earth kernel: [    4.558153] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 12
> Oct 18 14:25:30 earth kernel: [    4.627023] PCI: setting IRQ 12 as level-triggered
> Oct 18 14:25:30 earth kernel: [    4.627030] 8139too 0000:00:10.0: PCI INT A -> Link[LNKA] -> GSI 12 (level, low) -> IRQ 12
> Oct 18 14:25:30 earth kernel: [    4.726354] device: 'eth1': device_add
> Oct 18 14:25:30 earth kernel: [    4.726506] eth1: RealTek RTL8139 at 0xf880a000, 00:c0:df:0b:f9:a4, IRQ 12
> Oct 18 14:25:30 earth kernel: [    4.808946] eth1:  Identified 8139 chip type 'RTL-8139C'
> Oct 18 14:25:30 earth kernel: [    4.808950] driver: '0000:00:10.0': driver_bound: bound to device '8139too'
> Oct 18 14:25:30 earth kernel: [    4.808954] bus: 'pci': really_probe: bound device 0000:00:10.0 to driver 8139too
> Oct 18 14:25:30 earth kernel: [    4.809018] Uniform Multi-Platform E-IDE driver
> Oct 18 14:25:30 earth kernel: [    4.863329] bus: 'ide': registered
> Oct 18 14:25:30 earth kernel: [    4.863333] device class 'ide_port': registering
> Oct 18 14:25:30 earth kernel: [    4.863415] bus: 'pci': add driver HPT366_IDE
> Oct 18 14:25:30 earth kernel: [    4.863474] bus: 'pci': add driver SiI_IDE
> Oct 18 14:25:30 earth kernel: [    4.863540] bus: 'pci': add driver VIA_IDE
> Oct 18 14:25:30 earth kernel: [    4.863593] bus: 'pci': add driver PCI_IDE
> Oct 18 14:25:30 earth kernel: [    4.863654] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
> Oct 18 14:25:30 earth kernel: [    4.980471] Probing IDE interface ide0...
> Oct 18 14:25:30 earth kernel: [    5.257626] Switched to high resolution mode on CPU 0
> Oct 18 14:25:30 earth kernel: [    5.540021] device: 'ide0': device_add
> Oct 18 14:25:30 earth kernel: [    5.540036] device: 'ide0': device_add
> Oct 18 14:25:30 earth kernel: [    5.540100] Probing IDE interface ide1...
> Oct 18 14:25:30 earth kernel: [    6.100020] device: 'ide1': device_add
> Oct 18 14:25:30 earth kernel: [    6.100034] device: 'ide1': device_add
> Oct 18 14:25:30 earth kernel: [    6.100130] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> Oct 18 14:25:30 earth kernel: [    6.154638] ide1 at 0x170-0x177,0x376 on irq 15
> Oct 18 14:25:30 earth kernel: [    6.209172] device class 'ide_generic': registering
> Oct 18 14:25:30 earth kernel: [    6.209224] bus: 'ide': add driver ide-disk
> Oct 18 14:25:30 earth kernel: [    6.209274] bus: 'ide': add driver ide-cdrom
> Oct 18 14:25:30 earth kernel: [    6.209328] device class 'scsi_disk': registering
> Oct 18 14:25:30 earth kernel: [    6.209435] Driver 'sd' needs updating - please use bus_type methods
> Oct 18 14:25:30 earth kernel: [    6.285557] bus: 'scsi': add driver sd
> Oct 18 14:25:30 earth kernel: [    6.285610] bus: 'pci': add driver sata_sil
> Oct 18 14:25:30 earth kernel: [    6.285621] bus: 'pci': driver_probe_device: matched device 0000:00:0b.0 with driver sata_sil
> Oct 18 14:25:30 earth kernel: [    6.285626] bus: 'pci': really_probe: probing driver sata_sil with device 0000:00:0b.0
> Oct 18 14:25:30 earth kernel: [    6.285635] sata_sil 0000:00:0b.0: version 2.3
> Oct 18 14:25:30 earth kernel: [    6.286433] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
> Oct 18 14:25:30 earth kernel: [    6.355294] PCI: setting IRQ 10 as level-triggered
> Oct 18 14:25:30 earth kernel: [    6.355302] sata_sil 0000:00:0b.0: PCI INT A -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [    6.455520] scsi0 : sata_sil
> Oct 18 14:25:30 earth kernel: [    6.490068] device: 'host0': device_add
> Oct 18 14:25:30 earth kernel: [    6.490080] bus: 'scsi': add device host0
> Oct 18 14:25:30 earth kernel: [    6.490161] device: 'host0': device_add
> Oct 18 14:25:30 earth kernel: [    6.490271] scsi1 : sata_sil
> Oct 18 14:25:30 earth kernel: [    6.524846] device: 'host1': device_add
> Oct 18 14:25:30 earth kernel: [    6.524854] bus: 'scsi': add device host1
> Oct 18 14:25:30 earth kernel: [    6.524954] device: 'host1': device_add
> Oct 18 14:25:30 earth kernel: [    6.525044] ata1: SATA max UDMA/100 mmio m512@0xe7000000 tf 0xe7000080 irq 10
> Oct 18 14:25:30 earth kernel: [    6.610583] ata2: SATA max UDMA/100 mmio m512@0xe7000000 tf 0xe70000c0 irq 10
> Oct 18 14:25:30 earth kernel: [    7.016033] ata1: SATA link down (SStatus 0 SControl 310)
> Oct 18 14:25:30 earth kernel: [    7.400042] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
> Oct 18 14:25:30 earth kernel: [    7.481288] ata2.00: ATA-7: Maxtor 6L300S0, BANC1G10, max UDMA/133
> Oct 18 14:25:30 earth kernel: [    7.555366] ata2.00: 586114704 sectors, multi 0: LBA48 NCQ (not used)
> Oct 18 14:25:30 earth kernel: [    7.649282] ata2.00: configured for UDMA/100
> Oct 18 14:25:30 earth kernel: [    7.700595] scsi 1:0:0:0: Direct-Access     ATA      Maxtor 6L300S0   BANC PQ: 0 ANSI: 5
> Oct 18 14:25:30 earth kernel: [    7.797552] device: 'target1:0:0': device_add
> Oct 18 14:25:30 earth kernel: [    7.797561] bus: 'scsi': add device target1:0:0
> Oct 18 14:25:30 earth kernel: [    7.797624] device: '1:0:0:0': device_add
> Oct 18 14:25:30 earth kernel: [    7.797656] bus: 'scsi': add device 1:0:0:0
> Oct 18 14:25:30 earth kernel: [    7.797718] bus: 'scsi': driver_probe_device: matched device 1:0:0:0 with driver sd
> Oct 18 14:25:30 earth kernel: [    7.797722] bus: 'scsi': really_probe: probing driver sd with device 1:0:0:0
> Oct 18 14:25:30 earth kernel: [    7.797755] device: '1:0:0:0': device_add
> Oct 18 14:25:30 earth kernel: [    7.797887] sd 1:0:0:0: [sda] 586114704 512-byte hardware sectors (300091 MB)
> Oct 18 14:25:30 earth kernel: [    7.883522] sd 1:0:0:0: [sda] Write Protect is off
> Oct 18 14:25:30 earth kernel: [    7.940963] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
> Oct 18 14:25:30 earth kernel: [    7.941011] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> Oct 18 14:25:30 earth kernel: [    8.049422] device: 'sda': device_add
> Oct 18 14:25:30 earth kernel: [    8.049526] sd 1:0:0:0: [sda] 586114704 512-byte hardware sectors (300091 MB)
> Oct 18 14:25:30 earth kernel: [    8.135082] sd 1:0:0:0: [sda] Write Protect is off
> Oct 18 14:25:30 earth kernel: [    8.192510] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
> Oct 18 14:25:30 earth kernel: [    8.192549] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> Oct 18 14:25:30 earth kernel: [    8.300958]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 >
> Oct 18 14:25:30 earth kernel: [    8.419796] device: 'sda1': device_add
> Oct 18 14:25:30 earth kernel: [    8.419826] device: 'sda2': device_add
> Oct 18 14:25:30 earth kernel: [    8.419851] device: 'sda3': device_add
> Oct 18 14:25:30 earth kernel: [    8.419875] device: 'sda4': device_add
> Oct 18 14:25:30 earth kernel: [    8.419902] device: 'sda5': device_add
> Oct 18 14:25:30 earth kernel: [    8.419951] device: 'sda6': device_add
> Oct 18 14:25:30 earth kernel: [    8.420551] device: '8:0': device_add
> Oct 18 14:25:30 earth kernel: [    8.420630] sd 1:0:0:0: [sda] Attached SCSI disk
> Oct 18 14:25:30 earth kernel: [    8.476016] driver: '1:0:0:0': driver_bound: bound to device 'sd'
> Oct 18 14:25:30 earth kernel: [    8.476020] bus: 'scsi': really_probe: bound device 1:0:0:0 to driver sd
> Oct 18 14:25:30 earth kernel: [    8.476025] device: '1:0:0:0': device_add
> Oct 18 14:25:30 earth kernel: [    8.476105] driver: '0000:00:0b.0': driver_bound: bound to device 'sata_sil'
> Oct 18 14:25:30 earth kernel: [    8.476109] bus: 'pci': really_probe: bound device 0000:00:0b.0 to driver sata_sil
> Oct 18 14:25:30 earth kernel: [    8.476229] bus: 'pci': add driver sata_sil24
> Oct 18 14:25:30 earth kernel: [    8.476296] bus: 'pci': add driver sata_via
> Oct 18 14:25:30 earth kernel: [    8.476306] bus: 'pci': driver_probe_device: matched device 0000:00:0d.3 with driver sata_via
> Oct 18 14:25:30 earth kernel: [    8.476310] bus: 'pci': really_probe: probing driver sata_via with device 0000:00:0d.3
> Oct 18 14:25:30 earth kernel: [    8.476319] sata_via 0000:00:0d.3: version 2.3
> Oct 18 14:25:30 earth kernel: [    8.476343] sata_via 0000:00:0d.3: PCI INT A -> Link[LNKB] -> GSI 11 (level, low) -> IRQ 11
> Oct 18 14:25:30 earth kernel: [    8.576517] sata_via 0000:00:0d.3: routed to hard irq line 11
> Oct 18 14:25:30 earth kernel: [    8.645546] scsi2 : sata_via
> Oct 18 14:25:30 earth kernel: [    8.680102] device: 'host2': device_add
> Oct 18 14:25:30 earth kernel: [    8.680112] bus: 'scsi': add device host2
> Oct 18 14:25:30 earth kernel: [    8.680202] device: 'host2': device_add
> Oct 18 14:25:30 earth kernel: [    8.680379] scsi3 : sata_via
> Oct 18 14:25:30 earth kernel: [    8.714896] device: 'host3': device_add
> Oct 18 14:25:30 earth kernel: [    8.714904] bus: 'scsi': add device host3
> Oct 18 14:25:30 earth kernel: [    8.714958] device: 'host3': device_add
> Oct 18 14:25:30 earth kernel: [    8.715053] scsi4 : sata_via
> Oct 18 14:25:30 earth kernel: [    8.749622] device: 'host4': device_add
> Oct 18 14:25:30 earth kernel: [    8.749631] bus: 'scsi': add device host4
> Oct 18 14:25:30 earth kernel: [    8.749731] device: 'host4': device_add
> Oct 18 14:25:30 earth kernel: [    8.749811] ata3: SATA max UDMA/133 port i16@0xc400 bmdma 0xd400 irq 11
> Oct 18 14:25:30 earth kernel: [    8.829146] ata4: SATA max UDMA/133 port i16@0xc800 bmdma 0xd408 irq 11
> Oct 18 14:25:30 earth kernel: [    8.908438] ata5: PATA max UDMA/133 port i16@0xcc00 bmdma 0xd410 irq 11
> Oct 18 14:25:30 earth kernel: [    9.314571] ata3: SATA link down (SStatus 0 SControl 310)
> Oct 18 14:25:30 earth kernel: [    9.706570] ata4: SATA link down (SStatus 0 SControl 310)
> Oct 18 14:25:30 earth kernel: [    9.940401] ata5.01: ATAPI: TEAC DVD+RW DV-W58E, D.0J, max UDMA/33
> Oct 18 14:25:30 earth kernel: [   10.028396] ata5.01: configured for UDMA/33
> Oct 18 14:25:30 earth kernel: [   10.080040] scsi 4:0:1:0: CD-ROM            TEAC     DVD+RW DV-W58E   D.0J PQ: 0 ANSI: 5
> Oct 18 14:25:30 earth kernel: [   10.177005] device: 'target4:0:1': device_add
> Oct 18 14:25:30 earth kernel: [   10.177017] bus: 'scsi': add device target4:0:1
> Oct 18 14:25:30 earth kernel: [   10.177087] device: '4:0:1:0': device_add
> Oct 18 14:25:30 earth kernel: [   10.177114] bus: 'scsi': add device 4:0:1:0
> Oct 18 14:25:30 earth kernel: [   10.177228] bus: 'scsi': driver_probe_device: matched device 4:0:1:0 with driver sd
> Oct 18 14:25:30 earth kernel: [   10.177232] bus: 'scsi': really_probe: probing driver sd with device 4:0:1:0
> Oct 18 14:25:30 earth kernel: [   10.177248] device: '4:0:1:0': device_add
> Oct 18 14:25:30 earth kernel: [   10.177342] driver: '0000:00:0d.3': driver_bound: bound to device 'sata_via'
> Oct 18 14:25:30 earth kernel: [   10.177347] bus: 'pci': really_probe: bound device 0000:00:0d.3 to driver sata_via
> Oct 18 14:25:30 earth kernel: [   10.177440] bus: 'pci': add driver sata_sis
> Oct 18 14:25:30 earth kernel: [   10.177569] bus: 'pci': add driver pata_via
> Oct 18 14:25:30 earth kernel: [   10.177665] bus: 'pci': add driver pata_sis
> Oct 18 14:25:30 earth kernel: [   10.177723] bus: 'platform': add driver pata_platform
> Oct 18 14:25:30 earth kernel: [   10.177777] bus: 'pci': add driver ata_generic
> Oct 18 14:25:30 earth kernel: [   10.177855] bus: 'pnp': add driver i8042 kbd
> Oct 18 14:25:30 earth kernel: [   10.177871] bus: 'pnp': driver_probe_device: matched device 00:09 with driver i8042 kbd
> Oct 18 14:25:30 earth kernel: [   10.177875] bus: 'pnp': really_probe: probing driver i8042 kbd with device 00:09
> Oct 18 14:25:30 earth kernel: [   10.177886] driver: '00:09': driver_bound: bound to device 'i8042 kbd'
> Oct 18 14:25:30 earth kernel: [   10.177889] bus: 'pnp': really_probe: bound device 00:09 to driver i8042 kbd
> Oct 18 14:25:30 earth kernel: [   10.177968] bus: 'pnp': add driver i8042 aux
> Oct 18 14:25:30 earth kernel: [   10.178066] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
> Oct 18 14:25:30 earth kernel: [   10.252155] PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
> Oct 18 14:25:30 earth kernel: [   10.367885] bus: 'platform': add driver i8042
> Oct 18 14:25:30 earth kernel: [   10.367952] Registering platform device 'i8042'. Parent at platform
> Oct 18 14:25:30 earth kernel: [   10.367956] device: 'i8042': device_add
> Oct 18 14:25:30 earth kernel: [   10.367965] bus: 'platform': add device i8042
> Oct 18 14:25:30 earth kernel: [   10.368040] bus: 'platform': driver_probe_device: matched device i8042 with driver i8042
> Oct 18 14:25:30 earth kernel: [   10.368044] bus: 'platform': really_probe: probing driver i8042 with device i8042
> Oct 18 14:25:30 earth kernel: [   10.368081] serio: i8042 KBD port at 0x60,0x64 irq 1
> Oct 18 14:25:30 earth kernel: [   10.427645] driver: 'i8042': driver_bound: bound to device 'i8042'
> Oct 18 14:25:30 earth kernel: [   10.427649] bus: 'platform': really_probe: bound device i8042 to driver i8042
> Oct 18 14:25:30 earth kernel: [   10.427658] device: 'mice': device_add
> Oct 18 14:25:30 earth kernel: [   10.427708] device: 'serio0': device_add
> Oct 18 14:25:30 earth kernel: [   10.427716] bus: 'serio': add device serio0
> Oct 18 14:25:30 earth kernel: [   10.427852] device: 'psaux': device_add
> Oct 18 14:25:30 earth kernel: [   10.427953] mice: PS/2 mouse device common for all mice
> Oct 18 14:25:30 earth kernel: [   10.490578] bus: 'serio': add driver atkbd
> Oct 18 14:25:30 earth kernel: [   10.490702] bus: 'serio': add driver psmouse
> Oct 18 14:25:30 earth kernel: [   10.490776] bus: 'pnp': add driver rtc_cmos
> Oct 18 14:25:30 earth kernel: [   10.490786] bus: 'pnp': driver_probe_device: matched device 00:04 with driver rtc_cmos
> Oct 18 14:25:30 earth kernel: [   10.490790] bus: 'pnp': really_probe: probing driver rtc_cmos with device 00:04
> Oct 18 14:25:30 earth kernel: [   10.490873] device: 'rtc0': device_add
> Oct 18 14:25:30 earth kernel: [   10.490941] bus: 'serio': driver_probe_device: matched device serio0 with driver atkbd
> Oct 18 14:25:30 earth kernel: [   10.490945] bus: 'serio': really_probe: probing driver atkbd with device serio0
> Oct 18 14:25:30 earth kernel: [   10.490985] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
> Oct 18 14:25:30 earth kernel: [   10.564099] rtc0: alarms up to one year, y3k
> Oct 18 14:25:30 earth kernel: [   10.615264] driver: '00:04': driver_bound: bound to device 'rtc_cmos'
> Oct 18 14:25:30 earth kernel: [   10.615268] bus: 'pnp': really_probe: bound device 00:04 to driver rtc_cmos
> Oct 18 14:25:30 earth kernel: [   10.615334] device class 'sound': registering
> Oct 18 14:25:30 earth kernel: [   10.615700] Advanced Linux Sound Architecture Driver Version 1.0.17.
> Oct 18 14:25:30 earth kernel: [   10.691917] device: 'timer': device_add
> Oct 18 14:25:30 earth kernel: [   10.692066] device: 'sequencer': device_add
> Oct 18 14:25:30 earth kernel: [   10.692131] device: 'sequencer2': device_add
> Oct 18 14:25:30 earth kernel: [   10.692336] device: 'seq': device_add
> Oct 18 14:25:30 earth kernel: [   10.692507] bus: 'pci': add driver EMU10K1_Audigy
> Oct 18 14:25:30 earth kernel: [   10.692522] bus: 'pci': driver_probe_device: matched device 0000:00:09.0 with driver EMU10K1_Audigy
> Oct 18 14:25:30 earth kernel: [   10.692526] bus: 'pci': really_probe: probing driver EMU10K1_Audigy with device 0000:00:09.0
> Oct 18 14:25:30 earth kernel: [   10.693153] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
> Oct 18 14:25:30 earth kernel: [   10.760987] PCI: setting IRQ 5 as level-triggered
> Oct 18 14:25:30 earth kernel: [   10.760995] EMU10K1_Audigy 0000:00:09.0: PCI INT A -> Link[LNKC] -> GSI 5 (level, low) -> IRQ 5
> Oct 18 14:25:30 earth kernel: [   10.879307] device: 'card0': device_add
> Oct 18 14:25:30 earth kernel: [   10.879629] device: 'hwC0D0': device_add
> Oct 18 14:25:30 earth kernel: [   10.879712] device: 'midiC0D0': device_add
> Oct 18 14:25:30 earth kernel: [   10.879784] device: 'midi': device_add
> Oct 18 14:25:30 earth kernel: [   10.879886] device: 'dmmidi': device_add
> Oct 18 14:25:30 earth kernel: [   10.880042] device: 'pcmC0D3p': device_add
> Oct 18 14:25:30 earth kernel: [   10.880132] device: '0-0:STAC9708,11': device_add
> Oct 18 14:25:30 earth kernel: [   10.880142] bus: 'ac97': add device 0-0:STAC9708,11
> Oct 18 14:25:30 earth kernel: [   10.880203] device: 'pcmC0D2p': device_add
> Oct 18 14:25:30 earth kernel: [   10.880318] device: 'pcmC0D2c': device_add
> Oct 18 14:25:30 earth kernel: [   10.880401] device: 'pcmC0D1c': device_add
> Oct 18 14:25:30 earth kernel: [   10.880475] device: 'adsp': device_add
> Oct 18 14:25:30 earth kernel: [   10.880623] device: 'pcmC0D0p': device_add
> Oct 18 14:25:30 earth kernel: [   10.880826] device: 'pcmC0D0c': device_add
> Oct 18 14:25:30 earth kernel: [   10.880900] device: 'dsp': device_add
> Oct 18 14:25:30 earth kernel: [   10.880967] device: 'audio': device_add
> Oct 18 14:25:30 earth kernel: [   10.881102] device: 'controlC0': device_add
> Oct 18 14:25:30 earth kernel: [   10.881194] device: 'mixer': device_add
> Oct 18 14:25:30 earth kernel: [   10.882077] driver: '0000:00:09.0': driver_bound: bound to device 'EMU10K1_Audigy'
> Oct 18 14:25:30 earth kernel: [   10.882083] bus: 'pci': really_probe: bound device 0000:00:09.0 to driver EMU10K1_Audigy
> Oct 18 14:25:30 earth kernel: [   10.882220] device: 'hwC0D2': device_add
> Oct 18 14:25:30 earth kernel: [   10.882461] device: 'midiC0D1': device_add
> Oct 18 14:25:30 earth kernel: [   10.882574] device: 'amidi': device_add
> Oct 18 14:25:30 earth kernel: [   10.882656] device: 'admmidi': device_add
> Oct 18 14:25:30 earth kernel: [   10.882907] device: 'midiC0D2': device_add
> Oct 18 14:25:30 earth kernel: [   10.882988] ALSA device list:
> Oct 18 14:25:30 earth kernel: [   10.918582]   #0: SBLive 5.1 [SB0060] (rev.7, serial:0x80611102) at 0xa000, irq 5
> Oct 18 14:25:30 earth kernel: [   11.008277] TCP cubic registered
> Oct 18 14:25:30 earth kernel: [   11.046958] NET: Registered protocol family 17
> Oct 18 14:25:30 earth kernel: [   11.100271] Using IPI Shortcut mode
> Oct 18 14:25:30 earth kernel: [   11.142098] device: 'cpu_dma_latency': device_add
> Oct 18 14:25:30 earth kernel: [   11.142257] device: 'network_latency': device_add
> Oct 18 14:25:30 earth kernel: [   11.142355] device: 'network_throughput': device_add
> Oct 18 14:25:30 earth kernel: [   11.142820] rtc_cmos 00:04: setting system clock to 2008-10-18 14:24:29 UTC (1224339869)
> Oct 18 14:25:30 earth kernel: [   11.239881] driver_probe_done: probe_count = 1
> Oct 18 14:25:30 earth kernel: [   11.242227] device: 'input0': device_add
> Oct 18 14:25:30 earth kernel: [   11.242382] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
> Oct 18 14:25:30 earth kernel: [   11.345659] driver_probe_done: probe_count = 1
> Oct 18 14:25:30 earth kernel: [   11.345701] device: 'event0': device_add
> Oct 18 14:25:30 earth kernel: [   11.345774] driver: 'serio0': driver_bound: bound to device 'atkbd'
> Oct 18 14:25:30 earth kernel: [   11.345779] bus: 'serio': really_probe: bound device serio0 to driver atkbd
> Oct 18 14:25:30 earth kernel: [   11.448021] driver_probe_done: probe_count = 0
> Oct 18 14:25:30 earth kernel: [   11.488866] EXT3-fs: INFO: recovery required on readonly filesystem.
> Oct 18 14:25:30 earth kernel: [   11.565038] EXT3-fs: write access will be enabled during recovery.
> Oct 18 14:25:30 earth kernel: [   14.460056] kjournald starting.  Commit interval 5 seconds
> Oct 18 14:25:30 earth kernel: [   14.525869] EXT3-fs: sda3: orphan cleanup on readonly fs
> Oct 18 14:25:30 earth kernel: [   14.589547] ext3_orphan_cleanup: deleting unreferenced inode 1651642
> Oct 18 14:25:30 earth kernel: [   14.589603] ext3_orphan_cleanup: deleting unreferenced inode 2731932
> Oct 18 14:25:30 earth kernel: [   14.635262] ext3_orphan_cleanup: deleting unreferenced inode 1880759
> Oct 18 14:25:30 earth kernel: [   14.692413] ext3_orphan_cleanup: deleting unreferenced inode 2730830
> Oct 18 14:25:30 earth kernel: [   14.869340] ext3_orphan_cleanup: deleting unreferenced inode 2731480
> Oct 18 14:25:30 earth kernel: [   14.879458] ext3_orphan_cleanup: deleting unreferenced inode 784904
> Oct 18 14:25:30 earth kernel: [   14.879469] ext3_orphan_cleanup: deleting unreferenced inode 784903
> Oct 18 14:25:30 earth kernel: [   14.879477] ext3_orphan_cleanup: deleting unreferenced inode 784902
> Oct 18 14:25:30 earth kernel: [   14.879485] ext3_orphan_cleanup: deleting unreferenced inode 784901
> Oct 18 14:25:30 earth kernel: [   14.879492] ext3_orphan_cleanup: deleting unreferenced inode 784900
> Oct 18 14:25:30 earth kernel: [   14.879499] EXT3-fs: sda3: 10 orphan inodes deleted
> Oct 18 14:25:30 earth kernel: [   14.937982] EXT3-fs: recovery complete.
> Oct 18 14:25:30 earth kernel: [   14.991288] EXT3-fs: mounted filesystem with ordered data mode.
> Oct 18 14:25:30 earth kernel: [   15.062275] VFS: Mounted root (ext3 filesystem) readonly.
> Oct 18 14:25:30 earth kernel: [   15.127235] Freeing unused kernel memory: 168k freed
> Oct 18 14:25:30 earth kernel: [   15.395297] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   15.438325] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   17.974729] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.974905] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.974908] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.974968] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.974997] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   17.975083] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   17.975301] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.975364] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.975367] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.975425] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.987062] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   17.987201] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   17.987333] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.987396] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.987399] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.987452] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.987473] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   17.987552] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   17.987773] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.987834] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.987838] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.987898] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.987921] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   17.988699] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   17.989014] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.989742] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   17.989747] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   17.991085] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   18.008904] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   18.009039] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   19.307201] device: 'device:00': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309369] device: 'device:01': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309392] device: 'device:02': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309414] device: 'device:03': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309437] device: 'device:04': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309460] device: 'device:05': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309482] device: 'device:06': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309505] device: 'device:07': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309528] device: 'device:08': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309549] device: 'device:09': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309570] device: 'device:0a': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309591] device: 'device:0b': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.309616] device: 'device:0c': dev_uevent: bus uevent() returned -12
> Oct 18 14:25:30 earth kernel: [   19.964667] bus: 'i2c': registered
> Oct 18 14:25:30 earth kernel: [   19.964673] device class 'i2c-adapter': registering
> Oct 18 14:25:30 earth kernel: [   19.964695] bus: 'i2c': add driver dummy
> Oct 18 14:25:30 earth kernel: [   19.993360] device class 'dvb': registering
> Oct 18 14:25:30 earth kernel: [   20.023783] Linux video capture interface: v2.00
> Oct 18 14:25:30 earth kernel: [   20.079198] device class 'video4linux': registering
> Oct 18 14:25:30 earth kernel: [   20.128949] cx2388x alsa driver version 0.0.6 loaded
> Oct 18 14:25:30 earth kernel: [   20.188488] bus: 'pci': add driver cx88_audio
> Oct 18 14:25:30 earth kernel: [   20.188513] bus: 'pci': driver_probe_device: matched device 0000:00:08.1 with driver cx88_audio
> Oct 18 14:25:30 earth kernel: [   20.188518] bus: 'pci': really_probe: probing driver cx88_audio with device 0000:00:08.1
> Oct 18 14:25:30 earth kernel: [   20.188572] cx88_audio 0000:00:08.1: PCI INT A -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   20.291230] cx88[0]: subsystem: 0070:1402, board: Hauppauge WinTV-HVR3000 TriMode Analog/DVB-S/DVB-T [card=53,autodetected], frontend(s): 2
> Oct 18 14:25:30 earth kernel: [   20.441331] cx88[0]: TV tuner type 63, Radio tuner type -1
> Oct 18 14:25:30 earth kernel: [   20.543667] cx88/0: cx2388x v4l2 driver version 0.0.6 loaded
> Oct 18 14:25:30 earth kernel: [   20.611576] bus: 'pci': add driver cx8800
> Oct 18 14:25:30 earth kernel: [   20.642127] device: 'i2c-0': device_add
> Oct 18 14:25:30 earth kernel: [   20.642204] cx88[0]: i2c init: enabling analog demod on HVR1300/3000/4000 tuner
> Oct 18 14:25:30 earth kernel: [   20.739369] cx88/2: cx2388x MPEG-TS Driver Manager version 0.0.6 loaded
> Oct 18 14:25:30 earth kernel: [   20.818717] bus: 'pci': add driver cx88-mpeg driver manager
> Oct 18 14:25:30 earth kernel: [   20.831853] bus: 'i2c': add driver tuner'
> Oct 18 14:25:30 earth kernel: [   20.924588] tuner' 0-0043: chip found @ 0x86 (cx88[0])
> Oct 18 14:25:30 earth kernel: [   21.066079] tda9887 0-0043: creating new instance
> Oct 18 14:25:30 earth kernel: [   21.122653] tda9887 0-0043: tda988[5/6/7] found
> Oct 18 14:25:30 earth kernel: [   21.177716] device: '0-0043': device_add
> Oct 18 14:25:30 earth kernel: [   21.177740] bus: 'i2c': add device 0-0043
> Oct 18 14:25:30 earth kernel: [   21.177760] driver: '0-0043': driver_bound: bound to device 'tuner''
> Oct 18 14:25:30 earth kernel: [   21.183110] tuner' 0-0061: chip found @ 0xc2 (cx88[0])
> Oct 18 14:25:30 earth kernel: [   21.244768] device: '0-0061': device_add
> Oct 18 14:25:30 earth kernel: [   21.244790] bus: 'i2c': add device 0-0061
> Oct 18 14:25:30 earth kernel: [   21.244810] driver: '0-0061': driver_bound: bound to device 'tuner''
> Oct 18 14:25:30 earth kernel: [   21.248681] tuner' 0-0063: chip found @ 0xc6 (cx88[0])
> Oct 18 14:25:30 earth kernel: [   21.310443] device: '0-0063': device_add
> Oct 18 14:25:30 earth kernel: [   21.310465] bus: 'i2c': add device 0-0063
> Oct 18 14:25:30 earth kernel: [   21.310486] driver: '0-0063': driver_bound: bound to device 'tuner''
> Oct 18 14:25:30 earth kernel: [   21.332003] bus: 'i2c': add driver tuner
> Oct 18 14:25:30 earth kernel: [   21.471194] tveeprom 0-0050: Hauppauge model 14109, rev B3A0, serial# 1531431
> Oct 18 14:25:30 earth kernel: [   21.556694] tveeprom 0-0050: MAC address is 00-0D-FE-17-5E-27
> Oct 18 14:25:30 earth kernel: [   21.625588] tveeprom 0-0050: tuner model is Philips FMD1216ME (idx 100, type 63)
> Oct 18 14:25:30 earth kernel: [   21.714261] tveeprom 0-0050: TV standards PAL(B/G) PAL(I) SECAM(L/L') PAL(D/D1/K) ATSC/DVB Digital (eeprom 0xf4)
> Oct 18 14:25:30 earth kernel: [   21.836237] tveeprom 0-0050: audio processor is CX882 (idx 33)
> Oct 18 14:25:30 earth kernel: [   21.906172] tveeprom 0-0050: decoder processor is CX882 (idx 25)
> Oct 18 14:25:30 earth kernel: [   21.978191] tveeprom 0-0050: has radio, has IR receiver, has no IR transmitter
> Oct 18 14:25:30 earth kernel: [   22.064781] cx88[0]: hauppauge eeprom: model=14109
> Oct 18 14:25:30 earth kernel: [   22.191142] bus: 'usb': registered
> Oct 18 14:25:30 earth kernel: [   22.191149] device class 'usb_host': registering
> Oct 18 14:25:30 earth kernel: [   22.191175] bus: 'usb': add driver usbfs
> Oct 18 14:25:30 earth kernel: [   22.191204] usbcore: registered new interface driver usbfs
> Oct 18 14:25:30 earth kernel: [   22.257185] bus: 'usb': add driver hub
> Oct 18 14:25:30 earth kernel: [   22.257203] usbcore: registered new interface driver hub
> Oct 18 14:25:30 earth kernel: [   22.390663] Driver 'sr' needs updating - please use bus_type methods
> Oct 18 14:25:30 earth kernel: [   22.466845] bus: 'scsi': add driver sr
> Oct 18 14:25:30 earth kernel: [   22.466861] bus: 'scsi': driver_probe_device: matched device 4:0:1:0 with driver sr
> Oct 18 14:25:30 earth kernel: [   22.466865] bus: 'scsi': really_probe: probing driver sr with device 4:0:1:0
> Oct 18 14:25:30 earth kernel: [   22.523335] sr0: scsi3-mmc drive: 40x/40x writer cd/rw xa/form2 cdda tray
> Oct 18 14:25:30 earth kernel: [   22.604913] Uniform CD-ROM driver Revision: 3.20
> Oct 18 14:25:30 earth kernel: [   22.661203] device: 'sr0': device_add
> Oct 18 14:25:30 earth kernel: [   22.661354] device: '11:0': device_add
> Oct 18 14:25:30 earth kernel: [   22.661561] sr 4:0:1:0: Attached scsi CD-ROM sr0
> Oct 18 14:25:30 earth kernel: [   22.661566] driver: '4:0:1:0': driver_bound: bound to device 'sr'
> Oct 18 14:25:30 earth kernel: [   22.661571] bus: 'scsi': really_probe: bound device 4:0:1:0 to driver sr
> Oct 18 14:25:30 earth kernel: [   22.793949] bus: 'platform': add driver pcspkr
> Oct 18 14:25:30 earth kernel: [   22.793966] bus: 'platform': driver_probe_device: matched device pcspkr with driver pcspkr
> Oct 18 14:25:30 earth kernel: [   22.793970] bus: 'platform': really_probe: probing driver pcspkr with device pcspkr
> Oct 18 14:25:30 earth kernel: [   22.793986] device: 'input1': device_add
> Oct 18 14:25:30 earth kernel: [   22.794070] input: PC Speaker as /devices/platform/pcspkr/input/input1
> Oct 18 14:25:30 earth kernel: [   23.019906] bus: 'usb': add driver usb
> Oct 18 14:25:30 earth kernel: [   23.019972] usbcore: registered new device driver usb
> Oct 18 14:25:30 earth kernel: [   23.101491] device: 'event1': device_add
> Oct 18 14:25:30 earth kernel: [   23.101605] driver: 'pcspkr': driver_bound: bound to device 'pcspkr'
> Oct 18 14:25:30 earth kernel: [   23.101612] bus: 'platform': really_probe: bound device pcspkr to driver pcspkr
> Oct 18 14:25:30 earth kernel: [   23.130752] USB Universal Host Controller Interface driver v3.0
> Oct 18 14:25:30 earth kernel: [   23.201741] bus: 'pci': add driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   23.251171] tuner-simple 0-0061: creating new instance
> Oct 18 14:25:30 earth kernel: [   23.312766] tuner-simple 0-0061: type set to 63 (Philips FMD1216ME MK3 Hybrid Tuner)
> Oct 18 14:25:30 earth kernel: [   23.409240] device: 'input2': device_add
> Oct 18 14:25:30 earth kernel: [   23.409423] input: cx88 IR (Hauppauge WinTV-HVR300 as /devices/pci0000:00/0000:00:08.1/input/input2
> Oct 18 14:25:30 earth kernel: [   23.548117] device: 'event2': device_add
> Oct 18 14:25:30 earth kernel: [   23.548335] cx88[0]/1: CX88x/0: ALSA support for cx2388x boards
> Oct 18 14:25:30 earth kernel: [   23.619415] device: 'card1': device_add
> Oct 18 14:25:30 earth kernel: [   23.619459] device: 'pcmC1D0c': device_add
> Oct 18 14:25:30 earth kernel: [   23.619523] device: 'dsp1': device_add
> Oct 18 14:25:30 earth kernel: [   23.620309] device: 'audio1': device_add
> Oct 18 14:25:30 earth kernel: [   23.620518] device: 'controlC1': device_add
> Oct 18 14:25:30 earth kernel: [   23.620676] device: 'mixer1': device_add
> Oct 18 14:25:30 earth kernel: [   23.620914] driver: '0000:00:08.1': driver_bound: bound to device 'cx88_audio'
> Oct 18 14:25:30 earth kernel: [   23.620919] bus: 'pci': really_probe: bound device 0000:00:08.1 to driver cx88_audio
> Oct 18 14:25:30 earth kernel: [   23.633759] bus: 'pci': driver_probe_device: matched device 0000:00:08.0 with driver cx8800
> Oct 18 14:25:30 earth kernel: [   23.633765] bus: 'pci': really_probe: probing driver cx8800 with device 0000:00:08.0
> Oct 18 14:25:30 earth kernel: [   23.633808] cx8800 0000:00:08.0: PCI INT A -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   23.731940] cx88[0]/0: found at 0000:00:08.0, rev: 5, irq: 10, latency: 32, mmio: 0xe2000000
> Oct 18 14:25:30 earth kernel: [   23.848522] ehci_hcd: block sizes: qh 128 qtd 96 itd 160 sitd 96
> Oct 18 14:25:30 earth kernel: [   23.848566] bus: 'pci': add driver ehci_hcd
> Oct 18 14:25:30 earth kernel: [   23.878077] device class 'scsi_generic': registering
> Oct 18 14:25:30 earth kernel: [   23.878175] device: 'sg0': device_add
> Oct 18 14:25:30 earth kernel: [   23.878300] sd 1:0:0:0: Attached scsi generic sg0 type 0
> Oct 18 14:25:30 earth kernel: [   23.941999] device: 'sg1': device_add
> Oct 18 14:25:30 earth kernel: [   23.942040] sr 4:0:1:0: Attached scsi generic sg1 type 5
> Oct 18 14:25:30 earth kernel: [   24.021842] bus: 'i2c': add driver wm8775'
> Oct 18 14:25:30 earth kernel: [   24.022053] wm8775' 0-001b: chip found @ 0x36 (cx88[0])
> Oct 18 14:25:30 earth kernel: [   24.090437] device: '0-001b': device_add
> Oct 18 14:25:30 earth kernel: [   24.090450] bus: 'i2c': add device 0-001b
> Oct 18 14:25:30 earth kernel: [   24.090468] driver: '0-001b': driver_bound: bound to device 'wm8775''
> Oct 18 14:25:30 earth kernel: [   24.090475] bus: 'i2c': add driver wm8775
> Oct 18 14:25:30 earth kernel: [   24.095838] device: 'video0': device_add
> Oct 18 14:25:30 earth kernel: [   24.096829] cx88[0]/0: registered device video0 [v4l2]
> Oct 18 14:25:30 earth kernel: [   24.158562] device: 'vbi0': device_add
> Oct 18 14:25:30 earth kernel: [   24.158633] cx88[0]/0: registered device vbi1
> Oct 18 14:25:30 earth kernel: [   24.210917] device: 'radio0': device_add
> Oct 18 14:25:30 earth kernel: [   24.211073] cx88[0]/0: registered device radio2
> Oct 18 14:25:30 earth kernel: [   24.329011] driver: '0000:00:08.0': driver_bound: bound to device 'cx8800'
> Oct 18 14:25:30 earth kernel: [   24.329021] bus: 'pci': really_probe: bound device 0000:00:08.0 to driver cx8800
> Oct 18 14:25:30 earth kernel: [   24.329080] bus: 'pci': driver_probe_device: matched device 0000:00:08.2 with driver cx88-mpeg driver manager
> Oct 18 14:25:30 earth kernel: [   24.329084] bus: 'pci': really_probe: probing driver cx88-mpeg driver manager with device 0000:00:08.2
> Oct 18 14:25:30 earth kernel: [   24.329111] cx88[0]/2: cx2388x 8802 Driver Manager
> Oct 18 14:25:30 earth kernel: [   24.386800] cx88-mpeg driver manager 0000:00:08.2: PCI INT A -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   24.503581] cx88[0]/2: found at 0000:00:08.2, rev: 5, irq: 10, latency: 32, mmio: 0xe4000000
> Oct 18 14:25:30 earth kernel: [   24.604735] cx8802_probe() allocating 2 frontend(s)
> Oct 18 14:25:30 earth kernel: [   24.663237] driver: '0000:00:08.2': driver_bound: bound to device 'cx88-mpeg driver manager'
> Oct 18 14:25:30 earth kernel: [   24.663242] bus: 'pci': really_probe: bound device 0000:00:08.2 to driver cx88-mpeg driver manager
> Oct 18 14:25:30 earth kernel: [   24.678574] bus: 'pci': driver_probe_device: matched device 0000:00:0d.0 with driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   24.678581] bus: 'pci': really_probe: probing driver uhci_hcd with device 0000:00:0d.0
> Oct 18 14:25:30 earth kernel: [   24.678622] uhci_hcd 0000:00:0d.0: PCI INT A -> Link[LNKB] -> GSI 11 (level, low) -> IRQ 11
> Oct 18 14:25:30 earth kernel: [   24.778920] uhci_hcd 0000:00:0d.0: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   24.841794] device: 'usb_host1': device_add
> Oct 18 14:25:30 earth kernel: [   24.842029] drivers/usb/core/inode.c: creating file 'devices'
> Oct 18 14:25:30 earth kernel: [   24.842038] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   24.842069] uhci_hcd 0000:00:0d.0: new USB bus registered, assigned bus number 1
> Oct 18 14:25:30 earth kernel: [   24.930939] uhci_hcd 0000:00:0d.0: detected 2 ports
> Oct 18 14:25:30 earth kernel: [   24.989408] uhci_hcd 0000:00:0d.0: uhci_check_and_reset_hc: cmd = 0x0000
> Oct 18 14:25:30 earth kernel: [   24.989411] uhci_hcd 0000:00:0d.0: Performing full reset
> Oct 18 14:25:30 earth kernel: [   24.989424] uhci_hcd 0000:00:0d.0: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   24.989441] uhci_hcd 0000:00:0d.0: irq 11, io base 0x0000bc00
> Oct 18 14:25:30 earth kernel: [   25.058367] usb usb1: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   25.058379] device: 'usb1': device_add
> Oct 18 14:25:30 earth kernel: [   25.058455] bus: 'usb': add device usb1
> Oct 18 14:25:30 earth kernel: [   25.058470] usb usb1: uevent
> Oct 18 14:25:30 earth kernel: [   25.058486] bus: 'usb': driver_probe_device: matched device usb1 with driver usb
> Oct 18 14:25:30 earth kernel: [   25.058490] bus: 'usb': really_probe: probing driver usb with device usb1
> Oct 18 14:25:30 earth kernel: [   25.058498] usb usb1: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   25.058502] usb usb1: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   25.125314] usb usb1: adding 1-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   25.125318] device: '1-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   25.125331] bus: 'usb': add device 1-0:1.0
> Oct 18 14:25:30 earth kernel: [   25.125665] usb 1-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   25.126074] bus: 'usb': driver_probe_device: matched device 1-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   25.126079] bus: 'usb': really_probe: probing driver hub with device 1-0:1.0
> Oct 18 14:25:30 earth kernel: [   25.126088] hub 1-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   25.126092] hub 1-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   25.126095] hub 1-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   25.171299] hub 1-0:1.0: 2 ports detected
> Oct 18 14:25:30 earth kernel: [   25.219392] hub 1-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   25.219395] hub 1-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   25.219398] hub 1-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   25.219401] hub 1-0:1.0: power on to power good time: 2ms
> Oct 18 14:25:30 earth kernel: [   25.219409] hub 1-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   25.219414] hub 1-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   25.323616] uhci_hcd 0000:00:0d.0: port 1 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   25.323634] uhci_hcd 0000:00:0d.0: port 2 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   25.424100] driver: '1-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   25.424108] bus: 'usb': really_probe: bound device 1-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   25.424119] device class 'usb_endpoint': registering
> Oct 18 14:25:30 earth kernel: [   25.424248] device: 'usbdev1.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   25.424414] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   25.424433] driver: 'usb1': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   25.424436] bus: 'usb': really_probe: bound device usb1 to driver usb
> Oct 18 14:25:30 earth kernel: [   25.425172] device: 'usbdev1.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   25.425491] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
> Oct 18 14:25:30 earth kernel: [   25.506884] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   25.593476] usb usb1: Product: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   25.651922] usb usb1: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty uhci_hcd
> Oct 18 14:25:30 earth kernel: [   25.742677] usb usb1: SerialNumber: 0000:00:0d.0
> Oct 18 14:25:30 earth kernel: [   25.798060] driver: '0000:00:0d.0': driver_bound: bound to device 'uhci_hcd'
> Oct 18 14:25:30 earth kernel: [   25.798065] bus: 'pci': really_probe: bound device 0000:00:0d.0 to driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   25.798768] hub 1-0:1.0: state 7 ports 2 chg 0000 evt 0000
> Oct 18 14:25:30 earth kernel: [   25.801766] bus: 'pci': driver_probe_device: matched device 0000:00:0d.1 with driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   25.801774] bus: 'pci': really_probe: probing driver uhci_hcd with device 0000:00:0d.1
> Oct 18 14:25:30 earth kernel: [   25.801816] uhci_hcd 0000:00:0d.1: PCI INT B -> Link[LNKA] -> GSI 12 (level, low) -> IRQ 12
> Oct 18 14:25:30 earth kernel: [   25.901960] uhci_hcd 0000:00:0d.1: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   25.964590] device: 'usb_host2': device_add
> Oct 18 14:25:30 earth kernel: [   25.964646] drivers/usb/core/inode.c: creating file '002'
> Oct 18 14:25:30 earth kernel: [   25.964658] uhci_hcd 0000:00:0d.1: new USB bus registered, assigned bus number 2
> Oct 18 14:25:30 earth kernel: [   26.053353] uhci_hcd 0000:00:0d.1: detected 2 ports
> Oct 18 14:25:30 earth kernel: [   26.111830] uhci_hcd 0000:00:0d.1: uhci_check_and_reset_hc: cmd = 0x0000
> Oct 18 14:25:30 earth kernel: [   26.111833] uhci_hcd 0000:00:0d.1: Performing full reset
> Oct 18 14:25:30 earth kernel: [   26.111845] uhci_hcd 0000:00:0d.1: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   26.111860] uhci_hcd 0000:00:0d.1: irq 12, io base 0x0000c000
> Oct 18 14:25:30 earth kernel: [   26.180864] usb usb2: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   26.180876] device: 'usb2': device_add
> Oct 18 14:25:30 earth kernel: [   26.180945] bus: 'usb': add device usb2
> Oct 18 14:25:30 earth kernel: [   26.180959] usb usb2: uevent
> Oct 18 14:25:30 earth kernel: [   26.181003] bus: 'usb': driver_probe_device: matched device usb2 with driver usb
> Oct 18 14:25:30 earth kernel: [   26.181007] bus: 'usb': really_probe: probing driver usb with device usb2
> Oct 18 14:25:30 earth kernel: [   26.181015] usb usb2: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   26.181019] usb usb2: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   26.247874] usb usb2: adding 2-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   26.247877] device: '2-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   26.247892] bus: 'usb': add device 2-0:1.0
> Oct 18 14:25:30 earth kernel: [   26.247902] usb 2-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   26.247915] bus: 'usb': driver_probe_device: matched device 2-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   26.247919] bus: 'usb': really_probe: probing driver hub with device 2-0:1.0
> Oct 18 14:25:30 earth kernel: [   26.247927] hub 2-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   26.247930] hub 2-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   26.247933] hub 2-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   26.292934] hub 2-0:1.0: 2 ports detected
> Oct 18 14:25:30 earth kernel: [   26.340997] hub 2-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   26.341000] hub 2-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   26.341002] hub 2-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   26.341006] hub 2-0:1.0: power on to power good time: 2ms
> Oct 18 14:25:30 earth kernel: [   26.341013] hub 2-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   26.341017] hub 2-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   26.548818] uhci_hcd 0000:00:0d.1: port 1 portsc 018a,00
> Oct 18 14:25:30 earth kernel: [   26.548836] uhci_hcd 0000:00:0d.1: port 2 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   26.652041] driver: '2-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   26.652049] bus: 'usb': really_probe: bound device 2-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   26.652065] device: 'usbdev2.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   26.652206] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   26.652283] driver: 'usb2': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   26.652286] bus: 'usb': really_probe: bound device usb2 to driver usb
> Oct 18 14:25:30 earth kernel: [   26.652297] device: 'usbdev2.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   26.652373] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
> Oct 18 14:25:30 earth kernel: [   26.733798] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   26.820369] usb usb2: Product: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   26.878853] usb usb2: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty uhci_hcd
> Oct 18 14:25:30 earth kernel: [   26.969610] usb usb1: suspend_rh (auto-stop)
> Oct 18 14:25:30 earth kernel: [   26.969622] usb usb2: SerialNumber: 0000:00:0d.1
> Oct 18 14:25:30 earth kernel: [   27.024984] driver: '0000:00:0d.1': driver_bound: bound to device 'uhci_hcd'
> Oct 18 14:25:30 earth kernel: [   27.024988] bus: 'pci': really_probe: bound device 0000:00:0d.1 to driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   27.025626] hub 2-0:1.0: state 7 ports 2 chg 0000 evt 0000
> Oct 18 14:25:30 earth kernel: [   27.026124] bus: 'pci': driver_probe_device: matched device 0000:00:0d.2 with driver ehci_hcd
> Oct 18 14:25:30 earth kernel: [   27.026129] bus: 'pci': really_probe: probing driver ehci_hcd with device 0000:00:0d.2
> Oct 18 14:25:30 earth kernel: [   27.026167] ehci_hcd 0000:00:0d.2: PCI INT C -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   27.126282] ehci_hcd 0000:00:0d.2: EHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   27.188913] device: 'usb_host3': device_add
> Oct 18 14:25:30 earth kernel: [   27.188963] drivers/usb/core/inode.c: creating file '003'
> Oct 18 14:25:30 earth kernel: [   27.188974] ehci_hcd 0000:00:0d.2: new USB bus registered, assigned bus number 3
> Oct 18 14:25:30 earth kernel: [   27.277676] ehci_hcd 0000:00:0d.2: reset hcs_params 0x2204 dbg=0 cc=2 pcc=2 ordered !ppc ports=4
> Oct 18 14:25:30 earth kernel: [   27.277682] ehci_hcd 0000:00:0d.2: reset hcc_params 6872 thresh 7 uframes 256/512/1024
> Oct 18 14:25:30 earth kernel: [   27.277735] ehci_hcd 0000:00:0d.2: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
> Oct 18 14:25:30 earth kernel: [   27.277752] ehci_hcd 0000:00:0d.2: MWI active
> Oct 18 14:25:30 earth kernel: [   27.277755] ehci_hcd 0000:00:0d.2: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   27.277768] ehci_hcd 0000:00:0d.2: irq 10, io mem 0xe7001000
> Oct 18 14:25:30 earth kernel: [   27.345629] ehci_hcd 0000:00:0d.2: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
> Oct 18 14:25:30 earth kernel: [   27.345637] ehci_hcd 0000:00:0d.2: init command 010009 (park)=0 ithresh=1 period=256 RUN
> Oct 18 14:25:30 earth kernel: [   27.361132] ehci_hcd 0000:00:0d.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> Oct 18 14:25:30 earth kernel: [   27.450962] usb usb3: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   27.450977] device: 'usb3': device_add
> Oct 18 14:25:30 earth kernel: [   27.451072] bus: 'usb': add device usb3
> Oct 18 14:25:30 earth kernel: [   27.451098] usb usb3: uevent
> Oct 18 14:25:30 earth kernel: [   27.451167] bus: 'usb': driver_probe_device: matched device usb3 with driver usb
> Oct 18 14:25:30 earth kernel: [   27.451171] bus: 'usb': really_probe: probing driver usb with device usb3
> Oct 18 14:25:30 earth kernel: [   27.451183] usb usb3: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   27.451187] usb usb3: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   27.518104] usb usb3: adding 3-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   27.518107] device: '3-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   27.518127] bus: 'usb': add device 3-0:1.0
> Oct 18 14:25:30 earth kernel: [   27.518146] usb 3-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   27.518177] bus: 'usb': driver_probe_device: matched device 3-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   27.518181] bus: 'usb': really_probe: probing driver hub with device 3-0:1.0
> Oct 18 14:25:30 earth kernel: [   27.518190] hub 3-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   27.518192] hub 3-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   27.518196] hub 3-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   27.563178] hub 3-0:1.0: 4 ports detected
> Oct 18 14:25:30 earth kernel: [   27.611224] hub 3-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   27.611227] hub 3-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   27.611229] hub 3-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   27.611233] hub 3-0:1.0: power on to power good time: 20ms
> Oct 18 14:25:30 earth kernel: [   27.611241] hub 3-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   27.611245] hub 3-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   27.712557] driver: '3-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   27.712563] bus: 'usb': really_probe: bound device 3-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   27.712578] device: 'usbdev3.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   27.712689] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   27.712700] driver: 'usb3': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   27.712704] bus: 'usb': really_probe: bound device usb3 to driver usb
> Oct 18 14:25:30 earth kernel: [   27.712716] device: 'usbdev3.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   27.712766] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
> Oct 18 14:25:30 earth kernel: [   27.794198] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   27.880784] usb usb3: Product: EHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   27.939274] usb usb3: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty ehci_hcd
> Oct 18 14:25:30 earth kernel: [   28.030024] usb usb3: SerialNumber: 0000:00:0d.2
> Oct 18 14:25:30 earth kernel: [   28.085392] driver: '0000:00:0d.2': driver_bound: bound to device 'ehci_hcd'
> Oct 18 14:25:30 earth kernel: [   28.085397] bus: 'pci': really_probe: bound device 0000:00:0d.2 to driver ehci_hcd
> Oct 18 14:25:30 earth kernel: [   28.094222] hub 3-0:1.0: state 7 ports 4 chg 0000 evt 0000
> Oct 18 14:25:30 earth kernel: [   28.116709] bus: 'pci': driver_probe_device: matched device 0000:00:11.2 with driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   28.116716] bus: 'pci': really_probe: probing driver uhci_hcd with device 0000:00:11.2
> Oct 18 14:25:30 earth kernel: [   28.116763] uhci_hcd 0000:00:11.2: PCI INT D -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   28.216976] usb usb2: suspend_rh (auto-stop)
> Oct 18 14:25:30 earth kernel: [   28.217004] uhci_hcd 0000:00:11.2: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   28.279741] device: 'usb_host4': device_add
> Oct 18 14:25:30 earth kernel: [   28.279812] drivers/usb/core/inode.c: creating file '004'
> Oct 18 14:25:30 earth kernel: [   28.279841] uhci_hcd 0000:00:11.2: new USB bus registered, assigned bus number 4
> Oct 18 14:25:30 earth kernel: [   28.368481] uhci_hcd 0000:00:11.2: detected 2 ports
> Oct 18 14:25:30 earth kernel: [   28.426962] uhci_hcd 0000:00:11.2: uhci_check_and_reset_hc: cmd = 0x0000
> Oct 18 14:25:30 earth kernel: [   28.426966] uhci_hcd 0000:00:11.2: Performing full reset
> Oct 18 14:25:30 earth kernel: [   28.426978] uhci_hcd 0000:00:11.2: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   28.427003] uhci_hcd 0000:00:11.2: irq 10, io base 0x0000e400
> Oct 18 14:25:30 earth kernel: [   28.495939] usb usb4: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   28.495952] device: 'usb4': device_add
> Oct 18 14:25:30 earth kernel: [   28.496060] bus: 'usb': add device usb4
> Oct 18 14:25:30 earth kernel: [   28.496078] usb usb4: uevent
> Oct 18 14:25:30 earth kernel: [   28.496112] bus: 'usb': driver_probe_device: matched device usb4 with driver usb
> Oct 18 14:25:30 earth kernel: [   28.496115] bus: 'usb': really_probe: probing driver usb with device usb4
> Oct 18 14:25:30 earth kernel: [   28.496125] usb usb4: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   28.496129] usb usb4: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   28.562996] usb usb4: adding 4-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   28.562999] device: '4-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   28.563014] bus: 'usb': add device 4-0:1.0
> Oct 18 14:25:30 earth kernel: [   28.563028] usb 4-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   28.563116] bus: 'usb': driver_probe_device: matched device 4-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   28.563120] bus: 'usb': really_probe: probing driver hub with device 4-0:1.0
> Oct 18 14:25:30 earth kernel: [   28.563129] hub 4-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   28.563132] hub 4-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   28.563135] hub 4-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   28.608062] hub 4-0:1.0: 2 ports detected
> Oct 18 14:25:30 earth kernel: [   28.656133] hub 4-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   28.656136] hub 4-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   28.656138] hub 4-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   28.656142] hub 4-0:1.0: power on to power good time: 2ms
> Oct 18 14:25:30 earth kernel: [   28.656149] hub 4-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   28.656154] hub 4-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   28.775953] uhci_hcd 0000:00:11.2: port 1 portsc 01ab,00
> Oct 18 14:25:30 earth kernel: [   28.775964] hub 4-0:1.0: port 1: status 0301 change 0003
> Oct 18 14:25:30 earth kernel: [   28.775975] uhci_hcd 0000:00:11.2: port 2 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   28.876065] driver: '4-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   28.876071] bus: 'usb': really_probe: bound device 4-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   28.876087] device: 'usbdev4.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   28.876240] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   28.876260] driver: 'usb4': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   28.876263] bus: 'usb': really_probe: bound device usb4 to driver usb
> Oct 18 14:25:30 earth kernel: [   28.876282] device: 'usbdev4.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   28.876369] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
> Oct 18 14:25:30 earth kernel: [   28.957747] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   29.044334] usb usb4: Product: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   29.102821] usb usb4: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty uhci_hcd
> Oct 18 14:25:30 earth kernel: [   29.193571] usb usb4: SerialNumber: 0000:00:11.2
> Oct 18 14:25:30 earth kernel: [   29.248950] driver: '0000:00:11.2': driver_bound: bound to device 'uhci_hcd'
> Oct 18 14:25:30 earth kernel: [   29.248954] bus: 'pci': really_probe: bound device 0000:00:11.2 to driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   29.249589] hub 4-0:1.0: state 7 ports 2 chg 0002 evt 0000
> Oct 18 14:25:30 earth kernel: [   29.249607] hub 4-0:1.0: port 1, status 0301, change 0000, 1.5 Mb/s
> Oct 18 14:25:30 earth kernel: [   29.249994] bus: 'pci': driver_probe_device: matched device 0000:00:11.3 with driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   29.249998] bus: 'pci': really_probe: probing driver uhci_hcd with device 0000:00:11.3
> Oct 18 14:25:30 earth kernel: [   29.250041] uhci_hcd 0000:00:11.3: PCI INT D -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   29.350247] uhci_hcd 0000:00:11.3: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   29.412866] device: 'usb_host5': device_add
> Oct 18 14:25:30 earth kernel: [   29.412916] drivers/usb/core/inode.c: creating file '005'
> Oct 18 14:25:30 earth kernel: [   29.412927] uhci_hcd 0000:00:11.3: new USB bus registered, assigned bus number 5
> Oct 18 14:25:30 earth kernel: [   29.501700] uhci_hcd 0000:00:11.3: detected 2 ports
> Oct 18 14:25:30 earth kernel: [   29.560227] uhci_hcd 0000:00:11.3: uhci_check_and_reset_hc: cmd = 0x0000
> Oct 18 14:25:30 earth kernel: [   29.560230] uhci_hcd 0000:00:11.3: Performing full reset
> Oct 18 14:25:30 earth kernel: [   29.560242] uhci_hcd 0000:00:11.3: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   29.560257] uhci_hcd 0000:00:11.3: irq 10, io base 0x0000e800
> Oct 18 14:25:30 earth kernel: [   29.629198] usb usb5: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   29.629211] device: 'usb5': device_add
> Oct 18 14:25:30 earth kernel: [   29.629289] bus: 'usb': add device usb5
> Oct 18 14:25:30 earth kernel: [   29.629306] usb usb5: uevent
> Oct 18 14:25:30 earth kernel: [   29.629346] bus: 'usb': driver_probe_device: matched device usb5 with driver usb
> Oct 18 14:25:30 earth kernel: [   29.629350] bus: 'usb': really_probe: probing driver usb with device usb5
> Oct 18 14:25:30 earth kernel: [   29.629359] usb usb5: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   29.629363] usb usb5: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   29.696165] usb usb5: adding 5-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   29.696168] device: '5-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   29.696183] bus: 'usb': add device 5-0:1.0
> Oct 18 14:25:30 earth kernel: [   29.696194] usb 5-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   29.696211] bus: 'usb': driver_probe_device: matched device 5-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   29.696214] bus: 'usb': really_probe: probing driver hub with device 5-0:1.0
> Oct 18 14:25:30 earth kernel: [   29.696224] hub 5-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   29.696227] hub 5-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   29.696231] hub 5-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   29.742091] hub 5-0:1.0: 2 ports detected
> Oct 18 14:25:30 earth kernel: [   29.790134] hub 5-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   29.790136] hub 5-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   29.790139] hub 5-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   29.790143] hub 5-0:1.0: power on to power good time: 2ms
> Oct 18 14:25:30 earth kernel: [   29.790151] hub 5-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   29.790155] hub 5-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   29.856035] usb 4-1: new low speed USB device using uhci_hcd and address 2
> Oct 18 14:25:30 earth kernel: [   29.938920] uhci_hcd 0000:00:11.3: port 1 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   29.938933] uhci_hcd 0000:00:11.3: port 2 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   30.040030] driver: '5-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   30.040035] bus: 'usb': really_probe: bound device 5-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   30.040050] device: 'usbdev5.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   30.040192] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   30.040260] driver: 'usb5': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   30.040263] bus: 'usb': really_probe: bound device usb5 to driver usb
> Oct 18 14:25:30 earth kernel: [   30.040278] device: 'usbdev5.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   30.040338] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
> Oct 18 14:25:30 earth kernel: [   30.121715] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   30.208308] usb usb5: Product: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   30.266789] usb usb5: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty uhci_hcd
> Oct 18 14:25:30 earth kernel: [   30.357538] usb usb5: SerialNumber: 0000:00:11.3
> Oct 18 14:25:30 earth kernel: [   30.412917] driver: '0000:00:11.3': driver_bound: bound to device 'uhci_hcd'
> Oct 18 14:25:30 earth kernel: [   30.412922] bus: 'pci': really_probe: bound device 0000:00:11.3 to driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   30.446120] cx88/2: cx2388x dvb driver version 0.0.6 loaded
> Oct 18 14:25:30 earth kernel: [   30.512949] cx88/2: registering cx8802 driver, type: dvb access: shared
> Oct 18 14:25:30 earth kernel: [   30.592232] cx88[0]/2: subsystem: 0070:1402, board: Hauppauge WinTV-HVR3000 TriMode Analog/DVB-S/DVB-T [card=53]
> Oct 18 14:25:30 earth kernel: [   30.714217] cx88[0]/2: cx2388x based DVB/ATSC card
> Oct 18 14:25:30 earth kernel: [   30.808482] usb 4-1: skipped 1 descriptor after interface
> Oct 18 14:25:30 earth kernel: [   30.812627] usb 4-1: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   30.826626] device: '4-1': device_add
> Oct 18 14:25:30 earth kernel: [   30.826766] bus: 'usb': add device 4-1
> Oct 18 14:25:30 earth kernel: [   30.826810] usb 4-1: uevent
> Oct 18 14:25:30 earth kernel: [   30.826839] bus: 'usb': driver_probe_device: matched device 4-1 with driver usb
> Oct 18 14:25:30 earth kernel: [   30.826843] bus: 'usb': really_probe: probing driver usb with device 4-1
> Oct 18 14:25:30 earth kernel: [   30.826855] usb 4-1: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   30.826859] usb 4-1: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   30.923220] usb 4-1: adding 4-1:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   30.923226] device: '4-1:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   30.923276] bus: 'usb': add device 4-1:1.0
> Oct 18 14:25:30 earth kernel: [   30.923303] usb 4-1:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   30.923341] device: 'usbdev4.2_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   30.923481] drivers/usb/core/inode.c: creating file '002'
> Oct 18 14:25:30 earth kernel: [   30.923495] driver: '4-1': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   30.923499] bus: 'usb': really_probe: bound device 4-1 to driver usb
> Oct 18 14:25:30 earth kernel: [   30.923511] device: 'usbdev4.2_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   30.923550] usb 4-1: New USB device found, idVendor=046d, idProduct=c00b
> Oct 18 14:25:30 earth kernel: [   31.003984] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> Oct 18 14:25:30 earth kernel: [   31.089547] usb 4-1: Product: USB Mouse
> Oct 18 14:25:30 earth kernel: [   31.135494] usb 4-1: Manufacturer: Logitech
> Oct 18 14:25:30 earth kernel: [   31.185676] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
> Oct 18 14:25:30 earth kernel: [   31.186867] bus: 'pci': driver_probe_device: matched device 0000:00:11.4 with driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   31.186873] bus: 'pci': really_probe: probing driver uhci_hcd with device 0000:00:11.4
> Oct 18 14:25:30 earth kernel: [   31.186915] uhci_hcd 0000:00:11.4: PCI INT D -> Link[LNKD] -> GSI 10 (level, low) -> IRQ 10
> Oct 18 14:25:30 earth kernel: [   31.287067] uhci_hcd 0000:00:11.4: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   31.349744] device: 'usb_host6': device_add
> Oct 18 14:25:30 earth kernel: [   31.349808] drivers/usb/core/inode.c: creating file '006'
> Oct 18 14:25:30 earth kernel: [   31.349819] uhci_hcd 0000:00:11.4: new USB bus registered, assigned bus number 6
> Oct 18 14:25:30 earth kernel: [   31.438469] usb usb5: suspend_rh (auto-stop)
> Oct 18 14:25:30 earth kernel: [   31.438491] uhci_hcd 0000:00:11.4: detected 2 ports
> Oct 18 14:25:30 earth kernel: [   31.496947] uhci_hcd 0000:00:11.4: uhci_check_and_reset_hc: cmd = 0x0000
> Oct 18 14:25:30 earth kernel: [   31.496950] uhci_hcd 0000:00:11.4: Performing full reset
> Oct 18 14:25:30 earth kernel: [   31.496963] uhci_hcd 0000:00:11.4: supports USB remote wakeup
> Oct 18 14:25:30 earth kernel: [   31.497014] uhci_hcd 0000:00:11.4: irq 10, io base 0x0000ec00
> Oct 18 14:25:30 earth kernel: [   31.566035] usb usb6: default language 0x0409
> Oct 18 14:25:30 earth kernel: [   31.566048] device: 'usb6': device_add
> Oct 18 14:25:30 earth kernel: [   31.566118] bus: 'usb': add device usb6
> Oct 18 14:25:30 earth kernel: [   31.566134] usb usb6: uevent
> Oct 18 14:25:30 earth kernel: [   31.566152] bus: 'usb': driver_probe_device: matched device usb6 with driver usb
> Oct 18 14:25:30 earth kernel: [   31.566156] bus: 'usb': really_probe: probing driver usb with device usb6
> Oct 18 14:25:30 earth kernel: [   31.566166] usb usb6: usb_probe_device
> Oct 18 14:25:30 earth kernel: [   31.566170] usb usb6: configuration #1 chosen from 1 choice
> Oct 18 14:25:30 earth kernel: [   31.633003] usb usb6: adding 6-0:1.0 (config #1, interface 0)
> Oct 18 14:25:30 earth kernel: [   31.633006] device: '6-0:1.0': device_add
> Oct 18 14:25:30 earth kernel: [   31.633021] bus: 'usb': add device 6-0:1.0
> Oct 18 14:25:30 earth kernel: [   31.633031] usb 6-0:1.0: uevent
> Oct 18 14:25:30 earth kernel: [   31.633098] bus: 'usb': driver_probe_device: matched device 6-0:1.0 with driver hub
> Oct 18 14:25:30 earth kernel: [   31.633102] bus: 'usb': really_probe: probing driver hub with device 6-0:1.0
> Oct 18 14:25:30 earth kernel: [   31.633112] hub 6-0:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   31.633115] hub 6-0:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   31.633118] hub 6-0:1.0: USB hub found
> Oct 18 14:25:30 earth kernel: [   31.678055] hub 6-0:1.0: 2 ports detected
> Oct 18 14:25:30 earth kernel: [   31.726117] hub 6-0:1.0: standalone hub
> Oct 18 14:25:30 earth kernel: [   31.726120] hub 6-0:1.0: no power switching (usb 1.0)
> Oct 18 14:25:30 earth kernel: [   31.726122] hub 6-0:1.0: individual port over-current protection
> Oct 18 14:25:30 earth kernel: [   31.726126] hub 6-0:1.0: power on to power good time: 2ms
> Oct 18 14:25:30 earth kernel: [   31.726134] hub 6-0:1.0: local power source is good
> Oct 18 14:25:30 earth kernel: [   31.726139] hub 6-0:1.0: trying to enable port power on non-switchable hub
> Oct 18 14:25:30 earth kernel: [   31.728201] CX24123: detected CX24123
> Oct 18 14:25:30 earth kernel: [   31.772152] device: 'i2c-1': device_add
> Oct 18 14:25:30 earth kernel: [   31.814967] tuner-simple 0-0061: attaching existing instance
> Oct 18 14:25:30 earth kernel: [   31.882878] tuner-simple 0-0061: type set to 63 (Philips FMD1216ME MK3 Hybrid Tuner)
> Oct 18 14:25:30 earth kernel: [   31.979187] DVB: registering new adapter (cx88[0])
> Oct 18 14:25:30 earth kernel: [   32.036677] DVB: registering adapter 0 frontend 0 (Conexant CX24123/CX24109)...
> Oct 18 14:25:30 earth kernel: [   32.124310] device: 'dvb0.frontend0': device_add
> Oct 18 14:25:30 earth kernel: [   32.124636] device: 'dvb0.demux0': device_add
> Oct 18 14:25:30 earth kernel: [   32.124676] device: 'dvb0.dvr0': device_add
> Oct 18 14:25:30 earth kernel: [   32.124710] device: 'dvb0.net0': device_add
> Oct 18 14:25:30 earth kernel: [   32.124814] DVB: registering adapter 0 frontend 1 (Conexant CX22702 DVB-T)...
> Oct 18 14:25:30 earth kernel: [   32.210388] device: 'dvb0.frontend1': device_add
> Oct 18 14:25:30 earth kernel: [   32.211530] device: 'dvb0.demux1': device_add
> Oct 18 14:25:30 earth kernel: [   32.211769] device: 'dvb0.dvr1': device_add
> Oct 18 14:25:30 earth kernel: [   32.211811] device: 'dvb0.net1': device_add
> Oct 18 14:25:30 earth kernel: [   32.301511] uhci_hcd 0000:00:11.4: port 1 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   32.301530] uhci_hcd 0000:00:11.4: port 2 portsc 008a,00
> Oct 18 14:25:30 earth kernel: [   32.404042] driver: '6-0:1.0': driver_bound: bound to device 'hub'
> Oct 18 14:25:30 earth kernel: [   32.404050] bus: 'usb': really_probe: bound device 6-0:1.0 to driver hub
> Oct 18 14:25:30 earth kernel: [   32.404066] device: 'usbdev6.1_ep81': device_add
> Oct 18 14:25:30 earth kernel: [   32.404197] drivers/usb/core/inode.c: creating file '001'
> Oct 18 14:25:30 earth kernel: [   32.404211] driver: 'usb6': driver_bound: bound to device 'usb'
> Oct 18 14:25:30 earth kernel: [   32.404215] bus: 'usb': really_probe: bound device usb6 to driver usb
> Oct 18 14:25:30 earth kernel: [   32.404226] device: 'usbdev6.1_ep00': device_add
> Oct 18 14:25:30 earth kernel: [   32.404415] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
> Oct 18 14:25:30 earth kernel: [   32.485766] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Oct 18 14:25:30 earth kernel: [   32.572344] usb usb6: Product: UHCI Host Controller
> Oct 18 14:25:30 earth kernel: [   32.630833] usb usb6: Manufacturer: Linux 2.6.27-rc9-00016-g6984937-dirty uhci_hcd
> Oct 18 14:25:30 earth kernel: [   32.721592] usb usb6: SerialNumber: 0000:00:11.4
> Oct 18 14:25:30 earth kernel: [   32.776971] driver: '0000:00:11.4': driver_bound: bound to device 'uhci_hcd'
> Oct 18 14:25:30 earth kernel: [   32.776976] bus: 'pci': really_probe: bound device 0000:00:11.4 to driver uhci_hcd
> Oct 18 14:25:30 earth kernel: [   32.779131] hub 6-0:1.0: state 7 ports 2 chg 0000 evt 0000
> Oct 18 14:25:30 earth kernel: [   33.110418] bus: 'usb': add driver usbhid
> Oct 18 14:25:30 earth kernel: [   33.110453] bus: 'usb': driver_probe_device: matched device 4-1:1.0 with driver usbhid
> Oct 18 14:25:30 earth kernel: [   33.110458] bus: 'usb': really_probe: probing driver usbhid with device 4-1:1.0
> Oct 18 14:25:30 earth kernel: [   33.110470] usbhid 4-1:1.0: usb_probe_interface
> Oct 18 14:25:30 earth kernel: [   33.110473] usbhid 4-1:1.0: usb_probe_interface - got id
> Oct 18 14:25:30 earth kernel: [   33.125795] device: 'input3': device_add
> Oct 18 14:25:30 earth kernel: [   33.125993] input: Logitech USB Mouse as /devices/pci0000:00/0000:00:11.2/usb4/4-1/4-1:1.0/input/input3
> Oct 18 14:25:30 earth kernel: [   33.252734] device: 'mouse0': device_add
> Oct 18 14:25:30 earth kernel: [   33.253097] device: 'event3': device_add
> Oct 18 14:25:30 earth kernel: [   33.253151] input: USB HID v1.10 Mouse [Logitech USB Mouse] on usb-0000:00:11.2-1
> Oct 18 14:25:30 earth kernel: [   33.343225] driver: '4-1:1.0': driver_bound: bound to device 'usbhid'
> Oct 18 14:25:30 earth kernel: [   33.343231] bus: 'usb': really_probe: bound device 4-1:1.0 to driver usbhid
> Oct 18 14:25:30 earth kernel: [   33.343280] usbcore: registered new interface driver usbhid
> Oct 18 14:25:30 earth kernel: [   33.410055] usbhid: v2.6:USB HID core driver
> Oct 18 14:25:30 earth kernel: [   33.880042] usb usb6: suspend_rh (auto-stop)
> Oct 18 14:25:30 earth kernel: [   34.876240] Adding 1004052k swap on /dev/sda2.  Priority:-1 extents:1 across:1004052k
> Oct 18 14:25:30 earth kernel: [   35.238571] EXT3 FS on sda3, internal journal
> Oct 18 14:25:30 earth kernel: [   45.779428] fuse init (API version 7.9)
> Oct 18 14:25:30 earth kernel: [   45.825577] device: 'fuse': device_add
> Oct 18 14:25:30 earth kernel: [   45.930675] kjournald starting.  Commit interval 5 seconds
> Oct 18 14:25:30 earth kernel: [   45.996605] EXT3 FS on sda1, internal journal
> Oct 18 14:25:30 earth kernel: [   46.049037] EXT3-fs: mounted filesystem with ordered data mode.
> Oct 18 14:25:30 earth kernel: [   46.140996] kjournald starting.  Commit interval 5 seconds
> Oct 18 14:25:30 earth kernel: [   46.207007] EXT3 FS on sda5, internal journal
> Oct 18 14:25:30 earth kernel: [   46.259469] EXT3-fs: mounted filesystem with ordered data mode.
> Oct 18 14:25:30 earth kernel: [   46.356191] kjournald starting.  Commit interval 5 seconds
> Oct 18 14:25:30 earth kernel: [   46.431723] EXT3 FS on sda6, internal journal
> Oct 18 14:25:30 earth kernel: [   46.484166] EXT3-fs: mounted filesystem with ordered data mode.
> Oct 18 14:25:30 earth kernel: [   48.191855] NET: Registered protocol family 10
> Oct 18 14:25:30 earth kernel: [   48.577015] ADDRCONF(NETDEV_UP): eth0: link is not ready
> Oct 18 14:25:30 earth kernel: [   48.739246] TLAN: eth0: Starting autonegotiation.
> Oct 18 14:25:30 earth kernel: [   50.794174] TLAN:  Giving autonegotiation more time.
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  Please check that your adapter has
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  been properly connected to a HUB or Switch.
> Oct 18 14:25:30 earth kernel: [   50.796011] TLAN:  Trying to establish link in the background...
> Oct 18 14:25:30 earth kernel: [   59.058195] TLAN: eth0: Autonegotiation complete.
> Oct 18 14:25:30 earth kernel: [   59.215360] TLAN: eth0: Link active
> Oct 18 14:25:30 earth kernel: [   59.216010] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> Oct 18 14:25:30 earth kernel: [   67.965828] ADDRCONF(NETDEV_UP): eth0: link is not ready
> Oct 18 14:25:30 earth kernel: [   68.127259] TLAN: eth0: Starting autonegotiation.
> Oct 18 14:25:30 earth kernel: [   70.182180] TLAN:  Giving autonegotiation more time.
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  Please check that your adapter has
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  been properly connected to a HUB or Switch.
> Oct 18 14:25:30 earth kernel: [   70.184010] TLAN:  Trying to establish link in the background...
> Oct 18 14:25:30 earth kernel: [   70.601415] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> Oct 18 14:25:30 earth kernel: [   71.028474] PPP generic driver version 2.4.2
> Oct 18 14:25:30 earth kernel: [   71.079865] device class 'ppp': registering
> Oct 18 14:25:30 earth kernel: [   71.079897] device: 'ppp': device_add
> Oct 18 14:25:30 earth kernel: [   72.096821] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.096919] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.096922] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.097008] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.108913] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   72.109051] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   72.109171] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.109212] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.109215] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.109310] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.109335] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   72.110060] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   72.110180] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.110211] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.110214] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.110241] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.110273] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   72.110300] device: 'vcsa1': device_add
> Oct 18 14:25:30 earth kernel: [   72.110399] device: 'vcs1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.110427] device: 'vcs1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.110430] device: 'vcsa1': device_unregister
> Oct 18 14:25:30 earth kernel: [   72.110446] device: 'vcsa1': device_create_release
> Oct 18 14:25:30 earth kernel: [   72.111014] device: 'vcs1': device_add
> Oct 18 14:25:30 earth kernel: [   72.111107] device: 'vcsa1': device_add
> Oct 18 14:25:36 earth kernel: [   78.446187] TLAN: eth0: Autonegotiation complete.
> Oct 18 14:25:36 earth kernel: [   78.603351] TLAN: eth0: Link active
> Oct 18 14:25:36 earth kernel: [   78.604011] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> Oct 18 14:25:39 earth kernel: [   81.076045] eth1: no IPv6 routers present
> Oct 18 14:25:43 earth kernel: [   84.849860] warning: `jsvc' uses 32-bit capabilities (legacy support in use)
> Oct 18 14:25:44 earth kernel: [   86.423688] NET: Registered protocol family 24
> Oct 18 14:25:44 earth kernel: [   86.569205] device: 'ppp0': device_add
> Oct 18 14:25:46 earth kernel: [   88.488925] device: 'vcs3': device_add
> Oct 18 14:25:46 earth kernel: [   88.489072] device: 'vcsa3': device_add
> Oct 18 14:25:46 earth kernel: [   88.492747] device: 'vcs4': device_add
> Oct 18 14:25:46 earth kernel: [   88.492888] device: 'vcsa4': device_add
> Oct 18 14:25:46 earth kernel: [   88.495349] device: 'vcs2': device_add
> Oct 18 14:25:46 earth kernel: [   88.495462] device: 'vcsa2': device_add
> Oct 18 14:25:46 earth kernel: [   88.497462] device: 'vcs5': device_add
> Oct 18 14:25:46 earth kernel: [   88.497574] device: 'vcsa5': device_add
> Oct 18 14:25:46 earth kernel: [   88.502647] device: 'vcs6': device_add
> Oct 18 14:25:46 earth kernel: [   88.502767] device: 'vcsa6': device_add
> Oct 18 14:25:47 earth kernel: [   89.328049] eth0: no IPv6 routers present
> Oct 18 14:25:59 earth kernel: [  101.376560] ip_tables: (C) 2000-2006 Netfilter Core Team
> Oct 18 14:25:59 earth kernel: [  101.568965] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> 
> 
> On Sun, Oct 19, 2008 at 12:24:21PM +0200, Manfred Scherer wrote:
> > I've did some more tests belonging this bug.
> > 
> > 1st.
> > http request to the DSL-modem (admin-Interface). Here is the tcpdump,
> > 
> > kernel 2.6.26:
> > pc1:~ # tcpdump -i eth1 -vvv
> > tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
> > 12:43:10.201543 arp who-has 192.168.1.1 tell 192.168.1.22
> > 12:43:10.201779 arp reply 192.168.1.1 is-at 00:19:15:47:0e:11
> > 12:43:10.201798 IP (tos 0x8, ttl  64, id 24982, offset 0, flags [DF], length: 60) 192.168.1.22.25219 > 192.168.1.1.http: S [tcp sum ok] 824562007:824562007(0) win 5840 <mss 1460,sackOK,timestamp 4294881473 0,nop,wscale 6>
> > 12:43:10.202300 arp who-has 192.168.1.22 tell 192.168.1.1
> > 12:43:10.202319 arp reply 192.168.1.22 is-at 00:08:c7:28:5a:96
> > 12:43:10.202820 IP (tos 0x0, ttl 100, id 2152, offset 0, flags [none], length: 44) 192.168.1.1.http > 192.168.1.22.25219: S [tcp sum ok] 0:0(0) ack 824562008 win 49152 <mss 1400>
> > 12:43:10.202895 IP (tos 0x8, ttl  64, id 24983, offset 0, flags [DF], length: 40) 192.168.1.22.25219 > 192.168.1.1.http: . [tcp sum ok] 1:1(0) ack 1 win 5840
> > 12:43:10.203330 IP (tos 0x0, ttl 100, id 2153, offset 0, flags [none], length: 40) 192.168.1.1.http > 192.168.1.22.25219: . [tcp sum ok] 1:1(0) ack 1 win 49152
> > ...
> > 
> > 
> > kernel 2.6.27:
> > 
> > pc1:~ # tcpdump -i eth1 -vvv
> > tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
> > 12:36:50.434395 arp who-has 192.168.1.1 tell 192.168.1.22
> > 12:36:51.434178 arp who-has 192.168.1.1 tell 192.168.1.22
> > 12:36:52.434029 arp who-has 192.168.1.1 tell 192.168.1.22
> > ^C
> > 3 packets captured
> > 3 packets received by filter
> > 0 packets dropped by kernel
> > pc1:~ #
> > 
> > 
> > 2nd. 
> > I used the tlan.c and tlan.h from kernel source 2.6.26 in the
> > kernel source 2.6.27 to build a kernel. Result is:
> > - http request to the DSLModem operates
> > - pppoe operates (as proof this mail)
> > 
> > Manfred Scherer
> > 
> 
> 
