From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 2/4] packet: add extended BPF fanout mode
Date: Fri, 14 Aug 2015 22:31:35 -0400
Message-ID: <1439605897-28311-3-git-send-email-willemb@google.com>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33531 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbbHOCbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 22:31:42 -0400
Received: by qged69 with SMTP id d69so63051666qge.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 19:31:41 -0700 (PDT)
In-Reply-To: <1439605897-28311-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add fanout mode PACKET_FANOUT_EBPF that accepts an en extended BPF
program to select a socket.

Update the internal eBPF program by passing to socket option
SOL_PACKET/PACKET_FANOUT_DATA a file descriptor returned by bpf().

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/if_packet.h |  1 +
 net/packet/af_packet.c         | 31 +++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index a4bb16f..9e7edfd 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -64,6 +64,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_RND		4
 #define PACKET_FANOUT_QM		5
 #define PACKET_FANOUT_CBPF		6
+#define PACKET_FANOUT_EBPF		7
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8869d07..7b8e39a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1472,6 +1472,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 		idx = fanout_demux_rollover(f, skb, 0, false, num);
 		break;
 	case PACKET_FANOUT_CBPF:
+	case PACKET_FANOUT_EBPF:
 		idx = fanout_demux_bpf(f, skb, num);
 		break;
 	}
@@ -1529,6 +1530,7 @@ static void fanout_init_data(struct packet_fanout *f)
 		atomic_set(&f->rr_cur, 0);
 		break;
 	case PACKET_FANOUT_CBPF:
+	case PACKET_FANOUT_EBPF:
 		RCU_INIT_POINTER(f->bpf_prog, NULL);
 		break;
 	}
@@ -1571,12 +1573,39 @@ static int fanout_set_data_cbpf(struct packet_sock *po, char __user *data,
 	return 0;
 }
 
+static int fanout_set_data_ebpf(struct packet_sock *po, char __user *data,
+				unsigned int len)
+{
+	struct bpf_prog *new;
+	u32 fd;
+
+	if (sock_flag(&po->sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+	if (len != sizeof(fd))
+		return -EINVAL;
+	if (copy_from_user(&fd, data, len))
+		return -EFAULT;
+
+	new = bpf_prog_get(fd);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+	if (new->type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		bpf_prog_put(new);
+		return -EINVAL;
+	}
+
+	__fanout_set_data_bpf(po->fanout, new);
+	return 0;
+}
+
 static int fanout_set_data(struct packet_sock *po, char __user *data,
 			   unsigned int len)
 {
 	switch (po->fanout->type) {
 	case PACKET_FANOUT_CBPF:
 		return fanout_set_data_cbpf(po, data, len);
+	case PACKET_FANOUT_EBPF:
+		return fanout_set_data_ebpf(po, data, len);
 	default:
 		return -EINVAL;
 	};
@@ -1586,6 +1615,7 @@ static void fanout_release_data(struct packet_fanout *f)
 {
 	switch (f->type) {
 	case PACKET_FANOUT_CBPF:
+	case PACKET_FANOUT_EBPF:
 		__fanout_set_data_bpf(f, NULL);
 	};
 }
@@ -1608,6 +1638,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	case PACKET_FANOUT_RND:
 	case PACKET_FANOUT_QM:
 	case PACKET_FANOUT_CBPF:
+	case PACKET_FANOUT_EBPF:
 		break;
 	default:
 		return -EINVAL;
-- 
2.5.0.276.gf5e568e
