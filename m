From: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: ipv4,nodefrag: check socket type before touching nodefrag flag
Date: Mon, 20 Sep 2010 11:27:56 +0200
Message-ID: <1284974876-4596-1-git-send-email-jolsa@redhat.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

hi,
we need to check proper socket type within ipv4_conntrack_defrag
function before referencing the nodefrag flag.

For example the tun driver receive path produces skbs with
AF_UNSPEC socket type, and so current code is causing unwanted
fragmented packets going out.

wbr,
jirka



Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index eab8de3..f3a9b42 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -66,9 +66,11 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 					  const struct net_device *out,
 					  int (*okfn)(struct sk_buff *))
 {
+	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(skb->sk);
 
-	if (inet && inet->nodefrag)
+	if (sk && (sk->sk_family == PF_INET) &&
+	    inet->nodefrag)
 		return NF_ACCEPT;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
