From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Mon, 14 Apr 2008 22:26:06 +0200
Message-ID: <20080414202605.GA6164@ami.dom.local>
References: <47FFAFFA.7070802@superclick.com> <20080413121031.GA5211@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Enrico Demarin <enrico@superclick.com>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:50005 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbYDNU2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 16:28:35 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1692137fgb.17
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 13:28:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080413121031.GA5211@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 02:10:31PM +0200, Jarek Poplawski wrote:
> Enrico Demarin wrote, On 04/11/2008 08:37 PM:
...
> > I stumbled by chance in a deadlock condition using HTB and the ingress 
> > scheduler at the same time.
...
> I think one of possible reasons could be a qdisc with the same
> handle and parent ids, like ingress, but I can't see how it could
> be referenced by your htb classes yet...

I think I got it! Enrico wrote to me he will not be able to test
before monday, but IMHO this fix is obvious here...

Regards,
Jarek P. 

--------------->

[NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop

TC_H_MAJ(parentid) for root classes is the same as for ingress, and if
ingress qdisc is created qdisc_lookup() returns its pointer (without
ingress NULL is returned). After this all qdisc_lookups give the same,
and we get endless loop. (I don't know how this could hide for so
long - it should trigger with every leaf class deleted if it's qdisc
isn't empty.)

After this fix qdisc_lookup() is omitted both for ingress and root
parents, but looking for root is only wasting a little time here...
Many thanks to Enrico Demarin for finding a test for catching this
bug, which probably bothered quite a lot of admins.
 

Reported-by: Enrico Demarin <enrico@superclick.com>,
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>

---

 net/sched/sch_api.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 15b91a9..c40773c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -386,6 +386,9 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 	if (n == 0)
 		return;
 	while ((parentid = sch->parent)) {
+		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
+			return;
+
 		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
 		if (sch == NULL) {
 			WARN_ON(parentid != TC_H_ROOT);
