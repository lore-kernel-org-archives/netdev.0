From: Michael Scott <michael.scott@linaro.org>
Subject: [PATCH] bluetooth: 6lowpan: fix use after free in chan_suspend/resume
Date: Tue, 28 Mar 2017 23:10:18 -0700
Message-ID: <20170329061018.4243-1-michael.scott@linaro.org>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        linux-bluetooth@vger.kernel.org, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Scott <michael.scott@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f176.google.com ([74.125.82.176]:36464 "EHLO
        mail-ot0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752930AbdC2GKs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:10:48 -0400
Received: by mail-ot0-f176.google.com with SMTP id t8so3817941otf.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 23:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A status field in the skb_cb struct was storing a channel status
based on channel suspend/resume events.  This stored status was
then used to return EAGAIN if there were packet sending issues
in snd_pkt().

The issue is that the skb has been freed by the time the callback
to 6lowpan's suspend/resume was called.  So, this generates a
"use after free" issue that was noticed while running kernel tests
with KASAN debug enabled.

Let's eliminate the status field entirely as we can use the channel
tx_credits to indicate whether we should return EAGAIN when handling
packets.

Signed-off-by: Michael Scott <michael.scott@linaro.org>
---
 net/bluetooth/6lowpan.c | 21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index d491529332f4..e27be3ca0a0c 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -38,7 +38,6 @@ struct skb_cb {
 	struct in6_addr addr;
 	struct in6_addr gw;
 	struct l2cap_chan *chan;
-	int status;
 };
 #define lowpan_cb(skb) ((struct skb_cb *)((skb)->cb))
 
@@ -528,7 +527,7 @@ static int send_pkt(struct l2cap_chan *chan, struct sk_buff *skb,
 	}
 
 	if (!err)
-		err = lowpan_cb(skb)->status;
+		err = (!chan->tx_credits ? -EAGAIN : 0);
 
 	if (err < 0) {
 		if (err == -EAGAIN)
@@ -964,26 +963,12 @@ static struct sk_buff *chan_alloc_skb_cb(struct l2cap_chan *chan,
 
 static void chan_suspend_cb(struct l2cap_chan *chan)
 {
-	struct sk_buff *skb = chan->data;
-
-	BT_DBG("chan %p conn %p skb %p", chan, chan->conn, skb);
-
-	if (!skb)
-		return;
-
-	lowpan_cb(skb)->status = -EAGAIN;
+	BT_DBG("chan %p suspend", chan);
 }
 
 static void chan_resume_cb(struct l2cap_chan *chan)
 {
-	struct sk_buff *skb = chan->data;
-
-	BT_DBG("chan %p conn %p skb %p", chan, chan->conn, skb);
-
-	if (!skb)
-		return;
-
-	lowpan_cb(skb)->status = 0;
+	BT_DBG("chan %p resume", chan);
 }
 
 static long chan_get_sndtimeo_cb(struct l2cap_chan *chan)
-- 
2.11.0
