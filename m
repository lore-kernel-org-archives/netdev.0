From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] bpf: introduce bpf_skb_vlan_push/pop()
 helpers
Date: Fri, 17 Jul 2015 10:12:18 +0200
Message-ID: <1437120738.1026.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
	 <1437101884-2081-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38780 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbbGQIMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:12:23 -0400
Received: by wicmv11 with SMTP id mv11so35988889wic.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 01:12:22 -0700 (PDT)
In-Reply-To: <1437101884-2081-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-16 at 19:58 -0700, Alexei Starovoitov wrote:
> In order to let eBPF programs call skb_vlan_push/pop via helper functions

Why should eBPF program do such thing ?

Are BPF users in the kernel expecting skb being changed, and are we sure
they reload all cached values when/if needed ?

> eBPF JITs need to recognize helpers that change skb->data, since
> skb->data and hlen are cached as part of JIT code generation.
> - arm64 JIT is using bpf_load_pointer() without caching, so it's ok as-is.
> - x64 JIT recognizes bpf_skb_vlan_push/pop() calls and re-caches skb->data/hlen
>   after such calls (experiments showed that conditional re-caching is slower).
> - s390 JIT falls back to interpreter for now when bpf_skb_vlan_push() is present
>   in the program (re-caching is tbd).



> +static u64 bpf_skb_vlan_push(u64 r1, u64 vlan_proto, u64 vlan_tci, u64 r4, u64 r5)
> +{
> +	struct sk_buff *skb = (struct sk_buff *) (long) r1;
> +
> +	if (unlikely(vlan_proto != htons(ETH_P_8021Q) &&
> +		     vlan_proto != htons(ETH_P_8021AD)))
> +		vlan_proto = htons(ETH_P_8021Q);


This would raise sparse error, as vlan_proto is u64, and htons() __be16

make C=2 CF=-D__CHECK_ENDIAN__ net/core/filter.o
