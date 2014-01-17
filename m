From: Harry Mason <harry.mason@smoothwall.net>
Subject: [PATCH v3] sch_htb: let skb->priority refer to non-leaf class
Date: Fri, 17 Jan 2014 13:22:32 +0000
Message-ID: <1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
References: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>
		 <1389889520.31367.403.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
	 <52D927CD.4080403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og115.obsmtp.com ([64.18.2.217]:60568 "HELO
	exprod7og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751401AbaAQNWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:22:46 -0500
Received: by mail-wg0-f51.google.com with SMTP id z12so4422771wgg.6
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 05:22:44 -0800 (PST)
In-Reply-To: <52D927CD.4080403@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the class in skb->priority is not a leaf, apply filters from the
selected class, not the qdisc. This lets netfilter or user space
partially classify the packet.

Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
---

On Fri, 2014-01-17 at 16:53 +0400, Sergei Shtylyov wrote:
> On 17-01-2014 14:19, Harry Mason wrote:
> > +	if (cl) {
> > +		if (cl->level == 0)
> > +			return cl;
> > +		/* Start with inner filter chain if a non-leaf class is selected */
> > +		tcf = cl->filter_list;
> > +	} else
> > +		tcf = q->filter_list;
> 
>     There should be {} in the *else* arm, since it's in another arm of *if* 
> already -- see Documentation/CodingStyle.

Thanks, updated.

 net/sched/sch_htb.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 717b210..e9c8c08 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -219,11 +219,16 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if (skb->priority == sch->handle)
 		return HTB_DIRECT;	/* X:0 (direct flow) selected */
 	cl = htb_find(skb->priority, sch);
-	if (cl && cl->level == 0)
-		return cl;
+	if (cl) {
+		if (cl->level == 0)
+			return cl;
+		/* Start with inner filter chain if a non-leaf class is selected */
+		tcf = cl->filter_list;
+	} else {
+		tcf = q->filter_list;
+	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	tcf = q->filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-- 
1.7.10.4
