From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] {f,m}_bpf: allow for sharing maps
Date: Mon, 23 Nov 2015 16:11:48 -0800
Message-ID: <20151123161148.7553cecb@xeon-e3>
References: <fb36dba8b867c3fce59560e2a8b295c0ae13a24c.1447323729.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36047 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbKXALi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:11:38 -0500
Received: by pacdm15 with SMTP id dm15so861782pac.3
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 16:11:37 -0800 (PST)
In-Reply-To: <fb36dba8b867c3fce59560e2a8b295c0ae13a24c.1447323729.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2015 00:39:29 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> This larger work addresses one of the bigger remaining issues on
> tc's eBPF frontend, that is, to allow for persistent file descriptors.
> Whenever tc parses the ELF object, extracts and loads maps into the
> kernel, these file descriptors will be out of reach after the tc
> instance exits.
> 
> Meaning, for simple (unnested) programs which contain one or
> multiple maps, the kernel holds a reference, and they will live
> on inside the kernel until the program holding them is unloaded,
> but they will be out of reach for user space, even worse with
> (also multiple nested) tail calls.
> 
> For this issue, we introduced the concept of an agent that can
> receive the set of file descriptors from the tc instance creating
> them, in order to be able to further inspect/update map data for
> a specific use case. However, while that is more tied towards
> specific applications, it still doesn't easily allow for sharing
> maps accross multiple tc instances and would require a daemon to
> be running in the background. F.e. when a map should be shared by
> two eBPF programs, one attached to ingress, one to egress, this
> currently doesn't work with the tc frontend.
> 
> This work solves exactly that, i.e. if requested, maps can now be
> _arbitrarily_ shared between object files (PIN_GLOBAL_NS) or within
> a single object (but various program sections, PIN_OBJECT_NS) without
> "loosing" the file descriptor set. To make that happen, we use eBPF
> object pinning introduced in kernel commit b2197755b263 ("bpf: add
> support for persistent maps/progs") for exactly this purpose.
> 
> The shipped examples/bpf/bpf_shared.c code from this patch can be
> easily applied, for instance, as:
> 
>  - classifier-classifier shared:
> 
>   tc filter add dev foo parent 1: bpf obj shared.o sec egress
>   tc filter add dev foo parent ffff: bpf obj shared.o sec ingress
> 
>  - classifier-action shared (here: late binding to a dummy classifier):
> 
>   tc actions add action bpf obj shared.o sec egress pass index 42
>   tc filter add dev foo parent ffff: bpf obj shared.o sec ingress
>   tc filter add dev foo parent 1: bpf bytecode '1,6 0 0 4294967295,' \
>      action bpf index 42
> 
> The toy example increments a shared counter on egress and dumps its
> value on ingress (if no sharing (PIN_NONE) would have been chosen,
> map value is 0, of course, due to the two map instances being created):
> 
>   [...]
>           <idle>-0     [002] ..s. 38264.788234: : map val: 4
>           <idle>-0     [002] ..s. 38264.788919: : map val: 4
>           <idle>-0     [002] ..s. 38264.789599: : map val: 5
>   [...]
> 
> ... thus if both sections reference the pinned map(s) in question,
> tc will take care of fetching the appropriate file descriptor.
> 
> The patch has been tested extensively on both, classifier and
> action sides.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next branch
