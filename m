From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 1/8] netlink: Make the sending netlink socket availabe in NETLINK_CB
Date: Fri, 25 Jul 2014 16:22:22 +0800
Message-ID: <1406276549-6616-2-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:35522 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759441AbaGYIYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:24:20 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

The sending socket of an skb is already available by it's port id
in the NETLINK_CB.  If you want to know more like to examine the
credentials on the sending socket you have to look up the sending
socket by it's port id and all of the needed functions and data
structures are static inside of af_netlink.c.  So do the simple
thing and pass the sending socket to the receivers in the NETLINK_CB.

I intend to use this to get the user namespace of the sending socket
in inet_diag so that I can report uids in the context of the process
who opened the socket, the same way I report uids in the contect
of the process who opens files.

Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/linux/netlink.h  | 1 +
 net/netlink/af_netlink.c | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index b23e9cd..af6c763 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -166,6 +166,7 @@ struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
+	struct sock             *ssk;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ff960b7..571fc2c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -899,7 +899,8 @@ static void netlink_rcv_wake(struct sock *sk)
 		wake_up_interruptible(&nlk->wait);
 }
 
-static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
+static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
+				  struct sock *ssk)
 {
 	int ret;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -908,6 +909,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
 		skb_set_owner_r(skb, sk);
+		NETLINK_CB(skb).ssk = ssk;
 		nlk->netlink_rcv(skb);
 	}
 	kfree_skb(skb);
@@ -932,7 +934,7 @@ retry:
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
-		return netlink_unicast_kernel(sk, skb);
+		return netlink_unicast_kernel(sk, skb, ssk);
 
 	if (sk_filter(sk, skb)) {
 		err = skb->len;
-- 
1.8.0
