From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix qdisc state in net_tx_action()
Date: Fri, 5 Sep 2008 08:29:15 +0000
Message-ID: <20080905082915.GA7320@ff.dom.local>
References: <200809050143.27998.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:28872 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbYIEI3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 04:29:24 -0400
Received: by ik-out-1112.google.com with SMTP id c28so220223ika.5
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 01:29:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809050143.27998.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-09-2008 00:43, Denys Fedoryshchenko wrote:
> I catch it!!!! And it is not ppp seems.
...
> Here is command that stuck. ifconfig, tc doesn't work, and seems 
> even sockets cannot be created (i cannot open new ssh connection 
> from this router, but i can ssh to existing socket).
> 
> I trigger this bug on latest git too.
> 
> 
>   PID  PPID USER     STAT   VSZ %MEM %CPU COMMAND
> 11593     1 root     R     2048  0.1 47.5 tc qdisc del dev ifb0 root
...

Great!!!!

Alas these logs are not very clear, but while browsing the code I
think I found one of possible reasons around this (but I'm not sure
this is all...).

Thanks,
Jarek P.

------------>

pkt_sched: Fix qdisc state in net_tx_action()

net_tx_action() can skip __QDISC_STATE_SCHED bit clearing while qdisc
is neither ran nor rescheduled, which may cause endless loop in
dev_deactivate().

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/core/dev.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 60c51f7..e719ed2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1991,8 +1991,13 @@ static void net_tx_action(struct softirq_action *h)
 				spin_unlock(root_lock);
 			} else {
 				if (!test_bit(__QDISC_STATE_DEACTIVATED,
-					      &q->state))
+					      &q->state)) {
 					__netif_reschedule(q);
+				} else {
+					smp_mb__before_clear_bit();
+					clear_bit(__QDISC_STATE_SCHED,
+						  &q->state);
+				}
 			}
 		}
 	}
