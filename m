From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] cls_cgroup: Allow classifier cgroups to have their classid reset to 0
Date: Mon, 20 Aug 2012 13:59:10 -0400
Message-ID: <1345485550-15556-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54227 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2HTR7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 13:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network classifier cgroup initalizes each cgroups instance classid value to
0.  However, the sock_update_classid function only updates classid's in sockets
if the tasks cgroup classid is not zero, and if it differs from the current
classid.  The later check is to prevent cache line dirtying, but the former is
detrimental, as it prevents resetting a classid for a cgroup to 0.  While this
is not a common action, it has administrative usefulness (if the admin wants to
disable classification of a certain group temporarily for instance).

Easy fix, just remove the zero check.  Tested successfully by myself

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..116786c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1230,7 +1230,7 @@ void sock_update_classid(struct sock *sk)
 	rcu_read_lock();  /* doing current task, which cannot vanish. */
 	classid = task_cls_classid(current);
 	rcu_read_unlock();
-	if (classid && classid != sk->sk_classid)
+	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
-- 
1.7.7.6
