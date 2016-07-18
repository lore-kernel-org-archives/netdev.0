From: Shiraz Saleem <shiraz.saleem@intel.com>
Subject: [PATCH V2] Add flow control to the portmapper
Date: Mon, 18 Jul 2016 14:23:30 -0500
Message-ID: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
Cc: linux-rdma@vger.kernel.org, swise@opengridcomputing.com,
	e1000-rdma@lists.sourceforge.net, netdev@vger.kernel.org,
	Mustafa Ismail <mustafa.ismail@intel.com>,
	Shiraz Saleem <shiraz.saleem@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:49800 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789AbcGRT0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mustafa Ismail <mustafa.ismail@intel.com>

During connection establishment with a large number of connections,
it is possible that the connection requests might fail. Adding flow
control prevents this failure. Change ibnl unicast to use netlink
messaging with blocking to enable flow control.

Signed-off-by: Faisal Latif <faisal.latif@intel.com>
Signed-off-by: Mustafa Ismail <mustafa.ismail@intel.com>
Signed-off-by: Shiraz Saleem <shiraz.saleem@intel.com>
---

V2: update commit message with justification for flow control. CC'ing
linux-netdev mailing list.
 
 drivers/infiniband/core/netlink.c |  4 ++--
 include/net/netlink.h             | 17 +++++++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 9b8c20c..6b09580 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -229,7 +229,7 @@ static void ibnl_rcv(struct sk_buff *skb)
 int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
 			__u32 pid)
 {
-	return nlmsg_unicast(nls, skb, pid);
+	return nlmsg_unicast_block(nls, skb, pid);
 }
 EXPORT_SYMBOL(ibnl_unicast);
 
@@ -251,7 +251,7 @@ int __init ibnl_init(void)
 		pr_warn("Failed to create netlink socket\n");
 		return -ENOMEM;
 	}
-
+	nls->sk_sndtimeo = 10 * HZ;
 	return 0;
 }
 
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 254a0fc..5434279 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -598,6 +598,23 @@ static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 portid
 }
 
 /**
+ * nlmsg_unicast_block - unicast a netlink message with blocking
+ * @sk: netlink socket to spread message to
+ * @skb: netlink message as socket buffer
+ * @portid: netlink portid of the destination socket
+ */
+static inline int nlmsg_unicast_block(struct sock *sk, struct sk_buff *skb, u32 portid)
+{
+	int err;
+
+	err = netlink_unicast(sk, skb, portid, 0);
+	if (err > 0)
+		err = 0;
+
+	return err;
+}
+
+/**
  * nlmsg_for_each_msg - iterate over a stream of messages
  * @pos: loop counter, set to current message
  * @head: head of message stream
-- 
2.1.3
