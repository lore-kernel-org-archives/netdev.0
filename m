From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -next 4/4] cgroup: bpf: Add an example to do cgroup
 checking in BPF
Date: Tue, 21 Jun 2016 18:19:06 -0700
Message-ID: <20160622011904.GC97149@ast-mbp.thefacebook.com>
References: <1466555002-1316296-1-git-send-email-kafai@fb.com>
 <1466555002-1316296-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org
To: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466555002-1316296-5-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 05:23:22PM -0700, Martin KaFai Lau wrote:
> test_cgrp2_array_pin.c:
> A userland program that creates a bpf_map (BPF_MAP_TYPE_GROUP_ARRAY),
> pouplates/updates it with a cgroup2's backed fd and pins it to a
> bpf-fs's file.  The pinned file can be loaded by tc and then used
> by the bpf prog later.  This program can also update an existing pinned
> array and it could be useful for debugging/testing purpose.
> 
> test_cgrp2_tc_kern.c:
> A bpf prog which should be loaded by tc.  It is to demonstrate
> the usage of bpf_skb_in_cgroup.
> 
> test_cgrp2_tc.sh:
> A script that glues the test_cgrp2_array_pin.c and
> test_cgrp2_tc_kern.c together.  The idea is like:
> 1. Use test_cgrp2_array_pin.c to populate a BPF_MAP_TYPE_CGROUP_ARRAY
>    with a cgroup fd
> 2. Load the test_cgrp2_tc_kern.o by tc
> 3. Do a 'ping -6 ff02::1%ve' to ensure the packet has been
>    dropped because of a match on the cgroup
> 
> Most of the lines in test_cgrp2_tc.sh is the boilerplate
> to setup the cgroup/bpf-fs/net-devices/netns...etc.  It is
> not bulletproof on errors but should work well enough and
> give enough debug info if things did not go well.
> 
> Signed-off-by: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
> Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  samples/bpf/Makefile               |   3 +
>  samples/bpf/bpf_helpers.h          |   2 +
>  samples/bpf/test_cgrp2_array_pin.c | 109 +++++++++++++++++++++
>  samples/bpf/test_cgrp2_tc.sh       | 189 +++++++++++++++++++++++++++++++++++++
>  samples/bpf/test_cgrp2_tc_kern.c   |  71 ++++++++++++++
>  5 files changed, 374 insertions(+)
...
> +struct bpf_elf_map SEC("maps") test_cgrp2_array_pin = {
> +	.type		= BPF_MAP_TYPE_CGROUP_ARRAY,
> +	.size_key	= sizeof(uint32_t),
> +	.size_value	= sizeof(uint32_t),
> +	.pinning	= PIN_GLOBAL_NS,
> +	.max_elem	= 1,
> +};
> +
> +SEC("filter")
> +int handle_egress(struct __sk_buff *skb)
> +{
> +	void *data = (void *)(long)skb->data;
> +	struct eth_hdr *eth = data;
> +	struct ipv6hdr *ip6h = data + sizeof(*eth);
> +	void *data_end = (void *)(long)skb->data_end;
> +	char dont_care_msg[] = "dont care %04x %d\n";
> +	char pass_msg[] = "pass\n";
> +	char reject_msg[] = "reject\n";
> +
> +	/* single length check */
> +	if (data + sizeof(*eth) + sizeof(*ip6h) > data_end)
> +		return TC_ACT_OK;

love the test case.
It's using tc + clsact + cls_bpf in da mode + bpffs + direct packet access
and new cgroup helper.
All the most recent features I can think of :)

Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
