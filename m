From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] ipv6: check propagates sk in sk_mc_loop instead of skb->sk
Date: Fri, 15 Aug 2014 20:32:56 +0200
Message-ID: <1408127576-11518-3-git-send-email-jiri@resnulli.us>
References: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:40481 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaHOSdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:33:03 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so2661121wes.22
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:33:02 -0700 (PDT)
In-Reply-To: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the dst->output() path for ip6tunnel_xmit, the code assumes the skb
it has to transmit is attached to an inet socket, specifically via
ip6_finish_output2(): The sk_mc_loop() test triggers a WARN_ON() when the
provider of the packet is an AF_PACKET socket.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e2c93c6..a889a96 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -70,7 +70,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(skb->sk) &&
+		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(sk) &&
 		    ((mroute6_socket(dev_net(dev), skb) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
-- 
1.9.3
