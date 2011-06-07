From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: cpu offline cause napi stall
Date: Tue, 07 Jun 2011 08:50:03 +0200
Message-ID: <1307429403.2642.77.camel@edumazet-laptop>
References: <20110601181253.GA2374@osiris.boeblingen.de.ibm.com>
	 <1306958592.3946.0.camel@edumazet-laptop>
	 <20110601204233.GA2410@osiris.boeblingen.de.ibm.com>
	 <20110606.145051.267562411413352856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60296 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1FGGuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 02:50:09 -0400
In-Reply-To: <20110606.145051.267562411413352856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Frank Blaschka reported :
<quote>
  During heavy network load we turn off/on cpus.
  Sometimes this causes a stall on the network device.
  Digging into the dump I found out following:

  napi is scheduled but does not run. From the I/O buffers
  and the napi state I see napi/rx_softirq processing has stopped
  because the budget was reached. napi stays in the
  softnet_data poll_list and the rx_softirq was raised again.

  I assume at this time the cpu offline comes in,
  the rx softirq is raised/moved to another cpu but napi stays in the
  poll_list of the softnet_data of the now offline cpu.

  Reviewing dev_cpu_callback (net/core/dev.c) I did not find the
  poll_list is transfered to the new cpu.
</quote>

This patch is a straightforward implementation of Frank suggestion :

Transfert poll_list and trigger NET_RX_SOFTIRQ on new cpu.

Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
---
While doing my tests on bnx2x adapter, I found patch was working ok,
but /proc/interrupts still increment interrupt count on my offlined
cpu... go figure...

 net/core/dev.c |    5 +++++
 1 files changed, 5 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9393078..095909c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6178,6 +6178,11 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		oldsd->output_queue = NULL;
 		oldsd->output_queue_tailp = &oldsd->output_queue;
 	}
+	/* Append NAPI poll list from offline CPU. */
+	if (!list_empty(&oldsd->poll_list)) {
+		list_splice_init(&oldsd->poll_list, &sd->poll_list);
+		raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	}
 
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();


