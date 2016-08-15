From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Sun, 14 Aug 2016 20:09:54 -0700
Message-ID: <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKfjKPuGO98S5XwVSuOcimLtZD6Y9WRQ9pvdBa16TQyFw@mail.gmail.com>
 <20160809000015.GA9866@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKJTqb25vE_TyRiv1X3tg-dU3OLXh+FxPfcBhxmQoOZ=A@mail.gmail.com>
 <57B0F768.8000307@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Reshetova, Elena" <elena.reshetova@intel.com>
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57B0F768.8000307@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 15, 2016 at 12:57:44AM +0200, Mickaël Salaün wrote:
> Hi,
> 
> I've been working on an extension to seccomp-bpf since last year and published 
> a first RFC about it [1]. I'm working on a second RFC/PoC which use eBPF 
> instead of cBPF and is more close to a common LSM than the first RFC. I plan 
> to publish this second RFC by the end of the month.
> 
Interesting. I plan on dropping another RFC close to the end of the month as 
well.

> Our approaches have some common points (i.e. use eBPF in an LSM, stacked 
> filters like seccomp) but I'm focused on a kind of unprivileged LSM (i.e. no 
> CAP_SYS_ADMIN), to make standalone sandboxes, which brings more constraints 
> (e.g. no use of unsafe functions like bpf_probe_read(), take care of privacy, 
> SUID exec, stable ABI…). However, I don't want to handle resource limits, 
> which should be the job of cgroups.
> 
Kind of. Sometimes describing these resource limits is difficult. For example, I 
have a customer who is trying to restrict containers from burning up all the 
ephemeral ports on the machine. In this, they have an incredibly elaborate chain 
of wiring to prevent a given container from connecting to the same (proto, 
destip, destport) more than 1000 times.

I'm unsure of how you'd model that in a cgroup. 

> For now, I'm focusing on file-system access control which is one of the more 
> complex system to properly filter. I also plan to support basic network access 
> control.
> 
> What you are trying to accomplish seems more related to a Netfilter extension 
> (something like ipset but with eBPF maybe?).
> 
I don't only want to do network access control, I also want to write to the 
value once it's copied into kernel space. There are lot of benefits of doing 
this at the syscall level, but the two primary ones are performance, and 
capability. 

One of the biggest complaints with our current approach to filtering & load 
balancing (iptables) is that it hides information. When people connect through 
the load balancer, they want to find out who they connected to, and without some 
high application-level mechanism, this isn't possible. On the other hand, if we 
just rewrite the destination address in the connect hook, we can pretty easily
allow them to do getpeername.

I'm curious about your filesystem access limiter. Do you have a way to make it so
that a given container can only write, say, 100mb of data to disk? 


>  Mickaël
> 
> 
> [1] http://www.openwall.com/lists/kernel-hardening/2016/03/24/2
> 
> 
> 

