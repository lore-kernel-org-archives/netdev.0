From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: [RFC v2: Patch 3/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Wed, 11 Mar 2009 16:53:53 +0800
Message-ID: <1236761633.2567.444.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:52370 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754600AbZCKIyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 04:54:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 3rd patch is totally example on ixgbe driver. Pls. doesn't apply
it. It's just for a demo.
=EF=BB=BF
NIC driver could use this capability like below steps:
1) Call =EF=BB=BFalloc_etherdev_rxtx_mq when probe the NIC to initiate;

In NAPI RX cleanup function:
2) Initiate a local var struct sk_buff_head skb_head;
3) get the cpu number by calling netif_rx_processing_cpu;
4) In the packet collection loop, just calls __skb_queue_tail(skb_head,=
 skb)
to add skb to the list;
5) Before exiting, calls raise_netif_irq to submit the skb list to the =
specific cpu.

We can add another step after 3) to check input_pkt_alien_queue.qlen. I=
f qlen is
bigger than =EF=BB=BFnetdev_max_backlog, exit the function instead of c=
ollecting packets,
so NIC hardware could drop packets. It's better than dropping packets b=
y =EF=BB=BFsoftware.

Below _SAMPLE_ patch (has some garbage codes) is against the latest IXG=
BE driver.

---

--- ixgbe-1.3.58_route/src/ixgbe_main.c	2009-03-03 08:09:35.000000000 +=
0800
+++ ixgbe-1.3.58_route_backlog/src/ixgbe_main.c	2009-03-10 08:01:06.000=
000000 +0800
@@ -443,7 +443,8 @@ static int __ixgbe_notify_dca(struct dev
 static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
                               struct sk_buff *skb, u8 status,
                               struct ixgbe_ring *ring,
-                              union ixgbe_adv_rx_desc *rx_desc)
+                              union ixgbe_adv_rx_desc *rx_desc,
+                              struct sk_buff_head *skb_head)
 {
 	int ret;
 	bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
@@ -469,7 +470,9 @@ static void ixgbe_receive_skb(struct ixg
 			if (adapter->vlgrp && is_vlan && (tag !=3D 0))
 				vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
 			else
-				netif_receive_skb(skb);
+				__skb_queue_tail(skb_head, skb);
+				//netif_rx_queue(skb, skb_head);
+				//YMZHANG netif_receive_skb(skb);
 #else
 			netif_receive_skb(skb);
 #endif
@@ -664,7 +667,8 @@ static void ixgbe_lro_ring_flush(struct=20
                                  struct ixgbe_adapter *adapter,
                                  struct ixgbe_lro_desc *lrod, u8 statu=
s,
                                  struct ixgbe_ring *rx_ring,
-                                 union ixgbe_adv_rx_desc *rx_desc)
+                                 union ixgbe_adv_rx_desc *rx_desc,
+                                 struct sk_buff_head *skb_head)
 {
 	struct iphdr *iph;
 	struct tcphdr *th;
@@ -701,7 +705,7 @@ static void ixgbe_lro_ring_flush(struct=20
 #ifdef NETIF_F_TSO
 	skb_shinfo(skb)->gso_size =3D lrod->mss;
 #endif
-	ixgbe_receive_skb(adapter, skb, status, rx_ring, rx_desc);
+	ixgbe_receive_skb(adapter, skb, status, rx_ring, rx_desc, skb_head);
=20
 	netdev->last_rx =3D jiffies;
 	lro_data->stats.coal +=3D lrod->append_cnt + 1;
@@ -718,14 +722,15 @@ static void ixgbe_lro_ring_flush(struct=20
 static void ixgbe_lro_ring_flush_all(struct ixgbe_lro_list *lrolist,
                                      struct ixgbe_adapter *adapter, u8=
 status,
                                      struct ixgbe_ring *rx_ring,
-                                     union ixgbe_adv_rx_desc *rx_desc)
+                                     union ixgbe_adv_rx_desc *rx_desc,
+                                     struct sk_buff_head *skb_head)
 {
 	struct ixgbe_lro_desc *lrod;
 	struct hlist_node *node, *node2;
=20
 	hlist_for_each_entry_safe(lrod, node, node2, &lrolist->active, lro_no=
de)
 		ixgbe_lro_ring_flush(lrolist, adapter, lrod, status, rx_ring,
-		                     rx_desc);
+		                     rx_desc, skb_head);
 }
=20
 /*
@@ -855,14 +860,14 @@ static int ixgbe_lro_ring_queue(struct i
=20
 			if (!header_ok) {
 				ixgbe_lro_ring_flush(lrolist, adapter, lrod,
-				                     status, rx_ring, rx_desc);
+				                     status, rx_ring, rx_desc, skb_head);
 				return -1;
 			}
=20
 			if (seq !=3D lrod->next_seq) {
 				/* out of order packet */
 				ixgbe_lro_ring_flush(lrolist, adapter, lrod,
-				                     status, rx_ring, rx_desc);
+				                     status, rx_ring, rx_desc, skb_head);
 				return -1;
 			}
