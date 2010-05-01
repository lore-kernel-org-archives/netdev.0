From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 095/100] c/r: Add rtnl_dellink() helper
Date: Sat,  1 May 2010 10:16:17 -0400
Message-ID: <1272723382-19470-96-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64437 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947Ab0EAOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:53 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

This is the kernel equivalent of "ip link del $name" and matches the
existing rtnl_newlink() equivalent of "ip link add $name".  It factors
out the message creation and dispatch code a little further into
rtnl_do() before adding the new function.

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 net/checkpoint_dev.c |   86 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 72 insertions(+), 14 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 34a6bdb..5097011 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -475,22 +475,49 @@ static struct sk_buff *new_link_msg(new_link_fn fn, void *data, char *name)
 	return skb;
 }
 
-static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
+static struct sk_buff *del_link_msg(char *name)
+{
+	int ret = -ENOMEM;
+	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	struct ifinfomsg *ifm;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_DELLINK, sizeof(*ifm), flags);
+	if (!nlh)
+		goto out;
+
+	ifm = nlmsg_data(nlh);
+	memset(ifm, 0, sizeof(*ifm));
+
+	ret = nla_put_string(skb, IFLA_IFNAME, name);
+	if (ret)
+		goto out;
+
+	nlmsg_end(skb, nlh);
+
+ out:
+	if (ret < 0) {
+		kfree_skb(skb);
+		skb = ERR_PTR(ret);
+	}
+
+	return skb;
+}
+
+static int rtnl_do(struct sk_buff *skb)
 {
 	int ret = -ENOMEM;
 	struct socket *rtnl = NULL;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *rskb = NULL;
 	struct nlmsghdr *nlh;
 	struct msghdr msg;
 	struct kvec kvec;
 
-	skb = new_link_msg(fn, data, name);
-	if (IS_ERR(skb)) {
-		ckpt_debug("failed to create new link message: %li\n",
-			   PTR_ERR(skb));
-		return ERR_PTR(PTR_ERR(skb));
-	}
-
 	memset(&msg, 0, sizeof(msg));
 	kvec.iov_len = skb->len;
 	kvec.iov_base = skb->head;
@@ -510,25 +537,56 @@ static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
 		goto out;
 	}
 
-	/* Free the send skb to make room for the receive skb */
-	kfree_skb(skb);
-
-	nlh = rtnl_get_response(rtnl, &skb);
+	nlh = rtnl_get_response(rtnl, &rskb);
 	if (IS_ERR(nlh)) {
 		ret = PTR_ERR(nlh);
 		ckpt_debug("RTNETLINK said: %i\n", ret);
 	}
  out:
 	rtnl_close(rtnl);
+	kfree_skb(rskb);
  out_noclose:
-	kfree_skb(skb);
+	return ret;
+}
 
+static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
+{
+	struct sk_buff *skb;
+	int ret;
+
+	skb = new_link_msg(fn, data, name);
+	if (IS_ERR(skb)) {
+		ckpt_debug("failed to create new link message: %li\n",
+			   PTR_ERR(skb));
+		return ERR_PTR(PTR_ERR(skb));
+	}
+
+	ret = rtnl_do(skb);
+	kfree_skb(skb);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	else
 		return dev_get_by_name(current->nsproxy->net_ns, name);
 }
 
+static int rtnl_dellink(char *name)
+{
+	struct sk_buff *skb;
+	int ret;
+
+	skb = del_link_msg(name);
+	if (IS_ERR(skb)) {
+		ckpt_debug("failed to create del link message: %li\n",
+			   PTR_ERR(skb));
+		return PTR_ERR(skb);
+	}
+
+	ret = rtnl_do(skb);
+	kfree_skb(skb);
+
+	return ret;
+}
+
 static int netdev_noop(void *data)
 {
 	return 0;
-- 
1.6.3.3

