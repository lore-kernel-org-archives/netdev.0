From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink: netlink_ack send a capped message in case of error
Date: Mon, 24 Aug 2015 20:56:37 +0200
Message-ID: <20150824185637.GA19923@salvia>
References: <1440367577-15786-1-git-send-email-christophe-h.ricard@st.com>
 <1440367577-15786-2-git-send-email-christophe-h.ricard@st.com>
 <CAE4R7bAYUhbUoGK_M=USJW8pgWmBrKsNuzLFmY70aBzti53Vxg@mail.gmail.com>
 <CALD+uuz7NHdWU0qqogu6_cs81Ng6gpcCPFUr4WUF+hpQPMaysg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: Scott Feldman <sfeldma@gmail.com>, jbenc@redhat.com,
	Samuel Ortiz <sameo@linux.intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christophe Ricard <christophe-h.ricard@st.com>
To: Christophe Ricard <christophe.ricard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51750 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbbHXSuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 14:50:23 -0400
Content-Disposition: inline
In-Reply-To: <CALD+uuz7NHdWU0qqogu6_cs81Ng6gpcCPFUr4WUF+hpQPMaysg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 24, 2015 at 10:08:22AM +0200, Christophe Ricard wrote:
> Hi Scott,
> 
> I think i understand the potential limitation of my solution.
> I saw something was proposed by Jiri Benc who pushed an additional flag to
> tell if the payload can be ignored in case of an error.
> http://patchwork.ozlabs.org/patch/290976/
> 
> Do you think this one is acceptable ? I am not sure to understand David
> last comment.

I think David suggests something like the (completely untested)
attached patch.

--9amGYk9869ThD9tj
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netlink-add-NETLINK_CAP_ACK-socket-option.patch"

>From 3aa0deafb5648427d154e26920d9d85f89dab190 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 24 Aug 2015 20:23:45 +0200
Subject: [PATCH RFC] netlink: add NETLINK_CAP_ACK socket option

Since commit c05cdb1b864f ("netlink: allow large data transfers from
user-space"), the kernel may fail to allocate the necessary room for the
acknowledgement message back to userspace. This patch introduces a new socket
option that trims off the payload of the original netlink message.

The netlink message header is still included, so the user can guess from the
sequence number what is the message that has triggered the acknowledgment.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netlink.h |    1 +
 net/netlink/af_netlink.c     |   25 +++++++++++++++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

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
index 67d2104..baa5973 100644
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
@@ -2869,13 +2887,16 @@ EXPORT_SYMBOL(__netlink_dump_start);
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 {
+	struct netlink_sock *nlk = nlk_sk(in_skb->sk);
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
 
-	/* error messages get the original request appened */
-	if (err)
+	/* Error messages get the original request appended, unless the user
+	 * requests to cap the error message.
+	 */
+	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
 		payload += nlmsg_len(nlh);
 
 	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
-- 
1.7.10.4


--9amGYk9869ThD9tj--
