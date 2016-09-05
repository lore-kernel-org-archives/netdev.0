From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Mon, 5 Sep 2016 14:47:44 +0200
Message-ID: <2102550b-5eb4-66be-39c0-495202c60c1a@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
 <20160827000325.GA29480@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56583 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932274AbcIEMrs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 08:47:48 -0400
In-Reply-To: <20160827000325.GA29480@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

On 08/27/2016 02:03 AM, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 09:58:48PM +0200, Daniel Mack wrote:
>> This patch adds two sets of eBPF program pointers to struct cgroup.
>> One for such that are directly pinned to a cgroup, and one for such
>> that are effective for it.
>>
>> To illustrate the logic behind that, assume the following example
>> cgroup hierarchy.
>>
>>   A - B - C
>>         \ D - E
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
> ...
>> +	css_for_each_descendant_pre(pos, &cgrp->self) {
>> +		struct cgroup *desc = container_of(pos, struct cgroup, self);
>> +
>> +		/* skip the subtree if the descendant has its own program */
>> +		if (desc->bpf.prog[type] && desc != cgrp)
> 
> is desc != cgrp really needed?
> I thought css_for_each_descendant_pre() shouldn't walk itself
> or I'm missing how it works.

Hmm, no - that check is necessary in my tests, and also according to the
documentation:

/**
 * css_for_each_descendant_pre - pre-order walk of a css's descendants
 * @pos: the css * to use as the loop cursor
 * @root: css whose descendants to walk
 *
 * Walk @root's descendants.  @root is included in the iteration and the
 * first node to be visited.  Must be called under rcu_read_lock().
 *


Daniel
