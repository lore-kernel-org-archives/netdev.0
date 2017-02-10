From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Thu, 9 Feb 2017 21:22:57 -0800
Message-ID: <20170210052254.GA57910@ast-mbp.thefacebook.com>
References: <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
 <5894F19A.60305@iogearbox.net>
 <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com>
 <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
 <5898847B.2060400@iogearbox.net>
 <20170206192114.GA54756@ast-mbp.thefacebook.com>
 <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
 <589AF867.3020009@iogearbox.net>
 <c19a41f5-7737-d971-67e0-919276b47b95@cumulusnetworks.com>
 <589C51B1.5040205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Quentin Monnet <quentin.monnet@6wind.com>,
        netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36135 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750874AbdBJFYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 00:24:10 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so1739944pfo.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 21:23:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <589C51B1.5040205@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 12:25:37PM +0100, Daniel Borkmann wrote:
>
> Correct the overlap both use-cases share is the dump itself. It needs
> to be in such a condition for CRIU, that it can be reloaded eventually,

I don't think it makes sense to drag criu into this discussion.
I expressed my take on criu in the other thread. tldr:
bpf is a graph of dependencies between programs, maps, applications
and kernel events. So to save/restore this graph one would need to solve
very hard problems of stopping multiple applications at once,
stopping kernel events and so on. I don't think it's worth going that route.

> >    - Alternatively, the attach is always done by passing the FD as an
> >attribute, so the netlink dump could attach an fd to the running
> >program, return the FD as an attribute and the bpf program is retrieved
> >from the fd. This is a major departure from how dumps work with
> >processing attributes and needing to attach open files to a process will
> >be problematic. Integrating the bpf into the dump is a natural fit.
> 
> Right, I think it's a natural fit to place it into the various points/
> places where it's attached to, as we're stuck with that anyway for the
> attachment part. Meaning in cls_bpf, it would go as a mem blob into the
> netlink attribute. There would need to be a common BPF core helper that
> the various subsystem users call in order to generate that mentioned
> output format, and that resulting mem blob is then stuck into either
> nlattr, mem provided by syscall, etc.

I think if we use ten different ways to dump it, it will
complicate the user space tooling.
I'd rather see one way of doing it via new syscall command.
Pass prog_fd and it will return insns in some form.

Here is more concrete proposal:
- add two flags to PROG_LOAD:
  BPF_F_ENFORCE_STATELESS - it will require verifier to check that program
  doesn't use maps and any other global state (doesn't use bpf_redirect,
  doesn't use bpf_set_tunnel_key and tunnel_opt)
  This will ensure that program is stateless and pure instruction
  dump is meaningful. For 'ip vrf' case it will be enough.
  BPF_F_ALLOW_DUMP - it will save original program, so in the common
  case we wouldn't need to waste memory to save program

- add new bpf syscall command BPF_PROG_DUMP
  input: prog_fd, output: insns
  it will work right away with OBJ_GET command and the user will
  be able to dump stateless programs pinned in bpffs

- add approriate interfaces for different attach points to return prog_fd:
  for cgroup it will be new BPF_PROG_GET command.
  for socket it will be new getsockopt. (Actually BPF_PROG_GET can work
  for sockets too and probably better).
  for xdp and tc we need to find a way to return prog_fd.
  netlink is no good, since it would be very weird to install fd
  and return it async in netlink body. We can simply say that
  whoever wants to dump programs need to first pin them in bpffs
  and then attach to tc/xdp. iproute2 already does it anyway.
  Realistically tc/xdp programs are almost always stateful, so
  dump won't be available for them anyway.

If in the future we will discover magic way of restoring maps,
we can relax prog loading part and allow BPF_F_ALLOW_DUMP to be
used independently of BPF_F_ENFORCE_STATELESS flag.
(In the beginning these two flags would need to be used together).
Also we'll be able to extend BPF_PROG_DUMP independently
of attachment points. If we introduce something like global
variable section or read-only string section (like some folks asked)
we can dump it back. Insns will not be the only section.

My main point is that right now I'd really like to avoid
dealing with stateful bits (maps, etc), since there is no
good way of dumping it, while stateless will be enough
for 'ip vrf' and simple programs.

Thoughts?
