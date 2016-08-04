From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Thu, 4 Aug 2016 02:24:11 -0700
Message-ID: <20160804092409.GA21986@ircssh.c.rugged-nimbus-611.internal>
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
 <CAFLxGvw2XNyfVeVjjie3UgbGA8LR2-gFhqKQhJR=1NzBP51ZkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	LSM <linux-security-module@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFLxGvw2XNyfVeVjjie3UgbGA8LR2-gFhqKQhJR=1NzBP51ZkA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 04, 2016 at 10:41:17AM +0200, Richard Weinberger wrote:
> Sargun,
> 
> On Thu, Aug 4, 2016 at 9:11 AM, Sargun Dhillon <sargun@sargun.me> wrote:
> > I distributed this patchset to linux-security-module@vger.kernel.org earlier,
> > but based on the fact that the archive is down, and this is a fairly
> > broad-sweeping proposal, I figured I'd grow the audience a little bit. Sorry
> > if you received this multiple times.
> >
> > I've begun building out the skeleton of a Linux Security Module, and I'd like to
> > get feedback on it. It's a skeleton, and I've only populated a few hooks, so I'm
> > mostly looking for input on the general proposal, interest, and design. It's a
> > minor LSM. My particular use case is one in which containers are being
> > dynamically deployed to machines by internal developers in a different group.
> > The point of Checmate is to act as an extensible bed for _safe_, complex
> > security policies. It's nice to enable dynamic security policies that can be
> > defined in C, and change as neccessary, without ever having to patch, or rebuild
> > the kernel.
> >
> > For many of these containers, the security policies can be fairly nuanced. One
> > particular one to take into account is network security. Often times,
> > administrators want to prevent ingress, and egress connectivity except from a
> > few select IPs. Egress filtering can be managed using net_cls, but without
> > modifying running software, it's non-trivial to attach a filter to all sockets
> > being created within a container. The inet_conn_request, socket_recvmsg,
> > socket_sock_rcv_skb hooks make this trivial to implement.
> 
> What is wrong with having firewall rules per container?
> Either by matching the container IP or an interface...
> 
This requires infrastructure that's not always available. For one, this approach 
typically requires a network namespace per container, and therefore a dedicated 
IP. It's pretty common [1][2] to not have an IP/container solution, nor a 
network namespace per container solution. The alternatives to have a network 
namespace without IP/container typically involve bifurcating traffic using TC 
mirred actions, and friends. This isn't really great for debuggability. Twitter 
does this with their Mesos network isolator [3]. Cgroups / net_cls is great for 
egress traffic, but not ingress.

> > Other times, containers need to be throttled in places where there's not really
> > a good place to impose that policy for software which isn't built in-house.  If
> > one wants to limit file creations/sec, or reject I/O under certain
> > characteristics, there's not a great place to do it now. This gives engineers a
> > mechanism to write those policies.
> 
> Hmm, not sure if resource control is something we want to do with an LSM.
> 
This is just an example I brought up. I know of a fairly large security vendor 
that has abuse "patterns", and locks software down if it looks "abusive". They 
do it for VMs, but it'd be nice to do similar for containers.

> > This same flexibility can be used to take existing programs and enable safe BPF
> > helpers to modify memory to allow rules to pass. One example that I prototyped
> > was Docker's port mapping, which has an overhead (DNAT), and there's some loss
> > of fidelity in the BSD Socket API to identify what's going on. Instead, we can
> > just rewrite the port in a bind, based upon some data in a BPF map, and a cgroup
> > match.
> >
> > I can actually see other minor security modules being implemented in Checmate,
> > for example, Yama, or the recently proposed Hardchroot could be reimplemented in
> > BPF. Potentially, they could even be API compatible.
> >
> > Although, at first, much of this sounds like seccomp, it's quite different. For
> > one, what we can do in the security hooks is more complex (access to kernel
> > pointers). The other side of this is we can have effects on a system-wide,
> > or cgroup level. This also circumvents the need for CRIU-friendly policies.
> 
> It is like seccomp except that you have a single rule set and target LSM hooks
> instead of syscalls, right?
You're right, it's very similar. I like to think of Checmate as nftables for 
syscalls.

It turns out having this on LSM hooks is a very big difference. Since LSM hooks 
are executed after data is copied to the kernel, you can safely dereference 
pointers and inspect the user's intentions. In one of the attached patches, I 
block traffic to AF_INET, port 1 -- there's no way to do that with seccomp(-bpf) 
today. This could also be used for things like filesystem path based filtering.

You also have full access to the gambit of eBPF, as opposed to seccomp's cBPF. 
This allows you do to a variety of things, like write your programs in C, and 
compile them down to BPF via LLVM. You also have access to maps to share 
information between programs, and tail calls to chain together policies. seccomp 
cannot easily do this because of the checkpoint requirement [4].

> 
> -- 
> Thanks,
> //richard

[1] https://docs.docker.com/engine/userguide/networking/dockernetworks/
[2] http://research.google.com/pubs/pub41684.html (Google Omega)
[3] http://mesos.readthedocs.io/en/0.22.2/network-monitoring/
[4] https://lwn.net/Articles/658422/
