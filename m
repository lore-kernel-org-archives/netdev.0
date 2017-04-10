From: Ansis Atteka <aatteka@ovn.org>
Subject: [PATCH net] xfrm: calculate L4 checksums also for GSO case before encrypting packets
Date: Mon, 10 Apr 2017 11:42:07 -0700
Message-ID: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
Cc: Ansis Atteka <aatteka@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:52079 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdDJSn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 14:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, if L4 checksum calculation is done after encryption,
then all ESP packets end up being corrupted at the location
where pre-encryption L4 checksum field resides.

One of the ways to reproduce this bug is to have a VM with virtio_net
driver (UFO set to ON in the guest VM); and then encapsulate all guest's
Ethernet frames in GENEVE; and then further encrypt GENEVE with IPsec.
In this case following symptoms are observed:
1. If using ixgbe NIC, then the driver will also emit following
   warning message:
   ixgbe 0000:01:00.1: partial checksum but l4 proto=32!
2. Receiving VM will drop all the corrupted ESP packets, hence UDP iperf test
   with large packets will fail completely or TCP iperf will get ridiculously
   low performance because TCP window will never grow above MTU.

Signed-off-by: Ansis Atteka <aatteka@ovn.org>
---
 net/xfrm/xfrm_output.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8ba29fe..7ad7e5f 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -168,7 +168,8 @@ static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct sk_buff *segs;
+	struct sk_buff *segs, *nskb;
+	int err;
 
 	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
 	BUILD_BUG_ON(sizeof(*IP6CB(skb)) > SKB_SGO_CB_OFFSET);
@@ -180,21 +181,27 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 		return -EINVAL;
 
 	do {
-		struct sk_buff *nskb = segs->next;
-		int err;
+		nskb = segs->next;
 
 		segs->next = NULL;
-		err = xfrm_output2(net, sk, segs);
+		err = skb_checksum_help(segs);
+		if (unlikely(err)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
+			goto error;
+		}
 
+		err = xfrm_output2(net, sk, segs);
 		if (unlikely(err)) {
-			kfree_skb_list(nskb);
-			return err;
+			goto error;
 		}
 
 		segs = nskb;
 	} while (segs);
 
 	return 0;
+error:
+	kfree_skb_list(nskb);
+	return err;
 }
 
 int xfrm_output(struct sock *sk, struct sk_buff *skb)
-- 
1.9.1
