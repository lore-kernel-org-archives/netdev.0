From: kaber@trash.net
Subject: [PATCH 6/6] netfilter: nf_nat: avoid double seq_adjust for loopback
Date: Thu, 16 Jun 2011 21:41:41 +0200
Message-ID: <1308253301-29894-7-git-send-email-kaber@trash.net>
References: <1308253301-29894-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64069 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758018Ab1FPTlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:41:47 -0400
In-Reply-To: <1308253301-29894-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	Avoid double seq adjustment for loopback traffic
because it causes silent repetition of TCP data. One
example is passive FTP with DNAT rule and difference in the
length of IP addresses.

	This patch adds check if packet is sent and
received via loopback device. As the same conntrack is
used both for outgoing and incoming direction, we restrict
seq adjustment to happen only in POSTROUTING.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack.h           |    6 ++++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 +++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index c7c42e7..5d4f8e5 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -307,6 +307,12 @@ static inline int nf_ct_is_untracked(const struct nf_conn *ct)
 	return test_bit(IPS_UNTRACKED_BIT, &ct->status);
 }
 
+/* Packet is received from loopback */
+static inline bool nf_is_loopback_packet(const struct sk_buff *skb)
+{
+	return skb->dev && skb->skb_iif && skb->dev->flags & IFF_LOOPBACK;
+}
+
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index db10075..de9da21 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -121,7 +121,9 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 		return ret;
 	}
 
-	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)) {
+	/* adjust seqs for loopback traffic only in outgoing direction */
+	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status) &&
+	    !nf_is_loopback_packet(skb)) {
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
 
 		seq_adjust = rcu_dereference(nf_nat_seq_adjust_hook);
-- 
1.7.2.3

