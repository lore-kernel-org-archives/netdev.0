From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] net: Fix module refcount leak in kernel_accept()
Date: Thu, 18 Dec 2008 18:20:46 +0800
Message-ID: <494A23FE.6020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59824 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbYLRKUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 05:20:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel_accept() does not hold the module refcount of newsock->ops->owner,
so we need __module_get(newsock->ops->owner) code after call kernel_accept()
by hand.
In sunrpc, the module refcount is missing to hold. So this cause kernel panic.

Used following script to reproduct:

while [ 1 ];
do
    mount -t nfs4 192.168.0.19:/ /mnt
    touch /mnt/file
    umount /mnt
    lsmod | grep ipv6
done

This patch fixed the problem by add __module_get(newsock->ops->owner) to
kernel_accept(). So we do not need to used __module_get(newsock->ops->owner)
in every place when used kernel_accept().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/bluetooth/rfcomm/core.c |    2 --
 net/socket.c                |    1 +
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index ba537fa..ce68e04 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1786,8 +1786,6 @@ static inline void rfcomm_accept_connection(struct rfcomm_session *s)
 	if (err < 0)
 		return;
 
-	__module_get(nsock->ops->owner);
-
 	/* Set our callbacks */
 	nsock->sk->sk_data_ready   = rfcomm_l2data_ready;
 	nsock->sk->sk_state_change = rfcomm_l2state_change;
diff --git a/net/socket.c b/net/socket.c
index 92764d8..76ba80a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2307,6 +2307,7 @@ int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
 	}
 
 	(*newsock)->ops = sock->ops;
+	__module_get((*newsock)->ops->owner);
 
 done:
 	return err;
-- 
1.5.3.8



