From: Patrick McHardy <kaber@trash.net>
Subject: Re: OOPS iproute2/tc/u32_destroy in 2.6.22-rc3-git6
Date: Sun, 03 Jun 2007 20:05:16 +0200
Message-ID: <466302DC.3030300@trash.net>
References: <20070603161814.q5x2jsq8dck4gcgw@bigboss.aws-it.at>	<4662D881.5080600@googlemail.com> <4662EE12.1080400@trash.net> <20070603194856.9eyyeukhesgw0owg@bigboss.aws-it.at>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030902040603010707060109"
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Strobl Anton <a.strobl@aws-it.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49711 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbXFCSHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 14:07:41 -0400
In-Reply-To: <20070603194856.9eyyeukhesgw0owg@bigboss.aws-it.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030902040603010707060109
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Strobl Anton wrote:
> Patch for sch_cbq.c works perfect - no more kernel panic!
> (sch_atm.c => im not able to test atm shaping, sorry)


Thanks Anton. Dave, please apply.


--------------030902040603010707060109
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Fix filter double free

cbq and atm destroy their filters twice when destroying inner classes
during qdisc destruction.

Reported-and-tested-by: Strobl Anton <a.strobl@aws-it.at>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ea1601c50bf23af25094511e2a9ce1b755ab9669
tree a4b8b9f3675606ff935d2422e26b24adf6c1ad3c
parent 1df4e603136d09c0aee78102a05fb960be3764bb
author Patrick McHardy <kaber@trash.net> Sun, 03 Jun 2007 18:35:09 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 03 Jun 2007 20:04:21 +0200

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
 

--------------030902040603010707060109--
