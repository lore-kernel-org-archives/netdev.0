From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 10:16:34 +0000
Message-ID: <20090227101634.GD4156@ff.dom.local>
References: <200902261745.28952.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:48644 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbZB0KQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 05:16:41 -0500
Received: by fk-out-0910.google.com with SMTP id f33so485099fkf.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 02:16:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902261745.28952.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2009 16:45, Denys Fedoryschenko wrote:
> Hi, triggered a bug in DRR seems
...
> [65298.391392] BUG: unable to handle kernel NULL pointer dereference at (null)
> [65298.391397] IP: [<ffffffffa0021700>] drr_change_class+0x39/0x2de [sch_drr]
...

Thanks for the report,
Jarek P.
----------->
pkt_sched: sch_drr: Fix oops in drr_change_class.

drr_change_class lacks a check for NULL of tca[TCA_OPTIONS], so oops
is possible.

Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_drr.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index f6b4fa9..e36e94a 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -66,11 +66,15 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 {
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl = (struct drr_class *)*arg;
+	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_DRR_MAX + 1];
 	u32 quantum;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_DRR_MAX, tca[TCA_OPTIONS], drr_policy);
+	if (!opt)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_DRR_MAX, opt, drr_policy);
 	if (err < 0)
 		return err;
 
