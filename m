From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 4/8] vmxnet3: Provide required number of bytes in
	first SG buffer
Date: Fri, 14 Jan 2011 16:59:41 -0800
Message-ID: <20110115005941.1064.26929.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a performance enhancement fix. vmxnet3 device performs better when
provided with at least 54 bytes (ethernet 14 + IP 20+ TCP 20) in the first SG
buffer. For UDP packets driver provides lesser than that in first sg. This
change fixes the same. Also avoid the redundant pskb_may_pull() call.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index f47db1c..a1632a9 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -807,30 +807,25 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 				   skb_transport_header(skb))->doff * 4;
 		ctx->copy_size = ctx->eth_ip_hdr_size + ctx->l4_hdr_size;
 	} else {
-		unsigned int pull_size;
-
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			ctx->eth_ip_hdr_size = skb_checksum_start_offset(skb);
 
 			if (ctx->ipv4) {
 				struct iphdr *iph = (struct iphdr *)
 						    skb_network_header(skb);
-				if (iph->protocol == IPPROTO_TCP) {
-					pull_size = ctx->eth_ip_hdr_size +
-						    sizeof(struct tcphdr);
-
-					if (unlikely(!pskb_may_pull(skb,
-								pull_size))) {
-						goto err;
-					}
+				if (iph->protocol == IPPROTO_TCP)
 					ctx->l4_hdr_size = ((struct tcphdr *)
 					   skb_transport_header(skb))->doff * 4;
-				} else if (iph->protocol == IPPROTO_UDP) {
+				else if (iph->protocol == IPPROTO_UDP)
+					/*
+					 * Use tcp header size so that bytes to
+					 * be copied are more than required by
+					 * the device.
+					 */
 					ctx->l4_hdr_size =
-							sizeof(struct udphdr);
-				} else {
+							sizeof(struct tcphdr);
+				else
 					ctx->l4_hdr_size = 0;
-				}
 			} else {
 				/* for simplicity, don't copy L4 headers */
 				ctx->l4_hdr_size = 0;
