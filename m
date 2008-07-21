From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 1/1] qeth: fix 2.6.27 build
Date: Mon, 21 Jul 2008 14:48:36 +0200
Message-ID: <488485A4.9030305@trash.net>
References: <20080721115428.005485000@de.ibm.com> <20080721115507.647845000@de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405050204050300010504"
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, bunk@kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36648 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbYGUMsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 08:48:38 -0400
In-Reply-To: <20080721115507.647845000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010405050204050300010504
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

frank.blaschka@de.ibm.com wrote:

 >                        tag = (u16 *)(new_skb->data + 12);
 >                        *tag = __constant_htons(ETH_P_8021Q);
 >                        *(tag + 1) = htons(vlan_tx_tag_get(new_skb));
 >-                       VLAN_TX_SKB_CB(new_skb)->magic = 0;

The intention appears to be to invalidate the tag (its used
later on again if present), so that doesn't look correct.



--------------010405050204050300010504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

qeth: fix build error caused by VLAN changes

Adrian Bunk reports this build error:

CC      drivers/s390/net/qeth_l3_main.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->' (have 'int')
make[3]: *** [drivers/s390/net/qeth_l3_main.o] Error 1

The intention of the driver appears to be to invalidate the VLAN tag.
Change it to set skb->vlan_tci to zero, which has the same effect.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index b29afef..38de31b 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2651,7 +2651,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			tag = (u16 *)(new_skb->data + 12);
 			*tag = __constant_htons(ETH_P_8021Q);
 			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
-			VLAN_TX_SKB_CB(new_skb)->magic = 0;
+			new_skb->vlan_tci = 0;
 		}
 	}
 

--------------010405050204050300010504--
