From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 09:54:29 -0400
Message-ID: <1243605269.3966.28.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Xy8It6mvGD69AKR/HH1+"
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Jarek Poplawski <jarkao2@gmail.com>
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:63391 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758848AbZE2NzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 09:55:25 -0400
Received: by qw-out-2122.google.com with SMTP id 5so3950270qwd.37
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 06:55:27 -0700 (PDT)
In-Reply-To: <1243604796.3966.21.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Xy8It6mvGD69AKR/HH1+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Minoru,

I hate to do this to you after i made suggestions on how to
make the changes.... (as an adult i hate it when people do it to
me;->)
But sometimes code helps. So what i meant is the attached patch.
I havent even compiled it yet.
If it works, please submit it and add yourself as the author
(and a signed-off from me). Then we can revisit the init()
issue in cls_group..
You should also cc tgraf in your cls_grp config questions.

cheers,
jamal

On Fri, 2009-05-29 at 09:46 -0400, jamal wrote:
> 
> This is incorrect. tp may already exist and you dont want to destroy
> for failure to change its parameters. You also dont want to reattach
> an existing tp because it succeeded in parameter change. 
> So the soln is to check if this is a new tp and then do what you did
> above...
> Did that make sense?
> 
> cheers,
> jamal

--=-Xy8It6mvGD69AKR/HH1+
Content-Disposition: attachment; filename=err-change-inited
Content-Type: text/x-patch; name=err-change-inited; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..8760a48 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -266,11 +266,6 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
-
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
 
@@ -314,8 +309,21 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
+	if (err == 0) {
+		if (n->nlmsg_type == RTM_NEWTFILTER &&
+		    (n->nlmsg_flags&NLM_F_CREATE)) {
+			spin_lock_bh(root_lock);
+			tp->next = *back;
+			*back = tp;
+			spin_unlock_bh(root_lock);
+		}
 		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	} else {
+		if (n->nlmsg_type == RTM_NEWTFILTER &&
+		    (n->nlmsg_flags&NLM_F_CREATE)) {
+			tcf_destroy(tp);
+		}
+	}
 
 errout:
 	if (cl)

--=-Xy8It6mvGD69AKR/HH1+--

