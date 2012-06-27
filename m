From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/18] unix_diag: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:32 -0700 (PDT)
Message-ID: <20120626.220232.1072696225565818854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853Ab2F0FCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:33 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 29773584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too and remove useless
casts.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/unix/diag.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 7e8a24b..977ca31 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -126,10 +126,12 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	struct nlmsghdr *nlh;
 	struct unix_diag_msg *rep;
 
-	nlh = NLMSG_PUT(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep));
+	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep), 0);
+	if (!nlh)
+		goto out_nlmsg_trim;
 	nlh->nlmsg_flags = flags;
 
-	rep = NLMSG_DATA(nlh);
+	rep = nlmsg_data(nlh);
 
 	rep->udiag_family = AF_UNIX;
 	rep->udiag_type = sk->sk_type;
@@ -139,32 +141,32 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 
 	if ((req->udiag_show & UDIAG_SHOW_NAME) &&
 	    sk_diag_dump_name(sk, skb))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	if ((req->udiag_show & UDIAG_SHOW_VFS) &&
 	    sk_diag_dump_vfs(sk, skb))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	if ((req->udiag_show & UDIAG_SHOW_PEER) &&
 	    sk_diag_dump_peer(sk, skb))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	if ((req->udiag_show & UDIAG_SHOW_ICONS) &&
 	    sk_diag_dump_icons(sk, skb))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	if ((req->udiag_show & UDIAG_SHOW_RQLEN) &&
 	    sk_diag_show_rqlen(sk, skb))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	if ((req->udiag_show & UDIAG_SHOW_MEMINFO) &&
 	    sock_diag_put_meminfo(sk, skb, UNIX_DIAG_MEMINFO))
-		goto nlmsg_failure;
+		goto out_nlmsg_trim;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
+out_nlmsg_trim:
 	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
@@ -189,7 +191,7 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct unix_diag_req *req;
 	int num, s_num, slot, s_slot;
 
-	req = NLMSG_DATA(cb->nlh);
+	req = nlmsg_data(cb->nlh);
 
 	s_slot = cb->args[0];
 	num = s_num = cb->args[1];
@@ -309,7 +311,7 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		};
 		return netlink_dump_start(sock_diag_nlsk, skb, h, &c);
 	} else
-		return unix_diag_get_exact(skb, h, (struct unix_diag_req *)NLMSG_DATA(h));
+		return unix_diag_get_exact(skb, h, nlmsg_data(h));
 }
 
 static const struct sock_diag_handler unix_diag_handler = {
-- 
1.7.10.2
