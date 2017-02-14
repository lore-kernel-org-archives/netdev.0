From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] packet: fix races in fanout_add()
Date: Tue, 14 Feb 2017 09:03:51 -0800
Message-ID: <1487091831.8227.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34489 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932283AbdBNRES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:04:18 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so17929375otj.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 09:04:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Multiple threads can call fanout_add() at the same time.

We need to grab fanout_mutex earlier to avoid races that could
lead to one thread freeing po->rollover that was set by another thread.

Do the same in fanout_release(), for peace of mind, and to help us
finding lockdep issues earlier.

Fixes: dc99f600698d ("packet: Add fanout support.")
Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c |   55 +++++++++++++++++++++------------------
 1 file changed, 30 insertions(+), 25 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d56ee46b11fc9524e457e5fe8adf10c105a66ab6..0f03f6a53b4ddb8093a2122914200c0738af8fb3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1619,6 +1619,7 @@ static void fanout_release_data(struct packet_fanout *f)
 
 static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 {
+	struct packet_rollover *rollover = NULL;
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_fanout *f, *match;
 	u8 type = type_flags & 0xff;
@@ -1641,23 +1642,28 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		return -EINVAL;
 	}
 
+	mutex_lock(&fanout_mutex);
+
+	err = -EINVAL;
 	if (!po->running)
-		return -EINVAL;
+		goto out;
 
+	err = -EALREADY;
 	if (po->fanout)
-		return -EALREADY;
+		goto out;
 
 	if (type == PACKET_FANOUT_ROLLOVER ||
 	    (type_flags & PACKET_FANOUT_FLAG_ROLLOVER)) {
-		po->rollover = kzalloc(sizeof(*po->rollover), GFP_KERNEL);
-		if (!po->rollover)
-			return -ENOMEM;
-		atomic_long_set(&po->rollover->num, 0);
-		atomic_long_set(&po->rollover->num_huge, 0);
-		atomic_long_set(&po->rollover->num_failed, 0);
+		err = -ENOMEM;
+		rollover = kzalloc(sizeof(*rollover), GFP_KERNEL);
+		if (!rollover)
+			goto out;
+		atomic_long_set(&rollover->num, 0);
+		atomic_long_set(&rollover->num_huge, 0);
+		atomic_long_set(&rollover->num_failed, 0);
+		po->rollover = rollover;
 	}
 
-	mutex_lock(&fanout_mutex);
 	match = NULL;
 	list_for_each_entry(f, &fanout_list, list) {
 		if (f->id == id &&
@@ -1704,11 +1710,11 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		}
 	}
 out:
-	mutex_unlock(&fanout_mutex);
-	if (err) {
-		kfree(po->rollover);
+	if (err && rollover) {
+		kfree(rollover);
 		po->rollover = NULL;
 	}
+	mutex_unlock(&fanout_mutex);
 	return err;
 }
 
@@ -1717,23 +1723,22 @@ static void fanout_release(struct sock *sk)
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_fanout *f;
 
-	f = po->fanout;
-	if (!f)
-		return;
-
 	mutex_lock(&fanout_mutex);
-	po->fanout = NULL;
+	f = po->fanout;
+	if (f) {
+		po->fanout = NULL;
+
+		if (atomic_dec_and_test(&f->sk_ref)) {
+			list_del(&f->list);
+			dev_remove_pack(&f->prot_hook);
+			fanout_release_data(f);
+			kfree(f);
+		}
 
-	if (atomic_dec_and_test(&f->sk_ref)) {
-		list_del(&f->list);
-		dev_remove_pack(&f->prot_hook);
-		fanout_release_data(f);
-		kfree(f);
+		if (po->rollover)
+			kfree_rcu(po->rollover, rcu);
 	}
 	mutex_unlock(&fanout_mutex);
-
-	if (po->rollover)
-		kfree_rcu(po->rollover, rcu);
 }
 
 static bool packet_extra_vlan_len_allowed(const struct net_device *dev,
