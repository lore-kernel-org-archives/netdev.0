From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Stale entries in RT_TABLE_LOCAL
Date: Wed, 23 Feb 2011 12:43:23 -0500
Message-ID: <201102231243.23579.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_7cUZNbkPyWgWUyw"
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:2261 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692Ab1BWRnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:43:25 -0500
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0026.austin.hp.com (Postfix) with ESMTP id BC1D0C6D5
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 17:43:24 +0000 (UTC)
Received: from hplaptop.localnet (unknown [16.212.4.13])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id 7FF7830198
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 17:43:24 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_7cUZNbkPyWgWUyw
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

I have found several scenarios when after deleting IP-address from an 
interface there is a stale entry left in RT_TABLE_LOCAL.

All these scenarios use the fact that it is possible to add the same address 
multiple times to the same interface using different masks.

Let us do the following using dummy0 interface:

ifconfig dummy0 192.168.140.31 netmask 255.255.252.0
ip addr add 192.168.142.109/23 dev dummy0
ip addr add 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/23 dev dummy0

We add 192.168.142.109/23 and 192.168.142.109/22, then delete them (order is 
important). After that, 192.168.142.109 is not in 'ip addr ls' but there are 
entries using this addr in RT_TABLE_LOCAL.

An attached script demonstrates the problem:

{asid 14:00:57} sudo sh iptest.sh
Tables before the test
13: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 5e:1a:fa:44:90:f6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.140.31/22 brd 192.168.143.255 scope global dummy0
    inet6 fe80::5c1a:faff:fe44:90f6/64 scope link 
       valid_lft forever preferred_lft forever
 
local 192.168.140.31 dev dummy0  proto kernel  scope host  src 192.168.140.31 
broadcast 192.168.140.0 dev dummy0  proto kernel  scope link  src 
192.168.140.31 
broadcast 192.168.143.255 dev dummy0  proto kernel  scope link  src
192.168.140.31 
----------------------
Tables after the test
13: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 5e:1a:fa:44:90:f6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.140.31/22 brd 192.168.143.255 scope global dummy0
    inet6 fe80::5c1a:faff:fe44:90f6/64 scope link 
       valid_lft forever preferred_lft forever
 
local 192.168.140.31 dev dummy0  proto kernel  scope host  src 192.168.140.31 
local 192.168.142.109 dev dummy0  proto kernel  scope host  src 192.168.140.31 
broadcast 192.168.143.255 dev dummy0  proto kernel  scope link  src
192.168.140.31 
broadcast 192.168.143.255 dev dummy0  proto kernel  scope link  src
192.168.142.109 


As you see, even though there is no 192.168.142.109 on dummy0 address list, 
the entries referring to this addr are still present in RT_TABLE_LOCAL.

Another scenario (adding/deleting two addresses, each one twice with different 
mask) can lead to stale entries cross-referencing each other, like

local 192.168.5.8  proto kernel  scope host  src 192.168.5.9 
local 192.168.5.9  proto kernel  scope host  src 192.168.5.8 

Analysis
--------

Both scenarios use the fact that we can add the same address multiple times to 
the same interface, using different masks.

1. When we delete an IP addr, we remove it from the interface addr list and 
send a notifier to routing code (fib_del_ifaddr) asking to delete the 
associated routes.

2. When we enter fib_del_ifaddr(struct in_ifaddr *ifa), the address is already
deleted. But if we add the same IP twice (with different masks), the same
address (even though with different prefix) is present two times. So after the
first deletion we still have its 2nd instance on the list.

3. We do the following in fib_del_ifaddr():

         for (ifa1 = in_dev->ifa_list; ifa1; ifa1 = ifa1->ifa_next) {
                 if (ifa->ifa_local == ifa1->ifa_local)
                         ok |= LOCAL_OK;
                 if (ifa->ifa_broadcast == ifa1->ifa_broadcast)
                         ok |= BRD_OK;
                 if (brd == ifa1->ifa_broadcast)
                         ok |= BRD1_OK;
                 if (any == ifa1->ifa_broadcast)
                         ok |= BRD0_OK;
         }

That is, we loop on all addrs of the interface (in_dev->ifa_list) and compare
address we have just deleted (passed in 'ifa') with addresses on the list. 

As we compare them without taking prefix (mask) into account, the following 
will be true:

ifa->ifa_local == ifa1->ifa_local
ifa->ifa_broadcast == ifa1->ifa_broadcast

4. As a result, after deleting the first instance of IP (192.168.142.109/22) 
we still have  192.168.142.109/23 on the list. The routing code will find that 
this addr (and broadcast) are still present on the list and will not delete 
the routes.

5. When we delete the second time (192.168.142.109/23), there will be no
192.168.142.109 on the list anymore and the routing code will delete the route 
- but only one out of two entries.

How this can be fixed
---------------------

I am not sure what is the best way to fix this, I can think of several 
approaches:

  (a) change the sources so that it would be impossible to add the same IP 
      multiple times, even with different masks. I cannot think of any
      situation where adding the same IP (but with different mask) to the same
      interface could be useful. But maybe I am wrong?

  (b) improve the deletion algorithm in fib_del_ifaddr()

  (c) add a periodic cleanup that will purge all entries from 'local' table if
      there are no corresponding IPs on the interface list


Impact
------

Stale entries in RT_TABLE_LOCAL make ARP reply to requests for that IPs, even 
though these IPs do not belong to any interface.

These scenarios might seem a bit pathological, but in reality they are 
possible on clusters with multiple addresses on several interfaces, where 
addresses are added/deleted for service migration. Address migration can be 
done both by software and by system administrators and if by mistake a wrong 
mask is used, we can get this situation.

And yes, one of HP customers met exactly this problem. They saw a 'duplicate 
IP' issue after migrating some services and found that the host replies to 
ARP-request even though 'ip addr ls' did not show this address. It is not 
common knowledge that ARP implementation uses RT_TABLE_LOCAL to decide whether 
IP is local, so they were unable to understand what is wrong.

Regards,
Alex

------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux                      Hewlett-Packard (Canada)
------------------------------------------------------------------

--Boundary-00=_7cUZNbkPyWgWUyw
Content-Type: application/x-shellscript;
  name="iptest.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iptest.sh"

# Reinserting the module, to start from clean slate

modprobe -r dummy
modprobe dummy

ifconfig dummy0 192.168.140.31 netmask 255.255.252.0


echo "Tables before the test"
ip addr ls dev dummy0
echo " "
ip route show table local | fgrep dummy
echo "----------------------"

ip addr add 192.168.142.109/23 dev dummy0
ip addr add 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/23 dev dummy0

# Now print the results
echo "Tables after the test"
# Addrs
ip addr ls dev dummy0
echo " "

# Local routing table
ip route show table local | fgrep dummy
--Boundary-00=_7cUZNbkPyWgWUyw--
