From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/8] bpf: multi program support for cgroup+bpf
Date: Mon, 2 Oct 2017 21:21:23 -0700
Message-ID: <f5d34464-42a9-b51b-edc4-06c44b3c4845@fb.com>
References: <20171002234857.3707580-1-ast@fb.com>
 <20171002234857.3707580-2-ast@fb.com>
 <71bda584-d828-7472-7655-85a454dbe297@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Ahern <dsa@cumulusnetworks.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56440 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750767AbdJCEVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 00:21:47 -0400
In-Reply-To: <71bda584-d828-7472-7655-85a454dbe297@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 8:54 PM, David Ahern wrote:
> On 10/2/17 4:48 PM, Alexei Starovoitov wrote:
>> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
>> index 546113430049..70f679a94804 100644
>> --- a/kernel/bpf/cgroup.c
>> +++ b/kernel/bpf/cgroup.c
>> @@ -27,129 +27,361 @@ void cgroup_bpf_put(struct cgroup *cgrp)
>>  {
>>  	unsigned int type;
>>
>> -	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.prog); type++) {
>> -		struct bpf_prog *prog = cgrp->bpf.prog[type];
>> -
>> -		if (prog) {
>> -			bpf_prog_put(prog);
>> +	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.progs); type++) {
>> +		struct list_head *progs = &cgrp->bpf.progs[type];
>> +		struct bpf_prog_list *pl, *tmp;
>> +
>> +		list_for_each_entry_safe(pl, tmp, progs, node) {
>> +			list_del(&pl->node);
>> +			bpf_prog_put(pl->prog);
>> +			kfree(pl);
>>  			static_branch_dec(&cgroup_bpf_enabled_key);
>>  		}
>> +		bpf_prog_array_free(cgrp->bpf.effective[type]);
>> +	}
>> +}
>> +
>
> ...
>
>>
>> -	if (prog)
>> -		static_branch_inc(&cgroup_bpf_enabled_key);
>> +	/* all allocations were successful. Activate all prog arrays */
>> +	css_for_each_descendant_pre(css, &cgrp->self) {
>> +		struct cgroup *desc = container_of(css, struct cgroup, self);
>>
>> +		activate_effective_progs(desc, type, desc->bpf.inactive);
>> +		desc->bpf.inactive = NULL;
>> +	}
>> +
>> +	static_branch_inc(&cgroup_bpf_enabled_key);
>>  	if (old_prog) {
>>  		bpf_prog_put(old_prog);
>>  		static_branch_dec(&cgroup_bpf_enabled_key);
>>  	}
>>  	return 0;
>
> It's not clear to me that the static_branch_inc and static_branch_dec's
> are equal since the dec is in the loop over each program in the list,
> but the inc is not in a loop.

i'm not sure what you're trying to say.
The first loop quoted above is inside cgroup_bpf_put()
which is called when cgroup is destroyed. At this point
we're detaching and prog_put all attached programs.
While there is only one static_branch_inc() in __cgroup_bpf_attach()
that is called every time the prog is attached to a cgroup.
So what's the concern?
Note we're doing branch_dec only for progs in prog_list.
Just like we do branch_inc only for progs in prog_list.
Computing prog_array doesn't involve manipulations with prog's refcnt
and no branch_inc/dec either.
