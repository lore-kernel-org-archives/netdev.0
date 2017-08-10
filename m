From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [RFC PATCH 0/2] Support of VPLS MPLS
Date: Thu, 10 Aug 2017 22:28:35 +0200
Message-ID: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35834 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753183AbdHJU27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 16:28:59 -0400
Received: by mail-wm0-f51.google.com with SMTP id m85so28246389wma.0
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 13:28:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small series implements the support of VPLS dataplane using MPLS
encapsulation to perform a l2VPN using a virtual network device.

The ingress ethernet frames are encapsulated and carried over an MPLS packet
switched network, then decapsulated in the egress router (LER) by a vpls
device.

This small schema describe how to configure a vpls device to perform l2VPN
over MPLS PSN:

in LER0:
  - ip link add name br0 type bridge
  - ip link set dev0 master br0
  - ip link add name vpls0 type vpls id 10 output 111 input 222 \
    via {{dev3_addr}} dev dev1
  - ip link set vpls0 master br0

in LER1:
  - ip link add name br1 type bridge
  - ip link set dev2 master br0
  - ip link add name vpls1 type vpls id 20 output 222 input 111 \
    via {{dev1_addr}} dev dev3
  - ip link set vpls1 master br1

                LER0                                     LER1
           +--------------+                       +--------------+
           |              |                       |              |
           | +- br0--+    |                       |  vpls1       |
           | |       |    |       +--------+      |    |         |
 ------- dev0+       |    |       |        |      |    |      +-dev2 ----------
           |         |   dev1 --- |MPLS PSN| --- dev3  |      |  |
10.1.0.0/24|         |    |       |        |      |    |      |  | 10.1.0.0/24
           |       vpls0  |       +--------+      |    +--br1-+  |
           |              |                       |              |
           +--------------+                       +--------------+

packet dissection:

                     |                                 |
ether0/ip0/payload   | ether1/mpls0/ether0/ip0/payload | ether0/ip0/payload
                     |                                 |

An Iproute2 patch is available to complete this serie here:
https://github.com/6WIND/iproute2/commit/0d1d3f2a5733421baf08e247d4ce2fb03cd666f1

Example of more detailed configurations with iproute2:

Create a VPLS vdev "vpls0" to neighbor 10.200.0.2 via dev1, encapsulate the
incoming Ethernet frame from the bridge in MPLS packets with label 111 with
ttl 10 and uncap recieved MPLS packets from dev1 with label 222:

	ip link add name vpls0 type vpls id 10 output 111 input 222 ttl 10 \
        via 10.200.0.2 dev dev1

Same configuration than the previous one just use Ipv6:

	ip link add name vpls0 type vpls id 10 output 111 input 222 ttl 10 \
        via fd00:200::2 dev dev1

Now the same configuration but tag the outer Ethernet frame with vlan id 55:

	ip link add name vpls0 type vpls id 10 output 111 input 222 vlan 55 \
	ttl 10 via 10.200.0.2 dev dev1

The approch for configuration is from OpenBSD, more information:
https://man.openbsd.org/mpw.4

TODO next:
  - Support of Pseudowire Emulation Edge-to-Edge (PWE3) datapath.
    https://tools.ietf.org/html/rfc4385
  - Add the support of lightweight VPLS tunnel for scalability. ie one device
    with many tunnels.
