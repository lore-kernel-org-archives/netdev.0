From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v3 0/4] fragmentation ICMP
Date: Thu,  7 May 2015 21:26:35 -0700
Message-ID: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:42321 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750886AbbEHEsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 00:48:15 -0400
Received: by mail-pd0-f182.google.com with SMTP id a3so63066766pde.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 21:48:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we send ICMP packets when errors occur during fragmentation or
de-fragmentation.  However, it is a bug when sending those ICMP packets
in the context of using netfilter for bridging.

Those ICMP packets are only expected in the context of routing, not in
bridging mode.

The local stack is not involved in bridging forward decisions, thus
should be not used for deciding the reverse path for those ICMP messages.

This bug only affects IPV4, not in IPv6.

---
v1->v2:  restructure the patches into two patches that fix defragmentation and
         fragmentation respectively. 

	 A bit is add in IPCB to control whether ICMP packet should be
	 generated for defragmentation.

	 Fragmentation ICMP is now removed by restructuring the
	 ip_fragment() API.

v2->v3:  Add droping icmp for bridging contrack users
         drop exporting ip_fragment() API.

Andy Zhou (4):
  ipv4: introduce frag_expire_skip_icmp()
  IPv4: skip ICMP for bridge contrack users when defrag expires
  bridge_netfilter: No ICMP packet on IPv4 defragmentation timeout
  bridge_netfilter: No ICMP packet on IPv4 fragmentation error

 include/net/inet_frag.h   |  4 +++-
 include/net/ip.h          | 15 +++++++++++++--
 net/bridge/br_netfilter.c | 26 +++++++++++++++++++++++++-
 net/ipv4/ip_fragment.c    | 25 ++++++++++++++++++++-----
 net/ipv4/ip_output.c      | 40 ++++++++++++++++++++++++++++------------
 5 files changed, 89 insertions(+), 21 deletions(-)

-- 
1.9.1
