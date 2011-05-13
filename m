From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: netlink: don't try unicast when dst_pid is zero for NETLINK_USERSOCK
Date: Fri, 13 May 2011 14:24:54 +0800
Message-ID: <1305267894-3314-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:46028 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab1EMGZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 02:25:57 -0400
Received: by pzk9 with SMTP id 9so1040070pzk.19
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 23:25:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NETLINK_USERSOCK, no one listens on PID 0, so sending a message only to
to a multicast group should not return -ECONNREFUSED.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netlink/af_netlink.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c8f35b5..ba89304 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1379,6 +1379,8 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (dst_group) {
 		atomic_inc(&skb->users);
 		netlink_broadcast(sk, skb, dst_pid, dst_group, GFP_KERNEL);
+		if (dst_pid == 0 && sk->sk_protocol == NETLINK_USERSOCK)
+			return len;
 	}
 	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
 
