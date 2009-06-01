From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 01 Jun 2009 09:03:30 -0400
Message-ID: <1243861410.3966.268.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
	 <1243776293.3966.241.camel@dogo.mojatatu.com>
	 <20090531195557.GA2777@ami.dom.local>
	 <1243813216.3966.254.camel@dogo.mojatatu.com>
	 <20090601060638.GA4256@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5eLE3ZUo3X2gCi9XS07M"
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:50514 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbZFANEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 09:04:31 -0400
Received: by qyk36 with SMTP id 36so1573422qyk.33
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 06:04:32 -0700 (PDT)
In-Reply-To: <20090601060638.GA4256@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5eLE3ZUo3X2gCi9XS07M
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2009-06-01 at 06:06 +0000, Jarek Poplawski wrote:

> 
> But how about that (of course extremely rude) case "tc filter replace"
> is run with a new prio?


Jarek, sir, handyman extraordinaire, handsome devil, and lover of
kittens I humbly opine that we need to handle that case. 
How about going back to your original idea of defining tp_created? With
apologies to Minoru (he must be thinking we are lunatics by now), how
does the attached changed patch look to you?

Before you throw another rock, there is another issue which will be
caused by this rude misconfig:
"replace" really means "get rid of the old and add this new one".
But for the last 50 years we do not "get rid of the old". I cant think
of a clean way to do it sans shaving one of the kittens. One simple
thing to do is to printk a warning when detecting this error. I think
one needs to draw a line where bad config affects your life - in this
case i dont think it is worth big changes..

cheers,
jamal

--=-5eLE3ZUo3X2gCi9XS07M
Content-Disposition: attachment; filename=err-change-inited-2
Content-Type: text/x-patch; name=err-change-inited-2; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..08d98e8 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -135,6 +135,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	unsigned long cl;
 	unsigned long fh;
 	int err;
+	int tp_created = 0;
 
 	if (net != &init_net)
 		return -EINVAL;
@@ -266,10 +267,7 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
+		tp_created = 1;
 
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
@@ -314,8 +312,19 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
+	if (err == 0) {
+		if (tp_created) {
+			spin_lock_bh(root_lock);
+			tp->next = *back;
+			*back = tp;
+			spin_unlock_bh(root_lock);
+		}
 		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	} else {
+		if (tp_created) {
+			tcf_destroy(tp);
+		}
+	}
 
 errout:
 	if (cl)

--=-5eLE3ZUo3X2gCi9XS07M--

