From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 13:45:40 +0100
Message-ID: <5829B1F4.8040708@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5829AA80.2090102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
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
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:28974 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932305AbcKNMqO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 07:46:14 -0500
In-Reply-To: <5829AA80.2090102@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/2016 13:13, Mason wrote:

> This is a different log which I got earlier, but can no longer reproduce:
> 
> # tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
> 11:08:09.610662 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
> 11:08:10.642852 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
> 11:08:10.643276 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
> 11:08:10.790526 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
> 11:08:11.638146 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46
> 11:08:11.638156 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
> 11:08:11.638345 IP 172.27.64.58 > 172.27.64.1: ICMP echo reply, id 29883, seq 0, length 28
> 11:08:16.642811 ARP, Request who-has 172.27.64.1 tell 172.27.64.58, length 46
> 11:08:16.642822 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28

Additional tests on v4.7

If I set the link up *BEFORE* running the DHCP client, then I get:

# ip link set eth0 up /* Wait 4-5 seconds */
[   69.815303] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx

# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 13:27:30 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 13:27:30 UTC 2016
Sending discover...
Mon Nov 14 13:27:31 UTC 2016
Sending select for 172.27.64.58...
Mon Nov 14 13:27:32 UTC 2016
Lease of 172.27.64.58 obtained, lease time 604800
Mon Nov 14 13:27:32 UTC 2016
deleting routers
Mon Nov 14 13:27:32 UTC 2016
adding dns 172.27.0.17

real    0m1.292s
user    0m0.037s
sys     0m0.087s

# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
13:27:30.922880 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:27:30.923055 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
13:27:31.924151 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:27:31.936221 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:27:32.061869 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:27:35.933946 ARP, Request who-has 172.27.64.58 tell 172.27.64.1, length 28
13:27:35.934079 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46


I did see (once) the 9-packet trace (with the ping echo/reply)

# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
13:17:31.494117 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:17:32.495374 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:17:32.510753 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:17:32.591262 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:17:33.494093 ARP, Reply 172.27.64.58 is-at 00:16:e8:4b:b0:7d, length 46
13:17:33.494107 IP 172.27.64.1 > 172.27.64.58: ICMP echo request, id 29883, seq 0, length 28
13:17:33.494242 IP 172.27.64.58 > 172.27.64.1: ICMP echo reply, id 29883, seq 0, length 28
13:17:38.500651 ARP, Request who-has 172.27.64.1 tell 172.27.64.58, length 46
13:17:38.500663 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28

Since the ping request is sent from the DHCP server, perhaps the server
is checking its ARP table. I think it is not an important difference.


Experiment #2

Set link up, then down, then up. Then send DHCP request.

# ip link set eth0 up
[   39.185326] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[root@buildroot ~]# ip link set eth0 down
/* WAIT A LONG TIME FOR "Link is Down" MESSAGE */
# ip link set eth0 up
[  102.818598] nb8800 26000.ethernet eth0: Link is Down
[  104.828632] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx

Note: isn't it weird that I have to set link up before "link down" message appears?


# time udhcpc | while read LINE; do date; echo $LINE; done
Mon Nov 14 13:40:08 UTC 2016
udhcpc (v1.22.1) started
Mon Nov 14 13:40:08 UTC 2016
Sending discover...
Mon Nov 14 13:40:11 UTC 2016
Sending discover...
Mon Nov 14 13:40:14 UTC 2016
Sending discover...
Mon Nov 14 13:40:37 UTC 2016
Sending discover...
Mon Nov 14 13:40:40 UTC 2016
Sending discover...
Mon Nov 14 13:40:43 UTC 2016
Sending discover...
Mon Nov 14 13:41:06 UTC 2016
Sending discover...
Mon Nov 14 13:41:09 UTC 2016
Sending discover...
Mon Nov 14 13:41:12 UTC 2016
Sending discover...
Mon Nov 14 13:41:35 UTC 2016
Sending discover...
Mon Nov 14 13:41:38 UTC 2016
Sending discover...
Mon Nov 14 13:41:42 UTC 2016
Sending discover...
^C

real    1m37.623s
user    0m0.100s
sys     0m0.053s


# tcpdump -n -i eth1-boards ether host 00:16:e8:4b:b0:7d
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1-boards, link-type EN10MB (Ethernet), capture size 262144 bytes
13:40:08.593122 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:09.594365 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:40:11.619772 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:11.619925 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:40:14.646372 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:14.646535 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:40:37.706093 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:37.706257 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:40:40.732693 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:40.732827 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:40:43.759342 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:40:43.759475 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:06.819024 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:06.819201 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:09.845671 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:09.845807 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:12.872271 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:12.872396 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:35.931994 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:35.932162 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:38.958593 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:38.958742 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
13:41:41.985194 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:16:e8:4b:b0:7d, length 300
13:41:41.985359 IP 172.27.200.1.67 > 172.27.64.58.68: BOOTP/DHCP, Reply, length 391
^C
24 packets captured
24 packets received by filter
0 packets dropped by kernel


Link appears to be broken (not receiving) after up/down/up sequence.
Despite the rx_frames_ok: 8 ???
And why 8, server sent 12 replies...

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
     rx_broadcast_frames: 3
     rx_multicast_frames: 1
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 975
     rx_frames: 8
     tx_bytes_ok: 4344
     tx_frames_ok: 15
     tx_64_byte_frames: 3
     tx_127_byte_frames: 0
     tx_255_byte_frames: 0
     tx_511_byte_frames: 12
     tx_1023_byte_frames: 0
     tx_max_size_frames: 0
     tx_oversize_frames: 0
     tx_broadcast_frames: 12
     tx_multicast_frames: 0
     tx_control_frames: 0
     tx_pause_frames: 0
     tx_underrun_frames: 0
     tx_single_collision_frames: 0
     tx_multi_collision_frames: 0
     tx_deferred_collision_frames: 0
     tx_late_collision_frames: 0
     tx_excessive_collision_frames: 0
     tx_bytes: 4344
     tx_frames: 15
     tx_collisions: 0


Will add a few traces, as suggested by Florian.

Regards.
