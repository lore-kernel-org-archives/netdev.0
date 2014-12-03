From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 03 Dec 2014 07:51:15 -0500
Message-ID: <547F0743.4040301@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:52961 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaLCMvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 07:51:17 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so12650082igb.17
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 04:51:17 -0800 (PST)
In-Reply-To: <1417539636-12710-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/14 12:00, Jiri Pirko wrote:
> rcu variant is not correct here. The code is called by updater (rtnl
> lock is held), not by reader (no rcu_read_lock is held).
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   net/sched/cls_bpf.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index cbfaf6f..d0de979 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -141,7 +141,7 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
>   	if (head == NULL)
>   		return 0UL;
>
> -	list_for_each_entry_rcu(prog, &head->plist, link) {
> +	list_for_each_entry(prog, &head->plist, link) {
>   		if (prog->handle == handle) {
>   			ret = (unsigned long) prog;

The above is ok i think - only one user space entrant at a time
and datapath is not affected because no modification is happening.

>   			break;
> @@ -337,7 +337,7 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
>   	struct cls_bpf_head *head = rtnl_dereference(tp->root);
>   	struct cls_bpf_prog *prog;
>
> -	list_for_each_entry_rcu(prog, &head->plist, link) {
> +	list_for_each_entry(prog, &head->plist, link) {
>   		if (arg->count < arg->skip)
>   			goto skip;
>   		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
>

I think this may be problematic. Doesnt a flush operation also use the
walker?

cheers,
jamal
