From: "Subash Abhinov Kasiviswanathan" <subashab@codeaurora.org>
Subject: [PATCH net] esp: Fix crash observed during device unregistration and decryption
Date: Wed, 16 Mar 2016 18:25:26 -0600
Message-ID: <008d01d17fe3$81c2b520$85481f60$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
	"'Steffen Klassert'" <steffen.klassert@secunet.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46097 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbcCQAZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 20:25:29 -0400
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A crash is observed when a decrypted packet is processed in receive path.
get_rps_cpus() tries to dereference the skb->dev fields but it appears
that the device is freed from the poison pattern.

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

Since the device appears to have been freed, the dereference of skb->dev in
get_rps_cpus() leads to an unhandled page fault exception.

Fix this by holding on to device reference when queueing packets
asynchronously and releasing the reference on call back return.

Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv4/esp4.c | 2 ++
 net/ipv6/esp6.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4779374..d482a96 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -380,6 +380,7 @@ static void esp_input_done(struct crypto_async_request
*base, int err)
 {
 	struct sk_buff *skb = base->data;
 
+	dev_put(skb->dev);
 	xfrm_input_resume(skb, esp_input_done2(skb, err));
 }
 
@@ -454,6 +455,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff
*skb)
 
 	esph = (struct ip_esp_hdr *)skb->data;
 
+	dev_hold(skb->dev);
 	aead_request_set_callback(req, 0, esp_input_done, skb);
 
 	/* For ESN we move the header forward by 4 bytes to
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 060a60b..12c491a 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -334,6 +334,7 @@ static void esp_input_done(struct crypto_async_request
*base, int err)
 {
 	struct sk_buff *skb = base->data;
 
+	dev_put(skb->dev);
 	xfrm_input_resume(skb, esp_input_done2(skb, err));
 }
 
@@ -408,6 +409,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff
*skb)
 
 	esph = (struct ip_esp_hdr *)skb->data;
 
+	dev_hold(skb->dev);
 	aead_request_set_callback(req, 0, esp_input_done, skb);
 
 	/* For ESN we move the header forward by 4 bytes to
-- 
