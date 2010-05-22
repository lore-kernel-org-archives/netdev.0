From: "George B." <georgeb@gmail.com>
Subject: VLANs, bonding redux: vlan state does not follow ethernet
Date: Fri, 21 May 2010 23:24:39 -0700
Message-ID: <AANLkTimxJHKjAEm7wMYObFn9U3Sc1WPRYUuFFIKwwAyD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40888 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab0EVGYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 02:24:42 -0400
Received: by fxm5 with SMTP id 5so1380988fxm.19
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 23:24:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 2.6.34 I am trying to remove bottlenecks.  Instead of bonding
two ethernet interfaces and applying vlans to the bond, I am applying
the vlans to the ethernet and bonding the vlans creating a separate
bond interface for each vlan.

The trouble now is that the bond interface does not see when the
ethernet interface goes down.  The vlan reports to the bonding driver
that it is up when the ethernet it is connected to is down.  This
results in packet loss through the bond interface as the bond driver
attempts to use that vlan.

eth1 shows having no link:

root@sandbox:/proc/net# ethtool eth1
Settings for eth1:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  Not reported
        Link partner advertised pause frame use: No
        Link partner advertised auto-negotiation: No
        Speed: Unknown!
        Duplex: Unknown! (255)
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: Unknown
        Supports Wake-on: pumbag
        Wake-on: g
        Current message level: 0x00000001 (1)
        Link detected: no

bonding driver says eth1.99 reports MII status up:

root@sandbox:/proc/net# cat bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth0.99
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:26:9e:1c:d3:3e

Slave Interface: eth1.99
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:26:9e:1c:d3:3f

is there some parameter I can give that tells the vlan driver to
follow the state of the interface it is attached to?  Having a vlan
that reports being up all the time even when its underlying interface
is down is less than useful. It would seem intuitive that a vlan's
state would follow that of the interface it is attached to.

root@sandbox:/proc/net# cat vlan/eth0.99
eth0.99  VID: 99         REORDER_HDR: 1  dev->priv_flags: 21
         total frames received           32
          total bytes received         4735
      Broadcast/Multicast Rcvd            0

      total frames transmitted           50
       total bytes transmitted         3852
            total headroom inc            0
           total encap on xmit            0
Device: eth0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings:
root@sandbox:/proc/net# cat vlan/eth1.99
eth1.99  VID: 99         REORDER_HDR: 1  dev->priv_flags: 21
         total frames received            0
          total bytes received            0
      Broadcast/Multicast Rcvd            0

      total frames transmitted            0
       total bytes transmitted            0
            total headroom inc            0
           total encap on xmit            0
Device: eth1
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings:

root@sandbox:/proc/net# ping 10.1.99.1
PING 10.1.99.1 (10.1.99.1) 56(84) bytes of data.
64 bytes from 10.1.99.1: icmp_seq=2 ttl=255 time=0.299 ms
64 bytes from 10.1.99.1: icmp_seq=4 ttl=255 time=0.311 ms
64 bytes from 10.1.99.1: icmp_seq=6 ttl=255 time=0.325 ms
64 bytes from 10.1.99.1: icmp_seq=8 ttl=255 time=0.291 ms
64 bytes from 10.1.99.1: icmp_seq=10 ttl=255 time=0.308 ms

George
