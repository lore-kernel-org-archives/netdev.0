From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/2] act_bpf, cls_bpf: send eBPF bytecode through
Date: Fri, 15 Apr 2016 12:41:05 +0200
Message-ID: <5710C541.7070609@iogearbox.net>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Quentin Monnet <quentin.monnet@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35541 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbcDOKlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 06:41:07 -0400
In-Reply-To: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Quentin,

On 04/15/2016 12:07 PM, Quentin Monnet wrote:
> When a new BPF traffic control filter or action is set up with tc, the
> bytecode is sent back to userspace through a netlink socket for cBPF, but
> not for eBPF (the file descriptor pointing to the object file containing
> the bytecode is sent instead).
>
> This patch makes cls_bpf and act_bpf modules send the bytecode for eBPF as
> well (in addition to the file descriptor).
>
> New BPF flags are used in order to differenciate what BPF version is in
> use, so that userspace tools can process the bytecode properly.
>
> Once the series is accepted and merged, it is intended to submit a patch
> for the iproute2 package, so as to fix tc utility so as to use the new
> flags and to display the bytecode in eBPF format when needed. This tc
> patch is already available at:
> https://github.com/6WIND/iproute2/commits/netlink_eBPF

Thanks for working on this, but it's unfortunately not that easy. Let
me ask, what would be the intended use-case to dump the insns?

I'm asking because if you dump them as-is, then a reinject at a later
time of that bytecode back into the kernel will most likely be rejected
by the verifier.

This is because on load time, verifier does rewrites/expansion on some
of the insns (f.e. map pointers, helper functions, ctx access etc, see
also appendix in [1]), so the code as seen in the kernel would need to
be sanitized first.

Also, how would you make sense/transform maps into a meaningful
representation (probably possible to find a scheme when they are pinned)?

Another possibility is that such programs need to be pinned (can be done
easily by tc in the background) and then implement a CRIU facility into
the bpf(2) syscall to retrieve them. tc could make use of this w/o too
much effort, and at the same time it would help CRIU folks, too. It
also seems cleaner to have only one central api (bpf(2)) to dump them,
but needs a bit of thought.

Thanks & cheers,
Daniel

   [1] http://www.netdevconf.org/1.1/proceedings/slides/borkmann-tc-classifier-cls-bpf.pdf

> Quentin Monnet (2):
>    act_bpf: send back eBPF bytecode through netlink socket
>    cls_bpf: send back eBPF bytecode through netlink socket
>
>   include/uapi/linux/pkt_cls.h       |  1 +
>   include/uapi/linux/tc_act/tc_bpf.h |  1 +
>   net/sched/act_bpf.c                | 23 +++++++++++++++++++++++
>   net/sched/cls_bpf.c                | 25 +++++++++++++++++++++++--
>   4 files changed, 48 insertions(+), 2 deletions(-)
>
