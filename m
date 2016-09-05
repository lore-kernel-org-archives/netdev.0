From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Mon, 5 Sep 2016 14:40:02 -0700
Message-ID: <20160905214001.GA30050@ircssh.c.rugged-nimbus-611.internal>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
 <20160829230359.GB25396@ircssh.c.rugged-nimbus-611.internal>
 <c38e0552-f406-1d00-d5f0-1cdca7082d15@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:35779 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932322AbcIEVkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 17:40:20 -0400
Received: by mail-it0-f48.google.com with SMTP id e124so163619662ith.0
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 14:40:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c38e0552-f406-1d00-d5f0-1cdca7082d15@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 05, 2016 at 04:49:26PM +0200, Daniel Mack wrote:
> Hi,
> 
> On 08/30/2016 01:04 AM, Sargun Dhillon wrote:
> > On Fri, Aug 26, 2016 at 09:58:48PM +0200, Daniel Mack wrote:
> >> This patch adds two sets of eBPF program pointers to struct cgroup.
> >> One for such that are directly pinned to a cgroup, and one for such
> >> that are effective for it.
> >>
> >> To illustrate the logic behind that, assume the following example
> >> cgroup hierarchy.
> >>
> >>   A - B - C
> >>         \ D - E
> >>
> >> If only B has a program attached, it will be effective for B, C, D
> >> and E. If D then attaches a program itself, that will be effective for
> >> both D and E, and the program in B will only affect B and C. Only one
> >> program of a given type is effective for a cgroup.
> >>
> > How does this work when running and orchestrator within an orchestrator? The 
> > Docker in Docker / Mesos in Mesos use case, where the top level orchestrator is 
> > observing the traffic, and there is an orchestrator within that also need to run 
> > it.
> > 
> > In this case, I'd like to run E's filter, then if it returns 0, D's, and B's, 
> > and so on.
> 
> Running multiple programs was an idea I had in one of my earlier drafts,
> but after some discussion, I refrained from it again because potentially
> walking the cgroup hierarchy on every packet is just too expensive.
>
I think you're correct here. Maybe this is something I do with the LSM-attached 
filters, and not for skb filters. Do you think there might be a way to opt-in to 
this option? 

> > Is it possible to allow this, either by flattening out the
> > datastructure (copy a ref to the bpf programs to C and E) or
> > something similar?
> 
> That would mean we carry a list of eBPF program pointers of dynamic
> size. IOW, the deeper inside the cgroup hierarchy, the bigger the list,
> so it can store a reference to all programs of all of its ancestor.
> 
> While I think that would be possible, even at some later point, I'd
> really like to avoid it for the sake of simplicity.
> 
> Is there any reason why this can't be done in userspace? Compile a
> program X for A, and overload it with Y, with Y doing the same than X
> but add some extra checks? Note that all users of the bpf(2) syscall API
> will need CAP_NET_ADMIN anyway, so there is no delegation to
> unprivileged sub-orchestators or anything alike really.

One of the use-cases that's becoming more and more common are 
containers-in-containers. In this, you have a privileged container that's 
running something like build orchestration, and you want to do macro-isolation 
(say limit access to only that tennant's infrastructure). Then, when the build 
orchestrator runs a build, it may want to monitor, and further isolate the tasks 
that run in the build job. This is a side-effect of composing different 
container technologies. Typically you use one system for images, then another 
for orchestration, and the actual program running inside of it can also leverage 
containerization.

Example:
K8s->Docker->Jenkins Agent->Jenkins Build Job

There's also a differentiation of ownership in each of these systems. I would 
really not require a middleware system that all my software has to talk to, 
because sometimes I'm taking off the shelf software (Jenkins), and porting it to 
containers. I think one of the pieces that's led to the success of cgroups is 
the straightforward API, and ease of use (and it's getting even easier in v2).

It's perfectly fine to give the lower level tasks CAP_NET_ADMIN, because we use 
something like seccomp-bpf plus some of the work I've been doing with the LSM to 
prevent the sub-orchestrators from accidentally blowing away the system. 
Usually, we trust these orchestrators (internal users), so it's more of a 
precautionary measure as opposed to a true security measure.

Also, rewriting BPF programs, although pretty straightforward sounds like a pain 
to do in userspace, even with a helper. If we were to take peoples programs and 
chain them together via tail call, or similar, I can imagine where rewriting a 
program might push you over the instruction limit.
> 
> 
> Thanks,
> Daniel
> 
