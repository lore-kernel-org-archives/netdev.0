From: Patrick McHardy <kaber@trash.net>
Subject: Re: more... iproute2/htb/whatever critical bug ?
Date: Tue, 27 Mar 2007 17:10:36 +0200
Message-ID: <460933EC.9060908@trash.net>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <4602B96A.5000308@trash.net> <20070326182654.M24011@visp.net.lb>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070509000406030703050207"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60732 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbXC0PLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 11:11:48 -0400
In-Reply-To: <20070326182654.M24011@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070509000406030703050207
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Denys wrote:
> Mar 26 21:20:04 ROUTER-75 [  551.481081] BUG: unable to handle kernel NULL 
> pointer dereference
> Mar 26 21:20:04 ROUTER-75 at virtual address 00000074
> Mar 26 21:20:04 ROUTER-75 [  551.481187]  printing eip:
> Mar 26 21:20:04 ROUTER-75 [  551.481236] f8a11df1
> Mar 26 21:20:04 ROUTER-75 [  551.481289] *pde = 00000000
> Mar 26 21:20:04 ROUTER-75 [  551.481340] Oops: 0000 [#1]
> Mar 26 21:20:04 ROUTER-75 [  551.481384]
> Mar 26 21:20:04 ROUTER-75 SMP
> Mar 26 21:20:04 ROUTER-75
> Mar 26 21:20:04 ROUTER-75 [  551.481549] Modules linked in:
> .... long module list
> ar 26 21:20:04 ROUTER-75 [  551.485237] CPU:    0
> Mar 26 21:20:04 ROUTER-75 [  551.485238] EIP:    0060:[<f8a11df1>]    Not 
> tainted VLI
> Mar 26 21:20:04 ROUTER-75 [  551.485239] EFLAGS: 00010282   (2.6.20.3-build-
> 0001 #4)
> Mar 26 21:20:04 ROUTER-75 [  551.485438] EIP is at htb_qlen_notify+0x9/0x79 
> [sch_htb]


Oops, that seems to be my fault. Can you please try the attached patch?
To reproduce the problem you need to have packets queued while the
device is going down, so please make sure that is true by flooding
the device or something like that.


--------------070509000406030703050207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_htb: fix oops in htb_qlen_notify

htb_delete calls qdisc_tree_decrease_qlen after removing the class from
the class hash. This makes the ->get operation in qdisc_tree_decrease_qlen
fail, so it passes a NULL pointer to htb_qlen_notify, causing an oops.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 866d03284bf4ae694c8c12c1742dde1c5c06eca7
tree e43ac244d44b2422f0acb92dc9a48a66f92c2792
parent 703071b5b93d88d5acb0edd5b9dd86c69ad970f2
author Patrick McHardy <kaber@trash.net> Tue, 27 Mar 2007 17:07:50 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 27 Mar 2007 17:07:50 +0200

 net/sched/sch_htb.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 97cbb9a..3c3294d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1380,15 +1380,15 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	sch_tree_lock(sch);
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
-
 	if (!cl->level) {
 		qlen = cl->un.leaf.q->q.qlen;
 		qdisc_reset(cl->un.leaf.q);
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
+	/* delete from hash and active; remainder in destroy_class */
+	hlist_del_init(&cl->hlist);
+
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 

--------------070509000406030703050207--
