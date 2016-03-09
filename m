From: subashab@codeaurora.org
Subject: [RFC] xfrm: netdevice unregistration during decryption
Date: Tue, 08 Mar 2016 19:16:23 -0700
Message-ID: <9fb4925ea87677df44c75c435efc329f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60426 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcCICQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:16:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am observing a crash originating from XFRM framework on a 3.18 ARM64
kernel.

get_rps_cpus tries to dereference the skb->dev fields but it appears 
that
the device is freed from the poison pattern.
The following is the crash call stack -

  55428.227024:   <2> [<ffffffc000af58ec>] get_rps_cpu+0x94/0x2f0
  55428.227027:   <2> [<ffffffc000af5f94>] netif_rx_internal+0x140/0x1cc
  55428.227030:   <2> [<ffffffc000af6094>] netif_rx+0x74/0x94
  55428.227035:   <2> [<ffffffc000bc0b6c>] xfrm_input+0x754/0x7d0
  55428.227038:   <2> [<ffffffc000bc0bf8>] xfrm_input_resume+0x10/0x1c
  55428.227044:   <2> [<ffffffc000ba6eb8>] esp_input_done+0x20/0x30
  55428.227056:   <2> [<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
  55428.227060:   <2> [<ffffffc0000b7324>] worker_thread+0x2f8/0x418
  55428.227064:   <2> [<ffffffc0000bb40c>] kthread+0xe0/0xec

-013|get_rps_cpu(
     |    dev = 0xFFFFFFC08B688000,
     |    skb = 0xFFFFFFC0C76AAC00 -> (
     |      dev = 0xFFFFFFC08B688000 -> (
     |        name = 
"......................................................
     |        name_hlist = (next = 0xAAAAAAAAAAAAAAAA, pprev = 
0xAAAAAAAAAAA

Following are the sequence of events observed -

1. Encrypted packet in receive path from netdevice queued to network 
stack

2. Encrypted packet queued for decryption (asynchronous)

static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
...
          aead_request_set_callback(req, 0, esp_input_done, skb);

3. Netdevice brought down and freed

4. Packet is decrypted and returned through callback in esp_input_done.

5. Packet is queued again for process in network stack using netif_rx.

The device appears to have been freed and as result, the dereference of
skb->dev in get_rps_cpus() leads to an unhandled page fault exception.

Would it make sense here to detect the device going away here using a
netdev notifier callback and free the packets after the asynchronous
callback returns.

Additionally, since the callback is from a worker thread, is it better
to use netif_rx_ni instead of netif_rx

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 85d1d47..f791128 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -351,7 +351,7 @@ resume:

         if (decaps) {
                 skb_dst_drop(skb);
-               netif_rx(skb);
+               netif_rx_ni(skb);
