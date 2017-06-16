From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/2] net/core: use local_bh_disable() in netif_rx_ni()
Date: Fri, 16 Jun 2017 19:23:59 +0200
Message-ID: <20170616172400.10809-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:56426 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdFPRYF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 2004 [0] netif_rx_ni() gained a preempt_disable() section around
netif_rx() and its do_softirq() + testing for it. The do_softirq() part
is required because netif_rx() raises the softirq but does not invoke
it. The preempt_disable() is required to avoid running the BH in
parallel.
All this can be avoided be putting this into a local_bh_disable()ed
section. The local_bh_enable() part will invoke do_softirq() if
required.

[0] Make netif_rx_ni preempt-safe
    http://oss.sgi.com/projects/netdev/archive/2004-10/msg02211.html

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/core/dev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b8d6dd9e8b5c..b1f8a89322bd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3928,11 +3928,9 @@ int netif_rx_ni(struct sk_buff *skb)
=20
 	trace_netif_rx_ni_entry(skb);
=20
-	preempt_disable();
+	local_bh_disable();
 	err =3D netif_rx_internal(skb);
-	if (local_softirq_pending())
-		do_softirq();
-	preempt_enable();
+	local_bh_enable();
=20
 	return err;
 }
--=20
2.11.0
