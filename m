From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 2 Aug 2008 13:45:26 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8B37@rrsmsx501.amr.corp.intel.com>
References: <20080802133719.GB2970@ami.dom.local>
	<20080802162733.GA10059@ami.dom.local>
	<20080802.121815.167998262.davem@davemloft.net>
 <20080802.122251.94384264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"jarkao2@gmail.com" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:55686 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbYHBTpa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 15:45:30 -0400
In-Reply-To: <20080802.122251.94384264.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Still no luck.

I was able to reset the interfaces and change the MTU multiple times until eventually the system froze. No trace.

Emil

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Saturday, August 02, 2008 12:23 PM
To: jarkao2@gmail.com
Cc: Tantilov, Emil S; Kirsher, Jeffrey T; netdev@vger.kernel.org
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue

From: David Miller <davem@davemloft.net>
Date: Sat, 02 Aug 2008 12:18:15 -0700 (PDT)

> See my other emails, it isn't even necessary anyways.

Sorry, because some idiot took part of the conversation private
my follow-on fixup patch didn't make it to the list, here it is.

It goes on top of the original patch I sent out:

diff --git a/net/core/dev.c b/net/core/dev.c
index 69320a5..da7acac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1796,7 +1796,7 @@ gso:
        skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
        if (q->enqueue) {
-               spinlock_t *root_lock = qdisc_root_lock(q);
+               spinlock_t *root_lock = qdisc_lock(q);

                spin_lock(root_lock);

@@ -1995,7 +1995,7 @@ static void net_tx_action(struct softirq_action *h)
                        smp_mb__before_clear_bit();
                        clear_bit(__QDISC_STATE_SCHED, &q->state);

-                       root_lock = qdisc_root_lock(q);
+                       root_lock = qdisc_lock(q);
                        if (spin_trylock(root_lock)) {
                                qdisc_run(q);
                                spin_unlock(root_lock);
