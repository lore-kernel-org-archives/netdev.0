From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Mon, 5 Sep 2016 15:39:03 -0700
Message-ID: <57CDF407.8020706@fb.com>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
 <20160829230359.GB25396@ircssh.c.rugged-nimbus-611.internal>
 <c38e0552-f406-1d00-d5f0-1cdca7082d15@zonque.org>
 <20160905214001.GA30050@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <htejun@fb.com>, <daniel@iogearbox.net>, <davem@davemloft.net>,
        <kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
        <harald@redhat.com>, <netdev@vger.kernel.org>
To: Sargun Dhillon <sargun@sargun.me>, Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47700 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751057AbcIEWjk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 18:39:40 -0400
In-Reply-To: <20160905214001.GA30050@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/16 2:40 PM, Sargun Dhillon wrote:
> On Mon, Sep 05, 2016 at 04:49:26PM +0200, Daniel Mack wrote:
>> Hi,
>>
>> On 08/30/2016 01:04 AM, Sargun Dhillon wrote:
>>> On Fri, Aug 26, 2016 at 09:58:48PM +0200, Daniel Mack wrote:
>>>> This patch adds two sets of eBPF program pointers to struct cgroup.
>>>> One for such that are directly pinned to a cgroup, and one for such
>>>> that are effective for it.
>>>>
>>>> To illustrate the logic behind that, assume the following example
>>>> cgroup hierarchy.
>>>>
>>>>    A - B - C
>>>>          \ D - E
>>>>
>>>> If only B has a program attached, it will be effective for B, C, D
>>>> and E. If D then attaches a program itself, that will be effective for
>>>> both D and E, and the program in B will only affect B and C. Only one
>>>> program of a given type is effective for a cgroup.
>>>>
>>> How does this work when running and orchestrator within an orchestrator? The
>>> Docker in Docker / Mesos in Mesos use case, where the top level orchestrator is
>>> observing the traffic, and there is an orchestrator within that also need to run
>>> it.
>>>
>>> In this case, I'd like to run E's filter, then if it returns 0, D's, and B's,
>>> and so on.
>>
>> Running multiple programs was an idea I had in one of my earlier drafts,
>> but after some discussion, I refrained from it again because potentially
>> walking the cgroup hierarchy on every packet is just too expensive.
>>
> I think you're correct here. Maybe this is something I do with the LSM-attached
> filters, and not for skb filters. Do you think there might be a way to opt-in to
> this option?
>
>>> Is it possible to allow this, either by flattening out the
>>> datastructure (copy a ref to the bpf programs to C and E) or
>>> something similar?
>>
>> That would mean we carry a list of eBPF program pointers of dynamic
>> size. IOW, the deeper inside the cgroup hierarchy, the bigger the list,
>> so it can store a reference to all programs of all of its ancestor.
>>
>> While I think that would be possible, even at some later point, I'd
>> really like to avoid it for the sake of simplicity.
>>
>> Is there any reason why this can't be done in userspace? Compile a
>> program X for A, and overload it with Y, with Y doing the same than X
>> but add some extra checks? Note that all users of the bpf(2) syscall API
>> will need CAP_NET_ADMIN anyway, so there is no delegation to
>> unprivileged sub-orchestators or anything alike really.
>
> One of the use-cases that's becoming more and more common are
> containers-in-containers. In this, you have a privileged container that's
> running something like build orchestration, and you want to do macro-isolation
> (say limit access to only that tennant's infrastructure). Then, when the build
> orchestrator runs a build, it may want to monitor, and further isolate the tasks
> that run in the build job. This is a side-effect of composing different
> container technologies. Typically you use one system for images, then another
> for orchestration, and the actual program running inside of it can also leverage
> containerization.
>
> Example:
> K8s->Docker->Jenkins Agent->Jenkins Build Job

frankly I don't buy this argument, since above
and other 'examples' of container-in-container look
fake to me. There is a ton work to be done for such
scheme to be even remotely feasible. The cgroup+bpf
stuff would be the last on my list to 'fix' for such
deployments. I don't think we should worry about it
at present.
