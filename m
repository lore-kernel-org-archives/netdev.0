From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:21:05 -0400
Message-ID: <1271424065.4606.31.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-sE4E3cilklutYmV5uwYt"
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:56422 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab0DPNVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:21:05 -0400
Received: by pzk42 with SMTP id 42so1885137pzk.4
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:21:05 -0700 (PDT)
In-Reply-To: <1271395106.16881.3645.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sE4E3cilklutYmV5uwYt
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2010-04-16 at 07:18 +0200, Eric Dumazet wrote:

> 
> A kernel module might do this, this could be integrated in perf bench so
> that we can regression tests upcoming kernels.

Perf would be good - but even softnet_stat cleaner than the the nasty
hack i use (attached) would be a good start; the ping with and without
rps gives me a ballpark number.

IPI is important to me because having tried it before it and failed
miserably. I was thinking the improvement may be due to hardware used
but i am having a hard time to get people to tell me what hardware they
used! I am old school - I need data;-> The RFS patch commit seems to
have more info but still vague, example: 
"The benefits of RFS are dependent on cache hierarchy, application
load, and other factors"
Also, what does a "simple" or "complex" benchmark mean?;->
I think it is only fair to get this info, no?

Please dont consider what i say above as being anti-RPS.
5 microsec extra latency is not bad if it can be amortized.
Unfortunately, the best traffic i could generate was < 20Kpps of
ping which still manages to get 1 IPI/packet on Nehalem. I am going
to write up some app (lots of cycles available tommorow). I still think
it is valueable.

cheers,
jamal

--=-sE4E3cilklutYmV5uwYt
Content-Disposition: attachment; filename="p1"
Content-Type: text/x-patch; name="p1"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..f8267fc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -224,6 +224,7 @@ struct netif_rx_stats {
 	unsigned time_squeeze;
 	unsigned cpu_collision;
 	unsigned received_rps;
+	unsigned ipi_rps;
 };
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
diff --git a/kernel/smp.c b/kernel/smp.c
index 9867b6b..8c5dcb7 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/smp.h>
 #include <linux/cpu.h>
+#include <linux/netdevice.h>
 
 static struct {
 	struct list_head	queue;
@@ -158,7 +159,10 @@ void generic_exec_single(int cpu, struct call_single_data *data, int wait)
 	 * equipped to do the right thing...
 	 */
 	if (ipi)
+{
 		arch_send_call_function_single_ipi(cpu);
+		__get_cpu_var(netdev_rx_stat).ipi_rps++;
+}
 
 	if (wait)
 		csd_lock_wait(data);
diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..0bbbdcf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3563,10 +3563,12 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
 {
 	struct netif_rx_stats *s = v;
 
-	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
+	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   s->total, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   s->cpu_collision, s->received_rps);
+		   s->cpu_collision, s->received_rps, s->ipi_rps);
+	s->ipi_rps = 0;
+	s->received_rps = 0;
 	return 0;
 }
 

--=-sE4E3cilklutYmV5uwYt--

