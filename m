From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: remove time limit in process_backlog()
Date: Sat, 17 Apr 2010 16:17:02 +0200
Message-ID: <1271513822.16881.4734.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:56377 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab0DQORK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 10:17:10 -0400
Received: by bwz25 with SMTP id 25so4028493bwz.28
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 07:17:08 -0700 (PDT)
In-Reply-To: <z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- There is no point to enforce a time limit in process_backlog(), since
other napi instances dont follow same rule. We can exit after only one
packet processed...
The normal quota of 64 packets per napi instance should be the norm, and
net_rx_action() already has its own time limit.
Note : /proc/net/core/dev_weight can be used to tune this 64 default
value.

- Use DEFINE_PER_CPU_ALIGNED for softnet_data definition.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 7abf959..8092f01 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -264,7 +264,7 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	queue in the local softnet handler.
  */
 
-DEFINE_PER_CPU(struct softnet_data, softnet_data);
+DEFINE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 EXPORT_PER_CPU_SYMBOL(softnet_data);
 
 #ifdef CONFIG_LOCKDEP
@@ -3232,7 +3232,6 @@ static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
-	unsigned long start_time = jiffies;
 
 	napi->weight = weight_p;
 	do {
@@ -3252,7 +3251,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		local_irq_enable();
 
 		__netif_receive_skb(skb);
-	} while (++work < quota && jiffies == start_time);
+	} while (++work < quota);
 
 	return work;
 }


