From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next 0/2] BPF, kprobes: Add current_in_cgroup helper
Date: Sun, 7 Aug 2016 17:52:36 -0700
Message-ID: <20160808005234.GA80725@ast-mbp>
References: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
 <20160807043203.GA77894@ast-mbp>
 <20160807045605.GA10067@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, daniel@zonque.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33075 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbcHHAy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 20:54:57 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so23972599pfe.0
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2016 17:54:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160807045605.GA10067@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 06, 2016 at 09:56:06PM -0700, Sargun Dhillon wrote:
> On Sat, Aug 06, 2016 at 09:32:05PM -0700, Alexei Starovoitov wrote:
> > On Sat, Aug 06, 2016 at 09:06:53PM -0700, Sargun Dhillon wrote:
> > > This patchset includes a helper and an example to determine whether the kprobe 
> > > is currently executing in the context of a specific cgroup based on a cgroup
> > > bpf map / array. 
> > 
> > description is too short to understand how this new helper is going to be used.
> > depending on kprobe current is not always valid.
> Anything not in in_interrupt() should have a current, right?
> 
> > what are you trying to achieve?
> This is primarily to help troubleshoot containers (Docker, and now systemd). A 
> lot of the time we want to determine what's going on in a given container 
> (opening files, connecting to systems, etc...). There's not really a great way 
> to restrict to containers except by manually walking datastructures to check for 
> the right cgroup. This seems like a better alternative.

so it's about restricting or determining?
In other words if it's analytics/tracing that's one thing, but
enforcement/restriction is quite different.
For analytics one can walk task_css_set(current)->dfl_cgrp and remember
that pointer in a map or something for stats collections and similar.
If it's restricting apps in containers then kprobe approach
is not usable. I don't think you'd want to built an enforcement system
on an unstable api then can vary kernel-to-kernel.

> > This looks like an alternative to lsm patches submitted earlier?
> No. But I would like to use this helper in the LSM patches I'm working on. For 
> now, with those patches, and this helper, I can create a map sized 1, and add 
> the cgroup I care about to it. Given I can add as many bpf programs to an LSM
> hook I want, I can use this mechanism to "attach BPF programs to cgroups" -- 
> I put that in quotes because you're not really attaching it to a cgroup,
> but just burning some instructions on checking it. 

how many cgroups will you need to check? The current bpf_skb_in_cgroup()
suffers similar scaling issues.
I think the proper restriction/enforcement could be done via attaching bpf
program to a cgroup. These patches are being worked on Daniel Mack cc-ed.
Then bpf program will be able to enforce networking behavior of applications
in cgroups.
For global container analytics I think we need something that converts
current to cgroup_id or cgroup_handle. I don't think descendant check
can scale for such use case.
