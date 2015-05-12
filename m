From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/5] net: Increase inputs to flow_keys hashing
Date: Mon, 11 May 2015 20:26:39 -0700
Message-ID: <1431401204-731380-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63714 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752001AbbELD1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 23:27:42 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4C3OCCq005772
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ub5fsgp76-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:42 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 d7f309a0f85611e4bf310002c9521c9e-cbade1e0 for <netdev@vger.kernel.org>;	Mon,
 11 May 2015 20:27:40 -0700
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

For flow lables we also eliminate the short circuit in flow_dissector
for non-zero flow label. The flow label is now considered additional
input to ports.

Testing: Ran netperf TCP_RR for 200 flows using IPv4 and IPv6 comparing
before the patches and with the patches. Did not detect nay performance
degradation.

v2:
  - Took out MPLS entropy label. Will add this later.

Tom Herbert (5):
  net: Get skb hash over flow_keys structure
  net: Add full IPv6 addresses to flow_keys
  net: Add VLAN ID to flow_keys
  net: Add IPv6 flow label to flow_keys
  net: Add GRE keyid in flow_keys

 drivers/net/bonding/bond_main.c                |   9 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |   8 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   4 +-
 include/net/flow_keys.h                        |  44 ++++++-
 include/net/ip.h                               |  21 +++-
 include/net/ipv6.h                             |  21 +++-
 net/core/flow_dissector.c                      | 159 +++++++++++++++++--------
 net/sched/cls_flow.c                           |  14 ++-
 8 files changed, 208 insertions(+), 72 deletions(-)

-- 
1.8.1
