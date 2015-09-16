From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 11/30] ipv4: Only compute net once in ip_do_fragment
Date: Tue, 15 Sep 2015 20:03:59 -0500
Message-ID: <1442365458-16349-11-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60412 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbbIPBNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:41 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_output.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9ee622ad8dfa..85b72d450184 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -531,9 +531,11 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
+	struct net *net;
 	int err = 0;
 
 	dev = rt->dst.dev;
+	net = dev_net(dev);
 
 	/*
 	 *	Point into the IP datagram header.
@@ -626,7 +628,7 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 			err = output(sk, skb);
 
 			if (!err)
-				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+				IP_INC_STATS(net, IPSTATS_MIB_FRAGCREATES);
 			if (err || !frag)
 				break;
 
@@ -636,7 +638,7 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 		}
 
 		if (err == 0) {
-			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+			IP_INC_STATS(net, IPSTATS_MIB_FRAGOKS);
 			return 0;
 		}
 
@@ -645,7 +647,7 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 			kfree_skb(frag);
 			frag = skb;
 		}
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		return err;
 
 slow_path_clean:
@@ -767,15 +769,15 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+		IP_INC_STATS(net, IPSTATS_MIB_FRAGCREATES);
 	}
 	consume_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+	IP_INC_STATS(net, IPSTATS_MIB_FRAGOKS);
 	return err;
 
 fail:
 	kfree_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+	IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
 EXPORT_SYMBOL(ip_do_fragment);
-- 
2.2.1
