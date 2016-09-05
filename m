From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Mon, 5 Sep 2016 14:50:19 +0200
Message-ID: <8394d2e9-d29f-9e6c-9fd9-0cb76f107d47@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
 <57C4BA42.2090300@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Borkmann <daniel@iogearbox.net>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56617 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932413AbcIEMuW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 08:50:22 -0400
In-Reply-To: <57C4BA42.2090300@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2016 12:42 AM, Daniel Borkmann wrote:
> On 08/26/2016 09:58 PM, Daniel Mack wrote:
>> This patch adds two sets of eBPF program pointers to struct cgroup.
>> One for such that are directly pinned to a cgroup, and one for such
>> that are effective for it.
>>
>> To illustrate the logic behind that, assume the following example
>> cgroup hierarchy.
>>
>>    A - B - C
>>          \ D - E
>>
>> If only B has a program attached, it will be effective for B, C, D
>> and E. If D then attaches a program itself, that will be effective for
>> both D and E, and the program in B will only affect B and C. Only one
>> program of a given type is effective for a cgroup.
>>
>> Attaching and detaching programs will be done through the bpf(2)
>> syscall. For now, ingress and egress inet socket filtering are the
>> only supported use-cases.
>>
>> Signed-off-by: Daniel Mack <daniel@zonque.org>
> [...]
>> +void __cgroup_bpf_update(struct cgroup *cgrp,
>> +			 struct cgroup *parent,
>> +			 struct bpf_prog *prog,
>> +			 enum bpf_attach_type type)
>> +{
>> +	struct bpf_prog *old_prog, *effective;
>> +	struct cgroup_subsys_state *pos;
>> +
>> +	old_prog = xchg(cgrp->bpf.prog + type, prog);
>> +
>> +	if (prog)
>> +		static_branch_inc(&cgroup_bpf_enabled_key);
>> +
>> +	if (old_prog) {
>> +		bpf_prog_put(old_prog);
>> +		static_branch_dec(&cgroup_bpf_enabled_key);
>> +	}
>> +
>> +	effective = (!prog && parent) ?
>> +		rcu_dereference_protected(parent->bpf.effective[type],
>> +					  lockdep_is_held(&cgroup_mutex)) :
>> +		prog;
>> +
>> +	css_for_each_descendant_pre(pos, &cgrp->self) {
>> +		struct cgroup *desc = container_of(pos, struct cgroup, self);
>> +
>> +		/* skip the subtree if the descendant has its own program */
>> +		if (desc->bpf.prog[type] && desc != cgrp)
>> +			pos = css_rightmost_descendant(pos);
>> +		else
>> +			rcu_assign_pointer(desc->bpf.effective[type],
>> +					   effective);
>> +	}
> 
> Shouldn't the old_prog reference only be released right here at the end
> instead of above (otherwise this could race)?

Yes, that's right. Will change as well. Thanks for spotting!


Daniel
