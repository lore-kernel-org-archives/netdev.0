From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2 2/2] netpoll: Use skb_irq_freeable to make zap_completion_queue safe.
Date: Tue, 01 Apr 2014 12:21:02 -0700
Message-ID: <87lhvoj1pd.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	<1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
	<87lhw7inzg.fsf@nemi.mork.no>
	<1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>
	<87mwgbkttv.fsf_-_@x220.int.ebiederm.org>
	<8761mzktj9.fsf_-_@x220.int.ebiederm.org>
	<53357681.9050200@cogentembedded.com>
	<87wqf8j1rx.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?utf-8?Q?'Bj=C3=B8rn?= Mork' <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"stephen\@networkplumber.org" <stephen@networkplumber.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong\@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm\@selenic.com" <mpm@selenic.com>,
	"satyam.sharma\@gmail.com" <satyam.sharma@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33287 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbaDATVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:21:54 -0400
In-Reply-To: <87wqf8j1rx.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 01 Apr 2014 12:19:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace the test in zap_completion_queue to test when it is safe to
free skbs in hard irq context with skb_irq_freeable ensuring we only
free skbs when it is safe, and removing the possibility of subtle
problems.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ed7740f7a94d..e33937fb32a0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -270,7 +270,7 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor) {
+			if (!skb_irq_freeable(skb)) {
 				atomic_inc(&skb->users);
 				dev_kfree_skb_any(skb); /* put this one back */
 			} else {
-- 
1.7.10.4
