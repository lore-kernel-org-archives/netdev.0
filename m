From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 15:58:23 +0100
Message-ID: <5829D10F.30206@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:14308 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932726AbcKNO67 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 09:58:59 -0500
In-Reply-To: <20161114133428.GF26710@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/2016 14:34, Andrew Lunn wrote:

> Mason wrote:
> 
>> How exactly does one use the generic PHY driver?
> 
> If there is no specific driver available for the PHY, linux will fall
> back to the generic driver. So just don't compile the specific driver.
> You can see under /sys/bus/mdio_bus/devices which driver is being
> used.

I've removed the Atheros driver from the kernel config.

# ls /sys/bus/mdio_bus/drivers
Generic 10G PHY/ Generic PHY/

# ls -l "/sys/bus/mdio_bus/devices/26000.nb8800-mii:04/"
lrwxrwxrwx    1 root     root             0 Jan  1 00:00 of_node -> ../../../../../../../firmware/devicetree/base/soc/ethernet@26000/ethernet-phy@4/
-r--r--r--    1 root     root          4096 Jan  1 00:00 phy_has_fixups
-r--r--r--    1 root     root          4096 Jan  1 00:00 phy_id
-r--r--r--    1 root     root          4096 Jan  1 00:00 phy_interface
lrwxrwxrwx    1 root     root             0 Jan  1 00:00 subsystem -> ../../../../../../../bus/mdio_bus/
-rw-r--r--    1 root     root          4096 Jan  1 00:00 uevent

