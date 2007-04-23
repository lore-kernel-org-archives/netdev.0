From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 15:12:40 -0700
Message-ID: <20070423151240.0e8cabed.akpm@linux-foundation.org>
References: <20070423132719.b7cf1c9e.akpm@linux-foundation.org>
	<20070423.133730.115642229.davem@davemloft.net>
	<20070423135639.26ca125a.akpm@linux-foundation.org>
	<20070423.141706.92341313.davem@davemloft.net>
	<20070423144557.8c74c4b0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:32816 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754339AbXDWWNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 18:13:13 -0400
In-Reply-To: <20070423144557.8c74c4b0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 14:45:57 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Let me play around with udpspam a bit.

tcpdump does show stuff coming in when I run udpspam against the test
machine from another host.

More rtnl weirdness.  Running `ifup eth0' gave me:


Apr 23 14:53:57 localhost smartd[4051]: smartd has fork()ed into background mode. New PID=4051. 
Apr 23 14:56:47 localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Apr 23 14:56:47 localhost kernel: e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
Apr 23 14:56:47 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Apr 23 14:56:48 localhost dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
Apr 23 14:56:48 localhost dhclient: DHCPACK from 172.18.119.253
Apr 23 14:56:48 localhost avahi-daemon[3971]: New relevant interface eth0.IPv4 for mDNS.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.18.116.155.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Registering new address record for 172.18.116.155 on eth0.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Withdrawing address record for 172.18.116.155 on eth0.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Leaving mDNS multicast group on interface eth0.IPv4 with address 172.18.116.155.
Apr 23 14:56:48 localhost avahi-daemon[3971]: iface.c: interface_mdns_mcast_join() called but no local address available.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Interface eth0.IPv4 no longer relevant for mDNS.
Apr 23 14:56:48 localhost avahi-daemon[3971]: New relevant interface eth0.IPv4 for mDNS.
Apr 23 14:56:48 localhost avahi-daemon[3971]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.18.116.155.
Apr 23 14:56:48 localhost kernel: RTNL: assertion failed at net/ipv4/igmp.c (1205)
Apr 23 14:56:48 localhost kernel: 
Apr 23 14:56:48 localhost kernel: Call Trace:
Apr 23 14:56:48 localhost kernel:  [<ffffffff8049340c>] ip_mc_inc_group+0x3e/0x1f2
Apr 23 14:56:48 localhost kernel:  [<ffffffff80493b2b>] ip_mc_join_group+0xca/0xe8
Apr 23 14:56:48 localhost kernel:  [<ffffffff8047e441>] do_ip_setsockopt+0x6db/0x9d7
Apr 23 14:56:48 localhost kernel:  [<ffffffff8029696e>] autoremove_wake_function+0x0/0x2e
Apr 23 14:56:48 localhost kernel:  [<ffffffff80336018>] selinux_inode_getattr+0x50/0x5e
Apr 23 14:56:48 localhost kernel:  [<ffffffff80333c56>] socket_has_perm+0x5b/0x68
Apr 23 14:56:48 localhost kernel:  [<ffffffff8047e7e5>] ip_setsockopt+0x22/0x86
Apr 23 14:56:48 localhost kernel:  [<ffffffff8045587b>] sys_setsockopt+0x8f/0xb5
Apr 23 14:56:48 localhost kernel:  [<ffffffff8025911e>] system_call+0x7e/0x83
Apr 23 14:56:48 localhost kernel: 
Apr 23 14:56:48 localhost NET[4351]: /sbin/dhclient-script : updated /etc/resolv.conf
Apr 23 14:56:48 localhost avahi-daemon[3971]: Registering new address record for 172.18.116.155 on eth0.
Apr 23 14:56:48 localhost dhclient: bound to 172.18.116.155 -- renewal in 3205 seconds.
Apr 23 14:56:49 localhost avahi-daemon[3971]: New relevant interface eth0.IPv6 for mDNS.
Apr 23 14:56:49 localhost avahi-daemon[3971]: Joining mDNS multicast group on interface eth0.IPv6 with address fe80::204:23ff:fec6:d7d2.
Apr 23 14:56:49 localhost avahi-daemon[3971]: Registering new address record for fe80::204:23ff:fec6:d7d2 on eth0.

which is just stupid.  The rtnl_lock() is right there in ip_mc_join_group().
And this is a different architecture and config and compiler from yesterday's
fun.  And no scheduler patches involved here.
