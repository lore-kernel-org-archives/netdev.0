From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: frag: Always orphan skbs inside ip_defrag()
Date: Fri, 22 Jan 2016 17:22:42 -0800
Message-ID: <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453506552-10373-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hannes@stressinduktion.org,
	pshelar@ovn.org
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32866 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948AbcAWBWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 20:22:45 -0500
Received: by mail-pf0-f182.google.com with SMTP id e65so50829207pfe.0
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 17:22:44 -0800 (PST)
In-Reply-To: <1453506552-10373-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-22 at 15:49 -0800, Joe Stringer wrote:
> Later parts of the stack (including fragmentation) expect that there is
> never a socket attached to frag in a frag_list, however this invariant
> was not enforced on all defrag paths. This could lead to the
> BUG_ON(skb->sk) during ip_do_fragment(), as per the call stack at the
> end of this commit message.
> 
> While the call could be added to openvswitch to fix this particular
> error, the head and tail of the frags list are already orphaned
> indirectly inside ip_defrag(), so it seems like the remaining fragments
> should all be orphaned in all circumstances.


Yes, it looks we have a problem, and even IP early demux apparently does
not check if incoming packet is a fragment.

Your patch could also remove some socket leaks in this respect.

I guess we also could add a safety check (ipv4 only, but ipv6 needs care
as well)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index b1209b63381f..99513c829213 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -316,7 +316,9 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
-	if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
+	if (sysctl_ip_early_demux &&
+	    !skb_dst(skb) && !skb->sk &&
+	    !ip_is_fragment(iph)) {
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
