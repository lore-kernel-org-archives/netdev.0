From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 44/50] netfilter: nat: skip checksum on offload SCTP packets
Date: Wed,  7 Dec 2016 22:52:50 +0100
Message-ID: <1481147576-5690-45-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60252 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933451AbcLGVx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:57 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 275A8573E5
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:56 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 18A9FDA86C
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:56 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 04B39DA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:54 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

SCTP GSO and hardware can do CRC32c computation after netfilter processing,
so we can avoid calling sctp_compute_checksum() on skb if skb->ip_summed
is equal to CHECKSUM_PARTIAL. Moreover, set skb->ip_summed to CHECKSUM_NONE
when the NAT code computes the CRC, to prevent offloaders from computing
it again (on ixgbe this resulted in a transmission with wrong L4 checksum).

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_proto_sctp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 2e14108ff697..31d358691af0 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -47,7 +47,10 @@ sctp_manip_pkt(struct sk_buff *skb,
 		hdr->dest = tuple->dst.u.sctp.port;
 	}
 
-	hdr->checksum = sctp_compute_cksum(skb, hdroff);
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		hdr->checksum = sctp_compute_cksum(skb, hdroff);
+		skb->ip_summed = CHECKSUM_NONE;
+	}
 
 	return true;
 }
-- 
2.1.4
