From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: nf_ct_ipv4: packets with wrong ihl are invalid
Date: Tue, 10 Apr 2012 14:49:00 +0200
Message-ID: <1334062141-3962-5-git-send-email-pablo@netfilter.org>
References: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

It was reported that the Linux kernel sometimes logs:

klogd: [2629147.402413] kernel BUG at net / netfilter /
nf_conntrack_proto_tcp.c: 447!
klogd: [1072212.887368] kernel BUG at net / netfilter /
nf_conntrack_proto_tcp.c: 392

ipv4_get_l4proto() in nf_conntrack_l3proto_ipv4.c and tcp_error() in
nf_conntrack_proto_tcp.c should catch malformed packets, so the errors
at the indicated lines - TCP options parsing - should not happen.
However, tcp_error() relies on the "dataoff" offset to the TCP header,
calculated by ipv4_get_l4proto().  But ipv4_get_l4proto() does not check
bogus ihl values in IPv4 packets, which then can slip through tcp_error()
and get caught at the TCP options parsing routines.

The patch fixes ipv4_get_l4proto() by invalidating packets with bogus
ihl value.

The patch closes netfilter bugzilla id 771.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 750b06a..cf73cc7 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -84,6 +84,14 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	*dataoff = nhoff + (iph->ihl << 2);
 	*protonum = iph->protocol;
 
+	/* Check bogus IP headers */
+	if (*dataoff > skb->len) {
+		pr_debug("nf_conntrack_ipv4: bogus IPv4 packet: "
+			 "nhoff %u, ihl %u, skblen %u\n",
+			 nhoff, iph->ihl << 2, skb->len);
+		return -NF_ACCEPT;
+	}
+
 	return NF_ACCEPT;
 }
 
-- 
1.7.2.5

