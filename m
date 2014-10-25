From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Sat, 25 Oct 2014 01:44:04 +0100
Message-ID: <20141025004403.GC11289@acer.localdomain>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
 <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
 <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141025003644.GB11289@acer.localdomain>
 <CAHA+R7M3y=Mj_L3yL0UM41mfGa+go+Kq4wYga7D6epY3uq_yWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Terry Lam <vtlam@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43003 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933095AbaJYAoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:44:11 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7M3y=Mj_L3yL0UM41mfGa+go+Kq4wYga7D6epY3uq_yWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 05:38:48PM -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 5:36 PM, Patrick McHardy <kaber@trash.net> wrote:
> >
> > Again, the correct fix is to make qdisc_create_dflt() not call
> > qdisc_destroy() but clean up the qdisc manually as done in
> > qdisc_create().
> 
> I kindly wish you a good luck with fixing all callers of qdisc_create_dflt().
> Go ahead. :)

Here you go:

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fc04fe9..3a71e51 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -590,18 +590,21 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 	struct Qdisc *sch;
 
 	if (!try_module_get(ops->owner))
-		goto errout;
+		goto err1;
 
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
-		goto errout;
+		goto err2;
 	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
 
-	qdisc_destroy(sch);
-errout:
+	dev_put(sch->dev_queue->dev);
+	kfree((char *)sch - sch->padded);
+err2:
+	module_put(ops->owner);
+err1:
 	return NULL;
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
