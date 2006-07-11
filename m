From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: active-backup/bonding with drivers not supporting set_mac_address()
Date: Tue, 11 Jul 2006 17:01:01 +0300
Message-ID: <44B3AF1D.7060100@voltaire.com>
References: <Pine.LNX.4.64.0607101618390.26558@zuben> <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:47734 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1750796AbWGKOBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 10:01:09 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:

> 	What network device drivers are there that don't permit ever
> changing the device MAC address?

I am thinking about what would it take to support active-backup/bonding 
for IP over Infiniband (see Documentation/infiniband/ipoib.txt).

The IPoIB MAC address (defined in RFC 4391 section 9.1.1) is 20 bytes 
long and made of the IB port GID (16 bytes), the IB QPN (Queue-Pair 
number) used by this device (3 bytes) plus 1 reserved byte.

The IPoIB MAC address is made of two unique hardware resource 
identifiers: the GID which identifies the HCA IP port and the number of 
the QP opened by the driver on this HCA/port.  Currently the driver does 
not support changing this MAC and i am also looking into whether its 
possible and what does it would take to have some abstraction layer 
implemented in the driver that would allow for external setting of the 
MAC address; that is an intermediate data structure that would translate 
from the MAC address exposed in the device and neigh structures to the 
actual IB hardware address.

However, again, if you would ACK an intension to patch the bonding 
driver such that it will not force usage of dev->set_mac_address for 
active-backup/bonding i would prefer to first produce and test a patch 
which does not change the IPoIB driver (drivers/infiniband/ulp/ipoib)

Or.

Below is the addr info on a node named dill with two ipoib devices ib0 
(192.168.10.118) and ib1 (not up) and the neigh info for an ipoib 
endpoint whose address is 192.168.10.57

so

the GID of the port associated with ib0 is 
fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:51:dd

the GID of the port associated with ib1 is
fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:51:de

the qpn used by ib0 is 00:04:04 (0x404)
the qpn used by ib1 is 00:04:05 (0x405)

the remote GID in this example is 
fe:80:00:00:00:00:00:00:00:08:f1:04:03:97:07:99

and the remote qpn is 0x404

dill # ip addr show ib0
6: ib0: <BROADCAST,MULTICAST,UP,10000> mtu 2044 qdisc pfifo_fast qlen 128
     link/[32] 00:00:04:04:fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:51:dd
       brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
     inet 192.168.10.118/24 brd 192.168.10.255 scope global ib0
     inet6 fe80::208:f104:396:51dd/64 scope link
        valid_lft forever preferred_lft forever

dill# ip addr show ib1
7: ib1: <BROADCAST,MULTICAST> mtu 2044 qdisc noop qlen 128
     link/[32] 00:00:04:05:fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:51:de
       brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff

dill# ip neigh show 192.168.10.57
192.168.10.57 dev ib0 lladdr 
00:00:04:04:fe:80:00:00:00:00:00:00:00:08:f1:04:03:97:07:99 nud reachable

