From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 15:04:35 +0100
Message-ID: <46013B73.2060804@trash.net>
References: <1174471116.16343.10.camel@localhost> <4601047A.6050108@trash.net> <46010641.3000009@trash.net> <4601268D.7090003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040203020909030404070501"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43559 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbXCUOEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 10:04:43 -0400
In-Reply-To: <4601268D.7090003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040203020909030404070501
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>>Alexey just explained to me why we do need qdisc_tree_lock in private
>>mail. While dumping only the first skb is filled under the RTNL,
>>while filling further skbs we don't hold the RTNL anymore. So I will
>>probably have to drop that patch.
> 
> 
> 
> What we could do is replace the netlink cb_lock spinlock by a
> user-supplied mutex (supplied to netlink_kernel_create, rtnl_mutex
> in this case). That would put the entire dump under the rtnl and
> allow us to get rid of qdisc_tree_lock and avoid the need to take
> dev_base_lock during qdisc dumping. Same in other spots like
> rtnl_dump_ifinfo, inet_dump_ifaddr, ...


These (compile tested) patches demonstrate the idea. The first one
lets netlink_kernel_create users specify a mutex that should be
held during dump callbacks, the second one uses this for rtnetlink
and changes inet_dump_ifaddr for demonstration.

A complete patch would allow us to simplify locking in lots of
spots, all rtnetlink users currently need to implement extra
locking just for the dump functions, and a number of them
already get it wrong and seem to rely on the rtnl.

If there are no objections to this change I'm going to update
the second patch to include all rtnetlink users.


--------------040203020909030404070501
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

--------------040203020909030404070501
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NET_SCHED]: Fix ingress locking

Ingress queueing uses a seperate lock for serializing enqueue operations,
but fails to properly protect itself against concurrent changes to the
qdisc tree. Use queue_lock for now since the real fix it quite intrusive.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 11985909b582dc688b5a7c0f73f16244224116f4
tree 0ee26bec34053f6c9b5f905ffbc1437881428eeb
parent f1b9a0694552e18e7a43c292d21abe3b51dfcae2
author Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:11:56 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:11:56 +0100

 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cf71614..5984b55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1750,10 +1750,10 @@ static int ing_filter(struct sk_buff *sk
 
 		skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_INGRESS);
 
-		spin_lock(&dev->ingress_lock);
+		spin_lock(&dev->queue_lock);
 		if ((q = dev->qdisc_ingress) != NULL)
 			result = q->enqueue(skb, q);
-		spin_unlock(&dev->ingress_lock);
+		spin_unlock(&dev->queue_lock);
 
 	}
 

--------------040203020909030404070501--
