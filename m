From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: don't send NETLINK_URELEASE for unbound sockets
Date: Thu,  7 Apr 2016 09:31:38 +0200
Message-ID: <1460014298-30293-1-git-send-email-johannes@sipsolutions.net>
Cc: Dmitry Ivanov <dmitrijs.ivanovs@ubnt.com>,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43087 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426AbcDGHby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 03:31:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Ivanov <dmitrijs.ivanovs@ubnt.com>

All existing users of NETLINK_URELEASE use it to clean up resources that
were previously allocated to a socket via some command. As a result, no
users require getting this notification for unbound sockets.

Sending it for unbound sockets, however, is a problem because any user
(including unprivileged users) can create a socket that uses the same ID
as an existing socket. Binding this new socket will fail, but if the
NETLINK_URELEASE notification is generated for such sockets, the users
thereof will be tricked into thinking the socket that they allocated the
resources for is closed.

In the nl80211 case, this will cause destruction of virtual interfaces
that still belong to an existing hostapd process; this is the case that
Dmitry noticed. In the NFC case, it will cause a poll abort. In the case
of netlink log/queue it will cause them to stop reporting events, as if
NFULNL_CFG_CMD_UNBIND/NFQNL_CFG_CMD_UNBIND had been called.

Fix this problem by checking that the socket is bound before generating
the NETLINK_URELEASE notification.

Cc: stable@vger.kernel.org
Signed-off-by: Dmitry Ivanov <dima@ubnt.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 215fc08c02ab..330ebd600f25 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -688,7 +688,7 @@ static int netlink_release(struct socket *sock)
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->portid) {
+	if (nlk->portid && nlk->bound) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
-- 
2.7.0
