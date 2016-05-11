From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 06/13] ipv6: Fix nexthdr for reinjection
Date: Wed, 11 May 2016 09:47:26 -0700
Message-ID: <1462985253-2380625-7-git-send-email-tom@herbertland.com>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:25558 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932448AbcEKQsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 12:48:21 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4BGlCXk022766
	for <netdev@vger.kernel.org>; Wed, 11 May 2016 09:48:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22v4rchq5q-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 May 2016 09:48:20 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 29f82896179811e6af730002c95209d8-993e9c50 for <netdev@vger.kernel.org>;	Wed,
 11 May 2016 09:48:19 -0700
In-Reply-To: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
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
