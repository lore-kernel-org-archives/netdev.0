From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Mon, 26 Nov 2012 08:34:37 -0800
Message-ID: <1353947677.7553.2.camel@edumazet-glaptop>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
	 <1353800616.2590.4562.camel@edumazet-glaptop>
	 <20121126100111.GA3728@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org,
	"Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39005 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab2KZQek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 11:34:40 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so8138864pbc.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 08:34:40 -0800 (PST)
In-Reply-To: <20121126100111.GA3728@mac.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 11:01 +0100, Tino Keitel wrote:
> On Sat, Nov 24, 2012 at 15:43:36 -0800, Eric Dumazet wrote:
> 
> [...]
> 
> > Hmm, I wonder if BQL makes a particular bug showing more often.
> > 
> > I see gianfar uses a very small watchdog_timeo of 1 second, while many
> > drivers use 5 seconds.
> > 
> > What happens if you change this to 5 seconds ?
> 
> I still got the trace and a failing ptp client.
> 

Thanks. Is this bug easy to trigger ?

I suspect a core issue and a race, likely to happen on your (non x86)
hardware

Could you add the following debugging patch ?

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index aefc150..a8859ec 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -117,7 +117,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	int ret = NETDEV_TX_BUSY;
 
 	/* And release qdisc */
-	spin_unlock(root_lock);
+//	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
@@ -125,7 +125,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_UNLOCK(dev, txq);
 
-	spin_lock(root_lock);
+//	spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
