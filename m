From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bridge: fix potential crash in __netdev_pick_tx()
Date: Thu, 09 Jul 2015 18:56:07 +0200
Message-ID: <1436460967.24939.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <559A3B9C.90905@oracle.com>
	 <1436179279.25714.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bob Liu <bob.liu@oracle.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33578 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbbGIQ4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 12:56:11 -0400
Received: by wgck11 with SMTP id k11so228987679wgc.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 09:56:10 -0700 (PDT)
In-Reply-To: <1436179279.25714.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
fixed an issue in normal forward path, caused by sender_cpu & napi_id
skb fields being an union.

Bridge is another point where skb can be forwarded, so we need
the same cure.

Bug triggers if packet was received on a NIC using skb_mark_napi_id()

Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Bob Liu <bob.liu@oracle.com>
Tested-by: Bob Liu <bob.liu@oracle.com>
---
 net/bridge/br_forward.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e97572b5d2cc..0ff6e1bbca91 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -42,6 +42,7 @@ int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
 	} else {
 		skb_push(skb, ETH_HLEN);
 		br_drop_fake_rtable(skb);
+		skb_sender_cpu_clear(skb);
 		dev_queue_xmit(skb);
 	}
 
