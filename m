From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next] sched: act_csum: don't mangle TCP and UDP GSO packets
Date: Thu, 23 Mar 2017 10:39:40 +0100
Message-ID: <4e8409b7761a7b545febde6d2fcce0cbe7d0e759.1490261581.git.dcaratti@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43524 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbdCWJjr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 05:39:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after act_csum computes the checksum on skbs carrying GSO TCP/UDP packets,
subsequent segmentation fails because skb_needs_check(skb, true) returns
true. Because of that, skb_warn_bad_offload() is invoked and the following
message is displayed:

WARNING: CPU: 3 PID: 28 at net/core/dev.c:2553 skb_warn_bad_offload+0xf0/0xfd
<...>

  [<ffffffff8171f486>] skb_warn_bad_offload+0xf0/0xfd
  [<ffffffff8161304c>] __skb_gso_segment+0xec/0x110
  [<ffffffff8161340d>] validate_xmit_skb+0x12d/0x2b0
  [<ffffffff816135d2>] validate_xmit_skb_list+0x42/0x70
  [<ffffffff8163c560>] sch_direct_xmit+0xd0/0x1b0
  [<ffffffff8163c760>] __qdisc_run+0x120/0x270
  [<ffffffff81613b3d>] __dev_queue_xmit+0x23d/0x690
  [<ffffffff81613fa0>] dev_queue_xmit+0x10/0x20

Since GSO is able to compute checksum on individual segments of such skbs,
we can simply skip mangling the packet.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/sched/act_csum.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index e978ccd4..6c319a4 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -181,6 +181,9 @@ static int tcf_csum_ipv4_tcp(struct sk_buff *skb, unsigned int ihl,
 	struct tcphdr *tcph;
 	const struct iphdr *iph;
 
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+		return 1;
+
 	tcph = tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*tcph));
 	if (tcph == NULL)
 		return 0;
@@ -202,6 +205,9 @@ static int tcf_csum_ipv6_tcp(struct sk_buff *skb, unsigned int ihl,
 	struct tcphdr *tcph;
 	const struct ipv6hdr *ip6h;
 
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		return 1;
+
 	tcph = tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*tcph));
 	if (tcph == NULL)
 		return 0;
@@ -225,6 +231,9 @@ static int tcf_csum_ipv4_udp(struct sk_buff *skb, unsigned int ihl,
 	const struct iphdr *iph;
 	u16 ul;
 
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+		return 1;
+
 	/*
 	 * Support both UDP and UDPLITE checksum algorithms, Don't use
 	 * udph->len to get the real length without any protocol check,
@@ -278,6 +287,9 @@ static int tcf_csum_ipv6_udp(struct sk_buff *skb, unsigned int ihl,
 	const struct ipv6hdr *ip6h;
 	u16 ul;
 
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+		return 1;
+
 	/*
 	 * Support both UDP and UDPLITE checksum algorithms, Don't use
 	 * udph->len to get the real length without any protocol check,
-- 
2.7.4
