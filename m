From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [net-next 0/2] BPF, kprobes: Add current_in_cgroup helper
Date: Sun, 7 Aug 2016 20:08:19 -0700
Message-ID: <20160808030818.GA26215@ircssh.c.rugged-nimbus-611.internal>
References: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
 <20160807043203.GA77894@ast-mbp>
 <20160807045605.GA10067@ircssh.c.rugged-nimbus-611.internal>
 <20160808005234.GA80725@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, daniel@zonque.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36607 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcHHDIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 23:08:22 -0400
Received: by mail-it0-f47.google.com with SMTP id x130so64285283ite.1
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2016 20:08:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160808005234.GA80725@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your feedback Alexei,
I really appreciate it.

On Sun, Aug 07, 2016 at 05:52:36PM -0700, Alexei Starovoitov wrote:
> On Sat, Aug 06, 2016 at 09:56:06PM -0700, Sargun Dhillon wrote:
> > On Sat, Aug 06, 2016 at 09:32:05PM -0700, Alexei Starovoitov wrote:
> > > On Sat, Aug 06, 2016 at 09:06:53PM -0700, Sargun Dhillon wrote:
> > > > This patchset includes a helper and an example to determine whether the kprobe 
> > > > is currently executing in the context of a specific cgroup based on a cgroup
> > > > bpf map / array. 
> > > 
> > > description is too short to understand how this new helper is going to be used.
> > > depending on kprobe current is not always valid.
> > Anything not in in_interrupt() should have a current, right?
> > 
> > > what are you trying to achieve?
> > This is primarily to help troubleshoot containers (Docker, and now systemd). A 
> > lot of the time we want to determine what's going on in a given container 
> > (opening files, connecting to systems, etc...). There's not really a great way 
> > to restrict to containers except by manually walking datastructures to check for 
> > the right cgroup. This seems like a better alternative.
> 
> so it's about restricting or determining?
> In other words if it's analytics/tracing that's one thing, but
> enforcement/restriction is quite different.
> For analytics one can walk task_css_set(current)->dfl_cgrp and remember
> that pointer in a map or something for stats collections and similar.
> If it's restricting apps in containers then kprobe approach
> is not usable. I don't think you'd want to built an enforcement system
> on an unstable api then can vary kernel-to-kernel.
> 
The first real-world use case are to implement something like Sysdig. Often the 
team running the team running the containers don't always know what's inside of 
them, so they want to be able to view network, I/O, and other activity by 
container. Right now, the lowest common denominator between all of the 
containerization techniques is cgroups. We've seen examples of where a admin is 
unsure of the workload, and would love to use opensnoop, but there are too many 
workloads on the machine.

Unfortunately, I don't think that it's possible just to check 
task_css_set(current)->dfl_cgrp in a bpf program. The container, especially 
containers with sidecars (what Kubernetes calls Pods, I believe?) tend to have 
multiple nested cgroups inside of them. If you had a way to convert cgroup array 
entries to pointers, I imagine you could write an unrolled loop to check for 
ownership within a limited range.

I'm still looking for comments from the LSM folks on Checmate[1]. It appears 
that there has been very little churn in the LSM hooks API that's API-breaking. 
For many of syscall hooks, they're closely tied to the syscall API, so they 
can't really change too much. I think that a toolkit like iovisor, or another 
userland translation layer, these hooks could be very powerful. I would love to 
hear feedback from the LSM folks.

My plan with those patches is to reimplement Yama, and Hardchroot in BPF 
programs to show off the potential capabilities of Checmate. I'd also like to 
create some example programs blocking CVEs that have popped up. I think of the 
idea like nftables for kernel syscalls, storage, and the network stack.

The other example I want to show is implementing Docker-bridge style network 
isolation with Checmate. Most folks use it to map ports, and to restrict binding 
to specific ports, and not the dedicated network namespace, or loopback 
interface. It turns out for some applications this comes at a pretty significant 
hit[2][3], as well as awkward upper bounds based on conntrack.

> > > This looks like an alternative to lsm patches submitted earlier?
> > No. But I would like to use this helper in the LSM patches I'm working on. For 
> > now, with those patches, and this helper, I can create a map sized 1, and add 
> > the cgroup I care about to it. Given I can add as many bpf programs to an LSM
> > hook I want, I can use this mechanism to "attach BPF programs to cgroups" -- 
> > I put that in quotes because you're not really attaching it to a cgroup,
> > but just burning some instructions on checking it. 
> 
> how many cgroups will you need to check? The current bpf_skb_in_cgroup()
> suffers similar scaling issues.
> I think the proper restriction/enforcement could be done via attaching bpf
> program to a cgroup. These patches are being worked on Daniel Mack cc-ed.
> Then bpf program will be able to enforce networking behavior of applications
> in cgroups.
> For global container analytics I think we need something that converts
> current to cgroup_id or cgroup_handle. I don't think descendant check
> can scale for such use case.
> 
Usually there's a top level cgroup for a container, and then cgroup for each 
subprocess, and maybe a third level if that fans out to multiple workers (See: 
unicorn). I see your point though about scalability, or performance issues. I 
still think a current_is_cgroup (vs in_cgroup) call would be really nice. 
Though, if we have a current_cgroup_id helper, it introduces the problem that if 
there is churn in cgroups, the ID may be reassigned. There still needs to be a 
way to keep the reference, and perhaps we just make a helper to convert cgroup 
map entires into IDs.

The approach I took in the Checmate patches allows for "attachment" to a uts 
namespace, which are perhaps the lightest, and simplest namespaces. Maybe that's 
the right direction to go, but I'm looking forward to seeing Daniel's patches.

-Thanks,
Sargun

[1] https://lkml.org/lkml/2016/8/4/58
[2] https://www.percona.com/blog/2016/02/11/measuring-docker-io-overhead/ 
[3] http://blog.pierreroudier.net/wp-content/uploads/2015/08/rc25482.pdf (warning: PDF)
