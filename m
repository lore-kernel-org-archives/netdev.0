From: "Mcmillan, Scott A" <scott.a.mcmillan@intel.com>
Subject: [RFC PATCH] packet_mmap: expose hw packet timestamps to network
 packet capture utilities
Date: Fri, 21 May 2010 13:24:52 -0700
Message-ID: <09ED21B37E0F694688A2317C4FED9ED3046E444260@azsmsx504.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tcpdump-workers@lists.tcpdump.org"
	<tcpdump-workers@lists.tcpdump.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17212 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab0EUUZJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 16:25:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a setting, PACKET_TIMESTAMP, to specify the packet timestamp source that is exported to capture utilities like tcpdump by packet_mmap.  

PACKET_TIMESTAMP accepts the same integer bit field as SO_TIMESTAMPING.  However, only the SOF_TIMESTAMPING_SYS_HARDWARE
and SOF_TIMESTAMPING_RAW_HARDWARE values are currently recognized by PACKET_TIMESTAMP.  SOF_TIMESTAMPING_SYS_HARDWARE takes precedence over SOF_TIMESTAMPING_RAW_HARDWARE if both bits are set.

If PACKET_TIMESTAMP is not set, a software timestamp generated inside the networking stack is used (the behavior before this setting was added).

I am concurrently submitting a patch to the tcpdump / libpcap maintainers adding support for this capability.  

Thanks,
Scott

Signed-off-by: Scott McMillan <scott.a.mcmillan@intel.com>

--- a/include/linux/if_packet.h	2010-05-18 17:22:59.000000000 -0500
+++ b/include/linux/if_packet.h	2010-05-21 14:37:30.000000000 -0500
@@ -48,6 +48,7 @@
 #define PACKET_LOSS			14
 #define PACKET_VNET_HDR			15
 #define PACKET_TX_TIMESTAMP		16
+#define PACKET_TIMESTAMP		17
 
 struct tpacket_stats {
 	unsigned int	tp_packets;
--- a/net/packet/af_packet.c	2010-05-18 17:21:48.000000000 -0500
+++ b/net/packet/af_packet.c	2010-05-21 14:48:41.000000000 -0500
@@ -83,6 +83,7 @@
 #include <linux/if_vlan.h>
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
+#include <linux/net_tstamp.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -202,6 +203,7 @@
 	unsigned int		tp_hdrlen;
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
+	unsigned int		tp_tstamp;
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
@@ -656,6 +658,7 @@
 	struct sk_buff *copy_skb = NULL;
 	struct timeval tv;
 	struct timespec ts;
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -737,7 +740,13 @@
 		h.h1->tp_snaplen = snaplen;
 		h.h1->tp_mac = macoff;
 		h.h1->tp_net = netoff;
-		if (skb->tstamp.tv64)
+		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
+				&& shhwtstamps->syststamp.tv64)
+			tv = ktime_to_timeval(shhwtstamps->syststamp);
+		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
+				&& shhwtstamps->hwtstamp.tv64)
+			tv = ktime_to_timeval(shhwtstamps->hwtstamp);
+		else if (skb->tstamp.tv64)
 			tv = ktime_to_timeval(skb->tstamp);
 		else
 			do_gettimeofday(&tv);
@@ -750,7 +759,13 @@
 		h.h2->tp_snaplen = snaplen;
 		h.h2->tp_mac = macoff;
 		h.h2->tp_net = netoff;
-		if (skb->tstamp.tv64)
+		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
+				&& shhwtstamps->syststamp.tv64)
+			ts = ktime_to_timespec(shhwtstamps->syststamp);
+		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
+				&& shhwtstamps->hwtstamp.tv64)
+			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
+		else if (skb->tstamp.tv64)
 			ts = ktime_to_timespec(skb->tstamp);
 		else
 			getnstimeofday(&ts);
@@ -2027,6 +2042,18 @@
 		po->has_vnet_hdr = !!val;
 		return 0;
 	}
+	case PACKET_TIMESTAMP:
+	{
+		int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->tp_tstamp = val;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -2119,6 +2146,12 @@
 		val = po->tp_loss;
 		data = &val;
 		break;
+	case PACKET_TIMESTAMP:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = po->tp_tstamp;
+		data = &val;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
--- a/Documentation/networking/packet_mmap.txt	2010-05-18 17:24:18.000000000 -0500
+++ b/Documentation/networking/packet_mmap.txt	2010-05-21 14:39:48.000000000 -0500
@@ -493,6 +493,32 @@
     pfd.events = POLLOUT;
     retval = poll(&pfd, 1, timeout);
 
+-------------------------------------------------------------------------------
++ PACKET_TIMESTAMP
+-------------------------------------------------------------------------------
+
+The PACKET_TIMESTAMP setting determines the source of the timestamp in
+the packet meta information.  If your NIC is capable of timestamping
+packets in hardware, you can request those hardware timestamps to used.
+Note: you may need to enable the generation of hardware timestamps with
+SIOCSHWTSTAMP.
+
+PACKET_TIMESTAMP accepts the same integer bit field as
+SO_TIMESTAMPING.  However, only the SOF_TIMESTAMPING_SYS_HARDWARE
+and SOF_TIMESTAMPING_RAW_HARDWARE values are recognized by
+PACKET_TIMESTAMP.  SOF_TIMESTAMPING_SYS_HARDWARE takes precedence over
+SOF_TIMESTAMPING_RAW_HARDWARE if both bits are set.
+
+    int req = 0;
+    req |= SOF_TIMESTAMPING_SYS_HARDWARE;
+    setsockopt(fd, SOL_PACKET, PACKET_TIMESTAMP, (void *) &req, sizeof(req))
+
+If PACKET_TIMESTAMP is not set, a software timestamp generated inside
+the networking stack is used (the behavior before this setting was added).
+
+See include/linux/net_tstamp.h and Documentation/networking/timestamping
+for more information on hardware timestamps.
+
 --------------------------------------------------------------------------------
 + THANKS
 --------------------------------------------------------------------------------
