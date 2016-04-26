From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-rfs: fix false sharing accessing
 sd->input_queue_head
Date: Tue, 26 Apr 2016 15:30:07 -0700
Message-ID: <1461709807.5535.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33781 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbcDZWaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 18:30:09 -0400
Received: by mail-pa0-f46.google.com with SMTP id zm5so12974122pac.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 15:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sd->input_queue_head is incremented for each processed packet
in process_backlog(), and read from other cpus performing
Out Of Order avoidance in get_rps_cpu()

Moving this field in a separate cache line keeps it mostly
hot for the cpu in process_backlog(), as other cpus will
only read it.

In a stress test, process_backlog() was consuming 6.80 % of cpu cycles,
and the patch reduced the cost to 0.65 %

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18d8394f2e5d..934ca866562d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2747,11 +2747,15 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 
 #ifdef CONFIG_RPS
-	/* Elements below can be accessed between CPUs for RPS */
+	/* input_queue_head should be written by cpu owning this struct,
+	 * and only read by other cpus. Worth using a cache line.
+	 */
+	unsigned int		input_queue_head ____cacheline_aligned_in_smp;
+
+	/* Elements below can be accessed between CPUs for RPS/RFS */
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 	struct softnet_data	*rps_ipi_next;
 	unsigned int		cpu;
-	unsigned int		input_queue_head;
 	unsigned int		input_queue_tail;
 #endif
 	unsigned int		dropped;
