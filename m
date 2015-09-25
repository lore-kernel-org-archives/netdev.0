From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 2/5] netfilter: Push struct net down into nf_afinfo.reroute
Date: Fri, 25 Sep 2015 15:07:28 -0500
Message-ID: <1443211651-22154-2-git-send-email-ebiederm@xmission.com>
References: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38711 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932976AbbIYUPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 16:15:15 -0400
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network namespace is needed when routing a packet.
Stop making nf_afinfo.reroute guess which network namespace
is the proper namespace to route the packet in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h | 2 +-
 net/ipv4/netfilter.c      | 2 +-
 net/ipv6/netfilter.c      | 2 +-
 net/netfilter/nf_queue.c  | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 987c74cd523c..165ab2d14734 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -283,7 +283,7 @@ struct nf_afinfo {
 				 struct flowi *fl, bool strict);
 	void		(*saveroute)(const struct sk_buff *skb,
 				     struct nf_queue_entry *entry);
-	int		(*reroute)(struct sk_buff *skb,
+	int		(*reroute)(struct net *net, struct sk_buff *skb,
 				   const struct nf_queue_entry *entry);
 	int		route_key_size;
 };
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 61eafc9b4545..9e07e6f23398 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -104,7 +104,7 @@ static void nf_ip_saveroute(const struct sk_buff *skb,
 	}
 }
 
-static int nf_ip_reroute(struct sk_buff *skb,
+static int nf_ip_reroute(struct net *net, struct sk_buff *skb,
 			 const struct nf_queue_entry *entry)
 {
 	const struct ip_rt_info *rt_info = nf_queue_entry_reroute(entry);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index b4de08a83e0b..26911b93dc7a 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -93,7 +93,7 @@ static void nf_ip6_saveroute(const struct sk_buff *skb,
 	}
 }
 
-static int nf_ip6_reroute(struct sk_buff *skb,
+static int nf_ip6_reroute(struct net *net, struct sk_buff *skb,
 			  const struct nf_queue_entry *entry)
 {
 	struct ip6_rt_info *rt_info = nf_queue_entry_reroute(entry);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 9f3c3c25fa73..34f628e16a4c 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -199,7 +199,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	if (verdict == NF_ACCEPT) {
 		afinfo = nf_get_afinfo(entry->state.pf);
-		if (!afinfo || afinfo->reroute(skb, entry) < 0)
+		if (!afinfo || afinfo->reroute(entry->state.net, skb, entry) < 0)
 			verdict = NF_DROP;
 	}
 
-- 
2.2.1
