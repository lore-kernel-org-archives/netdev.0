From: pablo@netfilter.org
Subject: [PATCH 1/3] netlink: add netlink_dump_control structure for netlink_dump_start()
Date: Sat, 25 Feb 2012 01:30:15 +0100
Message-ID: <1330129817-28199-2-git-send-email-pablo@netfilter.org>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Davem considers that the argument list of this interface is getting
out of control. This patch tries to address this issue following
his proposal:

struct netlink_dump_control c = { .dump = dump, .done = done, ... };

netlink_dump_start(..., &c);

Suggested by David S. Miller.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 crypto/crypto_user.c                 |   10 +++++++---
 drivers/infiniband/core/netlink.c    |   10 +++++++---
 include/linux/netlink.h              |   10 +++++++---
 net/core/rtnetlink.c                 |    9 +++++++--
 net/ipv4/inet_diag.c                 |   18 ++++++++++++------
 net/netfilter/ipset/ip_set_core.c    |   10 +++++++---
 net/netfilter/nf_conntrack_netlink.c |   18 ++++++++++++------
 net/netfilter/nfnetlink_acct.c       |    6 ++++--
 net/netlink/af_netlink.c             |   11 ++++-------
 net/netlink/genetlink.c              |    9 +++++++--
 net/unix/diag.c                      |   10 ++++++----
 net/xfrm/xfrm_user.c                 |    9 +++++++--
 12 files changed, 87 insertions(+), 43 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 16f8693..b6ac138 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -389,9 +389,13 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    (nlh->nlmsg_flags & NLM_F_DUMP))) {
 		if (link->dump == NULL)
 			return -EINVAL;
-
-		return netlink_dump_start(crypto_nlsk, skb, nlh,
-					  link->dump, link->done, 0);
+		{
+			struct netlink_dump_control c = {
+				.dump = link->dump,
+				.done = link->done,
+			};
+			return netlink_dump_start(crypto_nlsk, skb, nlh, &c);
+		}
 	}
 
 	err = nlmsg_parse(nlh, crypto_msg_min[type], attrs, CRYPTOCFGA_MAX,
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index d1c8196..396e293 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -147,9 +147,13 @@ static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			if (op < 0 || op >= client->nops ||
 			    !client->cb_table[RDMA_NL_GET_OP(op)].dump)
 				return -EINVAL;
-			return netlink_dump_start(nls, skb, nlh,
-						  client->cb_table[op].dump,
-						  NULL, 0);
+
+			{
+				struct netlink_dump_control c = {
+					.dump = client->cb_table[op].dump,
+				};
+				return netlink_dump_start(nls, skb, nlh, &c);
+			}
 		}
 	}
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a390e9d..1f8c1a9 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -248,11 +248,15 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 #define NLMSG_PUT(skb, pid, seq, type, len) \
 	NLMSG_NEW(skb, pid, seq, type, len, 0)
 
+struct netlink_dump_control {
+	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
+	int (*done)(struct netlink_callback*);
+	u16 min_dump_alloc;
+};
+
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
-			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
-			      int (*done)(struct netlink_callback*),
-			      u16 min_dump_alloc);
+			      struct netlink_dump_control *control);
 
 
 #define NL_NONROOT_RECV 0x1
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 65aebd4..7aef62e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1981,8 +1981,13 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		__rtnl_unlock();
 		rtnl = net->rtnl;
-		err = netlink_dump_start(rtnl, skb, nlh, dumpit,
-					 NULL, min_dump_alloc);
+		{
+			struct netlink_dump_control c = {
+				.dump		= dumpit,
+				.min_dump_alloc	= min_dump_alloc,
+			};
+			err = netlink_dump_start(rtnl, skb, nlh, &c);
+		}
 		rtnl_lock();
 		return err;
 	}
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index fcf2818..8d25a1c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -960,9 +960,12 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
 				return -EINVAL;
 		}
-
-		return netlink_dump_start(sock_diag_nlsk, skb, nlh,
-					  inet_diag_dump_compat, NULL, 0);
+		{
+			struct netlink_dump_control c = {
+				.dump = inet_diag_dump_compat,
+			};
+			return netlink_dump_start(sock_diag_nlsk, skb, nlh, &c);
+		}
 	}
 
 	return inet_diag_get_exact_compat(skb, nlh);
