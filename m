From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: some tc commands fail on 2.6.29-rc6-git5, works on
	2.6.28.7
Date: Thu, 5 Mar 2009 00:34:58 +0100
Message-ID: <20090304233458.GA8303@ami.dom.local>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com> <20090301165729.8e08e1d7.akpm@linux-foundation.org> <49AC28FF.1040102@gmail.com> <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com> <1236135028.7883.44.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Dykstra <john.dykstra1@gmail.com>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:45780 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbZCDXff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 18:35:35 -0500
Content-Disposition: inline
In-Reply-To: <1236135028.7883.44.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 08:50:28PM -0600, John Dykstra wrote:
> On Tue, 2009-03-03 at 23:10 +0000, Joao Correia wrote:
> > I have confirmed again that the exact same commands (as on the
> > original message), work flawlessly on 2.6.28.7 without a hitch, and,
> > AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-git7
> > and it still fails like on git6.
> 
> I have also reproduced this on Linus' latest 2.6.29-rc6 tree, using tc
> version iproute2-ss071016 and a kernel config with all traffic control
> features enabled.
> 
> The error reported by tc comes from the kernel-level check added by:
> 
> 	commit c1b56878fb68e9c14070939ea4537ad4db79ffae
> 	Author: Stephen Hemminger <shemminger@vyatta.com>
> 	Date:   Tue Nov 25 21:14:06 2008 -0800
> 
>     	tc: policing requires a rate estimator
> 
>     Found that while trying average rate policing, it was possible to
>     request average rate policing without a rate estimator. This results
>     in no policing which is harmless but incorrect.
> 
>     Since policing could be setup in two steps, need to check
>     in the kernel.
> 
>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> I got the same error when using the tc version iproute2-ss090115 built
> this evening from the public git repository.
> 
>   -- John
> 

Very nice diagnose, thanks!
Jarek P.

PS: after upgrading iproute I couldn't reproduce this seemingly OK
test with older versions anymore...

------------------->
pkt_sched: act_police: Fix a rate estimator test.

A commit c1b56878fb68e9c14070939ea4537ad4db79ffae "tc: policing requires
a rate estimator" introduced a test which invalidates previously working
configs, based on examples from iproute2: doc/actions/actions-general.
This is too rigorous: a rate estimator is needed only when police's
"avrate" option is used.

Reported-by: Joao Correia <joaomiguelcorreia@gmail.com>
Diagnosed-by: John Dykstra <john.dykstra1@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/act_police.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 5c72a11..f8f047b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -183,13 +183,6 @@ override:
 		if (R_tab == NULL)
 			goto failure;
 
-		if (!est && (ret == ACT_P_CREATED ||
-			     !gen_estimator_active(&police->tcf_bstats,
-						   &police->tcf_rate_est))) {
-			err = -EINVAL;
-			goto failure;
-		}
-
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
 					       tb[TCA_POLICE_PEAKRATE]);
@@ -205,6 +198,12 @@ override:
 					    &police->tcf_lock, est);
 		if (err)
 			goto failure_unlock;
+	} else if (tb[TCA_POLICE_AVRATE] &&
+		   (ret == ACT_P_CREATED ||
+		    !gen_estimator_active(&police->tcf_bstats,
+					  &police->tcf_rate_est))) {
+		err = -EINVAL;
+		goto failure_unlock;
 	}
 
 	/* No failure allowed after this point */
