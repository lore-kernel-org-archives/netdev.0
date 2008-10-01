From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] lib8390: Fix locking in ei_poll (poll controller)
Date: Wed, 1 Oct 2008 06:58:25 +0000
Message-ID: <20081001065824.GA11235@ff.dom.local>
References: <20080930101030.GA6290@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:1049 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbYJAG6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 02:58:31 -0400
Received: by nf-out-0910.google.com with SMTP id d3so167177nfc.21
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 23:58:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080930101030.GA6290@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


lib8390: Fix locking in ei_poll (poll controller)

This lockdep warning:
  =================================
  [ INFO: inconsistent lock state ]
  2.6.27-rc7 #3
  ---------------------------------
  inconsistent {in-softirq-W} -> {softirq-on-W} usage.
  syslogd/2474 [HC0[0]:SC0[0]:HE1:SE1] takes:
   (_xmit_ETHER#2){-+..}, at: [<c0265562>] netpoll_send_skb+0x132/0x190
  ...

is caused by unconditional local_irq_disable()/local_irq_enable() in
disable_irq_lockdep()/enable_irq_lockdep() used by __ei_poll(). Since
netconsole/netpoll always calls dev->poll_controller() with local irqs
disabled, disable_irq()/enable_irq() instead is safe and enough (like
e.g. in 3c509 or 8139xx drivers).

Reported-and-tested-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 drivers/net/lib8390.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 00d59ab..f80dcc1 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -530,9 +530,9 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void __ei_poll(struct net_device *dev)
 {
-	disable_irq_lockdep(dev->irq);
+	disable_irq(dev->irq);
 	__ei_interrupt(dev->irq, dev);
-	enable_irq_lockdep(dev->irq);
+	enable_irq(dev->irq);
 }
 #endif
 
