From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28 3/4] myri10ge: Add Toeplitz-hashing related routines
Date: Fri, 12 Sep 2008 19:49:07 +0200
Message-ID: <48CAAB93.2070703@myri.com>
References: <48CAAAEF.1060205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1993 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753647AbYILRuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 13:50:12 -0400
In-Reply-To: <48CAAAEF.1060205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

myri10ge uses a Toeplitz hashing. Add the corresponding select_queue()
method without using it yet.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  165 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 165 insertions(+)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:24:15.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:24:42.000000000 +0200
@@ -250,6 +250,8 @@
 	u32 read_write_dma;
 	u32 link_changes;
 	u32 msg_enable;
+	u32 *toeplitz_hash_table;
+	u8 rss_key[32];
 };
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
@@ -2194,6 +2196,169 @@
 	return 0;
 }
 
+static int myri10ge_init_toeplitz(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int i, b, s, t, j;
+	int status;
+	u32 k[8];
+	u32 tmp;
+	u8 *key;
+
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RSS_KEY_OFFSET, &cmd, 0);
+	if (status != 0) {
+		printk(KERN_ERR
+		       "myri10ge: %s: failed to get rss key\n", mgp->dev->name);
+		return -EIO;
+	}
+	memcpy_fromio(mgp->rss_key, mgp->sram + cmd.data0,
+		      sizeof(mgp->rss_key));
+
+	mgp->toeplitz_hash_table = kmalloc(sizeof(u32) * 12 * 256, GFP_KERNEL);
+	if (mgp->toeplitz_hash_table == NULL)
+		return -ENOMEM;
+	key = (u8 *) mgp->rss_key;
+	t = 0;
+	for (b = 0; b < 12; b++) {
+		for (s = 0; s < 8; s++) {
+			/* Bits: b*8+s, ..., b*8+s+31 */
+			k[s] = 0;
+			for (j = 0; j < 32; j++) {
+				int bit = b * 8 + s + j;
+				bit = 0x1 & (key[bit / 8] >> (7 - (bit & 0x7)));
+				k[s] |= bit << (31 - j);
+			}
+		}
+
+		for (i = 0; i <= 0xff; i++) {
+			tmp = 0;
+			if (i & (1 << 7)) {
+				tmp ^= k[0];
+			}
+			if (i & (1 << 6)) {
+				tmp ^= k[1];
+			}
+			if (i & (1 << 5)) {
+				tmp ^= k[2];
+			}
+			if (i & (1 << 4)) {
+				tmp ^= k[3];
+			}
+			if (i & (1 << 3)) {
+				tmp ^= k[4];
+			}
+			if (i & (1 << 2)) {
+				tmp ^= k[5];
+			}
+			if (i & (1 << 1)) {
+				tmp ^= k[6];
+			}
+			if (i & (1 << 0)) {
+				tmp ^= k[7];
+			}
+			mgp->toeplitz_hash_table[t++] = tmp;
+		}
+	}
+	return 0;
+}
+
+static inline u16
+myri10ge_toeplitz_select_queue(struct net_device *dev, struct iphdr *ip)
+{
+	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct tcphdr *hdr;
+	u32 saddr, daddr;
+	u32 hash;
+	u32 *table = mgp->toeplitz_hash_table;
+	u16 src, dst;
+
+	/*
+	 * Note hashing order is reversed from how it is done
+	 * in the NIC, so as to generate the same hash value
+	 * for the connection to try to keep connections CPU local
+	 */
+
+	/* hash on IPv4 src/dst address */
+	saddr = ntohl(ip->saddr);
+	daddr = ntohl(ip->daddr);
+	hash = table[(256 * 0) + ((daddr >> 24) & 0xff)];
+	hash ^= table[(256 * 1) + ((daddr >> 16) & 0xff)];
+	hash ^= table[(256 * 2) + ((daddr >> 8) & 0xff)];
+	hash ^= table[(256 * 3) + ((daddr) & 0xff)];
+	hash ^= table[(256 * 4) + ((saddr >> 24) & 0xff)];
+	hash ^= table[(256 * 5) + ((saddr >> 16) & 0xff)];
+	hash ^= table[(256 * 6) + ((saddr >> 8) & 0xff)];
+	hash ^= table[(256 * 7) + ((saddr) & 0xff)];
+	/* hash on TCP port, if required */
+	if ((myri10ge_rss_hash & MXGEFW_RSS_HASH_TYPE_TCP_IPV4) &&
+	    ip->protocol == IPPROTO_TCP) {
+		hdr = (struct tcphdr *)(((u8 *) ip) + (ip->ihl << 2));
+		src = ntohs(hdr->source);
+		dst = ntohs(hdr->dest);
+
+		hash ^= table[(256 * 8) + ((dst >> 8) & 0xff)];
+		hash ^= table[(256 * 9) + ((dst) & 0xff)];
+		hash ^= table[(256 * 10) + ((src >> 8) & 0xff)];
+		hash ^= table[(256 * 11) + ((src) & 0xff)];
+	}
+	return (u16) (hash & (dev->real_num_tx_queues - 1));
+}
+
+static u16
+myri10ge_simple_select_queue(struct net_device *dev, struct iphdr *ip)
+{
+	struct udphdr *hdr;
+	u32 hash_val = 0;
+
+	if (ip->protocol != IPPROTO_TCP && ip->protocol != IPPROTO_UDP)
+		return (0);
+	hdr = (struct udphdr *)(((u8 *) ip) + (ip->ihl << 2));
+
+	/*
+	 * Use the second byte of the *destination* address for
+	 * MXGEFW_RSS_HASH_TYPE_SRC_PORT, so as to match NIC's hashing
+	 */
+	hash_val = ntohs(hdr->dest) & 0xff;
+	if (myri10ge_rss_hash == MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT)
+		hash_val += ntohs(hdr->source) & 0xff;
+
+	return (u16) (hash_val & (dev->real_num_tx_queues - 1));
+}
+
+static u16 myri10ge_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct iphdr *ip;
+	struct vlan_hdr *vh;
+
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		ip = ip_hdr(skb);
+	} else if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		vh = (struct vlan_hdr *)skb->data;
+		if ((vh->h_vlan_encapsulated_proto !=
+		     __constant_htons(ETH_P_IP)))
+			return 0;
+		ip = (struct iphdr *)skb->data + sizeof(*vh);
+	} else {
+		return 0;
+	}
+
+	switch (myri10ge_rss_hash) {
+	case MXGEFW_RSS_HASH_TYPE_IPV4:
+		/* fallthru */
+	case MXGEFW_RSS_HASH_TYPE_TCP_IPV4:
+		/* fallthru */
+	case (MXGEFW_RSS_HASH_TYPE_IPV4 | MXGEFW_RSS_HASH_TYPE_TCP_IPV4):
+		return (myri10ge_toeplitz_select_queue(dev, ip));
+		break;
+	case MXGEFW_RSS_HASH_TYPE_SRC_PORT:
+		/* fallthru */
+	case MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT:
+		return (myri10ge_simple_select_queue(dev, ip));
+	default:
+		return (0);
+	}
+}
+
 static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 {
 	struct myri10ge_cmd cmd;


