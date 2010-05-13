From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] TBF: stop qdisc infanticide
Date: Thu, 13 May 2010 09:17:17 -0700
Message-ID: <20100513091717.78bd7f1f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42344 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759347Ab0EMQRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 12:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several netem users have complained that when using TBF for rate control
that any change to TBF parameters destroys the child qdisc. A typical
use is to have a test that sets up netem + TBF then changes bandwidth
setting.  But every time the parameters of TBF are changed it destroys
the child qdisc, requiring reconfiguration. Other qdisc's like HTB
don't do this.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_tbf.c	2010-05-12 20:41:06.257006386 -0700
+++ b/net/sched/sch_tbf.c	2010-05-12 20:52:35.671216316 -0700
@@ -273,7 +273,11 @@ static int tbf_change(struct Qdisc* sch,
 	if (max_size < 0)
 		goto done;
 
-	if (qopt->limit > 0) {
+	if (q->qdisc) {
+		err = fifo_set_limit(q->qdisc, qopt->limit);
+		if (err)
+			goto done;
+	} else if (qopt->limit > 0) {
 		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
 		if (IS_ERR(child)) {
 			err = PTR_ERR(child);
