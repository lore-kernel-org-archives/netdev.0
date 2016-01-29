From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCH net] netlink: not trim skb for mmaped socket when dump
Date: Fri, 29 Jan 2016 10:45:50 +0900
Message-ID: <20160129014549.GA28672@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35713 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755178AbcA2Bpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 20:45:55 -0500
Received: by mail-pa0-f67.google.com with SMTP id gi1so2808888pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 17:45:55 -0800 (PST)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id tp6sm19254307pab.25.2016.01.28.17.45.53
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 17:45:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not trim skb for mmaped socket since its buf size is fixed
and userspace will read as frame which data equals head. mmaped
socket will not call recvmsg, means max_recvmsg_len is 0,
skb_reserve was not called before commit: db65a3aaf29e.

Fixes: db65a3aaf29e (netlink: Trim skb to alloc size to avoid MSG_TRUNC)
Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

---
 net/netlink/af_netlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 81dc1bb..f1ffb34 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2831,7 +2831,8 @@ static int netlink_dump(struct sock *sk)
 	 * reasonable static buffer based on the expected largest dump of a
 	 * single netdev. The outcome is MSG_TRUNC error.
 	 */
-	skb_reserve(skb, skb_tailroom(skb) - alloc_size);
+	if (!netlink_rx_is_mmaped(sk))
+		skb_reserve(skb, skb_tailroom(skb) - alloc_size);
 	netlink_skb_set_owner_r(skb, sk);
 
 	len = cb->dump(skb, cb);
-- 
1.7.10.4
