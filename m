From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NET-2.6 1/1] qlcnic: limit skb frags for non tso
	packet
Date: Tue, 12 Apr 2011 00:19:41 -0700
Message-ID: <1302592781-13881-2-git-send-email-amit.salecha@qlogic.com>
References: <1302592781-13881-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anirban.chakraborty@qlogic.com, stable@kernel.org,
        ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1302592781-13881-1-git-send-email-amit.salecha@qlogic.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

Machines are getting deadlock in four node cluster environment.
All nodes are accessing (find /gfs2 -depth -print|cpio -ocv > /dev/null)
200 GB storage on a GFS2 filesystem.
This result in memory fragmentation and driver receives 18 frags for
1448 byte packets.
For non tso packet, fw drops the tx request, if it has >14 frags.

Fixing it by pulling extra frags.

Cc: stable@kernel.org
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index dc44564..b0dead0 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -99,6 +99,7 @@
 #define TX_UDPV6_PKT	0x0c
 
 /* Tx defines */
+#define QLCNIC_MAX_FRAGS_PER_TX	14
 #define MAX_TSO_HEADER_DESC	2
 #define MGMT_CMD_DESC_RESV	4
 #define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index cd88c7e..cb1a1ef 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2099,6 +2099,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct cmd_desc_type0 *hwdesc, *first_desc;
 	struct pci_dev *pdev;
 	struct ethhdr *phdr;
+	int delta = 0;
 	int i, k;
 
 	u32 producer;
@@ -2118,6 +2119,19 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
+	/* 14 frags supported for normal packet and
+	 * 32 frags supported for TSO packet
+	 */
+	if (!skb_is_gso(skb) && frag_count > QLCNIC_MAX_FRAGS_PER_TX) {
+
+		for (i = 0; i < (frag_count - QLCNIC_MAX_FRAGS_PER_TX); i++)
+			delta += skb_shinfo(skb)->frags[i].size;
+
+		if (!__pskb_pull_tail(skb, delta))
+			goto drop_packet;
+
+		frag_count = 1 + skb_shinfo(skb)->nr_frags;
+	}
 
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
-- 
1.7.3.2

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
