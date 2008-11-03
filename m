From: Roland Dreier <rdreier@cisco.com>
Subject: Re: patch: support long (above 14 bytes) HW addresses in arp_ioctl
Date: Mon, 03 Nov 2008 15:53:26 -0800
Message-ID: <adaod0wv021.fsf@cisco.com>
References: <490EDBDD.1030104@gmail.com> <ada63n4wvxp.fsf@cisco.com>
	<490F496C.2010608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Constantine Gavrilov <constantine.gavrilov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:49201 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbYKCXx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 18:53:28 -0500
In-Reply-To: <490F496C.2010608@gmail.com> (Constantine Gavrilov's message of
	"Mon, 03 Nov 2008 20:56:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[netdev added to cc list]

 > In arp_req_get() in net/arp.c, there is code:
 > 
 > memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
 > 
 > dev->addr_len can be larger than size of
 > r->arp_ha.sa_data. Inititally, I thought it would corrupt kernel
 > stack. I was wrong, since r still has enough space not to overflow
 > even for the largest HW address (32 bytes). It would corrupt the data
 > structure though, and that corrupted reply would be propagated to
 > user.
 > 
 > There is a similar situation in arp_req_set(), where a "junk" arp
 > entry will be set if dev->addr_len is larger that 14 bytes. 
 > 
 > At the very minimum, both arp_req_set() and arp_req_get() should
 > return error (-EINVAL), and not return junk or set junk. Truncated
 > /proc/net/arp output should also be fixed.

The EINVAL return makes sense; I'm not sure /proc/net/arp is important
enough to fix.  I guess it depends on the impact of the fix.

 > I was not aware that rtnetlink is capable of doing things like arp
 > table or interface manipulation (like netdevice ioctls). My
 > applications needs to be able to manipulate arp cache for large macs,
 > and I do not mind recompiling by adding a flag. I do not mind fixing
 > arp cli to use this either (venerable arp  does use arp_ioctl). And
 > there are many many legacy solutions that use arp_ioctl() in programs
 > and arp utility in scripts. Consider porting those to infiniband.
 > 
 > Will rtnetlink work for any net_device (like netdevice ioctls do) for
 > ARP and interface configurations calls or does it require special
 > support in net_device itself? Any possible problems with rtnetlink?

rtnetlink is the preferred modern interface between userspace and kernel
for networking information.  There is also the "iproute2" package that
provides a good command line interface that is capable of handling IPoIB
addresses.  For example:

$ ip addr show dev ib1
5: ib1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2044 qdisc pfifo_fast state UP qlen 256
    link/infiniband 80:00:00:48:fe:80:00:00:00:00:00:00:00:02:c9:03:00:00:01:65 brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
    inet 192.168.145.74/24 brd 192.168.145.255 scope global ib1
    inet6 fe80::202:c903:0:165/64 scope link 
       valid_lft forever preferred_lft forever

$ ip neigh
192.168.145.73 dev ib1 lladdr 80:00:00:48:fe:80:00:00:00:00:00:00:00:02:c9:03:00:00:01:30 STALE
172.29.224.1 dev eth0 lladdr 00:00:0c:07:ac:e0 REACHABLE

and so on.

 - R.
