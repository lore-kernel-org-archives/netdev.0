From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net v2 RESEND] xfrm: Fix crash observed during device unregistration and decryption
Date: Wed, 23 Mar 2016 22:39:50 -0600
Message-ID: <1458794390-19788-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	Jerome Stanislaus <jeromes@codeaurora.org>
To: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46962 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbcCXEnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 00:43:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A crash is observed when a decrypted packet is processed in receive
path. get_rps_cpus() tries to dereference the skb->dev fields but it
appears that the device is freed from the poison pattern.

[<ffffffc000af58ec>] get_rps_cpu+0x94/0x2f0
[<ffffffc000af5f94>] netif_rx_internal+0x140/0x1cc
[<ffffffc000af6094>] netif_rx+0x74/0x94
[<ffffffc000bc0b6c>] xfrm_input+0x754/0x7d0
[<ffffffc000bc0bf8>] xfrm_input_resume+0x10/0x1c
[<ffffffc000ba6eb8>] esp_input_done+0x20/0x30
[<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
[<ffffffc0000b7324>] worker_thread+0x2f8/0x418
[<ffffffc0000bb40c>] kthread+0xe0/0xec

-013|get_rps_cpu(
     |    dev = 0xFFFFFFC08B688000,
     |    skb = 0xFFFFFFC0C76AAC00 -> (
     |      dev = 0xFFFFFFC08B688000 -> (
     |        name =
"......................................................
     |        name_hlist = (next = 0xAAAAAAAAAAAAAAAA, pprev =
0xAAAAAAAAAAA

Following are the sequence of events observed -

- Encrypted packet in receive path from netdevice is queued
- Encrypted packet queued for decryption (asynchronous)
- Netdevice brought down and freed
- Packet is decrypted and returned through callback in esp_input_done
- Packet is queued again for process in network stack using netif_rx

Since the device appears to have been freed, the dereference of
skb->dev in get_rps_cpus() leads to an unhandled page fault
exception.

Fix this by holding on to device reference when queueing packets
asynchronously and releasing the reference on call back return.

v2: Make the change generic to xfrm as mentioned by Steffen and
update the title to xfrm

Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jerome Stanislaus <jeromes@codeaurora.org>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/xfrm/xfrm_input.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ad7f5b3..1c4ad47 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -292,12 +292,15 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		XFRM_SKB_CB(skb)->seq.input.hi = seq_hi;
 
 		skb_dst_force(skb);
+		dev_hold(skb->dev);
 
 		nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
 			return 0;
 resume:
+		dev_put(skb->dev);
+
 		spin_lock(&x->lock);
 		if (nexthdr <= 0) {
 			if (nexthdr == -EBADMSG) {
-- 
1.8.2.1
