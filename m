From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH] netlink: add API to retrieve all group memberships
Date: Fri, 12 Jun 2015 18:15:38 +0200
Message-ID: <1434125738-1990-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33748 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323AbbFLQQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:16:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/uapi/linux/netlink.h | 15 ++++++++-------
 net/netlink/af_netlink.c     | 22 ++++++++++++++++++++++
 2 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 1a85940..e38094f 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -101,13 +101,14 @@ struct nlmsgerr {
 	struct nlmsghdr msg;
 };
 
-#define NETLINK_ADD_MEMBERSHIP	1
-#define NETLINK_DROP_MEMBERSHIP	2
-#define NETLINK_PKTINFO		3
-#define NETLINK_BROADCAST_ERROR	4
-#define NETLINK_NO_ENOBUFS	5
-#define NETLINK_RX_RING		6
-#define NETLINK_TX_RING		7
+#define NETLINK_ADD_MEMBERSHIP		1
+#define NETLINK_DROP_MEMBERSHIP		2
+#define NETLINK_PKTINFO			3
+#define NETLINK_BROADCAST_ERROR		4
+#define NETLINK_NO_ENOBUFS		5
+#define NETLINK_RX_RING			6
+#define NETLINK_TX_RING			7
+#define NETLINK_LIST_MEMBERSHIPS	8
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bf6e766..b84dbe7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2254,6 +2254,28 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
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
