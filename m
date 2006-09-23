From: mostrows@earthlink.net
Subject: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Sat, 23 Sep 2006 12:30:23 -0500
Message-ID: <115903262344-git-send-email-mostrows@earthlink.net>
Reply-To: mostrows@earthlink.net
Cc: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:12245 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP
	id S1750766AbWIWR3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 13:29:32 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PPPoE must advertise the underlying device's MTU via the ppp channel
descriptor structure, as multilink functionality depends on it.

__pppoe_xmit must free any skb it allocates if there is an error
submitting the skb downstream.

Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>
---
 drivers/net/pppoe.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 475dc93..b4dc516 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -600,6 +600,7 @@ static int pppoe_connect(struct socket *
 		po->chan.hdrlen = (sizeof(struct pppoe_hdr) +
 				   dev->hard_header_len);
 
+		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr);
 		po->chan.private = sk;
 		po->chan.ops = &pppoe_chan_ops;
 
@@ -831,7 +832,7 @@ static int __pppoe_xmit(struct sock *sk,
 	struct pppoe_hdr *ph;
 	int headroom = skb_headroom(skb);
 	int data_len = skb->len;
-	struct sk_buff *skb2;
+	struct sk_buff *skb2 = NULL;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
@@ -887,6 +888,8 @@ static int __pppoe_xmit(struct sock *sk,
 	return 1;
 
 abort:
+	if (skb2)
+		kfree_skb(skb2);
 	return 0;
 }
 
-- 
1.4.1.1

