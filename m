From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v1, kernel version 3.2.1] rtnetlink workaround around the
 skb buff size issue
Date: Fri, 3 Feb 2012 15:24:21 +0100 (CET)
Message-ID: <10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

Adding new rtnetlink ops and command for getting more information about
network devices, which are not able to fit inside predefined SKB structures
(e.g. PAGE_SIZE limit). DEVDUMP command allows to call specific device driver
code for complete handling this netlink message. Useful if devices needed to
list some addition dynamic structures like hlists and doesn't require to have
complete set of codes for it new PF families.

Signed-off-by: Stefan Gula <steweg@gmail.com>

---
 - this patch is per-requisition for my new macvlan patch


diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/include/linux/rtnetlink.h linux-3.2.1-macvlan/include/linux/rtnetlink.h
--- linux-3.2.1-orig/include/linux/rtnetlink.h	2012-01-27 13:38:57.000000000 +0000
+++ linux-3.2.1-macvlan/include/linux/rtnetlink.h	2012-02-02 08:34:14.000000000 +0000
@@ -120,6 +120,8 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_DEVDUMP = 80,
+#define RTM_DEVDUMP	RTM_DEVDUMP
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/include/net/rtnetlink.h linux-3.2.1-macvlan/include/net/rtnetlink.h
--- linux-3.2.1-orig/include/net/rtnetlink.h	2012-01-27 13:38:57.000000000 +0000
+++ linux-3.2.1-macvlan/include/net/rtnetlink.h	2012-02-02 05:58:50.000000000 +0000
@@ -78,6 +78,9 @@ struct rtnl_link_ops {
 	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
 						 unsigned int *tx_queues,
 						 unsigned int *real_tx_queues);
+	int			(*dev_dump)(struct sk_buff *skb,
+					    struct net_device *dev, int type,
+					    u32 pid, u32 seq);
 };
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/net/core/rtnetlink.c linux-3.2.1-macvlan/net/core/rtnetlink.c
--- linux-3.2.1-orig/net/core/rtnetlink.c	2012-01-27 14:22:12.000000000 +0000
+++ linux-3.2.1-macvlan/net/core/rtnetlink.c	2012-02-02 23:59:54.000000000 +0000
@@ -1874,6 +1874,42 @@ static int rtnl_getlink(struct sk_buff *
 	return err;
 }
 
+static int rtnl_devdump(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ifinfomsg *ifm;
+	char ifname[IFNAMSIZ];
+	struct nlattr *tb[IFLA_MAX+1];
+	struct net_device *dev = NULL;
+	int err;
+	const struct rtnl_link_ops *ops;
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = __dev_get_by_index(net, ifm->ifi_index);
+	else if (tb[IFLA_IFNAME])
+		dev = __dev_get_by_name(net, ifname);
+	else
+		return -EINVAL;
+
+	if (dev == NULL)
+		return -ENODEV;
+
+	ops = dev->rtnl_link_ops;
+	if (ops && ops->dev_dump)
+		return ops->dev_dump(skb, dev, RTM_DEVDUMP,
+				     NETLINK_CB(skb).pid, nlh->nlmsg_seq);
+
+	return -EOPNOTSUPP;
+}
+
 static u16 rtnl_calcit(struct sk_buff *skb)
 {
 	return min_ifinfo_dump_size;
@@ -2097,5 +2133,7 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
+
+	rtnl_register(PF_UNSPEC, RTM_DEVDUMP, rtnl_devdump, NULL, NULL);
 }
 
