From: Feng King <kinwin2008@gmail.com>
Subject: [PATCH] conntrack: avoid unnecessary lock in tcp_packet
Date: Tue,  6 Dec 2011 20:35:07 +0800
Message-ID: <1323174907-2670-1-git-send-email-kinwin2008@gmail.com>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net,
	Feng King <kinwin2008@gmail.com>,
	Feng Jin <ronyjin@tencent.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45810 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933327Ab1LFMfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 07:35:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    when IPS_SEQ_ADJUST_BIT is not set, there are no need to obtain
net_offset in tcp_in_window from tcp_packet.
    nat_offset will acquire global nf_nat_seqofs_lock spinlock,
and on heavy load, there will be big contention. After 30 secs webbench
stress testing, we can see from lockstat:
                    nf_nat_seqofs_lock:        798200         798213
		    1.01          57.37      216229.42        9943722
		    10055712           0.61          60.70
		    1909636.49
 and from perf report, nf_nat_get_offset contributes 18.49% of our
 overall spin_lock_bh cost, It's unnecessary.

Signed-off-by: Feng Jin <ronyjin@tencent.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 8235b86..88c70f1 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -502,7 +502,8 @@ static inline s16 nat_offset(const struct nf_conn *ct,
 	return get_offset != NULL ? get_offset(ct, dir, seq) : 0;
 }
 #define NAT_OFFSET(pf, ct, dir, seq) \
-	(pf == NFPROTO_IPV4 ? nat_offset(ct, dir, seq) : 0)
+	((pf == NFPROTO_IPV4) && test_bit(IPS_SEQ_ADJUST_BIT, &ct->status) \
+	    ? nat_offset(ct, dir, seq) : 0)
 #else
 #define NAT_OFFSET(pf, ct, dir, seq)	0
 #endif
-- 
1.7.7.3
