From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] bpf: add skb_postpush_rcsum and fix
 dev_forward_skb occasions
Date: Thu, 7 Jan 2016 10:52:40 -0800
Message-ID: <20160107185239.GA3880@ast-mbp.thefacebook.com>
References: <cover.1452176592.git.daniel@iogearbox.net>
 <ea76eeeaed015a797cef5df2533bae1ebd62aa05.1452176592.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34819 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbcAGSwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 13:52:42 -0500
Received: by mail-pa0-f53.google.com with SMTP id ho8so4353228pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 10:52:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ea76eeeaed015a797cef5df2533bae1ebd62aa05.1452176592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 03:50:23PM +0100, Daniel Borkmann wrote:
> Add a small helper skb_postpush_rcsum() and fix up redirect locations
> that need CHECKSUM_COMPLETE fixups on ingress. dev_forward_skb() expects
> a proper csum that covers also Ethernet header, f.e. since 2c26d34bbcc0
> ("net/core: Handle csum for CHECKSUM_COMPLETE VXLAN forwarding"), we
> also do skb_postpull_rcsum() after pulling Ethernet header off via
> eth_type_trans().
> 
> When using eBPF in a netns setup f.e. with vxlan in collect metadata mode,
> I can trigger the following csum issue with an IPv6 setup:
> 
>   [  505.144065] dummy1: hw csum failure
>   [...]
>   [  505.144108] Call Trace:
>   [  505.144112]  <IRQ>  [<ffffffff81372f08>] dump_stack+0x44/0x5c
>   [  505.144134]  [<ffffffff81607cea>] netdev_rx_csum_fault+0x3a/0x40
>   [  505.144142]  [<ffffffff815fee3f>] __skb_checksum_complete+0xcf/0xe0
>   [  505.144149]  [<ffffffff816f0902>] nf_ip6_checksum+0xb2/0x120
>   [  505.144161]  [<ffffffffa08c0e0e>] icmpv6_error+0x17e/0x328 [nf_conntrack_ipv6]
>   [  505.144170]  [<ffffffffa0898eca>] ? ip6t_do_table+0x2fa/0x645 [ip6_tables]
>   [  505.144177]  [<ffffffffa08c0725>] ? ipv6_get_l4proto+0x65/0xd0 [nf_conntrack_ipv6]
>   [  505.144189]  [<ffffffffa06c9a12>] nf_conntrack_in+0xc2/0x5a0 [nf_conntrack]
>   [  505.144196]  [<ffffffffa08c039c>] ipv6_conntrack_in+0x1c/0x20 [nf_conntrack_ipv6]
>   [  505.144204]  [<ffffffff8164385d>] nf_iterate+0x5d/0x70
>   [  505.144210]  [<ffffffff816438d6>] nf_hook_slow+0x66/0xc0
>   [  505.144218]  [<ffffffff816bd302>] ipv6_rcv+0x3f2/0x4f0
>   [  505.144225]  [<ffffffff816bca40>] ? ip6_make_skb+0x1b0/0x1b0
>   [  505.144232]  [<ffffffff8160b77b>] __netif_receive_skb_core+0x36b/0x9a0
>   [  505.144239]  [<ffffffff8160bdc8>] ? __netif_receive_skb+0x18/0x60
>   [  505.144245]  [<ffffffff8160bdc8>] __netif_receive_skb+0x18/0x60
>   [  505.144252]  [<ffffffff8160ccff>] process_backlog+0x9f/0x140
>   [  505.144259]  [<ffffffff8160c4a5>] net_rx_action+0x145/0x320
>   [...]
> 
> What happens is that on ingress, we push Ethernet header back in, either
> from cls_bpf or right before skb_do_redirect(), but without updating csum.
> The "hw csum failure" can be fixed by using the new skb_postpush_rcsum()
> helper for the dev_forward_skb() case to correct the csum diff again.
> 
> Thanks to Hannes Frederic Sowa for the csum_partial() idea!
> 
> Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
> Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
