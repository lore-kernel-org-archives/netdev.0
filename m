From: "Ramon Casellas" <ramon.casellas@cttc.es>
Subject: RE: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 15:15:41 +0100
Message-ID: <B936998C7BAD4852B0CD9AB17E72CFD0@CTTCA769C54C37>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Jarek Poplawski'" <jarkao2@gmail.com>, <netdev@vger.kernel.org>,
	"'Ramon Casellas'" <ramon.casellas@cttc.es>
To: "'J. K. Cliburn'" <jcliburn@gmail.com>,
	"'Patrick McHardy'" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.cttc.es ([84.88.62.202]:2714 "EHLO pollux.cttc.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418AbYJ2O2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 10:28:22 -0400
Received: from scorpius.cttc.es (scorpius.cttc.es [84.88.62.197])
	by pollux.cttc.es (8.13.1/8.13.1) with ESMTP id m9TE9jIF027306
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 15:09:46 +0100
In-Reply-To: <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Mensaje original-----
> De: J. K. Cliburn [mailto:jcliburn@gmail.com]

> >> Crap, I didn't think of that, all drivers I tested with support
> >> NAPI. I can't think of a clean way to fix it right now, but I'll
> >> look into it.
> >
> > This is the best I could come up with, short of simply restoring
> > the old behaviour for non-polling drivers.
> >
> > The __vlan_hwaccel_rx function only does the device lookup and
> > stores it in the cb. The remaining processing is done in a new
> > function that is invoked by netif_receive_skb(), in the proper
> > context. Unfortunatly this needs vlan-specific handling in
> > netif_receive_skb().
> 
> Can you please try the attached patch from Patrick and see if it fixes
> your kernel warning?

All, 

I applied the patch to linux.2.6.27.2 (already patched for VLAN support on
ATL1 devices as per Jay fix). Patch applied cleanly and there was no warn on
slow path on dmesg after the reboot, with fully functional VLAN (broken in
atl cards since 2.6.26)

Linux failamp 2.6.27.2 #1 SMP Wed Oct 29 14:22:49 CET 2008 i686 GNU/Linux

3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state
UP qlen 1000
    link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
    inet 1.1.1.91/24 brd 1.1.1.255 scope global eth0
    inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
       valid_lft forever preferred_lft forever

4: eth0.200@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
state UP 
    link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.91/24 brd 10.1.1.255 scope global eth0.200
    inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
       valid_lft forever preferred_lft forever
5: eth0.300@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
state UP 
    link/ether 00:1f:c6:bb:75:fa brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.91/24 brd 192.168.100.255 scope global eth0.300
    inet6 fe80::21f:c6ff:febb:75fa/64 scope link 
       valid_lft forever preferred_lft forever

I played a bit with tshark: 

failamp:/mnt# tshark -i eth0.300
Running as user "root" and group "root". This could be dangerous.
Capturing on eth0.300
  0.000000 Cisco_35:9a:11 -> PVST+        STP Conf. Root = 
33068/00:0e:84:50:ff:80  Cost = 12  Port = 0x8011

Thanks for your efforts. Let me know if you need further testing.

Ramon

(reboot)

[    1.916334] atl1 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    1.916380] atl1 0000:02:00.0: setting latency timer to 64
[    1.916390] atl1 0000:02:00.0: version 2.1.3
[   10.602350] atl1 0000:02:00.0: eth0 link is up 100 Mbps full duplex
[   10.602389] atl1 0000:02:00.0: eth0 link is up 1000 Mbps full duplex
[   20.696004] eth0: no IPv6 routers present
[   21.680003] eth0.200: no IPv6 routers present
[   22.072004] eth0.300: no IPv6 routers present
[  859.560556] device eth0 left promiscuous mode
[  862.100013] device eth0.300 entered promiscuous mode
[  862.100061] device eth0 entered promiscuous mode
[  869.311133] device eth0.300 left promiscuous mode
[  869.311180] device eth0 left promiscuous mode

