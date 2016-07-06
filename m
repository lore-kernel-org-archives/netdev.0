From: Masashi Honma <masashi.honma@gmail.com>
Subject: [RFC 1/7] netlink: Add allocation flag to netlink_unicast()
Date: Wed,  6 Jul 2016 09:28:30 +0900
Message-ID: <1467764916-4983-2-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, ccaulfie@redhat.com,
	teigland@redhat.com, bsingharora@gmail.com,
	Masashi Honma <masashi.honma@gmail.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36060 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcGFA3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 20:29:04 -0400
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though netlink_broadcast() has allocation flag which can specify
memory allocation type (ex. GFP_KERNEL/GFP_ATOMIC), netlink_unicast()
does not have it. This can cause "BUG: sleeping function called from
invalid context at" with CONFIG_DEBUG_ATOMIC_SLEEP enabled kernel when
calling netlink_unicast() inside RCU read-side section and not in IRQ.

This patch adds an allocation flag to netlink_unicast().

At this moment, the allocation flag could be zero to imply gfp_any().
This is a temporal functionality for stepwise modification and
removed at the end of the series of patches.

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 drivers/connector/connector.c        |  2 +-
 include/linux/netlink.h              |  3 ++-
 include/net/netlink.h                |  2 +-
 kernel/audit.c                       |  9 +++++----
 net/core/rtnetlink.c                 |  2 +-
 net/ipv4/fib_frontend.c              |  2 +-
 net/ipv4/inet_diag.c                 |  2 +-
 net/ipv4/udp_diag.c                  |  2 +-
 net/netfilter/ipset/ip_set_core.c    | 11 +++++++----
 net/netfilter/nf_conntrack_netlink.c |  9 ++++++---
 net/netfilter/nfnetlink.c            |  2 +-
 net/netfilter/nfnetlink_acct.c       |  2 +-
 net/netfilter/nfnetlink_cthelper.c   |  2 +-
 net/netfilter/nfnetlink_cttimeout.c  |  5 +++--
 net/netfilter/nft_compat.c           |  4 ++--
 net/netlink/af_netlink.c             | 12 +++++++-----
 net/sctp/sctp_diag.c                 |  2 +-
 net/unix/diag.c                      |  2 +-
 samples/connector/cn_test.c          |  2 +-
 19 files changed, 44 insertions(+), 33 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 25693b0..44470e6 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -125,7 +125,7 @@ int cn_netlink_send_mult(struct cn_msg *msg, u16 len, u32 portid, u32 __group,
 		return netlink_broadcast(dev->nls, skb, portid, group,
 					 gfp_mask);
 	return netlink_unicast(dev->nls, skb, portid,
-			!gfpflags_allow_blocking(gfp_mask));
+			       !gfpflags_allow_blocking(gfp_mask), gfp_mask);
 }
 EXPORT_SYMBOL_GPL(cn_netlink_send_mult);
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index da14ab6..f90d24a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -69,7 +69,8 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 
-extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
+extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
+			   int nonblock, gfp_t allocation);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
 extern int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb,
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 254a0fc..898e449 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -590,7 +590,7 @@ static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 portid
 {
 	int err;
 
-	err = netlink_unicast(sk, skb, portid, MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, portid, MSG_DONTWAIT, 0);
 	if (err > 0)
 		err = 0;
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 8d528f9..131577d 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -411,7 +411,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 restart:
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
+	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0, gfp_any());
 	if (err < 0) {
 		pr_err("netlink_unicast sending to audit_pid=%d returned error: %d\n",
 		       audit_pid, err);
@@ -547,7 +547,7 @@ int audit_send_list(void *_dest)
 	mutex_unlock(&audit_cmd_mutex);
 
 	while ((skb = __skb_dequeue(&dest->q)) != NULL)
-		netlink_unicast(aunet->nlsk, skb, dest->portid, 0);
+		netlink_unicast(aunet->nlsk, skb, dest->portid, 0, gfp_any());
 
 	put_net(net);
 	kfree(dest);
@@ -591,7 +591,7 @@ static int audit_send_reply_thread(void *arg)
 
 	/* Ignore failure. It'll only happen if the sender goes away,
 	   because our timeout is set to infinite. */
-	netlink_unicast(aunet->nlsk , reply->skb, reply->portid, 0);
+	netlink_unicast(aunet->nlsk , reply->skb, reply->portid, 0, gfp_any());
 	put_net(net);
 	kfree(reply);
 	return 0;
@@ -814,7 +814,8 @@ static int audit_replace(pid_t pid)
 
 	if (!skb)
 		return -ENOMEM;
-	return netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
+	return netlink_unicast(audit_sock, skb, audit_nlk_portid, 0,
+			       GFP_KERNEL);
 }
 
 static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb49ca2..3433633f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -649,7 +649,7 @@ int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int g
 		atomic_inc(&skb->users);
 	netlink_broadcast(rtnl, skb, pid, group, GFP_KERNEL);
 	if (echo)
-		err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+		err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT, GFP_KERNEL);
 	return err;
 }
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index ef2ebeb..6a4286f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1096,7 +1096,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	portid = NETLINK_CB(skb).portid;      /* netlink portid */
 	NETLINK_CB(skb).portid = 0;        /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
-	netlink_unicast(net->ipv4.fibnl, skb, portid, MSG_DONTWAIT);
+	netlink_unicast(net->ipv4.fibnl, skb, portid, MSG_DONTWAIT, GFP_KERNEL);
 }
 
 static int __net_init nl_fib_lookup_init(struct net *net)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 38c2c47..2963b5f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -441,7 +441,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 		goto out;
 	}
 	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, GFP_KERNEL);
 	if (err > 0)
 		err = 0;
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 3d5ccf4..69ac502 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -83,7 +83,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out;
 	}
 	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, GFP_KERNEL);
 	if (err > 0)
 		err = 0;
 out:
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index a748b0c..fcbe122 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1510,7 +1510,7 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		*errline = lineno;
 
 		netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid,
