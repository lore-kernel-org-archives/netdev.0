From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] packet: in packet_do_bind, test fanout with bind_lock held
Date: Tue, 26 Sep 2017 12:19:37 -0400
Message-ID: <20170926161937.60597-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35274 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934771AbdIZQTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 12:19:40 -0400
Received: by mail-qk0-f195.google.com with SMTP id o77so7143343qke.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 09:19:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Once a socket has po->fanout set, it remains a member of the group
until it is destroyed. The prot_hook must be constant and identical
across sockets in the group.

If fanout_add races with packet_do_bind between the test of po->fanout
and taking the lock, the bind call may make type or dev inconsistent
with that of the fanout group.

Hold po->bind_lock when testing po->fanout to avoid this race.

I had to introduce artificial delay (local_bh_enable) to actually
observe the race.

Fixes: dc99f600698d ("packet: Add fanout support.")
Signed-off-by: Willem de Bruijn <willemb@google.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
---
 net/packet/af_packet.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1da0851f51f2..bec01a3daf5b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3071,13 +3071,15 @@ static int packet_do_bind(struct sock *sk, const char *name, int ifindex,
 	int ret = 0;
 	bool unlisted = false;
 
-	if (po->fanout)
-		return -EINVAL;
-
 	lock_sock(sk);
 	spin_lock(&po->bind_lock);
 	rcu_read_lock();
 
+	if (po->fanout) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
 	if (name) {
 		dev = dev_get_by_name_rcu(sock_net(sk), name);
 		if (!dev) {
-- 
2.14.1.821.g8fa685d3b7-goog
