From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: cls_basic: fix NULL pointer dereference
Date: Tue, 20 Mar 2007 18:15:00 +0100
Message-ID: <46001694.9090402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003050402000302090805"
Cc: Linux Netdev List <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54680 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965309AbXCTRPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 13:15:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003050402000302090805
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

These two patches fix the cls_basic crash reported by Chris
Madden and the ingress locking problem.

Please apply, thanks.


--------------050003050402000302090805
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET_SCHED]: cls_basic: fix NULL pointer dereference

cls_basic doesn't allocate tp->root before it is linked into the
active classifier list, resulting in a NULL pointer dereference
when packets hit the classifier before its ->change function is
called.

Reported by Chris Madden <chris@reflexsecurity.com>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f1b9a0694552e18e7a43c292d21abe3b51dfcae2
tree f5ae39c1746fdc1ffbee6c1d90d035ee48ca4904
parent 0a14fe6e5efd0af0f9c6c01e0433445d615d0110
author Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:08:54 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:08:54 +0100

 net/sched/cls_basic.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index fad08e5..70fe36e 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -81,6 +81,13 @@ static void basic_put(struct tcf_proto *
 
 static int basic_init(struct tcf_proto *tp)
 {
+	struct basic_head *head;
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+	INIT_LIST_HEAD(&head->flist);
+	tp->root = head;
 	return 0;
 }
 
@@ -176,15 +183,6 @@ static int basic_change(struct tcf_proto
 	}
 
 	err = -ENOBUFS;
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

--------------050003050402000302090805--
