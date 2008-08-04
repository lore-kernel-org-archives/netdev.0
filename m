From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: Eliminate unnecessary forward delay
Date: Mon, 4 Aug 2008 10:35:34 -0700
Message-ID: <20080804103534.6b7896d9@extreme>
References: <20080804170439.GA13546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46005 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567AbYHDRfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 13:35:37 -0400
In-Reply-To: <20080804170439.GA13546@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Aug 2008 01:04:39 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi:
> 
> bridge: Eliminate unnecessary forward delay
> 
> When the forward delay is set to zero, we still delay the setting
> of the forwarding state by one or possibly two timers depending
> on whether STP is enabled.  This could either turn out to be
> instantaneous, or horribly slow depending on the load of the
> machine.
> 
> As there is nothing preventing us from enabling forwarding straight
> away, this patch eliminates this potential delay by executing the
> code directly if the forward delay is zero.
> 
> The effect of this problem is that immediately after the carrier
> comes on a port, the bridge will drop all packets received from
> that port until it enters forwarding mode, thus causing unnecessary
> packet loss.
> 
> Note that this patch doesn't fully remove the delay due to the
> link watcher.  We should also check the carrier state when we
> are about to drop an incoming packet because the port is disabled.
> But that's for another patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 

Same again, this time compile tested...

--- a/net/bridge/br_stp.c	2008-08-04 10:20:21.000000000 -0700
+++ b/net/bridge/br_stp.c	2008-08-04 10:29:26.000000000 -0700
@@ -368,14 +368,25 @@ static void br_make_blocking(struct net_
 /* called under bridge lock */
 static void br_make_forwarding(struct net_bridge_port *p)
 {
-	if (p->state == BR_STATE_BLOCKING) {
-		if (p->br->stp_enabled == BR_KERNEL_STP)
-			p->state = BR_STATE_LISTENING;
-		else
-			p->state = BR_STATE_LEARNING;
+	struct net_bridge *br = p->br;
 
-		br_log_state(p);
-		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);	}
+	if (p->state != BR_STATE_BLOCKING)
+		return;
+
+	if (br->forward_delay == 0) {
+		p->state = BR_STATE_FORWARDING;
+		br_topology_change_detection(br);
+		del_timer(&p->forward_delay_timer);
+	}
+	else if (p->br->stp_enabled == BR_KERNEL_STP)
+		p->state = BR_STATE_LISTENING;
+	else
+		p->state = BR_STATE_LEARNING;
+
+	br_log_state(p);
+
+	if (br->forward_delay != 0)
+		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);
 }
 
 /* called under bridge lock */