> On 09/08/2016 02:22, Kees Cook wrote:
> > On Mon, Aug 8, 2016 at 5:00 PM, Sargun Dhillon <sargun@sargun.me> wrote:
> >> On Mon, Aug 08, 2016 at 04:44:02PM -0700, Kees Cook wrote:
> >>> On Thu, Aug 4, 2016 at 12:11 AM, Sargun Dhillon <sargun@sargun.me> wrote:
> >>>> I distributed this patchset to linux-security-module@vger.kernel.org earlier,
> >>>> but based on the fact that the archive is down, and this is a fairly
> >>>> broad-sweeping proposal, I figured I'd grow the audience a little bit. Sorry
> >>>> if you received this multiple times.
> >>>>
> >>>> I've begun building out the skeleton of a Linux Security Module, and I'd like to
> >>>> get feedback on it. It's a skeleton, and I've only populated a few hooks, so I'm
> >>>> mostly looking for input on the general proposal, interest, and design. It's a
> >>>> minor LSM. My particular use case is one in which containers are being
> >>>> dynamically deployed to machines by internal developers in a different group.
> >>>> The point of Checmate is to act as an extensible bed for _safe_, complex
> >>>> security policies. It's nice to enable dynamic security policies that can be
> >>>> defined in C, and change as neccessary, without ever having to patch, or rebuild
> >>>> the kernel.
> >>>>
> >>>> For many of these containers, the security policies can be fairly nuanced. One
> >>>> particular one to take into account is network security. Often times,
> >>>> administrators want to prevent ingress, and egress connectivity except from a
> >>>> few select IPs. Egress filtering can be managed using net_cls, but without
> >>>> modifying running software, it's non-trivial to attach a filter to all sockets
> >>>> being created within a container. The inet_conn_request, socket_recvmsg,
> >>>> socket_sock_rcv_skb hooks make this trivial to implement.
> >>>>
> >>>> Other times, containers need to be throttled in places where there's not really
> >>>> a good place to impose that policy for software which isn't built in-house.  If
> >>>> one wants to limit file creations/sec, or reject I/O under certain
> >>>> characteristics, there's not a great place to do it now. This gives engineers a
> >>>> mechanism to write those policies.
> >>>>
> >>>> This same flexibility can be used to take existing programs and enable safe BPF
> >>>> helpers to modify memory to allow rules to pass. One example that I prototyped
> >>>> was Docker's port mapping, which has an overhead (DNAT), and there's some loss
> >>>> of fidelity in the BSD Socket API to identify what's going on. Instead, we can
> >>>> just rewrite the port in a bind, based upon some data in a BPF map, and a cgroup
> >>>> match.
> >>>>
> >>>> I can actually see other minor security modules being implemented in Checmate,
> >>>> for example, Yama, or the recently proposed Hardchroot could be reimplemented in
> >>>> BPF. Potentially, they could even be API compatible.
> >>>>
> >>>> Although, at first, much of this sounds like seccomp, it's quite different. For
> >>>> one, what we can do in the security hooks is more complex (access to kernel
> >>>> pointers). The other side of this is we can have effects on a system-wide,
> >>>> or cgroup level. This also circumvents the need for CRIU-friendly policies.
> >>>>
> >>>> Lastly, the flexibility of this mechanism allows for prevention of security
> >>>> vulnerabilities which are often complex in nature and require the interaction
> >>>> of multiple hooks (CVE-2014-9717 is a good example), and although ksplice,
> >>>> and livepatch exist, they're not always easy to use, as compared to loading
> >>>> a single bpf program across all kernels.
> >>>>
> >>>> The user-facing API is exposed via prctl as it's meant to be very simple (at
> >>>> least the kernel components). It only has three operations. For a given security
> >>>> hook, you can attach a BPF program to it, which will add it to the set of
> >>>> programs that are executed over when the hook is hit. You can reset a hook,
> >>>> which removes all program associated with a given hook, and you can set a
> >>>> deny_reset flag on a hook to prevent anyone from resetting it. It's likely that
> >>>> an individual would want to set this in any production use case.
> >>>
> >>> One fairly serious problem that seccomp had to overcome was dealing
> >>> with exec+setuid in the face of an attacker. The main example is "what
> >>> if we refuse to allow a program to drop privileges via a filter rule?"
> >>> For seccomp, no-new-privs was introduced for non-root users of
> >>> seccomp. Programmatic syscall (or LSM) filters need to deal with this,
> >>> and it's a bit ungainly. :)
> >>>
> >> Couldn't someone do the same with SELinux, or Apparmor?
> > 
> > The "big" LSMs aren't defined programmatically by non-root users, so
> > there is no risk of elevating privileges (they are already root).
> > 
> >>> Also, if you have a prctl API that already has 3 operations, you might
> >>> want to use a new syscall anyway. :)
> >>>
> >> Looking at other LSMs, they appear to expose their API via a virtual filesystem,
> >> or prctl. I followed the model of YAMA. I think there may be two more operations
> >> (detach program, and mark a hook as append-only / read-only / disabled). It
> >> seems like overkill to implement my own syscall.
> >>
> >>>> On the BPF side of it, all that's involved in the work in progress is to
> >>>> move some of the tracing helpers into the shared helpers. For example,
> >>>> it's very valuable to have access to current when enforcing a hook.
> >>>> BPF programs also have access to maps, which somewhat works around
> >>>> the need for security blobs in some cases.
> >>>
> >>> Just from a compatibility perspective, doesn't this end up exposing
> >>> kernel structures to userspace? What happens when the structures
> >>> change?
> >>>
> >> I wouldn't consider BPF userspace. Although it executes in the kernel, I
> >> wouldn't really consider it kernel space either as it's restricted to safe
> >> operations.
> >>
> >> As far as addressing this issue -- A significant part of the LSM hooks API is
> >> tied to the syscall, giving stability to those datastructures.
> > 
> > Just for the sake of clarity: they're tied to internal callers,
> > usually near syscall entry points; LSMs can't filter syscalls.
> > 
> >> If you look at
> >> the API itself a significant part of it has been untouched for 3+ years, and
> >> it's been even longer since there has been an API breaking change. On the other
> >> hand, the developer has the ability to perform arbitrary reads of kernel space
> >> using bpf_probe_read.
> > 
> > What's hilarious is that syscall API is unchanged, but LSM API keeps
> > shifting around a little at a time. So, same issues as with kprobes,
> > etc, as you mention.
> > 
> > FWIW, I'd much rather have an LSM that reacts to seccomp filters and
> > maps syscall arguments to in-kernel data structures that can be
> > examined during an LSM hook. Then we'd have both a stable API and a
> > programmatic filtering of data structures.
> > 
> >> This is addressed in the 4th patch, which requires the BPF program is compiled
> >> against the current kernel version. The userspace policy orchestration code
> >> should recompile the BPF program on the fly matching the current kernel's
> >> datastructures. There's a certain level of rope here given to the operator,
> >> and it's expected that they use it carefully. Similarly, folks could load
> >> kprobes, kmods, and other programs that have the same issues.
> > 
> > Right, perhaps I misunderstood the privilege level you were targeting.
> > :) Did you intend for unprivileged users to use this, or just the
> > init-ns root user?
> > 
> >>
> >>> And from a security perspective, programmatic examination of kernel
> >>> structures means you can trivially leak kernel memory locations and
> >>> contents. Resisting these sorts of leaks needs to be addressed too.
> >>>
> >> I'm unsure of that unintentional exfiltration of kernel memory locations is
> >> possible. You may be able to via a BPF map or similar (logging). What kinds of
> >> attacks are you thinking about specifically?
> > 
> > Well, I was looking at the example you sent, and it seemed like it had
> > raw access to kernel pointers, which means it could be programmed to
> > leak the values.
> > 
> >>> This looks like a subset of kprobes but available to non-root users,
> >>> which looks rather scary to me at first glance. :)
> >> You need CAP_SYS_ADMIN to touch this. These folks are the same ones that control
> >> SELinux, and Apparmor.
> > 
> > Ah-ha, missed that. Still, we want to keep a bright line between uid-0
> > and ring-0, and to make sure this is just init-ns CAP_SYS_ADMIN.
> > 
> > -Kees
> > 
> >>
> >>>
> >>> -Kees
> >>>
> >>>>
> >>>> I would love to know what y'all think.
> >>>>
> >>>> Sargun Dhillon (4):
> >>>>   bpf: move tracing helpers to shared helpers
> >>>>   bpf, security: Add Checmate
> >>>>   security/checmate: Add Checmate sample
> >>>>   bpf: Restrict Checmate bpf programs to current kernel ABI
> >>>>
> >>>>  include/linux/bpf.h              |   2 +
> >>>>  include/linux/checmate.h         |  38 +++++
> >>>>  include/uapi/linux/Kbuild        |   1 +
> >>>>  include/uapi/linux/bpf.h         |   1 +
> >>>>  include/uapi/linux/checmate.h    |  65 +++++++++
> >>>>  include/uapi/linux/prctl.h       |   3 +
> >>>>  kernel/bpf/helpers.c             |  34 +++++
> >>>>  kernel/bpf/syscall.c             |   2 +-
> >>>>  kernel/trace/bpf_trace.c         |  33 -----
> >>>>  samples/bpf/Makefile             |   4 +
> >>>>  samples/bpf/bpf_load.c           |  11 +-
> >>>>  samples/bpf/checmate1_kern.c     |  28 ++++
> >>>>  samples/bpf/checmate1_user.c     |  54 +++++++
> >>>>  security/Kconfig                 |   1 +
> >>>>  security/Makefile                |   2 +
> >>>>  security/checmate/Kconfig        |   6 +
> >>>>  security/checmate/Makefile       |   3 +
> >>>>  security/checmate/checmate_bpf.c |  67 +++++++++
> >>>>  security/checmate/checmate_lsm.c | 304 +++++++++++++++++++++++++++++++++++++++
> >>>>  19 files changed, 622 insertions(+), 37 deletions(-)
> >>>>  create mode 100644 include/linux/checmate.h
> >>>>  create mode 100644 include/uapi/linux/checmate.h
> >>>>  create mode 100644 samples/bpf/checmate1_kern.c
> >>>>  create mode 100644 samples/bpf/checmate1_user.c
> >>>>  create mode 100644 security/checmate/Kconfig
> >>>>  create mode 100644 security/checmate/Makefile
> >>>>  create mode 100644 security/checmate/checmate_bpf.c
> >>>>  create mode 100644 security/checmate/checmate_lsm.c
> >>>>
> >>>> --
> >>>> 2.7.4
> >>>>
> >>>
> >>>
> >>>
> >>> --
> >>> Kees Cook
> >>> Nexus Security
> > 
> > 
> > 
> 
> 



