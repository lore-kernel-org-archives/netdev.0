From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] [PPP] pppoe: Fill in header directly in __pppoe_xmit
Date: Fri, 31 Aug 2007 17:11:32 +0800
Message-ID: <E1IR2XM-0007QC-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757159AbXHaJLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:34 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XN-0004RM-4Y
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:33 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XM-0007QC-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:32 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] pppoe: Fill in header directly in __pppoe_xmit

This patch removes the hdr variable (which is copied into the skb)
and instead sets the header directly in the skb.

It also uses __skb_push instead of skb_push since we've just checked
using skb_cow for enough head room.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppoe.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 8818253..bac3654 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -848,19 +848,12 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
 	struct net_device *dev = po->pppoe_dev;
-	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
 	int data_len = skb->len;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
 
-	hdr.ver	= 1;
-	hdr.type = 1;
-	hdr.code = 0;
-	hdr.sid	= po->num;
-	hdr.length = htons(skb->len);
-
 	if (!dev)
 		goto abort;
 
@@ -870,12 +863,17 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	if (skb_cow(skb, sizeof(*ph) + dev->hard_header_len))
 		goto abort;
 
-	ph = (struct pppoe_hdr *) skb_push(skb, sizeof(struct pppoe_hdr));
-	memcpy(ph, &hdr, sizeof(struct pppoe_hdr));
-	skb->protocol = __constant_htons(ETH_P_PPP_SES);
-
+	__skb_push(skb, sizeof(*ph));
 	skb_reset_network_header(skb);
 
+	ph = pppoe_hdr(skb);
+	ph->ver	= 1;
+	ph->type = 1;
+	ph->code = 0;
+	ph->sid	= po->num;
+	ph->length = htons(data_len);
+
+	skb->protocol = __constant_htons(ETH_P_PPP_SES);
 	skb->dev = dev;
 
 	dev->hard_header(skb, dev, ETH_P_PPP_SES,
