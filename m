From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] packet: hold bind lock when rebinding to fanout hook
Date: Thu, 14 Sep 2017 17:14:41 -0400
Message-ID: <20170914211441.67326-1-willemb@google.com>
Cc: davem@davemloft.net, nixiaoming@huawei.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:53962 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbdINVPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 17:15:06 -0400
Received: by mail-qk0-f178.google.com with SMTP id t184so567306qke.10
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 14:15:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packet socket bind operations must hold the po->bind_lock. This keeps
po->running consistent with whether the socket is actually on a ptype
list to receive packets.

fanout_add unbinds a socket and its packet_rcv/tpacket_rcv call, then
binds the fanout object to receive through packet_rcv_fanout.

Make it hold the po->bind_lock when testing po->running and rebinding.
Else, it can race with other rebind operations, such as that in
packet_set_ring from packet_rcv to tpacket_rcv. Concurrent updates
can result in a socket being added to a fanout group twice, causing
use-after-free KASAN bug reports, among others.

Reported independently by both trinity and syzkaller.
Verified that the syzkaller reproducer passes after this patch.

Reported-by: nixioaming <nixiaoming@huawei.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c26172995511..d288f52c53f7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1684,10 +1684,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 
 	mutex_lock(&fanout_mutex);
 
-	err = -EINVAL;
-	if (!po->running)
-		goto out;
-
 	err = -EALREADY;
 	if (po->fanout)
 		goto out;
@@ -1749,7 +1745,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		list_add(&match->list, &fanout_list);
 	}
 	err = -EINVAL;
-	if (match->type == type &&
+
+	spin_lock(&po->bind_lock);
+	if (po->running &&
+	    match->type == type &&
 	    match->prot_hook.type == po->prot_hook.type &&
 	    match->prot_hook.dev == po->prot_hook.dev) {
 		err = -ENOSPC;
@@ -1761,6 +1760,13 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			err = 0;
 		}
 	}
+	spin_unlock(&po->bind_lock);
+
+	if (err && !refcount_read(&match->sk_ref)) {
+		list_del(&match->list);
+		kfree(match);
+	}
+
 out:
 	if (err && rollover) {
 		kfree(rollover);
-- 
2.14.1.690.gbb1197296e-goog
