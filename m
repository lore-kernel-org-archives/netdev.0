From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [PATCH v4] netlink: add NETLINK_CAP_ACK socket option
Date: Fri, 28 Aug 2015 07:07:48 +0200
Message-ID: <1440738468-2374-2-git-send-email-christophe-h.ricard@st.com>
References: <1440738468-2374-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org, christophe-h.ricard@st.com,
	christophe.ricard@gmail.com
To: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36489 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbH1FHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:07:55 -0400
Received: by wicgk12 with SMTP id gk12so9888661wic.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:07:55 -0700 (PDT)
In-Reply-To: <1440738468-2374-1-git-send-email-christophe-h.ricard@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c05cdb1b864f ("netlink: allow large data transfers from
user-space"), the kernel may fail to allocate the necessary room for the
acknowledgment message back to userspace. This patch introduces a new
socket option that trims off the payload of the original netlink message.

The netlink message header is still included, so the user can guess from
the sequence number what is the message that has triggered the
acknowledgment.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Christophe Ricard <christophe-h.ricard@st.com>
---
 include/uapi/linux/netlink.h |  1 +
 net/netlink/af_netlink.c     | 27 ++++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index cf6a65c..6f3fe16 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -110,6 +110,7 @@ struct nlmsgerr {
 #define NETLINK_TX_RING			7
 #define NETLINK_LISTEN_ALL_NSID		8
 #define NETLINK_LIST_MEMBERSHIPS	9
+#define NETLINK_CAP_ACK			10
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 67d2104..131d1a4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -84,6 +84,7 @@ struct listeners {
 #define NETLINK_F_BROADCAST_SEND_ERROR	0x4
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
 #define NETLINK_F_LISTEN_ALL_NSID	0x10
+#define NETLINK_F_CAP_ACK		0x20
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
@@ -2258,6 +2259,13 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			nlk->flags &= ~NETLINK_F_LISTEN_ALL_NSID;
 		err = 0;
 		break;
+	case NETLINK_CAP_ACK:
+		if (val)
+			nlk->flags |= NETLINK_F_CAP_ACK;
+		else
+			nlk->flags &= ~NETLINK_F_CAP_ACK;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2332,6 +2340,16 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		netlink_table_ungrab();
 		break;
 	}
+	case NETLINK_CAP_ACK:
+		if (len < sizeof(int))
+			return -EINVAL;
+		len = sizeof(int);
+		val = nlk->flags & NETLINK_F_CAP_ACK ? 1 : 0;
+		if (put_user(len, optlen) ||
+		    put_user(val, optval))
+			return -EFAULT;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2873,9 +2891,12 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
+	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
 
-	/* error messages get the original request appened */
-	if (err)
+	/* Error messages get the original request appened, unless the user
+	 * requests to cap the error message.
+	 */
+	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
 		payload += nlmsg_len(nlh);
 
 	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
@@ -2898,7 +2919,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 			  NLMSG_ERROR, payload, 0);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
-	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
+	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
-- 
2.1.4
