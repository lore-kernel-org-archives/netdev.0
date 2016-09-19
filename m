From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Mon, 19 Sep 2016 14:53:12 -0700
Message-ID: <20160919215311.GA9723@ircssh.c.rugged-nimbus-611.internal>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
 <20160916195728.GA14736@ircssh.c.rugged-nimbus-611.internal>
 <1918ef04-f22f-dce3-4bb4-1275936111d0@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:36007 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752725AbcISVxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:53:15 -0400
Received: by mail-it0-f41.google.com with SMTP id o3so81679897ita.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:53:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1918ef04-f22f-dce3-4bb4-1275936111d0@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 06:34:28PM +0200, Daniel Mack wrote:
> Hi,
> 
> On 09/16/2016 09:57 PM, Sargun Dhillon wrote:
> > On Wed, Sep 14, 2016 at 01:13:16PM +0200, Daniel Mack wrote:
> 
> >> I have no idea what makes you think this is limited to systemd. As I
> >> said, I provided an example for userspace that works from the command
> >> line. The same limitation apply as for all other users of cgroups.
> >>
> > So, at least in my work, we have Mesos, but on nearly every machine that Mesos 
> > runs, people also have systemd. Now, there's recently become a bit of a battle 
> > of ownership of things like cgroups on these machines. We can usually solve it 
> > by nesting under systemd cgroups, and thus so far we've avoided making too many 
> > systemd-specific concessions.
> > 
> > The reason this works (mostly), is because everything we touch has a sense of 
> > nesting, where we can apply policy at a place lower in the hierarchy, and yet 
> > systemd's monitoring and policy still stays in place. 
> > 
> > Now, with this patch, we don't have that, but I think we can reasonably add some 
> > flag like "no override" when applying policies, or alternatively something like 
> > "no new privileges", to prevent children from applying policies that override 
> > top-level policy.
> 
> Yes, but the API is already guarded by CAP_NET_ADMIN. Take that
> capability away from your children, and they can't tamper with the
> policy. Does that work for you?
> 
No. This can be addressed in a follow-on patch, but the use-case is that I have 
a container orchestrator (Docker, or Mesos), and systemd. The sysadmin controls 
systemd, and Docker is controlled by devs. Typically, the system owner wants 
some system level statistics, and filtering, and then we want to do 
per-container filtering.

We really want to be able to do nesting with userspace tools that are oblivious, 
and we want to delegate a level of the cgroup hierarchy to the tool that created 
it. I do not see Docker integrating with systemd any time soon, and that's 
really the only other alternative.

> > I realize there is a speed concern as well, but I think for 
> > people who want nested policy, we're willing to make the tradeoff. The cost
> > of traversing a few extra pointers still outweighs the overhead of network
> > namespaces, iptables, etc.. for many of us. 
> 
> Not sure. Have you tried it?
> 
Tried nested policies? Yes. I tried nested policy execution with syscalls, and I 
tested with bind and connect. The performance overhead was pretty minimal, but 
latency increased by 100 microseconds+ once the number of BPF hooks increased 
beyond 30. The BPF programs were trivial, and essentially did a map lookup, and 
returned 0.

I don't think that it's just raw cycles / execution time, but I didn't spend 
enough time digging into it to determine the performance hit. I'm waiting
for your patchset to land, and then I plan to work off of it.

> > What do you think Daniel?
> 
> I think we should look at an implementation once we really need it, and
> then revisit the performance impact. In any case, this can be changed
> under the hood, without touching the userspace API (except for adding
> flags if we need them).
> 
+1
> >> Not necessarily. You can as well do it the inetd way, and pass the
> >> socket to a process that is launched on demand, but do SO_ATTACH_FILTER
> >> + SO_LOCK_FILTER  in the middle. What happens with payload on the socket
> >> is not transparent to the launched binary at all. The proposed cgroup
> >> eBPF solution implements a very similar behavior in that regard.
> >
> > It would be nice to be able to see whether or not a filter is attached to a 
> > cgroup, but given this is going through syscalls, at least introspection
> > is possible as opposed to something like netlink.
> 
> Sure, there are many ways. I implemented the bpf cgroup logic using an
> own cgroup controller once, which made it possible to read out the
> status. But as we agreed on attaching programs through the bpf(2) system
> call, I moved back to the implementation that directly stores the
> pointers in the cgroup.
> 
> First enabling the controller through the fs-backed cgroup interface,
> then come back through the bpf(2) syscall and then go back to the fs
> interface to read out status values is a bit weird.
> 
Hrm, that makes sense. with the BPF syscall, would there be a way to get
file descriptor of the currently attached BPF program?

> >> And FWIW, I agree with Thomas - there is nothing wrong with having
> >> multiple options to use for such use-cases.
> >
> > Right now, for containers, we have netfilter and network namespaces.
> > There's a lot of performance overhead that comes with this.
> 
> Out of curiosity: Could you express that in numbers? And how exactly are
> you testing?
> 
Sure. Our workload that we use as a baseline is Redis with redis-benchmark. We 
reconnect after every connection, and we're running "isolation" between two 
containers on the same machine to try to rule out any physical infrastructure 
overhead.

So, we ran two tests with network namespaces. The first one was putting Redis 
into its own network namespace, and using tc to do some basic shaping:
Client--Veth---Host Namespace---Veth---Redis

The second was:
Client--Veth--Host Namespace+Iptables filtering--Veth--Redis. 

The second test required us to use conntrack, as we wanted stateful filtering.

Ops/sec:
Original: 4275
Situation 1: 3823
Situation 2: 1489

Latency (milliseconds):
Original: 0.69
Situation 1: 0.82
Situation 2: 2.11

This was on a (KVM) machine with 16GB of RAM, and 8 Cores where the machine was 
supposed to be dedicated to me. Given that it's not bare metal, take these 
numbers with a grain of salt.

> > Not only
> > that, but iptables doesn't really have a simple way of usage by
> > automated infrastructure. We (firewalld, systemd, dockerd, mesos)
> > end up fighting with one another for ownership over firewall rules.
> 
> Yes, that's a common problem.
> 
> > Although, I have problems with this approach, I think that it's
> > a good baseline where we can have top level owned by systemd,
> > docker underneath that, and Mesos underneath that. We can add
> > additional hooks for things like Checmate and Landlock, and
> > with a little more work, we can do compositition, solving
> > all of our problems.
> 
> It is supposed to be just a baseline, yes.
> 
> 
> Thanks for your feedback,
> Daniel
> 
