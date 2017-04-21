From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/3] packet: add PACKET_FANOUT_FLAG_UNIQUEID to assign new fanout group id.
Date: Fri, 21 Apr 2017 10:56:11 -0400
Message-ID: <20170421145612.106869-3-willemdebruijn.kernel@gmail.com>
References: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Cc: maloneykernel@gmail.com, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33310 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424798AbdDUTUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:20:54 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so2356511qkh.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:20:53 -0700 (PDT)
In-Reply-To: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Fanout uses a per net global namespace. A process that intends to create
a new fanout group can accidentally join an existing group. It is not
possible to detect this.

Add socket option PACKET_FANOUT_FLAG_UNIQUEID.  When specified the
supplied fanout group id must be set to 0, and the kernel chooses an id
that is not already in use.  This is an ephemeral flag so that
other sockets can be added to this group using setsockopt, but NOT
specifying this flag.  The current getsockopt(..., PACKET_FANOUT, ...)
can be used to retrieve the new group id.

We assume that there are not a lot of fanout groups and that this is not
a high frequency call.

The method assigns ids starting at zero and increases until it finds an
unused id.  It keeps track of the last assigned id, and uses it as a
starting point to find new ids.

Signed-off-by: Mike Maloney <maloney@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>

---
 include/uapi/linux/if_packet.h |  1 +
 net/packet/af_packet.c         | 44 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 9e7edfd8141e..4df96a7dd4fa 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -66,6 +66,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_CBPF		6
 #define PACKET_FANOUT_EBPF		7
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
+#define PACKET_FANOUT_FLAG_UNIQUEID	0x2000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
 struct tpacket_stats {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8489beff5c25..94052f42058b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1496,6 +1496,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 DEFINE_MUTEX(fanout_mutex);
 EXPORT_SYMBOL_GPL(fanout_mutex);
 static LIST_HEAD(fanout_list);
+static u16 fanout_next_id;
 
 static void __fanout_link(struct sock *sk, struct packet_sock *po)
 {
@@ -1629,6 +1630,36 @@ static void fanout_release_data(struct packet_fanout *f)
 	};
 }
 
+static bool __fanout_id_is_free(struct sock *sk, u16 candidate_id)
+{
+	struct packet_fanout *f;
+
+	list_for_each_entry(f, &fanout_list, list) {
+		if (f->id == candidate_id &&
+		    read_pnet(&f->net) == sock_net(sk)) {
+			return false;
+		}
+	}
+	return true;
+}
+
+static bool fanout_find_new_id(struct sock *sk, u16 *new_id)
+{
+	u16 id = fanout_next_id;
+
+	do {
+		if (__fanout_id_is_free(sk, id)) {
+			*new_id = id;
+			fanout_next_id = id + 1;
+			return true;
+		}
+
+		id++;
+	} while (id != fanout_next_id);
+
+	return false;
+}
+
 static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 {
 	struct packet_rollover *rollover = NULL;
@@ -1676,6 +1707,19 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		po->rollover = rollover;
 	}
 
+	if (type_flags & PACKET_FANOUT_FLAG_UNIQUEID) {
+		if (id != 0) {
+			err = -EINVAL;
+			goto out;
+		}
+		if (!fanout_find_new_id(sk, &id)) {
+			err = -ENOMEM;
+			goto out;
+		}
+		/* ephemeral flag for the first socket in the group: drop it */
+		flags &= ~(PACKET_FANOUT_FLAG_UNIQUEID >> 8);
+	}
+
 	match = NULL;
 	list_for_each_entry(f, &fanout_list, list) {
 		if (f->id == id &&
-- 
2.12.2.816.g2cccc81164-goog
