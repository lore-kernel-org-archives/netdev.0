From: Andrew Lunn <andrew@lunn.ch>
Subject: mvneta bug with  mvneta_set_rx_mode()
Date: Tue, 15 Nov 2016 00:03:05 +0100
Message-ID: <20161114230305.GA6260@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38528 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939765AbcKNXDH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 18:03:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas

I think i have found a bug in the mvneta driver, when coupled with
DSA. I'm using an Armada 370 RD board, but i expect you can reproduce
this in any board using mvneta and a switch.

I set the MAC address on a switch interface:

root@370-rd:~# ip link set address f2:42:42:42:42:42 dev lan2
root@370-rd:~# ip addr add 10.42.42.42/24 dev lan2
root@370-rd:~# ip link set lan2 up
root@370-rd:~# ip link set eth1 up
root@370-rd:~# ping 10.42.42.41

This does not work:

PING 10.42.42.41 (10.42.42.1) 56(84) bytes of data.
>From 10.42.42.42 icmp_seq=1 Destination Host Unreachable
>From 10.42.42.42 icmp_seq=2 Destination Host Unreachable
>From 10.42.42.42 icmp_seq=3 Destination Host Unreachable
^C
--- 10.42.42.1 ping statistics ---
10 packets transmitted, 0 received, +3 errors, 100% packet loss, time 9338ms
pipe 8

However, if i run tcpdump on the mvneta interface, so putting it into
promiscuous mode:

root@370-rd:~# tcpdump -i eth1 &
[1] 3757
root@370-rd:~# ping 10.42.42.1
PING 10.42.42.1 (10.42.42.1) 56(84) bytes of data.
64 bytes from 10.42.42.1: icmp_seq=1 ttl=64 time=1.43 ms
16:48:28.185095 MEDSA 0.2:0: ARP, Request who-has 10.42.42.1 tell 10.42.42.42, length 28
16:48:28.185767 MEDSA 0.2:0: ARP, Reply 10.42.42.1 is-at d8:eb:97:bf:44:f3 (oui Unknown), length 46
16:48:28.185961 MEDSA 0.2:0: IP 10.42.42.42 > 10.42.42.1: ICMP echo request, id 3760, seq 1, length 64
16:48:28.186429 MEDSA 0.2:0: IP 10.42.42.1 > 10.42.42.42: ICMP echo reply, id 3760, seq 1, length 64
16:48:29.186857 MEDSA 0.2:0: IP 10.42.42.42 > 10.42.42.1: ICMP echo request, id 3760, seq 2, length 64
16:48:29.187620 MEDSA 0.2:0: IP 10.42.42.1 > 10.42.42.42: ICMP echo reply, id 3760, seq 2, length 64
64 bytes from 10.42.42.1: icmp_seq=2 ttl=64 time=0.834 ms
16:48:30.189156 MEDSA 0.2:0: IP 10.42.42.42 > 10.42.42.1: ICMP echo request, id 3760, seq 3, length 64
16:48:30.189867 MEDSA 0.2:0: IP 10.42.42.1 > 10.42.42.42: ICMP echo reply, id 3760, seq 3, length 64
64 bytes from 10.42.42.1: icmp_seq=3 ttl=64 time=0.782 ms
^C
--- 10.42.42.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 0.782/1.015/1.431/0.296 ms

What should happen is that when the MAC address is set on lan2, it
calls dsa_slave_set_mac_address(). It sees that the requested address
is different to the masters MAC address, so it calls dev_uc_add() to
add the MAC address to the master device, i.e. the mvneta. That causes
the MAC address to be added to the interfaces dev->uc list.  Since the
driver has dev->priv_flags & IFF_UNICAST_FLT true, it is indicating it
supports unicast filtering. So __dev_set_rx_mode() calls the drivers
set_rx_mode() to setup the filtering.

I don't see anywhere in mvneta where it walks the dev->uc list adding
these MAC addresses to its filter. Either it needs to do this, or it
should not have IFF_UNICAST_FLT, so that the core code will put the
interface into promisc mode when multiple unicast addresses are added.

Do you have time to look into this?

Thanks
	Andrew
