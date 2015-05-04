From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/6] net: Increase inputs to flow_keys hashing
Date: Mon, 4 May 2015 16:02:34 -0700
Message-ID: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51934 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751025AbbEDXCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:02:53 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t44MwTKo024757
	for <netdev@vger.kernel.org>; Mon, 4 May 2015 16:02:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u6h34879a-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 May 2015 16:02:53 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 b0ad4e32f2b111e4bf310002c9521c9e-cbade1e0 for <netdev@vger.kernel.org>;	Mon,
 04 May 2015 16:02:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds new fields to the flow_keys structure and hashes
over these fields to get a better flow hash. In particular, these
patches now include hashing over the full IPv6 addresses in order
to defend against address spoofing that always results in the
same hash. The new input also includes the Ethertype, L4 protocol,
VLAN, flow label, GRE keyid, and MPLS entropy label.

In order to increase hash inputs, we switch to using jhash2
which operates an an array of u32's. jhash2 operates on multiples of
three words. The data in the hash is constructed for that, and there
are are two variants for IPv4 and Ipv6 addressing. For IPv4 addresses,
jhash is performed over six u32's and for IPv6 it is done over twelve.

flow_keys can store either IPv4 or IPv6 addresses (addr_proto field
is a selector). ipv6_addr_hash is no longer used to convert addresses
for setting in flow table. For legacy uses of flow keys outside of
flow_dissector the flow_get_u32_src and flow_get_u32_dst functions
have been added to get u32 representation representations of addresses
in flow_keys.

For flow labels we also eliminate the short circuit in flow_dissector
for non-zero flow label. The flow label is now considered additional
input to ports.

Testing: Ran netperf TCP_RR for 200 flows using IPv4 and IPv6 comparing
before the patches and with the patches. Did not detect any performance
degradation.

Tom Herbert (6):
  net: Get skb hash over flow_keys structure
  net: Add full IPv6 addresses to flow_keys
  net: Add VLAN ID to flow_keys
  net: Add IPv6 flow label to flow_keys
  net: Add GRE keyid in flow_keys
  mpls: Add MPLS entropy label in flow_keys

 drivers/net/bonding/bond_main.c                |   9 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |   8 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   4 +-
 include/net/flow_keys.h                        |  44 +++++-
 include/net/ip.h                               |  21 ++-
 include/net/ipv6.h                             |  21 ++-
 include/uapi/linux/in.h                        |   2 +
 include/uapi/linux/mpls.h                      |   3 +
 net/core/flow_dissector.c                      | 184 ++++++++++++++++++-------
 net/sched/cls_flow.c                           |  14 +-
 10 files changed, 239 insertions(+), 71 deletions(-)

-- 
1.8.1