-				MSG_DONTWAIT);
+				MSG_DONTWAIT, GFP_KERNEL);
 		/* Signal netlink not to send its ACK/errmsg.  */
 		return -EINTR;
 	}
@@ -1695,7 +1695,8 @@ static int ip_set_header(struct net *net, struct sock *ctnl,
 		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (ret < 0)
 		return ret;
 
@@ -1755,7 +1756,8 @@ static int ip_set_type(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 	nlmsg_end(skb2, nlh2);
 
 	pr_debug("Send TYPE, nlmsg_len: %u\n", nlh2->nlmsg_len);
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (ret < 0)
 		return ret;
 
@@ -1798,7 +1800,8 @@ static int ip_set_protocol(struct net *net, struct sock *ctnl,
 		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a18d1ce..6537e8d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1224,7 +1224,8 @@ static int ctnetlink_get_conntrack(struct net *net, struct sock *ctnl,
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (err < 0)
 		goto out;
 
@@ -2083,7 +2084,8 @@ static int ctnetlink_stat_ct(struct net *net, struct sock *ctnl,
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (err < 0)
 		goto out;
 
@@ -2821,7 +2823,8 @@ static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (err < 0)
 		goto out;
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 2278d9a..f6193e7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -143,7 +143,7 @@ EXPORT_SYMBOL_GPL(nfnetlink_set_err);
 int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 		      int flags)
 {
-	return netlink_unicast(net->nfnl, skb, portid, flags);
+	return netlink_unicast(net->nfnl, skb, portid, flags, 0);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 1b4de4b..8b5bd59 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -311,7 +311,7 @@ static int nfnl_acct_get(struct net *net, struct sock *nfnl,
 			break;
 		}
 		ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
-					MSG_DONTWAIT);
+				      MSG_DONTWAIT, GFP_KERNEL);
 		if (ret > 0)
 			ret = 0;
 
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index e924e95..e46b7cd 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -559,7 +559,7 @@ static int nfnl_cthelper_get(struct net *net, struct sock *nfnl,
 			}
 
 			ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
-						MSG_DONTWAIT);
+					      MSG_DONTWAIT, GFP_KERNEL);
 			if (ret > 0)
 				ret = 0;
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 3c84f14..813eb8a 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -279,7 +279,7 @@ static int cttimeout_get_timeout(struct net *net, struct sock *ctnl,
 			break;
 		}
 		ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid,
-					MSG_DONTWAIT);
+				      MSG_DONTWAIT, GFP_KERNEL);
 		if (ret > 0)
 			ret = 0;
 
@@ -496,7 +496,8 @@ static int cttimeout_default_get(struct net *net, struct sock *ctnl,
 		err = -ENOMEM;
 		goto err;
 	}
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid,
+			      MSG_DONTWAIT, GFP_KERNEL);
 	if (ret > 0)
 		ret = 0;
 
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 6228c42..7de9ea4 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -582,8 +582,8 @@ static int nfnl_compat_get(struct net *net, struct sock *nfnl,
 		return -ENOSPC;
 	}
 
-	ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
-				MSG_DONTWAIT);
+	ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT,
+			      GFP_KERNEL);
 	if (ret > 0)
 		ret = 0;
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 627f898..c68bf74 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1220,14 +1220,14 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 	return ret;
 }
 
-int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
-		    u32 portid, int nonblock)
+int netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 portid,
+		    int nonblock, gfp_t allocation)
 {
 	struct sock *sk;
 	int err;
 	long timeo;
 
-	skb = netlink_trim(skb, gfp_any());
+	skb = netlink_trim(skb, allocation ? allocation : gfp_any());
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
@@ -1783,7 +1783,8 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		atomic_inc(&skb->users);
 		netlink_broadcast(sk, skb, dst_portid, dst_group, GFP_KERNEL);
 	}
-	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, dst_portid,
+			      msg->msg_flags & MSG_DONTWAIT, GFP_KERNEL);
 
 out:
 	scm_destroy(&scm);
@@ -2250,7 +2251,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
-	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
+	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid,
+			MSG_DONTWAIT, GFP_KERNEL);
 }
 EXPORT_SYMBOL(netlink_ack);
 
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index f69edcf..4e66405 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -259,7 +259,7 @@ static int sctp_tsp_dump_one(struct sctp_transport *tsp, void *p)
 	}
 
 	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, GFP_KERNEL);
 	if (err > 0)
 		err = 0;
 out:
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 4d96797..5e7e952 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -280,7 +280,7 @@ again:
 		goto again;
 	}
 	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, GFP_KERNEL);
 	if (err > 0)
 		err = 0;
 out:
diff --git a/samples/connector/cn_test.c b/samples/connector/cn_test.c
index d12cc94..640d11b 100644
--- a/samples/connector/cn_test.c
+++ b/samples/connector/cn_test.c
@@ -116,7 +116,7 @@ static int cn_test_want_notify(void)
 
 	NETLINK_CB(skb).dst_group = ctl->group;
 	//netlink_broadcast(nls, skb, 0, ctl->group, GFP_ATOMIC);
-	netlink_unicast(nls, skb, 0, 0);
+	netlink_unicast(nls, skb, 0, 0, GFP_ATOMIC);
 
 	pr_info("request was sent: group=0x%x\n", ctl->group);
 
-- 
2.7.4
