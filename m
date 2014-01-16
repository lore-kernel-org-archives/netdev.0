From: Harry Mason <harry.mason@smoothwall.net>
Subject: [PATCH] sch_htb: let skb->priority refer to non-leaf class
Date: Thu, 16 Jan 2014 14:45:19 +0000
Message-ID: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <hadi@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og107.obsmtp.com ([64.18.2.167]:38878 "HELO
	exprod7og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751389AbaAPOvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 09:51:18 -0500
Received: by mail-we0-f169.google.com with SMTP id u57so3322766wes.0
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 06:51:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the class in skb->priority is not a leaf, apply filters from the
selected class, not the qdisc. This allows netfilter or user space
to partially classify the packet and tc filters to finish it off.

Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
---
 net/sched/sch_htb.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 717b210..e50ab65 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -223,7 +223,13 @@ static struct htb_class *htb_classify(struct
sk_buff *skb, struct Qdisc *sch,
        return cl;

    *qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-   tcf = q->filter_list;
+
+   /* Start with inner filter chain if a non-leaf class is selected */
+   if (cl)
+       tcf = cl->filter_list;
+   else
+       tcf = q->filter_list;
+
    while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
        switch (result) {
-- 
1.7.10.4