@@ -985,9 +988,12 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
 				return -EINVAL;
 		}
-
-		return netlink_dump_start(sock_diag_nlsk, skb, h,
-					  inet_diag_dump, NULL, 0);
+		{
+			struct netlink_dump_control c = {
+				.dump = inet_diag_dump,
+			};
+			return netlink_dump_start(sock_diag_nlsk, skb, h, &c);
+		}
 	}
 
 	return inet_diag_get_exact(skb, h, (struct inet_diag_req_v2 *)NLMSG_DATA(h));
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index aeee9bd..e6c1c96 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1162,9 +1162,13 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
-	return netlink_dump_start(ctnl, skb, nlh,
-				  ip_set_dump_start,
-				  ip_set_dump_done, 0);
+	{
+		struct netlink_dump_control c = {
+			.dump = ip_set_dump_start,
+			.done = ip_set_dump_done,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
 }
 
 /* Add, del and test */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 33a7bb4..dd4aaba 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -977,9 +977,13 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	u16 zone;
 	int err;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP)
-		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
-					  ctnetlink_done, 0);
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_dump_table,
+			.done = ctnetlink_done,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
 
 	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
 	if (err < 0)
@@ -1881,9 +1885,11 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		return netlink_dump_start(ctnl, skb, nlh,
-					  ctnetlink_exp_dump_table,
-					  ctnetlink_exp_done, 0);
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_exp_dump_table,
+			.done = ctnetlink_exp_done,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
 
 	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 11ba013..3eb348b 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -171,8 +171,10 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 	char *acct_name;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		return netlink_dump_start(nfnl, skb, nlh, nfnl_acct_dump,
-					  NULL, 0);
+		struct netlink_dump_control c = {
+			.dump = nfnl_acct_dump,
+		};
+		return netlink_dump_start(nfnl, skb, nlh, &c);
 	}
 
 	if (!tb[NFACCT_NAME])
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4d751e3..ab74845 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1736,10 +1736,7 @@ errout_skb:
 
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       int (*dump)(struct sk_buff *skb,
-				   struct netlink_callback *),
-		       int (*done)(struct netlink_callback *),
-		       u16 min_dump_alloc)
+		       struct netlink_dump_control *control)
 {
 	struct netlink_callback *cb;
 	struct sock *sk;
@@ -1750,10 +1747,10 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	if (cb == NULL)
 		return -ENOBUFS;
 
-	cb->dump = dump;
-	cb->done = done;
+	cb->dump = control->dump;
+	cb->done = control->done;
 	cb->nlh = nlh;
-	cb->min_dump_alloc = min_dump_alloc;
+	cb->min_dump_alloc = control->min_dump_alloc;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a115471..9f40441 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -563,8 +563,13 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EOPNOTSUPP;
 
 		genl_unlock();
-		err = netlink_dump_start(net->genl_sock, skb, nlh,
-					 ops->dumpit, ops->done, 0);
+		{
+			struct netlink_dump_control c = {
+				.dump = ops->dumpit,
+				.done = ops->done,
+			};
+			err = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		}
 		genl_lock();
 		return err;
 	}
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 6b7697f..4195555 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -301,10 +301,12 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
 
-	if (h->nlmsg_flags & NLM_F_DUMP)
-		return netlink_dump_start(sock_diag_nlsk, skb, h,
-					  unix_diag_dump, NULL, 0);
-	else
+	if (h->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = unix_diag_dump,
+		};
+		return netlink_dump_start(sock_diag_nlsk, skb, h, &c);
+	} else
 		return unix_diag_get_exact(skb, h, (struct unix_diag_req *)NLMSG_DATA(h));
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 66b84fb..7128dde 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2299,8 +2299,13 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (link->dump == NULL)
 			return -EINVAL;
 
-		return netlink_dump_start(net->xfrm.nlsk, skb, nlh,
-					  link->dump, link->done, 0);
+		{
+			struct netlink_dump_control c = {
+				.dump = link->dump,
+				.done = link->done,
+			};
+			return netlink_dump_start(net->xfrm.nlsk, skb, nlh, &c);
+		}
 	}
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
-- 
1.7.7.3

