From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 iproute2 0/5] iproute2: Add FOU and GUE configuration in ip
Date: Wed,  5 Nov 2014 10:06:23 -0800
Message-ID: <1415210788-8058-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:48525 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaKESGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:06:41 -0500
Received: by mail-ig0-f171.google.com with SMTP id hl2so9167804igb.4
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:06:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support in iproute2 to configure FOU and GUE ports
for receive, and using FOU or GUE with ip tunnels (IPIP, GRE, sit) on
transmit.

A new ip subcommand "fou" has been added to configure FOU/GUE ports.
For example:

  ip fou add port 5555 gue 
  ip fou add port 9999 ipproto 4

The first command creates a GUE port, the second creates a direct FOU
port for IPIP (receive payload is a assumed to be an IP packet).

fou.8 and gue.8 man pages were added to describe this command.

To configure an IP tunnel to use FOU or GUE encap parameters have
been added. For example:

  ip link add name tun1 type ipip remote 192.168.1.1 local 192.168.1.2 \
     ttl 225 encap gue encap-sport auto encap-dport 7777 encap-csum
  ip link add name tun2 type gre remote 192.168.1.1 local 192.168.1.2 \
     ttl 225 encap fou encap-sport auto encap-dport 8888 encap-csum

The first command configures an IPIP tunnel to use GUE on transmit. The
peer might be configured to receive GUE packets with the
"ip fou add port 7777 gue" command.

The second configures a GRE tunnel to use FOU encapsulation. The
peer might be configured to receive these packets with the
"ip fou add port 8888 ipproto 47" command.

v2:
  - Add man pages fou.8 and gue.8
  - Add ntohs for print ports in configuration
  - Add support for remote checksum offload

Tom Herbert (5):
  ip fou: Support to configure foo-over-udp RX
  ip link ipip: Add support to configure FOU and GUE
  ip link gre: Add support to configure FOU and GUE
  ip link: Add support for remote checksum offload
  iproute2: Man pages for fou and gue

 include/linux/fou.h       |  41 ++++++++++++
 include/linux/if_tunnel.h |   1 +
 ip/Makefile               |   2 +-
 ip/ip.c                   |   3 +-
 ip/ip_common.h            |   1 +
 ip/ipfou.c                | 159 ++++++++++++++++++++++++++++++++++++++++++++++
 ip/link_gre.c             |  98 ++++++++++++++++++++++++++++
 ip/link_iptnl.c           |  98 ++++++++++++++++++++++++++++
 man/man8/ip-fou.8         |  76 ++++++++++++++++++++++
 man/man8/ip-gue.8         |   1 +
 10 files changed, 478 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/fou.h
 create mode 100644 ip/ipfou.c
 create mode 100644 man/man8/ip-fou.8
 create mode 100644 man/man8/ip-gue.8

-- 
2.1.0.rc2.206.gedb03e5
