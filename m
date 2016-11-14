From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 13:13:52 +0100
Message-ID: <5829AA80.2090102@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
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
Received: from smtp5-g21.free.fr ([212.27.42.5]:45420 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934051AbcKNMO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 07:14:29 -0500
In-Reply-To: <20161113030919.GA2892@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/11/2016 04:09, Andrew Lunn wrote:

> Mason wrote:
> 
>> When connected to a Gigabit switch
>> 3.4 negotiates a LAN DHCP setup instantly
>> 4.7 requires over 5 seconds to do so
> 
> When you run tcpdump on the DHCP server, are you noticing the first
> request is missing?
> 
> What can happen is the dhclient gets started immediately and sends out
> its first request before auto-negotiation has finished. So this first packet
> gets lost. The retransmit after a few seconds is then successful.

This is what happens on 3.4

# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 11:57:12 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 11:57:12 UTC 2016
Sending discover...
[   50.150000] tangox-enet.0: link up (1000 Mbps - Full Duplex)
Mon Nov 14 11:57:15 UTC 2016
Sending discover...
Mon Nov 14 11:57:16 UTC 2016
Sending select for 172.27.64.58...
Mon Nov 14 11:57:17 UTC 2016
Lease of 172.27.64.58 obtained, lease time 604800
Mon Nov 14 11:57:17 UTC 2016
deleting routers
Mon Nov 14 11:57:17 UTC 2016
adding dns 172.27.0.17

real    0m4.704s
user    0m0.030s
sys     0m0.550s


The corresponding log on the DHCP server was

# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
11:57:16.095474 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:57:16.095638 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
11:57:17.096740 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:57:17.097182 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:57:17.202842 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:57:21.101946 ARP, Request who-has 172.27.64.58 tell 172.27.64.1, length 28
11:57:21.102182 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46


This is a different log which I got earlier, but can no longer reproduce:

# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
11:08:09.610662 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:08:10.642852 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:08:10.643276 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:08:10.790526 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:08:11.638146 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46
11:08:11.638156 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
11:08:11.638345 IP 172.27.64.58 > 172.27.64.1: ICMP echo reply, id 29883, seq 0, length 28
11:08:16.642811 ARP, Request who-has 172.27.64.1 tell 172.27.64.58, length 46
11:08:16.642822 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28



This is what happens on v4.7

# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 11:51:25 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 11:51:25 UTC 2016
Sending discover...
Mon Nov 14 11:51:28 UTC 2016
Sending discover...
[  342.658572] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
Mon Nov 14 11:51:32 UTC 2016
Sending discover...
Mon Nov 14 11:51:33 UTC 2016
Sending select for 172.27.64.58...
Mon Nov 14 11:51:33 UTC 2016
Lease of 172.27.64.58 obtained, lease time 604800
Mon Nov 14 11:51:33 UTC 2016
deleting routers
Mon Nov 14 11:51:33 UTC 2016
adding dns 172.27.0.17

real    0m7.348s
user    0m0.053s
sys     0m0.077s


The corresponding log on the DHCP server was

# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
11:51:31.957245 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:51:31.957409 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
11:51:32.958514 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:51:32.970538 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
11:51:33.038205 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
11:51:36.957949 ARP, Request who-has 172.27.64.58 tell 172.27.64.1, length 28
11:51:36.958112 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46


For reference, here are the ethtool statistics on 4.7 after the DHCP setup:

# ethtool -S eth0
NIC statistics:
     rx_bytes_ok: 1747
     rx_frames_ok: 9
     rx_undersize_frames: 0
     rx_fragment_frames: 0
     rx_64_byte_frames: 3
     rx_127_byte_frames: 2
     rx_255_byte_frames: 1
     rx_511_byte_frames: 3
     rx_1023_byte_frames: 0
     rx_max_size_frames: 0
     rx_oversize_frames: 0
     rx_bad_fcs_frames: 0
     rx_broadcast_frames: 4
     rx_multicast_frames: 1
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 1747
     rx_frames: 9
     tx_bytes_ok: 756
     tx_frames_ok: 3
     tx_64_byte_frames: 1
     tx_127_byte_frames: 0
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
     tx_bytes: 756
     tx_frames: 3
     tx_collisions: 0


Regards.
