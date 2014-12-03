From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 3 Dec 2014 14:26:35 +0100
Message-ID: <20141203132635.GH1860@nanopsycho.orion>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
 <1417539636-12710-4-git-send-email-jiri@resnulli.us>
 <547F0743.4040301@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:55766 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbaLCN0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:26:37 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so19841544wgh.40
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:26:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547F0743.4040301@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 03, 2014 at 01:51:15PM CET, jhs@mojatatu.com wrote:
>On 12/02/14 12:00, Jiri Pirko wrote:
>>rcu variant is not correct here. The code is called by updater (rtnl
>>lock is held), not by reader (no rcu_read_lock is held).
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  net/sched/cls_bpf.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>>diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
>>index cbfaf6f..d0de979 100644
>>--- a/net/sched/cls_bpf.c
>>+++ b/net/sched/cls_bpf.c
>>@@ -141,7 +141,7 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
>>  	if (head == NULL)
>>  		return 0UL;
>>
>>-	list_for_each_entry_rcu(prog, &head->plist, link) {
>>+	list_for_each_entry(prog, &head->plist, link) {
>>  		if (prog->handle == handle) {
>>  			ret = (unsigned long) prog;
>
>The above is ok i think - only one user space entrant at a time
>and datapath is not affected because no modification is happening.
>
>>  			break;
>>@@ -337,7 +337,7 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
>>  	struct cls_bpf_head *head = rtnl_dereference(tp->root);
>>  	struct cls_bpf_prog *prog;
>>
>>-	list_for_each_entry_rcu(prog, &head->plist, link) {
>>+	list_for_each_entry(prog, &head->plist, link) {
>>  		if (arg->count < arg->skip)
>>  			goto skip;
>>  		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
>>
>
>I think this may be problematic. Doesnt a flush operation also use the
>walker?

I don't believe so. Just look at tc_dump_tfilter.

But even if that would the the case, _rcu variant is wrong (yep, it
would have to be replaced by _safe variant then). 


>
>cheers,
>jamal
>
>
