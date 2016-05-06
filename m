From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 07/11] ipv6: Fix nexthdr for reinjection
Date: Fri, 6 May 2016 15:12:02 -0700
Message-ID: <1462572726-566137-8-git-send-email-tom@herbertland.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33863 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758841AbcEFWMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:12:24 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u46M8TUH023368
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 15:12:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22ruk83fd8-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:12:23 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9a836c5c13d711e6ae7d0002c9521c9e-807fcc50 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 15:12:21 -0700
In-Reply-To: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6_input_finish the protocol handle returns a value greater than
zero the packet needs to be resubmitted using the returned protocol.
The returned protocol is being ignored and each time through resubmit
nexthdr is taken from an offest in the packet. This patch fixes that
so that nexthdr is taken from return value of the protocol handler.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_input.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 6ed5601..2a0258a 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -222,13 +222,14 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
 	 */
 
 	rcu_read_lock();
-resubmit:
+
 	idev = ip6_dst_idev(skb_dst(skb));
 	if (!pskb_pull(skb, skb_transport_offset(skb)))
 		goto discard;
 	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb_network_header(skb)[nhoff];
 
+resubmit:
 	raw = raw6_local_deliver(skb, nexthdr);
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
 	if (ipprot) {
@@ -256,10 +257,12 @@ resubmit:
 			goto discard;
 
 		ret = ipprot->handler(skb);
-		if (ret > 0)
+		if (ret > 0) {
+			nexthdr = ret;
 			goto resubmit;
-		else if (ret == 0)
+		} else if (ret == 0) {
 			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDELIVERS);
+		}
 	} else {
 		if (!raw) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-- 
2.8.0.rc2
