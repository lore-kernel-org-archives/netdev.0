From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 3 Dec 2014 14:21:42 +0100
Message-ID: <20141203132142.GG1860@nanopsycho.orion>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
 <1417539636-12710-4-git-send-email-jiri@resnulli.us>
 <20141203121949.GA24370@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:48766 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaLCNVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:21:44 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so20052421wgh.18
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:21:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141203121949.GA24370@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 03, 2014 at 01:19:49PM CET, pablo@netfilter.org wrote:
>On Tue, Dec 02, 2014 at 06:00:33PM +0100, Jiri Pirko wrote:
>> rcu variant is not correct here. The code is called by updater (rtnl
>> lock is held), not by reader (no rcu_read_lock is held).
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/sched/cls_bpf.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
>> index cbfaf6f..d0de979 100644
>> --- a/net/sched/cls_bpf.c
>> +++ b/net/sched/cls_bpf.c
>> @@ -141,7 +141,7 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
>>  	if (head == NULL)
>>  		return 0UL;
>>  
>> -	list_for_each_entry_rcu(prog, &head->plist, link) {
>> +	list_for_each_entry(prog, &head->plist, link) {
>>  		if (prog->handle == handle) {
>>  			ret = (unsigned long) prog;
>>  			break;
>> @@ -337,7 +337,7 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
>>  	struct cls_bpf_head *head = rtnl_dereference(tp->root);
>>  	struct cls_bpf_prog *prog;
>>  
>> -	list_for_each_entry_rcu(prog, &head->plist, link) {
>> +	list_for_each_entry(prog, &head->plist, link) {
>
>We still need the _rcu here in the walk path. IIRC, this is called from the
>dump path and we hold no rtnl_lock there.

It is called from tc_dump_tfilter only. And tc_dump_tfilter is always
called with rtnl_lock

>
>>  		if (arg->count < arg->skip)
>>  			goto skip;
>>  		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
>> -- 
>> 1.9.3
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
