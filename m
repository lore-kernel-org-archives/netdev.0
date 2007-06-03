From: Patrick McHardy <kaber@trash.net>
Subject: Re: OOPS iproute2/tc/u32_destroy in 2.6.22-rc3-git6
Date: Sun, 03 Jun 2007 18:36:34 +0200
Message-ID: <4662EE12.1080400@trash.net>
References: <20070603161814.q5x2jsq8dck4gcgw@bigboss.aws-it.at> <4662D881.5080600@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020307050403080008000008"
Cc: Strobl Anton <a.strobl@aws-it.at>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47973 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbXFCQi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 12:38:57 -0400
In-Reply-To: <4662D881.5080600@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020307050403080008000008
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Michal Piotrowski wrote:
> Strobl Anton pisze:
> 
>> While trying to stop qdisc/cbq with command
>>
>>    tc qdisc del dev eth1 root
>>
>> EIP is at u32_destroy+0x52/0xd8 [cls_u32]


Please try this patch.


--------------020307050403080008000008
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Fix filter double free

cbq and atm destroy their filters twice when destroying inner classes
during qdisc destruction.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a2b6772f1b9524b8d3c67bee3b92956d44555b22
tree a4b8b9f3675606ff935d2422e26b24adf6c1ad3c
parent 1df4e603136d09c0aee78102a05fb960be3764bb
author Patrick McHardy <kaber@trash.net> Sun, 03 Jun 2007 18:35:09 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 03 Jun 2007 18:35:09 +0200

 net/sched/sch_atm.c |    1 +
 net/sched/sch_cbq.c |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index be7d299..d1c383f 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -599,6 +599,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	/* races ? */
 	while ((flow = p->flows)) {
 		tcf_destroy_chain(flow->filter_list);
+		flow->filter_list = NULL;
 		if (flow->ref > 1)
 			printk(KERN_ERR "atm_destroy: %p->ref = %d\n",flow,
 			    flow->ref);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index a294542..ee2d596 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1748,10 +1748,12 @@ cbq_destroy(struct Qdisc* sch)
 	 * classes from root to leafs which means that filters can still
 	 * be bound to classes which have been destroyed already. --TGR '04
 	 */
-	for (h = 0; h < 16; h++)
-		for (cl = q->classes[h]; cl; cl = cl->next)
+	for (h = 0; h < 16; h++) {
+		for (cl = q->classes[h]; cl; cl = cl->next) {
 			tcf_destroy_chain(cl->filter_list);
-
+			cl->filter_list = NULL;
+		}
+	}
 	for (h = 0; h < 16; h++) {
 		struct cbq_class *next;
 

--------------020307050403080008000008--
