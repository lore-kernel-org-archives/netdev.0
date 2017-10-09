From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] ipv6: addrlabel: rework ip6addrlbl_get()
Date: Mon,  9 Oct 2017 09:52:24 -0700
Message-ID: <20171009165225.7008-2-edumazet@google.com>
References: <20171009165225.7008-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:47374 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754255AbdJIQwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:52:31 -0400
Received: by mail-pf0-f180.google.com with SMTP id z11so4397973pfk.4
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:52:31 -0700 (PDT)
In-Reply-To: <20171009165225.7008-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we allocate skb before the lookup, we can use RCU
without the need of ip6addrlbl_hold()

This means that the following patch can get rid of refcounting.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrlabel.c | 36 +++++++++++++-----------------------
 1 file changed, 13 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index c6311d7108f651c7385cd6316752ba4a86667dcc..f31489652c4ae1fc0c93d1756e13717f0689b0ab 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -546,38 +546,28 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 	addr = nla_data(tb[IFAL_ADDRESS]);
 
-	rcu_read_lock();
-	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
-	if (p && !ip6addrlbl_hold(p))
-		p = NULL;
-	lseq = net->ipv6.ip6addrlbl_table.seq;
-	rcu_read_unlock();
-
-	if (!p) {
-		err = -ESRCH;
-		goto out;
-	}
-
 	skb = nlmsg_new(ip6addrlbl_msgsize(), GFP_KERNEL);
-	if (!skb) {
-		ip6addrlbl_put(p);
+	if (!skb)
 		return -ENOBUFS;
-	}
 
-	err = ip6addrlbl_fill(skb, p, lseq,
-			      NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			      RTM_NEWADDRLABEL, 0);
+	err = -ESRCH;
 
-	ip6addrlbl_put(p);
+	rcu_read_lock();
+	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
+	lseq = net->ipv6.ip6addrlbl_table.seq;
+	if (p)
+		err = ip6addrlbl_fill(skb, p, lseq,
+				      NETLINK_CB(in_skb).portid,
+				      nlh->nlmsg_seq,
+				      RTM_NEWADDRLABEL, 0);
+	rcu_read_unlock();
 
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(skb);
-		goto out;
+	} else {
+		err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 	}
-
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
-out:
 	return err;
 }
 
-- 
2.14.2.920.gcf0c67979c-goog
