From: Olaf Kirch <okir@suse.de>
Subject: ip addr flush hangs
Date: Tue, 9 Mar 2004 15:48:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309144824.GD14419@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm currently debugging the following problem: on a 2.6.3
kernel, when doing this

	ifconfig eth0 down
	ip addr flush dev eth0

The second command hangs indefinitely. The reason is that the kernel
reports ipv6-all-hosts (ff02::1) when dumping all addresses, but
RTM_DELADDR on ff02::1 doesn't do anything. As /sbin/ip will loop until
the kernel reports no more matching addresses, it will go on like that
forever.

I don't see an obvious fix to this issue. On one hand, calling ifconfig
down will result in a call to addrconf_ifdown(dev, 0).  This will clear
the list of unicast addresses assigned to this interface, but will not
clear the list of multicast addresses (it unloads them from the NIC,
and sends IGMP leave packets, but the list of addresses will remain
attached to the device). So it doesn't destroy the interface completely,
it zaps its state just partly, intentionally.

On the other hand, if you manually remove all addresses from the
interface, this will result in a call to addrconf_ifdown(dev, 1),
causing the mcast list to be zapped as well.

This is not entirely consistent. Should a NETDEV_DOWN zap the
ipv6 configuration completely?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
