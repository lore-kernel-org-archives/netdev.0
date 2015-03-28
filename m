From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Handling device free after a packet is passed to the
 network stack
Date: Fri, 27 Mar 2015 19:49:28 -0700
Message-ID: <1427510968.25985.159.camel@edumazet-glaptop2.roam.corp.google.com>
References: <f3c7672edb978d520f12d72cb41d1e4d.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36520 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbbC1Ctb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 22:49:31 -0400
Received: by pdcp1 with SMTP id p1so22387012pdc.3
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 19:49:31 -0700 (PDT)
In-Reply-To: <f3c7672edb978d520f12d72cb41d1e4d.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-27 at 19:57 +0000, subashab@codeaurora.org wrote:
> We have been coming across a couple of scenarios where the device is freed
> and the corresponding packets which were already queued up the stack
> encounter crashes when they find that contents of skb->dev are no longer
> valid.
> 
> Specifically, we have observed an instance where a cpu hotplug occurs
> along with the network driver module unloading. When the packets are being
> queued up the stack using netif_rx_ni from dev_cpu_callback, get_rps_cpus
> crashes as it encounters invalid data at skb->dev since it would have been
> freed.
> 
> We would like to know if the kernel provides some mechanisms to safeguard
> against such scenarios.

This is supposed to be handled in flush_backlog() (net/core/dev.c)

Maybe you hit some race condition in on_each_cpu().

Really, I do not think we have tested such stress conditions ever.

cpu hotplug was very unstable 2 years ago (last time I tried it, this
was constantly failing outside of networking land)

I would try following patch, although I am not sure what would prevent
dev_cpu_callback() being called too late.

diff --git a/net/core/dev.c b/net/core/dev.c
index a0408d497dae04e7caa145f05c915b058aa2d356..fa74887adfe10709bce55ccf1e34d65c6b7a8fba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7149,11 +7149,17 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
-		netif_rx_ni(skb);
+		if (skb->dev->reg_state != NETREG_REGISTERED)
+			kfree_skb(skb);
+		else
+			netif_rx_ni(skb);
 		input_queue_head_incr(oldsd);
 	}
 	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
-		netif_rx_ni(skb);
+		if (skb->dev->reg_state != NETREG_REGISTERED)
+			kfree_skb(skb);
+		else
+			netif_rx_ni(skb);
 		input_queue_head_incr(oldsd);
 	}
 
