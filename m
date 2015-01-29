From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 0/6] net: Add STT support.
Date: Thu, 29 Jan 2015 15:29:16 -0800
Message-ID: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:49169 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755531AbbA2X3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:22 -0500
Received: by mail-pa0-f54.google.com with SMTP id eu11so44509927pac.13
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series adds support for Stateless Transport
Tunneling protocol.
STT uses TCP segmentation offload available in most of NIC. On
packet xmit STT driver appends STT header along with TCP header
to the packet. For GSO packet GSO parameters are set according
to tunnel configuration and packet is handed over to networking
stack. This allows use of segmentation offload available in NICs

The protocol is documented at
http://www.ietf.org/archive/id/draft-davie-stt-06.txt

I will send out OVS userspace patch on ovs-dev mailing list.

Following are test results. All tests are done on net-next with
STT and VXLAN kernel device without OVS.

Single Netperf session:
=======================
VXLAN:
    CPU utilization
     - Send local: 1.26
     - Recv remote: 8.62
    Throughput: 4.9 Gbit/sec
STT:
    CPU utilization
     - Send local: 1.01
     - Recv remote: 1.8
    Throughput: 9.45 Gbit/sec

Five Netperf sessions:
======================
VXLAN:
    CPU utilization
     - Send local: 9.7
     - Recv remote: 70 (varies from 60 to 80)
    Throughput: 9.05 Gbit/sec
STT:
    CPU utilization
     - Send local: 5.85
     - Recv remote: 14
    Throughput: 9.47 Gbit/sec

v1-v2:
- Added STT device.
- Fixed first patch according to comments from Eric.

Pravin B Shelar (6):
  skbuff: Add skb_list_linearize()
  net: Add STT tunneling protocol.
  openvswitch: Add support for STT tunneling.
  ip_tunnel: Introduce tunnel_info struct.
  ip_tunnel: Extend tunnel_info for STT.
  net: Add STT device.

 include/linux/skbuff.h           |    2 +
 include/net/ip_tunnels.h         |   63 +-
 include/net/stt.h                |   59 ++
 include/uapi/linux/if_tunnel.h   |   17 +
 include/uapi/linux/openvswitch.h |    1 +
 net/core/skbuff.c                |   34 +
 net/ipv4/Kconfig                 |   20 +
 net/ipv4/Makefile                |    2 +
 net/ipv4/gre_demux.c             |    4 +-
 net/ipv4/ip_gre.c                |  183 +++--
 net/ipv4/ip_stt.c                |  410 +++++++++++
 net/ipv4/ip_tunnel.c             |  312 +++++----
 net/ipv4/ip_vti.c                |   75 +-
 net/ipv4/ipip.c                  |   88 +--
 net/ipv4/stt.c                   | 1398 ++++++++++++++++++++++++++++++++++++++
 net/ipv6/sit.c                   |  152 ++---
 net/openvswitch/Kconfig          |   10 +
 net/openvswitch/Makefile         |    1 +
 net/openvswitch/vport-stt.c      |  216 ++++++
 19 files changed, 2674 insertions(+), 373 deletions(-)
 create mode 100644 include/net/stt.h
 create mode 100644 net/ipv4/ip_stt.c
 create mode 100644 net/ipv4/stt.c
 create mode 100644 net/openvswitch/vport-stt.c

-- 
1.9.1
