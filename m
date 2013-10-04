From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/33] netfilter: cttimeout: allow to set/get default protocol timeouts
Date: Fri,  4 Oct 2013 10:33:18 +0200
Message-ID: <1380875598-5250-34-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default timeouts are currently set via proc/sysctl interface, the
typical pattern is a file name like:

/proc/sys/net/netfilter/nf_conntrack_PROTOCOL_timeout_STATE

This results in one entry per default protocol state timeout.
This patch simplifies this by allowing to set default protocol
timeouts via cttimeout netlink interface.

This should allow us to get rid of the existing proc/sysctl code
in the midterm.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_cttimeout.h |    2 +
 net/netfilter/nfnetlink_cttimeout.c                |  161 +++++++++++++++++++-
 2 files changed, 155 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_cttimeout.h b/include/uapi/linux/netfilter/nfnetlink_cttimeout.h
index a2810a7..1ab0b97 100644
--- a/include/uapi/linux/netfilter/nfnetlink_cttimeout.h
+++ b/include/uapi/linux/netfilter/nfnetlink_cttimeout.h
@@ -6,6 +6,8 @@ enum ctnl_timeout_msg_types {
 	IPCTNL_MSG_TIMEOUT_NEW,
 	IPCTNL_MSG_TIMEOUT_GET,
 	IPCTNL_MSG_TIMEOUT_DELETE,
+	IPCTNL_MSG_TIMEOUT_DEFAULT_SET,
+	IPCTNL_MSG_TIMEOUT_DEFAULT_GET,
 
 	IPCTNL_MSG_TIMEOUT_MAX
 };
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 5058049..476accd 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -49,10 +49,8 @@ static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
 };
 
 static int
-ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
-			  struct nf_conntrack_l4proto *l4proto,
-			  struct net *net,
-			  const struct nlattr *attr)
+ctnl_timeout_parse_policy(void *timeouts, struct nf_conntrack_l4proto *l4proto,
+			  struct net *net, const struct nlattr *attr)
 {
 	int ret = 0;
 
@@ -64,8 +62,7 @@ ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
 		if (ret < 0)
 			return ret;
 
-		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, net,
-							  &timeout->data);
+		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, net, timeouts);
 	}
 	return ret;
 }
@@ -123,7 +120,8 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 				goto err_proto_put;
 			}
 
-			ret = ctnl_timeout_parse_policy(matching, l4proto, net,
+			ret = ctnl_timeout_parse_policy(&matching->data,
+							l4proto, net,
 							cda[CTA_TIMEOUT_DATA]);
 			return ret;
 		}
@@ -138,7 +136,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 		goto err_proto_put;
 	}
 
-	ret = ctnl_timeout_parse_policy(timeout, l4proto, net,
+	ret = ctnl_timeout_parse_policy(&timeout->data, l4proto, net,
 					cda[CTA_TIMEOUT_DATA]);
 	if (ret < 0)
 		goto err;
@@ -342,6 +340,147 @@ cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
 	return ret;
 }
 
