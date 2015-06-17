From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v2] netlink: add API to retrieve all group memberships
Date: Wed, 17 Jun 2015 17:14:33 +0200
Message-ID: <1434554073-23646-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds getsockopt(SOL_NETLINK, NETLINK_LIST_MEMBERSHIPS) to
retrieve all groups a socket is a member of. Currently, we have to use
getsockname() and look at the nl.nl_groups bitmask. However, this mask is
limited to 32 groups. Hence, similar to NETLINK_ADD_MEMBERSHIP and
NETLINK_DROP_MEMBERSHIP, this adds a separate sockopt to manager higher
groups IDs than 32.

This new NETLINK_LIST_MEMBERSHIPS option takes a pointer to __u32 and the
size of the array. The array is filled with the full membership-set of the
socket, and the required array size is returned in optlen. Hence,
user-space can retry with a properly sized array in case it was too small.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
v2:
  - rebase on top of net-next
    conflict due to 59324cf35ab ('netlink: allow to listen "all" netns')

 include/uapi/linux/netlink.h | 17 +++++++++--------
 net/netlink/af_netlink.c     | 22 ++++++++++++++++++++++
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 3e34b7d..cf6a65c 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -101,14 +101,15 @@ struct nlmsgerr {
 	struct nlmsghdr msg;
 };
 
-#define NETLINK_ADD_MEMBERSHIP	1
-#define NETLINK_DROP_MEMBERSHIP	2
-#define NETLINK_PKTINFO		3
-#define NETLINK_BROADCAST_ERROR	4
-#define NETLINK_NO_ENOBUFS	5
-#define NETLINK_RX_RING		6
-#define NETLINK_TX_RING		7
-#define NETLINK_LISTEN_ALL_NSID	8
+#define NETLINK_ADD_MEMBERSHIP		1
+#define NETLINK_DROP_MEMBERSHIP		2
+#define NETLINK_PKTINFO			3
+#define NETLINK_BROADCAST_ERROR		4
+#define NETLINK_NO_ENOBUFS		5
+#define NETLINK_RX_RING			6
+#define NETLINK_TX_RING			7
+#define NETLINK_LISTEN_ALL_NSID		8
+#define NETLINK_LIST_MEMBERSHIPS	9
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 69d67c3..dea9253 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2290,6 +2290,28 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		err = 0;
 		break;
+	case NETLINK_LIST_MEMBERSHIPS: {
+		int pos, idx, shift;
+
+		err = 0;
+		netlink_table_grab();
+		for (pos = 0; pos * 8 < nlk->ngroups; pos += sizeof(u32)) {
+			if (len - pos < sizeof(u32))
+				break;
+
+			idx = pos / sizeof(unsigned long);
+			shift = (pos % sizeof(unsigned long)) * 8;
+			if (put_user((u32)(nlk->groups[idx] >> shift),
+				     (u32 __user *)(optval + pos))) {
+				err = -EFAULT;
+				break;
+			}
+		}
+		if (put_user(ALIGN(nlk->ngroups / 8, sizeof(u32)), optlen))
+			err = -EFAULT;
+		netlink_table_ungrab();
+		break;
+	}
 	default:
 		err = -ENOPROTOOPT;
 	}
-- 
2.4.2
