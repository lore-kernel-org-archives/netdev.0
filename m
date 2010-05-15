From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tbf: stop wanton destruction of children (v2)
Date: Fri, 14 May 2010 17:38:59 -0700
Message-ID: <20100514173859.30a85875@nehalam>
References: <20100513091717.78bd7f1f@nehalam>
	<4BEC2760.7080704@trash.net>
	<20100513092728.766ee059@nehalam>
	<4BEC2936.2060800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40177 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222Ab0EOAjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 20:39:06 -0400
In-Reply-To: <4BEC2936.2060800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several netem users use TBF for rate control. But every time the parameters
of TBF are changed it destroys the child qdisc, requiring reconfigation.
Better to just keep child qdisc and just notify it of changed limit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_tbf.c	2010-05-14 15:04:56.297095729 -0700
+++ b/net/sched/sch_tbf.c	2010-05-14 15:09:57.296733332 -0700
@@ -273,7 +273,11 @@ static int tbf_change(struct Qdisc* sch,
 	if (max_size < 0)
 		goto done;
 
-	if (qopt->limit > 0) {
+	if (q->qdisc != &noop_qdisc) {
+		err = fifo_set_limit(q->qdisc, qopt->limit);
+		if (err)
+			goto done;
+	} else if (qopt->limit > 0) {
 		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
 		if (IS_ERR(child)) {
 			err = PTR_ERR(child);
