From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 15:57:57 +0100
Message-ID: <45FFF675.8040501@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com> <45FFF455.80003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020309020807050808070608"
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Chris Madden <chris@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51781 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbXCTO6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 10:58:18 -0400
In-Reply-To: <45FFF455.80003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020309020807050808070608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Chris Madden wrote:
> 
>>Ok, I replaced ingress_lock with queue_lock in ing_filter and it died in
>>the same place.  Trace below (looks to be substantively the same)...
>>
>>If I am reading tc_ctl_tfilter correctly, we are adding our new
>>tcf_proto to the end of the list, and it is getting used before the
>>change function is getting executed on it.   Locking the ingress_lock in
>>qdisc_lock_tree ( in addition to the extant queue_lock )seems to have
>>the same effect; I can get  a traceback from that if its useful.
> 
> 
> 
> The problem is that some classifiers (like basic, fw and route)
> implement empty ->init functions, although fw and route properly
> deal with it in their classification functions. The ->init function
> should allocate and initalize tp->root, which basic fails to do.
> If you give me a few hours I'll cook up a patch for this.


Actually its only cls_basic thats broken, in case of route and fw
its intentional for backwards-compatibility.

Can you try this patch please?


--------------020309020807050808070608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index fad08e5..ed788d0 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -81,6 +81,13 @@ static void basic_put(struct tcf_proto *
 
 static int basic_init(struct tcf_proto *tp)
 {
+	struct basic_head *head;
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&head->flist);
+	tp->root = head;
 	return 0;
 }
 
@@ -175,16 +182,6 @@ static int basic_change(struct tcf_proto
 		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE-1]);
 	}
 
-	err = -ENOBUFS;
-	if (head == NULL) {
-		head = kzalloc(sizeof(*head), GFP_KERNEL);
-		if (head == NULL)
-			goto errout;
-
-		INIT_LIST_HEAD(&head->flist);
-		tp->root = head;
-	}
-
 	f = kzalloc(sizeof(*f), GFP_KERNEL);
 	if (f == NULL)
 		goto errout;

--------------020309020807050808070608--
