From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [RFC PATCH v3 2/2] can: introduce new raw socket option to join the given CAN filters
Date: Wed,  1 Apr 2015 07:50:29 +0200
Message-ID: <1427867429-3909-3-git-send-email-socketcan@hartkopp.net>
References: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.163]:44450 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbDAFun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 01:50:43 -0400
In-Reply-To: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CAN_RAW socket can set multiple CAN identifier specific filters that lead
to multiple filters in the af_can.c filter processing. These filters are
indenpendent from each other which leads to logical OR'ed filters when applied.

This socket option joines the given CAN filters in the way that only CAN frames
are passed to user space that matched *all* given CAN filters. The semantic for
the applied filters is therefore changed to a logical AND.

This is useful especially when the filterset is a combination of filters where
the CAN_INV_FILTER flag is set in order to notch single CAN IDs or CAN ID
ranges from the incoming traffic.

As the raw_rcv() function is executed from NET_RX softirq the introduced
variables are implemented as per-CPU variables to avoid extensive locking at
CAN frame reception time.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 Documentation/networking/can.txt | 20 ++++++++++++++++++--
 include/uapi/linux/can/raw.h     |  1 +
 net/can/raw.c                    | 31 ++++++++++++++++++++++++++++++-
 3 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
index 0a2859a..5abad1e 100644
--- a/Documentation/networking/can.txt
+++ b/Documentation/networking/can.txt
@@ -22,7 +22,8 @@ This file contains
       4.1.3 RAW socket option CAN_RAW_LOOPBACK
       4.1.4 RAW socket option CAN_RAW_RECV_OWN_MSGS
       4.1.5 RAW socket option CAN_RAW_FD_FRAMES
-      4.1.6 RAW socket returned message flags
+      4.1.6 RAW socket option CAN_RAW_JOIN_FILTERS
+      4.1.7 RAW socket returned message flags
     4.2 Broadcast Manager protocol sockets (SOCK_DGRAM)
       4.2.1 Broadcast Manager operations
       4.2.2 Broadcast Manager message flags
@@ -601,7 +602,22 @@ solution for a couple of reasons:
   CAN FD frames by checking if the device maximum transfer unit is CANFD_MTU.
   The CAN device MTU can be retrieved e.g. with a SIOCGIFMTU ioctl() syscall.
 
-  4.1.6 RAW socket returned message flags
+  4.1.6 RAW socket option CAN_RAW_JOIN_FILTERS
+
+  The CAN_RAW socket can set multiple CAN identifier specific filters that
+  lead to multiple filters in the af_can.c filter processing. These filters
+  are indenpendent from each other which leads to logical OR'ed filters when
+  applied (see 4.1.1).
+
+  This socket option joines the given CAN filters in the way that only CAN
+  frames are passed to user space that matched *all* given CAN filters. The
+  semantic for the applied filters is therefore changed to a logical AND.
+
+  This is useful especially when the filterset is a combination of filters
+  where the CAN_INV_FILTER flag is set in order to notch single CAN IDs or
+  CAN ID ranges from the incoming traffic.
+
+  4.1.7 RAW socket returned message flags
 
   When using recvmsg() call, the msg->msg_flags may contain following flags:
 
diff --git a/include/uapi/linux/can/raw.h b/include/uapi/linux/can/raw.h
index 78ec76f..8735f108 100644
--- a/include/uapi/linux/can/raw.h
+++ b/include/uapi/linux/can/raw.h
@@ -57,6 +57,7 @@ enum {
 	CAN_RAW_LOOPBACK,	/* local loopback (default:on)       */
 	CAN_RAW_RECV_OWN_MSGS,	/* receive my own msgs (default:off) */
 	CAN_RAW_FD_FRAMES,	/* allow CAN FD frames (default:off) */
+	CAN_RAW_JOIN_FILTERS,	/* all filters must match to trigger */
 };
 
 #endif /* !_UAPI_CAN_RAW_H */
diff --git a/net/can/raw.c b/net/can/raw.c
index 8c75446..7b94554 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -77,6 +77,7 @@ MODULE_ALIAS("can-proto-1");
 struct uniqframe {
 	const struct sk_buff *skb;
 	ktime_t tstamp;
+	unsigned int join_rx_count;
 };
 
 struct raw_sock {
@@ -87,6 +88,7 @@ struct raw_sock {
 	int loopback;
 	int recv_own_msgs;
 	int fd_frames;
+	int join_filters;
 	int count;                 /* number of active filters */
 	struct can_filter dfilter; /* default/single filter */
 	struct can_filter *filter; /* pointer to filter(s) */
@@ -132,10 +134,21 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	/* eliminate multiple filter matches for the same skb */
 	if (this_cpu_ptr(ro->uniq)->skb == oskb &&
 	    ktime_equal(this_cpu_ptr(ro->uniq)->tstamp, oskb->tstamp)) {
-		return;
+		if (ro->join_filters) {
+			this_cpu_inc(ro->uniq->join_rx_count);
+			/* drop frame until all enabled filters matched */
+			if (this_cpu_ptr(ro->uniq)->join_rx_count < ro->count)
+				return;
+		} else {
+			return;
+		}
 	} else {
 		this_cpu_ptr(ro->uniq)->skb = oskb;
 		this_cpu_ptr(ro->uniq)->tstamp = oskb->tstamp;
+		this_cpu_ptr(ro->uniq)->join_rx_count = 1;
+		/* drop first frame to check all enabled filters? */
+		if (ro->join_filters && ro->count > 1)
+			return;
 	}
 
 	/* clone the given skb to be able to enqueue it into the rcv queue */
@@ -311,6 +324,7 @@ static int raw_init(struct sock *sk)
 	ro->loopback         = 1;
 	ro->recv_own_msgs    = 0;
 	ro->fd_frames        = 0;
+	ro->join_filters     = 0;
 
 	/* alloc_percpu provides zero'ed memory */
 	ro->uniq = alloc_percpu(struct uniqframe);
@@ -604,6 +618,15 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 
 		break;
 
+	case CAN_RAW_JOIN_FILTERS:
+		if (optlen != sizeof(ro->join_filters))
+			return -EINVAL;
+
+		if (copy_from_user(&ro->join_filters, optval, optlen))
+			return -EFAULT;
+
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -668,6 +691,12 @@ static int raw_getsockopt(struct socket *sock, int level, int optname,
 		val = &ro->fd_frames;
 		break;
 
+	case CAN_RAW_JOIN_FILTERS:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = &ro->join_filters;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
2.1.4
