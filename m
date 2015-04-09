From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 9 Apr 2015 11:08:03 -0700
Message-ID: <1428602883.4720.31.camel@prashant>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	 <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <21796.6843.983774.271495@mariner.uk.xensource.com>
	 <21796.7755.270785.292996@mariner.uk.xensource.com>
	 <1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1428448976.4720.15.camel@prashant>
	 <21797.13348.524963.29127@mariner.uk.xensource.com>
	 <1428543798.4720.20.camel@prashant>
	 <21798.24161.922394.539733@mariner.uk.xensource.com>
	 <1428595851.4720.22.camel@prashant>
	 <21798.44949.156680.399387@mariner.uk.xensource.com>
	 <21798.46590.928152.666550@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-cbhP/K6T43a0doWnXfKU"
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:55067 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932647AbbDISbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:31:38 -0400
In-Reply-To: <21798.46590.928152.666550@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-cbhP/K6T43a0doWnXfKU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2015-04-09 at 18:25 +0100, Ian Jackson wrote:

> root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
> NIC statistics:
>      rx_octets: 8196868
>      rx_ucast_packets: 633
>      rx_mcast_packets: 1
>      rx_bcast_packets: 123789
>      tx_octets: 42854
>      tx_ucast_packets: 9
>      tx_mcast_packets: 8
>      tx_bcast_packets: 603
> root@bedbug:~# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
>           inet addr:10.80.249.102  Bcast:10.80.251.255
>           Mask:255.255.252.0
>           inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:124774 errors:0 dropped:88921 overruns:0 frame:0
>           TX packets:620 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:8222158 (7.8 MiB)  TX bytes:42854 (41.8 KiB)
>           Interrupt:17 
> 
> root@bedbug:~#
> 
> It appears therefore that packets are being corrupted on the receive
> path, and the kernel then drops them (as misaddressed).
> 
thanks for the repo, the RX drop counter is updated at few places in the
driver. Please use the attached debug patch and provide the logs

--=-cbhP/K6T43a0doWnXfKU
Content-Disposition: attachment; filename="tg3_debug_1.patch"
Content-Type: text/x-patch; name="tg3_debug_1.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 777363eb77bddd52b9983c0025fed8b4ec151417 Mon Sep 17 00:00:00 2001
From: Prashant Sreedharan <prashant@broadcom.com>
Date: Thu, 9 Apr 2015 10:52:17 -0700
Subject: [stable: 3.14.37]tg3: debug_patch

---
 drivers/net/ethernet/broadcom/tg3.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8206113..5e2c9d6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6871,8 +6871,11 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 			skb_size = tg3_alloc_rx_data(tp, tpr, opaque_key,
 						    *post_ptr, &frag_size);
-			if (skb_size < 0)
+			if (skb_size < 0) {
+				netdev_err(tp->dev, "alloc_rx failure %x %x %x\n",
+					   skb_size, opaque_key, frag_size);
 				goto drop_it;
+			}
 
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
@@ -6886,6 +6889,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 			skb = build_skb(data, frag_size);
 			if (!skb) {
+				netdev_err(tp->dev, "build_skb failure %d\n",
+					   frag_size);
 				tg3_frag_free(frag_size != 0, data);
 				goto drop_it_no_recycle;
 			}
@@ -6896,8 +6901,10 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 			skb = netdev_alloc_skb(tp->dev,
 					       len + TG3_RAW_IP_ALIGN);
-			if (skb == NULL)
+			if (skb == NULL) {
+				netdev_err(tp->dev, "alloc_skb fail %d\n", len);
 				goto drop_it_no_recycle;
+			}
 
 			skb_reserve(skb, TG3_RAW_IP_ALIGN);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
@@ -6925,6 +6932,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		if (len > (tp->dev->mtu + ETH_HLEN) &&
 		    skb->protocol != htons(ETH_P_8021Q) &&
 		    skb->protocol != htons(ETH_P_8021AD)) {
+			netdev_err(tp->dev, "Proto %x %x\n",
+				   skb->protocol, len);
 			dev_kfree_skb(skb);
 			goto drop_it_no_recycle;
 		}
-- 
1.7.1


--=-cbhP/K6T43a0doWnXfKU--