+static int
+cttimeout_default_set(struct sock *ctnl, struct sk_buff *skb,
+		      const struct nlmsghdr *nlh,
+		      const struct nlattr * const cda[])
+{
+	__u16 l3num;
+	__u8 l4num;
+	struct nf_conntrack_l4proto *l4proto;
+	struct net *net = sock_net(skb->sk);
+	unsigned int *timeouts;
+	int ret;
+
+	if (!cda[CTA_TIMEOUT_L3PROTO] ||
+	    !cda[CTA_TIMEOUT_L4PROTO] ||
+	    !cda[CTA_TIMEOUT_DATA])
+		return -EINVAL;
+
+	l3num = ntohs(nla_get_be16(cda[CTA_TIMEOUT_L3PROTO]));
+	l4num = nla_get_u8(cda[CTA_TIMEOUT_L4PROTO]);
+	l4proto = nf_ct_l4proto_find_get(l3num, l4num);
+
+	/* This protocol is not supported, skip. */
+	if (l4proto->l4proto != l4num) {
+		ret = -EOPNOTSUPP;
+		goto err;
+	}
+
+	timeouts = l4proto->get_timeouts(net);
+
+	ret = ctnl_timeout_parse_policy(timeouts, l4proto, net,
+					cda[CTA_TIMEOUT_DATA]);
+	if (ret < 0)
+		goto err;
+
+	nf_ct_l4proto_put(l4proto);
+	return 0;
+err:
+	nf_ct_l4proto_put(l4proto);
+	return ret;
+}
+
+static int
+cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
+			    u32 seq, u32 type, int event,
+			    struct nf_conntrack_l4proto *l4proto)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
+
+	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version = NFNETLINK_V0;
+	nfmsg->res_id = 0;
+
+	if (nla_put_be16(skb, CTA_TIMEOUT_L3PROTO, htons(l4proto->l3proto)) ||
+	    nla_put_u8(skb, CTA_TIMEOUT_L4PROTO, l4proto->l4proto))
+		goto nla_put_failure;
+
+	if (likely(l4proto->ctnl_timeout.obj_to_nlattr)) {
+		struct nlattr *nest_parms;
+		unsigned int *timeouts = l4proto->get_timeouts(net);
+		int ret;
+
+		nest_parms = nla_nest_start(skb,
+					    CTA_TIMEOUT_DATA | NLA_F_NESTED);
+		if (!nest_parms)
+			goto nla_put_failure;
+
+		ret = l4proto->ctnl_timeout.obj_to_nlattr(skb, timeouts);
+		if (ret < 0)
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest_parms);
+	}
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nlmsg_failure:
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int cttimeout_default_get(struct sock *ctnl, struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
+{
+	__u16 l3num;
+	__u8 l4num;
+	struct nf_conntrack_l4proto *l4proto;
+	struct net *net = sock_net(skb->sk);
+	struct sk_buff *skb2;
+	int ret, err;
+
+	if (!cda[CTA_TIMEOUT_L3PROTO] || !cda[CTA_TIMEOUT_L4PROTO])
+		return -EINVAL;
+
+	l3num = ntohs(nla_get_be16(cda[CTA_TIMEOUT_L3PROTO]));
+	l4num = nla_get_u8(cda[CTA_TIMEOUT_L4PROTO]);
+	l4proto = nf_ct_l4proto_find_get(l3num, l4num);
+
+	/* This protocol is not supported, skip. */
+	if (l4proto->l4proto != l4num) {
+		err = -EOPNOTSUPP;
+		goto err;
+	}
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	ret = cttimeout_default_fill_info(net, skb2, NETLINK_CB(skb).portid,
+					  nlh->nlmsg_seq,
+					  NFNL_MSG_TYPE(nlh->nlmsg_type),
+					  IPCTNL_MSG_TIMEOUT_DEFAULT_SET,
+					  l4proto);
+	if (ret <= 0) {
+		kfree_skb(skb2);
+		err = -ENOMEM;
+		goto err;
+	}
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
+	if (ret > 0)
+		ret = 0;
+
+	/* this avoids a loop in nfnetlink. */
+	return ret == -EAGAIN ? -ENOBUFS : ret;
+err:
+	nf_ct_l4proto_put(l4proto);
+	return err;
+}
+
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 static struct ctnl_timeout *ctnl_timeout_find_get(const char *name)
 {
@@ -384,6 +523,12 @@ static const struct nfnl_callback cttimeout_cb[IPCTNL_MSG_TIMEOUT_MAX] = {
 	[IPCTNL_MSG_TIMEOUT_DELETE]	= { .call = cttimeout_del_timeout,
 					    .attr_count = CTA_TIMEOUT_MAX,
 					    .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DEFAULT_SET]= { .call = cttimeout_default_set,
+					    .attr_count = CTA_TIMEOUT_MAX,
+					    .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DEFAULT_GET]= { .call = cttimeout_default_get,
+					    .attr_count = CTA_TIMEOUT_MAX,
+					    .policy = cttimeout_nla_policy },
 };
 
 static const struct nfnetlink_subsystem cttimeout_subsys = {
-- 
1.7.10.4

