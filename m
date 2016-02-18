From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/4] iptunnel: scrub packet in iptunnel_pull_header
Date: Thu, 18 Feb 2016 11:22:48 +0100
Message-ID: <cover.1455790645.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426118AbcBRKXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:23:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As every IP tunnel has to scrub skb on decapsulation, iptunnel_pull_header
tried to do that and open coded part of skb_scrub_packet. Various tunneling
protocols (VXLAN, Geneve) then called full skb_scrub_packet on their own,
duplicating part of the scrubbing already done.

Consolidate the code, calling skb_scrub_packet from iptunnel_pull_header.
This will allow additional cleanups in VXLAN code, as the packet is scrubbed
early during rx processing after this patchset and VXLAN can start filling
out skb fields earlier.

The full picture of vxlan cleanup patches can be seen at:
https://github.com/jbenc/linux-vxlan/commits/master

Jiri Benc (4):
  geneve: implement geneve_get_sk_family helper
  geneve: move geneve device lookup before iptunnel_pull_header
  vxlan: move vxlan device lookup before iptunnel_pull_header
  iptunnel: scrub packet in iptunnel_pull_header

 drivers/net/geneve.c      | 98 +++++++++++++++++++++++++++--------------------
 drivers/net/vxlan.c       | 25 ++++++------
 include/net/ip_tunnels.h  |  3 +-
 net/ipv4/ip_gre.c         |  2 +-
 net/ipv4/ip_tunnel_core.c |  8 ++--
 net/ipv4/ipip.c           |  2 +-
 net/ipv6/sit.c            |  2 +-
 7 files changed, 76 insertions(+), 64 deletions(-)

-- 
1.8.3.1