=20
@@ -872,7 +877,7 @@ static int ixgbe_lro_ring_queue(struct i
 				if (lrod->tsval > tsval || *(ts_ptr + 2) =3D=3D 0) {
 					ixgbe_lro_ring_flush(lrolist, adapter,
 					                     lrod, status,
-					                     rx_ring, rx_desc);
+					                     rx_ring, rx_desc, skb_head);
 					return -1;
 				}
 				lrod->tsval =3D tsval;
@@ -911,13 +916,13 @@ static int ixgbe_lro_ring_queue(struct i
 				(struct tcphdr *)(lro_skb->data + sizeof(*iph));
 				header_th->psh |=3D th->psh;
 				ixgbe_lro_ring_flush(lrolist, adapter, lrod,
-				                     status, rx_ring, rx_desc);
+				                     status, rx_ring, rx_desc, skb_head);
 				return 0;
 			}
=20
 			if (lrod->append_cnt >=3D lro_data->max)
 				ixgbe_lro_ring_flush(lrolist, adapter, lrod,
-				                     status, rx_ring, rx_desc);
+				                     status, rx_ring, rx_desc, skb_head);
=20
 			return 0;
 		} /*End of if*/
@@ -1001,13 +1006,14 @@ static void ixgbe_lro_ring_init(struct i
=20
 #endif /* IXGBE_NO_LRO */
=20
+
 #ifdef CONFIG_IXGBE_NAPI
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-                               struct ixgbe_ring *rx_ring,
-                               int *work_done, int work_to_do)
+		struct ixgbe_ring *rx_ring,
+		int *work_done, int work_to_do)
 #else
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-                               struct ixgbe_ring *rx_ring)
+		struct ixgbe_ring *rx_ring)
 #endif
 {
 	struct pci_dev *pdev =3D adapter->pdev;
@@ -1019,12 +1025,17 @@ static bool ixgbe_clean_rx_irq(struct ix
 	u16 hdr_info;
 	bool cleaned =3D false;
 	int cleaned_count =3D 0;
+	struct sk_buff_head skb_head;
+	int cpu =3D netif_rx_processing_cpu(adapter->netdev, rx_ring->queue_i=
ndex);
+
 #ifndef CONFIG_IXGBE_NAPI
 	int work_to_do =3D rx_ring->work_limit, local_work_done =3D 0;
 	int *work_done =3D &local_work_done;
 #endif
 	unsigned int total_rx_bytes =3D 0, total_rx_packets =3D 0;
=20
+	skb_queue_head_init(&skb_head);
+
 	i =3D rx_ring->next_to_clean;
 	rx_desc =3D IXGBE_RX_DESC_ADV(*rx_ring, i);
 	staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
@@ -1135,7 +1146,7 @@ static bool ixgbe_clean_rx_irq(struct ix
 			goto next_desc;
 		}
 #endif
-		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
+		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc, &skb_head=
);
 		adapter->netdev->last_rx =3D jiffies;
=20
 next_desc:
@@ -1157,7 +1168,7 @@ next_desc:
 	rx_ring->next_to_clean =3D i;
 #ifndef IXGBE_NO_LRO
 	ixgbe_lro_ring_flush_all(rx_ring->lrolist, adapter,
-                            staterr, rx_ring, rx_desc);
+                            staterr, rx_ring, rx_desc, skb_head);
 #endif /* IXGBE_NO_LRO */
 	cleaned_count =3D IXGBE_DESC_UNUSED(rx_ring);
 #ifndef IXGBE_NO_INET_LRO
@@ -1180,6 +1191,9 @@ next_desc:
 	if (*work_done >=3D work_to_do)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, rx_ring->v_idx);
 #endif
+
+	raise_netif_irq(cpu, &skb_head);
+
 	return cleaned;
 }
=20
@@ -4103,6 +4117,8 @@ void ixgbe_napi_add_all(struct ixgbe_ada
 	for (q_idx =3D 0; q_idx < q_vectors; q_idx++) {
 		struct ixgbe_q_vector *q_vector =3D &adapter->q_vector[q_idx];
 		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
+		/*YMZ*/
+		//netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 32);
 	}
 }
=20
@@ -4998,7 +5014,7 @@ static int __devinit ixgbe_probe(struct=20
 	pci_set_master(pdev);
=20
 #ifdef HAVE_TX_MQ
-	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUE=
UES);
+	netdev =3D alloc_etherdev_rxtx_mq(sizeof(struct ixgbe_adapter), MAX_R=
X_QUEUES, MAX_TX_QUEUES);
 #else
 	netdev =3D alloc_etherdev(sizeof(struct ixgbe_adapter));
 #endif


