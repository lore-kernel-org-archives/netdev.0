From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 1/3] ipv4: Only compute net once in ip_call_ra_chain
Date: Fri,  9 Oct 2015 13:44:53 -0500
Message-ID: <1444416295-31683-1-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47193 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755920AbbJISwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 14:52:55 -0400
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_call_ra_chain is called early in the forwarding chain from
ip_forward and ip_mr_input, which makes skb->dev the correct
expression to get the input network device and dev_net(skb->dev) a
correct expression for the network namespace the packet is being
processed in.

Compute the network namespace and store it in a variable to make the
code clearer.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_input.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 7cc9f7bb7fb7..804b86fd615f 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -157,6 +157,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	u8 protocol = ip_hdr(skb)->protocol;
 	struct sock *last = NULL;
 	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 
 	for (ra = rcu_dereference(ip_ra_chain); ra; ra = rcu_dereference(ra->next)) {
 		struct sock *sk = ra->sk;
@@ -167,7 +168,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 		if (sk && inet_sk(sk)->inet_num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
-		    net_eq(sock_net(sk), dev_net(dev))) {
+		    net_eq(sock_net(sk), net)) {
 			if (ip_is_fragment(ip_hdr(skb))) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
 					return true;
-- 
2.2.1
