From: Baptiste Covolato <baptiste@arista.com>
Subject: [PATCH net-next 1/3] net: Flush all skbs related to an unregistered device
Date: Tue, 19 May 2015 16:24:51 -0700
Message-ID: <1432077893-4431-2-git-send-email-baptiste@arista.com>
References: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	Eric Mowat <mowat@arista.com>,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35939 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbESXZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:25:19 -0400
Received: by pabts4 with SMTP id ts4so43561617pab.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:25:18 -0700 (PDT)
In-Reply-To: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update flush_backlog to flush all packets in the backlog queue belonging
to a device being unregistered. Accordingly on_each_cpu no longer needs
to pass a device to flush_backlog since it handles any device in the
NETREG_UNREGISTERED state.

Signed-off-by: Baptiste Covolato <baptiste@arista.com>
Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/core/dev.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0e7afef..db59d18 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4005,13 +4005,12 @@ EXPORT_SYMBOL(netif_receive_skb_sk);
  */
 static void flush_backlog(void *arg)
 {
-	struct net_device *dev = arg;
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	struct sk_buff *skb, *tmp;
 
 	rps_lock(sd);
 	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
-		if (skb->dev == dev) {
+		if (skb->dev->reg_state == NETREG_UNREGISTERED) {
 			__skb_unlink(skb, &sd->input_pkt_queue);
 			kfree_skb(skb);
 			input_queue_head_incr(sd);
@@ -4020,7 +4019,7 @@ static void flush_backlog(void *arg)
 	rps_unlock(sd);
 
 	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
-		if (skb->dev == dev) {
+		if (skb->dev->reg_state == NETREG_UNREGISTERED) {
 			__skb_unlink(skb, &sd->process_queue);
 			kfree_skb(skb);
 			input_queue_head_incr(sd);
@@ -6790,7 +6789,7 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
+		on_each_cpu(flush_backlog, NULL, 1);
 
 		netdev_wait_allrefs(dev);
 
-- 
2.4.1
