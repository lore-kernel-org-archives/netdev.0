From: pablo@netfilter.org
Subject: [PATCH 1/2] netlink: netlink_dump_start may take data pointer for callbacks
Date: Fri, 24 Feb 2012 23:14:07 +0100
Message-ID: <1330121648-2956-2-git-send-email-pablo@netfilter.org>
References: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch modifies the netlink_dump_start function to take one
generic pointer to data. This pointer can be used inside the
dump() and done() callbacks via cb->data.

Netfilter is going to use this patch to provide filtered dumps
to user-space. This is specifically interesting in ctnetlink that
may handle lots of conntrack entries. We can save precious
cycles by skipping the conversion to TLV format of conntrack
entries that are not interesting for user-space.

More specifically, ctnetlink will include one operation to allow
to filter the dumping of conntrack entries by ctmark values.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 crypto/crypto_user.c                 |    2 +-
 drivers/infiniband/core/netlink.c    |    2 +-
 include/linux/netlink.h              |    2 ++
 net/core/rtnetlink.c                 |    2 +-
 net/ipv4/inet_diag.c                 |    4 ++--
 net/netfilter/ipset/ip_set_core.c    |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 net/netfilter/nfnetlink_acct.c       |    2 +-
 net/netlink/af_netlink.c             |    2 ++
 net/netlink/genetlink.c              |    2 +-
 net/unix/diag.c                      |    2 +-
 net/xfrm/xfrm_user.c                 |    2 +-
 12 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 16f8693..231d28a 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -391,7 +391,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EINVAL;
 
 		return netlink_dump_start(crypto_nlsk, skb, nlh,
-					  link->dump, link->done, 0);
+					  link->dump, link->done, NULL, 0);
 	}
 
 	err = nlmsg_parse(nlh, crypto_msg_min[type], attrs, CRYPTOCFGA_MAX,
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index d1c8196..13e8098 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -149,7 +149,7 @@ static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				return -EINVAL;
 			return netlink_dump_start(nls, skb, nlh,
 						  client->cb_table[op].dump,
-						  NULL, 0);
+						  NULL, NULL, 0);
 		}
 	}
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a390e9d..9f233ec 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -225,6 +225,7 @@ struct netlink_callback {
 	int			(*dump)(struct sk_buff * skb,
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
+	void			*data;
 	u16			family;
 	u16			min_dump_alloc;
 	unsigned int		prev_seq, seq;
@@ -252,6 +253,7 @@ extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
 			      int (*done)(struct netlink_callback*),
+			      void *data,
 			      u16 min_dump_alloc);
 
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 65aebd4..7de8b24 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1982,7 +1982,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		__rtnl_unlock();
 		rtnl = net->rtnl;
 		err = netlink_dump_start(rtnl, skb, nlh, dumpit,
-					 NULL, min_dump_alloc);
+					 NULL, NULL, min_dump_alloc);
 		rtnl_lock();
 		return err;
 	}
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index fcf2818..c1ff5dd 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -962,7 +962,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 
 		return netlink_dump_start(sock_diag_nlsk, skb, nlh,
-					  inet_diag_dump_compat, NULL, 0);
+					  inet_diag_dump_compat, NULL, NULL, 0);
 	}
 
 	return inet_diag_get_exact_compat(skb, nlh);
@@ -987,7 +987,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		}
 
 		return netlink_dump_start(sock_diag_nlsk, skb, h,
-					  inet_diag_dump, NULL, 0);
+					  inet_diag_dump, NULL, NULL, 0);
 	}
 
 	return inet_diag_get_exact(skb, h, (struct inet_diag_req_v2 *)NLMSG_DATA(h));
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index aeee9bd..7b63c16 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1164,7 +1164,7 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 
 	return netlink_dump_start(ctnl, skb, nlh,
 				  ip_set_dump_start,
-				  ip_set_dump_done, 0);
+				  ip_set_dump_done, NULL, 0);
 }
 
 /* Add, del and test */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 33a7bb4..404b317 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -979,7 +979,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP)
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
-					  ctnetlink_done, 0);
+					  ctnetlink_done, NULL, 0);
 
 	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
 	if (err < 0)
@@ -1883,7 +1883,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		return netlink_dump_start(ctnl, skb, nlh,
 					  ctnetlink_exp_dump_table,
-					  ctnetlink_exp_done, 0);
+					  ctnetlink_exp_done, NULL, 0);
 	}
 
 	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 11ba013..b7ea475 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -172,7 +172,7 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		return netlink_dump_start(nfnl, skb, nlh, nfnl_acct_dump,
-					  NULL, 0);
+					  NULL, NULL, 0);
 	}
 
 	if (!tb[NFACCT_NAME])
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4d751e3..ff08c89 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1739,6 +1739,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		       int (*dump)(struct sk_buff *skb,
 				   struct netlink_callback *),
 		       int (*done)(struct netlink_callback *),
+		       void *data,
 		       u16 min_dump_alloc)
 {
 	struct netlink_callback *cb;
@@ -1754,6 +1755,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->done = done;
 	cb->nlh = nlh;
 	cb->min_dump_alloc = min_dump_alloc;
+	cb->data = data;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a115471..1a5cbca 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -564,7 +564,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		genl_unlock();
 		err = netlink_dump_start(net->genl_sock, skb, nlh,
-					 ops->dumpit, ops->done, 0);
+					 ops->dumpit, ops->done, NULL, 0);
 		genl_lock();
 		return err;
 	}
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 6b7697f..8ad0962 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -303,7 +303,7 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 
 	if (h->nlmsg_flags & NLM_F_DUMP)
 		return netlink_dump_start(sock_diag_nlsk, skb, h,
-					  unix_diag_dump, NULL, 0);
+					  unix_diag_dump, NULL, NULL, 0);
 	else
 		return unix_diag_get_exact(skb, h, (struct unix_diag_req *)NLMSG_DATA(h));
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 66b84fb..eb86719 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2300,7 +2300,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EINVAL;
 
 		return netlink_dump_start(net->xfrm.nlsk, skb, nlh,
-					  link->dump, link->done, 0);
+					  link->dump, link->done, NULL, 0);
 	}
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
-- 
1.7.7.3

