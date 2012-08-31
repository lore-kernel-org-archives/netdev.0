From: pablo@netfilter.org
Subject: [PATCH 5/6] netfilter: nf_nat_sip: fix incorrect handling of EBUSY for RTCP expectation
Date: Fri, 31 Aug 2012 16:03:08 +0200
Message-ID: <1346421789-3449-6-git-send-email-pablo@netfilter.org>
References: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54083 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695Ab2HaOEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 10:04:34 -0400
In-Reply-To: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

We're hitting bug while trying to reinsert an already existing
expectation:

kernel BUG at kernel/timer.c:895!
invalid opcode: 0000 [#1] SMP
[...]
Call Trace:
 <IRQ>
 [<ffffffffa0069563>] nf_ct_expect_related_report+0x4a0/0x57a [nf_conntrack]
 [<ffffffff812d423a>] ? in4_pton+0x72/0x131
 [<ffffffffa00ca69e>] ip_nat_sdp_media+0xeb/0x185 [nf_nat_sip]
 [<ffffffffa00b5b9b>] set_expected_rtp_rtcp+0x32d/0x39b [nf_conntrack_sip]
 [<ffffffffa00b5f15>] process_sdp+0x30c/0x3ec [nf_conntrack_sip]
 [<ffffffff8103f1eb>] ? irq_exit+0x9a/0x9c
 [<ffffffffa00ca738>] ? ip_nat_sdp_media+0x185/0x185 [nf_nat_sip]

We have to remove the RTP expectation if the RTCP expectation hits EBUSY
since we keep trying with other ports until we succeed.

Reported-by: Rafal Fitt <rafalf@aplusc.com.pl>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_sip.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 4ad9cf1..9c87cde 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -502,7 +502,10 @@ static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int dataoff,
 		ret = nf_ct_expect_related(rtcp_exp);
 		if (ret == 0)
 			break;
-		else if (ret != -EBUSY) {
+		else if (ret == -EBUSY) {
+			nf_ct_unexpect_related(rtp_exp);
+			continue;
+		} else if (ret < 0) {
 			nf_ct_unexpect_related(rtp_exp);
 			port = 0;
 			break;
-- 
1.7.10.4
