From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/4] sctp: Drop ICMP packet too big message with MTU larger than current PMTU
Date: Tue, 21 Oct 2008 22:08:44 -0400
Message-ID: <1224641327-11913-2-git-send-email-vladislav.yasevich@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:31786 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbYJVCIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:08:52 -0400
In-Reply-To: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If ICMP packet too big message is received with MTU larger than current
PMTU, SCTP will still accept this ICMP message and sync the PMTU of assoc
with the wrong MTU.

Endpoing A                 Endpoint B
(ESTABLISHED)              (ESTABLISHED)
ICMP         --------->
(packet too big, MTU too larger)
                           sync PMTU

This patch fixed the problem by drop that ICMP message.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index a49fa80..bf612d9 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -369,7 +369,7 @@ static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 			   struct sctp_transport *t, __u32 pmtu)
 {
-	if (!t || (t->pathmtu == pmtu))
+	if (!t || (t->pathmtu <= pmtu))
 		return;
 
 	if (sock_owned_by_user(sk)) {
-- 
1.5.3.5

