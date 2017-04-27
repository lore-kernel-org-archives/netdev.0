From: David Miller <davem@davemloft.net>
Subject: assembler mnenomics for call/tailcall plus maps...
Date: Thu, 27 Apr 2017 16:42:45 -0400 (EDT)
Message-ID: <20170427.164245.1980485298195850482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: ast@fb.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968884AbdD0Umr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:42:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Can you guys give me some kind of idea of how it might be nice to
represent calls and tailcalls in assembler files?

And also the emission of maps.

Right now I just have the assembler looking for 32-bit immediate
values for call and tailcall instructions.

Looking at samples/bpf/sockex3_kern.c we have:

struct bpf_map_def SEC("maps") jmp_table = {
	.type = BPF_MAP_TYPE_PROG_ARRAY,
	.key_size = sizeof(u32),
	.value_size = sizeof(u32),
	.max_entries = 8,
};

#define PARSE_VLAN 1
#define PARSE_MPLS 2
#define PARSE_IP 3
#define PARSE_IPV6 4

/* protocol dispatch routine.
 * It tail-calls next BPF program depending on eth proto
 * Note, we could have used:
 * bpf_tail_call(skb, &jmp_table, proto);
 * but it would need large prog_array
 */
static inline void parse_eth_proto(struct __sk_buff *skb, u32 proto)
{
	switch (proto) {
	case ETH_P_8021Q:
	case ETH_P_8021AD:
		bpf_tail_call(skb, &jmp_table, PARSE_VLAN);
		break;
	case ETH_P_MPLS_UC:
	case ETH_P_MPLS_MC:
		bpf_tail_call(skb, &jmp_table, PARSE_MPLS);
		break;
	case ETH_P_IP:
		bpf_tail_call(skb, &jmp_table, PARSE_IP);
		break;
	case ETH_P_IPV6:
		bpf_tail_call(skb, &jmp_table, PARSE_IPV6);
		break;
	}
}

and these bpf_tail_call() invocations seem to expand to something like:

	call	1 ! PARSE_VLAN
	call	2 ! PARSE_MPLS
	call	3 ! PARSE_IP
	call	4 ! PARSE_IPV6

in the resultant ELF file.

Thanks.
