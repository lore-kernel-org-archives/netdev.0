From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 7/8] net: Use netlink_ns_capable to verify the permisions of netlink messages
Date: Fri, 25 Jul 2014 16:22:28 +0800
Message-ID: <1406276549-6616-8-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30241 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759879AbaGYIZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:25:08 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

It is possible by passing a netlink socket to a more privileged
executable and then to fool that executable into writing to the socket
data that happens to be valid netlink message to do something that
privileged executable did not intend to do.

To keep this from happening replace bare capable and ns_capable calls
with netlink_capable, netlink_net_calls and netlink_ns_capable calls.
Which act the same as the previous calls except they verify that the
opener of the socket had the desired permissions as well.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 crypto/crypto_user.c            | 2 +-
 drivers/connector/cn_proc.c     | 2 +-
 drivers/scsi/scsi_netlink.c     | 2 +-
 kernel/audit.c                  | 4 ++--
 net/core/rtnetlink.c            | 2 +-
 net/decnet/dn_dev.c             | 2 +-
 net/decnet/netfilter/dn_rtmsg.c | 2 +-
 net/netfilter/nfnetlink.c       | 2 +-
 net/netlink/genetlink.c         | 2 +-
 net/phonet/pn_netlink.c         | 4 ++--
 net/tipc/netlink.c              | 2 +-
 net/xfrm/xfrm_user.c            | 2 +-
 12 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 910497b..c86969e 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -452,7 +452,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	type -= CRYPTO_MSG_BASE;
 	link = &crypto_dispatch[type];
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if ((type == (CRYPTO_MSG_GETALG - CRYPTO_MSG_BASE) &&
diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 094a710..46856ae 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -332,7 +332,7 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 		return;
 
 	/* Can only change if privileged. */
-	if (!capable(CAP_NET_ADMIN)) {
+	if (!__netlink_ns_capable(nsp, &init_user_ns, CAP_NET_ADMIN)) {
 		err = EPERM;
 		goto out;
 	}
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index c77628a..a930b66 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -112,7 +112,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 			goto next_msg;
 		}
 
-		if (!capable(CAP_SYS_ADMIN)) {
+		if (!netlink_capable(skb, CAP_SYS_ADMIN)) {
 			err = -EPERM;
 			goto next_msg;
 		}
diff --git a/kernel/audit.c b/kernel/audit.c
index b4efae8..3c3a31c 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -601,13 +601,13 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 	case AUDIT_TTY_SET:
 	case AUDIT_TRIM:
 	case AUDIT_MAKE_EQUIV:
-		if (!capable(CAP_AUDIT_CONTROL))
+		if (!netlink_capable(skb, CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
-		if (!capable(CAP_AUDIT_WRITE))
+		if (!netlink_capable(skb, CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a133427..d3ac150 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2010,7 +2010,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && !capable(CAP_NET_ADMIN))
+	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index c00e307..b79ce1e 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -440,7 +440,7 @@ int dn_dev_ioctl(unsigned int cmd, void __user *arg)
 	case SIOCGIFADDR:
 		break;
 	case SIOCSIFADDR:
-		if (!capable(CAP_NET_ADMIN))
+		if (!netlink_capable(skb, CAP_NET_ADMIN))
 			return -EACCES;
 		if (sdn->sdn_family != AF_DECnet)
 			return -EINVAL;
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 1531135..dc750e2 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -108,7 +108,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 		return;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!netlink_capable(skb, CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
 	/* Eventually we might send routing messages too */
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index e6ddde1..5cfc865 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -129,7 +129,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 73d3f0c..dff8562 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -556,7 +556,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EOPNOTSUPP;
 
 	if ((ops->flags & GENL_ADMIN_PERM) &&
-	    !capable(CAP_NET_ADMIN))
+	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index d61f676..18485cd 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -70,7 +70,7 @@ static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
 	int err;
 	u8 pnaddr;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!netlink_capable(skb, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	ASSERT_RTNL();
@@ -228,7 +228,7 @@ static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
 	int err;
 	u8 dst;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!netlink_capable(skb, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	ASSERT_RTNL();
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 7bda8e3..0b4cf4f 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -47,7 +47,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	int hdr_space = NLMSG_SPACE(GENL_HDRLEN + TIPC_GENL_HDRLEN);
 	u16 cmd;
 
-	if ((req_userhdr->cmd & 0xC000) && (!capable(CAP_NET_ADMIN)))
+	if ((req_userhdr->cmd & 0xC000) && (!netlink_capable(skb, CAP_NET_ADMIN)))
 		cmd = TIPC_CMD_NOT_NET_ADMIN;
 	else
 		cmd = req_userhdr->cmd;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c8b903d..ce16eba 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2317,7 +2317,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (!capable(CAP_NET_ADMIN))
+	if (!netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
-- 
1.8.0