(I don't know why/how it finds so many ".." in the symlink path)

[    1.170994] libphy: Fixed MDIO Bus: probed
[    1.181794] libphy: nb8800-mii: probed
[    1.192759] nb8800 26000.ethernet eth0: MAC address 00:16:e8:4b:b0:7d

# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 15:39:50 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 15:39:50 UTC 2016
Sending discover...
[  125.468634] nb8800_link_reconfigure from phy_state_machine
[  126.475300] nb8800_link_reconfigure from phy_state_machine
Mon Nov 14 15:39:53 UTC 2016
Sending discover...
[  126.682096] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
Mon Nov 14 15:39:57 UTC 2016
Sending discover...
Mon Nov 14 15:40:20 UTC 2016
Sending discover...
Mon Nov 14 15:40:23 UTC 2016
Sending discover...
Mon Nov 14 15:40:26 UTC 2016
Sending discover...
Mon Nov 14 15:40:49 UTC 2016
Sending discover...
Mon Nov 14 15:40:52 UTC 2016
Sending discover...
Mon Nov 14 15:40:55 UTC 2016
Sending discover...
^C

real    1m12.040s
user    0m0.067s
sys     0m0.057s


# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
15:39:54.214574 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:39:55.215830 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:39:57.247862 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:39:57.248027 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:20.307556 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:20.307732 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:23.334155 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:23.334313 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:26.360807 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:26.360976 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:49.420473 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:49.420645 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:52.447121 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:52.447284 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:40:55.473721 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:40:55.473891 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391


# ethtool -S eth0
NIC statistics:
     rx_bytes_ok: 975
     rx_frames_ok: 8
     rx_undersize_frames: 0
     rx_fragment_frames: 0
     rx_64_byte_frames: 6
     rx_127_byte_frames: 0
     rx_255_byte_frames: 1
     rx_511_byte_frames: 1
     rx_1023_byte_frames: 0
     rx_max_size_frames: 0
     rx_oversize_frames: 0
     rx_bad_fcs_frames: 0
     rx_broadcast_frames: 4
     rx_multicast_frames: 0
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 975
     rx_frames: 8
     tx_bytes_ok: 2960
     tx_frames_ok: 11
     tx_64_byte_frames: 3
     tx_127_byte_frames: 0
     tx_255_byte_frames: 0
     tx_511_byte_frames: 8
     tx_1023_byte_frames: 0
     tx_max_size_frames: 0
     tx_oversize_frames: 0
     tx_broadcast_frames: 8
     tx_multicast_frames: 0
     tx_control_frames: 0
     tx_pause_frames: 0
     tx_underrun_frames: 0
     tx_single_collision_frames: 0
     tx_multi_collision_frames: 0
     tx_deferred_collision_frames: 0
     tx_late_collision_frames: 0
     tx_excessive_collision_frames: 0
     tx_bytes: 2960
     tx_frames: 11
     tx_collisions: 0




EXPERIMENT #2

Now running the same test with fixed-phy (instead of generic phy driver)

# ls -l "/sys/bus/mdio_bus/devices/26000.nb8800-mii:04/"
lrwxrwxrwx    1 root     root             0 Jan  1 00:01 of_node -> ../../../../../../../firmware/devicetree/base/soc/ethernet@26000/fixed-link/
-r--r--r--    1 root     root          4096 Jan  1 00:01 phy_has_fixups
-r--r--r--    1 root     root          4096 Jan  1 00:01 phy_id
-r--r--r--    1 root     root          4096 Jan  1 00:01 phy_interface
lrwxrwxrwx    1 root     root             0 Jan  1 00:01 subsystem -> ../../../../../../../bus/mdio_bus/
-rw-r--r--    1 root     root          4096 Jan  1 00:00 uevent

[    1.194170] libphy: Fixed MDIO Bus: probed
[    1.208618] libphy: nb8800-mii: probed
[    1.212422] mdio_bus 26000.nb8800-mii: /soc/ethernet@26000/fixed-link has invalid PHY address
[    1.221025] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 0
[    1.227788] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 1
[    1.234551] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 2
[    1.241310] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 3
[    1.248071] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 4
[    1.261077] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 5
[    1.267857] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 6
[    1.274623] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 7
[    1.281386] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 8
[    1.288144] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 9
[    1.294906] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 10
[    1.301750] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 11
[    1.308599] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 12
[    1.315444] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 13
[    1.322291] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 14
[    1.329142] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 15
[    1.335992] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 16
[    1.342839] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 17
[    1.349752] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 18
[    1.356652] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 19
[    1.363503] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 20
[    1.370352] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 21
[    1.377200] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 22
[    1.384048] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 23
[    1.390895] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 24
[    1.397742] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 25
[    1.404590] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 26
[    1.411437] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 27
[    1.418284] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 28
[    1.425132] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 29
[    1.431979] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 30
[    1.438826] mdio_bus 26000.nb8800-mii: scan phy fixed-link at address 31
[    1.450432] nb8800 26000.ethernet eth0: MAC address 00:16:e8:4b:b0:7d

# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 15:49:05 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 15:49:05 UTC 2016
Sending discover...
[  179.748319] nb8800_link_reconfigure from phy_state_machine
[  179.753888] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
Mon Nov 14 15:49:08 UTC 2016
Sending discover...
Mon Nov 14 15:49:09 UTC 2016
Sending select for 172.27.64.58...
Mon Nov 14 15:49:10 UTC 2016
Lease of 172.27.64.58 obtained, lease time 604800
Mon Nov 14 15:49:10 UTC 2016
deleting routers
Mon Nov 14 15:49:10 UTC 2016
adding dns 172.27.0.17

real    0m4.359s
user    0m0.043s
sys     0m0.080s


# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
15:49:09.054779 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:49:10.056055 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:49:10.071415 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
15:49:10.172012 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
15:49:11.054105 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46
15:49:11.054116 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
15:49:11.054304 IP 172.27.64.58 > 172.27.64.1: ICMP echo reply, id 29883, seq 0, length 28
15:49:16.057970 ARP, Request who-has 172.27.64.1 tell 172.27.64.58, length 46
15:49:16.057983 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28

# ethtool -S eth0
NIC statistics:
     rx_bytes_ok: 1196
     rx_frames_ok: 7
     rx_undersize_frames: 0
     rx_fragment_frames: 0
     rx_64_byte_frames: 4
     rx_127_byte_frames: 1
     rx_255_byte_frames: 0
     rx_511_byte_frames: 2
     rx_1023_byte_frames: 0
     rx_max_size_frames: 0
     rx_oversize_frames: 0
     rx_bad_fcs_frames: 0
     rx_broadcast_frames: 3
     rx_multicast_frames: 0
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 1196
     rx_frames: 7
     tx_bytes_ok: 886
     tx_frames_ok: 5
     tx_64_byte_frames: 2
     tx_127_byte_frames: 1
     tx_255_byte_frames: 0
     tx_511_byte_frames: 2
     tx_1023_byte_frames: 0
     tx_max_size_frames: 0
     tx_oversize_frames: 0
     tx_broadcast_frames: 2
     tx_multicast_frames: 0
     tx_control_frames: 0
     tx_pause_frames: 0
     tx_underrun_frames: 0
     tx_single_collision_frames: 0
     tx_multi_collision_frames: 0
     tx_deferred_collision_frames: 0
     tx_late_collision_frames: 0
     tx_excessive_collision_frames: 0
     tx_bytes: 886
     tx_frames: 5
     tx_collisions: 0



Hmmm...
[ 126.682096] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
vs
[ 179.753888] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off

I'm not sure whether "flow control" is relevant...

Regards.
