From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/6] virtio_net: introduce virtio_net_hdr_{from,to}_skb
Date: Wed,  8 Jun 2016 16:09:18 +0300
Message-ID: <1465391362-18437-3-git-send-email-rppt@linux.vnet.ibm.com>
References: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Mike Rapoport <mike.rapoport@gmail.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:20347 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1162039AbcFHNJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 09:09:43 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u58D9DiS133048
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2016 09:09:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23e9m3s4hp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 09:09:43 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 8 Jun 2016 14:09:40 +0100
In-Reply-To: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for conversion between virtio_net_hdr and skb GSO info is
duplicated at several places. Let's put it to a common place to allow
reuse.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/virtio_net.h | 101 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)
 create mode 100644 include/linux/virtio_net.h

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
new file mode 100644
index 0000000..1c912f8
--- /dev/null
+++ b/include/linux/virtio_net.h
@@ -0,0 +1,101 @@
+#ifndef _LINUX_VIRTIO_NET_H
+#define _LINUX_VIRTIO_NET_H
+
+#include <linux/if_vlan.h>
+#include <uapi/linux/virtio_net.h>
+
+static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
+					const struct virtio_net_hdr *hdr,
+					bool little_endian)
+{
+	unsigned short gso_type = 0;
+
+	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		case VIRTIO_NET_HDR_GSO_TCPV4:
+			gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV6:
+			gso_type = SKB_GSO_TCPV6;
+			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			gso_type = SKB_GSO_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			gso_type |= SKB_GSO_TCP_ECN;
+
+		if (hdr->gso_size == 0)
+			return -EINVAL;
+	}
+
+	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		u16 start = __virtio16_to_cpu(little_endian, hdr->csum_start);
+		u16 off = __virtio16_to_cpu(little_endian, hdr->csum_offset);
+
+		if (!skb_partial_csum_set(skb, start, off))
+			return -EINVAL;
+	}
+
+	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		u16 gso_size = __virtio16_to_cpu(little_endian, hdr->gso_size);
+
+		skb_shinfo(skb)->gso_size = gso_size;
+		skb_shinfo(skb)->gso_type = gso_type;
+
+		/* Header must be checked, and gso_segs computed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+
+	return 0;
+}
+
+static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
+					  struct virtio_net_hdr *hdr,
+					  bool little_endian)
+{
+	memset(hdr, 0, sizeof(*hdr));
+
+	if (skb_is_gso(skb)) {
+		struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+		/* This is a hint as to how much should be linear. */
+		hdr->hdr_len = __cpu_to_virtio16(little_endian,
+						 skb_headlen(skb));
+		hdr->gso_size = __cpu_to_virtio16(little_endian,
+						  sinfo->gso_size);
+		if (sinfo->gso_type & SKB_GSO_TCPV4)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+		else if (sinfo->gso_type & SKB_GSO_TCPV6)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+		else if (sinfo->gso_type & SKB_GSO_UDP)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
+		else
+			return -EINVAL;
+		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+			hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+	} else
+		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+		if (skb_vlan_tag_present(skb))
+			hdr->csum_start = __cpu_to_virtio16(little_endian,
+				skb_checksum_start_offset(skb) + VLAN_HLEN);
+		else
+			hdr->csum_start = __cpu_to_virtio16(little_endian,
+				skb_checksum_start_offset(skb));
+		hdr->csum_offset = __cpu_to_virtio16(little_endian,
+				skb->csum_offset);
+	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
+	} /* else everything is zero */
+
+	return 0;
+}
+
+#endif /* _LINUX_VIRTIO_BYTEORDER */
-- 
1.9.1
