From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Mon, 5 Sep 2016 16:49:26 +0200
Message-ID: <c38e0552-f406-1d00-d5f0-1cdca7082d15@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
 <20160829230359.GB25396@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:57831 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755239AbcIEOta (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 10:49:30 -0400
In-Reply-To: <20160829230359.GB25396@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 08/30/2016 01:04 AM, Sargun Dhillon wrote:
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
> How does this work when running and orchestrator within an orchestrator? The 
> Docker in Docker / Mesos in Mesos use case, where the top level orchestrator is 
> observing the traffic, and there is an orchestrator within that also need to run 
> it.
> 
> In this case, I'd like to run E's filter, then if it returns 0, D's, and B's, 
> and so on.

Running multiple programs was an idea I had in one of my earlier drafts,
but after some discussion, I refrained from it again because potentially
walking the cgroup hierarchy on every packet is just too expensive.

> Is it possible to allow this, either by flattening out the
> datastructure (copy a ref to the bpf programs to C and E) or
> something similar?

That would mean we carry a list of eBPF program pointers of dynamic
size. IOW, the deeper inside the cgroup hierarchy, the bigger the list,
so it can store a reference to all programs of all of its ancestor.

While I think that would be possible, even at some later point, I'd
really like to avoid it for the sake of simplicity.

Is there any reason why this can't be done in userspace? Compile a
program X for A, and overload it with Y, with Y doing the same than X
but add some extra checks? Note that all users of the bpf(2) syscall API
will need CAP_NET_ADMIN anyway, so there is no delegation to
unprivileged sub-orchestators or anything alike really.


Thanks,
Daniel
