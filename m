From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 08:03:20 +0200
Message-ID: <20080614060320.GA18454@elte.hu>
References: <20080612.211959.52937006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753724AbYFNGD5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080612.211959.52937006.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> 1) Revert one of the deferred-accept TCP changes as it
>    has tons of bugs with no imminent cures and the feature
>    itself can wait to 2.6.27 if at all.
> 
>    This clears up an entry on the regression list.

FYI, that regression is not fully fixed yet - your revert differs from 
the one i tested (from Ilpo) by the delta patch below. Without the extra 
change below i got this net/sched/sch_generic.c warning, twice:

[  173.354049] NETDEV WATCHDOG: eth0: transmit timed out
[  173.354148] ------------[ cut here ]------------
[  173.354221] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x9a/0xec()
[  173.354298] Modules linked in:
[  173.354421] Pid: 13452, comm: cc1 Tainted: G        W 2.6.26-rc6-00273-g81ae43a-dirty #2573
[  173.354516]  [<c01250ca>] warn_on_slowpath+0x46/0x76
[  173.354641]  [<c011d428>] ? try_to_wake_up+0x1d6/0x1e0
[  173.354815]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
[  173.357370]  [<c011d43d>] ? default_wake_function+0xb/0xd
[  173.357370]  [<c014112a>] ? trace_hardirqs_off_caller+0x15/0xc9
[  173.357370]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
[  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
[  173.357370]  [<c0142b33>] ? trace_hardirqs_on_caller+0x16/0x15b
[  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
[  173.357370]  [<c06bb3c9>] ? _spin_unlock_irqrestore+0x5b/0x71
[  173.357370]  [<c0133d46>] ? __queue_work+0x2d/0x32
[  173.357370]  [<c0134023>] ? queue_work+0x50/0x72
[  173.357483]  [<c0134059>] ? schedule_work+0x14/0x16
[  173.357654]  [<c05c59b8>] dev_watchdog+0x9a/0xec
[  173.357783]  [<c012d456>] run_timer_softirq+0x13d/0x19d
[  173.357905]  [<c05c591e>] ? dev_watchdog+0x0/0xec
[  173.358073]  [<c05c591e>] ? dev_watchdog+0x0/0xec
[  173.360804]  [<c0129ad7>] __do_softirq+0xb2/0x15c
[  173.360804]  [<c0129a25>] ? __do_softirq+0x0/0x15c
[  173.360804]  [<c0105526>] do_softirq+0x84/0xe9
[  173.360804]  [<c0129996>] irq_exit+0x4b/0x88
[  173.360804]  [<c010ec7a>] smp_apic_timer_interrupt+0x73/0x81
[  173.360804]  [<c0103ddd>] apic_timer_interrupt+0x2d/0x34
[  173.360804]  =======================
[  173.360804] ---[ end trace a7919e7f17c0a725 ]---

full report can be found at:

   http://lkml.org/lkml/2008/6/13/224

once i added the patch below this new warning went away. I'm wondering 
what this difference is about and why your revert differs from Ilpo's. 
It might as well be the right thing to do and the warning just shows 
something latent.

	Ingo

--------------->
commit 3019ae9652fe44c099669e5dba116acad583cfcb
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Jun 13 23:09:28 2008 +0200

    tcp: revert the TCP-accept changes as per Ilpo's patch
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 045e799..ec83448 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -466,9 +466,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
-				    (inet_rsk(req)->acked ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req))) {
+				if ((req->retrans < thresh ||
+				     (inet_rsk(req)->acked && req->retrans < max_retries))
+				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
