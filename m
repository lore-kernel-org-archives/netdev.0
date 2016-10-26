From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 18:55:46 -0700
Message-ID: <20161026015544.GA35758@ast-mbp.thefacebook.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <580FEA98.1090809@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        daniel@zonque.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36325 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbcJZBzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 21:55:51 -0400
Received: by mail-pf0-f194.google.com with SMTP id n85so2022221pfi.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 18:55:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <580FEA98.1090809@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 01:28:24AM +0200, Daniel Borkmann wrote:
> On 10/26/2016 12:30 AM, David Ahern wrote:
> >Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
> >BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
> >any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
> >Currently only sk_bound_dev_if is exported to userspace for modification
> >by a bpf program.
> >
> >This allows a cgroup to be configured such that AF_INET{6} sockets opened
> >by processes are automatically bound to a specific device. In turn, this
> >enables the running of programs that do not support SO_BINDTODEVICE in a
> >specific VRF context / L3 domain.
> >
> >Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> [...]
> >@@ -524,6 +535,10 @@ struct bpf_tunnel_key {
> >  	__u32 tunnel_label;
> >  };
> >
> >+struct bpf_sock {
> >+	__u32 bound_dev_if;
> >+};
> >+
> >  /* User return codes for XDP prog type.
> >   * A valid XDP program must return one of these defined values. All other
> >   * return codes are reserved for future use. Unknown return codes will result
> [...]
> >diff --git a/net/core/filter.c b/net/core/filter.c
> >index 4552b8c93b99..775802881b01 100644
> >--- a/net/core/filter.c
> >+++ b/net/core/filter.c
> >@@ -2482,6 +2482,27 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
> >  	.arg5_type	= ARG_CONST_STACK_SIZE,
> >  };
> >
> >+BPF_CALL_3(bpf_sock_store_u32, struct sock *, sk, u32, offset, u32, val)
> >+{
> >+	u8 *ptr = (u8 *)sk;
> >+
> >+	if (unlikely(offset > sizeof(*sk)))
> >+		return -EFAULT;
> >+
> >+	*((u32 *)ptr) = val;
> >+
> >+	return 0;
> >+}
> 
> Seems strange to me. So, this helper allows to overwrite arbitrary memory
> of a struct sock instance. Potentially we could crash the kernel.
> 
> And in your sock_filter_convert_ctx_access(), you already implement inline
> read/write for the context ...
> 
> Your demo code does in pseudocode:
> 
>   r1 = sk
>   r2 = offsetof(struct bpf_sock, bound_dev_if)
>   r3 = idx
>   r1->sk_bound_dev_if = idx
>   sock_store_u32(r1, r2, r3) // updates sk_bound_dev_if again to idx
>   return 1
> 
> Dropping that helper from the patch, the only thing a program can do here
> is to read/write the sk_bound_dev_if helper per cgroup. Hmm ... dunno. So
> this really has to be for cgroups v2, right?

Looks pretty cool.
Same question as Daniel... why extra helper?
If program overwrites bpf_sock->sk_bound_dev_if can we use that
after program returns?
Also do you think it's possible to extend this patch to prototype
the port bind restrictions that were proposed few month back using
the same bpf_sock input structure?
Probably the check would need to be moved into different
place instead of sk_alloc(), but then we'll have more
opportunities to overwrite bound_dev_if, look at ports and so on ?
