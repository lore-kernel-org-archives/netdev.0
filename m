From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 1/3] net: add skb_checksum_setup
Date: Wed, 8 Jan 2014 13:58:29 +0000
Message-ID: <1389189511-14568-2-git-send-email-paul.durrant@citrix.com>
References: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63640 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849AbaAHN6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 08:58:43 -0500
In-Reply-To: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a function to set up the partial checksum offset for IP
packets (and optionally re-calculate the pseudo-header checksum) into the
core network code.
The implementation was previously private and duplicated between xen-netback
and xen-netfront, however it is not xen-specific and is potentially useful
to any network driver.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |  271 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 272 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2a70cc..15b1003 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2940,6 +2940,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
 int skb_checksum_help(struct sk_buff *skb);
+int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847..cf9fc30 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -101,6 +101,7 @@
 #include <net/dst.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
+#include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
@@ -2281,6 +2282,276 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+static inline int skb_maybe_pull_tail(struct sk_buff *skb, unsigned int len,
+				      unsigned int max)
+{
+	if (skb_headlen(skb) >= len)
+		return 0;
+
+	/* If we need to pullup then pullup to the max, so we
+	 * won't need to do it again.
+	 */
+	if (max > skb->len)
+		max = skb->len;
+
+	if (__pskb_pull_tail(skb, max - skb_headlen(skb)) == NULL)
+		return -ENOMEM;
+
+	if (skb_headlen(skb) < len)
+		return -EPROTO;
+
+	return 0;
+}
+
+/* This value should be large enough to cover a tagged ethernet header plus
+ * maximally sized IP and TCP or UDP headers.
+ */
+#define MAX_IP_HDR_LEN 128
+
+static int skb_checksum_setup_ip(struct sk_buff *skb, bool recalculate)
+{
+	unsigned int off;
+	bool fragment;
+	int err;
+
+	fragment = false;
+
+	err = skb_maybe_pull_tail(skb,
+				  sizeof(struct iphdr),
+				  MAX_IP_HDR_LEN);
+	if (err < 0)
+		goto out;
+
+	if (ip_hdr(skb)->frag_off & htons(IP_OFFSET | IP_MF))
+		fragment = true;
+
+	off = ip_hdrlen(skb);
+
+	err = -EPROTO;
+
+	if (fragment)
+		goto out;
+
+	switch (ip_hdr(skb)->protocol) {
+	case IPPROTO_TCP:
+		err = skb_maybe_pull_tail(skb,
+					  off + sizeof(struct tcphdr),
+					  MAX_IP_HDR_LEN);
+		if (err < 0)
+			goto out;
+
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
+			goto out;
+		}
+
+		if (recalculate)
+			tcp_hdr(skb)->check =
+				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
+						   ip_hdr(skb)->daddr,
+						   skb->len - off,
+						   IPPROTO_TCP, 0);
+		break;
+	case IPPROTO_UDP:
+		err = skb_maybe_pull_tail(skb,
+					  off + sizeof(struct udphdr),
+					  MAX_IP_HDR_LEN);
+		if (err < 0)
+			goto out;
+
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
+			goto out;
+		}
+
+		if (recalculate)
+			udp_hdr(skb)->check =
+				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
+						   ip_hdr(skb)->daddr,
+						   skb->len - off,
+						   IPPROTO_UDP, 0);
+		break;
+	default:
+		goto out;
+	}
+
+	err = 0;
+
+out:
+	return err;
+}
+
+/* This value should be large enough to cover a tagged ethernet header plus
+ * an IPv6 header, all options, and a maximal TCP or UDP header.
+ */
+#define MAX_IPV6_HDR_LEN 256
+
+#define OPT_HDR(type, skb, off) \
+	(type *)(skb_network_header(skb) + (off))
+
+static int skb_checksum_setup_ipv6(struct sk_buff *skb, bool recalculate)
+{
+	int err;
+	u8 nexthdr;
+	unsigned int off;
+	unsigned int len;
+	bool fragment;
+	bool done;
+
+	fragment = false;
+	done = false;
+
+	off = sizeof(struct ipv6hdr);
+
+	err = skb_maybe_pull_tail(skb, off, MAX_IPV6_HDR_LEN);
+	if (err < 0)
+		goto out;
+
+	nexthdr = ipv6_hdr(skb)->nexthdr;
+
+	len = sizeof(struct ipv6hdr) + ntohs(ipv6_hdr(skb)->payload_len);
+	while (off <= len && !done) {
+		switch (nexthdr) {
+		case IPPROTO_DSTOPTS:
+		case IPPROTO_HOPOPTS:
+		case IPPROTO_ROUTING: {
+			struct ipv6_opt_hdr *hp;
+
+			err = skb_maybe_pull_tail(skb,
+						  off +
+						  sizeof(struct ipv6_opt_hdr),
+						  MAX_IPV6_HDR_LEN);
+			if (err < 0)
+				goto out;
+
+			hp = OPT_HDR(struct ipv6_opt_hdr, skb, off);
+			nexthdr = hp->nexthdr;
+			off += ipv6_optlen(hp);
+			break;
+		}
+		case IPPROTO_AH: {
+			struct ip_auth_hdr *hp;
+
+			err = skb_maybe_pull_tail(skb,
+						  off +
+						  sizeof(struct ip_auth_hdr),
+						  MAX_IPV6_HDR_LEN);
+			if (err < 0)
+				goto out;
+
+			hp = OPT_HDR(struct ip_auth_hdr, skb, off);
+			nexthdr = hp->nexthdr;
+			off += ipv6_authlen(hp);
+			break;
+		}
+		case IPPROTO_FRAGMENT: {
+			struct frag_hdr *hp;
+
+			err = skb_maybe_pull_tail(skb,
+						  off +
+						  sizeof(struct frag_hdr),
+						  MAX_IPV6_HDR_LEN);
+			if (err < 0)
+				goto out;
+
+			hp = OPT_HDR(struct frag_hdr, skb, off);
+
+			if (hp->frag_off & htons(IP6_OFFSET | IP6_MF))
+				fragment = true;
+
+			nexthdr = hp->nexthdr;
+			off += sizeof(struct frag_hdr);
+			break;
+		}
+		default:
+			done = true;
+			break;
+		}
+	}
+
+	err = -EPROTO;
+
+	if (!done || fragment)
+		goto out;
+
+	switch (nexthdr) {
+	case IPPROTO_TCP:
+		err = skb_maybe_pull_tail(skb,
+					  off + sizeof(struct tcphdr),
+					  MAX_IPV6_HDR_LEN);
+		if (err < 0)
+			goto out;
+
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
+			goto out;
+		}
+
+		if (recalculate)
+			tcp_hdr(skb)->check =
+				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						 &ipv6_hdr(skb)->daddr,
+						 skb->len - off,
+						 IPPROTO_TCP, 0);
+		break;
+	case IPPROTO_UDP:
+		err = skb_maybe_pull_tail(skb,
+					  off + sizeof(struct udphdr),
+					  MAX_IPV6_HDR_LEN);
+		if (err < 0)
+			goto out;
+
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
+			goto out;
+		}
+
+		if (recalculate)
+			udp_hdr(skb)->check =
+				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						 &ipv6_hdr(skb)->daddr,
+						 skb->len - off,
+						 IPPROTO_UDP, 0);
+		break;
+	default:
+		goto out;
+	}
+
+	err = 0;
+
+out:
+	return err;
+}
+
+/* Set up partial checksum offset and optionally recalculate pseudo header
+ * checksum.
+ */
+int skb_checksum_setup(struct sk_buff *skb, bool recalculate)
+{
+	int err;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		err = skb_checksum_setup_ip(skb, recalculate);
+		break;
+
+	case htons(ETH_P_IPV6):
+		err = skb_checksum_setup_ipv6(skb, recalculate);
+		break;
+
+	default:
+		err = -EPROTO;
+		break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(skb_checksum_setup);
+
 __be16 skb_network_protocol(struct sk_buff *skb)
 {
 	__be16 type = skb->protocol;
-- 
1.7.10.4
