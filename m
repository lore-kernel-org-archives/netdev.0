From: Sargun Dhillon <sargun@sargun.me>
Subject: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Thu, 4 Aug 2016 00:11:18 -0700
Message-ID: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

I distributed this patchset to linux-security-module@vger.kernel.org earlier, 
but based on the fact that the archive is down, and this is a fairly 
broad-sweeping proposal, I figured I'd grow the audience a little bit. Sorry
if you received this multiple times.

I've begun building out the skeleton of a Linux Security Module, and I'd like to 
get feedback on it. It's a skeleton, and I've only populated a few hooks, so I'm 
mostly looking for input on the general proposal, interest, and design. It's a 
minor LSM. My particular use case is one in which containers are being 
dynamically deployed to machines by internal developers in a different group. 
The point of Checmate is to act as an extensible bed for _safe_, complex 
security policies. It's nice to enable dynamic security policies that can be 
defined in C, and change as neccessary, without ever having to patch, or rebuild 
the kernel.

For many of these containers, the security policies can be fairly nuanced. One 
particular one to take into account is network security. Often times, 
administrators want to prevent ingress, and egress connectivity except from a 
few select IPs. Egress filtering can be managed using net_cls, but without 
modifying running software, it's non-trivial to attach a filter to all sockets 
being created within a container. The inet_conn_request, socket_recvmsg, 
socket_sock_rcv_skb hooks make this trivial to implement. 

Other times, containers need to be throttled in places where there's not really 
a good place to impose that policy for software which isn't built in-house.  If 
one wants to limit file creations/sec, or reject I/O under certain 
characteristics, there's not a great place to do it now. This gives engineers a 
mechanism to write those policies. 

This same flexibility can be used to take existing programs and enable safe BPF 
helpers to modify memory to allow rules to pass. One example that I prototyped 
was Docker's port mapping, which has an overhead (DNAT), and there's some loss 
of fidelity in the BSD Socket API to identify what's going on. Instead, we can 
just rewrite the port in a bind, based upon some data in a BPF map, and a cgroup 
match.

I can actually see other minor security modules being implemented in Checmate, 
for example, Yama, or the recently proposed Hardchroot could be reimplemented in 
BPF. Potentially, they could even be API compatible.

Although, at first, much of this sounds like seccomp, it's quite different. For
one, what we can do in the security hooks is more complex (access to kernel
pointers). The other side of this is we can have effects on a system-wide,
or cgroup level. This also circumvents the need for CRIU-friendly policies.

Lastly, the flexibility of this mechanism allows for prevention of security
vulnerabilities which are often complex in nature and require the interaction
of multiple hooks (CVE-2014-9717 is a good example), and although ksplice,
and livepatch exist, they're not always easy to use, as compared to loading
a single bpf program across all kernels.

The user-facing API is exposed via prctl as it's meant to be very simple (at 
least the kernel components). It only has three operations. For a given security 
hook, you can attach a BPF program to it, which will add it to the set of 
programs that are executed over when the hook is hit. You can reset a hook, 
which removes all program associated with a given hook, and you can set a 
deny_reset flag on a hook to prevent anyone from resetting it. It's likely that 
an individual would want to set this in any production use case.

On the BPF side of it, all that's involved in the work in progress is to
move some of the tracing helpers into the shared helpers. For example,
it's very valuable to have access to current when enforcing a hook.
BPF programs also have access to maps, which somewhat works around
the need for security blobs in some cases.

I would love to know what y'all think.

Sargun Dhillon (4):
  bpf: move tracing helpers to shared helpers
  bpf, security: Add Checmate
  security/checmate: Add Checmate sample
  bpf: Restrict Checmate bpf programs to current kernel ABI

 include/linux/bpf.h              |   2 +
 include/linux/checmate.h         |  38 +++++
 include/uapi/linux/Kbuild        |   1 +
 include/uapi/linux/bpf.h         |   1 +
 include/uapi/linux/checmate.h    |  65 +++++++++
 include/uapi/linux/prctl.h       |   3 +
 kernel/bpf/helpers.c             |  34 +++++
 kernel/bpf/syscall.c             |   2 +-
 kernel/trace/bpf_trace.c         |  33 -----
 samples/bpf/Makefile             |   4 +
 samples/bpf/bpf_load.c           |  11 +-
 samples/bpf/checmate1_kern.c     |  28 ++++
 samples/bpf/checmate1_user.c     |  54 +++++++
 security/Kconfig                 |   1 +
 security/Makefile                |   2 +
 security/checmate/Kconfig        |   6 +
 security/checmate/Makefile       |   3 +
 security/checmate/checmate_bpf.c |  67 +++++++++
 security/checmate/checmate_lsm.c | 304 +++++++++++++++++++++++++++++++++++++++
 19 files changed, 622 insertions(+), 37 deletions(-)
 create mode 100644 include/linux/checmate.h
 create mode 100644 include/uapi/linux/checmate.h
 create mode 100644 samples/bpf/checmate1_kern.c
 create mode 100644 samples/bpf/checmate1_user.c
 create mode 100644 security/checmate/Kconfig
 create mode 100644 security/checmate/Makefile
 create mode 100644 security/checmate/checmate_bpf.c
 create mode 100644 security/checmate/checmate_lsm.c

-- 
2.7.4

