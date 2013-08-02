From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] htb: fix sign extension bug
Date: Thu, 1 Aug 2013 22:32:07 -0700
Message-ID: <20130801223207.2a9c69e9@nehalam.linuxnetplumber.net>
References: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
 <ktfdq8$882$1@ger.gmane.org>
 <20130801221936.24d4b31e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50967 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab3HBFcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 01:32:16 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so272099pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 22:32:15 -0700 (PDT)
In-Reply-To: <20130801221936.24d4b31e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When userspace passes a large priority value 
the assignment of the unsigned value hopt->prio
to  signed int cl->prio causes cl->prio to become negative and the
comparison is with TC_HTB_NUMPRIO is always false.

The result is that HTB crashes by referencing outside
the array when processing packets. With this patch the large value
wraps around like other values outside the normal range.

See: https://bugzilla.kernel.org/show_bug.cgi?id=60669

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/sch_htb.c	2013-06-20 09:22:46.489542435 -0700
+++ b/net/sched/sch_htb.c	2013-08-01 22:12:43.736307055 -0700
@@ -100,7 +100,7 @@ struct htb_class {
 	struct psched_ratecfg	ceil;
 	s64			buffer, cbuffer;/* token bucket depth/rate */
 	s64			mbuffer;	/* max wait time */
-	int			prio;		/* these two are used only by leaves... */
+	u32			prio;		/* these two are used only by leaves... */
 	int			quantum;	/* but stored for parent-to-leaf return */
 
 	struct tcf_proto	*filter_list;	/* class attached filters */
