From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net-next] ibmveth: v1 calculate correct gso_size and set gso_type
Date: Wed, 26 Oct 2016 11:09:15 +1100
Message-ID: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        davem@davemloft.net, tom@herbertland.com, jarod@redhat.com,
        hofrat@osadl.org, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        mleitner@redhat.com, jmaxwell@redhat.com,
        Jon Maxwell <jmaxwell37@gmail.com>
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35824 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbcJZAJk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 20:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We recently encountered a bug where a few customers using ibmveth on the 
same LPAR hit an issue where a TCP session hung when large receive was
enabled. Closer analysis revealed that the session was stuck because the 
one side was advertising a zero window repeatedly.

We narrowed this down to the fact the ibmveth driver did not set gso_size 
which is translated by TCP into the MSS later up the stack. The MSS is 
used to calculate the TCP window size and as that was abnormally large, 
it was calculating a zero window, even although the sockets receive buffer 
was completely empty. 

We were able to reproduce this and worked with IBM to fix this. Thanks Tom 
and Marcelo for all your help and review on this.

The patch fixes both our internal reproduction tests and our customers tests.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 29c05d0..c51717e 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1182,6 +1182,8 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	int frames_processed = 0;
 	unsigned long lpar_rc;
 	struct iphdr *iph;
+	bool large_packet = 0;
+	u16 hdr_len = ETH_HLEN + sizeof(struct tcphdr);
 
 restart_poll:
 	while (frames_processed < budget) {
@@ -1236,10 +1238,28 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 						iph->check = 0;
 						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 						adapter->rx_large_packets++;
+						large_packet = 1;
 					}
 				}
 			}
 
+			if (skb->len > netdev->mtu) {
+				iph = (struct iphdr *)skb->data;
+				if (be16_to_cpu(skb->protocol) == ETH_P_IP &&
+				    iph->protocol == IPPROTO_TCP) {
+					hdr_len += sizeof(struct iphdr);
+					skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+					skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
+				} else if (be16_to_cpu(skb->protocol) == ETH_P_IPV6 &&
+					   iph->protocol == IPPROTO_TCP) {
+					hdr_len += sizeof(struct ipv6hdr);
+					skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+					skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
+				}
+				if (!large_packet)
+					adapter->rx_large_packets++;
+			}
+
 			napi_gro_receive(napi, skb);	/* send it up */
 
 			netdev->stats.rx_packets++;
-- 
1.8.3.1
