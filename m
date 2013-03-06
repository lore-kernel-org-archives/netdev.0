From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Tue, 05 Mar 2013 23:03:18 -0800
Message-ID: <1362553398.15793.168.camel@edumazet-glaptop>
References: <1362535067.15793.146.camel@edumazet-glaptop>
	 <20130305.210909.1826827522208936437.davem@davemloft.net>
	 <1362540509.15793.158.camel@edumazet-glaptop>
	 <20130305.233744.498353801662910535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:45824 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab3CFHDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 02:03:21 -0500
Received: by mail-ie0-f179.google.com with SMTP id k11so9049453iea.10
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 23:03:21 -0800 (PST)
In-Reply-To: <20130305.233744.498353801662910535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 23:37 -0500, David Miller wrote:

> Thanks for the explanation.
> 
> Since you haven't completely resolved the issues you were running into
> I'll target this to net-next for now.

Thanks David

An other issue is the spin_trylock() attempted in net_tx_action()

It seems we can miss a qdisc_run(), and have to wait the following
NET_TX softirq(s) to send more data. NET_RX being interleaved, we can
have to wait a long time (not mentioning other softirq handlers like
RCU ...)

I might be too tired right now, but cant see the reason of the trylock.

qdisc lock is already BH safe, so we should do a spinlock

I'll test the following patch tomorrow :

 net/core/dev.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a06a7a5..d5d4573 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3201,22 +3201,11 @@ static void net_tx_action(struct softirq_action *h)
 			head = head->next_sched;
 
 			root_lock = qdisc_lock(q);
-			if (spin_trylock(root_lock)) {
-				smp_mb__before_clear_bit();
-				clear_bit(__QDISC_STATE_SCHED,
-					  &q->state);
-				qdisc_run(q);
-				spin_unlock(root_lock);
-			} else {
-				if (!test_bit(__QDISC_STATE_DEACTIVATED,
-					      &q->state)) {
-					__netif_reschedule(q);
-				} else {
-					smp_mb__before_clear_bit();
-					clear_bit(__QDISC_STATE_SCHED,
-						  &q->state);
-				}
-			}
+			spin_lock(root_lock);
+			smp_mb__before_clear_bit();
+			clear_bit(__QDISC_STATE_SCHED, &q->state);
+			qdisc_run(q);
+			spin_unlock(root_lock);
 		}
 	}
 }
