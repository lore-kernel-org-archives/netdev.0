From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: early demux should be aware of fragments
Date: Tue, 26 Jan 2016 16:59:42 -0800
Message-ID: <1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453506552-10373-1-git-send-email-joe@ovn.org>
	 <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
	 <1453787905.11327.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, fw@strlen.de,
	hannes@stressinduktion.org, pravin shelar <pshelar@ovn.org>
To: Joe Stringer <joe@ovn.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33040 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbcA0A7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 19:59:45 -0500
Received: by mail-pf0-f179.google.com with SMTP id x125so2421115pfb.0
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 16:59:45 -0800 (PST)
In-Reply-To: <1453787905.11327.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We should not assume a valid protocol header is present,
as this is not the case for IPv4 fragments.

Lets avoid extra cache line misses and potential bugs
if we actually find a socket and incorrectly uses its dst.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_input.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index b1209b63381f..d77eb0c3b684 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -316,7 +316,10 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
-	if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
+	if (sysctl_ip_early_demux &&
+	    !skb_dst(skb) &&
+	    !skb->sk &&
+	    !ip_is_fragment(iph)) {
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
