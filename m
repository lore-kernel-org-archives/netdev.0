From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] C/R: Make rtnl_open() and rtnl_do() take and pass a netns
	pointer
Date: Fri, 23 Apr 2010 07:55:38 -0700
Message-ID: <1272034539-19899-4-git-send-email-danms@us.ibm.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272034539-19899-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

(also make rtnl_do() return negative or 0, not the message length)

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 2787892..df8b16a 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -107,12 +107,13 @@ static int __kern_dev_ioctl(struct net *net, unsigned int cmd, void *arg)
 	return ret;
 }
 
-static struct socket *rtnl_open(void)
+static struct socket *rtnl_open(struct net *net)
 {
 	struct socket *sock;
 	int ret;
 
-	ret = sock_create(AF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE, &sock);
+	ret = sock_create_kern_net(AF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE,
+				   net, &sock);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
@@ -538,7 +539,7 @@ static struct sk_buff *del_link_msg(char *name)
 	return skb;
 }
 
-static int rtnl_do(struct sk_buff *skb)
+static int rtnl_do(struct net *net, struct sk_buff *skb)
 {
 	int ret = -ENOMEM;
 	struct socket *rtnl = NULL;
@@ -551,7 +552,7 @@ static int rtnl_do(struct sk_buff *skb)
 	kvec.iov_len = skb->len;
 	kvec.iov_base = skb->head;
 
-	rtnl = rtnl_open();
+	rtnl = rtnl_open(net);
 	if (IS_ERR(rtnl)) {
 		ret = PTR_ERR(rtnl);
 		ckpt_debug("Unable to open rtnetlink socket: %i\n", ret);
@@ -570,7 +571,8 @@ static int rtnl_do(struct sk_buff *skb)
 	if (IS_ERR(nlh)) {
 		ret = PTR_ERR(nlh);
 		ckpt_debug("RTNETLINK said: %i\n", ret);
-	}
+	} else
+		ret = 0;
  out:
 	rtnl_close(rtnl);
 	kfree_skb(rskb);
@@ -590,7 +592,7 @@ static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
 		return ERR_PTR(PTR_ERR(skb));
 	}
 
-	ret = rtnl_do(skb);
+	ret = rtnl_do(current->nsproxy->net_ns, skb);
 	kfree_skb(skb);
 	if (ret < 0)
 		return ERR_PTR(ret);
@@ -610,7 +612,7 @@ static int rtnl_dellink(char *name)
 		return PTR_ERR(skb);
 	}
 
-	ret = rtnl_do(skb);
+	ret = rtnl_do(current->nsproxy->net_ns, skb);
 	kfree_skb(skb);
 
 	return ret;
-- 
1.6.2.5
