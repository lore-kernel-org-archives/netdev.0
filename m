From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netem: fix loss generators
Date: Thu, 21 Nov 2013 17:54:19 -0800
Message-ID: <20131121175419.59059598@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, stefano.salsano@uniroma2.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:53260 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab3KVScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 13:32:08 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so1665042pbc.11
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 10:32:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch from developers of the alternative loss models, downloaded from:
   http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG

We found some bugs in our first implementation.
A first set of bugs is in the function loss_4state:
   In the case 1 of the switch statement in the if conditions we
    need to add clg->a4 to clg->a1, according to the model.
   In the case 3 of the switch statement we need to delete "return
    true" if the condition leads us in the state 1, because the state 1 is
    a good state.

A second set of bugs is in the function loss_gilb_ell
  In both cases of the switch statement we need to add the break
    statement, because the two cases are mutually exclusive.
  In the case 2, of the switch we change the direction of the inequality to
    net_random()>clg->a3, because clg->a3 is h in the GE model and when h
    is 0 all packets will be lost.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/sch_netem.c	2013-11-21 17:22:03.655649667 -0800
+++ b/net/sched/sch_netem.c	2013-11-21 17:24:46.438773795 -0800
@@ -215,10 +215,10 @@ static bool loss_4state(struct netem_sch
 		if (rnd < clg->a4) {
 			clg->state = 4;
 			return true;
-		} else if (clg->a4 < rnd && rnd < clg->a1) {
+		} else if (clg->a4 < rnd && rnd < clg->a1 + clg->a4) {
 			clg->state = 3;
 			return true;
-		} else if (clg->a1 < rnd)
+		} else if (clg->a1 + clg->a4 < rnd)
 			clg->state = 1;
 
 		break;
@@ -235,6 +235,7 @@ static bool loss_4state(struct netem_sch
 			clg->state = 2;
 		else if (clg->a3 < rnd && rnd < clg->a2 + clg->a3) {
 			clg->state = 1;
+			return true;
 		} else if (clg->a2 + clg->a3 < rnd) {
 			clg->state = 3;
 			return true;
@@ -268,11 +269,13 @@ static bool loss_gilb_ell(struct netem_s
 			clg->state = 2;
 		if (net_random() < clg->a4)
 			return true;
+		break;
 	case 2:
 		if (net_random() < clg->a2)
 			clg->state = 1;
-		if (clg->a3 > net_random())
+		if (net_random() > clg->a3)
 			return true;
+		break;
 	}
 
 	return false;
