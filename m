From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 0/3] gro: Fixes for tunnels and GRO
Date: Wed, 19 Aug 2015 17:07:31 -0700
Message-ID: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47038 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbbHTAHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 20:07:52 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7K05WAh021648
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wd2v306mv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:51 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 7df2a38046cf11e5bbd524be0593f280-d5bfa2b0 for <netdev@vger.kernel.org>;	Wed,
 19 Aug 2015 17:07:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses some issue related to tunneling and GRO:

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

v3:
  - Don't restore gro callbacks for sit offload


Tom Herbert (3):
  gro: Fix remcsum offload to deal with frags in GRO
  vxlan: GRO support at tunnel layer
  fou: Do WARN_ON_ONCE in gue_gro_receive for bad proto callbacks

 drivers/net/vxlan.c       | 32 ++++++++++++++++----------------
 include/linux/netdevice.h | 44 ++++++++++++++++++++++++++++++++------------
 include/net/vxlan.h       |  1 +
 net/ipv4/fou.c            | 30 +++++++++++++-----------------
 4 files changed, 62 insertions(+), 45 deletions(-)

-- 
1.8.1
