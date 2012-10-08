From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] napi: limit GRO latency
Date: Mon, 8 Oct 2012 11:58:35 -0700
Message-ID: <20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	<CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	<1348769294.5093.1566.camel@edumazet-glaptop>
	<1348769990.5093.1584.camel@edumazet-glaptop>
	<CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	<1348841041.5093.2477.camel@edumazet-glaptop>
	<CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	<1349448747.21172.113.camel@edumazet-glaptop>
	<506F23F6.1060704@hp.com>
	<1349463634.21172.152.camel@edumazet-glaptop>
	<506F368F.3070403@hp.com>
	<1349467578.21172.178.camel@edumazet-glaptop>
	<50730217.6020206@hp.com>
	<1349715561.21172.3463.camel@edumazet-glaptop>
	<5073121B.2070300@hp.com>
	<1349718955.21172.3534.camel@edumazet-glaptop>
	<1349719006.21172.3537.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41366 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab2JHS7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 14:59:14 -0400
In-Reply-To: <1349719006.21172.3537.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Limit the latency of pending GRO in NAPI processing to 2*HZ.
When the system is under heavy network load, NAPI will go into
poll mode via soft irq, and only stay in the loop for
two jiffies. If this occurs, process the GRO pending list
to make sure and not delay outstanding TCP frames for too long.

Rearrange the exit path to get rid of unnecessary goto logic.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2012-10-08 09:21:27.466049785 -0700
+++ b/net/core/dev.c	2012-10-08 11:56:41.714618745 -0700
@@ -3937,8 +3937,16 @@ static void net_rx_action(struct softirq
 		 * Allow this to run for 2 jiffies since which will allow
 		 * an average latency of 1.5/HZ.
 		 */
-		if (unlikely(budget <= 0 || time_after(jiffies, time_limit)))
-			goto softnet_break;
+		if (unlikely(budget <= 0 || time_after(jiffies, time_limit))) {
+			/* Cleanup all pending GRO */
+
+			list_for_each_entry(n, &sd->poll_list, poll_list)
+				napi_gro_flush(n);
+
+			sd->time_squeeze++;
+			__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+			break;
+		}
 
 		local_irq_enable();
 
@@ -3987,7 +3995,6 @@ static void net_rx_action(struct softirq
 
 		netpoll_poll_unlock(have);
 	}
-out:
 	net_rps_action_and_irq_enable(sd);
 
 #ifdef CONFIG_NET_DMA
@@ -3997,13 +4004,6 @@ out:
 	 */
 	dma_issue_pending_all();
 #endif
-
-	return;
-
-softnet_break:
-	sd->time_squeeze++;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	goto out;
 }
 
 static gifconf_func_t *gifconf_list[NPROTO];
