From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: fix compat recvmsg
Date: Mon, 16 Aug 2010 09:20:44 +0200
Message-ID: <1281943244.3683.8.camel@jlt3.sipsolutions.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
	 <1281939002.2942.70.camel@edumazet-laptop>
	 <1281939753.3683.5.camel@jlt3.sipsolutions.net>
	 <1281940172.2942.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kalle Valo <kalle.valo@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52393 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab0HPHUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 03:20:47 -0400
In-Reply-To: <1281940172.2942.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Since
commit 1dacc76d0014a034b8aca14237c127d7c19d7726
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Wed Jul 1 11:26:02 2009 +0000

    net/compat/wext: send different messages to compat tasks

we had a race condition when setting and then
restoring frag_list. Eric attempted to fix it,
but the fix created even worse problems.

However, the original motivation I had when I
added the code that turned out to be racy is
no longer clear to me, since we only copy up
to skb->len to userspace, which doesn't include
the frag_list length. As a result, not doing
any frag_list clearing and restoring avoids
the race condition, while not introducing any
other problems.

Additionally, while preparing this patch I found
that since none of the remaining netlink code is
really aware of the frag_list, we need to use the
original skb's information for packet information
and credentials. This fixes, for example, the
group information received by compat tasks.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@kernel.org [2.6.31+, for 2.6.35 revert 1235f504aa]
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c |   46 ++++++++++++++++------------------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

--- wireless-testing.orig/net/netlink/af_netlink.c	2010-08-16 08:33:42.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2010-08-16 09:13:17.000000000 +0200
@@ -1406,7 +1406,7 @@ static int netlink_recvmsg(struct kiocb
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
 	size_t copied;
-	struct sk_buff *skb, *frag __maybe_unused = NULL;
+	struct sk_buff *skb, *data_skb;
 	int err;
 
 	if (flags&MSG_OOB)
@@ -1418,45 +1418,35 @@ static int netlink_recvmsg(struct kiocb
 	if (skb == NULL)
 		goto out;
 
+	data_skb = skb;
+
 #ifdef CONFIG_COMPAT_NETLINK_MESSAGES
 	if (unlikely(skb_shinfo(skb)->frag_list)) {
-		bool need_compat = !!(flags & MSG_CMSG_COMPAT);
-
 		/*
-		 * If this skb has a frag_list, then here that means that
-		 * we will have to use the frag_list skb for compat tasks
-		 * and the regular skb for non-compat tasks.
+		 * If this skb has a frag_list, then here that means that we
+		 * will have to use the frag_list skb's data for compat tasks
+		 * and the regular skb's data for normal (non-compat) tasks.
 		 *
-		 * The skb might (and likely will) be cloned, so we can't
-		 * just reset frag_list and go on with things -- we need to
-		 * keep that. For the compat case that's easy -- simply get
-		 * a reference to the compat skb and free the regular one
-		 * including the frag. For the non-compat case, we need to
-		 * avoid sending the frag to the user -- so assign NULL but
-		 * restore it below before freeing the skb.
+		 * If we need to send the compat skb, assign it to the
+		 * 'data_skb' variable so that it will be used below for data
+		 * copying. We keep 'skb' for everything else, including
+		 * freeing both later.
 		 */
-		if (need_compat) {
-			struct sk_buff *compskb = skb_shinfo(skb)->frag_list;
-			skb_get(compskb);
-			kfree_skb(skb);
-			skb = compskb;
-		} else {
-			frag = skb_shinfo(skb)->frag_list;
-			skb_shinfo(skb)->frag_list = NULL;
-		}
+		if (flags & MSG_CMSG_COMPAT)
+			data_skb = skb_shinfo(skb)->frag_list;
 	}
 #endif
 
 	msg->msg_namelen = 0;
 
-	copied = skb->len;
+	copied = data_skb->len;
 	if (len < copied) {
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
 
-	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_reset_transport_header(data_skb);
+	err = skb_copy_datagram_iovec(data_skb, 0, msg->msg_iov, copied);
 
 	if (msg->msg_name) {
 		struct sockaddr_nl *addr = (struct sockaddr_nl *)msg->msg_name;
@@ -1476,11 +1466,7 @@ static int netlink_recvmsg(struct kiocb
 	}
 	siocb->scm->creds = *NETLINK_CREDS(skb);
 	if (flags & MSG_TRUNC)
-		copied = skb->len;
-
-#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
-	skb_shinfo(skb)->frag_list = frag;
-#endif
+		copied = data_skb->len;
 
 	skb_free_datagram(sk, skb);
 


