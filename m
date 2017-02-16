From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Thu, 16 Feb 2017 11:08:19 +0100
Message-ID: <58A57A13.9070906@iogearbox.net>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, tj@kernel.org, luto@amacapital.net,
        ebiederm@xmission.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54289 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdBPKI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 05:08:27 -0500
In-Reply-To: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2017 02:29 AM, David Ahern wrote:
> In cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to compare the
> network namespace of the socket or packet
>
> Introduce bpf_sk_netns_cmp and bpf_skb_netns_cmp helpers to compare
> network namespace of the socket or skb to the namespace parameters
> in a prorgam.
>
> For example to disallow raw sockets in all non-init netns
> the bpf_type_cgroup_sock program can do:
> if (sk->type == SOCK_RAW && !bpf_sk_netns_cmp(sk, 0x3, 0xf0000075))
>    return 0;
>
> where 0x3 and 0xf0000075 are the st_dev and st_ino of /proc/pid/ns/net.
>
> Note that all bpf programs types are global. The same socket filter
> program can be attached to sockets in different netns,
> just like cls_bpf can see ingress/egress packets of multiple
> net_devices in different netns. The cgroup_bpf programs are
> the most exposed to sockets and devices across netns,
> but the need to identify netns applies to all.
> For example, if bpf_type_cgroup_skb didn't exist the system wide
> monitoring daemon could have used ld_preload mechanism and
> attached the same program to see traffic from applications
> across netns. Therefore make bpf_sk_netns_cmp() helper available
> to all network related bpf program types.
>
> For socket, cls_bpf and cgroup_skb programs this helper
> can be considered a new feature, whereas for cgroup_sock
> programs that modify sk->bound_dev_if (like 'ip vrf' does)
> it's a bug fix, since 'ip vrf' needs to be netns aware.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2->v3: build bot complained. s/static/static inline/. no other changes.
> v3->v4: fixed fallthrough case. Thanks Daniel.
> v4->v5: dsa converted netns_id as a u64 to netns_cmp with individual dev
>          and inode number. Updated samples test for sock bind.
[...]
> diff --git a/fs/nsfs.c b/fs/nsfs.c
> index 8c9fb29c6673..c335f513d467 100644
> --- a/fs/nsfs.c
> +++ b/fs/nsfs.c
> @@ -49,6 +49,13 @@ static void nsfs_evict(struct inode *inode)
>   	ns->ops->put(ns);
>   }
>
> +int ns_cmp(struct ns_common *ns, u64 dev, u64 ino)
> +{
> +	u64 ns_dev = new_encode_dev(nsfs_mnt->mnt_sb->s_dev);
> +
> +	return dev == ns_dev && ino == ns->inum;
> +}
> +
[...]
>   void net_drop_ns(void *);
>
> +static inline int netns_cmp(struct net *net, u64 dev, u64 ino)
> +{
> +	return ns_cmp(&net->ns, dev, ino);
> +}
> +
>   #else
[...]
>
>   /**
>    *	sk_filter_trim_cap - run a packet through a socket filter
> @@ -2597,6 +2598,39 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
>   	.arg5_type	= ARG_CONST_STACK_SIZE,
>   };
>
> +BPF_CALL_3(bpf_sk_netns_cmp, struct sock *, sk,  u64, ns_dev, u64, ns_ino)
> +{
> +	return netns_cmp(sock_net(sk), ns_dev, ns_ino);
> +}

Is there anything that speaks against doing the comparison itself
outside of the helper? Meaning, the helper would get a buffer
passed from stack f.e. struct foo { u64 ns_dev; u64 ns_ino; }
and fills both out with the netns info belonging to the sk/skb.

And the program can use that to make a match, or to use the
struct itself as a map lookup key (which in the previous patch
was also possible). Right now, such flexibility would be lost
for map usage with the above bpf_sk{,b}_netns_cmp() membership
test that checks only against one instance of ns_dev/ns_ino.

A helper used as bpf_get_netns_sk(sk, &buff, sizeof(buff)) resp.
bpf_get_netns_skb(skb, &buff, sizeof(buff)) can also still be
extended in future should something really change, f.e. we know
that the passed size must be 16 byte today, and anything else
would be rejected for now.

Thanks,
Daniel
