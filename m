From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Sun, 13 Apr 2008 14:10:31 +0200
Message-ID: <20080413121031.GA5211@ami.dom.local>
References: <47FFAFFA.7070802@superclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:35717 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbYDMMMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 08:12:40 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1140808fgb.17
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 05:12:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47FFAFFA.7070802@superclick.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Demarin wrote, On 04/11/2008 08:37 PM:

> Hi everyone,
> 
> I stumbled by chance in a deadlock condition using HTB and the ingress 
> scheduler at the same time.
> 
> - The bug seems to have been introduced in 2.6.23 and forward ( 2.6.22 
> works fine )
> - Tested up to  2.6.25-rc8
> 
> I found a temporary workaround  ( the ingress didnt have a reason to be 
> there in first place , just omitting it from the script avoids the 
> condition ), but it would be nice to have a proper fix. Let me know if 
> more data/testing is needed.

Hi,

It's a very nice test and results, but alas I don't have 3 boxes
around, so I wonder if you could try this debugging patch below?

I think one of possible reasons could be a qdisc with the same
handle and parent ids, like ingress, but I can't see how it could
be referenced by your htb classes yet...

Thanks,
Jarek P.

---

 net/sched/sch_api.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 15b91a9..de52b17 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -386,11 +386,18 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 	if (n == 0)
 		return;
 	while ((parentid = sch->parent)) {
+		struct Qdisc *sch_old = sch;
+
 		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
 		if (sch == NULL) {
 			WARN_ON(parentid != TC_H_ROOT);
 			return;
 		}
+		if (sch == sch_old) {
+			printk("qdisc loop: %p, %x\n", sch, sch->parent);
+			return;
+		}
+
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
