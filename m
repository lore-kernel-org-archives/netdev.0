From: Russell King <rmk@arm.linux.org.uk>
Subject: 2.6.6: IPv6 initialisation bug
Date: Tue, 18 May 2004 16:46:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040518164644.A21467@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I think I've found an IPv6 initialisation bug which occurs when IPv6
is modular, and you insert this module when eth0 is up and running,
but lo may be down.

IPv6 appears to create routes for addresses which are defined as
"local" (eg, link local, addresses assigned to the host etc) using
the loopback device.

However, if the ipv6 module is loaded when lo is down and some other
interface is up (eg, in the case of a root-NFS box), then things fall
apart.

bash-2.04# ip -6 addr
1: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qlen 1000
    inet6 fec0::1:a00:2bff:fe00:193/64 scope site dynamic
       valid_lft 2591630sec preferred_lft 604430sec
    inet6 2002:xxxx:xxxx:xxxx:a00:2bff:fe00:193/64 scope global dynamic
       valid_lft 2591630sec preferred_lft 604430sec
    inet6 fe80::a00:2bff:fe00:193/64 scope link
       valid_lft forever preferred_lft forever
2: lo: <LOOPBACK,UP> mtu 16436
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
bash-2.04# ip -6 route show table all
local ::1 via :: dev lo  proto none  metric 0  mtu 16436 advmss 16376
unreachable ::/96 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable ::ffff:0.0.0.0/96 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 2002:a00::/24 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 2002:7f00::/24 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 2002:a9fe::/32 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 2002:ac10::/28 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 2002:c0a8::/32 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
2002:xxxx:xxxx:xxxx::/64 dev eth0  proto kernel  metric 256  expires 2591712sec mtu 1500 advmss 1440
unreachable 2002:e000::/19 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
unreachable 3ffe:ffff::/32 dev lo  metric 1024  error -101 mtu 16436 advmss 16376
fe80::/64 dev eth0  metric 256  mtu 1500 advmss 1440
fec0:0:0:1::/64 dev eth0  proto kernel  metric 256  expires 2591712sec mtu 1500 advmss 1440
ff02::1 via ff02::1 dev eth0  metric 0
    cache  mtu 1500 advmss 1440
ff00::/8 dev eth0  metric 256  mtu 1500 advmss 1440
unreachable default dev lo  proto none  metric -1  error -101

As you can see, we're missing the local routes for all our addresses
against "eth0" - because we tried to add them to the IPv6 routing
table when "lo" was down.

The result is rather distasteful on the network - we start hammering
the local segment with neighbour solicitations for our link local and
global addresses, as well as sending neighbour solicitations for other
nodes addresses.  We receive neighbour advertisment replies, but because
we believe we don't own our own address, we forward them back out the
same interface triggering yet more neighbour solicitations for our own
addresses.

So... what's the solution for nodes running off root-NFS where "lo"
will always be brought up _after_ some other interface?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
