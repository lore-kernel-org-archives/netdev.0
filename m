From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to 'struct
 bpf_prog'
Date: Fri, 25 Jul 2014 13:25:35 +0200
Message-ID: <53D23EAF.4000001@redhat.com>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, willemb@google.com,
	pablo@netfilter.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759914AbaGYLZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 07:25:47 -0400
In-Reply-To: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ also Cc'ing Willem, Pablo ]

On 07/25/2014 10:04 AM, Alexei Starovoitov wrote:
> 'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
> as variable 'sk_filter', which makes code hard to read.
> Also it's easily confused with 'struct sock_filter'
> Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
> align the name with generic BPF use model.

Agreed, as we went for kernel/bpf/, renaming makes absolutely sense.

> The only ugly place is uapi/linux/netfilter/xt_bpf.h which
> managed to expose kernel internal structure into uapi header.
> Though it shouldn't even compile in user space, preserve the mess by
> adding empty 'struct sk_filter;' there and type cast it to 'struct bpf_prog'
> inside kernel in net/netfilter/xt_bpf.c
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>
> alternative fix for xt_bpf.h could be to replace:
>          /* only used in the kernel */
> 	struct sk_filter *filter __attribute__((aligned(8)));
> with
>          /* only used in the kernel */
> 	void *filter __attribute__((aligned(8)));
>
> but this 'void *' approach may further break broken userspace,
> whereas the fix implemented here is more seamless.

Yep, that's not good, 'struct sk_filter' should never have been in a uapi
file actually.

I think your current approach here, as you say, is more seamless, but as
the struct itself is *only* hidden inside kernel space, and there's no way
anyone can mess around with it, we might as well go for the more correct
void pointer, imho, it won't change anything in the structure size at least.

I guess the alignment in xt_bpf_info is for 32bit user space w/ 64bit kernel
space? I haven't looked so far into how exactly x_tables transfers that back
to user space, but are we effectively _leaking_ a kernel address after we
called sk_unattached_filter_create(&info->filter, ...) when dumping back to
user space? I guess for a possible leak in the _padding_ of the structure,
we might be copying gargabe from user space to kernel and back, that might
be less problematic, I think.

> Tested on x64, arm, sparc

[ Rest of the patch looks good, thanks. ]
