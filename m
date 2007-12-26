From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange Panic (Deadlock)
Date: Wed, 26 Dec 2007 19:54:11 +0100
Message-ID: <20071226185411.GA3061@ami.dom.local>
References: <476FCC41.8070202@bigtelecom.ru> <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru> <47701542.9010806@gmail.com> <4770C956.5040409@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:26344 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbXLZSwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 13:52:16 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1513585ugc.16
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 10:52:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4770C956.5040409@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 25, 2007 at 12:11:50PM +0300, Badalian Vyacheslav wrote:
...
> I have 4 machine. All platforms different.   All machine do 1 time in
> hour rebuild TC and IPTABLES rules.
> After it do
> echo START >> log.txt
> iptables-restore < xxx.txt
> tc qdisc del dev eth0 root
> tc qdisc del dev eth1 root
> tc -b new_rules.txt
> echo END >> log.txt
> 
> and its all that its doing.
> Bug always be between START and END
> All machines have above 300mbs traffic.
> I try turn off rebuilding rules on 1 PC and it work 3 week without reboot!

Hi Slavon,

After some looking around net schedulers' timers I think you could try
these 3 patches (2 in next messages). They should change 3 suspicious
(maybe only to me) places, but it's only guessing, to eliminate some
most nearby possibilities. These patches are independent, but of course
trying all at once should be quicker.
 
Thanks,
Jarek P.

[PATCH 1/3]
---

diff -Nurp linux-2.6.23.12-/net/sched/sch_generic.c linux-2.6.23.12+/net/sched/sch_generic.c
--- linux-2.6.23.12-/net/sched/sch_generic.c	2007-12-21 22:26:15.000000000 +0100
+++ linux-2.6.23.12+/net/sched/sch_generic.c	2007-12-26 18:39:20.000000000 +0100
@@ -251,10 +251,8 @@ static void dev_watchdog_up(struct net_d
 
 static void dev_watchdog_down(struct net_device *dev)
 {
-	netif_tx_lock_bh(dev);
-	if (del_timer(&dev->watchdog_timer))
+	if (del_timer_sync(&dev->watchdog_timer))
 		dev_put(dev);
-	netif_tx_unlock_bh(dev);
 }
 
 void netif_carrier_on(struct net_device *dev)
@@ -560,6 +558,8 @@ void dev_deactivate(struct net_device *d
 	struct Qdisc *qdisc;
 	struct sk_buff *skb;
 
+	dev_watchdog_down(dev);
+
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
 	dev->qdisc = &noop_qdisc;
@@ -572,8 +572,6 @@ void dev_deactivate(struct net_device *d
 
 	kfree_skb(skb);
 
-	dev_watchdog_down(dev);
-
 	/* Wait for outstanding dev_queue_xmit calls. */
 	synchronize_rcu();
 
