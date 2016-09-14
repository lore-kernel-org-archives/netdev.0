From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Tue, 13 Sep 2016 21:42:19 -0700
Message-ID: <20160914044217.GA44742@ast-mbp.thefacebook.com>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33173 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbcINEmZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 00:42:25 -0400
Content-Disposition: inline
In-Reply-To: <20160913172408.GC6138@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 07:24:08PM +0200, Pablo Neira Ayuso wrote:
> On Tue, Sep 13, 2016 at 03:31:20PM +0200, Daniel Mack wrote:
> > Hi,
> > 
> > On 09/13/2016 01:56 PM, Pablo Neira Ayuso wrote:
> > > On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
> > >> This is v5 of the patch set to allow eBPF programs for network
> > >> filtering and accounting to be attached to cgroups, so that they apply
> > >> to all sockets of all tasks placed in that cgroup. The logic also
> > >> allows to be extendeded for other cgroup based eBPF logic.
> > > 
> > > 1) This infrastructure can only be useful to systemd, or any similar
> > >    orchestration daemon. Look, you can only apply filtering policies
> > >    to processes that are launched by systemd, so this only works
> > >    for server processes.
> > 
> > Sorry, but both statements aren't true. The eBPF policies apply to every
> > process that is placed in a cgroup, and my example program in 6/6 shows
> > how that can be done from the command line.
> 
> Then you have to explain me how can anyone else than systemd use this
> infrastructure?

Sounds like systemd and bpf phobia combined :)
Jokes aside. I'm puzzled why systemd is even being mentioned here.
Here we use tupperware (our internal container management system) that
is heavily using cgroups and has nothing to do with systemd.
we're working as part of open container initiative, so hopefully soon
all container management systems will benefit from what we're building.
cgroups and bpf are crucial part of this process.

> > Also, systemd is able to control userspace processes just fine, and
> > it not limited to 'server processes'.
> 
> My main point is that those processes *need* to be launched by the
> orchestrator, which is was refering as 'server processes'.

No experience in systemd, so cannot comment about it,
but that statement is not true for our stuff.

> > > For client processes this infrastructure is
> > >    *racy*, you have to add new processes in runtime to the cgroup,
> > >    thus there will be time some little time where no filtering policy
> > >    will be applied. For quality of service, this may be an acceptable
> > >    race, but this is aiming to deploy a filtering policy.
> > 
> > That's a limitation that applies to many more control mechanisms in the
> > kernel, and it's something that can easily be solved with fork+exec.
> 
> As long as you have control to launch the processes yes, but this
> will not work in other scenarios. Just like cgroup net_cls and friends
> are broken for filtering for things that you have no control to
> fork+exec.

not true

> To use this infrastructure from a non-launcher process, you'll have to
> rely on the proc connection to subscribe to new process events, then
> echo that pid to the cgroup, and that interface is asynchronous so
> *adding new processes to the cgroup is subject to races*.

in general not true either. have you worked with cgroups or just speculating?
 
> *You're proposing a socket filtering facility that hooks layer 2
> output path*!

flashback. Not too long ago you were beating drums about netfilter
ingress hook operating at layer 2... sounds like nobody used it
and that was a bad call? Should we remove that netfilter hook then?

Our use case is different from Daniel's.
For us this cgroup+bpf is _not_ for filterting and _not_ for security.
We run a ton of tasks in cgroups that launch all sorts of
things on their own. We need to monitor what they do from networking
point of view. Therefore bpf programs need to monitor the traffic in
particular part of cgroup hierarchy. Not globally and no pass/drop decisions.
The monitoring itself is complicated. Like we need to group and
aggregate within bpf program based on certain bits of ipv6 address
and so on. bpf is only programmable engine that can do this job.
nft is simply not flexible enough to do that.
I'd really love to have an alternative to bpf for such tasks,
but you seem to spend all the energy arguing against bpf whereas
nft still has a lot to be desired.
