From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/4] gro: Fixes for tunnels and GRO
Date: Mon, 3 Aug 2015 10:11:14 -0700
Message-ID: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61522 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754294AbbHCRLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 13:11:49 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t73H6ffI009540
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2015 10:11:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1w2a678bn5-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 10:11:48 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 b85cc94e3a0211e5991324be0595f910-e53f32b0 for <netdev@vger.kernel.org>;	Mon,
 03 Aug 2015 10:11:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses some issue related to tunneling and GRO:

- Ensure headers are pull into skb->head when putting 1st packet onto
  GRO list
- Fix remote checksum offload to properly deal with frag0 in GRO.
- Add support for GRO at VXLAN tunnel (call gro_cells)

Testing: Ran one netperf TCP_STREAM to highlight impact of different
configurations:

GUE
  Zero UDP checksum
    4628.42 MBps
  UDP checksums enabled
    6800.51 MBps
  UDP checksums and remote checksum offload
    7663.82 MBps
  UDP checksums and remote checksum offload using no-partial
    7287.25 MBps

VXLAN
  Zero UDP checksum
    4112.02
  UDP checksums enabled
    6785.80 MBps
  UDP checksums and remote checksum offload
    7075.56 MBps
    
v2:
  - Drop "gro: Pull headers into skb head for 1st skb in gro list"
    from patch set
  - In vxlan_remcsum and gue_remcsum return immediately if remcsum
    processing was already done
  - Add gro callbacks for sit offload
  - Use WARN_ON_ONCE if we get a GUE protocol that does not have
    GRO offload support


Tom Herbert (4):
  gro: Fix remcsum offload to deal with frags in GRO
  vxlan: GRO support at tunnel layer
  ipv6: Add gro functions to sit_offloads
  fou: Do WARN_ON_ONCE in gue_gro_receive for bad proto callbacks

 drivers/net/vxlan.c       | 32 ++++++++++++++++----------------
 include/linux/netdevice.h | 44 ++++++++++++++++++++++++++++++++------------
 include/net/vxlan.h       |  1 +
 net/ipv4/fou.c            | 30 +++++++++++++-----------------
 net/ipv6/ip6_offload.c    |  2 ++
 5 files changed, 64 insertions(+), 45 deletions(-)

-- 
1.8.5.6
