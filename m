From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 11:50:25 -0400
Message-ID: <1439567427-19504-3-git-send-email-willemb@google.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35868 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533AbbHNPuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 11:50:35 -0400
Received: by qkdv3 with SMTP id v3so26768271qkd.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 08:50:35 -0700 (PDT)
In-Reply-To: <1439567427-19504-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add a fanout mode that accepts an eBPF program to select a socket.

Update the internal eBPF program by passing to socket option
SOL_PACKET/PACKET_FANOUT_DATA a file descriptor returned by bpf().

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/if_packet.h |  1 +
 net/packet/af_packet.c         | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index d41280a..daa0ddd 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -64,6 +64,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_RND		4
 #define PACKET_FANOUT_QM		5
 #define PACKET_FANOUT_BPF		6
+#define PACKET_FANOUT_EBPF		7
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 80d68c9..6352b7d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1472,6 +1472,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 		idx = fanout_demux_rollover(f, skb, 0, false, num);
 		break;
 	case PACKET_FANOUT_BPF:
+	case PACKET_FANOUT_EBPF:
 		idx = fanout_demux_bpf(f, skb, num);
 		break;
 	}
@@ -1529,6 +1530,7 @@ static void fanout_init_data(struct packet_fanout *f)
 		atomic_set(&f->rr_cur, 0);
 		break;
 	case PACKET_FANOUT_BPF:
+	case PACKET_FANOUT_EBPF:
 		RCU_INIT_POINTER(f->bpf_prog, NULL);
 		break;
 	}
@@ -1569,12 +1571,33 @@ static int fanout_set_data_bpf(struct packet_fanout *f, char __user *data,
 	return 0;
 }
 
+static int fanout_set_data_ebpf(struct packet_fanout *f, char __user *data,
+				unsigned int len)
+{
+	struct bpf_prog *new;
+	u32 fd;
+
+	if (len != sizeof(fd))
+		return -EINVAL;
+	if (copy_from_user(&fd, data, len))
+		return -EFAULT;
+
+	new = bpf_prog_get(fd);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	__fanout_set_data_bpf(f, new);
+	return 0;
+}
+
 static int fanout_set_data(struct packet_fanout *f, char __user *data,
 			   unsigned int len)
 {
 	switch (f->type) {
 	case PACKET_FANOUT_BPF:
 		return fanout_set_data_bpf(f, data, len);
+	case PACKET_FANOUT_EBPF:
+		return fanout_set_data_ebpf(f, data, len);
 	default:
 		return -EINVAL;
 	};
@@ -1584,6 +1607,7 @@ static void fanout_release_data(struct packet_fanout *f)
 {
 	switch (f->type) {
 	case PACKET_FANOUT_BPF:
+	case PACKET_FANOUT_EBPF:
 		__fanout_set_data_bpf(f, NULL);
 	};
 }
@@ -1606,6 +1630,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	case PACKET_FANOUT_RND:
 	case PACKET_FANOUT_QM:
 	case PACKET_FANOUT_BPF:
+	case PACKET_FANOUT_EBPF:
 		break;
 	default:
 		return -EINVAL;
-- 
2.5.0.276.gf5e568e
