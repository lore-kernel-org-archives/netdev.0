From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] netpoll: Introduce netpoll_carrier_timeout kernel option
Date: Wed, 8 Jul 2009 05:00:30 +0400
Message-ID: <20090708010030.GA26331@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:44742 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755321AbZGHBAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 21:00:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHYs require longer timeouts for carrier detection, and
auto-negotiation process may take indefinite amount of time.

It may be inconvenient to force longer timeouts for sane PHYs,
so let's introduce a kernel command line option.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 Documentation/kernel-parameters.txt |    5 +++++
 net/core/netpoll.c                  |   11 ++++++++++-
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index d77fbd8..9eac5bd 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1531,6 +1531,11 @@ and is between 256 and 4096 characters. It is defined in the file
 			symbolic names: lapic and ioapic
 			Example: nmi_watchdog=2 or nmi_watchdog=panic,lapic
 
+	netpoll_carrier_timeout=
+			[NET] Specifies amount of time (in seconds) that
+			netpoll should wait for a carrier. By default netpoll
+			waits 4 seconds.
+
 	no387		[BUGS=X86-32] Tells the kernel to use the 387 maths
 			emulation library even if a 387 maths coprocessor
 			is present.
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9675f31..4371da2 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -50,6 +50,15 @@ static atomic_t trapped;
 static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
+static unsigned int carrier_timeout = 4;
+
+static int __init carrier_timeout_setup(char *str)
+{
+	carrier_timeout = simple_strtoul(str, NULL, 0);
+	return 1;
+}
+__setup("netpoll_carrier_timeout=", carrier_timeout_setup);
+
 static void queue_process(struct work_struct *work)
 {
 	struct netpoll_info *npinfo =
@@ -732,7 +741,7 @@ int netpoll_setup(struct netpoll *np)
 		}
 
 		atleast = jiffies + HZ/10;
-		atmost = jiffies + 4*HZ;
+		atmost = jiffies + carrier_timeout * HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
 				printk(KERN_NOTICE
-- 
1.6.3.3
