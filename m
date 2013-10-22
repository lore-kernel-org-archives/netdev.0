From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH stable 3.11] sit: amend "allow to use rtnl ops on fb tunnel"
Date: Tue, 22 Oct 2013 10:59:18 -0400
Message-ID: <1382453958-32376-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:55254 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab3JVO7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 10:59:22 -0400
Received: by mail-ye0-f201.google.com with SMTP id l5so363211yen.0
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 07:59:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amend backport to 3.11.y of

 [ Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5 ]

The discussion thread in the upstream commit mentions that in
backports to stable-* branches, the line

  - unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);

must be omitted if that branch does not have commit 5e6700b3bf98
("sit: add support of x-netns"). This line has correctly been omitted
in the backport to 3.10, which indeed does not have that commit.

It was also removed in the backport to 3.11.y, which does have that
commit.

This causes the following steps to hit a BUG at net/core/dev.c:5039:

  `modprobe sit; rmmod sit`

The bug demonstrates that it causes a device to be unregistered twice.
The simple fix is to apply the one line in the upstream commit that
was dropped in the backport to 3.11 (3783100374653e2e7fbdf68c710f5).
This brings the logic in line with upstream linux, net and net-next
branches.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

The policy for networking patches is to queue stable patches up for
the davem/stable queue.

Since this patch only applies to one specific branch, I assumed
that creating it directly against 3.11.y is the right process. I
did *not* directly cc: the stable list. David, please let me know
if this should not go through your queue at all and I should
resubmit to stable.
---
 net/ipv6/sit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 86f639b..a51ad07 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1708,7 +1708,6 @@ static void __net_exit sit_exit_net(struct net *net)
 
 	rtnl_lock();
 	sit_destroy_tunnels(sitn, &list);
-	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-- 
1.8.4
