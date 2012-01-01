From: pablo@netfilter.org
Subject: [PATCH] netfilter: nfnetlink_acct: fix nfnl_acct_get operation
Date: Sun,  1 Jan 2012 17:22:25 +0100
Message-ID: <1325434945-21900-2-git-send-email-pablo@netfilter.org>
References: <1325434945-21900-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325434945-21900-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

The get operation was not sending the message that was built to
user-space. This patch also includes the appropriate handling for
the return value of netlink_unicast().

Moreover, fix error codes on error (for example, for non-existing
entry was uncorrect).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 362ab6c..11ba013 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -166,7 +166,7 @@ static int
 nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
 {
-	int ret = 0;
+	int ret = -ENOENT;
 	struct nf_acct *cur;
 	char *acct_name;
 
@@ -186,17 +186,26 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 			continue;
 
 		skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-		if (skb2 == NULL)
+		if (skb2 == NULL) {
+			ret = -ENOMEM;
 			break;
+		}
 
 		ret = nfnl_acct_fill_info(skb2, NETLINK_CB(skb).pid,
 					 nlh->nlmsg_seq,
 					 NFNL_MSG_TYPE(nlh->nlmsg_type),
 					 NFNL_MSG_ACCT_NEW, cur);
-		if (ret <= 0)
+		if (ret <= 0) {
 			kfree_skb(skb2);
+			break;
+		}
+		ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).pid,
+					MSG_DONTWAIT);
+		if (ret > 0)
+			ret = 0;
 
-		break;
+		/* this avoids a loop in nfnetlink. */
+		return ret == -EAGAIN ? -ENOBUFS : ret;
 	}
 	return ret;
 }
-- 
1.7.7.3

